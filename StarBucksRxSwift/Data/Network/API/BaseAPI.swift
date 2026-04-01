import Foundation

protocol BaseAPI {
    var path: String { get }
    var baseURL: String { get }
    var method: NetworkMethod { get }
    var header: [String: String]? { get }
    var body: [String: String]? { get }
}
extension BaseAPI {
    private func makeFormBody(_ parameters: [String: String]) -> Data? {
        let bodyString = parameters
            .map { "\($0.key)=\($0.value)" }
            .joined(separator: "&")
        
        return bodyString.data(using: .utf8)
    }
    
    func makeURLRequest() -> URLRequest? {
        let urlString = baseURL + path
        guard let url = URL(string: urlString) else { return nil }
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = method.string
        if let header {
            for (field, value) in header {
                urlRequest.setValue(value, forHTTPHeaderField: field)
            }
        }
        
        if let body {
            let body = makeFormBody(body)
            urlRequest.httpBody = body
        }
        
        return urlRequest
    }
}

