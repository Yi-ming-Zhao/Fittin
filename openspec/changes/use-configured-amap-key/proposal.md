## Why

用户已经提供个人高德 Web 服务 Key，希望打开地图即可使用，不再每次输入。客户端内置 Web 服务 Key 会使公开安装包暴露配额凭证。

## What Changes

- 移除地图 Key 输入，改为登录后通过受限后端加载地图。
- Key 仅在部署环境中配置，原文件忽略提交并限制本机权限。
- 保留逐次启用确认，明确单点经 Fittin 转发给高德；后端不保存坐标或图片。
- 限制请求、响应、速率、并发和超时，仅访问固定高德 API。

## Capabilities

### New Capabilities

- `configured-map-relay`: 登录保护的个人高德地图转发与凭证配置。

### Modified Capabilities

- `live-cardio-recording`: 地图免填 Key，更新位置分享说明，保持离线记录独立。

## Impact

Flutter 地图服务/组件与测试，Go 配置/路由/受限地图代理，部署环境与发布配置。无数据库迁移，不改变路线同步边界。
