import SnapKit
import UIKit
import RxCocoa
import RxSwift
import RxRelay


final class MenuViewController: UIViewController {
    private let categoryScrollView = UIScrollView()
    private let categoryContentView = UIView()
    private let tableView = UITableView(frame: .zero, style: .plain)

    private let categories = GoodsCategory.appSections
    private var categoryButtons: [UIButton] = []
    private var selectedCategory: GoodsCategory = .blended
    private var items: [MenuItemDTO] = []
    private var shouldScrollToTopAfterReload = false
    
    private let viewModel = MenuViewModel()
    private let disposeBag = DisposeBag()
    private let viewDidLoadRelay = PublishRelay<Void>()
    private let categorySelectedRelay = PublishRelay<GoodsCategory>()
    private let toastLabel: PaddingLabel = {
        let label = PaddingLabel(insets: UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16))
        label.backgroundColor = UIColor.black.withAlphaComponent(0.82)
        label.textColor = .white
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.layer.cornerRadius = 16
        label.clipsToBounds = true
        label.alpha = 0
        return label
    }()
    private var toastHideWorkItem: DispatchWorkItem?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        configureLayout()
        configureCategoryButtons()
        bindViewModel()
        viewDidLoadRelay.accept(())
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    private func configureView() {
        view.backgroundColor = .systemBackground

        tableView.backgroundColor = .systemBackground
        tableView.separatorStyle = .none
        tableView.rowHeight = 144
        tableView.estimatedRowHeight = 144
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(MenuItemCell.self, forCellReuseIdentifier: MenuItemCell.reuseIdentifier)
    }

    private func configureLayout() {
        [
            categoryScrollView,
            tableView
        ].forEach(view.addSubview)
        categoryScrollView.addSubview(categoryContentView)
        view.addSubview(toastLabel)

        categoryScrollView.showsHorizontalScrollIndicator = false

        categoryScrollView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).inset(8)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(52)
        }
        categoryContentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.height.equalToSuperview()
        }
        tableView.snp.makeConstraints { make in
            make.top.equalTo(categoryScrollView.snp.bottom).offset(8)
            make.leading.trailing.bottom.equalToSuperview()
        }
        toastLabel.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(20)
            make.bottom.equalTo(view.safeAreaLayoutGuide).inset(16)
        }
    }

    private func configureCategoryButtons() {
        categoryButtons.forEach { $0.removeFromSuperview() }
        categoryButtons.removeAll()

        var previousButton: UIButton?

        for category in categories {
            let button = UIButton(type: .system)
            button.setTitle(category.displayName, for: .normal)
            button.titleLabel?.font = .systemFont(ofSize: 14, weight: .semibold)
            button.layer.cornerRadius = 18
            button.contentEdgeInsets = UIEdgeInsets(top: 9, left: 14, bottom: 9, right: 14)
            button.addAction(
                UIAction { [weak self] _ in
                    self?.selectCategory(category)
                },
                for: .touchUpInside
            )

            categoryContentView.addSubview(button)
            button.snp.makeConstraints { make in
                make.centerY.equalToSuperview()
                if let previousButton {
                    make.leading.equalTo(previousButton.snp.trailing).offset(10)
                } else {
                    make.leading.equalToSuperview().inset(20)
                }
                if category == categories.last {
                    make.trailing.equalToSuperview().inset(20)
                }
            }

            categoryButtons.append(button)
            previousButton = button
        }

        updateCategorySelectionUI()
    }

    private func bindViewModel() {
        let input = MenuViewModel.Input(
            viewDidLoad: viewDidLoadRelay.asObservable(),
            categorySelected: categorySelectedRelay.asObservable()
        )
        let output = viewModel.transform(input: input)

        output.currentCategoryMenus
            .drive(with: self) { owner, items in
                owner.contribute(items)
            }
            .disposed(by: disposeBag)

        output.errorMessage
            .emit(with: self) { owner, message in
                owner.showToast(message)
            }
            .disposed(by: disposeBag)
    }

    private func contribute(_ items: [MenuItemDTO]) {
        self.items = items
        tableView.reloadData()

        guard shouldScrollToTopAfterReload else { return }
        shouldScrollToTopAfterReload = false
        tableView.layoutIfNeeded()
        tableView.setContentOffset(CGPoint(x: 0, y: -tableView.adjustedContentInset.top), animated: false)
    }

    private func selectCategory(_ category: GoodsCategory) {
        guard selectedCategory != category else { return }
        selectedCategory = category
        updateCategorySelectionUI()
        shouldScrollToTopAfterReload = true
        categorySelectedRelay.accept(category)
    }

    private func updateCategorySelectionUI() {
        for (index, button) in categoryButtons.enumerated() {
            let category = categories[index]
            let isSelected = category == selectedCategory
            button.backgroundColor = isSelected ? StarbucksPalette.primaryGreen : StarbucksPalette.softGray
            button.setTitleColor(isSelected ? .white : .label, for: .normal)
        }
    }

    private func showToast(_ message: String) {
        toastHideWorkItem?.cancel()
        toastLabel.text = message

        UIView.animate(withDuration: 0.2) {
            self.toastLabel.alpha = 1
        }

        let workItem = DispatchWorkItem { [weak self] in
            UIView.animate(withDuration: 0.2) {
                self?.toastLabel.alpha = 0
            }
        }
        toastHideWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: workItem)
    }

}

extension MenuViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: MenuItemCell.reuseIdentifier,
            for: indexPath
        ) as? MenuItemCell else {
            return UITableViewCell()
        }

        cell.configure(with: items[indexPath.row])
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let viewController = MenuDetailViewController(menuItem: items[indexPath.row])
        navigationController?.pushViewController(viewController, animated: true)
    }
}
