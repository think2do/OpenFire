//
//  Conversation.swift
//  daidaichat
//
//  Created by 呆胶布 on 2026/3/31.
//

import Foundation
import SwiftData

/// 对话模型
@Model
class Conversation {
    var id: UUID
    var title: String
    var createdAt: Date
    var updatedAt: Date
    
    // 一对多关系：一个对话包含多条消息
    @Relationship(deleteRule: .cascade, inverse: \Message.conversation)
    var messages: [Message]
    
    init(title: String = "新对话", createdAt: Date = Date()) {
        self.id = UUID()
        self.title = title
        self.createdAt = createdAt
        self.updatedAt = createdAt
        self.messages = []
    }
    
    /// 获取最后一条消息内容（用于历史对话列表预览）
    var lastMessagePreview: String {
        guard let lastMessage = messages.last else {
            return "暂无消息"
        }
        return lastMessage.content
    }
    
    /// 获取用户和助手的消息（排除系统消息），按时间排序
    var chatMessages: [Message] {
        messages
            .filter { $0.messageRole != .system }
            .sorted { $0.timestamp < $1.timestamp }
    }
}
