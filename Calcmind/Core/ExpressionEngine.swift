import Foundation

/// Converts a `[CalcToken]` stream into RPN (shunting-yard algorithm) and
/// evaluates it. Functions are treated as high-precedence prefix operators
/// that resolve against their matching parenthesis group; postfix operators
/// (%, !, x², x³) apply immediately to whatever precedes them.
enum ExpressionEngine {

    static func evaluate(_ tokens: [CalcToken], angleUnit: AngleUnit) throws -> Double {
        let rpn = try toRPN(tokens)
        let result = try evaluateRPN(rpn, angleUnit: angleUnit)
        guard result.isFinite else { throw CalcError.overflow }
        return result
    }

    // MARK: - RPN item (post-shunting-yard, only real math operations remain)

    private enum RPNItem {
        case number(Double)
        case binaryOperator(BinaryOperator)
        case function(MathFunction)
    }

    // MARK: - Shunting Yard

    private static func toRPN(_ tokens: [CalcToken]) throws -> [RPNItem] {
        var output: [RPNItem] = []
        var opStack: [CalcToken] = []

        for token in tokens {
            switch token {
            case .number(let value):
                output.append(.number(value))

            case .constant(let constant):
                output.append(.number(constant.value))

            case .function:
                opStack.append(token)

            case .postfix(let post):
                guard case .number(let last)? = output.popLast() else {
                    throw CalcError.syntaxError
                }
                output.append(.number(try post.apply(last)))

            case .binaryOperator(let incoming):
                while let top = opStack.last, shouldPop(top, over: incoming) {
                    opStack.removeLast()
                    try flush(top, into: &output)
                }
                opStack.append(token)

            case .leftParen:
                opStack.append(token)

            case .rightParen:
                while let top = opStack.last {
                    if case .leftParen = top { break }
                    opStack.removeLast()
                    try flush(top, into: &output)
                }
                guard let openParen = opStack.popLast(), case .leftParen = openParen else {
                    throw CalcError.syntaxError
                }
                // A function directly wrapping this paren group resolves now.
                if let top = opStack.last, case .function(let fn) = top {
                    opStack.removeLast()
                    output.append(.function(fn))
                }
            }
        }

        while let top = opStack.popLast() {
            if case .leftParen = top { throw CalcError.syntaxError }
            try flush(top, into: &output)
        }

        return output
    }

    private static func shouldPop(_ stackTop: CalcToken, over incoming: BinaryOperator) -> Bool {
        switch stackTop {
        case .binaryOperator(let stackOp):
            return incoming.isRightAssociative
                ? stackOp.precedence > incoming.precedence
                : stackOp.precedence >= incoming.precedence
        case .function:
            return true // functions always bind tighter than any binary operator
        default:
            return false
        }
    }

    private static func flush(_ token: CalcToken, into output: inout [RPNItem]) throws {
        switch token {
        case .binaryOperator(let op): output.append(.binaryOperator(op))
        case .function(let fn): output.append(.function(fn))
        default: throw CalcError.syntaxError
        }
    }

    // MARK: - RPN Evaluation

    private static func evaluateRPN(_ rpn: [RPNItem], angleUnit: AngleUnit) throws -> Double {
        var stack: [Double] = []

        for item in rpn {
            switch item {
            case .number(let value):
                stack.append(value)

            case .binaryOperator(let op):
                guard stack.count >= 2 else { throw CalcError.syntaxError }
                let rhs = stack.removeLast()
                let lhs = stack.removeLast()
                stack.append(try op.apply(lhs, rhs))

            case .function(let fn):
                guard let value = stack.popLast() else { throw CalcError.syntaxError }
                stack.append(try fn.apply(value, angleUnit: angleUnit))
            }
        }

        guard stack.count == 1, let result = stack.first else { throw CalcError.syntaxError }
        return result
    }
}
