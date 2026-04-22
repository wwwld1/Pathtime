# PathTime — 测试进度

## 运行测试

```bash
xcodebuild test \
  -scheme PathTime \
  -destination 'platform=iOS Simulator,name=iPhone 16'
```

> 注意：不能用 `swift test` 命令行运行，因为 `TrainArrival` 依赖 SwiftUI `Color`，macOS 命令行环境无法编译。

---

## 测试文件

| 文件 | 覆盖范围 | 状态 |
|------|---------|------|
| `TrainArrivalTests.swift` | `remainingSeconds`, `displayTime`, `arrivalDate`, `remainingMinutes` | ✅ 完成 |
| `StationTests.swift` | 枚举 rawValue、`isNJSide`、Codable、数量 | ✅ 完成 |
| `ColorHexTests.swift` | 合法/非法 hex 解析，已知 bug 文档化 | ✅ 完成 |
| `PinnedRouteTests.swift` | `displayTitle`、`fullTitle`、Equatable、Codable，已知 bug 文档化 | ✅ 完成 |
| `PinnedRoutesStoreTests.swift` | CRUD、去重、持久化、排序 | ✅ 完成 |
| `PathAPIServiceTests.swift` | JSON 解析、过滤、排序、网络错误 | ✅ 完成 |

---

## 已知 Bug（用测试文档化，暂不修复）

| Bug | 文件 | 测试方法 |
|-----|------|---------|
| `Color(hex:)` 对无效十六进制字符（如 `"GG5733"`）返回黑色而不是 `nil`，因为 Scanner 失败时 `rgb=0` | `ColorHexTests` | `test_invalidHexChars_KNOWN_ISSUE_returnsBlackInsteadOfNil` |
| `PinnedRoute` 的 `hash` 基于 `id`，但 `==` 基于内容，违反 Hashable 契约，导致 `Set` 无法正确去重 | `PinnedRouteTests` | `test_hashable_inconsistency_KNOWN_ISSUE` |

---

## Fixtures

```
PathTimeShared/Tests/PathTimeSharedTests/Fixtures/
├── ridepath_normal.json           正常响应（2 站台，含故意乱序的班次）
├── ridepath_invalid_secs.json     secondsToArrival 为 "abc" 的非法值
├── ridepath_unknown_direction.json direction label 为 "ToMars"
└── ridepath_empty.json            空 results 数组
```
