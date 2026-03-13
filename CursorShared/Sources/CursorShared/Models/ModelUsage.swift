import Foundation

public struct ModelUsage: Codable, Identifiable {
    public let id: String
    public let name: String
    public let requests: Int
    public let requestsTotal: Int
    public let tokens: Int
    public let maxRequestUsage: Int?
    public let maxTokenUsage: Int?

    public var percentageOfTotal: Double { 0 }

    public init(
        id: String,
        name: String,
        requests: Int,
        requestsTotal: Int,
        tokens: Int,
        maxRequestUsage: Int?,
        maxTokenUsage: Int?
    ) {
        self.id = id
        self.name = name
        self.requests = requests
        self.requestsTotal = requestsTotal
        self.tokens = tokens
        self.maxRequestUsage = maxRequestUsage
        self.maxTokenUsage = maxTokenUsage
    }
}

public struct ModelUsageResponse: Codable {
    public let gpt4: ModelUsageData
    public let gpt432k: ModelUsageData
    public let gpt35Turbo: ModelUsageData
    public let startOfMonth: String

    public enum CodingKeys: String, CodingKey {
        case gpt4 = "gpt-4"
        case gpt432k = "gpt-4-32k"
        case gpt35Turbo = "gpt-3.5-turbo"
        case startOfMonth
    }

    public init(gpt4: ModelUsageData, gpt432k: ModelUsageData, gpt35Turbo: ModelUsageData, startOfMonth: String) {
        self.gpt4 = gpt4
        self.gpt432k = gpt432k
        self.gpt35Turbo = gpt35Turbo
        self.startOfMonth = startOfMonth
    }
}

public struct ModelUsageData: Codable {
    public let numRequests: Int
    public let numRequestsTotal: Int
    public let numTokens: Int
    public let maxRequestUsage: Int?
    public let maxTokenUsage: Int?

    public init(
        numRequests: Int,
        numRequestsTotal: Int,
        numTokens: Int,
        maxRequestUsage: Int?,
        maxTokenUsage: Int?
    ) {
        self.numRequests = numRequests
        self.numRequestsTotal = numRequestsTotal
        self.numTokens = numTokens
        self.maxRequestUsage = maxRequestUsage
        self.maxTokenUsage = maxTokenUsage
    }
}
