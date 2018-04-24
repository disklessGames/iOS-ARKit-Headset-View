import XCTest
import SceneKit

@testable import HeadSetKit

class ViewControllerTests: XCTestCase {

    let sut = HeadsetViewController.createFromStoryBoard(with: SCNScene())

    override func setUp() {
        super.setUp()
        _ = sut.view
    }


    func testInit_CreatesAllViews() {

        XCTAssertNotNil(sut.mainScene)
        XCTAssertNotNil(sut.leftScene)
        XCTAssertNotNil(sut.rightScene)
    }

    func testSetScene_UpdatesSceneViews() {

        let scene = SCNScene()

        sut.set(scene: scene)

        XCTAssertEqual(sut.mainScene.scene, scene)
        XCTAssertEqual(sut.leftScene.scene, scene)
        XCTAssertEqual(sut.rightScene.scene, scene)
    }
}
