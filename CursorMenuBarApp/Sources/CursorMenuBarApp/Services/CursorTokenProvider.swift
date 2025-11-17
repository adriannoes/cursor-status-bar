import Foundation
import GRDB

class CursorTokenProvider {
    static let shared = CursorTokenProvider()
    
    private var cachedToken: String?
    private let customPathKey = "cursorDatabaseCustomPath"
    
    private init() {}
    
    func getToken() throws -> String? {
        if let cached = cachedToken {
            return cached
        }
        
        let token = try readTokenFromDatabase()
        cachedToken = token
        return token
    }
    
    func clearCache() {
        cachedToken = nil
    }
    
    func setCustomDatabasePath(_ path: String?) {
        if let path = path {
            UserDefaults.standard.set(path, forKey: customPathKey)
        } else {
            UserDefaults.standard.removeObject(forKey: customPathKey)
        }
        clearCache()
    }
    
    func getCustomDatabasePath() -> String? {
        UserDefaults.standard.string(forKey: customPathKey)
    }
    
    private func getDefaultDatabasePath() -> String {
        let homeDirectory = FileManager.default.homeDirectoryForCurrentUser.path
        return "\(homeDirectory)/Library/Application Support/Cursor/User/globalStorage/state.vscdb"
    }
    
    private func readTokenFromDatabase() throws -> String? {
        let dbPath = getCustomDatabasePath() ?? getDefaultDatabasePath()
        
        guard FileManager.default.fileExists(atPath: dbPath) else {
            print("Database file not found at: \(dbPath)")
            return nil
        }
        
        do {
            let dbQueue = try DatabaseQueue(path: dbPath, readonly: true)
            
            return try dbQueue.read { db in
                // Search for token in ItemTable
                let sql = """
                    SELECT value FROM ItemTable 
                    WHERE key LIKE '%workosCursorSessionToken%' 
                    OR key LIKE '%WorkosCursorSessionToken%'
                    LIMIT 1
                """
                
                if let row = try Row.fetchOne(db, sql: sql) {
                    if let value = row["value"] as? String {
                        return value
                    }
                }
                
                return nil
            }
        } catch {
            print("Error reading database: \(error.localizedDescription)")
            throw error
        }
    }
}

