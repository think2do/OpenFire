# 呆呆聊天 - 功能更新说明

## 新增功能

### 1. 首次启动配置页面
应用首次启动时，会显示配置页面，要求用户输入：
- **API Key**: 从你的 API 提供商处获取的密钥
- **Base URL**: API 服务的基础 URL（例如：`https://api.openai.com/v1` 或 `https://api.moonshot.cn/v1`）

配置完成后，设置会自动保存到 UserDefaults。

### 2. 模型列表获取与选择
- 应用会自动从配置的 Base URL 获取可用的模型列表
- 在聊天页面顶部，点击当前模型名称可以切换模型
- 支持任何兼容 OpenAI API 格式的服务

### 3. 设置页面
在聊天页面点击右上角的齿轮图标可以打开设置页面：
- 修改 API Key 和 Base URL
- 刷新模型列表
- 查看当前选中的模型
- 重置所有设置

## 技术实现

### 新增文件：
1. **APISettings.swift**: 单例类，管理 API 配置（API Key、Base URL、选中的模型）
2. **SetupView.swift**: 首次配置界面
3. **SettingsView.swift**: 设置管理界面

### 修改文件：
1. **ContentView.swift**: 添加配置状态检查，未配置时显示设置页面
2. **ChatView.swift**: 添加模型选择器和设置按钮
3. **KimiAPIService.swift**: 
   - 使用动态配置替代硬编码的 API Key 和 URL
   - 添加 `fetchModels()` 方法获取模型列表
   - 支持用户选择的模型

## 使用示例

### 配置 OpenAI
- API Key: `sk-xxx...`
- Base URL: `https://api.openai.com/v1`

### 配置 Moonshot AI (Kimi)
- API Key: `sk-xxx...`
- Base URL: `https://api.moonshot.cn/v1`

### 配置其他兼容服务
只要服务提供商兼容 OpenAI 的 API 格式（`/v1/chat/completions` 和 `/v1/models`），就可以使用。

## 数据持久化
所有设置通过 `UserDefaults` 持久化存储：
- `apiKey`: API 密钥
- `baseURL`: 基础 URL
- `selectedModel`: 当前选中的模型

## 安全提示
⚠️ API Key 目前存储在 UserDefaults 中。在生产环境中，建议使用 Keychain 来存储敏感信息。
