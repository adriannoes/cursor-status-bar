import Foundation
import GRDB

let dbPath = FileManager.default.homeDirectoryForCurrentUser.path + "/Library/Application Support/Cursor/User/globalStorage/state.vscdb"

guard FileManager.default.fileExists(atPath: dbPath) else {
    print("ERROR: Cursor database not found")
    exit(1)
}

var config = Configuration()
config.readonly = true
let dbQueue = try! DatabaseQueue(path: dbPath, configuration: config)

var token: String?
var userId: String?

var workosToken: String? = try dbQueue.read { db -> String? in
    let sql = """
        SELECT value FROM ItemTable
        WHERE key LIKE '%workosCursorSessionToken%' OR key LIKE '%WorkosCursorSessionToken%'
        LIMIT 1
    """
    if let row = try Row.fetchOne(db, sql: sql), let value = row["value"] as? String {
        return value
    }
    return nil
}

if let t = workosToken {
    token = t
    userId = t.contains("%3A%3A") ? String(t.split(separator: "%3A%3A").first ?? "") : t
    print("Using WorkosCursorSessionToken from ItemTable")
} else {
    // Fallback: try accessToken, refreshToken, or any key containing "workos"
    let tokens: [(String, String)] = try dbQueue.read { db -> [(String, String)] in
        var result: [(String, String)] = []
        let keys = ["cursorAuth/accessToken", "cursorAuth/refreshToken"]
        for key in keys {
            if let row = try Row.fetchOne(db, sql: "SELECT value FROM ItemTable WHERE key = ? LIMIT 1", arguments: [key]),
               let value = row["value"] as? String, value.count > 100 {
                result.append((key, value))
            }
        }
        // Also search for any key with workos in it
        if let row = try Row.fetchOne(db, sql: "SELECT key, value FROM ItemTable WHERE key LIKE '%workos%' OR key LIKE '%Workos%' LIMIT 1"),
           let value = row["value"] as? String {
            result.append((row["key"] as? String ?? "unknown", value))
        }
        return result
    }
    for (key, value) in tokens {
        token = value
        if value.hasPrefix("eyJ") {
            // JWT - decode for sub
            let parts = value.split(separator: ".")
            if parts.count >= 2 {
                var payload = String(parts[1])
                payload += String(repeating: "=", count: (4 - payload.count % 4) % 4)
                let base64 = payload.replacingOccurrences(of: "-", with: "+").replacingOccurrences(of: "_", with: "/")
                if let data = Data(base64Encoded: base64),
                   let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let sub = json["sub"] as? String {
                    userId = sub
                    print("Trying \(key) (JWT sub = \(sub))")
                    break
                }
            }
        } else if value.contains("%3A%3A") {
            userId = String(value.split(separator: "%3A%3A").first ?? "")
            print("Using \(key) (workos format)")
            break
        }
    }
    if userId == nil { userId = "unknown" }
}

guard let token = token, let actualUserId = userId, !actualUserId.isEmpty else {
    print("ERROR: No token found. Try: sqlite3 \"\(dbPath)\" \"SELECT key FROM ItemTable WHERE key LIKE '%auth%' OR key LIKE '%token%'\"")
    exit(1)
}

print("Token found. UserId prefix: \(String(actualUserId.prefix(30)))...")
print("")

// Try multiple auth formats
let authVariants: [(String, String, String)] = [
    ("Cookie: WorkosCursorSessionToken", "Cookie", "WorkosCursorSessionToken=\(token)"),
    ("Authorization: Bearer", "Authorization", "Bearer \(token)"),
]

var lastStatus = 0

for (name, header, value) in authVariants {
    print("--- Trying \(name) ---")
    let url = URL(string: "https://cursor.com/api/usage?user=\(actualUserId)")!
    var request = URLRequest(url: url)
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.setValue("https://cursor.com", forHTTPHeaderField: "Origin")
    request.setValue("https://cursor.com/dashboard", forHTTPHeaderField: "Referer")
    request.setValue("Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36", forHTTPHeaderField: "User-Agent")
    request.httpMethod = "GET"
    request.setValue(value, forHTTPHeaderField: header)

    var resultData: Data?
    var resultResponse: URLResponse?
    let semaphore = DispatchSemaphore(value: 0)
    URLSession.shared.dataTask(with: request) { data, response, _ in
        resultData = data
        resultResponse = response
        semaphore.signal()
    }.resume()
    semaphore.wait()

    guard let data = resultData, let response = resultResponse, let httpResponse = response as? HTTPURLResponse else {
        print("ERROR: No response")
        continue
    }

    lastStatus = httpResponse.statusCode
    print("Status: \(httpResponse.statusCode)")

    if httpResponse.statusCode == 200 {
        print("")
        if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
            print("=== TOP-LEVEL KEYS ===")
            print(Array(json.keys).sorted().joined(separator: ", "))
            print("")
            print("=== RAW JSON (pretty) ===")
            if let pretty = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted),
               let prettyStr = String(data: pretty, encoding: .utf8) {
                print(prettyStr)
            }
        } else {
            print(String(data: data, encoding: .utf8) ?? "Invalid UTF-8")
        }
        exit(0)
    }

    if let body = String(data: data, encoding: .utf8) {
        print("Response: \(body.prefix(200))")
    }
    print("")
}

print("All auth variants failed (last status: \(lastStatus))")
print("")
print("Next step: Open cursor.com/dashboard in browser → DevTools → Network →")
print("Find a request to cursor.com/api/usage → Copy 'WorkosCursorSessionToken' from Request Headers")
exit(1)
