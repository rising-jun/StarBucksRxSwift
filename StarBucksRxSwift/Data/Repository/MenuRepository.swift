import Foundation
import RxSwift
import RxRelay

final class MenuRepository {
    private let service = NetworkService()
    private let store = MenuStore()
    private var inFlightRequest: [GoodsCategory: Single<[MenuItemDTO]>] = [:]
    private let queue = DispatchQueue(label: "MenuRepository.Queue")
    
    private func fetchMenuStream(by menu: GoodsCategory) -> Single<[MenuItemDTO]> {
        let menuItemSingle: Single<MenuListResponseDTO> = service.fetchAPI(api: StarbucksAPI.menu(category: menu))
        return menuItemSingle.map { $0.list ?? [] }
    }
    
    func getAllMenuIfNeededStream() -> Single<[GoodsCategory: [MenuItemDTO]]> {
        queue.sync {
            let requests = GoodsCategory.appSections.map { category in
                getMenuIfNeededStream(by: category)
                    .map { (category, $0) }
            }
            
            return Single.zip(requests)
                .map { Dictionary(uniqueKeysWithValues: $0) }
        }
    }

    
    func getMenuIfNeededStream(by menu: GoodsCategory) -> Single<[MenuItemDTO]> {
        queue.sync {
            let cachedMenu = store.getMenus(by: menu)
            if !cachedMenu.isEmpty {
                return .just(cachedMenu)
            }
            
            if let inFlightRequest = inFlightRequest[menu] {
                return inFlightRequest
            }
            
            let request = fetchMenuStream(by: menu)
                .do(
                    onSuccess: { [weak self] menus in
                        self?.store.setMenus(by: menu, menus: menus)
                        self?.clearInFlightRequest(by: menu)
                    }, onError: { [weak self] _ in
                        self?.clearInFlightRequest(by: menu)
                    }
                )
                .asObservable()
                .share(replay: 1)
                .asSingle()
            
            inFlightRequest[menu] = request
            return request
        }
    }
    
    func clearInFlightRequest(by menu: GoodsCategory) {
        queue.sync {
            inFlightRequest[menu] = nil
        }
    }
}
