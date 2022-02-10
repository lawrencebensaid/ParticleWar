//
//  GameScene.swift
//  DotWars Shared
//
//  Created by Lawrence Bensaid on 2/8/22.
//

import SpriteKit

class GameScene: SKScene {
    
    private var sourceTouch: CGPoint?
    private var targetTouch: CGPoint?
    private let dragLine = SKShapeNode()
    private var rangeIndicators: [Client: RangeIndicator] = [:]
    
    class func newGameScene() -> GameScene {
        guard let scene = SKScene(fileNamed: "GameScene") as? GameScene else {
            print("Failed to load GameScene.sks")
            abort()
        }
        scene.scaleMode = .aspectFill
        return scene
    }
    
    override func didMove(to view: SKView) {
        self.setUpScene()
    }
    
    public func highlight(_ territory: Territory, by client: Client) {
        if rangeIndicators[client] == nil {
            let indicator = RangeIndicator()
            rangeIndicators[client] = indicator
            addChild(indicator)
        }
        let indicator = rangeIndicators[client]
        indicator?.size(territory.range)
        indicator?.color(territory.team?.color ?? .lightGray)
        indicator?.position = territory.position
    }
    
    public func resetHighlight(_ client: Client) {
        rangeIndicators[client]?.removeFromParent()
        rangeIndicators.removeValue(forKey: client)
    }
    
    public func deployArmy(from origin: Territory, to target: Territory) {
        let army = Army(origin: origin, target: target)
        addChild(army)
    }
    
    private func setUpScene() {
        let label = self.childNode(withName: "//helloLabel") as? SKLabelNode
        label?.removeFromParent()
        
        Game.main.register(self)
        Game.main.set(player: Client(.blue, showActions: true))
        Game.main.add(bot: Bot(client: Client(.red, showActions: true)))
        Game.main.add(bot: Bot(client: Client(.yellow, showActions: true)))
        Game.main.add(bot: Bot(client: Client(.green, showActions: true)))
        
        // HUD
        dragLine.strokeColor = .white
        dragLine.lineWidth = 8
        addChild(dragLine)
        
        // Center
        addChild(Territory(position: .init(x: 0, y: 150), context: self))
        addChild(Territory(position: .init(x: 0, y: 0), context: self))
        addChild(Territory(position: .init(x: 0, y: -150), context: self))
        
        // Right
        addChild(Territory(position: .init(x: 150, y: 75), context: self))
        addChild(Territory(position: .init(x: 150, y: -75), context: self))
        addChild(Territory(position: .init(x: 250, y: 50), context: self))
        addChild(Territory(position: .init(x: 250, y: -50), context: self))
        addChild(Territory(position: .init(x: 250, y: 150), context: self))
        addChild(Territory(position: .init(x: 250, y: -150), context: self))
        
        // Left
        addChild(Territory(position: .init(x: -150, y: 75), context: self))
        addChild(Territory(position: .init(x: -150, y: -75), context: self))
        addChild(Territory(position: .init(x: -250, y: 50), context: self))
        addChild(Territory(position: .init(x: -250, y: -50), context: self))
        addChild(Territory(position: .init(x: -250, y: 150), context: self))
        addChild(Territory(position: .init(x: -250, y: -150), context: self))
        
        // Corners
        addChild(HomeTerritory(team: .blue, position: .init(x: 400, y: 100), context: self))
        addChild(HomeTerritory(team: .green, position: .init(x: 400, y: -100), context: self))
        addChild(HomeTerritory(team: .red, position: .init(x: -400, y: 100), context: self))
        addChild(HomeTerritory(team: .yellow, position: .init(x: -400, y: -100), context: self))
    }
    
    public private(set) var territories: [SKNode: Territory] = [:]
    
    func addChild(_ territory: Territory) {
        territories[territory.node] = territory
        super.addChild(territory.node)
    }
    
    override func update(_ currentTime: TimeInterval) {

        for bot in Game.main.bots {
            bot.update()
        }
        
        for node in children {
            if let tower = territories[node] {
                tower.update()
            }
            if let army = node as? Army {
                guard let origin = army.origin else { continue }
                guard let target = army.target else { continue }
                if army.intersects(target.node) {
                    target.receive(army)
                    continue
                }
                let speed: CGFloat = 1
                let x = target.position.x - origin.position.x
                let y = target.position.y - origin.position.y
                let angle = atan2(y, x)
                let vx = cos(angle) * speed
                let vy = sin(angle) * speed
                army.position.x += vx
                army.position.y += vy
            }
        }
        
        if let sourceTouch = sourceTouch, let targetTouch = targetTouch {
            let path = CGMutablePath()
            path.move(to: sourceTouch)
            path.addLine(to: targetTouch)
            dragLine.path = path
        } else {
            dragLine.path = nil
        }
    }
    
}

#if os(iOS) || os(tvOS)
// Touch-based event handling
extension GameScene {
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches {
            let nodes = nodes(at: t.location(in: self))
            for node in nodes {
                if let tower = territories[node] {
                    targetTouch = nil
                    sourceTouch = tower.position
                }
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches {
            var point = t.location(in: self)
            let nodes = nodes(at: point)
            for node in nodes {
                if let tower = territories[node] {
                    point = tower.position
                    break
                }
            }
            targetTouch = point
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        targetTouch = nil
        for t in touches {
            let nodes = nodes(at: t.location(in: self))
            let territories = nodes.compactMap({ self.territories[$0] })
            if let node = nodes.first, territories.count == 0 {
                Game.main.player?.tap(node.position)
                break
            }
            for territory in territories {
                if let sourceTouch = sourceTouch, targetTouch != nil {
                    Game.main.player?.drag(from: sourceTouch, to: territory.position)
                    break
                } else {
                    Game.main.player?.tap(territory.position)
                    break
                }
            }
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("touchesCancelled()")
    }
    
}
#endif

#if os(OSX)
// Mouse-based event handling
extension GameScene {
    
    override func mouseDown(with event: NSEvent) {
        if let label = self.label {
            label.run(SKAction.init(named: "Pulse")!, withKey: "fadeInOut")
        }
        addChild(Army(position: t.location(in: self), color: .green))
    }
    
    override func mouseDragged(with event: NSEvent) {
        addChild(Army(position: t.location(in: self), color: .blue))
    }
    
    override func mouseUp(with event: NSEvent) {
        addChild(Army(position: t.location(in: self), color: .red))
    }
    
}
#endif

