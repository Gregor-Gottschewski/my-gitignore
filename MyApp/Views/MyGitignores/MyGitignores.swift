//
//  MyGitignores.swift
//  My Gitignore
//
//  Created by Gregor Gottschewski on 28.10.26.
//

import SwiftUI
import SwiftData
import AppKit

struct MyGitignores: View {
    @Environment(\.modelContext) private var context
    @Environment(TemplateStore.self) private var store
    @Query(sort: \GitignoreFile.name) private var files: [GitignoreFile]

    var searchText: String = ""

    @State private var fileToEdit: GitignoreFile?
    @State private var fileToDelete: GitignoreFile?

    private let columns = [GridItem(.adaptive(minimum: 160))]

    private var filteredFiles: [GitignoreFile] {
        guard !searchText.isEmpty else { return files }
        return files.filter {
            $0.name.localizedCaseInsensitiveContains(searchText)
                || $0.fileDescription.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns) {
                ForEach(filteredFiles) { file in
                    TemplateCard(
                        title: file.name,
                        subtitle: file.fileDescription.isEmpty ? "\(file.templates.count) templates" : file.fileDescription,
                        onCopy: { copy(file) },
                        onEdit: { fileToEdit = file },
                        onDelete: { fileToDelete = file },
                        color: file.color,
                    )
                }
            }
            .padding()
        }
        .overlay {
            if filteredFiles.isEmpty && !searchText.isEmpty {
                ContentUnavailableView.search(text: searchText)
            }
        }
        .sheet(item: $fileToEdit) { file in
            NewItemView(file: file) { fileToEdit = nil }
        }
        .confirmationDialog(
            "Delete \(fileToDelete?.name ?? "")?",
            isPresented: Binding(get: { fileToDelete != nil }, set: { if !$0 { fileToDelete = nil } }),
            titleVisibility: .visible
        ) {
            Button("Delete", role: .destructive) {
                if let file = fileToDelete { context.delete(file) }
            }
        }
    }

    private func copy(_ file: GitignoreFile) {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(store.combinedContent(for: file.templates), forType: .string)
    }
}

#Preview {
    MyGitignores()
        .modelContainer(for: GitignoreFile.self, inMemory: true)
        .environment(TemplateStore())
}
