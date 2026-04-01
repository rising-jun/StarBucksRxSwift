enum StarbucksAPI: BaseAPI {
    case homeBanner
    case events
    case eventDetail(id: String)
    case menu(category: GoodsCategory)
}
extension StarbucksAPI {
    var baseURL: String { "https://www.starbucks.co.kr" }
    
    var header: [String : String]? { nil }
    var path: String {
        switch self {
        case .homeBanner:
            "/banner/getBannerList.do"
        case .events:
            "/whats_new/getLsmEvent.do"
        case .eventDetail:
            "/whats_new/getLsmEvent.do"
        case .menu(let category):
            "/upload/json/menu/\(category.code).js"
        }
    }
    
    var method: NetworkMethod {
        switch self {
        case .homeBanner:
                .post
        case .events:
                .post
        case .eventDetail:
                .post
        case .menu(let category):
                .get
        }
    }
    
    var body: [String : String]? {
        switch self {
        case .homeBanner:
            [
                "MENU_CD": "STB3136"
            ]
            
        case .events:
            [
                "in_evt_code": "",
                "search_sido": "",
                "search_gugun": "",
                "search_store": "",
                "search_date": "0",
                "page": "1"
            ]
            
        case .eventDetail(let id):
            [
                "in_evt_code": id,
                "search_sido": "",
                "search_gugun": "",
                "search_store": "",
                "search_date": "0",
                "page": "1"
            ]
            
        case .menu:
            nil
            
        }
    }
}

