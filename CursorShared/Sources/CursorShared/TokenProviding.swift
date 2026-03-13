import Foundation

/// Protocol for providing Cursor API authentication token.
/// macOS: reads from Cursor's SQLite database.
/// iOS: manual input or Keychain.
public protocol TokenProviding {
    func getToken() throws -> String?
}
