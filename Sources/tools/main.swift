#!/usr/bin/swift

import Foundation

// MARK: - Typealiases

typealias Icons = [String: Icon]

// MARK: - Data Models

struct Icon: Codable {
    let changes: [String]?
    let styles: [String]
    let unicode: String
    let label: String
    let svg: [String: SVG]?
}

struct SVG: Codable {
    let raw: String
    let viewBox: [Double]        // FA7 uses numeric array now
    let width: UInt
    let height: UInt
    let path: Path
}

struct Path: Codable {
    let path: String
    let duotonePath: [String]

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        if let s = try? container.decode(String.self) {
            path = s
            duotonePath = []
        } else if let arr = try? container.decode([String].self) {
            duotonePath = arr
            path = ""
        } else {
            path = ""
            duotonePath = []
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try duotonePath.isEmpty ? container.encode(path) : container.encode(duotonePath)
    }
}

// MARK: - String Helpers

extension String {
    func camelCased(with separator: Character) -> String {
        return split(separator: separator).reduce("") { result, element in
            "\(result)\(result.count > 0 ? String(element.capitalized) : String(element))"
        }
    }

    func filteredKeywords() -> String {
        if self == "500px" { return "fiveHundredPixels" }
        if self == "subscript" { return "`subscript`" }
        return self
    }
}

// MARK: - Load JSON

guard let jsonData = FileManager.default.contents(atPath: "FortAwesome/Font-Awesome/metadata/icons.json") else {
    fatalError("Could not find JSON metadata file")
}

let icons = try JSONDecoder().decode(Icons.self, from: jsonData)

// MARK: - Generate Enum.swift

var fontAwesomeEnum = """
// Enum.swift
//
// Auto-generated from Font Awesome metadata.
// Do not edit manually.

public enum FontAwesome: String, CaseIterable {

"""

let sortedKeys = icons.keys.sorted()

for key in sortedKeys {
    guard let value = icons[key] else { continue }
    let enumKeyName = key.filteredKeywords().camelCased(with: "-")
    fontAwesomeEnum += "    case \(enumKeyName) = \"fa-\(key)\"\n"
}

fontAwesomeEnum += """

    /// Unicode of the icon
    public var unicode: String {
        switch self {
"""

for key in sortedKeys {
    guard let value = icons[key] else { continue }
    let enumKeyName = key.filteredKeywords().camelCased(with: "-")
    fontAwesomeEnum += "        case .\(enumKeyName): return \"\\u{\(value.unicode)}\"\n"
}

fontAwesomeEnum += """
        default: return ""
    }
    
    /// Supported styles of each icon
    public var supportedStyles: [FontAwesomeStyle] {
        switch self {
"""

for key in sortedKeys {
    guard let value = icons[key] else { continue }
    let enumKeyName = key.filteredKeywords().camelCased(with: "-")
    fontAwesomeEnum += "        case .\(enumKeyName): return [.\(value.styles.joined(separator: ", ."))]\n"
}

fontAwesomeEnum += """
        default: return []
    }
}

public enum FontAwesomeBrands: String {
"""

let brands = icons.filter { $0.value.styles.contains("brands") }
let sortedBrandKeys = brands.keys.sorted()

for key in sortedBrandKeys {
    let enumKeyName = key.filteredKeywords().camelCased(with: "-")
    fontAwesomeEnum += "    case \(enumKeyName) = \"fa-\(key)\"\n"
}

fontAwesomeEnum += """

    public var unicode: String {
        switch self {
"""

for key in sortedBrandKeys {
    guard let value = brands[key] else { continue }
    let enumKeyName = key.filteredKeywords().camelCased(with: "-")
    fontAwesomeEnum += "        case .\(enumKeyName): return \"\\u{\(value.unicode)}\"\n"
}

fontAwesomeEnum += """
        default: return ""
    }
}
"""

// MARK: - Write file

let outputPath = "FontAwesome/Enum.swift"
FileManager.default.createFile(
    atPath: outputPath,
    contents: fontAwesomeEnum.data(using: .utf8),
    attributes: nil
)

print("Enum.swift generated successfully at \(outputPath)")
