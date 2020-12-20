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
    
    private var isEditMode: Bool = false
    private var utilityBox: Entity? = nil
    private var nanBox: NANBoxEntity!
    private var cancelBag = Set<AnyCancellable>()
    private var currentUtilityBoxTransform: Transform?
    private var boxScene: Experience.BoxScene!
    
    @IBOutlet var arView: ARView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Load the "Box" scene from the "Experience" Reality File
        self.boxScene = try! Experience.loadBoxScene()
        
        // Add the box anchor to the scene
        arView.scene.anchors.append(boxScene)
        
        boxScene.actions.cubeTapped.onAction = handleTapped(_:)
        
        if let utilityBox = boxScene.utilityBox {
            
            utilityBox.removeFromParent()
            nanBox = NANBoxEntity(entity: utilityBox)

            arView.installGestures(for: utilityBox as HasCollision)
            
            let anchor = AnchorEntity()
            anchor.addChild(nanBox)
            arView.scene.addAnchor(anchor)
            
            
            nanBox.entity.transformPublisher
                // MUST use global thread or locks up
                .subscribe(on: DispatchQueue.global(qos: .default))
                .throttle(for: 1.0, scheduler: DispatchQueue.global(qos: .default), latest: true)
                .sink { (transform) in

                    DispatchQueue.main.async { [weak self] in
                        guard let self = self else { return }
                        
                        print("HERE IS THE TRANSFORM: \n\n" + String(describing: transform))
                        let distanceFromOrigin = distance(transform.translation, SIMD3<Float>(repeating: 0))
                        
                        print("\n**** distanceFromOrigin: \(distanceFromOrigin)\n")
                        
                        if distanceFromOrigin > 1  {
                            
                            print("ENTITY TOO FAR AWAY!  Resetting!\n")
                            
                            // move entity back to the origin
                            var userCameraLocation =
                                self.arView.cameraTransform.translation +

                                self.arView.cameraTransform.forwardVector * 0.5
                            // don't let block go down below ground
                            userCameraLocation.y = 0
                            
                            var homeTransform = Transform()
                            
                            homeTransform.translation = userCameraLocation
                            
                            homeTransform.rotation = self.nanBox.entity.transform.rotation

                            
                            // move with a completion handler
                            _ = self.nanBox.entity.move(to: homeTransform, relativeTo: nil, duration: 1.5, timingFunction: .easeInOut) {
                                
                                print("MOVE CALLBACK FIRED")
                            }
                            // close enough
                        } else if distanceFromOrigin < 0.05 {  // 5cm
                            print("ENITY IS CLOSE TO HOME")
                        }
                    }
                }
                .store(in: &cancelBag)
            
/*
           nanBox.entity.namePublisher.removeDuplicates().sink(receiveValue: { (name) in
                print(name)
            })
            .store(in: &cancelBag)
            
            // Subscribe to Entity.name
            let entityNameSubscriber = EntitySubscriber<String>(subscribedProperty: .name)
            
            print ("Subscribing at \(Date())")
            nanBox.entity.namePublisher.subscribe(entityNameSubscriber)


            let entityTransformSubscriber = EntitySubscriber<Transform>(subscribedProperty: .transform)

            print ("Subscribing to Transform Updates at \(Date())")

            nanBox.entity.transformPublisher.subscribe(entityTransformSubscriber)
            entityTransformSubscriber.cancelSubscription()

            
            nanBox.transformPublisher
                // DON'T SUBSCRIBE ON MAIN THREAD!!!!
                // keeps main thread active
                .subscribe(on: DispatchQueue.global())
                .throttle(for: 0.05, scheduler: DispatchQueue.main, latest: true)
                .sink (receiveValue: { value in

                    print("\n Sink on main?  \(Thread.isMainThread)\n")

                    // update the UI
                    DispatchQueue.main.async {
                        print("\n**** Dispatch on Main?  \(Thread.isMainThread)\n")
                        let it = value
                         print(it)
                    }
            })
            .store(in: &cancelBag)

            nanBox.namePublisher
                // DON'T SUBSCRIBE ON MAIN THREAD!!!!
                // keeps main thread active
                .subscribe(on: DispatchQueue.global())
                .throttle(for: 0.05, scheduler: DispatchQueue.main, latest: true)
                .sink (receiveValue: { value in

                    print("\n Sink on main?  \(Thread.isMainThread)\n")

                    // update the UI
                    DispatchQueue.main.async {
                        print("\n**** Dispatch on Main?  \(Thread.isMainThread)\n")
                        let it = value
                         print(it)
                    }
                    
                })
                .store(in: &cancelBag)
*/
             //TODO: Findout where this publisher camer from
//            nanBox.publisher.sink { (entity) in
//                print(entity)
//            }
        }
        
        setupEntityDetection()
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
    
    
    private func setupEntityDetection() {
        
        _ = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            
            let cameraTransform = self.arView.cameraTransform
            let camPosition = cameraTransform.translation
            let camFwdVec = cameraTransform.forwardVector
            
            let raycastResult = self.arView.scene.raycast(origin: camPosition, direction: camFwdVec, length: 10.0, query: .nearest, mask: .all, relativeTo: nil)
            
            if let hit = raycastResult.first {
                let entity  = hit.entity
                print("YOU HIT: \(entity)")
                
                if entity.name == "UtilityBox" {
                    self.play(on: entity)
                }
            }
        }
    }
    
    private func play(on hitEntity: Entity) {
        boxScene.notifications.jiggleNotification.post()
    }
    
    deinit {
        cancelBag.removeAll()
    }
}



