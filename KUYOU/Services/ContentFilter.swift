import Foundation

enum ContentError: LocalizedError {
    case tooShort(minLength: Int)
    case tooLong(maxLength: Int)
    case inappropriateContent
    case spamDetected
    
    var errorDescription: String? {
        switch self {
        case .tooShort(let minLength):
            return "投稿は\(minLength)文字以上で入力してください"
        case .tooLong(let maxLength):
            return "投稿は\(maxLength)文字以内で入力してください"
        case .inappropriateContent:
            return "不適切な内容が含まれています"
        case .spamDetected:
            return "スパムの可能性があります"
        }
    }
}

class ContentFilter {
    static let shared = ContentFilter()
    
    private let minContentLength = 10
    private let maxContentLength = 500
    
    private let bannedWords: Set<String> = [
    ]
    
    private let spamPatterns: [String] = [
        "http://",
        "https://",
        "www.",
        ".com",
        "儲かる",
        "稼げる",
        "クリック",
        "今すぐ"
    ]
    
    private init() {}
    
    func validate(_ content: String) -> Result<Void, ContentError> {
        let trimmedContent = content.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if trimmedContent.count < minContentLength {
            return .failure(.tooShort(minLength: minContentLength))
        }
        
        if trimmedContent.count > maxContentLength {
            return .failure(.tooLong(maxLength: maxContentLength))
        }
        
        if containsBannedWords(trimmedContent) {
            return .failure(.inappropriateContent)
        }
        
        if isSpam(trimmedContent) {
            return .failure(.spamDetected)
        }
        
        return .success(())
    }
    
    private func containsBannedWords(_ content: String) -> Bool {
        let lowercasedContent = content.lowercased()
        return bannedWords.contains { bannedWord in
            lowercasedContent.contains(bannedWord.lowercased())
        }
    }
    
    private func isSpam(_ content: String) -> Bool {
        let lowercasedContent = content.lowercased()
        
        let spamCount = spamPatterns.filter { pattern in
            lowercasedContent.contains(pattern.lowercased())
        }.count
        
        return spamCount >= 3
    }
    
    func sanitize(_ content: String) -> String {
        var sanitized = content.trimmingCharacters(in: .whitespacesAndNewlines)
        
        sanitized = sanitized.replacingOccurrences(of: "\n\n\n", with: "\n\n")
        
        return sanitized
    }
}