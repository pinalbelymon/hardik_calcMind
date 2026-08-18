import WidgetKit
import SwiftUI

struct CurrencyWidget: Widget {
    let kind = "CurrencyWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: CurrencyTimelineProvider()) { entry in
            CurrencyWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Currency Rates")
        .description("Live exchange rates, right on your Home Screen.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
