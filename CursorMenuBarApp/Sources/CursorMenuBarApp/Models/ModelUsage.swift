import Foundation

struct ModelUsage: Codable, Identifiable {
    let id: String
    let name: String
    let requests: Int
    let requestsTotal: Int
    let tokens: Int
    let maxRequestUsage: Int?
    let maxTokenUsage: Int?
    
    var percentageOfTotal: Double {
        // Will be calculated when we have the total requests
        return 0
    }
}

struct ModelUsageResponse: Codable {
    let gpt4: ModelUsageData
    let gpt432k: ModelUsageData
    let gpt35Turbo: ModelUsageData
    let startOfMonth: String
    
    enum CodingKeys: String, CodingKey {
        case gpt4 = "gpt-4"
        case gpt432k = "gpt-4-32k"
        case gpt35Turbo = "gpt-3.5-turbo"
        case startOfMonth
    }
}

struct ModelUsageData: Codable {
    let numRequests: Int
    let numRequestsTotal: Int
    let numTokens: Int
    let maxRequestUsage: Int?
    let maxTokenUsage: Int?
}

