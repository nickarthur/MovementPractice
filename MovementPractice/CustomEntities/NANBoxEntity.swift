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

    public var entity: Entity

    init(entity: Entity) {
        self.entity = entity
  
        super.init()
        self.name = "BOX WRAPPER (nanBOX)"
        
        self.addChild(entity)
        self.generateCollisionShapes(recursive: true)
    }
    
    required init() {
        fatalError("Not Supported")
    }
}
