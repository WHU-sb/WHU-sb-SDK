import Foundation
import CryptoKit

public struct WHUSBConfig {
    public let apiKey: String?
    public let apiSecret: String?
    public let baseUrl: String
    
    public init(apiKey: String? = nil, apiSecret: String? = nil, baseUrl: String = "https://whu.sb/api/v1") {
        self.apiKey = apiKey
        self.apiSecret = apiSecret
        self.baseUrl = baseUrl.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
    }
}

public struct APIResponse<T: Codable>: Codable {
    public let success: Bool
    public let data: T?
    public let message: String
}

public struct PagedResult<T: Codable>: Codable {
    public let items: [T]
    public let total: Int
    public let page: Int
    public let limit: Int
    public let totalPages: Int
}

public struct Course: Codable {
    public let id: UInt64
    public let course_uid: String
    public let name: String
    public let course_type: String?
    public let averageRating: Double?
}

/**
 * WHU-sb API SDK for Swift 5.5+
 */
public class WHUSBClient {
    private let config: WHUSBConfig
    private let session: URLSession
    
    public init(config: WHUSBConfig) {
        self.config = config
        self.session = URLSession.shared
    }
    
    public init(apiKey: String? = nil, apiSecret: String? = nil, baseUrl: String = "https://whu.sb/api/v1") {
        self.config = WHUSBConfig(apiKey: apiKey, apiSecret: apiSecret, baseUrl: baseUrl)
        self.session = URLSession.shared
    }
    
    private func generateSignature(timestamp: Int64) -> String {
        guard let key = config.apiKey, let secret = config.apiSecret else { return "" }
        let payload = "\(key)\(timestamp)\(secret)"
        let data = payload.data(using: .utf8)!
        let hash = SHA256.hash(data: data)
        return hash.compactMap { String(format: "%02x", $0) }.joined()
    }
    
    private func request<T: Codable>(method: String, endpoint: String, query: [String: String]? = nil, body: Data? = nil) async throws -> T {
        var urlComponents = URLComponents(string: "\(config.baseUrl)/\(endpoint.trimmingCharacters(in: CharacterSet(charactersIn: "/")))")!
        
        if let query = query {
            urlComponents.queryItems = query.map { URLQueryItem(name: $0.key, value: $0.value) }
        }
        
        var request = URLRequest(url: urlComponents.url!)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let timestamp = Int64(Date().timeIntervalSince1970)
        request.setValue(config.apiKey ?? "", forHTTPHeaderField: "X-API-Key")
        request.setValue(String(timestamp), forHTTPHeaderField: "X-Timestamp")
        
        if config.apiSecret != nil {
            request.setValue(generateSignature(timestamp: timestamp), forHTTPHeaderField: "X-Signature")
        }
        
        if let body = body {
            request.httpBody = body
        }
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NSError(domain: "WHUSBSDK", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid response"])
        }
        
        let apiResponse = try JSONDecoder().decode(APIResponse<T>.self, from: data)
        
        if !apiResponse.success {
            throw NSError(domain: "WHUSBSDK", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: apiResponse.message])
        }
        
        guard let resultData = apiResponse.data else {
            throw NSError(domain: "WHUSBSDK", code: -1, userInfo: [NSLocalizedDescriptionKey: "Empty data"])
        }
        
        return resultData
    }
    
    // --- Course APIs ---
    
    public func listCourses(page: Int = 1, limit: Int = 20) async throws -> PagedResult<Course> {
        return try await request(method: "GET", endpoint: "courses", query: ["page": String(page), "limit": String(limit)])
    }
    
    public func getCourse(uid: String) async throws -> Course {
        return try await request(method: "GET", endpoint: "courses/\(uid)")
    }
    
    public func searchCourses(query: String, page: Int = 1, limit: Int = 12) async throws -> PagedResult<Course> {
        return try await request(method: "GET", endpoint: "search/courses", query: ["query": query, "page": String(page), "limit": String(limit)])
    }
    
    // --- Search APIs ---
    
    public func getHotSearches() async throws -> [String] {
        return try await request(method: "GET", endpoint: "search/hot")
    }
    
    // --- User APIs ---
    
    public func getMe() async throws -> [String: String] {
        return try await request(method: "GET", endpoint: "users/me")
    }
    
    // --- Translation APIs ---
    
    public func translate(text: String, target: String) async throws -> [String: String] {
        let body = try JSONSerialization.data(withJSONObject: ["text": text, "target": target])
        return try await request(method: "POST", endpoint: "translation/translate", body: body)
    }
}
