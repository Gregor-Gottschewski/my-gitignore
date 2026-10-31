//
//  DownloadTemplatesView.swift
//  My Gitignore
//
//  Created by Gregor Gottschewski on 25.10.26.
//

import SwiftUI

struct DownloadTemplatesView: View {
    @Environment(TemplateStore.self) private var store
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Download templates?")
                .font(.title2)
                .bold()

            Text("The .gitignore templates have not been downloaded yet.")
                .foregroundStyle(.secondary)

            if let error = store.downloadError {
                Text("Download failed: \(error.localizedDescription)")
                    .foregroundStyle(.red)
            }

            HStack {
                if store.isDownloading {
                    ProgressView()
                        .controlSize(.small)
                        .accessibilityLabel("Downloading templates")
                }
                Spacer()
                Button(store.downloadError == nil ? "Download" : "Retry") {
                    Task {
                        await store.download()
                        if store.downloadError == nil { dismiss() }
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(store.isDownloading)
            }
        }
        .padding()
        .frame(width: 360)
        .interactiveDismissDisabled(store.isDownloading)
    }
}

#Preview {
    DownloadTemplatesView()
        .environment(TemplateStore())
}
