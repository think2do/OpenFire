//
//  ChatView.swift
//  daidaichat
//
//  Created by 呆胶布 on 2026/3/31.
//

import SwiftUI
import SwiftData

/// 对话页面
struct ChatView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var apiService = KimiAPIService()
    @ObservedObject private var settings = APISettings.shared
    
    @State var conversation: Conversation
    @State private var messageText = ""
    @State private var isLoading = false
    @State private var showHistory = false
    @State private var showSettings = false
    @State private var showModelPicker = false
    @State private var errorMessage: String?
    @State private var shouldScrollToBottom = false
    
    var body: some View {
        VStack(spacing: 0) {
            // 顶部工具栏
            HStack {
                Button(action: {
                    showHistory = true
                }) {
                    Image(systemName: "clock.arrow.circlepath")
                        .font(.title2)
                        .foregroundColor(.blue)
                }
                
                Spacer()
                
                VStack(spacing: 2) {
                    Text(conversation.title)
                        .font(.headline)
                        .lineLimit(1)
                    
                    // 显示当前选中的模型
                    if !settings.selectedModel.isEmpty {
                        Button(action: {
                            showModelPicker = true
                        }) {
                            HStack(spacing: 4) {
                                Text(settings.selectedModel)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Image(systemName: "chevron.down")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
                
                Spacer()
                
                HStack(spacing: 16) {
                    Button(action: {
                        showSettings = true
                    }) {
                        Image(systemName: "gear")
                            .font(.title2)
                            .foregroundColor(.blue)
                    }
                    
                    Button(action: createNewConversation) {
                        Image(systemName: "square.and.pencil")
                            .font(.title2)
                            .foregroundColor(.blue)
                    }
                }
            }
            .padding()
            .background(Color(.systemBackground))
            .shadow(color: .black.opacity(0.05), radius: 2, y: 1)
            
            // 对话展示区域
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(conversation.chatMessages) { message in
                            MessageBubble(message: message)
                                .id(message.id)
                        }
                        
                        // 加载指示器
                        if isLoading {
                            HStack {
                                ProgressView()
                                    .padding(.trailing, 8)
                                Text("思考中...")
                                    .foregroundColor(.secondary)
                                    .font(.subheadline)
                                Spacer()
                            }
                            .padding(.horizontal)
                            .id("loading")
                        }
                    }
                    .padding(.vertical)
                }
                .onChange(of: conversation.messages.count) { _, _ in
                    // 当消息数量变化时滚动到底部
                    withAnimation {
                        if let lastMessage = conversation.chatMessages.last {
                            proxy.scrollTo(lastMessage.id, anchor: .bottom)
                        }
                    }
                }
                .onChange(of: isLoading) { _, newValue in
                    // 当开始加载时滚动到加载指示器
                    if newValue {
                        withAnimation {
                            proxy.scrollTo("loading", anchor: .bottom)
                        }
                    }
                }
            }
            
            // 错误提示
            if let error = errorMessage {
                Text(error)
                    .font(.caption)
                    .foregroundColor(.red)
                    .padding(.horizontal)
                    .padding(.vertical, 4)
            }
            
            // 输入区域
            HStack(spacing: 12) {
                TextField("输入消息...", text: $messageText, axis: .vertical)
                    .textFieldStyle(.roundedBorder)
                    .lineLimit(1...5)
                
                Button(action: sendMessage) {
                    Image(systemName: "paperplane.fill")
                        .font(.title3)
                        .foregroundColor(messageText.isEmpty ? .gray : .blue)
                }
                .disabled(messageText.isEmpty || isLoading)
            }
            .padding()
            .background(Color(.systemBackground))
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $showHistory) {
            HistoryView(selectedConversation: $conversation)
        }
        .sheet(isPresented: $showSettings) {
            SettingsView()
        }
        .confirmationDialog("选择模型", isPresented: $showModelPicker) {
            ForEach(apiService.availableModels, id: \.self) { model in
                Button(model) {
                    settings.selectedModel = model
                }
            }
            Button("取消", role: .cancel) { }
        }
        .task {
            // 页面加载时获取模型列表
            if apiService.availableModels.isEmpty {
                do {
                    try await apiService.fetchModels()
                } catch {
                    errorMessage = "获取模型列表失败: \(error.localizedDescription)"
                }
            }
        }
    }
    
    private func sendMessage() {
        let text = messageText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }
        
        // 创建用户消息
        let userMessage = Message(role: .user, content: text)
        userMessage.conversation = conversation
        conversation.messages.append(userMessage)
        conversation.updatedAt = Date()
        
        modelContext.insert(userMessage)
        
        // 清空输入框
        messageText = ""
        errorMessage = nil
        isLoading = true
        
        Task {
            do {
                // 发送请求
                let response = try await apiService.sendMessage(messages: conversation.messages)
                
                // 创建助手消息
                let assistantMessage = Message(role: .assistant, content: response)
                assistantMessage.conversation = conversation
                conversation.messages.append(assistantMessage)
                conversation.updatedAt = Date()
                
                modelContext.insert(assistantMessage)
                
                // 如果是前两轮对话，生成标题
                if conversation.chatMessages.count == 4 && conversation.title == "新对话" {
                    let title = try await apiService.generateTitle(messages: conversation.chatMessages)
                    conversation.title = title
                }
                
                try modelContext.save()
                isLoading = false
            } catch {
                errorMessage = "发送失败: \(error.localizedDescription)"
                isLoading = false
            }
        }
    }
    
    private func createNewConversation() {
        let newConversation = Conversation()
        modelContext.insert(newConversation)
        try? modelContext.save()
        conversation = newConversation
    }
}

/// 消息气泡组件
struct MessageBubble: View {
    let message: Message
    
    var body: some View {
        HStack {
            if message.messageRole == .user {
                Spacer(minLength: 60)
            }
            
            VStack(alignment: message.messageRole == .user ? .trailing : .leading, spacing: 4) {
                Text(message.content)
                    .padding(12)
                    .background(message.messageRole == .user ? Color.blue : Color(.systemGray5))
                    .foregroundColor(message.messageRole == .user ? .white : .primary)
                    .cornerRadius(16)
                
                Text(message.timestamp, style: .time)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            
            if message.messageRole == .assistant {
                Spacer(minLength: 60)
            }
        }
        .padding(.horizontal)
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Conversation.self, Message.self, configurations: config)
    let conversation = Conversation()
    container.mainContext.insert(conversation)
    
    return ChatView(conversation: conversation)
        .modelContainer(container)
}
