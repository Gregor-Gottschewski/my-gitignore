//
//  Settings.swift
//  My Gitignore
//
//  Created by Gregor Gottschewski on 26.10.26.
//

import SwiftUI
import os

enum AppLinks {
    static let privacyPolicy = URL(string: "https://github.com/Gregor-Gottschewski/my-gitignore/blob/main/PRIVACY.md")!
    static let github = URL(string: "https://github.com/Gregor-Gottschewski/my-gitignore/")!
}

struct SettingsView: View {
    private let logger: Logger = Logger.init(subsystem: "me.gregorgott.mygitignore", category: "SettingsView")
    @Environment(TemplateStore.self) private var store
    @State private var showClearCacheErrorAlert = false
    @State private var showClearCacheConfirmation = false
    @State private var dataCleared = false

    var body: some View {
        Form {
            Section {
                Button("Delete all cached data", role: .destructive) {
                    showClearCacheConfirmation = true
                }
                .confirmationDialog("Delete all cached data question", isPresented: $showClearCacheConfirmation) {
                    Button("Delete", role: .destructive) {
                        if deleteData() {
                            dataCleared = true
                        } else {
                            showClearCacheErrorAlert = true
                        }
                    }
                    Button("Cancel", role: .cancel) { }
                } message: {
                    Text("The templates will have to be downloaded again.")
                }
                .alert("Error deleting files", isPresented: $showClearCacheErrorAlert) {
                    Button("OK", role: .confirm) { }
                } message: {
                    Text("Cached files couldn't be deleted.")
                }
            } footer: {
                Text("Deletes all stored templates and cached data.")
            }

            Section("About") {
                Link("Privacy Policy", destination: AppLinks.privacyPolicy)
                Link("Project on GitHub", destination: AppLinks.github)
            }

            Section("Licenses") {
                DisclosureGroup("github/gitignore") {
                    Text("""
                    The gitignore templates are provided by the github/gitignore project and released under CC0 1.0 Universal (public domain dedication).

                    https://github.com/github/gitignore
                    """)
                    .textSelection(.enabled)
                }
                DisclosureGroup("ZIPFoundation") {
                    Text("""
                    MIT License

                    Copyright (c) 2017-2026 Thomas Zoechling (https://www.peakstep.com)

                    Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

                    The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

                    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
                    """)
                    .font(.caption)
                    .textSelection(.enabled)
                }
                Text("Not affiliated with or endorsed by GitHub, Inc.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .formStyle(.grouped)
        .sheet(isPresented: $dataCleared) {
            DownloadTemplatesView()
        }
    }

    private func deleteData() -> Bool {
        do {
            try store.deleteStoredTemplates()
            return true
        } catch {
            logger.error("Error deleting all cached data: \(error)")
            return false
        }
    }
}

#Preview {
    SettingsView()
        .environment(TemplateStore())
}
