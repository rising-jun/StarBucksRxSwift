import RxCocoa
import RxSwift


final class MenuViewModel {
    private let menuRepository = MenuRepository()
    
    struct Input {
        var viewDidLoad: Observable<Void>
        var categorySelected: Observable<GoodsCategory>
    }
    
    struct Output {
        var currentCategoryMenus: Driver<[MenuItemDTO]>
    }
    
    func transform(input: Input) -> Output {
        let selectedCategory = Observable.merge(
            input.viewDidLoad.map { GoodsCategory.blended },
            input.categorySelected.distinctUntilChanged()
        )
        
        let currentCategoryMenus = selectedCategory
            .flatMapLatest { [weak self] category in
                guard let self else { return Observable<[MenuItemDTO]>.just([]) }
                return self.getMenus(for: category)
            }
        
        
        return Output(
            currentCategoryMenus: currentCategoryMenus.asDriver(onErrorJustReturn: [])
        )
    }

    private func getMenus(for category: GoodsCategory) -> Observable<[MenuItemDTO]> {
        return menuRepository.getMenuIfNeededStream(by: category)
            .do(
                onError: { error in
                    print(error)
                }
            )
            .asObservable()
    }
}
