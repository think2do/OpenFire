//
//  APISettings.swift
//  daidaichat
//
//  Created by 呆胶布 on 2026/3/31.
//

import Foundation
import Combine

/// API 配置设置
class APISettings: ObservableObject {
    static let shared = APISettings()
    
    @Published var apiKey: String {
        didSet {
            UserDefaults.standard.set(apiKey, forKey: "apiKey")
        }
    }
    
    @Published var baseURL: String {
        didSet {
            UserDefaults.standard.set(baseURL, forKey: "baseURL")
        }
    }
    
    @Published var selectedModel: String {
        didSet {
            UserDefaults.standard.set(selectedModel, forKey: "selectedModel")
        }
    }
    
    private init() {
        self.apiKey = UserDefaults.standard.string(forKey: "apiKey") ?? ""
        self.baseURL = UserDefaults.standard.string(forKey: "baseURL") ?? ""
        self.selectedModel = UserDefaults.standard.string(forKey: "selectedModel") ?? ""
    }
    
    /// 检查是否已完成初始配置
    var isConfigured: Bool {
        !apiKey.isEmpty && !baseURL.isEmpty
    }
    
    /// 重置所有设置
    func reset() {
        apiKey = ""
        baseURL = ""
        selectedModel = ""
    }
}
