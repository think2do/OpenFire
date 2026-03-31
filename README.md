# DaiDaiChat - AI 聊天助手 🤖💬

<div align="center">

[![Platform](https://img.shields.io/badge/platform-iOS%2017.0%2B-blue.svg)](https://developer.apple.com/ios/)
[![Swift](https://img.shields.io/badge/Swift-5.9+-orange.svg)](https://swift.org)
[![SwiftUI](https://img.shields.io/badge/SwiftUI-iOS%2017-green.svg)](https://developer.apple.com/xcode/swiftui/)
[![License](https://img.shields.io/badge/license-MIT-lightgrey.svg)](LICENSE)

一个基于 SwiftUI 和 SwiftData 开发的现代化 AI 聊天应用，集成 Moonshot AI 的 Kimi 模型。

[功能特性](#功能特性) • [技术栈](#技术栈) • [快速开始](#快速开始) • [使用说明](#使用说明) • [项目结构](#项目结构)

<img src="https://via.placeholder.com/800x400/4A90E2/FFFFFF?text=DaiDaiChat+Screenshot" alt="App Screenshot" width="600"/>

</div>

## ✨ 功能特性

### 核心功能
- 🗨️ **多轮对话** - 支持与 AI 进行连续对话， 维护上下文
- 🏷️ **智能标题** - 基于前两轮对话自动生成对话主题
- 💾 **本地存储** - 使用 SwiftData 持久化保存所有对话记录
- 📜 **历史记录** - 查看所有历史对话，最新消息置顶
- ↩️ **继续对话** - 随时选择历史对话继续聊天
- 🗑️ **删除管理** - 左滑删除不需要的对话组

### 用户体验
- 📱 **原生体验** - 纯 SwiftUI 打造的流畅界面
- 🔄 **实时滚动** - 新消息自动滚动到底部
- ⏳ **加载状态** - 显示"思考中"的友好提示
- ⚠️ **错误处理** - 网络异常时的友好错误提示
- 🎨 **优雅设计** - 消息气泡、时间戳等细节打磨

## 🛠 技术栈

- **语言**: Swift 5.9+
- **框架**: SwiftUI, SwiftData, Combine
- **最低版本**: iOS 17.0+
- **架构**: MVVM 架构模式
- **并发**: Swift Concurrency (async/await)
- **AI 模型**: Moonshot AI - Kimi K2.5

## 📋 环境要求

- Xcode 15.0+
- iOS 17.0+
- macOS 14.0+ (用于开发)
- 有效的 Moonshot AI API Key

## 🚀 快速开始

### 1. 克隆项目

```bash
git clone https://github.com/你的用户名/daidaichat.git
cd daidaichat
```

### 2. 打开项目

```bash
open daidaichat.xcodeproj
```

### 3. 首次启动配置 API

应用首次启动时会进入配置页，支持用户自行输入：

- **API Key**：你的服务商密钥
- **Base URL**：例如 `https://api.openai.com/v1` 或 `https://api.moonshot.cn/v1`

配置保存后，应用会自动请求 `Base URL/models` 获取模型列表，并自动选择首个可用模型（你也可以后续手动切换）。

> 💡 **提示**: 只要服务兼容 OpenAI API 格式（`/chat/completions` + `/models`），即可接入。

### 4. 配置网络权限

在项目的 `Info.plist` 中添加网络权限：

**方法 1：通过 Xcode 界面**
1. 选择项目 → Target → Info
2. 添加 `App Transport Security Settings` (Dictionary)
3. 在其下添加 `Allow Arbitrary Loads` (Boolean = YES)

**方法 2：直接编辑 Info.plist**

```xml
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsArbitraryLoads</key>
    <true/>
</dict>
```

⚠️ **生产环境建议使用更安全的配置**：

```xml
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSExceptionDomains</key>
    <dict>
        <key>api.moonshot.cn</key>
        <dict>
            <key>NSExceptionAllowsInsecureHTTPLoads</key>
            <false/>
            <key>NSIncludesSubdomains</key>
            <true/>
            <key>NSExceptionRequiresForwardSecrecy</key>
            <true/>
            <key>NSExceptionMinimumTLSVersion</key>
            <string>TLSv1.2</string>
        </dict>
    </dict>
</dict>
```

### 5. 运行项目

在 Xcode 中选择模拟器或真机，点击 `Run` (⌘R)

## 📱 使用说明

### 开始聊天
1. 首次打开应用先完成 API 配置（API Key + Base URL）
2. 在底部输入框输入消息
3. 点击发送按钮 ✈️

### API 与模型设置
- **修改配置**: 点击设置页修改 API Key 与 Base URL
- **模型列表**: 自动拉取模型列表，也可手动点击“刷新模型列表”
- **切换模型**: 在聊天页模型菜单中选择需要的模型

### 管理对话
- **新对话**: 点击右上角 ✏️ 按钮
- **查看历史**: 点击左上角 🕐 按钮
- **删除对话**: 在历史页面左滑对话项
- **继续对话**: 在历史页面点击对话项

### 功能演示

```
对话页面
┌─────────────────────────────┐
│  🕐   对话标题          ✏️   │
├─────────────────────────────┤
│                             │
│  你好！               [用户] │
│                             │
│  [AI]  你好！我是 Kimi...   │
│                             │
├─────────────────────────────┤
│  [输入框...]         ✈️     │
└─────────────────────────────┘
```

## 📂 项目结构

```
daidaichat/
├── daidaichatApp.swift        # 应用入口，SwiftData 配置
├── ContentView.swift           # 主视图，初始化对话
├── ChatView.swift              # 对话页面（核心功能）
├── HistoryView.swift           # 历史对话页面
├── Models/
│   ├── Message.swift           # 消息数据模型
│   └── Conversation.swift      # 对话数据模型
├── Services/
│   └── KimiAPIService.swift    # Kimi API 服务
└── README.md                   # 项目说明文档
```

### 核心文件说明

| 文件 | 说明 |
|-----|------|
| `Message.swift` | 定义消息模型，包含角色、内容、时间戳 |
| `Conversation.swift` | 定义对话模型，管理消息集合 |
| `KimiAPIService.swift` | 封装 API 调用，处理网络请求 |
| `ChatView.swift` | 对话界面，消息列表和输入框 |
| `HistoryView.swift` | 历史对话列表界面 |

## 🔧 技术亮点

### SwiftData 持久化
```swift
@Model
class Conversation {
    var messages: [Message]
    @Relationship(deleteRule: .cascade, inverse: \Message.conversation)
}
```

### Swift Concurrency
```swift
Task {
    let response = try await apiService.sendMessage(messages: messages)
    // 处理响应
}
```

### 响应式查询
```swift
@Query(sort: \Conversation.updatedAt, order: .reverse) 
private var conversations: [Conversation]
```

## 🧠 提示词设计

### 提示词思路
- **角色锁定**：先定义助手身份与能力边界，避免回答风格漂移。
- **安全约束**：在系统提示词中明确拒答高风险内容，降低违规输出概率。
- **任务拆分**：将“聊天回复”和“标题生成”拆为两套提示词，减少目标冲突。
- **输出约束**：对标题生成增加长度和格式限制，保证结果可直接用于 UI 展示。

### 具体提示词

**1) 对话系统提示词（聊天）**

```text
你是 Kimi，由 Moonshot AI 提供的人工智能助手，你更擅长中文和英文的对话。你会为用户提供安全，有帮助，准确的回答。同时，你会拒绝一切涉及恐怖主义,种族歧视,黄色暴力等问题的回答。Moonshot AI 为专有名词,不可翻译成其他语言。
```

**2) 标题生成系统提示词（自动命名）**

```text
你是一个对话标题生成助手。请根据用户的对话内容，生成一个简洁的标题（不超过10个字）。只返回标题文本，不要有其他内容。
```

## 🎯 开发计划

- [ ] 流式响应支持
- [ ] 多模态消息（图片、文件）
- [ ] 消息搜索功能
- [ ] 对话导出（JSON/TXT）
- [ ] 深色模式优化
- [ ] 自定义 API 配置界面
- [ ] 消息重试功能
- [ ] 消息复制和分享
- [ ] iPad 适配
- [ ] macOS 版本

## 🐛 已知问题

- 暂不支持流式响应
- 仅适配 iPhone 竖屏模式

## 🤝 贡献指南

欢迎提交 Issue 和 Pull Request！

1. Fork 本仓库
2. 创建特性分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 开启 Pull Request

## 📄 开源协议

本项目采用 MIT 协议 - 查看 [LICENSE](LICENSE) 文件了解详情

## 👨‍💻 作者

**呆胶布**

- GitHub: [@你的用户名](https://github.com/你的用户名)

## 🙏 致谢

- [Moonshot AI](https://www.moonshot.cn/) - 提供强大的 Kimi AI 模型
- [Apple](https://developer.apple.com/) - SwiftUI 和 SwiftData 框架
- 所有贡献者和支持者

## 📮 联系方式

如有问题或建议，欢迎通过以下方式联系：

- 提交 [Issue](https://github.com/你的用户名/daidaichat/issues)
- 发送邮件至: your.email@example.com

---

<div align="center">

**如果这个项目对你有帮助，请给个 ⭐️ Star 支持一下！**

Made with ❤️ by 呆胶布

</div>

