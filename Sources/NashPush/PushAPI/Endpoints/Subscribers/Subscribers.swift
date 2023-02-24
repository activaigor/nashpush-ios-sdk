import Foundation

struct Subscriber: Encodable {
  let token: String
  let isIos: Bool = true
}

struct Subscription: Decodable {
  let uuid: String
}

extension Request {
  static func create(subscriber: Subscriber) throws -> Request {
    let encoder = JSONEncoder()
    encoder.keyEncodingStrategy = .convertToSnakeCase

    let body = try encoder.encode(subscriber)
    return Request(
      path: "/api/\(API.Version.v1.rawValue)/subscribers/",
      method: .POST,
      body: body
    )
  }
}
