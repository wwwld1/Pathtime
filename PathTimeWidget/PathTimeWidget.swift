import WidgetKit
import SwiftUI
import AppIntents
import PathTimeShared

// MARK: - Widget Bundle

@main
struct PathTimeWidgetBundle: WidgetBundle {
    var body: some Widget {
        PathTimeSingleWidget()
    }
}

// MARK: - Single configurable widget (supports all sizes + lock screen)

struct PathTimeSingleWidget: Widget {
    let kind = "PathTimeSingleWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(
            kind: kind,
            intent: SelectRouteIntent.self,
            provider: PathTimeProvider()
        ) { entry in
            PathTimeWidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("PATH 到站时间")
        .description("显示选定路线的下一班车时间")
        .supportedFamilies([
            .systemSmall,
            .systemMedium,
            .systemLarge,
            .accessoryInline,
            .accessoryCircular,
            .accessoryRectangular
        ])
    }
}
