import WidgetKit
import SwiftUI
import PathTimeShared

// MARK: - Entry View (routes to the right size)

struct PathTimeWidgetEntryView: View {
    @Environment(\.widgetFamily) var family
    let entry: PathTimeEntry

    var body: some View {
        switch family {
        case .systemSmall:      SmallWidgetView(entry: entry)
        case .systemMedium:     MediumWidgetView(entry: entry)
        case .systemLarge:      LargeWidgetView(entry: entry)
        case .accessoryInline:  accessoryInlineView
        case .accessoryCircular: accessoryCircularView
        case .accessoryRectangular: accessoryRectangularView
        default:                SmallWidgetView(entry: entry)
        }
    }

    // MARK: - Lock Screen

    private var accessoryInlineView: some View {
        let title = entry.route?.displayTitle ?? "PATH"
        if let first = entry.arrivals.first {
            return Text("\(title) ") + Text(first.arrivalDate, style: .relative)
        }
        return Text("\(title) --")
    }

    private var accessoryCircularView: some View {
        VStack(spacing: 1) {
            Text(entry.route?.station.shortName ?? "PATH")
                .font(.caption2).fontWeight(.semibold)
            if let first = entry.arrivals.first {
                Text(first.arrivalDate, style: .timer)
                    .font(.title3).fontWeight(.bold).monospacedDigit()
            } else {
                Text("--").font(.title3).fontWeight(.bold)
            }
        }
    }

    private var accessoryRectangularView: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(entry.route?.displayTitle ?? "PATH")
                .font(.caption2).foregroundStyle(.secondary)
            HStack(spacing: 8) {
                ForEach(entry.arrivals.prefix(2)) { train in
                    HStack(spacing: 3) {
                        Circle().fill(train.lineColor).frame(width: 7, height: 7)
                        Text(train.arrivalDate, style: .timer)
                            .font(.caption).fontWeight(.semibold).monospacedDigit()
                    }
                }
            }
        }
    }
}

// MARK: - Small (2×2)

struct SmallWidgetView: View {
    let entry: PathTimeEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(entry.route?.displayTitle ?? "PATH")
                .font(.caption).foregroundStyle(.secondary).lineLimit(1)

            if let first = entry.arrivals.first {
                HStack(spacing: 5) {
                    Circle().fill(first.lineColor).frame(width: 10, height: 10)
                    // .timer shows "2:47" counting down — updates every second automatically
                    Text(first.arrivalDate, style: .timer)
                        .font(.title).fontWeight(.bold).monospacedDigit()
                }
                Text(first.headSign)
                    .font(.caption2).foregroundStyle(.secondary).lineLimit(1)
            }

            if let second = entry.arrivals.dropFirst().first {
                HStack(spacing: 5) {
                    Circle().fill(second.lineColor).frame(width: 8, height: 8)
                    Text(second.arrivalDate, style: .relative)
                        .font(.subheadline).fontWeight(.semibold).monospacedDigit()
                        .foregroundStyle(.secondary)
                }
            }

            Spacer(minLength: 0)
        }
        .padding(12)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
}

// MARK: - Medium (4×2)

struct MediumWidgetView: View {
    let entry: PathTimeEntry

    var body: some View {
        HStack(spacing: 0) {
            routeColumn(arrivals: Array(entry.arrivals), title: entry.route?.displayTitle ?? "PATH")
            Divider().padding(.vertical, 8)
            routeColumn(arrivals: [], title: "")
        }
        .padding(12)
    }

    @ViewBuilder
    private func routeColumn(arrivals: [TrainArrival], title: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title).font(.caption2).foregroundStyle(.secondary).lineLimit(1)
            ForEach(arrivals.prefix(3)) { train in
                HStack(spacing: 4) {
                    Circle().fill(train.lineColor).frame(width: 8, height: 8)
                    Text(train.headSign).font(.caption2).lineLimit(1).foregroundStyle(.secondary)
                    Spacer()
                    Text(train.arrivalDate, style: .relative)
                        .font(.caption).fontWeight(.bold).monospacedDigit()
                }
            }
            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Large (4×4)

struct LargeWidgetView: View {
    let entry: PathTimeEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(entry.route?.fullTitle ?? "PATH 到站时间").font(.headline)
                Spacer()
                Text(entry.fetchedAt, style: .time).font(.caption2).foregroundStyle(.tertiary)
            }

            Divider()

            if entry.arrivals.isEmpty {
                Text("暂无数据").foregroundStyle(.secondary).font(.caption)
            } else {
                ForEach(entry.arrivals.prefix(6)) { train in
                    HStack {
                        Circle().fill(train.lineColor).frame(width: 10, height: 10)
                        Text(train.headSign).font(.subheadline)
                        Spacer()
                        Text(train.arrivalDate, style: .relative)
                            .font(.subheadline).fontWeight(.bold).monospacedDigit()
                    }
                }
            }
            Spacer(minLength: 0)
        }
        .padding(14)
    }
}
