//
//  ElementOfDayWidget.swift
//  ElementOfDayWidget
//
//  Created by furkan çağlar on 26.09.2025.
//

import WidgetKit
import SwiftUI
import Foundation

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        // Use a more interesting placeholder element
        let placeholderElement = ElementData(
            number: "6",
            symbol: "C",
            enName: "Carbon",
            trName: "Karbon",
            weight: "12.011",
            category: "Nonmetal"
        )
        return SimpleEntry(date: Date(), elementData: placeholderElement)
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), elementData: ElementData.placeholder)
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<SimpleEntry>) -> ()) {
        var entries: [SimpleEntry] = []

        // Generate a timeline with entries for the next 24 hours
        let currentDate = Date()
        let calendar = Calendar.current
        
        // Add entry for current time
        let currentElement = getElementDataSync()
        let currentEntry = SimpleEntry(date: currentDate, elementData: currentElement)
        entries.append(currentEntry)
        
        // Add entry for tomorrow at midnight (when element changes)
        if let tomorrow = calendar.date(byAdding: .day, value: 1, to: currentDate) {
            let tomorrowElement = getElementDataSync() // This will be the same for today
            let tomorrowEntry = SimpleEntry(date: tomorrow, elementData: tomorrowElement)
            entries.append(tomorrowEntry)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
    
    private func getElementDataSync() -> ElementData {
        // Always try to get element data from UserDefaults (shared with Flutter app) first
        let userDefaults = UserDefaults(suiteName: "group.com.furkanages.elements")
        
        if let number = userDefaults?.string(forKey: "number"),
           let symbol = userDefaults?.string(forKey: "symbol"),
           let enName = userDefaults?.string(forKey: "enName"),
           let trName = userDefaults?.string(forKey: "trName"),
           let weight = userDefaults?.string(forKey: "weight"),
           let category = userDefaults?.string(forKey: "category") {
            
            // Debug: Print selected element from Flutter app
            print("iOS Widget - Using Flutter App Data: \(symbol) (\(enName))")
            print("iOS Widget - Data: number=\(number), symbol=\(symbol), enName=\(enName), trName=\(trName), weight=\(weight), category=\(category)")
            
            return ElementData(
                number: number,
                symbol: symbol,
                enName: enName,
                trName: trName,
                weight: weight,
                category: category
            )
        }
        
        // Debug: Print that Flutter data is not available
        print("iOS Widget - Flutter App Data not available, using fallback")
        
        // Fallback: Use local algorithm only if Flutter data is not available
        let element = ElementOfDayService.getElementOfDay()
        
        // Debug: Print selected element from local algorithm
        print("iOS Widget - Using Local Algorithm: \(element.symbol) (\(element.enName))")
        
        return ElementData(
            number: String(element.number),
            symbol: element.symbol,
            enName: element.enName,
            trName: element.trName,
            weight: element.weight,
            category: element.category
        )
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let elementData: ElementData
}

struct ElementData {
    let number: String
    let symbol: String
    let enName: String
    let trName: String
    let weight: String
    let category: String
    
    static let placeholder = ElementData(
        number: "1",
        symbol: "H",
        enName: "Hydrogen",
        trName: "Hidrojen",
        weight: "1.008",
        category: "Nonmetal"
    )
}

// Periodic elements data - matches Flutter app
struct PeriodicElement {
    let number: Int
    let symbol: String
    let enName: String
    let trName: String
    let weight: String
    let category: String
}

class ElementOfDayService {
    // Element numbers array - matches Flutter app
    static let elementNumbers = [
        1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20,
        21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40,
        41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60,
        61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 80,
        81, 82, 83, 84, 85, 86, 87, 88, 89, 90, 91, 92, 93, 94, 95, 96, 97, 98, 99, 100,
        101, 102, 103, 104, 105, 106, 107, 108, 109, 110, 111, 112, 113, 114, 115, 116, 117, 118
    ]
    
    // Periodic elements data
    static let elements: [PeriodicElement] = [
        PeriodicElement(number: 1, symbol: "H", enName: "Hydrogen", trName: "Hidrojen", weight: "1.008", category: "Nonmetal"),
        PeriodicElement(number: 2, symbol: "He", enName: "Helium", trName: "Helyum", weight: "4.003", category: "Noble Gas"),
        PeriodicElement(number: 3, symbol: "Li", enName: "Lithium", trName: "Lityum", weight: "6.941", category: "Alkali Metal"),
        PeriodicElement(number: 4, symbol: "Be", enName: "Beryllium", trName: "Berilyum", weight: "9.012", category: "Alkaline Earth Metal"),
        PeriodicElement(number: 5, symbol: "B", enName: "Boron", trName: "Bor", weight: "10.811", category: "Metalloid"),
        PeriodicElement(number: 6, symbol: "C", enName: "Carbon", trName: "Karbon", weight: "12.011", category: "Nonmetal"),
        PeriodicElement(number: 7, symbol: "N", enName: "Nitrogen", trName: "Azot", weight: "14.007", category: "Nonmetal"),
        PeriodicElement(number: 8, symbol: "O", enName: "Oxygen", trName: "Oksijen", weight: "15.999", category: "Nonmetal"),
        PeriodicElement(number: 9, symbol: "F", enName: "Fluorine", trName: "Flor", weight: "18.998", category: "Halogen"),
        PeriodicElement(number: 10, symbol: "Ne", enName: "Neon", trName: "Neon", weight: "20.180", category: "Noble Gas"),
        PeriodicElement(number: 11, symbol: "Na", enName: "Sodium", trName: "Sodyum", weight: "22.990", category: "Alkali Metal"),
        PeriodicElement(number: 12, symbol: "Mg", enName: "Magnesium", trName: "Magnezyum", weight: "24.305", category: "Alkaline Earth Metal"),
        PeriodicElement(number: 13, symbol: "Al", enName: "Aluminum", trName: "Alüminyum", weight: "26.982", category: "Post-transition Metal"),
        PeriodicElement(number: 14, symbol: "Si", enName: "Silicon", trName: "Silisyum", weight: "28.085", category: "Metalloid"),
        PeriodicElement(number: 15, symbol: "P", enName: "Phosphorus", trName: "Fosfor", weight: "30.974", category: "Nonmetal"),
        PeriodicElement(number: 16, symbol: "S", enName: "Sulfur", trName: "Kükürt", weight: "32.065", category: "Nonmetal"),
        PeriodicElement(number: 17, symbol: "Cl", enName: "Chlorine", trName: "Klor", weight: "35.453", category: "Halogen"),
        PeriodicElement(number: 18, symbol: "Ar", enName: "Argon", trName: "Argon", weight: "39.948", category: "Noble Gas"),
        PeriodicElement(number: 19, symbol: "K", enName: "Potassium", trName: "Potasyum", weight: "39.098", category: "Alkali Metal"),
        PeriodicElement(number: 20, symbol: "Ca", enName: "Calcium", trName: "Kalsiyum", weight: "40.078", category: "Alkaline Earth Metal"),
        PeriodicElement(number: 21, symbol: "Sc", enName: "Scandium", trName: "Skandiyum", weight: "44.956", category: "Transition Metal"),
        PeriodicElement(number: 22, symbol: "Ti", enName: "Titanium", trName: "Titanyum", weight: "47.867", category: "Transition Metal"),
        PeriodicElement(number: 23, symbol: "V", enName: "Vanadium", trName: "Vanadyum", weight: "50.942", category: "Transition Metal"),
        PeriodicElement(number: 24, symbol: "Cr", enName: "Chromium", trName: "Krom", weight: "51.996", category: "Transition Metal"),
        PeriodicElement(number: 25, symbol: "Mn", enName: "Manganese", trName: "Manganez", weight: "54.938", category: "Transition Metal"),
        PeriodicElement(number: 26, symbol: "Fe", enName: "Iron", trName: "Demir", weight: "55.845", category: "Transition Metal"),
        PeriodicElement(number: 27, symbol: "Co", enName: "Cobalt", trName: "Kobalt", weight: "58.933", category: "Transition Metal"),
        PeriodicElement(number: 28, symbol: "Ni", enName: "Nickel", trName: "Nikel", weight: "58.693", category: "Transition Metal"),
        PeriodicElement(number: 29, symbol: "Cu", enName: "Copper", trName: "Bakır", weight: "63.546", category: "Transition Metal"),
        PeriodicElement(number: 30, symbol: "Zn", enName: "Zinc", trName: "Çinko", weight: "65.38", category: "Transition Metal")
    ]
    
    // Same algorithm as Flutter app
    static func getElementOfDay() -> PeriodicElement {
        let now = Date()
        let calendar = Calendar.current
        let year = calendar.component(.year, from: now)
        let month = calendar.component(.month, from: now)
        let day = calendar.component(.day, from: now)
        
        // Create seed exactly like Flutter: year + month + day as string, then parse as int
        let seedString = "\(year)\(month)\(day)"
        let seed = Int(seedString) ?? 0
        
        // Debug: Print seed and algorithm details
        print("iOS Widget - Local Algorithm - Seed: \(seed), Elements count: \(elements.count)")
        
        // Use simple random with seed (same as Flutter's Random(seed).nextInt())
        let randomIndex = seed % elements.count
        let selectedElement = elements[randomIndex]
        
        // Debug: Print selected element from local algorithm
        print("iOS Widget - Local Algorithm - Selected: \(selectedElement.symbol) (\(selectedElement.enName))")
        print("iOS Widget - Local Algorithm - Random Index: \(randomIndex)")
        
        return selectedElement
    }
}

struct ElementOfDayWidgetEntryView : View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) var family

    var body: some View {
        VStack(spacing: 0) {
            // Header with title and date
            HStack {
                Text("Günün Elementi")
                    .font(.system(size: family == .systemSmall ? 12 : 14, weight: .semibold))
                    .foregroundColor(.white)
                Spacer()
                Text(_formatDate(entry.date))
                    .font(.system(size: family == .systemSmall ? 10 : 12, weight: .medium))
                    .foregroundColor(.white.opacity(0.8))
            }
            .padding(.horizontal, family == .systemSmall ? 6 : 8)
            .padding(.top, family == .systemSmall ? 4 : 6)
            
            Spacer()
            
            // Main content area - different layout for small vs medium
            if family == .systemSmall {
                // Small widget - vertical layout
                VStack(spacing: 6) {
                    // Atomic number and symbol
                    HStack(spacing: 6) {
                        Text(entry.elementData.number)
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                        
                        Text(entry.elementData.symbol)
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                    }
                    
                    // Element name
                    Text(entry.elementData.trName)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                        .lineLimit(1)
                    
                    // Category
                    Text(_getCategoryName(entry.elementData.category))
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(.white.opacity(0.8))
                        .lineLimit(1)
                        }
                        .padding(.horizontal, 6)
                        .padding(.bottom, 4)
            } else {
                // Medium widget - horizontal layout matching screenshot
                HStack(spacing: 16) {
                    // Left side - Element info in rounded rectangle
                    VStack(alignment: .leading, spacing: 6) {
                        // Atomic number and symbol in a rounded rectangle
                        HStack(spacing: 8) {
                            Text(entry.elementData.number)
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.white)
                            
                            Text(entry.elementData.symbol)
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.white)
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(.white.opacity(0.15))
                        )
                        
                        // Element name
                        Text(entry.elementData.trName)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                            .lineLimit(1)
                        
                        // Category
                        Text(_getCategoryName(entry.elementData.category))
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.white.opacity(0.8))
                            .lineLimit(1)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    // Right side - Navigation button
                    VStack {
                        Spacer()
                        Button(action: {
                            // Widget tap action
                        }) {
                            Image(systemName: "chevron.right")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(width: 32, height: 32)
                                .background(
                                    Circle()
                                        .fill(.white.opacity(0.2))
                                )
                        }
                        .buttonStyle(PlainButtonStyle())
                        Spacer()
                    }
                        }
                        .padding(.horizontal, 12)
                        .padding(.bottom, 8)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            ZStack {
                // Gradient overlay for depth over container background
                Rectangle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color(red: 0.1, green: 0.3, blue: 0.3).opacity(0.8),
                                Color(red: 0.15, green: 0.35, blue: 0.35).opacity(0.9),
                                Color(red: 0.1, green: 0.3, blue: 0.3).opacity(0.8)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                
                // Atom patterns covering entire area
                GeometryReader { geometry in
                    ZStack {
                        // Main atom pattern in center
                        ZStack {
                            // Electron orbits
                            Circle()
                                .stroke(.white.opacity(0.1), lineWidth: 1)
                                .frame(width: family == .systemSmall ? 50 : 70, height: family == .systemSmall ? 50 : 70)
                            
                            Circle()
                                .stroke(.white.opacity(0.08), lineWidth: 1)
                                .frame(width: family == .systemSmall ? 35 : 50, height: family == .systemSmall ? 35 : 50)
                            
                            Circle()
                                .stroke(.white.opacity(0.06), lineWidth: 1)
                                .frame(width: family == .systemSmall ? 20 : 30, height: family == .systemSmall ? 20 : 30)
                            
                            // Nucleus
                            Circle()
                                .fill(.white.opacity(0.1))
                                .frame(width: family == .systemSmall ? 6 : 8, height: family == .systemSmall ? 6 : 8)
                            
                            // Electrons
                            Circle()
                                .fill(.white.opacity(0.15))
                                .frame(width: 3, height: 3)
                                .offset(x: family == .systemSmall ? 25 : 35, y: 0)
                            
                            Circle()
                                .fill(.white.opacity(0.12))
                                .frame(width: 2, height: 2)
                                .offset(x: family == .systemSmall ? -18 : -25, y: family == .systemSmall ? 15 : 20)
                            
                            Circle()
                                .fill(.white.opacity(0.1))
                                .frame(width: 2, height: 2)
                                .offset(x: family == .systemSmall ? 12 : 18, y: family == .systemSmall ? -20 : -25)
                        }
                        .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
                        
                        // Additional atom patterns for full coverage
                        // Top-left corner
                        Circle()
                            .stroke(.white.opacity(0.05), lineWidth: 1)
                            .frame(width: 20, height: 20)
                            .position(x: 30, y: 30)
                        
                        // Top-right corner
                        Circle()
                            .stroke(.white.opacity(0.04), lineWidth: 1)
                            .frame(width: 15, height: 15)
                            .position(x: geometry.size.width - 30, y: 30)
                        
                        // Bottom-left corner
                        Circle()
                            .stroke(.white.opacity(0.03), lineWidth: 1)
                            .frame(width: 18, height: 18)
                            .position(x: 25, y: geometry.size.height - 25)
                        
                        // Bottom-right corner
                        Circle()
                            .stroke(.white.opacity(0.06), lineWidth: 1)
                            .frame(width: 12, height: 12)
                            .position(x: geometry.size.width - 25, y: geometry.size.height - 25)
                        
                        // Center-left
                        Circle()
                            .stroke(.white.opacity(0.04), lineWidth: 1)
                            .frame(width: 16, height: 16)
                            .position(x: 20, y: geometry.size.height / 2)
                        
                        // Center-right
                        Circle()
                            .stroke(.white.opacity(0.05), lineWidth: 1)
                            .frame(width: 14, height: 14)
                            .position(x: geometry.size.width - 20, y: geometry.size.height / 2)
                        
                        // Top-center
                        Circle()
                            .stroke(.white.opacity(0.03), lineWidth: 1)
                            .frame(width: 22, height: 22)
                            .position(x: geometry.size.width / 2, y: 40)
                        
                        // Bottom-center
                        Circle()
                            .stroke(.white.opacity(0.04), lineWidth: 1)
                            .frame(width: 18, height: 18)
                            .position(x: geometry.size.width / 2, y: geometry.size.height - 40)
                    }
                }
            }
        )
        .clipped()
    }
    
    private func _formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "tr_TR")
        formatter.dateFormat = "d MMMM yyyy"
        return formatter.string(from: date)
    }
    
    private func _getCategoryName(_ category: String) -> String {
        switch category {
        case "Nonmetal":
            return "Ametaller"
        case "Noble Gas":
            return "Soy Gazlar"
        case "Alkali Metal":
            return "Alkali Metaller"
        case "Alkaline Earth Metal":
            return "Toprak Alkali Metaller"
        case "Transition Metal":
            return "Geçiş Metaller"
        case "Post-transition Metal":
            return "Geçiş Sonrası Metaller"
        case "Metalloid":
            return "Metaloidler"
        case "Halogen":
            return "Halojenler"
        case "Lanthanide":
            return "Lantanitler"
        case "Actinide":
            return "Aktinitler"
        default:
            return category
        }
    }
}

