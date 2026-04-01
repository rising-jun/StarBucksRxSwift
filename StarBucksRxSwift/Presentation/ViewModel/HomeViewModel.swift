import RxCocoa
import RxSwift

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
    }
    
    func transform(input: Input) -> Output {
        let homeBannerItems = input.viewDidLoad
            .flatMap { [homeBannerRepository] _ in
                homeBannerRepository.getMenuIfNeededStream()
                    .asObservable()
                    .do(onError: { error in
                        print(error)
                    })
                    .catchAndReturn([])
            }
        
        let menuItems = input.viewDidLoad
            .flatMap { [menuRepository] _ in
                menuRepository.getMenuIfNeededStream(by: .blended)
                    .asObservable()
                    .do(onError: { error in
                        print(error)
                    })
                    .catchAndReturn([])
            }
        
        let eventItems = input.viewDidLoad
            .flatMap { [eventRepository] _ in
                eventRepository.getEventsIfNeededStream()
                    .asObservable()
                    .do(onError: { error in
                        print(error)
                    })
                    .catchAndReturn([])
            }
        
        let detailMenuItem = input.menuCardTapped
            .withLatestFrom(menuItems) { productCode, menuItems in
                let item = menuItems.first(where: { $0.productCode == productCode })
                return item
            }
            .compactMap { $0 }
        
        return Output(
            HomeBanners: homeBannerItems.asDriver(onErrorJustReturn: []),
            menus: menuItems.asDriver(onErrorJustReturn: []),
            event: eventItems.asDriver(onErrorJustReturn: []),
            showMenuDetail: detailMenuItem.asDriver(onErrorDriveWith: .empty())
        )
    }
}
