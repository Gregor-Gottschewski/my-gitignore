import SwiftUI

struct RGBColor: Codable {
    var red: Double
    var green: Double
    var blue: Double
    var opacity: Double = 1

    var color: Color {
        Color(.sRGB, red: red, green: green, blue: blue, opacity: opacity)
    }

    init(red: Double, green: Double, blue: Double, opacity: Double = 1) {
        self.red = red
        self.green = green
        self.blue = blue
        self.opacity = opacity
    }

    init(_ color: Color) {
        let resolved = color.resolve(in: EnvironmentValues())
        red = Double(resolved.red)
        green = Double(resolved.green)
        blue = Double(resolved.blue)
        opacity = Double(resolved.opacity)
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        red = try container.decode(Double.self, forKey: .red)
        green = try container.decode(Double.self, forKey: .green)
        blue = try container.decode(Double.self, forKey: .blue)
        opacity = try container.decodeIfPresent(Double.self, forKey: .opacity) ?? 1
    }
}

/// Plain description of a gitignore, shared by the bundled Explore catalog and user-created `GitignoreFile`s.
struct GitignoreDefinition: Codable, Identifiable {
    var name: String
    var description: String
    var templates: [String]
    var color: RGBColor

    var id: String { name }
}
