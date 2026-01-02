import SwiftUI

struct MenuBarView: View {
    @StateObject private var repository = MetricsRepository.shared
    @State private var refreshInterval: TimeInterval = 60
    @State private var refreshTimer: Timer?
    
    var body: some View {
        contentView
            .onAppear {
                Task {
                    await repository.refresh()
                }
                startRefreshTimer()
            }
            .onDisappear {
                stopRefreshTimer()
            }
    }
    
    private var contentView: some View {
        VStack(alignment: .leading, spacing: 0) {
            headerView
            
            Divider()
            
            if repository.isLoading {
                loadingView
            } else if let error = repository.errorMessage {
                errorView(error)
            } else if let metrics = repository.metrics {
                metricsView(metrics)
            } else {
                emptyView
            }
            
            Divider()
            
            footerView
        }
        .frame(width: 320)
        .padding(.vertical, 8)
    }
    
    private var headerView: some View {
        HStack {
            Text("Cursor Stats")
                .font(.headline)
            
            Spacer()
            
            Button(action: {
                Task {
                    await repository.refresh()
                }
            }) {
                Image(systemName: "arrow.clockwise")
                    .foregroundColor(.blue)
            }
            .buttonStyle(.plain)
            .disabled(repository.isLoading)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
    }
    
    private var loadingView: some View {
        HStack {
            Spacer()
            ProgressView()
            Text("Loading...")
                .foregroundColor(.secondary)
            Spacer()
        }
        .padding()
    }
    
    private func errorView(_ message: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(.orange)
                Text("Error")
                    .font(.headline)
            }
            
            Text(message)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
    }
    
    private var emptyView: some View {
        VStack {
            Text("No data available")
                .foregroundColor(.secondary)
        }
        .padding()
    }
    
    private func metricsView(_ metrics: CursorMetrics) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Premium Usage Section
                premiumUsageSection(metrics.premiumUsage)
                
                Divider()
                
                // Subscription Info
                subscriptionSection(metrics)
                
                Divider()
                
                // Model Distribution
                modelDistributionSection(metrics.modelDistribution)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
        }
    }
    
    private func premiumUsageSection(_ usage: PremiumUsage) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Premium Requests")
                .font(.headline)
            
            HStack {
                Text("\(usage.current) / \(usage.limit)")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Spacer()
                
                Text("\(Int(usage.percentage))%")
                    .font(.title3)
                    .foregroundColor(usageColor(for: usage.percentage))
            }
            
            // Progress Bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 8)
                        .cornerRadius(4)
                    
                    Rectangle()
                        .fill(usageColor(for: usage.percentage))
                        .frame(width: geometry.size.width * CGFloat(usage.percentage / 100), height: 8)
                        .cornerRadius(4)
                }
            }
            .frame(height: 8)
        }
    }
    
    private func subscriptionSection(_ metrics: CursorMetrics) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Subscription Plan")
                .font(.headline)
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("Included in plan:")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("\(metrics.subscriptionIncludedRequests)")
                        .font(.caption)
                        .fontWeight(.medium)
                }
                
                HStack {
                    Text("Remaining:")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("\(metrics.subscriptionRemainingRequests)")
                        .font(.caption)
                        .fontWeight(.medium)
                }
                
                let formatter = DateFormatter()
                formatter.dateStyle = .short
                formatter.timeStyle = .none
                
                HStack {
                    Text("Cycle:")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("\(formatter.string(from: metrics.billingCycleStart)) - \(formatter.string(from: metrics.billingCycleEnd))")
                        .font(.caption)
                }
            }
        }
    }
    
    private func modelDistributionSection(_ models: [ModelUsage]) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Most Used Models")
                .font(.headline)
            
            if models.isEmpty {
                Text("No models used yet")
                    .font(.caption)
                    .foregroundColor(.secondary)
            } else {
                let totalRequests = models.reduce(0) { $0 + $1.requests }
                
                ForEach(models.prefix(5)) { model in
                    let percentage = totalRequests > 0 ? (Double(model.requests) / Double(totalRequests)) * 100 : 0
                    
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text(model.name)
                                .font(.subheadline)
                                .fontWeight(.medium)
                            
                            Spacer()
                            
                            Text("\(model.requests) req")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Text("(\(Int(percentage))%)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        GeometryReader { geometry in
                            ZStack(alignment: .leading) {
                                Rectangle()
                                    .fill(Color.gray.opacity(0.1))
                                    .frame(height: 4)
                                    .cornerRadius(2)
                                
                                Rectangle()
                                    .fill(modelColor(for: model.id))
                                    .frame(width: geometry.size.width * CGFloat(percentage / 100), height: 4)
                                    .cornerRadius(2)
                            }
                        }
                        .frame(height: 4)
                    }
                }
            }
        }
    }
    
    private var footerView: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Refresh every:")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Picker("", selection: $refreshInterval) {
                    Text("30s").tag(30.0)
                    Text("1min").tag(60.0)
                    Text("5min").tag(300.0)
                    Text("10min").tag(600.0)
                }
                .pickerStyle(.menu)
                .frame(width: 80)
                .onChange(of: refreshInterval) { _ in
                    restartRefreshTimer()
                }
            }
            
            HStack {
                Text("Last updated:")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                Spacer()
                let formatter = DateFormatter()
                formatter.timeStyle = .short
                formatter.dateStyle = .none
                Text(formatter.string(from: Date()))
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
    }
    
    private func usageColor(for percentage: Double) -> Color {
        if percentage >= 90 {
            return .red
        } else if percentage >= 75 {
            return .orange
        } else if percentage >= 50 {
            return .yellow
        } else {
            return .green
        }
    }
    
    private func modelColor(for modelId: String) -> Color {
        switch modelId {
        case "gpt-4":
            return .blue
        case "gpt-4-32k":
            return .purple
        case "gpt-3.5-turbo":
            return .green
        default:
            return .gray
        }
    }
    
    private func startRefreshTimer() {
        stopRefreshTimer()
        refreshTimer = Timer.scheduledTimer(withTimeInterval: refreshInterval, repeats: true) { _ in
            Task {
                await repository.refresh()
            }
        }
    }
    
    private func stopRefreshTimer() {
        refreshTimer?.invalidate()
        refreshTimer = nil
    }
    
    private func restartRefreshTimer() {
        startRefreshTimer()
    }
}

