import Foundation
import SwiftData

@Model
final class CalculationRecord {
    var expression: String
    var result: String
    var isAISolved: Bool
    var date: Date

    init(expression: String, result: String, isAISolved: Bool = false, date: Date = .now) {
        self.expression = expression
        self.result = result
        self.isAISolved = isAISolved
        self.date = date
    }
}