struct ElementOfDayWidget: Widget {
    let kind: String = "ElementOfDayWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            ElementOfDayWidgetEntryView(entry: entry)
                .containerBackground(for: .widget) {
                    // Dark teal background filling entire widget
                    Rectangle()
                        .fill(Color(red: 0.1, green: 0.3, blue: 0.3))
                }
        }
        .configurationDisplayName("Günün Elementi")
        .description("Bugünün periyodik elementini sembol, isim ve atom ağırlığı ile gösterir")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

#Preview(as: .systemSmall) {
    ElementOfDayWidget()
} timeline: {
    SimpleEntry(date: .now, elementData: ElementData(
        number: "79",
        symbol: "Au",
        enName: "Gold",
        trName: "Altın",
        weight: "196.967",
        category: "Transition Metal"
    ))
    SimpleEntry(date: .now, elementData: ElementData(
        number: "26",
        symbol: "Fe",
        enName: "Iron",
        trName: "Demir",
        weight: "55.845",
        category: "Transition Metal"
    ))
}

#Preview(as: .systemMedium) {
    ElementOfDayWidget()
} timeline: {
    SimpleEntry(date: .now, elementData: ElementData(
        number: "79",
        symbol: "Au",
        enName: "Gold",
        trName: "Altın",
        weight: "196.967",
        category: "Transition Metal"
    ))
    SimpleEntry(date: .now, elementData: ElementData(
        number: "26",
        symbol: "Fe",
        enName: "Iron",
        trName: "Demir",
        weight: "55.845",
        category: "Transition Metal"
    ))
}
