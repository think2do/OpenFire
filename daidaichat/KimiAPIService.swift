//
//  KimiAPIService.swift
//  daidaichat
//
//  Created by 呆胶布 on 2026/3/31.
//

import Foundation
import Combine

/// Kimi API 请求和响应模型
struct ChatCompletionRequest: Codable {
    let model: String
    let messages: [ChatMessage]
}

struct ChatMessage: Codable {
    let role: String
    let content: String
}

struct ChatCompletionResponse: Codable {
    let id: String
    let choices: [Choice]
    
    struct Choice: Codable {
        let message: ChatMessage
        let finishReason: String?
        
        enum CodingKeys: String, CodingKey {
            case message
            case finishReason = "finish_reason"
        }
    }
}

/// 模型列表响应
struct ModelsResponse: Codable {
    let data: [ModelInfo]
    
    struct ModelInfo: Codable, Identifiable {
        let id: String
        let object: String?
        let created: Int?
        let ownedBy: String?
        
        enum CodingKeys: String, CodingKey {
            case id
            case object
            case created
            case ownedBy = "owned_by"
        }
    }
}

/// API 服务类
class KimiAPIService: ObservableObject {
    private let settings = APISettings.shared
    @Published var availableModels: [String] = []
    @Published var isLoadingModels = false
    
    private var apiKey: String {
        settings.apiKey
    }
    
    private var baseURL: String {
        settings.baseURL
    }
    
    private var model: String {
        settings.selectedModel.isEmpty ? "gpt-3.5-turbo" : settings.selectedModel
    }
    
    /// 获取可用的模型列表
    func fetchModels() async throws {
        isLoadingModels = true
        defer { isLoadingModels = false }
        
        let url = URL(string: "\(baseURL)/models")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw APIError.invalidResponse
        }
        
        let modelsResponse = try JSONDecoder().decode(ModelsResponse.self, from: data)
        
        await MainActor.run {
            self.availableModels = modelsResponse.data.map { $0.id }
            
            // 如果当前没有选中模型，自动选择第一个
            if settings.selectedModel.isEmpty && !availableModels.isEmpty {
                settings.selectedModel = availableModels[0]
            }
        }
    }
    
    /// 发送聊天请求
    func sendMessage(messages: [Message]) async throws -> String {
        let url = URL(string: "\(baseURL)/chat/completions")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        
        // 构建系统消息
        let systemMessage = ChatMessage(
            role: "system",
            content: "你是 Kimi，由 Moonshot AI 提供的人工智能助手，你更擅长中文和英文的对话。你会为用户提供安全，有帮助，准确的回答。同时，你会拒绝一切涉及恐怖主义,种族歧视,黄色暴力等问题的回答。Moonshot AI 为专有名词,不可翻译成其他语言。"
        )
        
        // 转换消息格式
        var chatMessages = [systemMessage]
        chatMessages.append(contentsOf: messages.map { message in
            ChatMessage(role: message.role, content: message.content)
        })
        
        let requestBody = ChatCompletionRequest(model: model, messages: chatMessages)
        request.httpBody = try JSONEncoder().encode(requestBody)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw APIError.invalidResponse
        }
        
        let completionResponse = try JSONDecoder().decode(ChatCompletionResponse.self, from: data)
        
        guard let firstChoice = completionResponse.choices.first else {
            throw APIError.noResponse
        }
        
        return firstChoice.message.content
    }
    
    /// 生成对话标题（基于前两轮对话）
    func generateTitle(messages: [Message]) async throws -> String {
        guard messages.count >= 2 else {
            return "新对话"
        }
        
        let url = URL(string: "\(baseURL)/chat/completions")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        
        // 构建生成标题的提示
        let systemMessage = ChatMessage(
            role: "system",
            content: "你是一个对话标题生成助手。请根据用户的对话内容，生成一个简洁的标题（不超过10个字）。只返回标题文本，不要有其他内容。"
        )
        
        // 获取前两轮对话
        let contextMessages = Array(messages.prefix(4)) // 前两轮可能有4条消息（2条用户+2条助手）
        let contextText = contextMessages.map { "\($0.messageRole == .user ? "用户" : "助手"): \($0.content)" }.joined(separator: "\n")
        
        let userMessage = ChatMessage(
            role: "user",
            content: "请为以下对话生成一个简洁的标题：\n\(contextText)"
        )
        
        let requestBody = ChatCompletionRequest(
            model: model,
            messages: [systemMessage, userMessage]
        )
        request.httpBody = try JSONEncoder().encode(requestBody)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            return "新对话"
        }
        
        do {
            let completionResponse = try JSONDecoder().decode(ChatCompletionResponse.self, from: data)
            return completionResponse.choices.first?.message.content ?? "新对话"
        } catch {
            return "新对话"
        }
    }
}

enum APIError: LocalizedError {
    case invalidResponse
    case noResponse
    
    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "服务器响应无效"
        case .noResponse:
            return "未收到响应"
        }
    }
}
