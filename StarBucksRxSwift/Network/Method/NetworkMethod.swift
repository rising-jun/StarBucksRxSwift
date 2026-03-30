enum NetworkMethod {
    case get
    case post
    
    var string: String {
        switch self {
        case .get:
            return "GET"
        case .post:
            return "POST"
        }
    }
}
