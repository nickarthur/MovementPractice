//
//  ViewController.swift
//  MovementPractice
//
//  Created by NickArthur Night on 12/12/20.
//

import UIKit
import RealityKit
import ARKit
import Combine

class ViewController: UIViewController {
    
    var isEditMode: Bool = false
    var utilityBox: Entity? = nil
    var nanBox: NANBoxEntity!
    
    var boxCancellable: AnyCancellable?
    
    var currentUtilityBoxTransform: Transform?
    
    @IBOutlet var arView: ARView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Load the "Box" scene from the "Experience" Reality File
        let boxScene = try! Experience.loadBoxScene()
        
        // Add the box anchor to the scene
        arView.scene.anchors.append(boxScene)
        
        boxScene.actions.cubeTapped.onAction = handleTapped(_:)
        
        if let utilityBox = boxScene.utilityBox {
            utilityBox.removeFromParent()
            nanBox = NANBoxEntity(entity: utilityBox)
            
            arView.installGestures(for: utilityBox as! HasCollision)
            
            let anchor = AnchorEntity()
            anchor.addChild(nanBox)
            arView.scene.addAnchor(anchor)
            
            boxCancellable = nanBox.publisher.sink(receiveValue: { (transform) in
                print( "\n\n****GOT IT!!!!\n\n" + String(describing: transform) + "\n**** GOOD")
        })
        }
    }
    
    
    func handleTapped(_ entity: Entity?) {
        
        guard let entity = entity else { return }
        isEditMode.toggle()
        
        print("\n\n**** THREAD in handleTapped \(String(describing: Thread.current.name))")
                                
        print("\n\nEntity Tapped: \(entity.name)\n")
        print("Parent Name: \(String(describing: entity.parent?.name))\n\n")
        
        print("UtilityBox Child-Entity TRANSFORM \(String(describing: entity.transform))")
        print("PARENT(wrapper) TRANSFORM \(String(describing: entity.parent?.transform))")
        
        if self.isEditMode {
            self.nanBox.shaderDebug(2)
        } else {
            self.nanBox.shaderDebug(0)
        }
    }
    
//    deinit {
//        boxCancellable?.cancel()
//    }
}



