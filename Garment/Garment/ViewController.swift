//
//  ViewController.swift
//  Garment
//
//  Created by Alex Lin on 6/18/20.
//  Copyright © 2020 OrganicRoboticsCorp. All rights reserved.
//

import UIKit
import RealityKit
import ARKit
import Combine
import Foundation

//apple sample code for capturing body motion
class ViewController: UIViewController, ARSessionDelegate {

    @IBOutlet var arView: ARView!
    
    // The 3D character to display.
    var character: BodyTrackedEntity?
    let characterOffset: SIMD3<Float> = [0.0, 0, 0] // Offset the character by one meter to the left
    let characterAnchor = AnchorEntity()
    
    //var elbow: ModelEntity?
    //let elbowAnchor =  AnchorEntity()
    
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
            guard let bodyAnchor = anchor as? ARBodyAnchor else { return }
            
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
            
            
            //******* NEED TO GUARD AGAINST IF ANY NODES BELOW ARE NOT DETECTED
            let skeleton = bodyAnchor.skeleton
            let jointNames = ["right_hand_joint", "right_forearm_joint", "right_arm_joint", "left_hand_joint", "left_forearm_joint", "left_arm_joint"]
            //var rightHand, rightForearm, rightArm, leftHand, leftForearm, leftArm : simd_float4x4
            var jointTransforms : [simd_float4x4] = []
            for i in 0..<jointNames.count{
                jointTransforms.append(skeleton.modelTransform(for: ARSkeleton.JointName(rawValue: jointNames[i]))!) //else { continue }
            }
            
            // (x,y,z) are positions of each joint relative to the hip(root)
            
            let rightHand : SIMD3<Float> = [jointTransforms[0][3,0], jointTransforms[0][3,1], jointTransforms[0][3,2]]
            let rightForearm : SIMD3<Float> = [jointTransforms[1][3,0], jointTransforms[1][3,1], jointTransforms[1][3,2]]
            let rightArm : SIMD3<Float> = [jointTransforms[2][3,0], jointTransforms[2][3,1], jointTransforms[2][3,2]]
            let leftHand : SIMD3<Float> = [jointTransforms[3][3,0], jointTransforms[3][3,1], jointTransforms[3][3,2]]
            let leftForearm : SIMD3<Float> = [jointTransforms[4][3,0], jointTransforms[4][3,1], jointTransforms[4][3,2]]
            let leftArm : SIMD3<Float> = [jointTransforms[5][3,0], jointTransforms[5][3,1], jointTransforms[5][3,2]]
            
            let r1 = distance(rightHand, rightForearm)
            let r2 = distance(rightArm, rightForearm)
            let r3 = distance_squared(rightHand, rightArm)
            let l1 = distance(leftHand, leftForearm)
            let l2 = distance(leftArm, leftForearm)
            let l3 = distance_squared(leftHand, leftArm)
            
            //acos gives radians
            let rightElbowAngle = acos((powf(r1,2) + powf(r2,2) + r3) / (2*r1*r2)) * 180 / Float.pi
            let leftElbowAngle = acos((powf(l1,2) + powf(l2,2) + l3) / (2*l1*l2)) * 180 / Float.pi
            
            let rightElbowText = MeshResource.generateText(rightElbowAngle.description) // Generate mesh
            let rightElbowEntity = ModelEntity(mesh: rightElbowText) // Create an entity from mesh
            let leftElbowText = MeshResource.generateText(leftElbowAngle.description)
            let leftElbowEntity = ModelEntity(mesh: leftElbowText)
            
            //characterAnchor.addChild(rightElbowEntity) // Need to create new ArchorEntity at elbow to attach text?
            //characterAnchor.addChild(leftElbowEntity)
            
            print("Right elbow angle is \(rightElbowAngle)")
            print("Left elbow angle is \(leftElbowAngle)")
                
            }
            
        }
    }
    
}


/*code for accessing hand, elbow, shoulder nodes
//hand -> elbow -> shoulder (child -> parent)
//from developer.apple.com/videos/play/wwdc2019/607

//Look for body anchor
for anchor in anchors {
    guard let bodyAnchor = anchor as? ARBodyAnchor else { return }
    // Access to the Position of Root Node
    let hipWorldPosition = bodyAnchor.transform
    // Accessing the Skeleton Geometry
    let skeleton = bodyAnchor.skeleton
    // Accessing List of Transforms of all joints Relative to Root
    let jointTransforms = skeleton.jointModelTransforms
    // Iterating over All joints
    for (i, jointTransform) in jointTransforms.enumerated() {
        //Extract Parent Index from Definition
        let parentIndex = skeleton.definition.parentIndices[ i ]
        //Check If it's Not Root
        guard parentIndex != -1 else {continue}
        //Find Position of Parent Joint
        let parentJointTransform = jointTransforms[parentIndex.intValue]
    }
}*/

