

import Foundation
import Combine
import RealityKit

// Subscriber: Waits 5 seconds after subscription, then requests a
// maximum of 3 values.
class EntitySubscriber<T>: Subscriber {
    
    typealias Input = T
    typealias Failure = Never
    
    private var subscription: Subscription?
    private var subscribedProperty: Entity.PropertyName
    
    
    init(subscribedProperty: Entity.PropertyName) {
        self.subscribedProperty = subscribedProperty
    }
    
    
    func receive(subscription: Subscription) {
        self.subscription = subscription
        subscription.request(.none)

    }
    
    
    func receive(_ input: T) -> Subscribers.Demand {
        
        switch self.subscribedProperty {
        case .name:
            print("Name: \(input)             \(Date())")

        case .transform:
            print("Transform:\n \(input)             \(Date())")

        }
        
        return Subscribers.Demand.none
    }
    
    
    func receive(completion: Subscribers.Completion<Never>) {
        print ("--done--")
    }
    
    
    func cancelSubscription() {
        subscription?.cancel()
    }
}
