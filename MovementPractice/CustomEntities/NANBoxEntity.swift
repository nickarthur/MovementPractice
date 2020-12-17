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

    @Published public var transform: Transform {
        willSet {
            entity?.transform = transform
        }
    }
    
    private var entity: Entity?
    
    init(entity: Entity) {
        self.transform = entity.transform
        super.init()
        
        self.entity = entity
        self.addChild(entity)
        self.generateCollisionShapes(recursive: true)
    }
    
    required init() {
        fatalError("Not Supported")
    }
    
    
    
}
