import Foundation
import Testing
@testable import FitnessApp

struct CardioInputRulesTests {
    @Test func durationBoundaries() {
        #expect(CardioInputRules.durationSeconds(hours: 1, minutes: 2, seconds: 3) == 3723)
        #expect(CardioInputRules.durationSeconds(hours: 0, minutes: 0, seconds: 1) == 1)
        #expect(CardioInputRules.durationSeconds(hours: 0, minutes: 0, seconds: 0) == nil)
        #expect(CardioInputRules.durationSeconds(hours: -1, minutes: 0, seconds: 0) == nil)
        #expect(CardioInputRules.durationSeconds(hours: 23, minutes: 59, seconds: 59) == 86399)
        #expect(CardioInputRules.durationSeconds(hours: 24, minutes: 0, seconds: 0) == nil)
        #expect(CardioInputRules.durationSeconds(hours: 0, minutes: 60, seconds: 0) == nil)
        #expect(CardioInputRules.durationSeconds(hours: 0, minutes: 0, seconds: 60) == nil)
    }

    @Test func distanceValidation() {
        let locale = Locale(identifier: "en_US")
        #expect(CardioInputRules.distanceMiles(" ", locale: locale) == 0)
        #expect(CardioInputRules.distanceMiles(" 2.5 ", locale: locale) == 2.5)
        #expect(CardioInputRules.distanceMiles("2,5", locale: Locale(identifier: "fr_FR")) == 2.5)
        for input in ["-1", "0", "nan", "inf", "1e3", "1.2.3", "two", "1,000"] {
            #expect(CardioInputRules.distanceMiles(input, locale: locale) == nil)
        }
    }

    @Test func activityValidation() {
        #expect(CardioInputRules.activityName(.indoorWalk, customName: "") == "Indoor walk")
        #expect(CardioInputRules.activityName(.other, customName: " Dance ") == "Dance")
        for input in ["", "   ", "123", "Walk\nRun", String(repeating: "a", count: 61)] {
            #expect(CardioInputRules.activityName(.other, customName: input) == nil)
        }
    }
}
