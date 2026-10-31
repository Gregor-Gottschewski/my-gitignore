import SwiftUI
import SwiftData
import AppKit

struct ContentView: View {
    @State private var selection: SidebarItem? = .favourites
    @State private var searchText = ""
    @State private var isCreating = false
    @State private var showDownloadPrompt = false
    @State private var copiedFileName: String?
    @Environment(TemplateStore.self) private var store;
    @Query(sort: \GitignoreFile.name) private var files: [GitignoreFile]

    private var matchingFiles: [GitignoreFile] {
        guard !searchText.isEmpty else { return [] }
        return files.filter {
            $0.name.localizedCaseInsensitiveContains(searchText)
                || $0.fileDescription.localizedCaseInsensitiveContains(searchText)
        }
    }

    private func copy(_ file: GitignoreFile) {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(store.combinedContent(for: file.templates), forType: .string)
        copiedFileName = file.name
        Task {
            try? await Task.sleep(for: .seconds(2))
            if copiedFileName == file.name { copiedFileName = nil }
        }
    }

    var body: some View {
        NavigationSplitView {
            List(SidebarItem.allCases, selection: $selection) { item in
                Label(item.title, systemImage: item.systemImage)
            }
            .navigationSplitViewColumnWidth(min: 150, ideal: 200)
        } detail: {
            if selection == .explore {
                ExploreView()
            } else if selection == .settings {
                SettingsView()
            } else if selection == .favourites {
                MyGitignores(searchText: searchText)
            } else {
                Text("Nothing selected")
            }
        }
        .searchable(text: $searchText) {
            if selection != .favourites {
                ForEach(matchingFiles.prefix(8)) { file in
                    HStack {
                        Text(file.name)
                        Spacer()
                        Button("Copy", systemImage: copiedFileName == file.name ? "checkmark" : "doc.on.doc") { copy(file) }
                            .labelStyle(.iconOnly)
                            .buttonStyle(.borderless)
                            .frame(width: 20, height: 20)
                            .contentTransition(.symbolEffect(.replace))
                            .animation(.default, value: copiedFileName)
                            .accessibilityLabel(copiedFileName == file.name ? "Copied" : "Copy .gitignore")
                    }
                    .searchCompletion(file.name)
                }
            }
        }
        .onSubmit(of: .search) {
            selection = .favourites
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("New Item", systemImage: "plus") {
                    isCreating = true
                }
            }
        }
        .sheet(isPresented: $showDownloadPrompt) {
            DownloadTemplatesView()
        }
        .sheet(isPresented: $isCreating) {
            NewItemView { isCreating = false }
        }
        .task {
            showDownloadPrompt = !store.templatesExists()
            while !Task.isCancelled {
                await store.updateIfNeeded()
                try? await Task.sleep(for: .seconds(3600))
            }
        }
    }
}

#Preview {
    ContentView()
}
