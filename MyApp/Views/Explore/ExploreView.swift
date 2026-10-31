//
//  DiscoverView.swift
//  My Gitignore
//
//  Created by Gregor Gottschewski on 26.10.26.
//

import SwiftUI
import SwiftData
import AppKit

struct ExploreView: View {
    @Environment(\.modelContext) private var context
    @Environment(TemplateStore.self) private var store

    private let columns = [GridItem(.adaptive(minimum: 160))]

    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns) {
                ForEach(ExploreCatalog.definitions) { definition in
                    TemplateCard(
                        title: definition.name,
                        subtitle: definition.description,
                        onCopy: { copy(definition) },
                        onAdd: { add(definition) },
                        color: definition.color.color
                    )
                }
            }
            .padding()
        }
    }

    private func copy(_ definition: GitignoreDefinition) {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(store.combinedContent(for: definition.templates), forType: .string)
    }

    /// Adds a copy to My Gitignores, suffixing the name if it is already taken.
    private func add(_ definition: GitignoreDefinition) {
        var name = definition.name
        var counter = 2
        while nameExists(name) {
            name = "\(definition.name) \(counter)"
            counter += 1
        }
        context.insert(GitignoreFile(definition: definition, name: name))
    }

    private func nameExists(_ name: String) -> Bool {
        let descriptor = FetchDescriptor<GitignoreFile>(predicate: #Predicate { $0.name == name })
        return ((try? context.fetchCount(descriptor)) ?? 0) > 0
    }
}

#Preview {
    ExploreView()
        .modelContainer(for: GitignoreFile.self, inMemory: true)
        .environment(TemplateStore())
}
