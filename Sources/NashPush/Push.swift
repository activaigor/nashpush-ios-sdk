import UIKit

public final class Push: NSObject {
    public static var appKey: String?

    private static var pushManager: PushManager?

    public static func register() {
        guard let appKey else {
            fatalError("AppKey not found.")
        }

        Task {
            pushManager = await PushManager(appKey: appKey)

            do {
                try await pushManager?.register()
            } catch {
                fatalError(error.localizedDescription)
            }
        }
    }
}
