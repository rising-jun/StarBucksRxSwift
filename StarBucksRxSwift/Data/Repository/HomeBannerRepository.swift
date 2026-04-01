import Foundation
import RxSwift
import RxRelay

final class HomeBannerRepository {
    private let service = NetworkService()
    private let store = HomeBannerStore()
    private var inFlightRequest: Single<[HomeBannerItemDTO]>?
    private let queue = DispatchQueue(label: "HomeBannerRepository.Queue")
    
    private func fetchHomBannerStream() -> Single<[HomeBannerItemDTO]> {
        let menuItemSingle: Single<HomeBannerResponseDTO> = service.fetchAPI(api: StarbucksAPI.homeBanner)
        return menuItemSingle.map { $0.list ?? [] }
    }
    
    func getMenuIfNeededStream() -> Single<[HomeBannerItemDTO]> {
        queue.sync {
            let cachedHomeBanners = store.getHomeBanners()
            if !cachedHomeBanners.isEmpty {
                return .just(cachedHomeBanners)
            }
            
            if let inFlightRequest {
                return inFlightRequest
            }
            
            let request = fetchHomBannerStream()
                .do(
                    onSuccess: { [weak self] banners in
                        self?.store.setHomeBanners(banners)
                        self?.clearInFlightRequest()
                    }, onError: { [weak self] _ in
                        self?.clearInFlightRequest()
                    }
                )
                .asObservable()
                .share(replay: 1)
                .asSingle()
            
            inFlightRequest = request
            return request
        }
    }
    
    func clearInFlightRequest() {
        queue.sync {
            inFlightRequest = nil
        }
    }
    
    func setInFlightRequest() {
        queue.sync {
            inFlightRequest = .just([])
        }
    }
}
