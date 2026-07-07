import XCTest
@testable import CurrencyDiary

@MainActor
final class CurrencyDiaryTests: XCTestCase {
    var store: Store!

    override func setUp() {
        super.setUp()
        store = Store()
    }

    func testSeedDataBelowFreeLimit() {
        XCTAssertLessThan(store.entries.count, Store.freeLimit)
    }

    func testAddEntryIncreasesCount() {
        let before = store.entries.count
        store.add(Entry(fromCurrency: "Test", toCurrency: "Test2", rate: 1, fee: 2))
        XCTAssertEqual(store.entries.count, before + 1)
    }

    func testCanAddMoreWhenBelowLimit() {
        XCTAssertTrue(store.canAddMore)
    }

    func testCannotAddMoreAtLimit() {
        while store.entries.count < Store.freeLimit {
            store.add(Entry(fromCurrency: "X", toCurrency: "Y", rate: 1, fee: 1))
        }
        XCTAssertFalse(store.canAddMore)
    }

    func testDeleteEntryRemovesIt() {
        let entry = Entry(fromCurrency: "Del", toCurrency: "Me", rate: 1, fee: 1)
        store.add(entry)
        store.delete(entry)
        XCTAssertFalse(store.entries.contains(where: { $0.id == entry.id }))
    }

    func testUpdateEntryChangesFields() {
        var entry = Entry(fromCurrency: "Old", toCurrency: "Old2", rate: 1, fee: 1)
        store.add(entry)
        entry.fromCurrency = "New"
        store.update(entry)
        XCTAssertEqual(store.entries.first(where: { $0.id == entry.id })?.fromCurrency, "New")
    }

    func testDeleteAtOffsets() {
        store.add(Entry(fromCurrency: "A", toCurrency: "B", rate: 1, fee: 1))
        let before = store.entries.count
        store.delete(at: IndexSet(integer: 0))
        XCTAssertEqual(store.entries.count, before - 1)
    }
}
