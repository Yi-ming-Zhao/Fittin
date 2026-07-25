# Fittin v1.0.12

本版本修复登录服务异常时显示底层解析错误的问题，并提升弱网与网关故障下的提示质量。

## 登录与可靠性

- 登录服务返回 502、503、HTML 错误页或其他临时网关响应时，不再显示 `Bad state` 或 JSON 解析异常。
- 临时服务故障会显示简洁、可重试的提示，并明确本地训练数据仍然安全。
- 账号密码错误时仍保留后端返回的准确提示，不会与临时网络故障混淆。
- 修正 `StateError` 的展示逻辑，避免把 Dart 内部错误前缀暴露给用户。

## Android 更新

- 已安装 v1.0.6 或更高版本的用户可以直接覆盖安装 v1.0.12，训练数据、主题与设置会保留。
- v1.0.12 继续使用稳定签名，Android versionCode 为 19。

---

This release fixes low-level parsing errors during authentication outages and improves weak-network and gateway-failure messaging.

## Authentication and reliability

- Temporary 502/503 responses, HTML gateway pages, and other transient authentication failures no longer expose `Bad state` or JSON parsing errors.
- Service outages show a concise retryable message and clarify that local training data remains safe.
- Invalid credentials continue to use the backend's precise error response instead of being confused with a temporary outage.
- `StateError` messages are unwrapped before presentation so Dart implementation details are not shown to users.

## Android update

- Users on v1.0.6 or later can install v1.0.12 directly over the existing app while retaining training data, themes, and settings.
- v1.0.12 continues to use the stable signer and Android versionCode 19.
