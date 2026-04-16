# PathTime — Product Spec

实时显示 NJ PATH 列车到站时间的 iPhone + Apple Watch 应用。

---

## 数据源

- **API**: `https://www.panynj.gov/bin/portauthority/ridepath.json?timeStamp=<ms>`
- 返回全部 13 个站台的实时班次（秒级到站时间、线路颜色、终点站）
- 无需鉴权，客户端直接请求

---

## 核心功能

### 1. iPhone App

| 功能 | 状态 |
|------|------|
| 所有站台实时到站时间列表 | ✅ |
| 站台详情页（按方向 + 终点分组） | ✅ |
| 搜索站台 | ✅ |
| 下拉刷新 | ✅ |
| 30 秒自动轮询 API | ✅ |

### 2. Pin 路线

| 功能 | 状态 |
|------|------|
| Pin 整个方向（如 JSQ → To NY，显示所有终点） | ✅ |
| Pin 具体终点（如 JSQ → WTC） | ✅ |
| 已收藏页查看全部 Pin | ✅ |
| 拖拽排序 Pin | ✅ |
| 左滑删除 Pin | ✅ |
| Pin 数据持久化（App Groups UserDefaults） | ✅ |

### 3. iOS Widget

| 功能 | 状态 |
|------|------|
| Small (2×2)：1条路线，大字显示下一班 | ✅ |
| Medium (4×2)：1条路线多班次 | ✅ |
| Large (4×4)：完整发车板 | ✅ |
| Lock Screen（锁屏组件） | ✅ |
| AppIntent 可配置显示哪条路线 | ✅ |
| Widget 倒计时精度（系统级自动秒更新） | ✅ `Text(arrivalDate, style: .timer/.relative)` |

### 4. Apple Watch App

| 功能 | 状态 |
|------|------|
| 收藏路线列表（显示下两班） | ✅ |
| 60 秒自动轮询 API | ✅ |
| 从 iPhone 同步 Pin（App Groups） | ✅ |
| Watch 端独立管理 Pin（增删） | ✅ 列表滑动删除；列表底部入口 → 选站台 → 选方向 → 添加 |

### 5. Watch Complication（表盘）

| 功能 | 状态 |
|------|------|
| `accessoryInline`：`JSQ 3 min` | ✅ |
| `accessoryCircular`：站名 + 彩色圆点 + 时间 | ✅ |
| `accessoryRectangular`：路线 + 下两班 | ✅ |
| `accessoryCorner`：彩色圆 + 角落标签 | ✅ |
| 表盘显示第一条收藏路线 | ✅ |
| 表盘可选择显示哪条路线 | ❌ 固定显示第一条 |

---

## 待完成

| 项目 | 优先级 | 说明 |
|------|--------|------|
| ~~Widget 倒计时精度~~ | ~~高~~ | ✅ 已完成 |
| Watch Complication 可选路线 | 中 | 用 AppIntent 让用户选择表盘显示哪条路线 |
| App Icon | 中 | 目前使用默认图标 |
| ~~Watch 端独立管理 Pin~~ | ~~低~~ | ✅ 已完成 |
| Background App Refresh | 低 | 后台定期预热数据，打开 App 时更快显示 |

---

## 技术架构

```
PathTime.xcodeproj
├── PathTimeShared/          本地 Swift Package（iOS + watchOS 共用）
│   ├── Models:              Station, TrainArrival, PinnedRoute
│   ├── Services:            PathAPIService, PinnedRoutesStore
│   └── ViewModels:          ArrivalsStore
├── PathTime/                iOS App (iOS 17+)
├── PathTimeWidget/          Widget Extension (WidgetKit, iOS)
├── PathTimeWatch/           Watch App (watchOS 10+)
└── PathTimeWatchWidget/     Watch Widget Extension（表盘 Complication）
```

**数据共享**：App Groups (`group.com.pathtime.shared`) 在 App / Widget / Watch 之间共享 Pin 数据。
