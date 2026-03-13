import Foundation

public struct PremiumUsage: Codable {
    public let current: Int
    public let limit: Int
    public let startOfMonth: String

    public var percentage: Double {
        guard limit > 0 else { return 0 }
        return (Double(current) / Double(limit)) * 100
    }

    public var remaining: Int {
        max(0, limit - current)
    }

    public init(current: Int, limit: Int, startOfMonth: String) {
        self.current = current
        self.limit = limit
        self.startOfMonth = startOfMonth
    }
}
