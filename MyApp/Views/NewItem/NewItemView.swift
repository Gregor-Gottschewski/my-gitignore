import os
import SwiftUI
import SwiftData

struct NewItemView: View {
    /// When set, the view edits this file instead of creating a new one.
    var file: GitignoreFile? = nil
    var onDone: () -> Void

    private let logger: Logger = Logger.init(subsystem: "me.gregorgott.mygitignore", category: "NewItemView")
    @State private var title = ""
    @State private var description = ""
    @State private var selectedTemplates = Set<String>()
    @State private var searchText: String = ""
    @State private var templates: [TemplateEntry] = []
    @State private var bgColor = Color(.sRGB, red: 0.98, green: 0.9, blue: 0.2)
    @State private var showDuplicateAlert = false
    @Environment(\.modelContext) private var context
    @Environment(TemplateStore.self) private var store

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                TextField("New Element", text: $title)
                    .textFieldStyle(.plain)
                    .font(.title)
                Spacer()
                Button("Cancel", action: onDone)
                    .controlSize(.large)
                Button("Done", action: finish)
                    .buttonStyle(.glassProminent)
                    .controlSize(.large)
                    .disabled(title.isEmpty)
            }
            
            TextField("Description...", text: $description)
                .textFieldStyle(.plain)
            
            ColorPicker("Color", selection: $bgColor)
            
            TextField("Search...", text: $searchText)
                .textFieldStyle(.roundedBorder)

            List(filteredTemplates) { template in
                Toggle(template.name, isOn: Binding(
                    get: { selectedTemplates.contains(template.name) },
                    set: { isOn in
                        if isOn { selectedTemplates.insert(template.name) }
                        else { selectedTemplates.remove(template.name) }
                    }
                ))
            }
        }
        .padding()
        .frame(minWidth: 450, minHeight: 500, alignment: .topLeading)
        .onAppear {
            templates = store.getTemplates().sorted().map { TemplateEntry(name: $0) }
            if let file {
                title = file.name
                description = file.fileDescription
                selectedTemplates = Set(file.templates)
                bgColor = file.color
            }
        }
        .alert("A template named “\(title.trimmingCharacters(in: .whitespacesAndNewlines))” already exists.", isPresented: $showDuplicateAlert) {
            Button("OK") {}
        } message: {
            Text("Please choose a different name.")
        }
    }

    private func finish() {
        let name = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !name.isEmpty else { return }
        guard !nameExists(name) else {
            showDuplicateAlert = true
            return
        }
        if let file {
            file.name = name
            file.fileDescription = description
            file.templates = selectedTemplates.sorted()
            file.color = bgColor
        } else {
            let data = GitignoreFile(name: name, fileDescription: description, templates: selectedTemplates.sorted(), color: bgColor)
            context.insert(data)
        }
        onDone()
    }

    private func nameExists(_ name: String) -> Bool {
        let ownID = file?.persistentModelID
        let descriptor = FetchDescriptor<GitignoreFile>(
            predicate: #Predicate { $0.name == name }
        )
        let matches = (try? context.fetch(descriptor)) ?? []
        return matches.contains { $0.persistentModelID != ownID }
    }
    
    private var filteredTemplates: [TemplateEntry] {
        if searchText.isEmpty { return templates }
        return templates.filter {
            $0.name.localizedCaseInsensitiveContains(searchText)
        }
    }
}

#Preview {
    NewItemView(onDone: { })
        .environment(TemplateStore())
        .modelContainer(for: GitignoreFile.self, inMemory: true)
}
