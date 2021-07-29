//
//  FlutterAppWidget.swift
//  FlutterAppWidget
//
//  Created by 冯旭超 on 2021/7/28.
//

import WidgetKit
import SwiftUI
import Intents
import OSLog

struct FlutterData: Decodable, Hashable {
    let text: String
}

struct Provider: IntentTimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), message: FlutterData(text: "Test"))
    }

    func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), message: FlutterData(text: "Test"))
        completion(entry)
    }

    func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [SimpleEntry] = []
        
        let sharedDefaults = UserDefaults.init(suiteName: "group.com.toner")
        var flutterData: FlutterData? = nil
        Logger().log("aaaassssss \(sharedDefaults == nil)")
        if sharedDefaults != nil {
            do {
                let shared = sharedDefaults!.string(forKey: "widgetData")
                print("value")
                print(shared)
                print(sharedDefaults)
                Logger().log("asasa \(shared == nil) forKey: widgetData. suiteName: group.com.toner")
                if shared != nil {
                    let decoder = JSONDecoder()
                    flutterData = try decoder.decode(FlutterData.self, from: shared!.data(using: .utf8)!)
                }
//                flutterData = FlutterData(text: "Hello")
            } catch {
                print(error)
            }
        }
        Logger().log("getTimelinelog \(String(describing: flutterData))")

        let currentDate = Date()
        let entryDate = Calendar.current.date(byAdding: .hour, value: 24, to: currentDate)!

        let entry = SimpleEntry(date: entryDate, message: flutterData)
        entries.append(entry)

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let message: FlutterData?
}

struct FlutterAppWidgetEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        Text(entry.message!.text)
            .widgetURL(URLComponents.init(string: "http://baidu.com?flutter_app_widget")?.url)
    }
}

@main
struct FlutterAppWidget: Widget {
    let kind: String = "FlutterAppWidget"

    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: ConfigurationIntent.self, provider: Provider()) { entry in
            FlutterAppWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("My Widget")
        .description("This is an example widget.")
    }
}

struct FlutterAppWidget_Previews: PreviewProvider {
    static var previews: some View {
        FlutterAppWidgetEntryView(entry: SimpleEntry(date: Date(), message: FlutterData(text: "Test")))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
