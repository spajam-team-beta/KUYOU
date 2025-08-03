import Foundation

struct DateUtils {
    static func decodeDate<K: CodingKey>(from container: KeyedDecodingContainer<K>, forKey key: K) throws -> Date {
        let dateString = try container.decode(String.self, forKey: key)
        
        // ISO8601 with fractional seconds
        let iso8601Formatter = ISO8601DateFormatter()
        iso8601Formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        if let date = iso8601Formatter.date(from: dateString) {
            return date
        }
        
        // ISO8601 without fractional seconds
        iso8601Formatter.formatOptions = [.withInternetDateTime]
        if let date = iso8601Formatter.date(from: dateString) {
            return date
        }
        
        // Fallback: Rails default format
        let fallbackFormatter = DateFormatter()
        fallbackFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
        if let date = fallbackFormatter.date(from: dateString) {
            return date
        }
        
        // Another fallback: without timezone
        fallbackFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        if let date = fallbackFormatter.date(from: dateString) {
            return date
        }
        
        throw DecodingError.dataCorruptedError(forKey: key, in: container, debugDescription: "Date string '\(dateString)' does not match any expected format.")
    }
}
