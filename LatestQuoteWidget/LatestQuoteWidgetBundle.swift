//
//  LatestQuoteWidgetBundle.swift
//  LatestQuoteWidget
//
//  Created by Alejandro on 5/22/23.
//

import WidgetKit
import SwiftUI

@main
struct LatestQuoteWidgetBundle: WidgetBundle {
    var body: some Widget {
        LatestQuoteWidget()
        LatestQuoteWidgetLiveActivity()
    }
}
