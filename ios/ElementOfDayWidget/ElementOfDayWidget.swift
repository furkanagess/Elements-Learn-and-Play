//
//  ElementOfDayWidget.swift
//  ElementOfDayWidget
//
//  Created by furkan çağlar on 14.09.2025.
//

import WidgetKit
import SwiftUI

// MARK: - Model
struct ElementEntry: TimelineEntry {
    let date: Date
    let symbol: String
    let name: String
    let number: String
    let category: String
    let atomicWeight: String?
}

// MARK: - Provider
struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> ElementEntry {
        ElementEntry(date: Date(), symbol: "Au", name: "Gold", number: "79", category: localizedCategory("transition metal"), atomicWeight: "196.97")
    }

    func getSnapshot(in context: Context, completion: @escaping (ElementEntry) -> Void) {
        completion(loadEntry())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<ElementEntry>) -> Void) {
        let entry = loadEntry()
        // Refresh in 1 hour by default
        let next = Calendar.current.date(byAdding: .hour, value: 1, to: Date()) ?? Date().addingTimeInterval(3600)
        completion(Timeline(entries: [entry], policy: .after(next)))
    }

    private func loadEntry() -> ElementEntry {
        // Read from HomeWidget shared UserDefaults (App Group)
        let defaults = UserDefaults(suiteName: "group.com.furkanages.elements")
        let symbol = defaults?.string(forKey: "symbol") ?? "?"
        let enName = defaults?.string(forKey: "enName") ?? "Element"
        let trName = defaults?.string(forKey: "trName") ?? enName
        let number = defaults?.string(forKey: "number") ?? "-"
        let categoryRaw = defaults?.string(forKey: "category")
        let atomicWeight = defaults?.string(forKey: "atomicWeight")

        let name = Locale.current.language.languageCode?.identifier == "tr" ? trName : enName
        let category = localizedCategory(categoryRaw)

        return ElementEntry(date: Date(), symbol: symbol, name: name, number: number, category: category, atomicWeight: atomicWeight)
    }
}

// MARK: - Localization helpers
func localizedCategory(_ raw: String?) -> String {
    guard let raw = raw else { return "" }
    let lower = raw.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
    if Locale.current.language.languageCode?.identifier != "tr" { return raw.capitalized }
    switch lower {
    case "alkali metal": return "Alkali Metal"
    case "alkaline earth metal": return "Toprak Alkali Metal"
    case "transition metal": return "Geçiş Metalleri"
    case "post-transition metal": return "Zayıf Metaller"
    case "metalloid": return "Yarı Metal"
    case "reactive nonmetal": return "Reaktif Ametal"
    case "noble gas": return "Soygaz"
    case "halogen": return "Halojen"
    case "lanthanide": return "Lantanit"
    case "actinide": return "Aktinit"
    default: return raw
    }
}

// MARK: - UI
struct ElementOfDayWidgetEntryView: View {
    var entry: Provider.Entry

    var body: some View {
        ZStack {
            // Background card + atom pattern
            RoundedRectangle(cornerRadius: 14)
                .fill(Color(hex: 0x262638))
            AtomPattern()

            VStack(spacing: 4) {
                // Header: pill title + date
                HStack {
                    Text(LocalizedStringKey("widget_title_element_of_day"))
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(
                            RoundedRectangle(cornerRadius: 12).fill(Color.white.opacity(0.2))
                        )
                    Spacer()
                    Text(Date.now, style: .date)
                        .font(.system(size: 10))
                        .foregroundColor(.white)
                }

                HStack(spacing: 8) {
                    // Left square
                    ZStack {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.white.opacity(0.13))
                        VStack(spacing: 1) {
                            Text(entry.number)
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(.white)
                            Text(entry.symbol)
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.white)
                        }
                        .padding(4)
                    }
                    .frame(width: 40)

                    // Middle info
                    VStack(alignment: .leading, spacing: 1) {
                        Text(entry.name)
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                            .lineLimit(1)
                        Text(entry.category)
                            .font(.system(size: 11))
                            .foregroundColor(.white)
                            .lineLimit(1)
                        if let aw = entry.atomicWeight, !aw.isEmpty {
                            Text(String(format: NSLocalizedString("widget_atomic_weight", comment: ""), aw))
                                .font(.system(size: 10))
                                .foregroundColor(.white)
                                .lineLimit(1)
                        }
                    }
                    Spacer(minLength: 6)
                    // Right arrow pill
                    Text(">")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white)
                        .frame(width: 24, height: 24)
                        .background(RoundedRectangle(cornerRadius: 12).fill(Color.white.opacity(0.2)))
                }
                .padding(.top, 4)
            }
            .padding(10)
        }
    }
}

// Background atom orbits
struct AtomPattern: View {
    var body: some View {
        ZStack {
            Circle().stroke(Color.white.opacity(0.1), lineWidth: 1).frame(width: 160, height: 160)
            Circle().stroke(Color.white.opacity(0.1), lineWidth: 1).frame(width: 130, height: 130)
            Circle().stroke(Color.white.opacity(0.1), lineWidth: 1).frame(width: 100, height: 100)
            Circle().fill(Color.white.opacity(0.06)).frame(width: 70, height: 70).offset(x: 120, y: -50)
            Circle().fill(Color.white.opacity(0.06)).frame(width: 80, height: 80).offset(x: -120, y: 36)
        }
    }
}

// MARK: - Widget
struct ElementOfDayWidget: Widget {
    let kind: String = "ElementOfDayWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            ElementOfDayWidgetEntryView(entry: entry)
        }
        .supportedFamilies([.systemMedium])
        .configurationDisplayName("Element of the Day")
        .description("Shows a featured periodic element")
    }
}

// MARK: - Utils
extension Color {
    init(hex: UInt32) {
        let r = Double((hex >> 16) & 0xFF)/255.0
        let g = Double((hex >> 8) & 0xFF)/255.0
        let b = Double(hex & 0xFF)/255.0
        self = Color(red: r, green: g, blue: b)
    }
}

#if DEBUG
#Preview("Medium", as: .systemMedium) {
    ElementOfDayWidget()
} timeline: {
    ElementEntry(date: .now, symbol: "Au", name: "Gold", number: "79", category: localizedCategory("transition metal"), atomicWeight: "196.97")
}
#endif
