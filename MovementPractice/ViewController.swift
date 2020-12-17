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
            nanBox = NANBoxEntity(entity: utilityBox)
            arView.installGestures(for: nanBox)
            let anchor = AnchorEntity()
            anchor.addChild(nanBox)
            arView.scene.addAnchor(anchor)
            
            boxCancellable = nanBox.$transform.throttle(for: 0.5, scheduler: RunLoop.main, latest: true).sink(receiveValue: { (transform) in
                    print(String(describing: transform))
            })
        }
        
    }
    
    
    func handleTapped(_ entity: Entity?) {
        guard let entity = entity else { return }
        isEditMode.toggle()
        
        print("Entity Tapped: \(entity.name)")
        
        if isEditMode {
            self.nanBox.shaderDebug(2)
        } else {
            self.nanBox.shaderDebug(0)
        }
        
    }
    
    deinit {
        boxCancellable?.cancel()
    }
}


extension Entity {
    @available(iOS 14.0, macOS 10.16, *)
    public func attachDebugModelComponent(_ debugModel: ModelDebugOptionsComponent) {
        components.set(debugModel)
        children.forEach { $0.attachDebugModelComponent(debugModel) }
    }

    @available(iOS 14.0, macOS 10.16, *)
    public func removeDebugModelComponent() {
        components[ModelDebugOptionsComponent.self] = nil
        children.forEach { $0.removeDebugModelComponent() }
    }

    public func shaderDebug(_ index: Int) {
        guard #available(iOS 14.0, macOS 10.16, *) else { return }

        var mewDebugModel: ModelDebugOptionsComponent?
        switch index {
        case 0: mewDebugModel = nil
        case 1: mewDebugModel = ModelDebugOptionsComponent(visualizationMode: .baseColor)
        case 2: mewDebugModel = ModelDebugOptionsComponent(visualizationMode: .normal)
        case 3: mewDebugModel = ModelDebugOptionsComponent(visualizationMode: .textureCoordinates)
        default: mewDebugModel = nil
        }

        if let mewDebugModel = mewDebugModel {
            attachDebugModelComponent(mewDebugModel)
        } else {
            removeDebugModelComponent()
        }
    }
}


