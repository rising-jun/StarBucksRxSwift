import SnapKit
import UIKit

final class MenuDetailViewController: UIViewController {
    private let menuItem: MenuItemDTO

    private let scrollView = UIScrollView()
    private let contentView = UIView()

    init(menuItem: MenuItemDTO) {
        self.menuItem = menuItem
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        configureLayout()
    }

    private func configureView() {
        view.backgroundColor = .systemBackground
        navigationItem.title = menuItem.productName ?? "Detail"
    }

    private func configureLayout() {
        let categoryLabel = makeMetaLabel(text: menuItem.categoryName ?? "카테고리 없음")
        let titleLabel = UILabel()
        titleLabel.text = menuItem.productName ?? "이름 없음"
        titleLabel.font = .systemFont(ofSize: 30, weight: .bold)
        titleLabel.numberOfLines = 0

        let descriptionLabel = UILabel()
        descriptionLabel.text = menuItem.content ?? "설명 없음"
        descriptionLabel.font = .systemFont(ofSize: 16, weight: .regular)
        descriptionLabel.textColor = .secondaryLabel
        descriptionLabel.numberOfLines = 0

        let nutritionLabel = UILabel()
        nutritionLabel.text = [
            "Kcal \(menuItem.kcal ?? "-")",
            "Sugar \(menuItem.sugars ?? "-")",
            "Protein \(menuItem.protein ?? "-")",
            "Sodium \(menuItem.sodium ?? "-")",
            "Caffeine \(menuItem.caffeine ?? "-")"
        ].joined(separator: "\n")
        nutritionLabel.font = .systemFont(ofSize: 15, weight: .medium)
        nutritionLabel.textColor = StarbucksPalette.warmBrown
        nutritionLabel.numberOfLines = 0

        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        [categoryLabel, titleLabel, descriptionLabel, nutritionLabel].forEach(contentView.addSubview)

        scrollView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(scrollView.snp.width)
        }
        categoryLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(20)
            make.leading.equalToSuperview().inset(20)
        }
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(categoryLabel.snp.bottom).offset(18)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        descriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        nutritionLabel.snp.makeConstraints { make in
            make.top.equalTo(descriptionLabel.snp.bottom).offset(24)
            make.leading.trailing.bottom.equalToSuperview().inset(20)
        }
    }

    private func makeMetaLabel(text: String) -> UILabel {
        let label = PaddingLabel(insets: UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12))
        label.text = text
        label.font = .systemFont(ofSize: 12, weight: .bold)
        label.textColor = .white
        label.backgroundColor = StarbucksPalette.primaryGreen
        label.layer.cornerRadius = 14
        label.clipsToBounds = true
        return label
    }
}
