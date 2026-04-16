import Foundation

public enum Station: String, CaseIterable, Codable, Hashable, Sendable {
    case NWK
    case HAR
    case JSQ
    case GRV
    case NEW
    case EXP
    case HOB
    case WTC
    case CHR
    case nineS     = "09S"
    case fourteenS = "14S"
    case twentyThreeS = "23S"
    case thirtyThreeS = "33S"

    public var displayName: String {
        switch self {
        case .NWK: return "Newark"
        case .HAR: return "Harrison"
        case .JSQ: return "Journal Square"
        case .GRV: return "Grove Street"
        case .NEW: return "Newport"
        case .EXP: return "Exchange Place"
        case .HOB: return "Hoboken"
        case .WTC: return "World Trade Center"
        case .CHR: return "Christopher St"
        case .nineS: return "9th Street"
        case .fourteenS: return "14th Street"
        case .twentyThreeS: return "23rd Street"
        case .thirtyThreeS: return "33rd Street"
        }
    }

    public var shortName: String {
        switch self {
        case .NWK: return "NWK"
        case .HAR: return "HAR"
        case .JSQ: return "JSQ"
        case .GRV: return "GRV"
        case .NEW: return "NEW"
        case .EXP: return "EXP"
        case .HOB: return "HOB"
        case .WTC: return "WTC"
        case .CHR: return "CHR"
        case .nineS: return "9 St"
        case .fourteenS: return "14 St"
        case .twentyThreeS: return "23 St"
        case .thirtyThreeS: return "33 St"
        }
    }

    /// NJ-side stations (west of Hudson)
    public var isNJSide: Bool {
        switch self {
        case .NWK, .HAR, .JSQ, .GRV, .NEW, .EXP, .HOB: return true
        default: return false
        }
    }
}

public enum Direction: String, Codable, Hashable, CaseIterable, Sendable {
    case toNY = "ToNY"
    case toNJ = "ToNJ"

    public var displayName: String {
        switch self {
        case .toNY: return "To NY"
        case .toNJ: return "To NJ"
        }
    }

    public var shortName: String {
        switch self {
        case .toNY: return "→NY"
        case .toNJ: return "→NJ"
        }
    }
}
