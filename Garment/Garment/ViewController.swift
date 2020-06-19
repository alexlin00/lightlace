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

class ViewController: UIViewController {
    
    @IBOutlet var arView: ARView!
    
    //arView.automaticallyConfigureSession = false
    let configuration = ARWorldTrackingConfiguration()
    //configuration.sceneReconstruction = arView.meshWithClassification
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Load the "Box" scene from the "Experience" Reality File
        let boxAnchor = try! Experience.loadBox()
        
        // Add the box anchor to the scene
        arView.scene.anchors.append(boxAnchor)
        
        arView.debugOptions.insert(.showSceneUnderstanding)
        arView.session.run(configuration)
    }
}
