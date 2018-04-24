
import UIKit
import SceneKit
import ARKit

enum FOV {
    case cheapHeadSet
    case rough
    case small

    var eyeFOV: Float {
        switch self {
        case .cheapHeadSet:
            return 60
        case .rough:
            return 38.5
        case .small:
            return 120
        }
    }
    var cameraImageScale: Float {
        switch self {
        case .cheapHeadSet:
            return 3.478 * 1080.0 / 720.0
        case .rough:
            return 1.739 * 1080.0 / 720.0
        case .small:
            return 8.756 * 1080.0 / 720.0
        }
    }

}
//    let eyeFOV = 90; var cameraImageScale = 6; // (Scale: 6 ± 1.0) Very Rough Guestimate.



public protocol ARUpdateable {
    func add(node: SCNNode, anchor: ARAnchor)
    func update(anchor: ARAnchor)
}

public class HeadsetViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var mainScene: ARSCNView!
    @IBOutlet weak var leftScene: ARSCNView!
    @IBOutlet weak var rightScene: ARSCNView!
    @IBOutlet weak var leftCameraView: UIImageView!
    @IBOutlet weak var rightCameraView: UIImageView!
    let eyeCamera : SCNCamera = SCNCamera()

    let interpupilaryDistance = 0.066
    let viewBackgroundColor = UIColor.black
    public var scene: ARUpdateable!
    let fov = FOV.cheapHeadSet

    func set(scene: ARUpdateable) {
        if let scene = scene as? SCNScene {
            mainScene.scene = scene
            mainScene.delegate = self
            mainScene.showsStatistics = true
            mainScene.isHidden = true

            // Set up Left-Eye SceneView
            leftScene.scene = scene
            leftScene.showsStatistics = mainScene.showsStatistics
            leftScene.isPlaying = true

            // Set up Right-Eye SceneView
            rightScene.scene = scene
            rightScene.showsStatistics = mainScene.showsStatistics
            rightScene.isPlaying = true
        }

    }

    fileprivate func configureCamera() {
        eyeCamera.zNear = 0.001
        /*
         Note:
         - camera.projectionTransform was not used as it currently prevents the simplistic setting of .fieldOfView . The lack of metal, or lower-level calculations, is likely what is causing mild latency with the camera.
         - .fieldOfView may refer to .yFov or a diagonal-fov.
         - in a STEREOSCOPIC layout on iPhone7+, the fieldOfView of one eye by default, is closer to 38.5°, than the listed default of 60°
         */
        eyeCamera.fieldOfView = CGFloat(fov.eyeFOV)
    }

    fileprivate func configureCameraViews() {
        ////////////////////////////////////////////////////////////////
        // Setup ImageViews - for rendering Camera Image
        self.leftCameraView.clipsToBounds = true
        self.leftCameraView.contentMode = UIViewContentMode.center
        self.rightCameraView.clipsToBounds = true
        self.rightCameraView.contentMode = UIViewContentMode.center
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        UIApplication.shared.isIdleTimerDisabled = true
        self.view.backgroundColor = viewBackgroundColor
        configureCamera()
    }



    public override func awakeFromNib() {
        super.awakeFromNib()

    }
    
    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        set(scene: scene)
        configureCameraViews()
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal, .vertical]
        configuration.isLightEstimationEnabled = true
        mainScene.session.run(configuration, options: [.removeExistingAnchors, .resetTracking])
    }
    
    override public func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        mainScene.session.pause()
    }

    // MARK: - ARSCNViewDelegate
    public func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        DispatchQueue.main.async {
            self.updateFrame()
        }
    }
    
    fileprivate func createPOVs() {
        /////////////////////////////////////////////
        // CREATE POINT OF VIEWS
        let pointOfView : SCNNode = SCNNode()
        pointOfView.transform = (mainScene.pointOfView?.transform)!
        pointOfView.scale = (mainScene.pointOfView?.scale)!
        // Create POV from Camera
        pointOfView.camera = eyeCamera

        // Set PointOfView for SceneView-LeftEye
        leftScene.pointOfView = pointOfView

        // Clone pointOfView for Right-Eye SceneView
        let pointOfView2 : SCNNode = (leftScene.pointOfView?.clone())!
        // Determine Adjusted Position for Right Eye
        let orientation : SCNQuaternion = pointOfView.orientation
        let orientationQuaternion : GLKQuaternion = GLKQuaternionMake(orientation.x, orientation.y, orientation.z, orientation.w)
        let eyePos : GLKVector3 = GLKVector3Make(1.0, 0.0, 0.0)
        let rotatedEyePos : GLKVector3 = GLKQuaternionRotateVector3(orientationQuaternion, eyePos)
        let rotatedEyePosSCNV : SCNVector3 = SCNVector3Make(rotatedEyePos.x, rotatedEyePos.y, rotatedEyePos.z)
        let mag : Float = Float(interpupilaryDistance)
        pointOfView2.position.x += rotatedEyePosSCNV.x * mag
        pointOfView2.position.y += rotatedEyePosSCNV.y * mag
        pointOfView2.position.z += rotatedEyePosSCNV.z * mag

        // Set PointOfView for SceneView-RightEye
        rightScene.pointOfView = pointOfView2
    }

    fileprivate func renderCameraImage() {
        ////////////////////////////////////////////
        // RENDER CAMERA IMAGE
        /*
         Note:
         - as camera.contentsTransform doesn't appear to affect the camera-image at the current time, we are re-rendering the image.
         - for performance, this should ideally be ported to metal
         */
        // Clear Original Camera-Image
        leftScene.scene.background.contents = UIColor.clear // This sets a transparent scene bg for all sceneViews - as they're all rendering the same scene.

        // Read Camera-Image
        let pixelBuffer : CVPixelBuffer? = mainScene.session.currentFrame?.capturedImage
        if pixelBuffer == nil { return }
        let ciimage = CIImage(cvPixelBuffer: pixelBuffer!)
        // Convert ciimage to cgimage, so uiimage can affect its orientation
        let context = CIContext(options: nil)
        let cgimage = context.createCGImage(ciimage, from: ciimage.extent)

        // Determine Camera-Image Scale
        var scale_custom : CGFloat = 1.0
        // let cameraImageSize : CGSize = CGSize(width: ciimage.extent.width, height: ciimage.extent.height) // 1280 x 720 on iPhone 7+
        // let eyeViewSize : CGSize = CGSize(width: self.view.bounds.width / 2, height: self.view.bounds.height) // (736/2) x 414 on iPhone 7+
        // let scale_aspectFill : CGFloat = cameraImageSize.height / eyeViewSize.height // 1.739 // fov = ~38.5 (guestimate on iPhone7+)
        // let scale_aspectFit : CGFloat = cameraImageSize.width / eyeViewSize.width // 3.478 // fov = ~60
        // scale_custom = 8.756 // (8.756) ~ appears close to 120° FOV - (guestimate on iPhone7+)
        // scale_custom = 6 // (6±1) ~ appears close-ish to 90° FOV - (guestimate on iPhone7+)
        scale_custom = CGFloat(fov.cameraImageScale)

        // Determine Camera-Image Orientation
        let imageOrientation : UIImageOrientation = (UIApplication.shared.statusBarOrientation == UIInterfaceOrientation.landscapeLeft) ? UIImageOrientation.down : UIImageOrientation.up

        // Display Camera-Image
        let uiimage = UIImage(cgImage: cgimage!, scale: scale_custom, orientation: imageOrientation)
        self.leftCameraView.image = uiimage
        self.rightCameraView.image = uiimage
    }

    func updateFrame() {
        createPOVs()
        renderCameraImage()
    }

    public static func createFromStoryBoard(with scene: ARUpdateable) -> HeadsetViewController {
        let sb = UIStoryboard(name: "Headset", bundle: Bundle(for: HeadsetViewController.self))
        let vc = sb.instantiateInitialViewController() as! HeadsetViewController
        vc.scene = scene
        return vc
    }

    public func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        scene.add(node: node, anchor: anchor)
    }

    public func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        scene.update(anchor: anchor)
    }
}
