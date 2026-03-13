import Foundation

public struct CursorMetrics: Codable {
    public let premiumUsage: PremiumUsage
    public let modelDistribution: [ModelUsage]
    public let subscriptionIncludedRequests: Int
    public let subscriptionRemainingRequests: Int
    public let billingCycleStart: Date
    public let billingCycleEnd: Date

    public init(premiumUsage: PremiumUsage, modelDistribution: [ModelUsage]) {
        self.premiumUsage = premiumUsage
        self.modelDistribution = modelDistribution.sorted { $0.requests > $1.requests }

        self.subscriptionIncludedRequests = premiumUsage.current
        self.subscriptionRemainingRequests = premiumUsage.remaining

        var startDate: Date?

        let iso8601WithFractional = ISO8601DateFormatter()
        iso8601WithFractional.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let date = iso8601WithFractional.date(from: premiumUsage.startOfMonth) {
            startDate = date
        }

        if startDate == nil {
            let iso8601 = ISO8601DateFormatter()
            iso8601.formatOptions = [.withInternetDateTime]
            if let date = iso8601.date(from: premiumUsage.startOfMonth) {
                startDate = date
            }
        }

        if startDate == nil {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
            formatter.timeZone = TimeZone(secondsFromGMT: 0)
            if let date = formatter.date(from: premiumUsage.startOfMonth) {
                startDate = date
            }
        }

        if startDate == nil {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
            formatter.timeZone = TimeZone(secondsFromGMT: 0)
            if let date = formatter.date(from: premiumUsage.startOfMonth) {
                startDate = date
            }
        }

        if let startDate = startDate {
            self.billingCycleStart = startDate
            var components = DateComponents()
            components.month = 1
            self.billingCycleEnd = Calendar.current.date(byAdding: components, to: startDate) ?? startDate
        } else {
            let now = Date()
            self.billingCycleStart = Calendar.current.startOfDay(for: now)
            self.billingCycleEnd = Calendar.current.date(byAdding: .month, value: 1, to: self.billingCycleStart) ?? now
        }
    }
}
