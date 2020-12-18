//
//  NANBoxEntity.swift
//  MovementPractice
//
//  Created by NickArthur Night on 12/15/20.
//

import UIKit
import RealityKit
import Combine

class NANBoxEntity: Entity, HasCollision {

    private var entity: Entity
    private var cancellable: AnyCancellable?
    init(entity: Entity) {
        self.entity = entity
        
        cancellable = self.entity.publisher
            .throttle(for: 1, scheduler: RunLoop.main, latest: true)
            .sink { (transform) in
                print("HERE IS THE TRANSFORM: \n\n" + String(describing: transform))
                let distanceFromOrigin = distance(transform.translation, SIMD3<Float>(repeating: 0))
                print("THE ENTITY IS This Far From the Origin: \(distanceFromOrigin)")
                if distanceFromOrigin > 1 {
                    print("ENTITY TOO FAR AWAY!  Resetting!\n")
                    // move entity back to the origin
                    var homeTransform = Transform()
                    homeTransform.translation = [0,0,-0.33]
                    homeTransform.rotation = entity.transform.rotation
                    entity.move(to: homeTransform, relativeTo: nil, duration: 1.5, timingFunction: .easeInOut)
                }
            }
        
        super.init()
        self.name = "BOX WRAPPER (nanBOX)"

        // BEGIN NAN DEBUG
//
//        // BOX CLASS
//        print("\n\nNAN NANBOX CLASS ADDRESS: \(Unmanaged<NANBoxEntity>.passUnretained(self).toOpaque()))")
//
//        // SUPER STRUCT
//        withUnsafeMutablePointer(to: &(super.transform) ) {
//
//            print("\n\n\nSUPER TRANSFORM STRUCT ADDRESS\($0)\n")
//            let scale: SIMD3 = $0.pointee.scale
//            print("SUPER  SCALE IS \(String(describing: scale))")
//        }
//
//        // SELF STRUCT
//        withUnsafeMutablePointer(to: &(self.transform) ) {
//
//            print("\n\n\nSELF TRANSFORM STRUCT ADDRESS\($0)\n")
//
//            let scale: SIMD3 = $0.pointee.scale
//            print("SELF  SCALE IS \(String(describing: scale))")
//        }
        // END NAN DEBUG
        
        self.addChild(entity)
        self.generateCollisionShapes(recursive: true)
    }
    
    required init() {
        fatalError("Not Supported")
    }
    
    
    
}
