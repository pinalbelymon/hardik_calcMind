import Foundation

// MARK: - Errors

enum CalcError: Error, Equatable {
    case divisionByZero
    case domainError     // e.g. sqrt of a negative number, asin(2)
    case syntaxError      // malformed token stream
    case overflow          // result isn't finite
}

// MARK: - Angle Unit

enum AngleUnit: String, CaseIterable, Equatable {
    case degrees, radians

    var displayLabel: String { self == .degrees ? "DEG" : "RAD" }
}

// MARK: - Binary Operators

enum BinaryOperator: String, CaseIterable, Equatable {
    case add = "+"
    case subtract = "−"
    case multiply = "×"
    case divide = "÷"
    case power = "^"

    var precedence: Int {
        switch self {
        case .add, .subtract: return 1
        case .multiply, .divide: return 2
        case .power: return 3
        }
    }

    var isRightAssociative: Bool { self == .power }

    func apply(_ lhs: Double, _ rhs: Double) throws -> Double {
        switch self {
        case .add: return lhs + rhs
        case .subtract: return lhs - rhs
        case .multiply: return lhs * rhs
        case .divide:
            guard rhs != 0 else { throw CalcError.divisionByZero }
            return lhs / rhs
        case .power:
            return pow(lhs, rhs)
        }
    }
}

// MARK: - Prefix (Unary) Functions

enum MathFunction: String, CaseIterable, Equatable {
    case sin, cos, tan
    case asin, acos, atan
    case sinh, cosh, tanh
    case ln, log
    case sqrt, cbrt
    case reciprocal   // 1/x

    var displaySymbol: String {
        switch self {
        case .sin: return "sin"
        case .cos: return "cos"
        case .tan: return "tan"
        case .asin: return "sin⁻¹"
        case .acos: return "cos⁻¹"
        case .atan: return "tan⁻¹"
        case .sinh: return "sinh"
        case .cosh: return "cosh"
        case .tanh: return "tanh"
        case .ln: return "ln"
        case .log: return "log"
        case .sqrt: return "√"
        case .cbrt: return "∛"
        case .reciprocal: return "1/"
        }
    }

    func apply(_ x: Double, angleUnit: AngleUnit) throws -> Double {
        let toRadians: (Double) -> Double = { angleUnit == .degrees ? $0 * .pi / 180 : $0 }
        let fromRadians: (Double) -> Double = { angleUnit == .degrees ? $0 * 180 / .pi : $0 }

        switch self {
        case .sin: return Foundation.sin(toRadians(x))
        case .cos: return Foundation.cos(toRadians(x))
        case .tan: return Foundation.tan(toRadians(x))
        case .asin:
            guard x >= -1, x <= 1 else { throw CalcError.domainError }
            return fromRadians(Foundation.asin(x))
        case .acos:
            guard x >= -1, x <= 1 else { throw CalcError.domainError }
            return fromRadians(Foundation.acos(x))
        case .atan:
            return fromRadians(Foundation.atan(x))
        case .sinh: return Foundation.sinh(x)
        case .cosh: return Foundation.cosh(x)
        case .tanh: return Foundation.tanh(x)
        case .ln:
            guard x > 0 else { throw CalcError.domainError }
            return Foundation.log(x)
        case .log:
            guard x > 0 else { throw CalcError.domainError }
            return Foundation.log10(x)
        case .sqrt:
            guard x >= 0 else { throw CalcError.domainError }
            return Foundation.sqrt(x)
        case .cbrt:
            return Foundation.cbrt(x)
        case .reciprocal:
            guard x != 0 else { throw CalcError.divisionByZero }
            return 1 / x
        }
    }
}

// MARK: - Postfix (Unary) Operators

enum PostfixOperator: String, CaseIterable, Equatable {
    case percent = "%"
    case factorial = "!"
    case square = "²"
    case cube = "³"

    func apply(_ x: Double) throws -> Double {
        switch self {
        case .percent:
            return x / 100
        case .factorial:
            guard x >= 0, x == x.rounded(), x <= 170 else { throw CalcError.domainError }
            let n = max(Int(x), 1)
            return (1...n).reduce(1.0) { $0 * Double($1) }
        case .square:
            return x * x
        case .cube:
            return x * x * x
        }
    }
}

// MARK: - Constants

enum MathConstant: String, CaseIterable, Equatable {
    case pi = "π"
    case e = "e"

    var value: Double {
        switch self {
        case .pi: return Double.pi
        case .e: return M_E
        }
    }
}

// MARK: - Token Stream
// The calculator UI never parses free text — every button tap appends a
// structured token directly, so the grammar is controlled at the source
// and the engine below never has to guess intent from a string.

enum CalcToken: Equatable {
    case number(Double)
    case binaryOperator(BinaryOperator)
    case function(MathFunction)
    case postfix(PostfixOperator)
    case constant(MathConstant)
    case leftParen
    case rightParen
}
