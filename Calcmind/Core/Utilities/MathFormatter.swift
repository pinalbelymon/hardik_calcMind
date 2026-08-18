import Foundation

/// Utility to sanitize AI response text and remove raw LaTeX math delimiters ($ and $$),
/// raw Markdown header symbols (###, ####), \mathbf{}, \text{}, \implies, \times, \quad, etc.,
/// producing clean, human-readable math text.
enum MathFormatter {
    static func format(_ text: String) -> String {
        guard !text.isEmpty else { return text }
        var result = text

        // Replace block math $$ ... $$ with inner content
        let blockPattern = #"\$\$(.*?)\$\$"#
        if let regex = try? NSRegularExpression(pattern: blockPattern, options: [.dotMatchesLineSeparators]) {
            let range = NSRange(result.startIndex..., in: result)
            result = regex.stringByReplacingMatches(in: result, options: [], range: range, withTemplate: "$1")
        }

        // Replace inline math $ ... $ with inner content
        let inlinePattern = #"\$(.*?)\$"#
        if let regex = try? NSRegularExpression(pattern: inlinePattern, options: []) {
            let range = NSRange(result.startIndex..., in: result)
            result = regex.stringByReplacingMatches(in: result, options: [], range: range, withTemplate: "$1")
        }

        // Convert Markdown headers (### Header / #### Header) into clean bold section titles
        let headerPattern = #"(?m)^#{1,6}\s*(.*?)$"#
        if let regex = try? NSRegularExpression(pattern: headerPattern, options: []) {
            let range = NSRange(result.startIndex..., in: result)
            result = regex.stringByReplacingMatches(in: result, options: [], range: range, withTemplate: "**$1**")
        }

        // Remove \mathbf{...}
        let mathbfPattern = #"\\mathbf\{(.*?)\}"#
        if let regex = try? NSRegularExpression(pattern: mathbfPattern, options: []) {
            let range = NSRange(result.startIndex..., in: result)
            result = regex.stringByReplacingMatches(in: result, options: [], range: range, withTemplate: "$1")
        }

        // Remove \text{...}
        let textPattern = #"\\text\{(.*?)\}"#
        if let regex = try? NSRegularExpression(pattern: textPattern, options: []) {
            let range = NSRange(result.startIndex..., in: result)
            result = regex.stringByReplacingMatches(in: result, options: [], range: range, withTemplate: "$1")
        }

        // Replace LaTeX command symbols with clean unicode equivalents
        let replacements: [(String, String)] = [
            ("\\implies", "⟹"),
            ("\\times", "×"),
            ("\\div", "÷"),
            ("\\quad", " "),
            ("\\qquad", " "),
            ("\\le ", "≤ "),
            ("\\leq", "≤"),
            ("\\ge ", "≥ "),
            ("\\geq", "≥"),
            ("\\pm", "±"),
            ("\\approx", "≈"),
            ("\\neq", "≠"),
            ("\\cdot", "•"),
            ("$$", ""),
            ("$", "")
        ]

        for (target, replacement) in replacements {
            result = result.replacingOccurrences(of: target, with: replacement)
        }

        return result
    }
}
