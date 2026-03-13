import CursorShared

extension MetricsRepository {
    static let shared = MetricsRepository(tokenProvider: CursorTokenProvider.shared)
}
