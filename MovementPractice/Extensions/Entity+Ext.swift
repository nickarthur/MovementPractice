

import Foundation
import Combine
import RealityKit

extension Entity {
    var publisher: Publishers.EntityTransformPublisher {
        print("Gettig publisher")
        return Publishers.EntityTransformPublisher(entity: self)
    }
}

extension Publishers {
    struct EntityTransformPublisher: Publisher {
        typealias Output = Transform
        typealias Failure = Never

        private let entity: Entity

        init(entity: Entity) {
            self.entity = entity
            print("YO! EntityTransformPublisher")
        }
        
        func receive<S>(subscriber: S) where S : Subscriber, Publishers.EntityTransformPublisher.Failure == S.Failure, Publishers.EntityTransformPublisher.Output == S.Input {
            let subscription = EntityTransformSubscription(subscriber: subscriber, entity: entity)
            print(#function)
            subscriber.receive(subscription: subscription)
        }
    }

    class EntityTransformSubscription<S: Subscriber>: Subscription where S.Input == Transform, S.Failure == Never {

        var timer: Timer?
        
        private var subscriber: S?
        private weak var entity: Entity?

        init(subscriber: S, entity: Entity) {
            self.subscriber = subscriber
            self.entity = entity
            subscribe()
            print("HELLO #function")
            print(#function)

        }
        
        func request(_ demand: Subscribers.Demand) { }

        func cancel() {
            subscriber = nil
            entity = nil
            timer?.invalidate()
            timer = nil
        }
        
        private func subscribe() {
            print(#function)

            timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(sendTransform), userInfo: nil, repeats: true)
        }
        
        @objc func sendTransform() {
            //print(#file, #function, String(#line) + " sending transform\n")

            guard let entity = entity else { return }
            _ = subscriber?.receive(entity.transform)
        }
    }
}
