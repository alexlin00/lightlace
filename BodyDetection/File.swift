//
//  File.swift
//  BodyDetection
//
//  Created by Alex Lin on 9/7/20.
//  Copyright © 2020 Apple. All rights reserved.
//

import Foundation
/*
//******* NEED TO GUARD AGAINST IF ANY NODES BELOW ARE NOT DETECTED
let skeleton = bodyAnchor.skeleton
    
/*
let jointNames = ["right_hand_joint", "right_forearm_joint", "right_arm_joint", "left_hand_joint", "left_forearm_joint", "left_arm_joint"]
//var rightHand, rightForearm, rightArm, leftHand, leftForearm, leftArm : simd_float4x4
var jointTransforms : [simd_float4x4] = []
for i in 0..<jointNames.count{
    jointTransforms.append(skeleton.modelTransform(for: ARSkeleton.JointName(rawValue: jointNames[i]))!) //else { continue }
}*/
    
guard let rightHandTransform = skeleton.modelTransform(for: .rightHand) else {continue}
guard let rightElbowTransform = skeleton.modelTransform(for: ARSkeleton.JointName(rawValue: "right_forearm_joint")) else {continue}
guard let rightArmTransform = skeleton.modelTransform(for: ARSkeleton.JointName(rawValue: "right_arm_joint")) else {continue}
guard let leftHandTransform = skeleton.modelTransform(for: .leftHand) else {continue}
guard let leftElbowTransform = skeleton.modelTransform(for: ARSkeleton.JointName(rawValue: "left_forearm_joint")) else {continue}
guard let leftArmTransform = skeleton.modelTransform(for: ARSkeleton.JointName(rawValue: "leftt_arm_joint")) else {continue}
 
 
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

// (x,y,z) are positions of each joint relative to the hip(root)

let rightHand : SIMD3<Float> = [rightHandTransform[3,0], rightHandTransform[3,1], rightHandTransform[3,2]]
let rightElbow : SIMD3<Float> = [rightElbowTransform[3,0], rightElbowTransform[3,1], rightElbowTransform[3,2]]
let rightArm : SIMD3<Float> = [rightArmTransform[3,0], rightArmTransform[3,1], rightArmTransform[3,2]]
let leftHand : SIMD3<Float> = [leftHandTransform[3,0], leftHandTransform[3,1], leftHandTransform[3,2]]
let leftElbow : SIMD3<Float> = [leftElbowTransform[3,0], leftElbowTransform[3,1], leftElbowTransform[3,2]]
let leftArm : SIMD3<Float> = [leftArmTransform[3,0], leftArmTransform[3,1], leftArmTransform[3,2]]

let r1 = distance(rightHand, rightElbow)
let r2 = distance(rightArm, rightElbow)
let r3 = distance_squared(rightHand, rightArm)
let l1 = distance(leftHand, leftElbow)
let l2 = distance(leftArm, leftElbow)
let l3 = distance_squared(leftHand, leftArm)

//acos gives radians
let rightElbowAngle = acos((powf(r1,2) + powf(r2,2) + r3) / (2*r1*r2)) * 180 / Float.pi
let leftElbowAngle = acos((powf(l1,2) + powf(l2,2) + l3) / (2*l1*l2)) * 180 / Float.pi

*/
let rightElbowText = MeshResource.generateText(rightElbowAngle.description) // Generate mesh
let rightElbowEntity = ModelEntity(mesh: rightElbowText) // Create an entity from mesh
let leftElbowText = MeshResource.generateText(leftElbowAngle.description)
let leftElbowEntity = ModelEntity(mesh: leftElbowText)

//characterAnchor.addChild(rightElbowEntity) // Need to create new ArchorEntity at elbow to attach text?
//characterAnchor.addChild(leftElbowEntity)

print("Right elbow angle is \(rightElbowAngle)")
print("Left elbow angle is \(leftElbowAngle)")
    
}*/
