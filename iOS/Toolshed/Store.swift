import Foundation
import Combine

@MainActor
final class Store: ObservableObject {
    static let freeLimit = 8

    @Published var items: [Tool] = []
    @Published var isPro: Bool = false

    private let fileURL: URL

    init() {
        let dir = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        fileURL = dir.appendingPathComponent("toolshed_items.json")
        load()
    }

    var canAddMore: Bool {
        isPro || items.count < Store.freeLimit
    }

    func add(_ item: Tool) {
        items.insert(item, at: 0)
        save()
    }

    func update(_ item: Tool) {
        if let idx = items.firstIndex(where: { $0.id == item.id }) {
            items[idx] = item
            save()
        }
    }

    func delete(at offsets: IndexSet) {
        items.remove(atOffsets: offsets)
        save()
    }

    func delete(_ item: Tool) {
        items.removeAll { $0.id == item.id }
        save()
    }

    private func load() {
        guard let data = try? Data(contentsOf: fileURL),
              let decoded = try? JSONDecoder().decode([Tool].self, from: data) else {
            items = Store.seedData()
            save()
            return
        }
        items = decoded
    }

    func save() {
        guard let data = try? JSONEncoder().encode(items) else { return }
        try? data.write(to: fileURL, options: .atomic)
    }

    static func seedData() -> [Tool] {
        [
        Tool(date: Date().addingTimeInterval(-86400), name: "Bypass Pruners", category: "Cutting", lastServiced: "Sharpened spring"),
        Tool(date: Date().addingTimeInterval(-172800), name: "Garden Fork", category: "Digging", lastServiced: "Oiled handle"),
        Tool(date: Date().addingTimeInterval(-259200), name: "Hedge Trimmer", category: "Powered", lastServiced: "Blades cleaned")
        ]
    }
}
