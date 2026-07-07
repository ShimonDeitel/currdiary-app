import SwiftUI

struct ContentView: View {
    @EnvironmentObject var store: Store
    @EnvironmentObject var purchases: PurchaseManager
    @State private var showAddSheet = false
    @State private var showSettings = false
    @State private var showPaywall = false
    @State private var editingEntry: Entry?

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.background.ignoresSafeArea()
                List {
                    ForEach(store.entries) { entry in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(entry.fromCurrency).font(Theme.headlineFont)
                            Text(entry.toCurrency).font(Theme.bodyFont).foregroundColor(.secondary)
                            HStack {
                                Text("\(entry.rate, specifier: \"%.1f\") rate")
                                Spacer()
                                Text("\(entry.fee, specifier: \"%.1f\")")
                            }
                            .font(.caption)
                            .foregroundColor(Theme.accent)
                        }
                        .padding(.vertical, 4)
                        .listRowBackground(Theme.card)
                        .contentShape(Rectangle())
                        .onTapGesture { editingEntry = entry }
                    }
                    .onDelete { offsets in
                        store.delete(at: offsets)
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Currency Diary")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { showSettings = true }) {
                        Image(systemName: "gearshape.fill")
                    }
                    .accessibilityIdentifier("settingsButton")
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        if store.canAddMore || purchases.isPro {
                            showAddSheet = true
                        } else {
                            showPaywall = true
                        }
                    }) {
                        Image(systemName: "plus.circle.fill")
                    }
                    .accessibilityIdentifier("addEntryButton")
                }
            }
            .sheet(isPresented: $showAddSheet) {
                EntryFormView(entry: nil) { newEntry in
                    store.add(newEntry)
                }
            }
            .sheet(item: $editingEntry) { entry in
                EntryFormView(entry: entry) { updated in
                    store.update(updated)
                }
            }
            .sheet(isPresented: $showSettings) {
                SettingsView()
            }
            .sheet(isPresented: $showPaywall) {
                PaywallView()
            }
        }
    }
}

struct EntryFormView: View {
    @Environment(\.dismiss) var dismiss
    @State private var fromCurrency: String
    @State private var toCurrency: String
    @State private var rateText: String
    @State private var feeText: String
    @State private var notes: String
    @FocusState private var focusedField: Field?
    private let originalID: UUID
    private let onSave: (Entry) -> Void

    enum Field { case f1, f2, n1, n2, notes }

    init(entry: Entry?, onSave: @escaping (Entry) -> Void) {
        _fromCurrency = State(initialValue: entry?.fromCurrency ?? "")
        _toCurrency = State(initialValue: entry?.toCurrency ?? "")
        _rateText = State(initialValue: entry != nil ? String(entry!.rate) : "")
        _feeText = State(initialValue: entry != nil ? String(entry!.fee) : "")
        _notes = State(initialValue: entry?.notes ?? "")
        originalID = entry?.id ?? UUID()
        self.onSave = onSave
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("fromCurrency") {
                    TextField("fromCurrency", text: $fromCurrency)
                        .focused($focusedField, equals: .f1)
                        .accessibilityIdentifier("field_fromCurrency")
                }
                Section("toCurrency") {
                    TextField("toCurrency", text: $toCurrency)
                        .focused($focusedField, equals: .f2)
                        .accessibilityIdentifier("field_toCurrency")
                }
                Section("Details") {
                    TextField("rate", text: $rateText)
                        .keyboardType(.decimalPad)
                        .focused($focusedField, equals: .n1)
                        .accessibilityIdentifier("field_rate")
                    TextField("fee", text: $feeText)
                        .keyboardType(.decimalPad)
                        .focused($focusedField, equals: .n2)
                        .accessibilityIdentifier("field_fee")
                    TextField("Notes", text: $notes)
                        .focused($focusedField, equals: .notes)
                        .accessibilityIdentifier("field_notes")
                }
            }
            .contentShape(Rectangle())
            .onTapGesture {
                focusedField = nil
            }
            .navigationTitle(originalID == UUID() ? "New Entry" : "Edit Entry")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .accessibilityIdentifier("formCancelButton")
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let entry = Entry(
                            id: originalID,
                            fromCurrency: fromCurrency,
                            toCurrency: toCurrency,
                            rate: Double(rateText) ?? 0,
                            fee: Double(feeText) ?? 0,
                            notes: notes
                        )
                        onSave(entry)
                        dismiss()
                    }
                    .accessibilityIdentifier("formSaveButton")
                    .disabled(fromCurrency.isEmpty)
                }
            }
        }
    }
}
