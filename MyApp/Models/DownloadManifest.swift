//
//  DownloadManifest.swift
//  My Gitignore
//
//  Created by Gregor Gottschewski on 23.10.26.
//

import Foundation

struct DownloadManifest: Codable {
    let date: Date
    let commit: String
    let templates: [String]
}

func writeDownloadManifest(to url: URL, manifest: DownloadManifest) throws {
    let encoder = JSONEncoder()
    encoder.dateEncodingStrategy = .iso8601
    try encoder.encode(manifest).write(to: url, options: .atomic)
}

func readDownloadManifest(from url: URL) throws -> DownloadManifest {
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .iso8601
    let data = try Data(contentsOf: url)
    return try decoder.decode(DownloadManifest.self, from: data)
}
