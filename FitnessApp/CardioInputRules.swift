import Foundation

enum CardioActivity: String, CaseIterable, Identifiable {
    case walk = "Walk"
    case indoorWalk = "Indoor walk"
    case run = "Run"
    case indoorRun = "Indoor run"
    case cycling = "Cycling"
    case indoorCycling = "Indoor cycling"
    case hiking = "Hiking"
    case swimming = "Swimming"
    case rowing = "Rowing"
    case elliptical = "Elliptical"
    case stairClimber = "Stair climber"
    case other = "Other"

    var id: String { rawValue }
}

enum CardioInputRules {
    static func durationSeconds(hours: Int, minutes: Int, seconds: Int) -> Int? {
        guard (0...23).contains(hours), (0...59).contains(minutes),
              (0...59).contains(seconds) else { return nil }
        let total = hours * 3600 + minutes * 60 + seconds
        return total > 0 ? total : nil
    }

    // Zero represents an unrecorded distance; entered distances must be positive.
    static func distanceMiles(_ text: String, locale: Locale = .current) -> Double? {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty { return 0 }
        let separator = locale.decimalSeparator ?? "."
        let normalized = trimmed.replacingOccurrences(of: separator, with: ".")
        guard normalized.allSatisfy({ "0123456789.".contains($0) }),
              normalized.filter({ $0 == "." }).count <= 1,
              let value = Double(normalized), value.isFinite, value > 0 else { return nil }
        return value
    }

    static func activityName(_ activity: CardioActivity, customName: String) -> String? {
        guard activity == .other else { return activity.rawValue }
        let name = customName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard (1...60).contains(name.count), name.contains(where: { $0.isLetter }),
              !name.unicodeScalars.contains(where: { CharacterSet.controlCharacters.contains($0) })
        else { return nil }
        return name
    }
}
