import Foundation
import SceneKit

class Player: SCNNode {

    let controllerDeadZone: SCNFloat = 0.1
    let maxSpeed: SCNFloat = 1
    let inputMultiplier: SCNFloat = 100.0
    let radius: Float = 0.1

    override init() {
        super.init()
        let ball = SCNSphere(radius: CGFloat(radius))
        ball.materials = [BallMaterial()]
        geometry = ball

        physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
        physicsBody?.mass = 1.0
        physicsBody?.damping = 10
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }

    fileprivate func exceedsDeadZone(_ force: SCNVector3) -> Bool {
        return force.magnitude > controllerDeadZone
    }

    func move(in force: SCNVector3) {
        if exceedsDeadZone(force),
            !isFullSpeed() {
            physicsBody?.applyForce(force * inputMultiplier, asImpulse: false)
        }
    }

    fileprivate func isFullSpeed() -> Bool {
        return physicsBody?.velocity.magnitude ?? 0 >= maxSpeed
    }

    func respawn(at newPos: SCNVector3) {
        position = SCNVector3(x: newPos.x, y: newPos.y + 1, z: newPos.z)
        physicsBody?.velocity = SCNVector3Zero
    }
}


class BallMaterial: SCNMaterial {

    override init() {
        super.init()
        self.lightingModel = .physicallyBased
        self.diffuse.contents = UIImage(named: "slate2-tiled-albedo2")!
        self.metalness.contents = UIImage(named: "slate2-tiled-metalness")!
        self.roughness.contents = UIImage(named: "slate2-tiled-rough")!
        self.normal.contents = UIImage(named: "slate2-tiled-height")!
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
}
