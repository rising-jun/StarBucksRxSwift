import SnapKit
import UIKit

final class MenuItemCell: UITableViewCell {
    static let reuseIdentifier = "MenuItemCell"

    private let cardView = UIView()
    private let titleLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let metaLabel = UILabel()
    private let badgeLabel = PaddingLabel(insets: UIEdgeInsets(top: 6, left: 10, bottom: 6, right: 10))

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureView()
        configureLayout()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with item: MenuItemDTO) {
        titleLabel.text = item.productName ?? "이름 없음"
        descriptionLabel.text = item.content ?? "설명 없음"
        metaLabel.text = item.categoryName ?? item.productCode ?? ""

        let badgeTexts = [
            item.newIcon == "N" ? "NEW" : nil,
            item.recommend == "1" ? "RECOMMEND" : nil,
            item.soldOut == "Y" ? "SOLD OUT" : nil
        ].compactMap { $0 }

        badgeLabel.text = badgeTexts.joined(separator: " · ")
        badgeLabel.isHidden = badgeTexts.isEmpty
    }

    private func configureView() {
        selectionStyle = .none
        backgroundColor = .clear

        cardView.backgroundColor = .secondarySystemBackground
        cardView.layer.cornerRadius = 22

        titleLabel.font = .systemFont(ofSize: 18, weight: .bold)
        titleLabel.numberOfLines = 0

        descriptionLabel.font = .systemFont(ofSize: 14, weight: .regular)
        descriptionLabel.textColor = .secondaryLabel
        descriptionLabel.numberOfLines = 0

        metaLabel.font = .systemFont(ofSize: 13, weight: .medium)
        metaLabel.textColor = StarbucksPalette.warmBrown
        metaLabel.numberOfLines = 0

        badgeLabel.font = .systemFont(ofSize: 11, weight: .bold)
        badgeLabel.textColor = .white
        badgeLabel.backgroundColor = StarbucksPalette.primaryGreen
        badgeLabel.layer.cornerRadius = 12
        badgeLabel.clipsToBounds = true
    }

    private func configureLayout() {
        contentView.addSubview(cardView)
        [titleLabel, descriptionLabel, metaLabel, badgeLabel].forEach(cardView.addSubview)

        cardView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 8, left: 20, bottom: 8, right: 20))
        }
        titleLabel.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview().inset(18)
        }
        descriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(18)
        }
        metaLabel.snp.makeConstraints { make in
            make.top.equalTo(descriptionLabel.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview().inset(18)
        }
        badgeLabel.snp.makeConstraints { make in
            make.top.equalTo(metaLabel.snp.bottom).offset(12)
            make.leading.equalToSuperview().inset(18)
            make.bottom.equalToSuperview().inset(18)
        }
    }
}
