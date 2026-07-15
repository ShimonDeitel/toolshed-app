import SwiftUI

struct ContentView: View {
    @EnvironmentObject var store: Store
    @EnvironmentObject var purchases: PurchaseManager
    @State private var showAdd = false
    @State private var showSettings = false
    @State private var showPaywall = false
    @State private var editingItem: Tool?

    @State private var newName: String = ""
    @State private var newCategory: String = ""
    @State private var newLastServiced: String = ""

    @State private var editName: String = ""
    @State private var editCategory: String = ""
    @State private var editLastServiced: String = ""

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.background.ignoresSafeArea()

                if store.items.isEmpty {
                    ContentUnavailableView(
                        "No entries yet",
                        systemImage: "leaf",
                        description: Text("Tap + to add your first entry.")
                    )
                } else {
                    List {
                        ForEach(store.items) { item in
                            Button {
                                editingItem = item
                                loadEdit(item)
                            } label: {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(item.name)
                                        .font(Theme.headlineFont)
                                        .foregroundStyle(.primary)
                                    Text(item.category + " · " + item.lastServiced)
                                        .font(Theme.captionFont)
                                        .foregroundStyle(.secondary)
                                }
                            }
                            .accessibilityIdentifier("itemRow_\(item.id.uuidString)")
                        }
                        .onDelete { offsets in
                            store.delete(at: offsets)
                        }
                    }
                    .scrollContentBackground(.hidden)
                }
            }
            .navigationTitle("Toolshed")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        showSettings = true
                    } label: {
                        Image(systemName: "gearshape.fill")
                    }
                    .accessibilityIdentifier("settingsButton")
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        if store.canAddMore {
                            showAdd = true
                        } else {
                            showPaywall = true
                        }
                    } label: {
                        Image(systemName: "plus")
                    }
                    .accessibilityIdentifier("addButton")
                }
            }
            .sheet(isPresented: $showAdd) {
                addSheet
            }
            .sheet(item: $editingItem) { item in
                editSheet(for: item)
            }
            .sheet(isPresented: $showSettings) {
                SettingsView()
            }
            .sheet(isPresented: $showPaywall) {
                PaywallView()
            }
        }
    }

    private var addSheet: some View {
        NavigationStack {
            Form {
                TextField("Name", text: $newName)
                    .accessibilityIdentifier("addNameField")
                TextField("Category", text: $newCategory)
                    .accessibilityIdentifier("addCategoryField")
                TextField("LastServiced", text: $newLastServiced)
                    .accessibilityIdentifier("addLastServicedField")
            }
            .onTapGesture {
                hideKeyboard()
            }
            .navigationTitle("Add Entry")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        showAdd = false
                    }
                    .accessibilityIdentifier("addCancelButton")
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let item = Tool(name: newName, category: newCategory, lastServiced: newLastServiced)
                        store.add(item)
                        resetNew()
                        showAdd = false
                    }
                    .accessibilityIdentifier("addSaveButton")
                    .disabled(newName.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }

    private func editSheet(for item: Tool) -> some View {
        NavigationStack {
            Form {
                TextField("Name", text: $editName)
                    .accessibilityIdentifier("editNameField")
                TextField("Category", text: $editCategory)
                    .accessibilityIdentifier("editCategoryField")
                TextField("LastServiced", text: $editLastServiced)
                    .accessibilityIdentifier("editLastServicedField")
                Button("Delete Entry", role: .destructive) {
                    store.delete(item)
                    editingItem = nil
                }
                .accessibilityIdentifier("editDeleteButton")
            }
            .onTapGesture {
                hideKeyboard()
            }
            .navigationTitle("Edit Entry")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        editingItem = nil
                    }
                    .accessibilityIdentifier("editCancelButton")
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        var updated = item
        updated.name = editName
        updated.category = editCategory
        updated.lastServiced = editLastServiced
                        store.update(updated)
                        editingItem = nil
                    }
                    .accessibilityIdentifier("editSaveButton")
                }
            }
        }
    }

    private func resetNew() {
        newName = ""
        newCategory = ""
        newLastServiced = ""
    }

    private func loadEdit(_ item: Tool) {
        editName = item.name
        editCategory = item.category
        editLastServiced = item.lastServiced
    }
}

extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
