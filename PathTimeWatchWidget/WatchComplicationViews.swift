import WidgetKit
import SwiftUI
import PathTimeShared

struct WatchComplicationEntryView: View {
    @Environment(\.widgetFamily) var family
    let entry: WatchComplicationEntry

    var body: some View {
        switch family {
        case .accessoryCorner:      cornerView
        case .accessoryCircular:    circularView
        case .accessoryRectangular: rectangularView
        case .accessoryInline:      inlineView
        default:                    circularView
        }
    }

    // ── Inline: "JSQ 3 min" ─────────────────────────────────────────────────
    private var inlineView: some View {
        let station = entry.route?.station.shortName ?? "PATH"
        let time = entry.nextArrival.map { $0.displayTime() } ?? "--"
        return Text("\(station) \(time)")
    }

    // ── Corner: colored dot + label ─────────────────────────────────────────
    private var cornerView: some View {
        ZStack {
            if let arrival = entry.nextArrival {
                Circle().fill(arrival.lineColor)
            } else {
                Circle().fill(.secondary)
            }
        }
        .widgetLabel {
            Text(entry.nextArrival.map { $0.arrivalDate } ?? .distantFuture, style: .timer)
                .font(.system(.body, design: .rounded, weight: .bold))
        }
    }

    // ── Circular: station + next time ───────────────────────────────────────
    private var circularView: some View {
        VStack(spacing: 1) {
            Text(entry.route?.station.shortName ?? "PATH")
                .font(.system(size: 11, weight: .semibold))
                .minimumScaleFactor(0.8)
            if let arrival = entry.nextArrival {
                HStack(spacing: 2) {
                    Circle().fill(arrival.lineColor).frame(width: 6, height: 6)
                    Text(arrival.arrivalDate, style: .timer)
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                        .monospacedDigit()
                }
            } else {
                Text("--").font(.system(size: 15, weight: .bold))
            }
        }
    }

    // ── Rectangular: route title + next 2 arrivals ──────────────────────────
    private var rectangularView: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(entry.route?.displayTitle ?? "PATH")
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(.secondary)
                .lineLimit(1)

            HStack(spacing: 10) {
                arrivalBadge(entry.nextArrival, emphasis: true)
                arrivalBadge(entry.secondArrival, emphasis: false)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    @ViewBuilder
    private func arrivalBadge(_ arrival: TrainArrival?, emphasis: Bool) -> some View {
        if let arrival {
            HStack(spacing: 3) {
                Circle().fill(arrival.lineColor).frame(width: 7, height: 7)
                Text(arrival.arrivalDate, style: .timer)
                    .font(.system(
                        size: emphasis ? 15 : 13,
                        weight: emphasis ? .bold : .medium,
                        design: .rounded
                    ))
                    .monospacedDigit()
                    .foregroundStyle(emphasis ? .primary : .secondary)
            }
        }
    }
}
