//
//  GameScene.swift
//  ParticleWar Shared
//
//  Created by Lawrence Bensaid on 2/8/22.
//

import SpriteKit

class GameScene: SKScene {
    
    private var sourceTouch: CGPoint?
    private var targetTouch: CGPoint?
    private let dragLine = SKShapeNode()
    private var rangeIndicators: [Client: RangeIndicator] = [:]
//    private var supplylines: [Client: [SupplyLine]] = [:]
    
    public var territories: [SKNode: Territory] = [:]
    public var armies: [SKNode: Army] = [:]
    
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
        let army = Army(team: origin.team, target: target, context: self)
        army.position = origin.position
        armies[army.node] = army
        super.addChild(army.node)
    }
    
    public func deployHighway(from origin: Territory, to target: Territory) {
        let highway = Highway(origin: origin, target: target)
        super.addChild(highway.node)
    }
    
    private func add(_ territory: Territory, at position: CGPoint) {
        territory.position = position
        territories[territory.node] = territory
        super.addChild(territory.node)
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
        dragLine.lineWidth = 8
        addChild(dragLine)
        
        // Center
        add(Territory(context: self), at: .init(x: 0, y: 150))
        add(Territory(context: self), at: .init(x: 0, y: 0))
        add(Territory(context: self), at: .init(x: 0, y: -150))
        
        // Right
        add(Territory(context: self), at: .init(x: 150, y: 75))
        add(Territory(context: self), at: .init(x: 150, y: -75))
        add(Territory(context: self), at: .init(x: 250, y: 50))
        add(Territory(context: self), at: .init(x: 250, y: -50))
        add(Territory(context: self), at: .init(x: 250, y: 150))
        add(Territory(context: self), at: .init(x: 250, y: -150))
        
        // Left
        add(Territory(context: self), at: .init(x: -150, y: 75))
        add(Territory(context: self), at: .init(x: -150, y: -75))
        add(Territory(context: self), at: .init(x: -250, y: 50))
        add(Territory(context: self), at: .init(x: -250, y: -50))
        add(Territory(context: self), at: .init(x: -250, y: 150))
        add(Territory(context: self), at: .init(x: -250, y: -150))
        
        // Corners
        add(HomeTerritory(team: .blue, context: self), at: .init(x: 400, y: 100))
        add(HomeTerritory(team: .green, context: self), at: .init(x: 400, y: -100))
        add(HomeTerritory(team: .red, context: self), at: .init(x: -400, y: 100))
        add(HomeTerritory(team: .yellow, context: self), at: .init(x: -400, y: -100))
    }
    
    override func update(_ currentTime: TimeInterval) {

        for bot in Game.main.bots {
            bot.update()
        }
        
        for node in children {
            if let tower = territories[node] {
                tower.update()
            }
            if let army = armies[node] {
                guard let target = army.target else { continue }
                if army.node.intersects(target.node) {
                    target.receive(army)
                    continue
                }
                let speed: CGFloat = 1
                let x = target.position.x - army.position.x
                let y = target.position.y - army.position.y
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
                    dragLine.strokeColor = tower.color!
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
        for t in touches {
            let nodes = nodes(at: t.location(in: self))
            let territories = nodes.compactMap({ self.territories[$0] })
            if let node = nodes.first, territories.count == 0 {
                Game.main.player?.tap(node.position)
                break
            }
            for territory in territories {
                if let sourceTouch = sourceTouch, sourceTouch != targetTouch {
                    Game.main.player?.drag(from: sourceTouch, to: territory.position)
                    break
                } else {
                    Game.main.player?.tap(territory.position)
                    break
                }
            }
        }
        targetTouch = nil
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
        let nodes = nodes(at: event.location(in: self))
        for node in nodes {
            if let tower = territories[node] {
                targetTouch = nil
                sourceTouch = tower.position
                dragLine.strokeColor = tower.color!
            }
        }
    }
    
    override func mouseDragged(with event: NSEvent) {
        var point = event.location(in: self)
        let nodes = nodes(at: point)
        for node in nodes {
            if let tower = territories[node] {
                point = tower.position
                break
            }
        }
        targetTouch = point
    }
    
    override func mouseUp(with event: NSEvent) {
        let nodes = nodes(at: event.location(in: self))
        let territories = nodes.compactMap({ self.territories[$0] })
        if let node = nodes.first, territories.count == 0 {
            Game.main.player?.tap(node.position)
            return
        }
        for territory in territories {
            if let sourceTouch = sourceTouch, sourceTouch != targetTouch {
                Game.main.player?.drag(from: sourceTouch, to: territory.position)
                return
            } else {
                Game.main.player?.tap(territory.position)
                return
            }
        }
        targetTouch = nil
    }
    
}
#endif

