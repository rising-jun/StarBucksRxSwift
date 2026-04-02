import Foundation
import RxCocoa
import RxSwift

private enum HomeError: LocalizedError {
    case bannerLoadFailed
    case menuLoadFailed
    case eventLoadFailed

    var errorDescription: String? {
        switch self {
        case .bannerLoadFailed:
            return "배너를 불러오지 못했습니다."
        case .menuLoadFailed:
            return "메뉴를 불러오지 못했습니다."
        case .eventLoadFailed:
            return "이벤트를 불러오지 못했습니다."
        }
    }
}

final class HomeViewModel {
    private let menuRepository: MenuRepository
    private let homeBannerRepository: HomeBannerRepository
    private let eventRepository: EventRepository
    
    init(
        menuRepository: MenuRepository = MenuRepository(),
        homeBannerRepository: HomeBannerRepository = HomeBannerRepository(),
        eventRepository: EventRepository = EventRepository()
    ) {
        self.menuRepository = menuRepository
        self.homeBannerRepository = homeBannerRepository
        self.eventRepository = eventRepository
    }
    
    struct Input {
        var viewDidLoad: Observable<Void>
        var menuCardTapped: Observable<String>
    }
    
    struct Output {
        var HomeBanners: Driver<[HomeBannerItemDTO]>
        var menus: Driver<[MenuItemDTO]>
        var event: Driver<[StoreEventItemDTO]>
        var showMenuDetail: Driver<MenuItemDTO>
        var errorMessage: Signal<String>
    }
    
    func transform(input: Input) -> Output {
        let errorRelay = PublishRelay<String>()

        let homeBannerItems = input.viewDidLoad
            .flatMapLatest { [homeBannerRepository] _ in
                homeBannerRepository.getMenuIfNeededStream()
                    .asObservable()
                    .do(onError: { _ in
                        errorRelay.accept(HomeError.bannerLoadFailed.errorDescription ?? "배너를 불러오지 못했습니다.")
                    })
                    .catchAndReturn([])
            }
        
        let menuItems = input.viewDidLoad
            .flatMapLatest { [menuRepository] _ in
                menuRepository.getMenuIfNeededStream(by: .blended)
                    .asObservable()
                    .do(onError: { _ in
                        errorRelay.accept(HomeError.menuLoadFailed.errorDescription ?? "메뉴를 불러오지 못했습니다.")
                    })
                    .catchAndReturn([])
            }
        
        let eventItems = input.viewDidLoad
            .flatMapLatest { [eventRepository] _ in
                eventRepository.getEventsIfNeededStream()
                    .asObservable()
                    .do(onError: { _ in
                        errorRelay.accept(HomeError.eventLoadFailed.errorDescription ?? "이벤트를 불러오지 못했습니다.")
                    })
                    .catchAndReturn([])
            }
        
        let detailMenuItem: Observable<MenuItemDTO> = input.menuCardTapped
            .withLatestFrom(menuItems) { productCode, menuItems in
                let item = menuItems.first(where: { $0.productCode == productCode })
                return item
            }
            .compactMap { $0 }
        
        return Output(
            HomeBanners: homeBannerItems.asDriver(onErrorJustReturn: []),
            menus: menuItems.asDriver(onErrorJustReturn: []),
            event: eventItems.asDriver(onErrorJustReturn: []),
            showMenuDetail: detailMenuItem.asDriver(onErrorDriveWith: Driver.empty()),
            errorMessage: errorRelay.asSignal()
        )
    }
}
