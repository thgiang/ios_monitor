import ActivityKit
import WidgetKit
import SwiftUI

struct LiveActivityAttributes: ActivityAttributes {
    // Define the content state for the live activity
    public struct ContentState: Codable, Hashable {
        var value: Int
    }

    // Define any additional fixed properties of the activity
    var name: String
}
