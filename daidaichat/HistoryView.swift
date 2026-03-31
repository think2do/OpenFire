//
//  HistoryView.swift
//  daidaichat
//
//  Created by 呆胶布 on 2026/3/31.
//

import SwiftUI
import SwiftData

/// 历史对话页面
struct HistoryView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \Conversation.updatedAt, order: .reverse) private var conversations: [Conversation]
    
    @Binding var selectedConversation: Conversation
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // 顶部工具栏
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .font(.title2)
                            .foregroundColor(.blue)
                    }
                    
                    Spacer()
                    
                    Text("历史对话")
                        .font(.headline)
                    
                    Spacer()
                    
                    Button(action: createNewConversation) {
                        Image(systemName: "square.and.pencil")
                            .font(.title2)
                            .foregroundColor(.blue)
                    }
                }
                .padding()
                .background(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 2, y: 1)
                
                // 对话记录列表
                if conversations.isEmpty {
                    VStack(spacing: 16) {
                        Spacer()
                        Image(systemName: "message.badge")
                            .font(.system(size: 60))
                            .foregroundColor(.secondary)
                        Text("暂无历史对话")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        Spacer()
                    }
                } else {
                    List {
                        ForEach(conversations) { conversation in
                            ConversationRow(conversation: conversation)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    selectedConversation = conversation
                                    dismiss()
                                }
                                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                    Button(role: .destructive) {
                                        deleteConversation(conversation)
                                    } label: {
                                        Label("删除", systemImage: "trash")
                                    }
                                }
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationBarHidden(true)
        }
    }
    
    private func createNewConversation() {
        let newConversation = Conversation()
        modelContext.insert(newConversation)
        try? modelContext.save()
        selectedConversation = newConversation
        dismiss()
    }
    
    private func deleteConversation(_ conversation: Conversation) {
        modelContext.delete(conversation)
        try? modelContext.save()
    }
}

/// 对话记录块
struct ConversationRow: View {
    let conversation: Conversation
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(conversation.title)
                    .font(.headline)
                    .lineLimit(1)
                
                Spacer()
                
                Text(conversation.updatedAt, style: .relative)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Text(conversation.lastMessagePreview)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .lineLimit(2)
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Conversation.self, Message.self, configurations: config)
    
    // 创建示例数据
    let conversation1 = Conversation(title: "Swift 学习")
    let message1 = Message(role: .user, content: "什么是 Swift？")
    message1.conversation = conversation1
    conversation1.messages.append(message1)
    container.mainContext.insert(conversation1)
    
    let conversation2 = Conversation(title: "做饭技巧")
    let message2 = Message(role: .user, content: "如何做红烧肉？")
    message2.conversation = conversation2
    conversation2.messages.append(message2)
    container.mainContext.insert(conversation2)
    
    @State var selected = conversation1
    
    return HistoryView(selectedConversation: $selected)
        .modelContainer(container)
}
