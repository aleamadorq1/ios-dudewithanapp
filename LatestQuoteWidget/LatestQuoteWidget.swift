import WidgetKit
import SwiftUI

struct SimpleEntry: TimelineEntry {
    let date: Date
    let quote: Quote
}

struct Provider: TimelineProvider {
    let apiService = APIService()

    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(),  quote: Quote(id: 0, quoteText: "Placeholder", secondaryText: "", url: "", creationDate: ""))
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        apiService.fetchLatestQuote { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let quote):
                    let entry = SimpleEntry(date: Date(), quote: quote)
                    completion(entry)
                case .failure(let error):
                    print("Error fetching latest quote: \(error)")
                    let entry = SimpleEntry(date: Date(), quote: Quote(id: 0, quoteText: "Error", secondaryText: "", url: "", creationDate: ""))
                    completion(entry)
                }
            }
        }
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<SimpleEntry>) -> ()) {
        apiService.fetchLatestQuote { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let quote):
                    let entry = SimpleEntry(date: Date(), quote: quote)
                    let timeline = Timeline(entries: [entry], policy: .atEnd)
                    completion(timeline)
                case .failure(let error):
                    print("Error fetching latest quote: \(error)")
                    let entry = SimpleEntry(date: Date(), quote: Quote(id: 0, quoteText: "Error", secondaryText: "", url: "", creationDate: ""))
                    let timeline = Timeline(entries: [entry], policy: .atEnd)
                    completion(timeline)
                }
            }
        }
    }
}

struct LatestQuoteWidgetEntryView : View {
    @Environment(\.widgetFamily) var family
    var entry: SimpleEntry
    let backgroundColor: Color = Color.white
    var icon: some View {
        Image(systemName: "quote.bubble") // Replace with your own image
            .foregroundColor(.black)
            .font(.system(size: 7))
    }

    var body: some View {
        if family == .accessoryRectangular {
            VStack(alignment: .leading, spacing: 0) {
                    Text(entry.quote.quoteText)
                        .font(.custom("HelveticaNeue", size: dynamicFontSize(quote: entry.quote)))
                        .foregroundColor(Color.black)
                        .padding(2)
                HStack(alignment: .top) {
                    icon
                    Text(entry.quote.secondaryText)
                        .font(.custom("HelveticaNeue", size: 7))
                        .foregroundColor(Color.black)
                        
                }
            }
        } else {
            GeometryReader { geometry in
                VStack(alignment: .leading) {
                    Text(entry.quote.quoteText)
                        .font(.custom("HelveticaNeue-Bold", size: dynamicFontSize(quote: entry.quote)))
                        .padding(.horizontal, 15)
                        .padding(.top, 15)
                        .foregroundColor(Color.black)

                    Text(entry.quote.secondaryText)
                        .font(.custom("HelveticaNeue-Bold", size: dynamicFontSizeForSecondaryText(quote: entry.quote)))
                        .padding(.top, 10)
                        .padding(.horizontal, 15)
                        .foregroundColor(Color.black)
                    
                }
                .frame(width: geometry.size.width * 0.85, height: geometry.size.height * 0.85)
                .background(Color.white)
                .border(Color.black, width: 2)
                .position(x: geometry.size.width * 0.5, y: geometry.size.height * 0.5)
            }
        }
    }
    
    func dynamicFontSize(quote: Quote) -> CGFloat {
        let length = quote.quoteText.count
        if length < 50 {
            return 12
        } else if length < 100 {
            return 10
        } else {
            return 8
        }
    }
    func dynamicFontSizeForSecondaryText(quote: Quote) -> CGFloat {
        let length = quote.secondaryText.count
        if length < 20 {
            return 9
        } else {
            return 7
        }
    }
}



struct LatestQuoteWidget: Widget {
    let kind: String = "LatestQuoteWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            LatestQuoteWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("My Widget")
        .description("This is an example widget.")
        .supportedFamilies([.systemSmall, .accessoryRectangular])
    }
}




struct LatestQuoteWidget_Previews: PreviewProvider {
    static var previews: some View {
        LatestQuoteWidgetEntryView(entry: SimpleEntry(date: Date(),  quote: Quote(id: 0, quoteText: "Error", secondaryText: "", url: "", creationDate: "")))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}

extension Color {
    func uiColor() -> UIColor {
        let components = self.cgColor?.components ?? [0, 0, 0, 0]
        return UIColor(red: components[0], green: components[1], blue: components[2], alpha: components[3])
    }
    
    func isLight() -> Bool {
        let uiColor = self.uiColor()
        let colorComponents = uiColor.cgColor.components
        let red = colorComponents?[0] ?? 0
        let green = colorComponents?[1] ?? 0
        let blue = colorComponents?[2] ?? 0
        let yiq = (red * 299 + green * 587 + blue * 114) / 1000
        return yiq >= 0.5
    }
}
