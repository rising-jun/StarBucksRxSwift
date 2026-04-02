import SafariServices
import SnapKit
import UIKit
import RxSwift
import RxCocoa

private final class BannerGradientView: UIView {
    override class var layerClass: AnyClass {
        CAGradientLayer.self
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        guard let gradientLayer = layer as? CAGradientLayer else { return }
        gradientLayer.colors = [
            UIColor.clear.cgColor,
            UIColor.black.withAlphaComponent(0.18).cgColor,
            UIColor.black.withAlphaComponent(0.82).cgColor
        ]
        gradientLayer.locations = [0.0, 0.55, 1.0]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1.0)
    }
}

final class HomeViewController: UIViewController {
    private enum Layout {
        static let bannerAspectRatio: CGFloat = 900 / 640
        static let eventAspectRatio: CGFloat = 0.56
        static let menuImageDiameter: CGFloat = 108
        static let menuItemWidth: CGFloat = 124
        static let menuItemHeight: CGFloat = 152
        static let menuItemSpacing: CGFloat = 16
    }

    private static let remoteImageCache = NSCache<NSURL, UIImage>()

    private let viewModel = HomeViewModel()
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let bannerTitleLabel = HomeViewController.makeSectionTitleLabel(text: "Season Banner")
    private let bannerSubtitleLabel = HomeViewController.makeSectionSubtitleLabel(text: "메인 배너 API로 대체될 영역")
    private let bannerContainerView = UIView()
    private let menuTitleLabel = HomeViewController.makeSectionTitleLabel(text: "Featured Menu")
    private let menuSubtitleLabel = HomeViewController.makeSectionSubtitleLabel(text: "메뉴 API가 붙을 대표 메뉴 미리보기")
    private let menuPreviewScrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsHorizontalScrollIndicator = false
        return scrollView
    }()
    private let menuPreviewStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .top
        stackView.spacing = Layout.menuItemSpacing
        return stackView
    }()
    private let eventTitleLabel = HomeViewController.makeSectionTitleLabel(text: "Events")
    private let eventSubtitleLabel = HomeViewController.makeSectionSubtitleLabel(text: "이벤트 API가 붙을 카드 리스트 미리보기")
    private let eventPreviewContainerView = UIView()
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
    
    private let disposeBag = DisposeBag()
    private var menuButtonTapped = PublishRelay<String>()
    private var toastHideWorkItem: DispatchWorkItem?
    
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

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
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

        output.errorMessage
            .emit(with: self) { owner, message in
                owner.showToast(message)
            }
            .disposed(by: disposeBag)
    }
    
    private func configureView() {
        view.backgroundColor = .systemBackground
    }
    
    private func configureHierarchy() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        menuPreviewScrollView.addSubview(menuPreviewStackView)
        
        [
            bannerTitleLabel,
            bannerSubtitleLabel,
            bannerContainerView,
            menuTitleLabel,
            menuSubtitleLabel,
            menuPreviewScrollView,
            eventTitleLabel,
            eventSubtitleLabel,
            eventPreviewContainerView
        ].forEach(contentView.addSubview)
        view.addSubview(toastLabel)
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
        menuPreviewScrollView.snp.makeConstraints { make in
            make.top.equalTo(menuSubtitleLabel.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(Layout.menuItemHeight)
        }
        menuPreviewStackView.snp.makeConstraints { make in
            make.edges.equalTo(menuPreviewScrollView.contentLayoutGuide).inset(UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20))
            make.height.equalTo(menuPreviewScrollView.frameLayoutGuide)
        }
        eventTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(menuPreviewScrollView.snp.bottom).offset(28)
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
        toastLabel.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(20)
            make.bottom.equalTo(view.safeAreaLayoutGuide).inset(16)
        }
    }
    
    private func makeBannerCard(for banner: HomeBannerItemDTO) -> UIView {
        let card = UIView()
        card.backgroundColor = .clear
        card.layer.cornerRadius = 24
        card.clipsToBounds = true

        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = StarbucksPalette.softGray
        imageView.image = makeBannerPlaceholderImage()
        configureBannerImage(imageView, with: banner)

        let gradientView = BannerGradientView()
        gradientView.isUserInteractionEnabled = false
        
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
        titleLabel.textColor = .white
        titleLabel.numberOfLines = 0
        
        let detailLabel = UILabel()
        detailLabel.text = banner.altMessage ?? banner.link ?? "링크 정보 없음"
        detailLabel.font = .systemFont(ofSize: 14, weight: .regular)
        detailLabel.textColor = UIColor.white.withAlphaComponent(0.88)
        detailLabel.numberOfLines = 0
        
        let actionButton = UIButton(type: .system)
        actionButton.setTitle("배너 링크 열기", for: .normal)
        actionButton.tintColor = .white
        actionButton.titleLabel?.font = .systemFont(ofSize: 14, weight: .semibold)
        actionButton.contentHorizontalAlignment = .left
        actionButton.isHidden = (banner.link ?? "").isEmpty
        actionButton.addAction(
            UIAction { [weak self] _ in
                self?.openLinkIfNeeded(banner.link)
            },
            for: .touchUpInside
        )
        
        [imageView, gradientView, badgeLabel, titleLabel, detailLabel, actionButton].forEach(card.addSubview)
        
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.height.equalTo(imageView.snp.width).multipliedBy(Layout.bannerAspectRatio)
        }
        gradientView.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.62)
        }
        badgeLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(20)
            make.bottom.equalTo(titleLabel.snp.top).offset(-14)
        }
        titleLabel.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(20)
            make.bottom.equalTo(detailLabel.snp.top).offset(-8)
        }
        detailLabel.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(20)
            make.bottom.equalTo(actionButton.snp.top).offset(-10)
        }
        actionButton.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(20)
            make.bottom.equalToSuperview().inset(20)
        }
        
        return card
    }
    
    private func renderBanners(with banners: [HomeBannerItemDTO]) {
        bannerContainerView.subviews.forEach { $0.removeFromSuperview() }
        let cards = banners.map(makeBannerCard(for:))
        layoutCards(cards, in: bannerContainerView, spacing: 16)
    }
    
    private func renderFeaturedMenus(with featuredMenus: [MenuItemDTO]) {
        menuPreviewStackView.arrangedSubviews.forEach { view in
            menuPreviewStackView.removeArrangedSubview(view)
            view.removeFromSuperview()
        }

        for item in featuredMenus {
            let previewView = makeFeaturedMenuPreviewView(for: item)
            menuPreviewStackView.addArrangedSubview(previewView)
        }
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
        card.layer.cornerRadius = 22
        card.clipsToBounds = true
        var aspectRatioConstraint = card.heightAnchor.constraint(equalTo: card.widthAnchor, multiplier: Layout.eventAspectRatio)
        aspectRatioConstraint.isActive = true

        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.image = makeEventPlaceholderImage()
        configureEventImage(imageView, with: item) { [weak card] image in
            guard let card else { return }

            let size = image.size
            guard size.width > 0, size.height > 0 else { return }

            let aspectRatio = size.height / size.width
            aspectRatioConstraint.isActive = false
            aspectRatioConstraint = card.heightAnchor.constraint(equalTo: card.widthAnchor, multiplier: aspectRatio)
            aspectRatioConstraint.isActive = true
            card.superview?.setNeedsLayout()
            card.superview?.layoutIfNeeded()
        }

        let gradientView = BannerGradientView()
        gradientView.isUserInteractionEnabled = false
        
        let titleLabel = UILabel()
        titleLabel.text = item.eventName ?? "제목 없음"
        titleLabel.font = .systemFont(ofSize: 19, weight: .bold)
        titleLabel.textColor = .white
        titleLabel.numberOfLines = 0
        
        let dateLabel = UILabel()
        dateLabel.text = "\(item.startDate ?? "-") - \(item.endDate ?? "-")"
        dateLabel.font = .systemFont(ofSize: 13, weight: .semibold)
        dateLabel.textColor = UIColor.white.withAlphaComponent(0.9)
        
        let actionButton = UIButton(type: .system)
        actionButton.setTitle("이벤트 보기", for: .normal)
        actionButton.tintColor = .white
        actionButton.contentHorizontalAlignment = .left
        actionButton.addAction(
            UIAction { [weak self] _ in
                guard let code = item.eventCode else { return }
                self?.openLinkIfNeeded("https://www.starbucks.co.kr/app/whats_new/campaign_view.do?pro_seq=\(code)")
            },
            for: .touchUpInside
        )
        
        [imageView, gradientView, titleLabel, dateLabel, actionButton].forEach(card.addSubview)

        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        gradientView.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.6)
        }
        titleLabel.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(18)
            make.bottom.equalTo(dateLabel.snp.top).offset(-8)
        }
        dateLabel.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(18)
            make.bottom.equalTo(actionButton.snp.top).offset(-10)
        }
        actionButton.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(18)
            make.bottom.equalToSuperview().inset(18)
        }
        
        return card
    }

    private func makeFeaturedMenuPreviewView(for item: MenuItemDTO) -> UIView {
        let containerView = UIView()

        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = Layout.menuImageDiameter / 2
        imageView.image = MenuThumbnailFactory.makeImage(for: item, diameter: Layout.menuImageDiameter)

        let titleLabel = UILabel()
        titleLabel.text = item.productName ?? "이름 없음"
        titleLabel.font = .systemFont(ofSize: 13, weight: .semibold)
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 2

        let tapButton = UIButton(type: .custom)
        tapButton.backgroundColor = .clear
        tapButton.addAction(
            UIAction { [weak self] _ in
                guard let productCode = item.productCode else { return }
                self?.menuButtonTapped.accept(productCode)
            },
            for: .touchUpInside
        )

        containerView.addSubview(imageView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(tapButton)

        containerView.snp.makeConstraints { make in
            make.width.equalTo(Layout.menuItemWidth)
        }
        imageView.snp.makeConstraints { make in
            make.top.centerX.equalToSuperview()
            make.width.height.equalTo(Layout.menuImageDiameter)
        }
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview()
            make.bottom.lessThanOrEqualToSuperview()
        }
        tapButton.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        configureMenuPreviewImage(imageView, with: item)

        return containerView
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

    private func configureBannerImage(_ imageView: UIImageView, with banner: HomeBannerItemDTO) {
        guard let imageURL = makeBannerImageURL(for: banner) else { return }
        loadImage(from: imageURL, into: imageView)
    }

    private func configureMenuPreviewImage(_ imageView: UIImageView, with item: MenuItemDTO) {
        guard let imageURL = makeMenuImageURL(for: item) else { return }
        loadImage(from: imageURL, into: imageView)
    }

    private func configureEventImage(
        _ imageView: UIImageView,
        with item: StoreEventItemDTO,
        onLoad: ((UIImage) -> Void)? = nil
    ) {
        guard let imageURL = makeEventImageURL(for: item) else { return }
        loadImage(from: imageURL, into: imageView, onLoad: onLoad)
    }

    private func loadImage(
        from url: URL,
        into imageView: UIImageView,
        onLoad: ((UIImage) -> Void)? = nil
    ) {
        if let cachedImage = Self.remoteImageCache.object(forKey: url as NSURL) {
            imageView.image = cachedImage
            onLoad?(cachedImage)
            return
        }

        URLSession.shared.dataTask(with: url) { data, _, _ in
            guard let data, let image = UIImage(data: data) else { return }
            Self.remoteImageCache.setObject(image, forKey: url as NSURL)

            DispatchQueue.main.async {
                imageView.image = image
                onLoad?(image)
            }
        }.resume()
    }

    private func makeBannerImageURL(for banner: HomeBannerItemDTO) -> URL? {
        let mobileImageName = banner.mobileImageName?.trimmingCharacters(in: .whitespacesAndNewlines)
        let imageName = banner.imageName?.trimmingCharacters(in: .whitespacesAndNewlines)
        let fileName = (mobileImageName?.isEmpty == false ? mobileImageName : nil)
            ?? (imageName?.isEmpty == false ? imageName : nil)
        guard let fileName else { return nil }
        return URL(string: "https://image.istarbucks.co.kr/upload/banner/\(fileName)")
    }

    private func makeMenuImageURL(for item: MenuItemDTO) -> URL? {
        let resolvedPath: String?
        switch (
            item.imageUploadPath?.trimmingCharacters(in: .whitespacesAndNewlines),
            item.filePath?.trimmingCharacters(in: .whitespacesAndNewlines)
        ) {
        case let (.some(basePath), .some(filePath)) where !basePath.isEmpty && !filePath.isEmpty:
            resolvedPath = basePath.hasSuffix("/") ? basePath + filePath : basePath + "/" + filePath
        case let (.some(basePath), _) where !basePath.isEmpty:
            resolvedPath = basePath
        case let (_, .some(filePath)) where !filePath.isEmpty:
            resolvedPath = filePath
        default:
            resolvedPath = nil
        }

        guard let resolvedPath else {
            return nil
        }

        return URL(string: resolvedPath)
    }

    private func makeEventImageURL(for item: StoreEventItemDTO) -> URL? {
        if
            let thumbnailName = item.mobileThumbnailName?.trimmingCharacters(in: .whitespacesAndNewlines),
            !thumbnailName.isEmpty
        {
            return URL(string: "https://image.istarbucks.co.kr/upload/promotion/\(thumbnailName)")
        }

        if
            let thumbnailName = item.webThumbnailName?.trimmingCharacters(in: .whitespacesAndNewlines),
            !thumbnailName.isEmpty
        {
            return URL(string: "https://image.istarbucks.co.kr/upload/promotion/\(thumbnailName)")
        }

        guard
            let imagePath = item.storeImage?.trimmingCharacters(in: .whitespacesAndNewlines),
            !imagePath.isEmpty
        else {
            return nil
        }

        if imagePath.hasPrefix("http://") || imagePath.hasPrefix("https://") {
            return URL(string: imagePath)
        }

        if imagePath.hasPrefix("/") {
            return URL(string: "https://image.istarbucks.co.kr\(imagePath)")
        }

        return URL(string: "https://image.istarbucks.co.kr/\(imagePath)")
    }

    private func makeBannerPlaceholderImage() -> UIImage? {
        let size = CGSize(width: 320, height: 176)
        let renderer = UIGraphicsImageRenderer(size: size)

        return renderer.image { context in
            let rect = CGRect(origin: .zero, size: size)
            let drawingContext = context.cgContext
            let colors = [StarbucksPalette.primaryGreen.cgColor, StarbucksPalette.cream.cgColor] as CFArray
            let colorSpace = CGColorSpaceCreateDeviceRGB()

            if let gradient = CGGradient(colorsSpace: colorSpace, colors: colors, locations: [0, 1]) {
                drawingContext.drawLinearGradient(
                    gradient,
                    start: CGPoint(x: 0, y: 0),
                    end: CGPoint(x: size.width, y: size.height),
                    options: []
                )
            }

            let symbolConfiguration = UIImage.SymbolConfiguration(pointSize: 40, weight: .medium)
            let symbolImage = UIImage(
                systemName: "photo.on.rectangle.angled",
                withConfiguration: symbolConfiguration
            )?.withTintColor(.white.withAlphaComponent(0.9), renderingMode: .alwaysOriginal)
            symbolImage?.draw(in: CGRect(x: rect.midX - 24, y: rect.midY - 24, width: 48, height: 48))
        }
    }

    private func makeEventPlaceholderImage() -> UIImage? {
        let size = CGSize(width: 160, height: 160)
        let renderer = UIGraphicsImageRenderer(size: size)

        return renderer.image { context in
            let rect = CGRect(origin: .zero, size: size)
            let drawingContext = context.cgContext
            let colors = [StarbucksPalette.primaryGreen.cgColor, StarbucksPalette.softGray.cgColor] as CFArray
            let colorSpace = CGColorSpaceCreateDeviceRGB()

            if let gradient = CGGradient(colorsSpace: colorSpace, colors: colors, locations: [0, 1]) {
                drawingContext.drawLinearGradient(
                    gradient,
                    start: CGPoint(x: 0, y: 0),
                    end: CGPoint(x: size.width, y: size.height),
                    options: []
                )
            }

            let symbolConfiguration = UIImage.SymbolConfiguration(pointSize: 34, weight: .medium)
            let symbolImage = UIImage(
                systemName: "storefront.fill",
                withConfiguration: symbolConfiguration
            )?.withTintColor(.white.withAlphaComponent(0.92), renderingMode: .alwaysOriginal)
            symbolImage?.draw(in: CGRect(x: rect.midX - 20, y: rect.midY - 20, width: 40, height: 40))
        }
    }
}
