import Foundation

struct PremiumUsage: Codable {
    let current: Int
    let limit: Int
    let startOfMonth: String
    
    var percentage: Double {
        guard limit > 0 else { return 0 }
        return (Double(current) / Double(limit)) * 100
    }
    
    var remaining: Int {
        max(0, limit - current)
    }
}

