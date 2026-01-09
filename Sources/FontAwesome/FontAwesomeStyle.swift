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
        case .solid: return "Font Awesome 7 Free-Solid-900"
        case .light: return "Font Awesome Light"
        case .regular: return "Font Awesome 7 Brands-Regular-400"
        case .brands: return "Font Awesome Brands"
        }
    }

    func fontFilename() -> String {
        switch self {
        case .solid: return "Font Awesome 7 Free-Solid-900.otf"
        case .light: return "Font Awesome Light.otf"
        case .regular: return "Font Awesome 7 Brands-Regular-400.otf"
        case .brands: return "Font Awesome Brands.otf"
        }
    }

    func fontFamilyName() -> String {
        switch self {
        case .brands: return "Font Awesome Brands"
        default: return "Font Awesome"
        }
    }
}