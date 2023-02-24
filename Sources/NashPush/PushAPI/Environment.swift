import Foundation

enum API {
  enum Environment: String {
    case staging = "webpush.staging.almightypush.com"
    case production = "webpush.production.almightypush.com"
  }

  enum Scheme: String {
    case http
    case https
  }

  enum Version: String {
    case v1
  }
}
