//
//  BackgroundIntent.swift
//
//  App Intent behind the widget's shuffle button (iOS 17+). It hands the
//  `reversed://next` URL to home_widget, which runs the Dart callback
//  registered in lib/main.dart (`widgetInteractivityCallback`).
//
//  This file must be a member of BOTH the Runner target and the
//  ReversedWidget extension target (see docs/ios-widget-setup.md).
//

import AppIntents
import Foundation
import home_widget

@available(iOS 17, *)
public struct BackgroundIntent: AppIntent {
  public static var title: LocalizedStringResource = "Show a different verse"
  public static var description = IntentDescription("Picks another verse for today.")

  @Parameter(title: "Widget URI")
  var url: URL?

  @Parameter(title: "App Group")
  var appGroup: String?

  public init() {}

  public init(url: URL?, appGroup: String?) {
    self.url = url
    self.appGroup = appGroup
  }

  public func perform() async throws -> some IntentResult {
    await HomeWidgetBackgroundWorker.run(url: url, appGroup: appGroup!)
    return .result()
  }
}

/// Lets the intent run even when the app is fully suspended.
@available(iOS 17, *)
@available(iOSApplicationExtension, unavailable)
extension BackgroundIntent: ForegroundContinuableIntent {}
