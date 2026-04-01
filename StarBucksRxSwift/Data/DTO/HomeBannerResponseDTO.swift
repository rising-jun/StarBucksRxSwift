import Foundation

struct HomeBannerResponseDTO: Decodable, Sendable {
    let list: [HomeBannerItemDTO]?
}

struct HomeBannerItemDTO: Decodable, Sendable {
    let menuCode: String?
    let title: String?
    let imageUploadPath: String?
    let imageName: String?
    let mobileImageName: String?
    let link: String?
    let altMessage: String?
    let viewStartDate: String?
    let viewEndDate: String?
    
    enum CodingKeys: String, CodingKey {
        case menuCode = "menu_CD"
        case title
        case imageUploadPath = "img_UPLOAD_PATH"
        case imageName = "img_NM"
        case mobileImageName = "m_IMG_NM"
        case link = "links"
        case altMessage = "alt_MSG"
        case viewStartDate = "view_SDATE"
        case viewEndDate = "view_EDATE"
    }
}
