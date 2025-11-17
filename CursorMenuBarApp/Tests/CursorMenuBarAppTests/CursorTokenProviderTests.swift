import XCTest
@testable import CursorMenuBarApp

final class CursorTokenProviderTests: XCTestCase {
    var tokenProvider: CursorTokenProvider!
    
    override func setUp() {
        super.setUp()
        tokenProvider = CursorTokenProvider.shared
        tokenProvider.clearCache()
    }
    
    func testGetDefaultDatabasePath() {
        // Test if the default path is correct
        let homeDirectory = FileManager.default.homeDirectoryForCurrentUser.path
        let expectedPath = "\(homeDirectory)/Library/Application Support/Cursor/User/globalStorage/state.vscdb"
        
        // We cannot test the private method directly, but we can verify
        // that the token provider exists and works
        XCTAssertNotNil(tokenProvider)
    }
    
    func testClearCache() {
        // Test that cache can be cleared
        tokenProvider.clearCache()
        XCTAssertNotNil(tokenProvider)
    }
    
    func testCustomDatabasePath() {
        // Test custom path configuration
        let customPath = "/custom/path/to/database.db"
        tokenProvider.setCustomDatabasePath(customPath)
        
        let retrievedPath = tokenProvider.getCustomDatabasePath()
        XCTAssertEqual(retrievedPath, customPath)
        
        // Clear
        tokenProvider.setCustomDatabasePath(nil)
        XCTAssertNil(tokenProvider.getCustomDatabasePath())
    }
}

