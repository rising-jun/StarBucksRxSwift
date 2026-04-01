import Foundation
import RxSwift

final class EventRepository {
    private let service = NetworkService()
    private let store = EventStore()
    private var inFlightRequest: Single<[StoreEventItemDTO]>?
    private let queue = DispatchQueue(label: "EventRepository.Queue")

    private func fetchEventStream() -> Single<[StoreEventItemDTO]> {
        let eventStream: Single<StoreEventResponseDTO> = service.fetchAPI(api: StarbucksAPI.events)
        return eventStream.map { $0.list ?? [] }
    }

    func getEventsIfNeededStream() -> Single<[StoreEventItemDTO]> {
        let cachedEvents = store.getEvents()
        if !cachedEvents.isEmpty {
            return .just(cachedEvents)
        }

        return queue.sync { () -> Single<[StoreEventItemDTO]> in
            let cachedEvents = store.getEvents()
            if !cachedEvents.isEmpty {
                return .just(cachedEvents)
            }

            if let inFlightRequest = inFlightRequest {
                return inFlightRequest
            }

            let request = fetchEventStream()
                .do(
                    onSuccess: { [weak self] events in
                        self?.store.setEvents(events)
                        self?.clearInFlightRequest()
                    },
                    onError: { [weak self] _ in
                        self?.clearInFlightRequest()
                    }
                )
                .asObservable()
                .share(replay: 1, scope: .forever)
                .asSingle()

            inFlightRequest = request
            return request
        }
    }

    private func clearInFlightRequest() {
        queue.sync {
            inFlightRequest = nil
        }
    }
}
