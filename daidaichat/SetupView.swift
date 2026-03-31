//
//  SetupView.swift
//  daidaichat
//
//  Created by 呆胶布 on 2026/3/31.
//

import SwiftUI

/// 初始配置页面，用于用户首次启动时输入 API Key 和 Base URL
struct SetupView: View {
    @ObservedObject var settings = APISettings.shared
    @Binding var isSetupComplete: Bool
    
    @State private var tempApiKey = ""
    @State private var tempBaseURL = ""
    @State private var showError = false
    @State private var errorMessage = ""
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        Image(systemName: "key.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.blue)
                            .frame(maxWidth: .infinity)
                            .padding(.top, 20)
                        
                        Text("欢迎使用呆呆聊天")
                            .font(.title)
                            .bold()
                            .frame(maxWidth: .infinity)
                        
                        Text("请配置你的 API 设置以开始使用")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity)
                            .padding(.bottom, 20)
                    }
                }
                .listRowBackground(Color.clear)
                
                Section {
                    TextField("API Key", text: $tempApiKey)
                        .textContentType(.password)
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
                    Button(action: saveSettings) {
                        HStack {
                            Spacer()
                            Text("开始使用")
                                .bold()
                            Spacer()
                        }
                    }
                    .disabled(tempApiKey.isEmpty || tempBaseURL.isEmpty)
                }
            }
            .navigationTitle("配置 API")
            .navigationBarTitleDisplayMode(.inline)
            .alert("配置错误", isPresented: $showError) {
                Button("确定", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
            .onAppear {
                // 如果已有设置，预填充
                if !settings.apiKey.isEmpty {
                    tempApiKey = settings.apiKey
                }
                if !settings.baseURL.isEmpty {
                    tempBaseURL = settings.baseURL
                }
            }
        }
    }
    
    private func saveSettings() {
        // 验证 Base URL 格式
        let trimmedURL = tempBaseURL.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let url = URL(string: trimmedURL), url.scheme != nil else {
            errorMessage = "请输入有效的 Base URL"
            showError = true
            return
        }
        
        // 验证 API Key
        let trimmedKey = tempApiKey.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedKey.isEmpty else {
            errorMessage = "请输入 API Key"
            showError = true
            return
        }
        
        // 保存设置
        settings.apiKey = trimmedKey
        settings.baseURL = trimmedURL
        
        // 标记配置完成
        isSetupComplete = true
    }
}

#Preview {
    SetupView(isSetupComplete: .constant(false))
}
