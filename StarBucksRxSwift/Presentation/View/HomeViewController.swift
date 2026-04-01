import SafariServices
import SnapKit
import UIKit
import RxSwift
import RxCocoa

final class HomeViewController: UIViewController {
    private let viewModel = HomeViewModel()
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let bannerTitleLabel = HomeViewController.makeSectionTitleLabel(text: "Season Banner")
    private let bannerSubtitleLabel = HomeViewController.makeSectionSubtitleLabel(text: "메인 배너 API로 대체될 영역")
    private let bannerContainerView = UIView()
    private let menuTitleLabel = HomeViewController.makeSectionTitleLabel(text: "Featured Menu")
    private let menuSubtitleLabel = HomeViewController.makeSectionSubtitleLabel(text: "메뉴 API가 붙을 대표 메뉴 미리보기")
    private let menuPreviewContainerView = UIView()
    private let eventTitleLabel = HomeViewController.makeSectionTitleLabel(text: "Events")
    private let eventSubtitleLabel = HomeViewController.makeSectionSubtitleLabel(text: "이벤트 API가 붙을 카드 리스트 미리보기")
    private let eventPreviewContainerView = UIView()
    
    private let disposeBag = DisposeBag()
    private var menuButtonTapped = PublishRelay<String>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        configureHierarchy()
        configureConstraints()
        bindViewModel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    private func bindViewModel() {
        let input = HomeViewModel.Input(
            viewDidLoad: .just(()),
            menuCardTapped: menuButtonTapped.asObservable()
        )
        let output = viewModel.transform(input: input)
        
        output.HomeBanners
            .drive { [weak self] banners in
                guard let self else { return }
                renderBanners(with: banners)
            }
            .disposed(by: disposeBag)
        
        output.menus
            .drive { [weak self] menus in
                guard let self else { return }
                renderFeaturedMenus(with: menus)
            }
            .disposed(by: disposeBag)
        
        output.event
            .drive { [weak self] events in
                guard let self else { return }
                renderEvents(with: events)
            }
            .disposed(by: disposeBag)
        
        output.showMenuDetail
            .drive { [weak self] item in
                let viewController = MenuDetailViewController(menuItem: item)
                self?.navigationController?.pushViewController(viewController, animated: true)
            }
            .disposed(by: disposeBag)
    }
    
    private func configureView() {
        view.backgroundColor = .systemBackground
    }
    
