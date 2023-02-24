import Foundation

final class PushAPIManager {
    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    func send(deviceToken: String) async throws -> Subscription {
        let subscriber = Subscriber(token: deviceToken)
        let request = try Request.create(subscriber: subscriber)
        let subscription: Subscription = try await send(request: request)

        return subscription
    }

    func send<T: Message>(callback: Callback<T>, subscriberId: String) async throws {
        let request = try Request.create(callback: callback, subscriberId: subscriberId)

        return try await send(request: request)
    }
}

extension PushAPIManager {
    private func send<T: Decodable>(request: Request) async throws -> T {
        let urlRequest = request.urlRequest
        let (data, response) = try await session.data(for: urlRequest)
        guard (response as? HTTPURLResponse)?.statusCode == 200 else {
            throw PushAPIManager.APIError.invalidStatusCode
        }

        let decoder = JSONDecoder()

        return try decoder.decode(T.self, from: data)
    }

    private func send(request: Request) async throws {
        let (_, response) = try await session.data(for: request.urlRequest)
        if (response as? HTTPURLResponse)?.statusCode != 200 {
            throw PushAPIManager.APIError.invalidStatusCode
        }
    }
}

extension PushAPIManager {
    enum APIError: Error {
        case invalidStatusCode
    }
}
