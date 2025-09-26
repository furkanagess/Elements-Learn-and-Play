//
//  ElementOfDayWidgetLiveActivity.swift
//  ElementOfDayWidget
//
//  Created by furkan çağlar on 26.09.2025.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct ElementOfDayWidgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct ElementOfDayWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: ElementOfDayWidgetAttributes.self) { context in
            // Lock screen/banner UI goes here
            VStack {
                Text("Hello \(context.state.emoji)")
            }
            .activityBackgroundTint(Color.cyan)
            .activitySystemActionForegroundColor(Color.black)

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    Text("Leading")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("Trailing")
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("Bottom \(context.state.emoji)")
                    // more content
                }
            } compactLeading: {
                Text("L")
            } compactTrailing: {
                Text("T \(context.state.emoji)")
            } minimal: {
                Text(context.state.emoji)
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }
}

extension ElementOfDayWidgetAttributes {
    fileprivate static var preview: ElementOfDayWidgetAttributes {
        ElementOfDayWidgetAttributes(name: "World")
    }
}

extension ElementOfDayWidgetAttributes.ContentState {
    fileprivate static var smiley: ElementOfDayWidgetAttributes.ContentState {
        ElementOfDayWidgetAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: ElementOfDayWidgetAttributes.ContentState {
         ElementOfDayWidgetAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: ElementOfDayWidgetAttributes.preview) {
   ElementOfDayWidgetLiveActivity()
} contentStates: {
    ElementOfDayWidgetAttributes.ContentState.smiley
    ElementOfDayWidgetAttributes.ContentState.starEyes
}
