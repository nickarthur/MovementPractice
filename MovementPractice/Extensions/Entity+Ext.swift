

import Foundation
import Combine
import RealityKit

extension Entity {
    enum PropertyName {
        case transform
        case name
    }
    
    var transformPublisher: Publishers.GenericEntityPublisher<Transform> {
        print("Gettig publisher")
        return Publishers.GenericEntityPublisher(entity: self, propertyName: .transform )
    }
    
    var namePublisher: Publishers.GenericEntityPublisher<String> {
        print("Gettig publisher")
        return Publishers.GenericEntityPublisher(entity: self, propertyName: .name)
    }
}

extension Publishers {
    struct GenericEntityPublisher<T>: Publisher {
        typealias Output = T
        typealias Failure = Never

        private let entity: Entity
        private let propertyName: Entity.PropertyName
        
        init(entity: Entity, propertyName: Entity.PropertyName) {
            self.entity = entity
            self.propertyName = propertyName
        }
        
        func receive<S>(subscriber: S) where S : Subscriber, Publishers.GenericEntityPublisher<T>.Failure == S.Failure, Publishers.GenericEntityPublisher<T>.Output == S.Input {
            let subscription = EntitySubscription(subscriber: subscriber, entity: entity, propertyName: propertyName)
            subscriber.receive(subscription: subscription)
        }
    }

    class EntitySubscription<S: Subscriber,T>: Subscription where S.Input == T, S.Failure == Never {

        var timer: Timer?
        
        private var subscriber: S?
        private weak var entity: Entity?
        private var subscribedEntityProperty: Entity.PropertyName
        
        init(subscriber: S, entity: Entity, propertyName: Entity.PropertyName) {
            self.subscriber = subscriber
            self.entity = entity
            self.subscribedEntityProperty = propertyName
            subscribe()
        }
        
        func request(_ demand: Subscribers.Demand) { }
//TODO: IMPLEMENT REQUEST
        func cancel() {
            subscriber = nil
            entity = nil
            timer?.invalidate()
            timer = nil
        }
        
        private func subscribe() {

            timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(sendEntityValue), userInfo: nil, repeats: true)
        }
        
        @objc func sendEntityValue() {

            guard let entity = entity else { return }
            
            switch self.subscribedEntityProperty {
            case .name:
                _ = subscriber?.receive(entity.name as! T)
            case .transform:
                _ = subscriber?.receive(entity.transform as! T)
            }

        }
    }
}
