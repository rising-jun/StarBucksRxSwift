import SnapKit
import UIKit

final class EventItemCell: UITableViewCell {
    static let reuseIdentifier = "EventItemCell"

    private let cardView = UIView()
    private let titleLabel = UILabel()
    private let dateLabel = UILabel()
    private let descriptionLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureView()
        configureLayout()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with item: StoreEventItemDTO) {
        titleLabel.text = item.eventName ?? "이벤트 제목 없음"
        descriptionLabel.text = item.eventDescription ?? item.eventMemo ?? "이벤트 설명 없음"

        let startDate = item.startDate ?? "-"
        let endDate = item.endDate ?? "-"
        dateLabel.text = "\(startDate) - \(endDate)"
    }

    private func configureView() {
        selectionStyle = .none
        backgroundColor = .clear

        cardView.backgroundColor = .secondarySystemBackground
        cardView.layer.cornerRadius = 22

        titleLabel.font = .systemFont(ofSize: 18, weight: .bold)
        titleLabel.numberOfLines = 0

        dateLabel.font = .systemFont(ofSize: 13, weight: .semibold)
        dateLabel.textColor = StarbucksPalette.primaryGreen

        descriptionLabel.font = .systemFont(ofSize: 14, weight: .regular)
        descriptionLabel.textColor = .secondaryLabel
        descriptionLabel.numberOfLines = 0
    }

    private func configureLayout() {
        contentView.addSubview(cardView)
        [titleLabel, dateLabel, descriptionLabel].forEach(cardView.addSubview)

        cardView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 8, left: 20, bottom: 8, right: 20))
        }
        titleLabel.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview().inset(18)
        }
        dateLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview().inset(18)
        }
        descriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(dateLabel.snp.bottom).offset(10)
            make.leading.trailing.bottom.equalToSuperview().inset(18)
        }
    }
}
