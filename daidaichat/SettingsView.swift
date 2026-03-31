//
//  SettingsView.swift
//  daidaichat
//
//  Created by 呆胶布 on 2026/3/31.
//

import SwiftUI

/// 设置页面
struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var settings = APISettings.shared
    @StateObject private var apiService = KimiAPIService()
    
    @State private var tempApiKey = ""
    @State private var tempBaseURL = ""
    @State private var showResetAlert = false
    @State private var isRefreshingModels = false
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    SecureField("API Key", text: $tempApiKey)
                        .autocapitalization(.none)
                        .autocorrectionDisabled()
                    
                } header: {
                    Text("API Key")
                } footer: {
                    Text("从你的 API 提供商处获取 API Key")
                }
                
                Section {
                    TextField("Base URL", text: $tempBaseURL)
                        .textContentType(.URL)
                        .autocapitalization(.none)
                        .autocorrectionDisabled()
                        .keyboardType(.URL)
                    
                } header: {
                    Text("Base URL")
                } footer: {
                    Text("例如: https://api.openai.com/v1")
                }
                
                Section {
                    if !settings.selectedModel.isEmpty {
                        HStack {
                            Text("当前模型")
                            Spacer()
                            Text(settings.selectedModel)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Button(action: refreshModels) {
                        HStack {
                            Text("刷新模型列表")
                            Spacer()
                            if isRefreshingModels {
                                ProgressView()
                            } else {
                                Image(systemName: "arrow.clockwise")
                            }
                        }
                    }
                    .disabled(isRefreshingModels)
                    
                    if !apiService.availableModels.isEmpty {
                        Text("找到 \(apiService.availableModels.count) 个可用模型")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                } header: {
                    Text("模型设置")
                }
                
                Section {
                    Button(role: .destructive, action: {
                        showResetAlert = true
                    }) {
                        HStack {
                            Spacer()
                            Text("重置所有设置")
                            Spacer()
                        }
                    }
                }
            }
            .navigationTitle("设置")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") {
                        saveSettings()
                    }
                    .disabled(tempApiKey.isEmpty || tempBaseURL.isEmpty)
                }
            }
            .alert("重置设置", isPresented: $showResetAlert) {
                Button("取消", role: .cancel) { }
                Button("重置", role: .destructive) {
                    resetSettings()
                }
            } message: {
                Text("确定要重置所有设置吗？这将清除你的 API Key 和 Base URL。")
            }
            .onAppear {
                tempApiKey = settings.apiKey
                tempBaseURL = settings.baseURL
                
                // 加载已有的模型列表
                if apiService.availableModels.isEmpty && settings.isConfigured {
                    Task {
                        try? await apiService.fetchModels()
                    }
                }
            }
        }
    }
    
    private func saveSettings() {
        let trimmedKey = tempApiKey.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedURL = tempBaseURL.trimmingCharacters(in: .whitespacesAndNewlines)
        
        settings.apiKey = trimmedKey
        settings.baseURL = trimmedURL
        
        dismiss()
    }
    
    private func refreshModels() {
        isRefreshingModels = true
        Task {
            do {
                try await apiService.fetchModels()
            } catch {
                print("刷新模型失败: \(error)")
            }
            isRefreshingModels = false
        }
    }
    
    private func resetSettings() {
        settings.reset()
        tempApiKey = ""
        tempBaseURL = ""
        dismiss()
    }
}

#Preview {
    SettingsView()
}
