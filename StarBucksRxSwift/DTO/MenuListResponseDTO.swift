import Foundation

struct MenuListResponseDTO: Decodable, Sendable {
    let list: [MenuItemDTO]?
}

struct MenuItemDTO: Decodable, Sendable {
    let productCode: String?
    let productName: String?
    let content: String?
    let filePath: String?
    let imageUploadPath: String?
    let categoryName: String?
    let kcal: String?
    let sugars: String?
    let protein: String?
    let sodium: String?
    let caffeine: String?
    let saturatedFat: String?
    let newIcon: String?
    let recommend: String?
    let soldOut: String?
    let price: String?
    
    enum CodingKeys: String, CodingKey {
        case productCode = "product_CD"
        case productName = "product_NM"
        case content
        case filePath = "file_PATH"
        case imageUploadPath = "img_UPLOAD_PATH"
        case categoryName = "cate_NAME"
        case kcal
        case sugars
        case protein
        case sodium
        case caffeine
        case saturatedFat = "sat_FAT"
        case newIcon = "newicon"
        case recommend = "recomm"
        case soldOut = "sold_OUT"
        case price
    }
}
