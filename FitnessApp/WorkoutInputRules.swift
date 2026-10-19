import Foundation

enum WorkoutInputRules {
    static func positiveInteger(_ text: String) -> Int? {
        let value = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !value.isEmpty, value.allSatisfy({ "0123456789".contains($0) }),
              let number = Int(value), number > 0 else { return nil }
        return number
    }

    static func setCount(_ text: String) -> String? {
        if let count = positiveInteger(text) {
            return String(count)
        }
        return repRange(text)
    }

    static func repRange(_ text: String) -> String? {
        let normalized = text.replacingOccurrences(of: "–", with: "-")
            .replacingOccurrences(of: "—", with: "-")
        let parts = normalized.split(separator: "-", omittingEmptySubsequences: false)
        guard parts.count == 2,
              let lower = positiveInteger(String(parts[0])),
              let upper = positiveInteger(String(parts[1])),
              lower <= upper else { return nil }
        return "\(lower)–\(upper)"
    }

    // Capitalize word starts without lowercasing acronyms such as RDL.
    static func capitalizedWords(_ text: String) -> String {
        var startsWord = true
        var result = ""
        for character in text.trimmingCharacters(in: .whitespacesAndNewlines) {
            if character.isLetter {
                result += startsWord ? String(character).uppercased() : String(character)
                startsWord = false
            } else {
                result.append(character)
                if character.isWhitespace || "-/(".contains(character) {
                    startsWord = true
                }
            }
        }
        return result
    }
}
