//
//  TemplateCard.swift
//  My Gitignore
//
//  Created by Gregor Gottschewski on 26.10.26.
//

import SwiftUI
import AppKit

struct TemplateCard: View {
    let title: String
    var subtitle: String? = nil
    var onCopy: (() -> Void)? = nil
    var onAdd: (() -> Void)? = nil
    var onEdit: (() -> Void)? = nil
    var onDelete: (() -> Void)? = nil
    var color: Color? = nil

    @State private var didCopy = false
    @State private var didAdd = false

    private var baseColor: Color {
        if let color { return color }
        return Color.blue
    }
    
    /// White text, switching to black only on very light cards (WCAG relative luminance of the gradient).
    private var contentColor: Color {
        let average = baseColor.mix(with: .white, by: 0.125)
        guard let rgb = NSColor(average).usingColorSpace(.sRGB) else { return .white }
        func linear(_ c: CGFloat) -> Double {
            let v = Double(c)
            return v <= 0.03928 ? v / 12.92 : pow((v + 0.055) / 1.055, 2.4)
        }
        let luminance = 0.2126 * linear(rgb.redComponent)
            + 0.7152 * linear(rgb.greenComponent)
            + 0.0722 * linear(rgb.blueComponent)
        // Strictly "best contrast" would switch to black at ~0.18, which looks
        // too early on saturated mid-tones. Stay with white until the colour is really light.
        let blackTextThreshold = 0.5
        return luminance > blackTextThreshold ? .black : .white
    }

    private var hasMenu: Bool { onEdit != nil || onDelete != nil }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(alignment: .top) {
                Text(title)
                    .font(.headline)
                    .lineLimit(2)
                Spacer(minLength: 0)
                if hasMenu { menu }
                if onAdd != nil { addButton }
            }
            if let subtitle {
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(contentColor.opacity(0.8))
                    .lineLimit(2)
            }
            Spacer(minLength: 0)
            if onCopy != nil {
                HStack {
                    Spacer()
                    copyButton
                }
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .aspectRatio(1, contentMode: .fit)
        .foregroundStyle(contentColor)
        .background(
            LinearGradient(
                colors: [baseColor.mix(with: .white, by: 0.25), baseColor],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ),
            in: RoundedRectangle(cornerRadius: 20, style: .continuous)
        )
        .shadow(color: baseColor.opacity(0.35), radius: 6, y: 2)
        .accessibilityElement(children: .contain)
        .accessibilityLabel(subtitle.map { "\(title), \($0)" } ?? title)
    }

    private var menu: some View {
        Menu {
            if let onEdit {
                Button("Edit", action: onEdit)
            }
            if let onDelete {
                Button("Delete", role: .destructive, action: onDelete)
            }
        } label: {
            Image(systemName: "ellipsis")
                .foregroundStyle(contentColor)
                .frame(width: 20, height: 20)
                .contentShape(Rectangle())
        }
        // .borderlessButton is backed by AppKit and ignores foregroundStyle.
        .menuStyle(.button)
        .buttonStyle(.plain)
        .menuIndicator(.hidden)
        .fixedSize()
        .accessibilityLabel("More actions")
    }

    private var addButton: some View {
        Button {
            onAdd?()
            didAdd = true
            Task {
                try? await Task.sleep(for: .seconds(1.5))
                didAdd = false
            }
        } label: {
            Image(systemName: didAdd ? "checkmark" : "plus")
                .frame(width: 20, height: 20)
                .contentTransition(.symbolEffect(.replace))
        }
        .buttonStyle(.borderless)
        .help("Add to My Gitignores")
        .accessibilityLabel(didAdd ? "Added to My Gitignores" : "Add to My Gitignores")
    }

    private var copyButton: some View {
        Button {
            onCopy?()
            didCopy = true
            Task {
                try? await Task.sleep(for: .seconds(1.5))
                didCopy = false
            }
        } label: {
            Image(systemName: didCopy ? "checkmark" : "document.on.document")
                .frame(width: 20, height: 20)
                .contentTransition(.symbolEffect(.replace))
        }
        .buttonBorderShape(.roundedRectangle(radius: 6))
        .help("Copy .gitignore")
        .accessibilityLabel(didCopy ? "Copied" : "Copy .gitignore")
    }
}

#Preview {
    TemplateCard(title: "Test", subtitle: "3 templates", onCopy: {}, onEdit: {}, onDelete: {})
        .frame(width: 180)
        .padding()
}
