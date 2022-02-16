//
//  GameScene.swift
//  ParticleWar Shared
//
//  Created by Lawrence Bensaid on 2/8/22.
//

import SpriteKit

class GameScene: SKScene, ObservableObject {
    
    private var sourceTouch: CGPoint?
    private var targetTouch: CGPoint?
    private let dragLine = SKShapeNode()
    private var rangeIndicators: [Client: RangeIndicator] = [:]
//    private var supplylines: [Client: [SupplyLine]] = [:]
    
    public var territories: [SKNode: Territory] = [:]
    public var armies: [SKNode: Army] = [:]
    
    public var level: Level?
    
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
    
    private func add(_ territory: Territory, at position: CGPoint? = nil) {
        if let position = position {
            territory.position = position
        }
        territories[territory.node] = territory
        super.addChild(territory.node)
    }
    
    private func getLevel() {
        
        if let path = Bundle.main.path(forResource: "level", ofType: "json") {
            guard let data = try? Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe) else { return }
            let decoder = JSONDecoder()
            decoder.userInfo = [.context: self]
            guard let level = try? decoder.decode(Level.self, from: data) else { return }
            self.level = level
        }
        
    }
    
    private func setUpScene() {
        let label = self.childNode(withName: "//helloLabel") as? SKLabelNode
        label?.removeFromParent()
        
        getLevel()
        
        guard let level = level else { return }
        level.register(self)
        level.set(player: Client(level.getTeamBy(name: "Blue")!, showActions: true))
        level.add(bot: Bot(client: Client(level.getTeamBy(name: "Red")!, showActions: true)))
        level.add(bot: Bot(client: Client(level.getTeamBy(name: "Yellow")!, showActions: true)))
        level.add(bot: Bot(client: Client(level.getTeamBy(name: "Green")!, showActions: true)))
        
        for team in level.teams {
            let label = SKLabelNode(text: "\(team.name)")
            label.position = .init(x: -frame.width / 2 - 100, y: -frame.height / 2 - 100)
            addChild(label)
        }
        
        for structure in level.structures {
            add(structure)
        }
        
        // HUD
        dragLine.lineWidth = 8
        addChild(dragLine)
    }
    
    override func update(_ currentTime: TimeInterval) {

        for bot in level?.bots ?? [] {
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
                level?.player?.tap(node.position)
                break
            }
            for territory in territories {
                if let sourceTouch = sourceTouch, sourceTouch != targetTouch {
                    level?.player?.drag(from: sourceTouch, to: territory.position)
                    break
                } else {
                    level?.player?.tap(territory.position)
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
        print("\(territories.count)/\(nodes.count)")
        if let node = nodes.first, territories.count == 0 {
            level?.player?.tap(node.position)
            return
        }
        for territory in territories {
            if let sourceTouch = sourceTouch, sourceTouch != targetTouch {
                level?.player?.drag(from: sourceTouch, to: territory.position)
                break
            } else {
                level?.player?.tap(territory.position)
                break
            }
        }
        targetTouch = nil
    }
    
}
#endif

