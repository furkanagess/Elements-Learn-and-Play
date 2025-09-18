//
//  ElementOfDayWidgetBundle.swift
//  ElementOfDayWidget
//
//  Created by furkan çağlar on 14.09.2025.
//

import WidgetKit
import SwiftUI

@main
struct ElementOfDayWidgetBundle: WidgetBundle {
    var body: some Widget {
        ElementOfDayWidget()
        ElementOfDayWidgetControl()
        ElementOfDayWidgetLiveActivity()
    }
}
