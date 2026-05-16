import Foundation

/// A single message in the bird companion chat
struct ChatMessage: Identifiable, Equatable {
    let id = UUID()
    let role: Role
    let content: String

    enum Role: String {
        case user       // Student's question
        case assistant  // Bird companion's answer
        case system     // Internal system prompt (not displayed)
    }

    init(role: Role, content: String) {
        self.role = role
        self.content = content
    }
}
