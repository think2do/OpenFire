//
//  ContentView.swift
//  daidaichat
//
//  Created by 呆胶布 on 2026/3/31.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Conversation.updatedAt, order: .reverse) private var conversations: [Conversation]
    
    @State private var currentConversation: Conversation?
    
    var body: some View {
        Group {
            if let conversation = currentConversation {
                ChatView(conversation: conversation)
            } else {
                ProgressView()
                    .onAppear {
                        initializeConversation()
                    }
            }
        }
    }
    
    private func initializeConversation() {
        // 如果有历史对话，加载最新的；否则创建新对话
        if let latestConversation = conversations.first {
            currentConversation = latestConversation
        } else {
            let newConversation = Conversation()
            modelContext.insert(newConversation)
            try? modelContext.save()
            currentConversation = newConversation
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Conversation.self, Message.self, configurations: config)
    
    return ContentView()
        .modelContainer(container)
}
