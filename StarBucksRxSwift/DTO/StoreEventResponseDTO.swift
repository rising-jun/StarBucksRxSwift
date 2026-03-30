import Foundation

struct StoreEventResponseDTO: Decodable, Sendable {
    let recordCount: Int?
    let pageSize: Int?
    let page: Int?
    let list: [StoreEventItemDTO]?
    
    enum CodingKeys: String, CodingKey {
        case recordCount
        case pageSize = "pagesize"
        case page
        case list
    }
}

struct StoreEventItemDTO: Decodable, Sendable {
    let eventCode: String?
    let eventName: String?
    let eventDescription: String?
    let eventMemo: String?
    let storeName: String?
    let storeImage: String?
    let startDate: String?
    let endDate: String?
    let eventStartDate: String?
    let eventEndDate: String?
    let isNewStore: String?
    
    enum CodingKeys: String, CodingKey {
        case eventCode = "evt_code"
        case eventName = "evt_name"
        case eventDescription = "evt_desc"
        case eventMemo = "evt_memo"
        case storeName = "s_name"
        case storeImage = "s_image"
        case startDate = "start_date"
        case endDate = "end_date"
        case eventStartDate = "evt_start_dt"
        case eventEndDate = "evt_end_dt"
        case isNewStore = "s_new"
    }
}
