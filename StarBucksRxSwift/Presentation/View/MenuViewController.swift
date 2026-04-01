import SnapKit
import UIKit

final class MenuViewController: UIViewController {
    private let categoryScrollView = UIScrollView()
    private let categoryContentView = UIView()
    private let tableView = UITableView(frame: .zero, style: .plain)

    private let categories = GoodsCategory.appSections
    private var categoryButtons: [UIButton] = []
    private var selectedCategory: GoodsCategory = .coldBrew
    private var items: [MenuItemDTO] = MockStarbucksData.menuItems(for: .coldBrew)

    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        configureLayout()
        configureCategoryButtons()
    }

    private func configureView() {
        view.backgroundColor = .systemBackground

        tableView.backgroundColor = .systemBackground
        tableView.separatorStyle = .none
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 120
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

    private func selectCategory(_ category: GoodsCategory) {
        guard selectedCategory != category else { return }
        selectedCategory = category
        updateCategorySelectionUI()
        items = MockStarbucksData.menuItems(for: category)
        tableView.reloadData()
    }

    private func updateCategorySelectionUI() {
        for (index, button) in categoryButtons.enumerated() {
            let category = categories[index]
            let isSelected = category == selectedCategory
            button.backgroundColor = isSelected ? StarbucksPalette.primaryGreen : StarbucksPalette.softGray
            button.setTitleColor(isSelected ? .white : .label, for: .normal)
        }
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
