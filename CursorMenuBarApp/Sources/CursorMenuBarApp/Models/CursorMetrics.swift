import Foundation

struct CursorMetrics: Codable {
    let premiumUsage: PremiumUsage
    let modelDistribution: [ModelUsage]
    let subscriptionIncludedRequests: Int
    let subscriptionRemainingRequests: Int
    let billingCycleStart: Date
    let billingCycleEnd: Date
    
    init(premiumUsage: PremiumUsage, modelDistribution: [ModelUsage]) {
        self.premiumUsage = premiumUsage
        self.modelDistribution = modelDistribution.sorted { $0.requests > $1.requests }
        
        // Calculate subscription included requests (using GPT-4 as base)
        self.subscriptionIncludedRequests = premiumUsage.current
        self.subscriptionRemainingRequests = premiumUsage.remaining
        
        // Calculate billing cycle
        var startDate: Date?
        
        // Try different date formats
        // ISO8601 with fractional seconds
        let iso8601WithFractional = ISO8601DateFormatter()
        iso8601WithFractional.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let date = iso8601WithFractional.date(from: premiumUsage.startOfMonth) {
            startDate = date
        }
        
        // ISO8601 without fractional seconds
        if startDate == nil {
            let iso8601 = ISO8601DateFormatter()
            iso8601.formatOptions = [.withInternetDateTime]
            if let date = iso8601.date(from: premiumUsage.startOfMonth) {
                startDate = date
            }
        }
        
        // DateFormatter with specific format
        if startDate == nil {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
            formatter.timeZone = TimeZone(secondsFromGMT: 0)
            if let date = formatter.date(from: premiumUsage.startOfMonth) {
                startDate = date
            }
        }
        
        // DateFormatter without milliseconds
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
            // Fallback to current date
            let now = Date()
            self.billingCycleStart = Calendar.current.startOfDay(for: now)
            self.billingCycleEnd = Calendar.current.date(byAdding: .month, value: 1, to: self.billingCycleStart) ?? now
        }
        
        // Percentages will be calculated when needed in the UI
    }
}

