//
//  ReversedWidget.swift
//  ReversedWidget
//
//  WidgetKit extension showing the verse of the day. All data is written by
//  the Flutter app through the `home_widget` plugin into the shared App Group
//  UserDefaults (see lib/services/widget_sync.dart). The app stores a schedule
//  of upcoming days, which we turn into a WidgetKit timeline so the verse
//  rolls over at midnight without the app being opened.
//

import AppIntents
import SwiftUI
import WidgetKit

let appGroupId = "group.com.codeaskush.reversed"

// MARK: - Data

struct WidgetVerse {
  let source: String
  let reference: String
  let text: String

  static let placeholder = WidgetVerse(
    source: "Reversed",
    reference: "",
    text: "Open the app once to choose your scripture and see today's verse."
  )
}

struct WidgetStyle {
  let background: Color
  let foreground: Color
  let accent: Color
  let textScale: CGFloat

  static let fallback = WidgetStyle(
    background: Color(red: 0.88, green: 0.48, blue: 0.12),
    foreground: .white,
    accent: .white.opacity(0.85),
    textScale: 1.0
  )

  static func load(from defaults: UserDefaults?) -> WidgetStyle {
    guard let defaults else { return .fallback }
    return WidgetStyle(
      background: Color(hex: defaults.string(forKey: "widget_bg")) ?? fallback.background,
      foreground: Color(hex: defaults.string(forKey: "widget_fg")) ?? fallback.foreground,
      accent: Color(hex: defaults.string(forKey: "widget_accent")) ?? fallback.accent,
      textScale: CGFloat(Double(defaults.string(forKey: "widget_text_scale") ?? "") ?? 1.0)
    )
  }
}

struct ScheduledVerse {
  let day: Date
  let verse: WidgetVerse
}

enum VerseStore {
  private static let dayFormatter: DateFormatter = {
    let f = DateFormatter()
    f.dateFormat = "yyyy-MM-dd"
    f.locale = Locale(identifier: "en_US_POSIX")
    f.timeZone = .current
    return f
  }()

  /// Schedule written by the app, sorted by day. Empty if the app never ran.
  static func schedule(from defaults: UserDefaults?) -> [ScheduledVerse] {
    guard
      let json = defaults?.string(forKey: "verse_schedule"),
      let data = json.data(using: .utf8),
      let entries = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]]
    else { return [] }

    return entries.compactMap { entry in
      guard
        let dateString = entry["date"] as? String,
        let day = dayFormatter.date(from: dateString),
        let text = entry["text"] as? String
      else { return nil }
      return ScheduledVerse(
        day: day,
        verse: WidgetVerse(
          source: entry["source"] as? String ?? "",
          reference: entry["reference"] as? String ?? "",
          text: text
        )
      )
    }.sorted { $0.day < $1.day }
  }

  /// The last verse the app pushed, independent of the schedule.
  static func current(from defaults: UserDefaults?) -> WidgetVerse? {
    guard let defaults, let text = defaults.string(forKey: "verse_text") else { return nil }
    return WidgetVerse(
      source: defaults.string(forKey: "verse_source") ?? "",
      reference: defaults.string(forKey: "verse_reference") ?? "",
      text: text
    )
  }
}

// MARK: - Timeline

struct VerseEntry: TimelineEntry {
  let date: Date
  let verse: WidgetVerse
  let style: WidgetStyle
}

struct VerseProvider: TimelineProvider {
  func placeholder(in context: Context) -> VerseEntry {
    VerseEntry(date: Date(), verse: .placeholder, style: .fallback)
  }

  func getSnapshot(in context: Context, completion: @escaping (VerseEntry) -> Void) {
    completion(entries().first ?? placeholder(in: context))
  }

  func getTimeline(in context: Context, completion: @escaping (Timeline<VerseEntry>) -> Void) {
    completion(Timeline(entries: entries(), policy: .atEnd))
  }

  /// One entry per scheduled day, starting with today's verse.
  private func entries() -> [VerseEntry] {
    let defaults = UserDefaults(suiteName: appGroupId)
    let style = WidgetStyle.load(from: defaults)
    let schedule = VerseStore.schedule(from: defaults)
    let startOfToday = Calendar.current.startOfDay(for: Date())

    var entries: [VerseEntry] = []
    for item in schedule where item.day >= startOfToday {
      // The first entry must be valid *now*, not at midnight.
      let date = entries.isEmpty ? Date() : item.day
      entries.append(VerseEntry(date: date, verse: item.verse, style: style))
    }

    if entries.isEmpty {
      let verse = VerseStore.current(from: defaults) ?? .placeholder
      entries.append(VerseEntry(date: Date(), verse: verse, style: style))
    }
    return entries
  }
}

