//
//  File.swift
//  
//
//  Created by Denys Litvinskyi on 24.02.2023.
//

import Foundation

struct NotificationData: Decodable {
    let campaignId: Int
    let channelId: Int
    let messageId: String
    let subscriberId: Int
    let subscriberToken: String
    let clickActions: [Action]

    enum DecodingError: Error {
        case dataNotFound
    }

    static func notificationData(from userInfo: [AnyHashable: Any]) throws -> NotificationData {
        guard let data = userInfo["data"] as? [AnyHashable: Any] else {
            throw DecodingError.dataNotFound
        }

        do {
            let serializedData = try JSONSerialization.data(withJSONObject: data)

            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase

            return try decoder.decode(NotificationData.self, from: serializedData)
        } catch {
            throw error
        }
    }
}

extension NotificationData {
    struct Action: Decodable {
        let action: String
        let clickActionData: String
    }
}
