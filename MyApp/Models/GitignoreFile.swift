//
//  GitignoreFile.swift
//  My Gitignore
//
//  Created by Gregor Gottschewski on 28.10.26.
//

import Foundation
import SwiftData
import SwiftUI

@Model
class GitignoreFile {
    @Attribute(.unique) var name: String
    var fileDescription: String
    var templates: [String]
    private var red: Double = 0.98
    private var green: Double = 0.9
    private var blue: Double = 0.2
    private var opacity: Double = 1

    /// SwiftData can't persist `Color`, so it is stored as sRGB components.
    var color: Color {
        get { Color(.sRGB, red: red, green: green, blue: blue, opacity: opacity) }
        set {
            let resolved = newValue.resolve(in: EnvironmentValues())
            red = Double(resolved.red)
            green = Double(resolved.green)
            blue = Double(resolved.blue)
            opacity = Double(resolved.opacity)
        }
    }

    init(name: String, fileDescription: String, templates: [String], color: Color) {
        self.name = name
        self.fileDescription = fileDescription
        self.templates = templates
        let resolved = color.resolve(in: EnvironmentValues())
        self.red = Double(resolved.red)
        self.green = Double(resolved.green)
        self.blue = Double(resolved.blue)
        self.opacity = Double(resolved.opacity)
    }

    convenience init(definition: GitignoreDefinition, name: String? = nil) {
        self.init(name: name ?? definition.name, fileDescription: definition.description,
                  templates: definition.templates, color: definition.color.color)
    }

    var definition: GitignoreDefinition {
        GitignoreDefinition(name: name, description: fileDescription, templates: templates,
                            color: RGBColor(red: red, green: green, blue: blue, opacity: opacity))
    }
}
