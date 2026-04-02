import Foundation
import RxCocoa
import RxSwift

private enum MenuError: LocalizedError {
    case menuLoadFailed

    var errorDescription: String? {
        switch self {
        case .menuLoadFailed:
            return "메뉴를 불러오지 못했습니다."
        }
    }
}

final class MenuViewModel {
    private let menuRepository = MenuRepository()
    
    struct Input {
        var viewDidLoad: Observable<Void>
        var categorySelected: Observable<GoodsCategory>
    }
    
    struct Output {
        var currentCategoryMenus: Driver<[MenuItemDTO]>
        var errorMessage: Signal<String>
    }
    
    func transform(input: Input) -> Output {
        let errorRelay = PublishRelay<String>()
        let selectedCategory = Observable.merge(
            input.viewDidLoad.map { GoodsCategory.blended },
            input.categorySelected.distinctUntilChanged()
        )
        
        let currentCategoryMenus = selectedCategory
            .flatMapLatest { [weak self] category in
                guard let self else { return Observable<[MenuItemDTO]>.just([]) }
                return self.getMenus(for: category, errorRelay: errorRelay)
            }
        
        
        return Output(
            currentCategoryMenus: currentCategoryMenus.asDriver(onErrorJustReturn: []),
            errorMessage: errorRelay.asSignal()
        )
    }

    private func getMenus(
        for category: GoodsCategory,
        errorRelay: PublishRelay<String>
    ) -> Observable<[MenuItemDTO]> {
        return menuRepository.getMenuIfNeededStream(by: category)
            .do(
                onError: { _ in
                    errorRelay.accept(
                        MenuError.menuLoadFailed.errorDescription ?? "메뉴를 불러오지 못했습니다."
                    )
                }
            )
            .catchAndReturn([])
            .asObservable()
    }
}
