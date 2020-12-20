

import Foundation
import Combine
import RealityKit


extension Entity {
    
    
    public func move(to target: Transform, relativeTo referenceEntity: Entity?, duration: TimeInterval, timingFunction: AnimationTimingFunction = .default, completion: @escaping () -> Void) -> AnimationPlaybackController  {
        
        let animationController = self.move(to: target, relativeTo: referenceEntity, duration: duration, timingFunction: timingFunction)

        // add additional half second delay to be somewhat certain the object is home
        DispatchQueue.main.asyncAfter(deadline: .now() + duration + 0.5, execute: completion)
        return animationController
    }
}

extension Entity: HasCollision {

    enum PropertyName {
        case transform
        case name
    }
    
    var transformPublisher: Publishers.GenericEntityPublisher<Transform> {
        return Publishers.GenericEntityPublisher<Transform>(entity: self, propertyName: .transform )
    }
    
    var namePublisher: Publishers.GenericEntityPublisher<String> {
        return Publishers.GenericEntityPublisher<String>(entity: self, propertyName: .name)
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
  
        
        /// Attaches the specified subscriber to this publisher.
        ///
        /// Always call this function instead of ``Publisher/receive(subscriber:)``.
        /// Adopters of ``Publisher`` must implement ``Publisher/receive(subscriber:)``. The implementation of ``Publisher/subscribe(_:)-4u8kn`` provided by ``Publisher`` calls through to ``Publisher/receive(subscriber:)``.
        ///
        /// - Parameter subscriber: The subscriber to attach to this publisher. After attaching, the subscriber can start to receive values.
        public func subscribe<S>(_ subscriber: S) where S : Subscriber, Self.Failure == S.Failure, Self.Output == S.Input {
            
            self.receive(subscriber: subscriber)
        }
        
        
        func receive<S>(subscriber: S) where S : Subscriber, Publishers.GenericEntityPublisher<T>.Failure == S.Failure, Publishers.GenericEntityPublisher<T>.Output == S.Input {
            let subscription = EntitySubscription(subscriber: subscriber, entity: entity, propertyName: propertyName)
            subscriber.receive(subscription: subscription)
        }
        

    }

    
    class EntitySubscription<S: Subscriber,T>: Subscription where S.Input == T, S.Failure == Never {

        var timer: Timer?
        private var demand: Subscribers.Demand = .none
        private var subscriber: S?
        private weak var entity: Entity?
        private var subscribedEntityProperty: Entity.PropertyName
        
        
        init(subscriber: S, entity: Entity, propertyName: Entity.PropertyName) {
            self.subscriber = subscriber
            self.entity = entity
            self.subscribedEntityProperty = propertyName
            
            // this path may not be valid any longer because
            // we have implemented: func request(_ demand: Subscribers.Demand)
            // sink and assign path NOT EntitySubscribers
            
            // we may be able to delete the timer as well
            if !(self.subscriber is EntitySubscriber<T>) {
//                subscribe()
            }
        }
        
        func request(_ demand: Subscribers.Demand) {

            var demand = demand

            // ...but now we check it here, instead.
            while let subscriber = subscriber, demand > 0 {
              demand -= 1
                sleep(1) // 1 millisecond
                print("AWAKE")
                guard let entity = self.entity else { return }
                
                switch self.subscribedEntityProperty {
                case .name:
                    demand += subscriber.receive(entity.name as! T)
                case .transform:

                    demand +=  subscriber.receive(entity.transform as! T)
                }
            }
            // signal done to the reciever
            subscriber?.receive(completion: Subscribers.Completion.finished
            )
        }
            

        func cancel() {
            subscriber = nil
            entity = nil
            timer?.invalidate()
            timer = nil
        }
        
//        private func subscribe() {
//
//            timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(sendEntityValue), userInfo: nil, repeats: true)
//        }
//
//        @objc func sendEntityValue() {
//
//            guard let entity = entity else { return }
//
//            switch self.subscribedEntityProperty {
//            case .name:
//                _ = subscriber?.receive(entity.name as! T)
//            case .transform:
//                _ = subscriber?.receive(entity.transform as! T)
//            }
//        }
    }
}
