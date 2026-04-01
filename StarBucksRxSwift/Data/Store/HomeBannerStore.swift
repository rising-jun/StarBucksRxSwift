import Foundation

final class HomeBannerStore {
    private let queue = DispatchQueue(label: "HomeBannerStore.Queue")
    private var banners: [HomeBannerItemDTO] = []
    
    func setHomeBanners(_ banners: [HomeBannerItemDTO]) {
        queue.sync {
            self.banners = banners
        }
    }
    
    func getHomeBanners() -> [HomeBannerItemDTO] {
        queue.sync {
            return banners
        }
    }
}
