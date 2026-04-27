import Foundation

struct Source: Codable {
    let title: String
    let urlString: String
    let timestamp: Date

    init(_ title: String, _ urlString: String) {
        self.title = title
        self.urlString = urlString
        self.timestamp = Date()
    }
}
