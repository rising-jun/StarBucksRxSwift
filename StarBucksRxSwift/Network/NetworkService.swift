import Foundation
import RxSwift


final class NetworkService{
    func fetchAPI<T: Decodable>(api: BaseAPI) throws -> Single<T>  {
        Single.create { single in
            guard let urlRequest = api.makeURLRequest() else {
                single(.failure(NetworkError.invaliedRequestURL))
                return Disposables.create()
            }
            
            let task = URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
                do {
                    if let error {
                        throw error
                    }
                    let decoder = JSONDecoder()
                    guard let data else { throw NetworkError.nilData }
                    let response = try decoder.decode(T.self, from: data)
                    single(.success(response))
                } catch {
                    single(.failure(error))
                }
            }
            task.resume()
            return Disposables.create()
        }
    }
}
