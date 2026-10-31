import Foundation

enum SidebarItem: String, CaseIterable, Identifiable {
    case favourites, explore, settings

    var id: Self { self }
    
    var title: String {
        switch self {
        case .favourites: "My Gitignores"
        case .explore: "Explore"
        case .settings: "Settings"
        }
    }

    var systemImage: String {
        switch self {
        case .favourites: "person"
        case .explore: "safari"
        case .settings: "gear"
        }
    }
}
