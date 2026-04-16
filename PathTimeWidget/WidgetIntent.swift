import AppIntents
import WidgetKit
import PathTimeShared

// MARK: - Entity representing a PinnedRoute

struct PinnedRouteEntity: AppEntity, Hashable {
    var id: String           // PinnedRoute.id.uuidString
    var displayTitle: String
    var station: String
    var direction: String
    var targetFilter: String?

    static var typeDisplayRepresentation = TypeDisplayRepresentation(name: "路线")

    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: LocalizedStringResource(stringLiteral: displayTitle))
    }

    static var defaultQuery = PinnedRouteEntityQuery()
}

struct PinnedRouteEntityQuery: EntityQuery {
    func entities(for identifiers: [String]) async throws -> [PinnedRouteEntity] {
        PinnedRoutesStore.shared.routes
            .filter { identifiers.contains($0.id.uuidString) }
            .map { $0.toEntity() }
    }

    func suggestedEntities() async throws -> [PinnedRouteEntity] {
        PinnedRoutesStore.shared.routes.map { $0.toEntity() }
    }

    func defaultResult() async -> PinnedRouteEntity? {
        PinnedRoutesStore.shared.routes.first?.toEntity()
    }
}

extension PinnedRoute {
    func toEntity() -> PinnedRouteEntity {
        PinnedRouteEntity(
            id: id.uuidString,
            displayTitle: fullTitle,
            station: station.rawValue,
            direction: direction.rawValue,
            targetFilter: targetFilter
        )
    }
}

// MARK: - Widget Configuration Intent

struct SelectRouteIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "选择路线"
    static var description = IntentDescription("选择在小组件上显示的 PATH 路线")

    @Parameter(title: "路线")
    var route: PinnedRouteEntity?
}
