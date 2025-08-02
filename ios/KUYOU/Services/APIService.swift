import Foundation
import Combine

enum APIError: LocalizedError {
    case invalidURL
    case noData
    case decodingError
    case networkError(String)
    case unauthorized
    case serverError(String)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "無効なURLです"
        case .noData:
            return "データがありません"
        case .decodingError:
            return "データの解析に失敗しました"
        case .networkError(let message):
            return "ネットワークエラー: \(message)"
        case .unauthorized:
            return "認証が必要です"
        case .serverError(let message):
            return "サーバーエラー: \(message)"
        }
    }
}

class APIService {
    static let shared = APIService()
    
    private let baseURL = "http://localhost:3000/api/v1"
    private let session = URLSession.shared
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder
    
    private init() {
        decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
    }
    
    private func createRequest(
        path: String,
        method: String = "GET",
        body: Data? = nil,
        authenticated: Bool = true
    ) -> URLRequest? {
        guard let url = URL(string: "\(baseURL)\(path)") else { return nil }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        if authenticated, let token = AuthService.shared.currentToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        request.httpBody = body
        
        return request
    }
    
    func request<T: Decodable>(
        path: String,
        method: String = "GET",
        body: Data? = nil,
        authenticated: Bool = true,
        responseType: T.Type
    ) -> AnyPublisher<T, APIError> {
        guard let request = createRequest(
            path: path,
            method: method,
            body: body,
            authenticated: authenticated
        ) else {
            return Fail(error: APIError.invalidURL)
                .eraseToAnyPublisher()
        }
        
        return session.dataTaskPublisher(for: request)
            .tryMap { data, response in
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw APIError.networkError("Invalid response")
                }
                
                switch httpResponse.statusCode {
                case 200...299:
                    return data
                case 401:
                    throw APIError.unauthorized
                case 400...499:
                    if let errorData = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                       let error = errorData["error"] as? String {
                        throw APIError.serverError(error)
                    }
                    throw APIError.serverError("Client error: \(httpResponse.statusCode)")
                case 500...599:
                    throw APIError.serverError("Server error: \(httpResponse.statusCode)")
                default:
                    throw APIError.networkError("Unexpected status code: \(httpResponse.statusCode)")
                }
            }
            .decode(type: T.self, decoder: decoder)
            .mapError { error in
                if error is DecodingError {
                    return APIError.decodingError
                } else if let apiError = error as? APIError {
                    return apiError
                } else {
                    return APIError.networkError(error.localizedDescription)
                }
            }
            .eraseToAnyPublisher()
    }
    
    func encode<T: Encodable>(_ value: T) throws -> Data {
        return try encoder.encode(value)
    }
}