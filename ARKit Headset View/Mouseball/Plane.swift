
import Foundation
import SceneKit
import ARKit

class Plane: SCNNode {

    var planeGeometry: SCNBox!
    var material = GridMaterial()

    override init() {
        super.init()

        addChildNode(createPlane(x: -1,
                                  y: 0,
                                  z: 1,
                                  width: 3,
                                  length: 3,
                                  number: nil))
    }
    
    init(number: Int) {
        super.init()

        let plane = createPlane(x: 0,
                                  y: 0,
                                  z: 0,
                                  width: CGFloat(number+2)/10,
                                  length: CGFloat(number+2)/10,
                                  number: number)
        addChildNode(plane)
    }

    init(anchor: ARPlaneAnchor) {
        super.init()

        let plane = createPlane(x: anchor.center.x,
                                  y: 0,
                                  z: anchor.center.z,
                                  width: CGFloat(anchor.extent.x),
                                  length: CGFloat(anchor.extent.z),
                                  height: CGFloat(anchor.extent.y))
        addChildNode(plane)
    }

    func createPlane(x: Float, y: Float, z: Float, width: CGFloat, length: CGFloat, height: CGFloat? = 0.02, number: Int? = 1) -> SCNNode {
        planeGeometry = SCNBox(width: width,
                            height: height!,
                            length: length,
                            chamferRadius: 1)
        planeGeometry.materials = [material]

        postSizeChangeUpdates()

        let node = SCNNode(geometry: planeGeometry)
        node.position = SCNVector3(x: x, y: y, z: z)
        return node
    }

    fileprivate func postSizeChangeUpdates() {
        physicsBody = SCNPhysicsBody(type: .kinematic,
                                     shape: SCNPhysicsShape(geometry: planeGeometry,
                                                            options: nil))
    }

    func update(anchor: ARPlaneAnchor) {

        planeGeometry.width = CGFloat(anchor.extent.x)
        planeGeometry.length = CGFloat(anchor.extent.z)
        planeGeometry.height = CGFloat(anchor.extent.y)
        position = SCNVector3(x: anchor.center.x, y: 0, z: anchor.center.z)
        postSizeChangeUpdates()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
}

class GridMaterial: SCNMaterial {
    override init() {
        super.init()
        diffuse.contents = #imageLiteral(resourceName: "grid.png")
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
}

