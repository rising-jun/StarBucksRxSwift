import SnapKit
import UIKit

final class MenuItemCardView: UIView {
    private static let imageCache = NSCache<NSURL, UIImage>()

    var didTap: (() -> Void)? {
        didSet {
            tapButton.isUserInteractionEnabled = didTap != nil
        }
    }

    private let thumbnailBackgroundView = UIView()
    private let thumbnailImageView = UIImageView()
    private let titleLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let metaLabel = UILabel()
    private let badgeLabel = PaddingLabel(insets: UIEdgeInsets(top: 6, left: 10, bottom: 6, right: 10))
    private let tapButton = UIButton(type: .custom)
    private var imageLoadTask: URLSessionDataTask?
    private var currentImageURL: URL?

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureView()
        configureLayout()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        imageLoadTask?.cancel()
    }

    func configure(with item: MenuItemDTO) {
        titleLabel.text = item.productName ?? "이름 없음"
        descriptionLabel.text = item.content ?? "설명 없음"
        metaLabel.text = item.categoryName ?? item.productCode ?? ""
        configureThumbnail(with: item)

        let badgeTexts = [
            item.newIcon == "N" ? "NEW" : nil,
            item.recommend == "1" ? "RECOMMEND" : nil,
            item.soldOut == "Y" ? "SOLD OUT" : nil
        ].compactMap { $0 }

        badgeLabel.text = badgeTexts.joined(separator: " · ")
        badgeLabel.isHidden = badgeTexts.isEmpty
    }

    private func configureView() {
        backgroundColor = .secondarySystemBackground
        layer.cornerRadius = 22
        clipsToBounds = true

        thumbnailBackgroundView.layer.cornerRadius = 36
        thumbnailBackgroundView.clipsToBounds = true

        thumbnailImageView.contentMode = .scaleAspectFill
        thumbnailImageView.clipsToBounds = true

        tapButton.backgroundColor = .clear
        tapButton.isUserInteractionEnabled = false
        tapButton.addAction(
            UIAction { [weak self] _ in
                self?.didTap?()
            },
            for: .touchUpInside
        )

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
        [thumbnailBackgroundView, titleLabel, descriptionLabel, metaLabel, badgeLabel, tapButton].forEach(addSubview)
        thumbnailBackgroundView.addSubview(thumbnailImageView)

        thumbnailBackgroundView.snp.makeConstraints { make in
            make.top.leading.equalToSuperview().inset(18)
            make.width.height.equalTo(72)
            make.bottom.lessThanOrEqualToSuperview().inset(18)
        }
        thumbnailImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(18)
            make.leading.equalTo(thumbnailBackgroundView.snp.trailing).offset(16)
            make.trailing.equalToSuperview().inset(18)
        }
        descriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
            make.leading.trailing.equalTo(titleLabel)
        }
        metaLabel.snp.makeConstraints { make in
            make.top.equalTo(descriptionLabel.snp.bottom).offset(10)
            make.leading.trailing.equalTo(titleLabel)
        }
        badgeLabel.snp.makeConstraints { make in
            make.top.equalTo(metaLabel.snp.bottom).offset(12)
            make.leading.equalTo(titleLabel)
            make.bottom.equalToSuperview().inset(18)
        }
        tapButton.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    private func configureThumbnail(with item: MenuItemDTO) {
        imageLoadTask?.cancel()
        imageLoadTask = nil

        thumbnailBackgroundView.backgroundColor = .clear
        thumbnailImageView.image = MenuThumbnailFactory.makeImage(for: item)

        guard let imageURL = makeImageURL(for: item) else {
            currentImageURL = nil
            return
        }

        currentImageURL = imageURL

        if let cachedImage = Self.imageCache.object(forKey: imageURL as NSURL) {
            applyRemoteImage(cachedImage, for: imageURL)
            return
        }

        imageLoadTask = URLSession.shared.dataTask(with: imageURL) { [weak self] data, _, _ in
            guard
                let self,
                let data,
                let image = UIImage(data: data)
            else {
                return
            }

            Self.imageCache.setObject(image, forKey: imageURL as NSURL)

            DispatchQueue.main.async {
                self.applyRemoteImage(image, for: imageURL)
            }
        }
        imageLoadTask?.resume()
    }

    private func applyRemoteImage(_ image: UIImage, for url: URL) {
        guard currentImageURL == url else { return }
        thumbnailImageView.image = image
        thumbnailBackgroundView.backgroundColor = .clear
    }

    private func makeImageURL(for item: MenuItemDTO) -> URL? {
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
}
