import Foundation

enum TutorModeSection: String, CaseIterable {
    case basics = "Basics"
    case practice = "Practice"
}

/// Study context for the AI Tutor — each mode adjusts Gemini's system instruction
/// so replies match what the student is trying to do.
struct TutorMode: Identifiable, Equatable {
    let id: String
    let title: String
    let subtitle: String
    let icon: String
    let section: TutorModeSection
    let systemInstruction: String
    let starterPrompt: String
    let examplePrompts: [String]

    static let mathTutor = TutorMode(
        id: "math_tutor",
        title: "Math Tutor",
        subtitle: "Chat with an AI tutor",
        icon: "book.fill",
        section: .basics,
        systemInstruction: """
        You are in general math tutor mode. Explain concepts clearly, check understanding
        with short questions, and adapt to the student's level. Balance intuition with
        step-by-step reasoning.
        """,
        starterPrompt: "I want help understanding a math topic.",
        examplePrompts: [
            "Explain the quadratic formula",
            "What is a derivative?",
            "How do I factor polynomials?",
        ]
    )

    static let allModes: [TutorMode] = [
        .mathTutor,
        TutorMode(
            id: "homework",
            title: "Homework",
            subtitle: "Your homework helper",
            icon: "pencil.and.ruler.fill",
            section: .basics,
            systemInstruction: """
            You are helping with homework. Guide the student through problems step by step
            instead of only giving the final answer. Ask what they've tried, point out
            mistakes gently, and teach the method so they can solve similar problems alone.
            """,
            starterPrompt: "I need help with my math homework.",
            examplePrompts: [
                "Help me with a word problem",
                "I'm stuck on question 7",
                "Check my work on this equation",
            ]
        ),
        TutorMode(
            id: "exam_prep",
            title: "Exam preparation",
            subtitle: "Practice for exams",
            icon: "checkmark.seal.fill",
            section: .basics,
            systemInstruction: """
            You are an exam coach. Offer practice-style questions, timed tips, and review
            strategies. Focus on high-yield topics, common exam traps, and how to show work
            clearly. When asked, create short drills and walk through solutions.
            """,
            starterPrompt: "I want to practice for an upcoming math exam.",
            examplePrompts: [
                "Give me a practice algebra problem",
                "What should I review for geometry?",
                "Help me prepare for a geometry test",
            ]
        ),
        TutorMode(
            id: "brain_training",
            title: "Brain training",
            subtitle: "Train logical thinking",
            icon: "brain.head.profile",
            section: .basics,
            systemInstruction: """
            You run quick logic and numeracy puzzles. Prefer short challenges, pattern
            recognition, mental math tricks, and reasoning games. Keep energy upbeat and
            celebrate correct thinking, not just correct answers.
            """,
            starterPrompt: "Give me a math brain teaser.",
            examplePrompts: [
                "A quick logic puzzle",
                "Mental math challenge",
                "Pattern recognition exercise",
            ]
        ),
        TutorMode(
            id: "study_tips",
            title: "Study tips",
            subtitle: "Excel at math",
            icon: "lightbulb.fill",
            section: .basics,
            systemInstruction: """
            You teach how to learn math effectively: note-taking, error analysis, spaced
            review, and fixing weak areas. Give concrete study plans and habits, not just
            formulas.
            """,
            starterPrompt: "How can I study math more effectively?",
            examplePrompts: [
                "How do I fix careless mistakes?",
                "Best way to review before a test",
                "How to remember formulas",
            ]
        ),
        TutorMode(
            id: "real_world",
            title: "Real-world math",
            subtitle: "Solve real-world math problems",
            icon: "globe.americas.fill",
            section: .basics,
            systemInstruction: """
            Connect math to everyday situations: budgeting, measurements, rates, discounts,
            travel, cooking, and DIY projects. Use realistic numbers and explain which math
            tools apply.
            """,
            starterPrompt: "Help me with a real-life math problem.",
            examplePrompts: [
                "Calculate a tip and split a bill",
                "Convert units for a recipe",
                "Compare loan interest options",
            ]
        ),
        TutorMode(
            id: "solve_math",
            title: "Solve math",
            subtitle: "Solve any math problem",
            icon: "questionmark.circle.fill",
            section: .practice,
            systemInstruction: """
            Focus on solving the problem the student presents. Show clear numbered steps,
            state assumptions, and give a final answer. If the problem is ambiguous, ask
            one clarifying question before solving.
            """,
            starterPrompt: "I have a math problem to solve.",
            examplePrompts: [
                "Solve 2x + 5 = 17",
                "Find the area of a triangle",
                "Simplify this expression",
            ]
        ),
        TutorMode(
            id: "accounting",
            title: "Accounting",
            subtitle: "Math for accountants",
            icon: "chart.pie.fill",
            section: .practice,
            systemInstruction: """
            Emphasize accounting math: percentages, interest, depreciation, margins, break-even,
            ratios, and spreadsheet-friendly calculations. Use business context and define
            terms when needed.
            """,
            starterPrompt: "Help me with accounting math.",
            examplePrompts: [
                "Calculate gross margin",
                "Simple interest example",
                "Depreciation straight-line method",
            ]
        ),
        TutorMode(
            id: "data_analysis",
            title: "Data analysis",
            subtitle: "Math for data analysis",
            icon: "chart.bar.fill",
            section: .practice,
            systemInstruction: """
            Teach statistics and data intuition: mean, median, variance, probability, linear
            trends, and reading charts. Prefer small datasets and explain what conclusions
            are (and aren't) justified.
            """,
            starterPrompt: "Explain a statistics concept for data analysis.",
            examplePrompts: [
                "What is standard deviation?",
                "Interpret a scatter plot",
                "Probability with two events",
            ]
        ),
        TutorMode(
            id: "college",
            title: "College",
            subtitle: "Math for college",
            icon: "building.columns.fill",
            section: .practice,
            systemInstruction: """
            Target college-level math: precalculus, calculus, linear algebra basics, and
            proofs at an introductory level. Use precise notation but still explain intuition.
            """,
            starterPrompt: "I need help with college-level math.",
            examplePrompts: [
                "Limits and continuity basics",
                "Matrix multiplication example",
                "Chain rule practice",
            ]
        ),
        TutorMode(
            id: "business",
            title: "Business",
            subtitle: "Math for business",
            icon: "briefcase.fill",
            section: .practice,
            systemInstruction: """
            Focus on business applications: ROI, unit economics, forecasting, optimization,
            and decision math. Tie formulas to what a business owner or analyst would do.
            """,
            starterPrompt: "Help with business math.",
            examplePrompts: [
                "Break-even analysis",
                "Compound growth estimate",
                "Compare two pricing models",
            ]
        ),
        TutorMode(
            id: "highschool",
            title: "High school",
            subtitle: "Math for high school",
            icon: "graduationcap.fill",
            section: .practice,
            systemInstruction: """
            Match typical high school curricula: algebra I/II, geometry, trigonometry, and
            intro precalculus. Align with classroom notation and exam-style working.
            """,
            starterPrompt: "I'm working on high school math.",
            examplePrompts: [
                "Systems of equations",
                "Pythagorean theorem application",
                "Sine and cosine in trig",
            ]
        ),
    ]

    static func mode(for id: String) -> TutorMode {
        allModes.first { $0.id == id } ?? .mathTutor
    }

    static func modes(in section: TutorModeSection) -> [TutorMode] {
        allModes.filter { $0.section == section }
    }
}
