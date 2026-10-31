import Foundation
import os

enum ExploreCatalog {
    private static let logger = Logger(subsystem: "me.gregorgott.mygitignore", category: "ExploreCatalog")

    static let definitions: [GitignoreDefinition] = {
        guard let url = Bundle.main.url(forResource: "ExploreGitignores", withExtension: "json") else {
            logger.error("ExploreGitignores.json not found in bundle")
            return []
        }
        do {
            return try JSONDecoder().decode([GitignoreDefinition].self, from: Data(contentsOf: url))
        } catch {
            logger.error("Error loading explore catalog: \(error)")
            return []
        }
    }()
}
