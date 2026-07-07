import Foundation

struct Tool: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var date: Date = Date()
    var name: String
    var category: String
    var lastServiced: String
}
