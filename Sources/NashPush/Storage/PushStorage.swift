import Foundation

final class PushStorage {
    static var standard = PushStorage()

    private let defaults = UserDefaults.standard

    var deviceToken: String? {
        get {
            value(for: .deviceToken)
        }

        set {
            set(object: newValue, for: .deviceToken)
        }
    }

    var appKey: String? {
        get {
            value(for: .appKey)
        }

        set {
            set(object: newValue, for: .appKey)
        }
    }

    private func value<T>(for key: PushStorage.Key) -> T? {
        return defaults.object(forKey: key.rawValue) as? T
    }

    private func set<T>(object: T?, for key: PushStorage.Key) {
        defaults.set(object, forKey: key.rawValue)
    }
}

extension PushStorage {
    enum Key: String {
        case deviceToken = "nash_push_device_token"
        case appKey = "nash_push_app_key"
    }
}
