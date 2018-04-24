
import Foundation
import SceneKit
import ARKit
import HeadSetKit

class JetFighterScene: SCNScene, ARUpdateable {
    func add(node: SCNNode, anchor: ARAnchor) {

    }

    func update(anchor: ARAnchor) {

    }

    convenience override init() {
        self.init(named: "art.scnassets/ship.scn")!
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
