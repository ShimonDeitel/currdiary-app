import Foundation

struct Entry: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var fromCurrency: String
    var toCurrency: String
    var rate: Double
    var fee: Double
    var date: Date = Date()
    var notes: String = ""
}
