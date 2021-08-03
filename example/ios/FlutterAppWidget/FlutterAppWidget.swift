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
    let start: Bool
    let message: String
}

struct Provider: IntentTimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), message: FlutterData(start: true, message: "Test"))
    }

    func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), message: FlutterData(start: true, message: "Test"))
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
        VStack(alignment:.leading) {
            Text("StudyStudy Study Study Study")
                .font(.system(size: 25))
                .bold()
                .lineLimit(2)
            Text("Work")
                .font(.system(size: 18))
                .lineLimit(1)
            Spacer()
            HStack {
                Text("0:00")
                    .font(.system(size: 18))
                Spacer()
                            Image(systemName: "play.fill")
                                .font(.system(size: 18))
            }
        }.padding()
            
//            Image(systemName: "play.fill")
//                .font(.system(size: 25))
//            Spacer()
//
//            Text("工作")
//                .font(.system(size: 12))
//                .fontWeight(.light)
//                .opacity(1)
//            Text(entry.message?.message ?? "NoMessage")
//                .font(.system(size: 18))
//                .fontWeight(.semibold)
//                .bold()
//                .lineLimit(1)
//                .frame(minWidth: /*@START_MENU_TOKEN@*/0/*@END_MENU_TOKEN@*/,  maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/,alignment: .leading)
//        }
//        .frame(minWidth: /*@START_MENU_TOKEN@*/0/*@END_MENU_TOKEN@*/, maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, minHeight: /*@START_MENU_TOKEN@*/0/*@END_MENU_TOKEN@*/,  maxHeight: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
//        .overlay(getTimerView()
//                    .font(.system(size: 25))
//                    .bold()
//                    .lineLimit(1)
//                    .frame(minWidth: /*@START_MENU_TOKEN@*/0/*@END_MENU_TOKEN@*/,  maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/,alignment: .leading))
//        .padding(.all, 12)
//        .background(ContainerRelativeShape().fill(Color.yellow))
//        .widgetURL(URLComponents.init(string: "http://baidu.com?flutter_app_widget")?.url)
    }
    
    func getTimerView() -> Text {
        if entry.message?.start ?? false {
            return Text(Date(), style: .timer)
        } else {
            return Text("0:00")
        }
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
        FlutterAppWidgetEntryView(entry: SimpleEntry(date: Date(), message: FlutterData(start: true, message: "Test")))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
