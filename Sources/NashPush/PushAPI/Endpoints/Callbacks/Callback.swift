//
//  File.swift
//  
//
//  Created by Denys Litvinskyi on 01.02.2023.
//

import Foundation

enum CallbackType: String, Encodable {
    case messageRead = "message_read"
    case messageClicked = "message_clicked"
    case messageClosed = "message_closed"
}

struct Callback<T: Message>: Encodable {
    let token: String
    let data: T

    enum CodingKeys: CodingKey {
        case type
        case token
        case data
    }

    func encode(to encoder: Encoder) throws {
        var container: KeyedEncodingContainer<Callback<T>.CodingKeys> = encoder.container(keyedBy: Callback<T>.CodingKeys.self)

        try container.encode(self.data.type, forKey: Callback<T>.CodingKeys.type)
        try container.encode(self.token, forKey: Callback<T>.CodingKeys.token)
        try container.encode(self.data, forKey: Callback<T>.CodingKeys.data)
    }
}

protocol Message: Encodable {
    var messageId: String { get }
    var type: CallbackType { get }
}

struct MessageRead: Message {
    private(set) var messageId: String
    private(set) var type: CallbackType = .messageRead
}

struct MessageClicked: Message {
    private(set) var messageId: String
    private(set) var actionId: String
    private(set) var type: CallbackType = .messageClicked
}

struct MessageClosed: Message {
    private(set) var messageId: String
    private(set) var type: CallbackType = .messageClosed
}

extension Request {
    static func create<T: Message>(callback: Callback<T>, subscriberId: String) throws -> Request {
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase

        let body = try encoder.encode(callback)
        return Request(
            path: "/api/\(API.Version.v1.rawValue)/subscribers/\(subscriberId)/callbacks/",
            method: .POST,
            body: body
        )
    }
}
