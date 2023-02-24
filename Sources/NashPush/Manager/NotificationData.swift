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
    let actions: [Action]
}

extension NotificationData {
    struct Action: Decodable {
        let action: String
        let clickActionData: String
    }
}
