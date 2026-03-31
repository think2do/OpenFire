//
//  Message.swift
//  daidaichat
//
//  Created by 呆胶布 on 2026/3/31.
//

import Foundation
import SwiftData

/// 消息角色
enum MessageRole: String, Codable {
    case system = "system"
    case user = "user"
    case assistant = "assistant"
}

/// 单条消息模型
@Model
class Message {
    var id: UUID
    var role: String // MessageRole的原始值
    var content: String
    var timestamp: Date
    
    // 关联到对话
    var conversation: Conversation?
    
    init(role: MessageRole, content: String, timestamp: Date = Date()) {
        self.id = UUID()
        self.role = role.rawValue
        self.content = content
        self.timestamp = timestamp
    }
    
    var messageRole: MessageRole {
        MessageRole(rawValue: role) ?? .user
    }
}
