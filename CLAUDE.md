# PathTime — CLAUDE.md

NJ PATH 实时到站时间应用，覆盖 iPhone App、iOS Widget、Apple Watch App 和 Watch Complication。

## 项目结构

```
PathTime.xcodeproj          由 project.yml + xcodegen 生成，勿手动编辑
PathTimeShared/             本地 Swift Package，iOS 和 watchOS 共用
PathTime/                   iOS App target (iOS 17+)
PathTimeWidget/             iOS Widget Extension (WidgetKit)
PathTimeWatch/              watchOS App target (watchOS 10+)
PathTimeWatchWidget/        watchOS Widget Extension（表盘 Complication）
scripts/test_api.swift      API 连通性验证脚本
SPEC.md                     需求与完成状态
```

## 添加新文件后必须重新生成项目

xcodegen 不自动感知新文件。每次新增 `.swift` 文件后：

```bash
xcodegen generate
```

## 数据源

```
GET https://www.panynj.gov/bin/portauthority/ridepath.json?timeStamp=<ms>
```

- 无需鉴权，客户端直接请求
- 返回全部 13 个 PATH 站台的实时班次
- 关键字段：`secondsToArrival`（字符串）、`lineColor`（hex，无 `#`）、`lastUpdated`（ISO8601）
- `PathAPIService.fetchArrivals()` 负责解析，返回 `[stationCode: [Direction: [TrainArrival]]]`

## 核心模型（PathTimeShared）

| 类型 | 说明 |
|------|------|
| `Station` | 13 个站台枚举，`rawValue` = API 中的 `consideredStation` 字段 |
| `Direction` | `.toNY` / `.toNJ`，对应 API 的 `"ToNY"` / `"ToNJ"` |
| `TrainArrival` | 单趟班次。`arrivalDate = fetchedAt + secondsToArrival`，用于 `Text(date, style:)` |
| `PinnedRoute` | 收藏的路线。`targetFilter == nil` 显示该方向所有终点，非 nil 只显示特定终点 |

## 关键服务（PathTimeShared）

**`PinnedRoutesStore`**（单例）
- 持久化到 App Groups UserDefaults（`group.com.pathtime.shared`）
- 在真机上 iOS App、Widget、Watch 三端共享同一容器
- 提供 `add/remove/toggle/move/delete/replaceAll`

**`ArrivalsStore`**（`@MainActor ObservableObject`）
- 每 30 秒（iOS）/ 60 秒（Watch）自动轮询 API
- `arrivals(for:)` 和 `arrivals(for route: PinnedRoute)` 两种查询方式

## 数据同步架构

```
iPhone App
  ├── PinnedRoutesStore (App Groups UserDefaults)  ──▶  iOS Widget (读)
  └── WatchSyncManager (WatchConnectivity)
        ├── sendMessage       当 Watch 在线时实时推送
        └── transferUserInfo  Watch 离线时队列发送

Watch App
  └── WatchConnectivityReceiver → PinnedRoutesStore.replaceAll()
```

> 模拟器中 App Groups 不跨 iOS/watchOS 共享，WatchConnectivity 是模拟器同步的唯一途径。

## Widget 刷新机制

- `TimelineProvider` 每次刷新请求 10 分钟后再次刷新，iOS 实际约 15–30 分钟执行一次
- **倒计时显示不依赖 Timeline 刷新**：用 `Text(train.arrivalDate, style: .timer/.relative)`，系统自动更新
- iPhone App 每次修改 Pin 后调用 `WidgetCenter.shared.reloadAllTimelines()`
- 所有 Widget 右下角显示 `Text(fetchedAt, style: .relative)`（"X 分钟前"）提示数据新鲜度

## Watch Complication

- 独立 target `PathTimeWatchWidget`，嵌套在 `PathTimeWatch` 内
- `StaticConfiguration`，自动显示 `PinnedRoutesStore.shared.routes.first`
- 支持 `.accessoryCorner / .accessoryCircular / .accessoryRectangular / .accessoryInline`

## 开发注意事项

**Bundle ID 前缀**：`com.pathtime`，需在 `project.yml` 中填入 `DEVELOPMENT_TEAM`

**App Groups ID**：`group.com.pathtime.shared`（已配置在所有 target 的 entitlements 中）

**WidgetKit 不能放在 PathTimeShared**：`WidgetCenter` 只在 iOS 可用，Watch target 也依赖 shared package。Widget reload 逻辑放在各自的 App target 中。

**新增站台**：在 `Station.swift` 枚举中添加 case，`rawValue` 必须与 API 的 `consideredStation` 字段完全一致。

## 工作流规范

- 每完成一个独立功能或修复后，主动提议并执行 commit，不等用户提醒
- Commit message 用英文，格式 `type: description`
- 多个不相关的改动拆分成多条 commit，按逻辑边界划分

## 常用命令

```bash
# 重新生成 Xcode 项目
xcodegen generate

# 验证 API 连通性
swift scripts/test_api.swift

# 查看 git 历史
git log --oneline
```
