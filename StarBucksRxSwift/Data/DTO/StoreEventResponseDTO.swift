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
    let mobileThumbnailName: String?
    let webThumbnailName: String?
    let imageUploadPath: String?
    
    enum CodingKeys: String, CodingKey {
        case eventCode = "evt_code"
        case promotionCode = "pro_SEQ"
        case eventName = "evt_name"
        case promotionTitle = "title"
        case eventDescription = "evt_desc"
        case eventMemo = "evt_memo"
        case storeName = "s_name"
        case storeImage = "s_image"
        case startDate = "start_date"
        case promotionStartDate = "start_DT"
        case endDate = "end_date"
        case promotionEndDate = "end_DT"
        case eventStartDate = "evt_start_dt"
        case eventEndDate = "evt_end_dt"
        case isNewStore = "s_new"
        case mobileThumbnailName = "mob_THUM"
        case webThumbnailName = "web_THUM"
        case imageUploadPath = "img_UPLOAD_PATH"
    }

    init(
        eventCode: String?,
        eventName: String?,
        eventDescription: String?,
        eventMemo: String?,
        storeName: String?,
        storeImage: String?,
        startDate: String?,
        endDate: String?,
        eventStartDate: String?,
        eventEndDate: String?,
        isNewStore: String?,
        mobileThumbnailName: String? = nil,
        webThumbnailName: String? = nil,
        imageUploadPath: String? = nil
    ) {
        self.eventCode = eventCode
        self.eventName = eventName
        self.eventDescription = eventDescription
        self.eventMemo = eventMemo
        self.storeName = storeName
        self.storeImage = storeImage
        self.startDate = startDate
        self.endDate = endDate
        self.eventStartDate = eventStartDate
        self.eventEndDate = eventEndDate
        self.isNewStore = isNewStore
        self.mobileThumbnailName = mobileThumbnailName
        self.webThumbnailName = webThumbnailName
        self.imageUploadPath = imageUploadPath
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        let promotionCode = try container.decodeIfPresent(Int.self, forKey: .promotionCode).map(String.init)
        let promotionTitle = try container.decodeIfPresent(String.self, forKey: .promotionTitle)
        let promotionStartDate = try container.decodeIfPresent(String.self, forKey: .promotionStartDate)
        let promotionEndDate = try container.decodeIfPresent(String.self, forKey: .promotionEndDate)

        eventCode = try container.decodeIfPresent(String.self, forKey: .eventCode) ?? promotionCode
        eventName = try container.decodeIfPresent(String.self, forKey: .eventName) ?? promotionTitle
        eventDescription = try container.decodeIfPresent(String.self, forKey: .eventDescription)
        eventMemo = try container.decodeIfPresent(String.self, forKey: .eventMemo)
        storeName = try container.decodeIfPresent(String.self, forKey: .storeName)
        storeImage = try container.decodeIfPresent(String.self, forKey: .storeImage)
        startDate = try container.decodeIfPresent(String.self, forKey: .startDate) ?? promotionStartDate
        endDate = try container.decodeIfPresent(String.self, forKey: .endDate) ?? promotionEndDate
        eventStartDate = try container.decodeIfPresent(String.self, forKey: .eventStartDate)
        eventEndDate = try container.decodeIfPresent(String.self, forKey: .eventEndDate)
        isNewStore = try container.decodeIfPresent(String.self, forKey: .isNewStore)
        mobileThumbnailName = try container.decodeIfPresent(String.self, forKey: .mobileThumbnailName)
        webThumbnailName = try container.decodeIfPresent(String.self, forKey: .webThumbnailName)
        imageUploadPath = try container.decodeIfPresent(String.self, forKey: .imageUploadPath)
    }
}
