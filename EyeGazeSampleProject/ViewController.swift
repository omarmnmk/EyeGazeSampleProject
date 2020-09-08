//
//  ViewController.swift
//  EyeGazeSampleProject
//
//  Created by Omar Namnakani on 03/09/2020.
//

import UIKit
import ARKit

class ViewController: UIViewController{
    
    
    @IBOutlet weak var sceneView: ARSCNView!
    
    
//    let screenWidth = UIScreen.main.bounds.width
//    let screenHeight = UIScreen.main.bounds.height
    
    var leftEye: SCNNode!
    var rightEye: SCNNode!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.sceneView.delegate = self
        
        sceneView.showsStatistics = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        
        // Check if the iPhone is X because its the only phone that supports TrueDepth Camera,
        // otherwise display an error message and terminate the app.
        guard ARFaceTrackingConfiguration.isSupported else {
            let alertController = UIAlertController(title: "iPhone X is not detected", message:
                                                        "You need a iPhone X to use this app", preferredStyle: UIAlertController.Style.alert)
            alertController.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
            self.present(alertController, animated: true, completion: nil)
            fatalError("ARFaceTracking is not supported on your device!")
        }
        
        // Create a session configuration
        let configuration = ARFaceTrackingConfiguration()
        
        // Run the view's session
        sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        
        // Pause the view's session
        self.sceneView.session.pause()
    }
    
    
    //MARK: A custom method used to create nodes in Cylinder shape
    private func createAnEyeNode(color : UIColor) -> SCNNode {
        
        let geometry = SCNCylinder(radius: 0.002, height: 0.2)
        geometry.radialSegmentCount = 3
        geometry.firstMaterial?.diffuse.contents = color
        
        let node = SCNNode()
        node.geometry = geometry
        node.geometry?.firstMaterial?.diffuse.contents = color
        node.opacity = 1
        node.renderingOrder = 100
        node.geometry?.firstMaterial?.readsFromDepthBuffer = false
        node.eulerAngles.x = -.pi / 2
        node.position.z = 0.1
        
        let parentNode = SCNNode()
        parentNode.addChildNode(node)
        return parentNode
        
    }
    
}


extension ViewController: ARSCNViewDelegate {
    
    //MARK: ARSCNViewDelegate
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        guard let faceAnchor = anchor as? ARFaceAnchor,
              //Ensure the Metal device used for rendering is not nil.
              let device = sceneView.device else { return nil }
        
        // Create a face geometry to be rendered by the Metal device.
        let faceGeometry = ARSCNFaceGeometry(device: device)
        
        // Create a SceneKit node based on the face geometry.
        let node = SCNNode(geometry: faceGeometry)
        node.geometry?.firstMaterial?.fillMode = .lines
        node.geometry?.firstMaterial?.transparency = 0.0
        
        // Configure the left and right eyes nodes and add them to SceneKit node
        leftEye = createAnEyeNode(color: UIColor.purple)
        rightEye = createAnEyeNode(color: UIColor.orange)
        
        node.addChildNode(leftEye)
        node.addChildNode(rightEye)
        
        return node
    }
    
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        
        guard  let faceAnchor = anchor as? ARFaceAnchor,
               let faceGeometry = node.geometry as? ARSCNFaceGeometry else { return }
        
        // Update The Transform Of The Left & Right Eyes From The Anchor Transform
        leftEye.simdTransform = faceAnchor.leftEyeTransform
        rightEye.simdTransform = faceAnchor.rightEyeTransform
        
        // Update the ARSCNFaceGeometry using the ARFaceAnchor’s ARFaceGeometry
        faceGeometry.update(from: faceAnchor.geometry)
        
        update(withFaceAnchor: faceAnchor)
    }
    
    
    // MARK: update(ARFaceAnchor)
    func update(withFaceAnchor anchor: ARFaceAnchor) {
        
//        let rotate:matrix_float4x4 =
//            simd_float4x4(SCNMatrix4Mult(SCNMatrix4MakeRotation(-Float.pi / 2.0, 1, 0, 0), SCNMatrix4MakeTranslation(0, 0, 0.1/2)))
        
        leftEye.simdTransform = anchor.leftEyeTransform
        rightEye.simdTransform = anchor.rightEyeTransform
        
    }
    
    
    
    
    
}
