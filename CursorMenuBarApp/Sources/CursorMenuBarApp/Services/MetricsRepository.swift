import Foundation

class MetricsRepository: ObservableObject {
    static let shared = MetricsRepository()
    
    @Published var metrics: CursorMetrics?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let tokenProvider = CursorTokenProvider.shared
    private let api = CursorAPI.shared
    
    private init() {}
    
    func refresh() async {
        await MainActor.run {
            isLoading = true
            errorMessage = nil
        }
        
        do {
            guard let token = try tokenProvider.getToken() else {
                await MainActor.run {
                    errorMessage = "Cursor token not found. Make sure you are logged into Cursor."
                    isLoading = false
                }
                return
            }
            
            // Fetch usage data
            let usageResponse = try await api.fetchUsage(token: token)
            
            // Convert to PremiumUsage
            let premiumUsage = PremiumUsage(
                current: usageResponse.gpt4.numRequests,
                limit: usageResponse.gpt4.maxRequestUsage ?? 500,
                startOfMonth: usageResponse.startOfMonth
            )
            
            // Convert to model distribution
            let totalRequests = usageResponse.gpt4.numRequests + 
                              usageResponse.gpt432k.numRequests + 
                              usageResponse.gpt35Turbo.numRequests
            
            var modelDistribution: [ModelUsage] = []
            
            if usageResponse.gpt4.numRequests > 0 {
                modelDistribution.append(ModelUsage(
                    id: "gpt-4",
                    name: "GPT-4",
                    requests: usageResponse.gpt4.numRequests,
                    requestsTotal: usageResponse.gpt4.numRequestsTotal,
                    tokens: usageResponse.gpt4.numTokens,
                    maxRequestUsage: usageResponse.gpt4.maxRequestUsage,
                    maxTokenUsage: usageResponse.gpt4.maxTokenUsage
                ))
            }
            
            if usageResponse.gpt432k.numRequests > 0 {
                modelDistribution.append(ModelUsage(
                    id: "gpt-4-32k",
                    name: "GPT-4-32k",
                    requests: usageResponse.gpt432k.numRequests,
                    requestsTotal: usageResponse.gpt432k.numRequestsTotal,
                    tokens: usageResponse.gpt432k.numTokens,
                    maxRequestUsage: usageResponse.gpt432k.maxRequestUsage,
                    maxTokenUsage: usageResponse.gpt432k.maxTokenUsage
                ))
            }
            
            if usageResponse.gpt35Turbo.numRequests > 0 {
                modelDistribution.append(ModelUsage(
                    id: "gpt-3.5-turbo",
                    name: "GPT-3.5 Turbo",
                    requests: usageResponse.gpt35Turbo.numRequests,
                    requestsTotal: usageResponse.gpt35Turbo.numRequestsTotal,
                    tokens: usageResponse.gpt35Turbo.numTokens,
                    maxRequestUsage: usageResponse.gpt35Turbo.maxRequestUsage,
                    maxTokenUsage: usageResponse.gpt35Turbo.maxTokenUsage
                ))
            }
            
            // Create metrics
            let metrics = CursorMetrics(
                premiumUsage: premiumUsage,
                modelDistribution: modelDistribution
            )
            
            await MainActor.run {
                self.metrics = metrics
                self.isLoading = false
            }
            
        } catch let error as CursorAPIError {
            await MainActor.run {
                self.errorMessage = error.localizedDescription
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.errorMessage = "Error fetching metrics: \(error.localizedDescription)"
                self.isLoading = false
            }
        }
    }
}

