//
//  Settings.swift
//  My Gitignore
//
//  Created by Gregor Gottschewski on 26.10.26.
//

import SwiftUI
import os

struct SettingsView: View {
    private let logger: Logger = Logger.init(subsystem: "me.gregorgott.mygitignore", category: "SettingsView")
    @State private var showClearChacheErrorAlert = false
    
    var body: some View {
        Form {
            Section {
                Button("Delete all cached data", role: .destructive) {
                    if (!deleteData()) { showClearChacheErrorAlert = true }
                } .alert("Error deleting files", isPresented: $showClearChacheErrorAlert) {
                    Button ("OK", role: .confirm) { }
                } message: {
                    Text("Cached files couldn't be deleted.")
                }
            } footer: {
                Text("Deletes all stored templates and cached data.")
            }
        }
        .formStyle(.grouped)
    }
    
    private func deleteData() -> Bool {
        do {
            try TemplateStore().deleteStoredTemplates()
            return true
        } catch {
            logger.error("Error deleting all cached data: \(error)")
            return false
        }
    }
}

#Preview {
    SettingsView()
}
