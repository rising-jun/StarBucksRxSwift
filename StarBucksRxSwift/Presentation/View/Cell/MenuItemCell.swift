import SnapKit
import UIKit

final class MenuItemCell: UITableViewCell {
    static let reuseIdentifier = "MenuItemCell"

    private let cardView = MenuItemCardView()

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
        cardView.configure(with: item)
    }

    private func configureView() {
        selectionStyle = .none
        backgroundColor = .clear
    }

    private func configureLayout() {
        contentView.addSubview(cardView)

        cardView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 8, left: 20, bottom: 8, right: 20))
        }
    }
}