// MARK: - View

struct ReversedWidgetEntryView: View {
  @Environment(\.widgetFamily) var family
  var entry: VerseEntry

  private var verseFont: Font {
    let size = (family == .systemSmall ? 13 : 15) * entry.style.textScale
    return .custom("Georgia", size: size)
  }

  var body: some View {
    VStack(alignment: .leading, spacing: 6) {
      HStack {
        Text(entry.verse.source.uppercased())
          .font(.system(size: 11, weight: .semibold))
          .foregroundColor(entry.style.accent)
          .lineLimit(1)
        Spacer()
        shuffleButton
      }

      Text(entry.verse.text)
        .font(verseFont)
        .foregroundColor(entry.style.foreground)
        .lineSpacing(3)
        .minimumScaleFactor(0.75)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)

      if !entry.verse.reference.isEmpty {
        Text(entry.verse.reference)
          .font(.system(size: 12 * entry.style.textScale, weight: .semibold))
          .foregroundColor(entry.style.accent)
          .lineLimit(1)
      }
    }
    .padding(EdgeInsets(top: 14, leading: 16, bottom: 14, trailing: 14))
    .widgetBackground(entry.style.background)
  }

  @ViewBuilder
  private var shuffleButton: some View {
    if #available(iOSApplicationExtension 17.0, *) {
      Button(intent: BackgroundIntent(url: URL(string: "reversed://next"), appGroup: appGroupId)) {
        Image(systemName: "shuffle")
          .font(.system(size: 14, weight: .semibold))
          .foregroundColor(entry.style.accent)
      }
      .buttonStyle(.plain)
    } else {
      Image(systemName: "shuffle")
        .font(.system(size: 14, weight: .semibold))
        .foregroundColor(entry.style.accent)
    }
  }
}

// MARK: - Widget

struct ReversedWidget: Widget {
  // Must match AppConstants.iosWidgetName in lib/core/constants.dart.
  let kind: String = "ReversedWidget"

  var body: some WidgetConfiguration {
    StaticConfiguration(kind: kind, provider: VerseProvider()) { entry in
      ReversedWidgetEntryView(entry: entry)
    }
    .configurationDisplayName("Verse of the day")
    .description("A daily verse from the Bhagavad Gita or the Bible.")
    .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    .contentMarginsDisabledIfAvailable()
  }
}

// MARK: - Helpers

extension Color {
  /// Parses `#AARRGGBB` or `#RRGGBB` as written by WidgetSync.toHex.
  init?(hex: String?) {
    guard var hex else { return nil }
    hex = hex.trimmingCharacters(in: CharacterSet(charactersIn: "#"))
    guard let value = UInt64(hex, radix: 16) else { return nil }
    let a, r, g, b: Double
    switch hex.count {
    case 8:
      a = Double((value >> 24) & 0xFF) / 255
      r = Double((value >> 16) & 0xFF) / 255
      g = Double((value >> 8) & 0xFF) / 255
      b = Double(value & 0xFF) / 255
    case 6:
      a = 1
      r = Double((value >> 16) & 0xFF) / 255
      g = Double((value >> 8) & 0xFF) / 255
      b = Double(value & 0xFF) / 255
    default:
      return nil
    }
    self.init(.sRGB, red: r, green: g, blue: b, opacity: a)
  }
}

extension View {
  /// iOS 17 requires `containerBackground`; earlier versions use a plain background.
  @ViewBuilder
  func widgetBackground(_ color: Color) -> some View {
    if #available(iOSApplicationExtension 17.0, *) {
      containerBackground(for: .widget) { color }
    } else {
      background(color)
    }
  }
}

extension WidgetConfiguration {
  func contentMarginsDisabledIfAvailable() -> some WidgetConfiguration {
    if #available(iOSApplicationExtension 17.0, *) {
      return contentMarginsDisabled()
    } else {
      return self
    }
  }
}

#if DEBUG
struct ReversedWidget_Previews: PreviewProvider {
  static var previews: some View {
    ReversedWidgetEntryView(
      entry: VerseEntry(
        date: Date(),
        verse: WidgetVerse(
          source: "Bhagavad Gita",
          reference: "2.47",
          text: "You have a right to your actions alone, never to their fruits."
        ),
        style: .fallback
      )
    )
    .previewContext(WidgetPreviewContext(family: .systemMedium))
  }
}
#endif
