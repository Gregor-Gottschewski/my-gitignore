//
//  TemplateStore.swift
//  My Gitignore
//
//  Created by Gregor Gottschewski on 23.10.26.
//

import os
import Foundation
import ZIPFoundation

@Observable
final class TemplateStore {
    var isDownloading = false
    var downloadError: Error?
    
    private let logger = Logger(subsystem: "me.gregorgott.mygitignore", category: "TemplateStore")
    private let directory: URL
    private let tempDirectory: URL
    private let templateDirectory: String = "gitignore-templates"
    private let downloadDirectory: String = "download"
    private let url: URL = URL(string: "https://github.com/github/gitignore/archive/refs/heads/main.zip")!
    private let commitURL: URL = URL(string: "https://api.github.com/repos/github/gitignore/commits/main")!
    private let zipName: String = "download.zip"
    private let manifestName: String = "manifest.json"
    private let lastCheckKey: String = "templatesLastChecked"
    private let checkInterval: TimeInterval = 24 * 60 * 60
    
    init() {
        let base: URL = URL.applicationSupportDirectory
        directory = base.appending(path: templateDirectory, directoryHint: .isDirectory)
        tempDirectory = base.appending(path: downloadDirectory, directoryHint: .isDirectory)
    }
    
    func templatesExists() -> Bool {
        return FileManager.default.fileExists(
            atPath: directory.appending(path: manifestName).path(percentEncoded: false))
    }
    
    func download() async {
        isDownloading = true
        downloadError = nil
        do {
            try await downloadFile(from: url)
            lastChecked = .now
        } catch {
            downloadError = error
        }
        isDownloading = false
    }

    /// Silently checks for new upstream commits at most once per `checkInterval`.
    func updateIfNeeded() async {
        guard templatesExists(), !isDownloading else { return }
        if let lastChecked, Date.now.timeIntervalSince(lastChecked) < checkInterval { return }

        isDownloading = true
        defer { isDownloading = false }
        do {
            try await downloadFile(from: url)
            lastChecked = .now
        } catch {
            logger.error("Update check failed: \(error)")
        }
    }

    private var lastChecked: Date? {
        get { UserDefaults.standard.object(forKey: lastCheckKey) as? Date }
        set { UserDefaults.standard.set(newValue, forKey: lastCheckKey) }
    }
    
    func getManifest() throws -> DownloadManifest? {
        if (!templatesExists()) { return nil }
        return try readDownloadManifest(from: directory.appending(path: manifestName))
    }
    
    func deleteStoredTemplates() throws {
        let fm: FileManager = FileManager.default
        try fm.removeItem(at: directory)
    }
    
    func getTemplates() -> [String] {
        let manifest: DownloadManifest?
        
        do {
            manifest = try getManifest()
        } catch {
            logger.error("Error loading manifest: \(error)")
            return []
        }
        
        return manifest?.templates ?? []
    }
    
    func getTemplateContent(from name: String) throws -> (String, String) {
        let manifest: DownloadManifest? = try getManifest()
        if (manifest == nil) { return (name, "") }
        
        if (!manifest!.templates.contains(name)) { return (name, "") }
        
        let path: URL = directory.appending(path: name)
        
        let fm: FileManager = FileManager()
        if (!fm.fileExists(atPath: path.path(percentEncoded: false))) {
            logger.error("Cannot find file \(path.path())")
            return (name, "")
        }
        
        let content: String = try String(contentsOf: path, encoding: .utf8)
        
        return (name, content)
    }
    
    /// Concatenates the given templates into one gitignore, each preceded by a `# name` header.
    func combinedContent(for templates: [String]) -> String {
        templates.compactMap { template in
            do {
                let (name, content) = try getTemplateContent(from: template)
                return "# \(name)\n\(content)"
            } catch {
                logger.error("Error reading template \(template): \(error)")
                return nil
            }
        }.joined(separator: "\n\n")
    }

    private func fetchLatestCommit() async throws -> String {
        var request = URLRequest(url: commitURL)
        request.setValue("application/vnd.github.sha", forHTTPHeaderField: "Accept")
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let http = response as? HTTPURLResponse,
              (200..<300).contains(http.statusCode),
              let commit = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines),
              !commit.isEmpty else {
            throw URLError(.badServerResponse)
        }
        return commit
    }
    
    private func downloadFile(from url: URL) async throws {
        let commit: String = try await fetchLatestCommit()
        if let manifest = try? getManifest(), manifest.commit == commit { return }
        
        let (tempURL, response) = try await URLSession.shared.download(from: url)
        
        guard let http = response as? HTTPURLResponse,
              (200..<300).contains(http.statusCode) else {
            throw URLError(.badServerResponse)
        }
        
        let fm: FileManager = FileManager.default
        try fm.createDirectory(at: tempDirectory, withIntermediateDirectories: true)
        let zipURL: URL = tempDirectory.appending(path: zipName)
        try? fm.removeItem(at: zipURL)
        try fm.moveItem(at: tempURL, to: zipURL)

        let files: [String] = try unzipDownload(zipURL: zipURL)
        try fm.removeItem(at: tempDirectory)
        try writeDownloadManifest(to: directory.appending(path: manifestName), manifest: DownloadManifest(date: .now, commit: commit, templates: files))
    }

    private func unzipDownload(zipURL: URL) throws -> [String] {
        let fm: FileManager = FileManager.default
        let extracted: URL = tempDirectory.appending(path: "extracted", directoryHint: .isDirectory)
        try? fm.removeItem(at: extracted)
        try fm.unzipItem(at: zipURL, to: extracted)

        try? fm.removeItem(at: directory)
        try fm.createDirectory(at: directory, withIntermediateDirectories: true)

        guard let enumerator = fm.enumerator(at: extracted, includingPropertiesForKeys: nil) else { return [] }

        let templates: [URL] = enumerator
            .compactMap { $0 as? URL }
            .filter { $0.lastPathComponent.hasSuffix(".gitignore") && $0.lastPathComponent != ".gitignore" }
            .sorted { ($0.pathComponents.count, $0.path) < ($1.pathComponents.count, $1.path) }

        var seen: Set<String> = []
        for template in templates {
            let name: String = template.deletingPathExtension().lastPathComponent.lowercased()
            guard seen.insert(name.lowercased()).inserted else { continue }
            try fm.moveItem(at: template, to: directory.appending(path: name))
        }
        
        return Array(seen)
    }

}
