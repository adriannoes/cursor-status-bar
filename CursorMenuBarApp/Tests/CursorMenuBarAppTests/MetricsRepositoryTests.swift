import XCTest
@testable import CursorMenuBarApp

final class MetricsRepositoryTests: XCTestCase {
    var repository: MetricsRepository!
    
    override func setUp() {
        super.setUp()
        repository = MetricsRepository.shared
    }
    
    func testRepositoryInitialization() {
        XCTAssertNotNil(repository)
        XCTAssertFalse(repository.isLoading)
        XCTAssertNil(repository.metrics)
        XCTAssertNil(repository.errorMessage)
    }
    
    func testPremiumUsageCalculation() {
        let usage = PremiumUsage(
            current: 150,
            limit: 500,
            startOfMonth: "2024-01-01T00:00:00.000Z"
        )
        
        XCTAssertEqual(usage.percentage, 30.0, accuracy: 0.1)
        XCTAssertEqual(usage.remaining, 350)
    }
    
    func testCursorMetricsInitialization() {
        let premiumUsage = PremiumUsage(
            current: 100,
            limit: 500,
            startOfMonth: "2024-01-01T00:00:00.000Z"
        )
        
        let model1 = ModelUsage(
            id: "gpt-4",
            name: "GPT-4",
            requests: 80,
            requestsTotal: 80,
            tokens: 1000,
            maxRequestUsage: 500,
            maxTokenUsage: nil
        )
        
        let model2 = ModelUsage(
            id: "gpt-4-32k",
            name: "GPT-4-32k",
            requests: 20,
            requestsTotal: 20,
            tokens: 500,
            maxRequestUsage: nil,
            maxTokenUsage: nil
        )
        
        let metrics = CursorMetrics(
            premiumUsage: premiumUsage,
            modelDistribution: [model1, model2]
        )
        
        XCTAssertEqual(metrics.premiumUsage.current, 100)
        XCTAssertEqual(metrics.modelDistribution.count, 2)
        // Verify that it's sorted by requests (highest first)
        XCTAssertEqual(metrics.modelDistribution.first?.id, "gpt-4")
    }
}

