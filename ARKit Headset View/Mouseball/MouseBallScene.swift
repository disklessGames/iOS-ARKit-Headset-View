
import Foundation
import SceneKit
import ARKit
import HeadSetKit

class MouseBallScene: SCNScene, ARUpdateable {

    var planes = [UUID: Plane]()

    override init() {
        super.init()

        rootNode.light = SCNLight()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }

    func add(node: SCNNode, anchor: ARAnchor) {
        if let anchor = anchor as? ARPlaneAnchor {
            let plane = Plane(anchor: anchor)
            planes[anchor.identifier] = plane
            node.addChildNode(plane)
        }
    }

    func update(anchor: ARAnchor) {
        if let plane = planes[anchor.identifier],
            let anchor = anchor as? ARPlaneAnchor {
            plane.update(anchor: anchor)
        }
    }
}
