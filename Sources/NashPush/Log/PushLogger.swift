//
//  File.swift
//  
//
//  Created by Denys Litvinskyi on 30.01.2023.
//

import Foundation

final class PushLogger {
  static let shared = PushLogger()

  func log(info: String) {
    log(message: info, on: .info)
  }

  func log(warning: String) {
    log(message: warning, on: .warning)
  }

  func log(error: Error) {
    log(message: error.localizedDescription, on: .error)
  }

  func log(error message: String) {
    log(message: message, on: .error)
  }

  private func log(message: String, on level: PushLogger.Level) {
    print("\(level.rawValue.uppercased()): \(message)")
  }
}

extension PushLogger {
  enum Level: String {
    case error
    case warning
    case info
  }
}
