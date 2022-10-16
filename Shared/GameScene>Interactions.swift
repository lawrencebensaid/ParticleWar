//
//  GameScene>Interactions.swift
//  ParticleWar
//
//  Created by Lawrence Bensaid on 10/16/22.
//

import SpriteKit

#if os(iOS) || os(tvOS)
extension GameScene {
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let camera = self.camera else { print("NO CAMEREA"); return }
        for touch in touches {
            let point = touch.location(in: self)
            previousCameraPoint = camera.position
            previousDragPoint = point
            
            if touch.tapCount == 2 {
                let move: SKAction = .move(to: CGPoint(x: point.x, y: point.y), duration: 0.5)
                move.timingMode = .easeOut
                camera.move(toParent: self)
                camera.run(move, withKey: "moving")
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let camera = self.camera else { print("NO CAMEREA"); return }
        for touch in touches {
            let point = touch.location(in: self)
            if let player = level?.player {
                player.tap(point)
            }
            
            // Bring camera back from the void
            let boundry: CGFloat = 800
            if camera.position.x > boundry || camera.position.x < -boundry || camera.position.y > boundry || camera.position.y < -boundry {
                let points = self.territories.keys.map({ $0.position })
                guard let target = camera.position.nearest(points).first else { return }
                let move: SKAction = .move(to: target, duration: 0.4)
                move.timingMode = .easeOut
                camera.move(toParent: self)
                camera.run(move, withKey: "moving")
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let camera = self.camera else { print("NO CAMEREA"); return }
        for touch in touches {
            let point = touch.location(in: self)
            let translation = CGPoint(
                x: point.x - previousDragPoint.x,
                y: point.y - previousDragPoint.y
            )
            let newPosition = CGPoint(
                x: previousCameraPoint.x + translation.x * -camera.xScale,
                y: previousCameraPoint.y + translation.y * -camera.xScale
            )
            previousCameraPoint = newPosition
            camera.position = newPosition
        }
    }
    
}
#endif

#if os(macOS)
extension GameScene {
    
    override func mouseDown(with event: NSEvent) {
        guard let camera = self.camera else { print("NO CAMEREA"); return }
        let point = event.location(in: self)
        previousCameraPoint = camera.position
        previousDragPoint = point
        
        if event.clickCount == 2 {
            let move: SKAction = .move(to: CGPoint(x: point.x, y: point.y), duration: 0.5)
            move.timingMode = .easeOut
            camera.move(toParent: self)
            camera.run(move, withKey: "moving")
        }
    }
    
    override func mouseUp(with event: NSEvent) {
        guard let camera = self.camera else { print("NO CAMEREA"); return }
        let point = event.location(in: self)
        if let player = level?.player {
            player.tap(point)
        }
        
        // Bring camera back from the void
        let boundry: CGFloat = 400
        if camera.position.x > boundry || camera.position.x < -boundry || camera.position.y > boundry || camera.position.y < -boundry {
            let points = self.territories.keys.map({ $0.position })
            guard let target = camera.position.nearest(points).first else { return }
            let move: SKAction = .move(to: target, duration: 0.4)
            move.timingMode = .easeOut
            camera.move(toParent: self)
            camera.run(move, withKey: "moving")
        }
    }
    
    override func mouseDragged(with event: NSEvent) {
        guard let camera = self.camera else { print("NO CAMEREA"); return }
        let point = event.location(in: self)
        let translation = CGPoint(
            x: point.x - previousDragPoint.x,
            y: point.y - previousDragPoint.y
        )
        let newPosition = CGPoint(
            x: previousCameraPoint.x + translation.x * -camera.xScale,
            y: previousCameraPoint.y + translation.y * -camera.xScale
        )
        previousCameraPoint = newPosition
        camera.position = newPosition
    }
    
}
#endif
