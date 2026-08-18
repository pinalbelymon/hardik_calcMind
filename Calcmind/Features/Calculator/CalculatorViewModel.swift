import SwiftUI
import Observation

/// All calculator state lives here. Views only ever call `tap...()` methods
/// and read the display/mode properties — no view touches `CalcToken` or
/// `ExpressionEngine` directly.
@Observable
final class CalculatorViewModel {
    private(set) var tokens: [CalcToken] = []
    private(set) var currentInput: String = ""

    var resultText: String = "0"
    var errorMessage: String?
    var isScientificMode: Bool = false
    var angleUnit: AngleUnit = .degrees
    var memoryValue: Double = 0
    /// Bump this to trigger the display's shake animation on invalid input.
    var shakeTrigger: Int = 0

    private var openParenCount = 0
    private var hasResult = false

    /// Called after every successful `=` with the expression and result
    /// text, so a view can persist it to history without this view model
    /// needing to know anything about SwiftData or a ModelContext.
    var onCalculationCompleted: ((_ expression: String, _ result: String) -> Void)?

    // MARK: - Display

    /// The small trailing line showing the full expression so far.
    var smallDisplay: String {
        var parts = tokens.map(displaySymbol)
        if !currentInput.isEmpty { parts.append(currentInput) }
        return parts.isEmpty ? " " : parts.joined()
    }

    /// The large primary number.
    var bigDisplay: String {
        if hasResult { return resultText }
        if !currentInput.isEmpty { return currentInput }
        if let preview = livePreviewValue { return DisplayFormatter.format(preview) }
        if case .number(let v)? = tokens.last, tokens.count == 1 {
            return DisplayFormatter.format(v)
        }
        return "0"
    }

    private var livePreviewValue: Double? {
        guard !tokens.isEmpty, !hasResult else { return nil }
        return try? ExpressionEngine.evaluate(tokens, angleUnit: angleUnit)
    }

    // MARK: - Digit / Decimal Input

    func tapDigit(_ digit: String) {
        if hasResult { reset(keepMemory: true) }
        errorMessage = nil

        if digit == "." {
            guard !currentInput.contains(".") else { return }
            currentInput += currentInput.isEmpty ? "0." : "."
        } else if currentInput == "0" {
            currentInput = digit
        } else {
            currentInput += digit
        }
    }

    // MARK: - Operators

    func tapOperator(_ op: BinaryOperator) {
        flushCurrentInput()
        if case .binaryOperator? = tokens.last {
            tokens.removeLast()
        }
        guard !tokens.isEmpty else { return }
        tokens.append(.binaryOperator(op))
        hasResult = false
    }

    func tapFunction(_ fn: MathFunction) {
        if hasResult { reset(keepMemory: true) }
        flushCurrentInput()
        tokens.append(.function(fn))
        tokens.append(.leftParen)
        openParenCount += 1
    }

    func tapConstant(_ constant: MathConstant) {
        if hasResult { reset(keepMemory: true) }
        flushCurrentInput()
        tokens.append(.constant(constant))
    }

    func tapPostfix(_ post: PostfixOperator) {
        flushCurrentInput()
        guard !tokens.isEmpty else { return }
        tokens.append(.postfix(post))
    }

    func tapPercent() { tapPostfix(.percent) }

    func tapParen() {
        flushCurrentInput()
        if openParenCount > 0, canCloseParen {
            tokens.append(.rightParen)
            openParenCount -= 1
        } else {
            tokens.append(.leftParen)
            openParenCount += 1
        }
    }

    private var canCloseParen: Bool {
        switch tokens.last {
        case .number, .rightParen, .postfix, .constant: return true
        default: return false
        }
    }

    func tapPlusMinus() {
        if !currentInput.isEmpty, let value = Double(currentInput) {
            currentInput = DisplayFormatter.format(-value)
        } else if case .number(let value)? = tokens.last {
            tokens[tokens.count - 1] = .number(-value)
        }
    }

    // MARK: - Equals / Clear / Backspace

    func tapEquals() {
        flushCurrentInput()
        guard !tokens.isEmpty else { return }
        do {
            let result = try ExpressionEngine.evaluate(tokens, angleUnit: angleUnit)
            // Capture the expression text before tokens gets collapsed to
            // just the result below — smallDisplay reads from tokens.
            let expressionText = smallDisplay
            let resultString = DisplayFormatter.format(result)
            resultText = resultString
            tokens = [.number(result)]
            openParenCount = 0
            hasResult = true
            onCalculationCompleted?(expressionText, resultString)
        } catch {
            handleError()
        }
    }

    func tapClear() { reset(keepMemory: true) }
    func tapAllClear() { reset(keepMemory: false) }

    func tapBackspace() {
        errorMessage = nil
        if !currentInput.isEmpty {
            currentInput.removeLast()
            return
        }
        guard let last = tokens.last else { return }
        if case .leftParen = last { openParenCount -= 1 }
        if case .rightParen = last { openParenCount += 1 }
        tokens.removeLast()
    }

    // MARK: - Memory

    func memoryClear() { memoryValue = 0 }

    func memoryRecall() {
        reset(keepMemory: true)
        currentInput = DisplayFormatter.format(memoryValue)
    }

    func memoryAdd() { memoryValue += currentEvaluatedValue ?? 0 }
    func memorySubtract() { memoryValue -= currentEvaluatedValue ?? 0 }

    private var currentEvaluatedValue: Double? {
        var working = tokens
        if !currentInput.isEmpty, let v = Double(currentInput) { working.append(.number(v)) }
        return try? ExpressionEngine.evaluate(working, angleUnit: angleUnit)
    }

    // MARK: - Private

    private func flushCurrentInput() {
        guard !currentInput.isEmpty else { return }
        if let value = Double(currentInput) {
            tokens.append(.number(value))
        }
        currentInput = ""
    }

    private func handleError() {
        errorMessage = "Error"
        resultText = "Error"
        shakeTrigger += 1
        Haptic.error()
    }

    private func reset(keepMemory: Bool) {
        tokens = []
        currentInput = ""
        resultText = "0"
        errorMessage = nil
        openParenCount = 0
        hasResult = false
        if !keepMemory { memoryValue = 0 }
    }

    private func displaySymbol(_ token: CalcToken) -> String {
        switch token {
        case .number(let v): return DisplayFormatter.format(v)
        case .binaryOperator(let op): return " \(op.rawValue) "
        case .function(let fn): return fn.displaySymbol
        case .postfix(let post): return post.rawValue
        case .constant(let c): return c.rawValue
        case .leftParen: return "("
        case .rightParen: return ")"
        }
    }
}
