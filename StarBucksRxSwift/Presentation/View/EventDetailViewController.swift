import SnapKit
import UIKit

final class EventDetailViewController: UIViewController {
    private let eventCode: String

    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let titleLabel = UILabel()
    private let dateLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let memoLabel = UILabel()

    init(eventCode: String) {
        self.eventCode = eventCode
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
        render(MockStarbucksData.event(with: eventCode))
    }

    private func configureView() {
        view.backgroundColor = .systemBackground
        navigationItem.title = "Event Detail"
        navigationItem.largeTitleDisplayMode = .never

        titleLabel.font = .systemFont(ofSize: 28, weight: .bold)
        titleLabel.numberOfLines = 0

        dateLabel.font = .systemFont(ofSize: 14, weight: .semibold)
        dateLabel.textColor = StarbucksPalette.primaryGreen
        dateLabel.numberOfLines = 0

        descriptionLabel.font = .systemFont(ofSize: 16, weight: .regular)
        descriptionLabel.textColor = .label
        descriptionLabel.numberOfLines = 0

        memoLabel.font = .systemFont(ofSize: 14, weight: .regular)
        memoLabel.textColor = .secondaryLabel
        memoLabel.numberOfLines = 0
    }

    private func configureLayout() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        [titleLabel, dateLabel, descriptionLabel, memoLabel].forEach(contentView.addSubview)

        scrollView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(scrollView.snp.width)
        }
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(24)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        dateLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(14)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        descriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(dateLabel.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        memoLabel.snp.makeConstraints { make in
            make.top.equalTo(descriptionLabel.snp.bottom).offset(20)
            make.leading.trailing.bottom.equalToSuperview().inset(20)
        }
    }

    private func render(_ item: StoreEventItemDTO?) {
        titleLabel.text = item?.eventName ?? "제목 없음"
        dateLabel.text = "\(item?.startDate ?? "-") - \(item?.endDate ?? "-")"
        descriptionLabel.text = item?.eventDescription ?? "이벤트 설명 없음"
        memoLabel.text = item?.eventMemo
    }
}
