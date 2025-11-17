import Foundation

class CursorAPI {
    static let shared = CursorAPI()
    
    private let baseURL = "https://cursor.com/api"
    
    private init() {}
    
    private func getBrowserHeaders(token: String) -> [String: String] {
        return [
            "Content-Type": "application/json",
            "Cookie": "WorkosCursorSessionToken=\(token)",
            "Origin": "https://cursor.com",
            "Referer": "https://cursor.com/dashboard",
            "Sec-Fetch-Site": "same-origin",
            "Sec-Fetch-Mode": "cors",
            "Sec-Fetch-Dest": "empty",
            "User-Agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36",
            "Accept": "*/*",
            "Accept-Language": "en",
            "Cache-Control": "no-cache",
            "Pragma": "no-cache"
        ]
    }
    
    func fetchUsage(token: String) async throws -> ModelUsageResponse {
        let userId = extractUserId(from: token)
        let url = URL(string: "\(baseURL)/usage?user=\(userId)")!
        
        var request = URLRequest(url: url)
        request.allHTTPHeaderFields = getBrowserHeaders(token: token)
        request.httpMethod = "GET"
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw CursorAPIError.invalidResponse
        }
        
        guard httpResponse.statusCode == 200 else {
            if httpResponse.statusCode == 401 {
                throw CursorAPIError.unauthorized
            }
            throw CursorAPIError.httpError(statusCode: httpResponse.statusCode)
        }
        
        // Decode manually because we have keys with hyphens
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        
        guard let json = json,
              let gpt4Dict = json["gpt-4"] as? [String: Any],
              let gpt432kDict = json["gpt-4-32k"] as? [String: Any],
              let gpt35TurboDict = json["gpt-3.5-turbo"] as? [String: Any],
              let startOfMonthString = json["startOfMonth"] as? String else {
            throw CursorAPIError.invalidResponse
        }
        
        let gpt4 = ModelUsageData(
            numRequests: gpt4Dict["numRequests"] as? Int ?? 0,
            numRequestsTotal: gpt4Dict["numRequestsTotal"] as? Int ?? 0,
            numTokens: gpt4Dict["numTokens"] as? Int ?? 0,
            maxRequestUsage: gpt4Dict["maxRequestUsage"] as? Int,
            maxTokenUsage: gpt4Dict["maxTokenUsage"] as? Int
        )
        
        let gpt432k = ModelUsageData(
            numRequests: gpt432kDict["numRequests"] as? Int ?? 0,
            numRequestsTotal: gpt432kDict["numRequestsTotal"] as? Int ?? 0,
            numTokens: gpt432kDict["numTokens"] as? Int ?? 0,
            maxRequestUsage: gpt432kDict["maxRequestUsage"] as? Int,
            maxTokenUsage: gpt432kDict["maxTokenUsage"] as? Int
        )
        
        let gpt35Turbo = ModelUsageData(
            numRequests: gpt35TurboDict["numRequests"] as? Int ?? 0,
            numRequestsTotal: gpt35TurboDict["numRequestsTotal"] as? Int ?? 0,
            numTokens: gpt35TurboDict["numTokens"] as? Int ?? 0,
            maxRequestUsage: gpt35TurboDict["maxRequestUsage"] as? Int,
            maxTokenUsage: gpt35TurboDict["maxTokenUsage"] as? Int
        )
        
        return ModelUsageResponse(
            gpt4: gpt4,
            gpt432k: gpt432k,
            gpt35Turbo: gpt35Turbo,
            startOfMonth: startOfMonthString
        )
    }
    
    func fetchUsageLimit(token: String, teamId: Int? = nil) async throws -> UsageLimitResponse {
        let url = URL(string: "\(baseURL)/dashboard/get-hard-limit")!
        
        var request = URLRequest(url: url)
        request.allHTTPHeaderFields = getBrowserHeaders(token: token)
        request.httpMethod = "POST"
        
        var body: [String: Any] = [:]
        if let teamId = teamId {
            body["teamId"] = teamId
        }
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw CursorAPIError.invalidResponse
        }
        
        guard httpResponse.statusCode == 200 else {
            if httpResponse.statusCode == 401 {
                throw CursorAPIError.unauthorized
            }
            throw CursorAPIError.httpError(statusCode: httpResponse.statusCode)
        }
        
        let decoder = JSONDecoder()
        return try decoder.decode(UsageLimitResponse.self, from: data)
    }
    
    private func extractUserId(from token: String) -> String {
        // Token format: userId%3A%3AjwtToken
        if let userId = token.split(separator: "%3A%3A").first {
            return String(userId)
        }
        return ""
    }
}

enum CursorAPIError: Error {
    case invalidResponse
    case unauthorized
    case httpError(statusCode: Int)
    case decodingError
    
    var localizedDescription: String {
        switch self {
        case .invalidResponse:
            return "Resposta inválida da API"
        case .unauthorized:
            return "Token inválido ou expirado"
        case .httpError(let code):
            return "Erro HTTP: \(code)"
        case .decodingError:
            return "Erro ao decodificar resposta"
        }
    }
}

struct UsageLimitResponse: Codable {
    let hardLimit: Double?
    let hardLimitPerUser: Double?
    let noUsageBasedAllowed: Bool?
}