    private func configureHierarchy() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        [
            bannerTitleLabel,
            bannerSubtitleLabel,
            bannerContainerView,
            menuTitleLabel,
            menuSubtitleLabel,
            menuPreviewContainerView,
            eventTitleLabel,
            eventSubtitleLabel,
            eventPreviewContainerView
        ].forEach(contentView.addSubview)
    }
    
    private func configureConstraints() {
        scrollView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(scrollView.snp.width)
        }
        bannerTitleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(24)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        bannerSubtitleLabel.snp.makeConstraints { make in
            make.top.equalTo(bannerTitleLabel.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        bannerContainerView.snp.makeConstraints { make in
            make.top.equalTo(bannerSubtitleLabel.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        menuTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(bannerContainerView.snp.bottom).offset(28)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        menuSubtitleLabel.snp.makeConstraints { make in
            make.top.equalTo(menuTitleLabel.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        menuPreviewContainerView.snp.makeConstraints { make in
            make.top.equalTo(menuSubtitleLabel.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        eventTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(menuPreviewContainerView.snp.bottom).offset(28)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        eventSubtitleLabel.snp.makeConstraints { make in
            make.top.equalTo(eventTitleLabel.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        eventPreviewContainerView.snp.makeConstraints { make in
            make.top.equalTo(eventSubtitleLabel.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(20)
            make.bottom.equalToSuperview().inset(32)
        }
    }
    
    private func makeBannerCard(for banner: HomeBannerItemDTO) -> UIView {
        let card = UIView()
        card.backgroundColor = StarbucksPalette.cream
        card.layer.cornerRadius = 24
        
        let badgeLabel = PaddingLabel(insets: UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12))
        badgeLabel.text = "BANNER API"
        badgeLabel.font = .systemFont(ofSize: 12, weight: .bold)
        badgeLabel.textColor = .white
        badgeLabel.backgroundColor = StarbucksPalette.primaryGreen
        badgeLabel.layer.cornerRadius = 14
        badgeLabel.clipsToBounds = true
        
        let titleText = banner.title ?? banner.altMessage ?? "제목 없음"
        let titleLabel = UILabel()
        titleLabel.text = titleText
        titleLabel.font = .systemFont(ofSize: 21, weight: .bold)
        titleLabel.numberOfLines = 0
        
        let detailLabel = UILabel()
        detailLabel.text = banner.altMessage ?? banner.link ?? "링크 정보 없음"
        detailLabel.font = .systemFont(ofSize: 14, weight: .regular)
        detailLabel.textColor = .secondaryLabel
        detailLabel.numberOfLines = 0
        
        let actionButton = UIButton(type: .system)
        actionButton.setTitle("배너 링크 열기", for: .normal)
        actionButton.tintColor = StarbucksPalette.primaryGreen
        actionButton.titleLabel?.font = .systemFont(ofSize: 14, weight: .semibold)
        actionButton.contentHorizontalAlignment = .left
        actionButton.isHidden = (banner.link ?? "").isEmpty
        actionButton.addAction(
            UIAction { [weak self] _ in
                self?.openLinkIfNeeded(banner.link)
            },
            for: .touchUpInside
        )
        
        [badgeLabel, titleLabel, detailLabel, actionButton].forEach(card.addSubview)
        
        badgeLabel.snp.makeConstraints { make in
            make.top.leading.equalToSuperview().inset(18)
        }
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(badgeLabel.snp.bottom).offset(14)
            make.leading.trailing.equalToSuperview().inset(18)
        }
        detailLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview().inset(18)
        }
        actionButton.snp.makeConstraints { make in
            make.top.equalTo(detailLabel.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview().inset(18)
            make.bottom.equalToSuperview().inset(18)
        }
        
        return card
    }
    
    private func renderBanners(with banners: [HomeBannerItemDTO]) {
        bannerContainerView.subviews.forEach { $0.removeFromSuperview() }
        let cards = banners.map(makeBannerCard(for:))
        layoutCards(cards, in: bannerContainerView, spacing: 16)
    }
    
    private func renderFeaturedMenus(with featuredMenus: [MenuItemDTO]) {
        menuPreviewContainerView.subviews.forEach { $0.removeFromSuperview() }
        let cards = featuredMenus.map { item -> UIView in
            let card = MenuItemCardView()
            card.configure(with: item)
            card.didTap = { [weak self] in
                guard let productCode = item.productCode else { return }
                self?.menuButtonTapped.accept(productCode)
            }
            return card
        }
        layoutCards(cards, in: menuPreviewContainerView, spacing: 14)
    }
    
    private func renderEvents(with events: [StoreEventItemDTO]) {
        eventPreviewContainerView.subviews.forEach { $0.removeFromSuperview() }
        let cards = events.map(makeEventPreviewCard(for:))
        layoutCards(cards, in: eventPreviewContainerView, spacing: 14)
    }
    
    private func layoutCards(_ cards: [UIView], in containerView: UIView, spacing: CGFloat) {
        var previousCard: UIView?
        
        for (index, card) in cards.enumerated() {
            containerView.addSubview(card)
            
            card.snp.makeConstraints { make in
                make.leading.trailing.equalToSuperview()
                if let previousCard {
                    make.top.equalTo(previousCard.snp.bottom).offset(spacing)
                } else {
                    make.top.equalToSuperview()
                }
                if index == cards.count - 1 {
                    make.bottom.equalToSuperview()
                }
            }
            
            previousCard = card
        }
    }
    
    private func makeEventPreviewCard(for item: StoreEventItemDTO) -> UIView {
        let card = UIView()
        card.backgroundColor = StarbucksPalette.softGray
        card.layer.cornerRadius = 22
        
        let titleLabel = UILabel()
        titleLabel.text = item.eventName ?? "제목 없음"
        titleLabel.font = .systemFont(ofSize: 19, weight: .bold)
        titleLabel.numberOfLines = 0
        
        let dateLabel = UILabel()
        dateLabel.text = "\(item.startDate ?? "-") - \(item.endDate ?? "-")"
        dateLabel.font = .systemFont(ofSize: 13, weight: .semibold)
        dateLabel.textColor = StarbucksPalette.primaryGreen
        
        let actionButton = UIButton(type: .system)
        actionButton.setTitle("이벤트 보기", for: .normal)
        actionButton.tintColor = StarbucksPalette.primaryGreen
        actionButton.contentHorizontalAlignment = .left
        actionButton.addAction(
            UIAction { [weak self] _ in
                guard let code = item.eventCode else { return }
                let viewController = EventDetailViewController(eventCode: code)
                self?.navigationController?.pushViewController(viewController, animated: true)
            },
            for: .touchUpInside
        )
        
        [titleLabel, dateLabel, actionButton].forEach(card.addSubview)
        
        titleLabel.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview().inset(18)
        }
        dateLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview().inset(18)
        }
        actionButton.snp.makeConstraints { make in
            make.top.equalTo(dateLabel.snp.bottom).offset(12)
            make.leading.trailing.bottom.equalToSuperview().inset(18)
        }
        
        return card
    }
    
    private static func makeSectionTitleLabel(text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = .systemFont(ofSize: 26, weight: .bold)
        return label
    }
    
    private static func makeSectionSubtitleLabel(text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        return label
    }
    
    private func openLinkIfNeeded(_ link: String?) {
        guard let link, let url = URL(string: link) else { return }
        let viewController = SFSafariViewController(url: url)
        present(viewController, animated: true)
    }
}
