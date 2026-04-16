import WidgetKit
import SwiftUI
import PathTimeShared

@main
struct PathTimeWatchWidgetBundle: WidgetBundle {
    var body: some Widget {
        PathTimeWatchComplication()
    }
}

struct PathTimeWatchComplication: Widget {
    let kind = "PathTimeWatchComplication"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: WatchTimelineProvider()) { entry in
            WatchComplicationEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("PATH 到站")
        .description("显示第一条收藏路线的下一班到站时间")
        .supportedFamilies([
            .accessoryCorner,
            .accessoryCircular,
            .accessoryRectangular,
            .accessoryInline
        ])
    }
}
