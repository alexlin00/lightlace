/*
See LICENSE folder for this sample’s licensing information.

Abstract:
The sample app's main view controller.
*/

import UIKit
import RealityKit
import ARKit
import Combine

class ViewController: UIViewController, ARSessionDelegate {

    @IBOutlet var arView: ARView!
    
    // The 3D character to display.
    var character: BodyTrackedEntity?
    let characterOffset: SIMD3<Float> = [-1.0, 0, 0] // Offset the character by one meter to the left
    let characterAnchor = AnchorEntity()
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        arView.session.delegate = self
        
        // If the iOS device doesn't support body tracking, raise a developer error for
        // this unhandled case.
        guard ARBodyTrackingConfiguration.isSupported else {
            fatalError("This feature is only supported on devices with an A12 chip")
        }

        // Run a body tracking configration.
        let configuration = ARBodyTrackingConfiguration()
        arView.session.run(configuration)
        
        arView.scene.addAnchor(characterAnchor)
        
        // Asynchronously load the 3D character.
        var cancellable: AnyCancellable? = nil
        cancellable = Entity.loadBodyTrackedAsync(named: "character/robot").sink(
            receiveCompletion: { completion in
                if case let .failure(error) = completion {
                    print("Error: Unable to load model: \(error.localizedDescription)")
                }
                cancellable?.cancel()
        }, receiveValue: { (character: Entity) in
            if let character = character as? BodyTrackedEntity {
                // Scale the character to human size
                character.scale = [1.0, 1.0, 1.0]
                self.character = character
                
                cancellable?.cancel()
            } else {
                print("Error: Unable to load model as BodyTrackedEntity")
            }
        })
    }
    
    func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
        for anchor in anchors {
            guard let bodyAnchor = anchor as? ARBodyAnchor else { continue }
            
            // Update the position of the character anchor's position.
            let bodyPosition = simd_make_float3(bodyAnchor.transform.columns.3)
            characterAnchor.position = bodyPosition + characterOffset
            // Also copy over the rotation of the body anchor, because the skeleton's pose
            // in the world is relative to the body anchor's rotation.
            characterAnchor.orientation = Transform(matrix: bodyAnchor.transform).rotation
   
            if let character = character, character.parent == nil {
                // Attach the character to its anchor as soon as
                // 1. the body anchor was detected and
                // 2. the character was loaded.
                characterAnchor.addChild(character)
                
                
                calcAngle(anchor: bodyAnchor)
            }
        }
        
    }
    
    func calcAngle(anchor: ARBodyAnchor) {
        let skeleton = anchor.skeleton
        
        guard let rightHand = skeleton.modelTransform(for: .rightHand)?.columns.3
        else {
            print("fail right hand")
            return
            
        }
        guard let rightElbow = skeleton.modelTransform(for: ARSkeleton.JointName(rawValue: "right_forearm_joint"))?.columns.3
        else {
            print("fail right elbow")
            return
        }
        guard let rightArm = skeleton.modelTransform(for: .rightShoulder)?.columns.3
        else {
            print("fail right arm")
            return
        }
        guard let leftHand = skeleton.modelTransform(for: .leftHand)?.columns.3
        else {
            print("fail left hand")
            return
        }
        guard let leftElbow = skeleton.modelTransform(for: ARSkeleton.JointName(rawValue: "left_forearm_joint"))?.columns.3
        else {
            print("fail left elbow")
            return
        }
        guard let leftArm = skeleton.modelTransform(for: .leftShoulder)?.columns.3
        else {
            print("fail right arm")
            return
        }
        
        let r1 = distance(rightHand, rightElbow)
        let r2 = distance(rightArm, rightElbow)
        let r3 = distance(rightHand, rightArm)
        let l1 = distance(leftHand, leftElbow)
        let l2 = distance(leftArm, leftElbow)
        let l3 = distance(leftHand, leftArm)
        
        print("r1 is \(r1)")
        print("r2 is \(r2)")
        print("r3 is \(r3)")
        print("l1 is \(l1)")
        print("l2 is \(l2)")
        print("l3 is \(l3)")
        
        
        let x = (powf(r1,2) + powf(r2,2) - powf(r3,2)) / (2*r1*r2)
        let y = (powf(l1,2) + powf(l2,2) - powf(l3,2)) / (2*l1*l2)
        print("x is \(x)")
        print("y is \(y)")
        
        let rightElbowAngle = acos(x) * 180 / Float.pi
        let leftElbowAngle = acos(y) * 180 / Float.pi
        
        print("Right elbow angle is \(rightElbowAngle) degrees")
        print("Left elbow angle is \(leftElbowAngle) degrees")
        
    }
        //New code below
        /*
        let skeleton = bodyAnchor.skeleton
        
        guard let rightHand = skeleton.modelTransform(for: .rightHand)?.columns.3 else {continue}
        guard let rightElbow = skeleton.modelTransform(for: ARSkeleton.JointName(rawValue: "right_forearm_joint"))?.columns.3 else {continue}
        guard let rightArm = skeleton.modelTransform(for: ARSkeleton.JointName(rawValue: "right_arm_joint"))?.columns.3 else {continue}
        guard let leftHand = skeleton.modelTransform(for: .leftHand)?.columns.3 else {continue}
        guard let leftElbow = skeleton.modelTransform(for: ARSkeleton.JointName(rawValue: "left_forearm_joint"))?.columns.3 else {continue}
        guard let leftArm = skeleton.modelTransform(for: ARSkeleton.JointName(rawValue: "leftt_arm_joint"))?.columns.3 else {continue}
        
        let r1 = distance(rightHand, rightElbow)
        let r2 = distance(rightArm, rightElbow)
        let r3 = distance_squared(rightHand, rightArm)
        let l1 = distance(leftHand, leftElbow)
        let l2 = distance(leftArm, leftElbow)
        let l3 = distance_squared(leftHand, leftArm)
    
        //acos gives radians
        let rightElbowAngle = acos((powf(r1,2) + powf(r2,2) + r3) / (2*r1*r2)) * 180 / Float.pi
        let leftElbowAngle = acos((powf(l1,2) + powf(l2,2) + l3) / (2*l1*l2)) * 180 / Float.pi
        
        print("Right elbow angle is \(rightElbowAngle)")
        print("Left elbow angle is \(leftElbowAngle)") */
    
}
