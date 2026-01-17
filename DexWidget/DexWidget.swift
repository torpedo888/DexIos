////
////  DexWidget.swift
////  DexWidget
////
////  Created by Ferenc Batorligeti on 2026. 01. 14..
////
//
//import WidgetKit
//import SwiftUI
//
//struct Provider: TimelineProvider {
//
//    var randomPokemon: Pokemon {
//        var results : [Pokemon] = []
//
//        do {
//            results = try PersistenceController().container.viewContext
//                .fetch(Pokemon.fetchRequest())
//        } catch {
//            print("Error: \(error)")
//        }
//
//        if let randomPokemon = results.randomElement() {
//            return randomPokemon
//        }
//
//        return PersistenceController.previewPokemon
//    }
//
//    func placeholder(in context: Context) -> SimpleEntry {
//        SimpleEntry.placeholder
//    }
//
//    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
//        completion(SimpleEntry.placeholder)
//    }
//
//    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
//        var entries: [SimpleEntry] = []
//
//        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
//        let currentDate = Date()
//
//        for secondOffset in 0..<10 {
//            let entryDate = Calendar.current.date(
//                byAdding: .second,
//                value: secondOffset * 2,
//                to: currentDate)!
//
//            let entryPokemon = randomPokemon
//
//            let entry = SimpleEntry(
//                date: entryDate,
//                name: entryPokemon.name!,
//                types: entryPokemon.types!,
//                sprite: entryPokemon.spriteImage
//            )
//
//            entries.append(entry) // <— You forgot this
//        }
//
//        // Ensure at least one entry is <= now; we did that by starting at `currentDate`
//
//        let timeline = Timeline(entries: entries, policy: .atEnd)
//
//        completion(timeline)
//    }
//}
//
//struct SimpleEntry: TimelineEntry {
//    let date: Date
//    let name: String
//    let types: [String]
//    let sprite: Image
//
//    static var placeholder: SimpleEntry {
//        SimpleEntry(date: .now, name: "bulbasaur", types: ["grass", "poison"],
//                    sprite: Image(.bulbasaur))
//    }
//
//    static var placeholder2: SimpleEntry {
//        SimpleEntry(date: .now, name: "mew", types: ["psychic"],
//                    sprite: Image(.mew))
//    }
//}
//
//struct DexWidgetEntryView : View {
//    @Environment(\.widgetFamily) var widgetSize
//    var entry: Provider.Entry
//
//    var pokemonImage : some View {
//        entry.sprite
//            .interpolation(.none)
//            .resizable()
//            .scaledToFit()
//            .shadow(color: .black,radius: 3)
//    }
//
//    var typesView: some View {
//        ForEach(entry.types, id:\.self) {
//            type in
//            Text(type.capitalized)
//                .font(.subheadline)
//                .fontWeight(.semibold)
//                .padding(.horizontal, 13)
//                .padding(.vertical, 5)
//                .background(Color(type.capitalized))
//                .clipShape(RoundedRectangle(cornerRadius: 8))
//                .shadow(radius: 3)
//        }
//    }
//
//    var body: some View {
//        switch widgetSize {
//        case .systemMedium:
//            HStack {
//                pokemonImage
//
//                Spacer()
//
//                VStack(alignment: .leading) {
//                    Text(entry.name.capitalized)
//                        .font(.title)
//                        .padding(.vertical, 1)
//
//                    HStack {
//                        typesView
//                    }
//                }
//                .layoutPriority(1)
//
//                Spacer()
//            }
//
//        case .systemLarge:
//            ZStack {
//                pokemonImage
//
//                VStack(alignment: .leading) {
//                    Text(entry.name.capitalized)
//                        .font(.largeTitle)
//                        .lineLimit(1)
//                        .minimumScaleFactor(0.75)
//
//                    Spacer()
//
//                    HStack {
//                        Spacer()
//
//                        typesView
//                    }
//
//                }
//            }
//
//        default:
//            pokemonImage
//        }
//    }
//}
//
//struct DexWidget: Widget {
//    let kind: String = "DexWidget"
//
//    var body: some WidgetConfiguration {
//        StaticConfiguration(kind: kind, provider: Provider()) { entry in
//            if #available(iOS 17.0, *) {
//                DexWidgetEntryView(entry: entry)
//                    .foregroundStyle(.black)
//                    .containerBackground(
//                        Color(entry.types[0].capitalized),
//                        for: .widget
//                    )
//            } else {
//                DexWidgetEntryView(entry: entry)
//                    .padding()
//                    .background()
//            }
//        }
//        .configurationDisplayName("Pokemon")
//        .description("See a random pokemon")
//    }
//}
//
////small widget size
//#Preview(as: .systemSmall) {
//    DexWidget()
//} timeline: {
//    SimpleEntry.placeholder
//    SimpleEntry.placeholder2
//}
//
////medium
//#Preview(as: .systemMedium) {
//    DexWidget()
//} timeline: {
//    SimpleEntry.placeholder
//    SimpleEntry.placeholder2
//}
//
////large
//#Preview(as: .systemLarge) {
//    DexWidget()
//} timeline: {
//    SimpleEntry.placeholder
//    SimpleEntry.placeholder2
//}
