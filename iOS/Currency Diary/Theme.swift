import SwiftUI

enum Theme {
    static let accent = Color(red: 0.118, green: 0.541, blue: 0.431)
    static let background = Color(red: 0.031, green: 0.078, blue: 0.067)
    static let card = background.opacity(0.6)
    static let titleFont = Font.system(.largeTitle, design: .rounded).weight(.bold)
    static let headlineFont = Font.system(.headline, design: .rounded)
    static let bodyFont = Font.system(.body, design: .rounded)
}
