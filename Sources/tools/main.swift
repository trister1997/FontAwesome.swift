#!/usr/bin/swift

import Foundation

// MARK: - Paths
let otfDir = "FortAwesome/Font-Awesome/otfs"
let enumPath = "Sources/FontAwesome/Enum.swift"
let fasPath = "Sources/FontAwesome/FontAwesomeStyle.swift"

// MARK: - Scan OTF files
let fileManager = FileManager.default
guard let otfFiles = try? fileManager.contentsOfDirectory(atPath: otfDir) else {
    fatalError("Could not read directory at \(otfDir)")
}

var fontNames: [String: String] = [:] // style -> fontName
var fileNames: [String: String] = [:] // style -> fileName

for file in otfFiles {
    guard file.hasSuffix(".otf") else { continue }
    let name = file.replacingOccurrences(of: ".otf", with: "")
    
    let lower = name.lowercased()
    if lower.contains("solid") {
        fontNames["solid"] = name
        fileNames["solid"] = file
    } else if lower.contains("light") {
        fontNames["light"] = name
        fileNames["light"] = file
    } else if lower.contains("regular") {
        fontNames["regular"] = name
        fileNames["regular"] = file
    } else if lower.contains("brands") {
        fontNames["brands"] = name
        fileNames["brands"] = file
    }
}

// MARK: - Generate FontAwesome.swift
var fontAwesomeSwift = """
// FontAwesome.swift
//
// Auto-generated from Font Awesome directory.
// Do not edit manually.

import UIKit
import CoreText

public struct FontAwesomeConfig {
    private init() { }
    public static let fontAspectRatio: CGFloat = 1.28571429
    public static var usesProFonts: Bool = false
}

public enum FontAwesomeStyle: String {
    case solid
    case light
    case regular
    case brands

    func fontName() -> String {
        switch self {
        case .solid: return "\(fontNames["solid"] ?? "Font Awesome Solid")"
        case .light: return "\(fontNames["light"] ?? "Font Awesome Light")"
        case .regular: return "\(fontNames["regular"] ?? "Font Awesome Regular")"
        case .brands: return "\(fontNames["brands"] ?? "Font Awesome Brands")"
        }
    }

    func fontFilename() -> String {
        switch self {
        case .solid: return "\(fileNames["solid"] ?? "Font Awesome Solid.otf")"
        case .light: return "\(fileNames["light"] ?? "Font Awesome Light.otf")"
        case .regular: return "\(fileNames["regular"] ?? "Font Awesome Regular.otf")"
        case .brands: return "\(fileNames["brands"] ?? "Font Awesome Brands.otf")"
        }
    }

    func fontFamilyName() -> String {
        switch self {
        case .brands: return "\(fontNames["brands"] ?? "Font Awesome Brands")"
        default: return "Font Awesome"
        }
    }
}
"""

// MARK: - Write FontAwesome.swift
fileManager.createFile(atPath: fasPath,
                       contents: fontAwesomeSwift.data(using: .utf8),
                       attributes: nil)

print("FontAwesome.swift updated successfully at \(fasPath)")
