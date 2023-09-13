import Foundation

struct Request {
    let path: String
    let method: HTTPMethod
    let body: Data?

    var url: URL? {
        var components = URLComponents()
        components.scheme = API.Scheme.https.rawValue
        components.host = API.Environment.production.rawValue
        components.path = path

        return components.url
    }

    var urlRequest: URLRequest {
        guard let url = url, let appKey = PushStorage.standard.appKey else {
            fatalError("Unable to create URL")
        }

        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.allHTTPHeaderFields = [
            "Channel-Token": appKey,
            "Content-Type": "application/json"
        ]
        request.httpBody = body

        return request
    }
}
