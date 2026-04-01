import Foundation

final class EventStore {
    private let queue = DispatchQueue(label: "EventStore.Queue")
    private var events: [StoreEventItemDTO] = []

    func setEvents(_ events: [StoreEventItemDTO]) {
        queue.sync {
            self.events = events
        }
    }

    func getEvents() -> [StoreEventItemDTO] {
        queue.sync {
            events
        }
    }
}
