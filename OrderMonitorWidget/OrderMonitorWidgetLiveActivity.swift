import ActivityKit
import WidgetKit
import SwiftUI

struct OrderMonitorWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: OrderActivityAttributes.self) { context in
            // MARK: - Lock Screen / Banner UI
            HStack(spacing: 16) {
                // Orders
                VStack(spacing: 4) {
                    Image(systemName: "cart.fill")
                        .font(.title2)
                        .foregroundColor(.blue)
                    Text("\(context.state.totalOrders)")
                        .font(.title2)
                        .bold()
                    Text("Đơn hàng")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                
                // Divider
                Rectangle()
                    .fill(.secondary.opacity(0.3))
                    .frame(width: 1, height: 40)
                
                // Late orders
                VStack(spacing: 4) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.title2)
                        .foregroundColor(context.state.lateOrders > 0 ? .red : .green)
                    Text("\(context.state.lateOrders)")
                        .font(.title2)
                        .bold()
                        .foregroundColor(context.state.lateOrders > 0 ? .red : .primary)
                    Text("Đơn trễ")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                
                // Divider
                Rectangle()
                    .fill(.secondary.opacity(0.3))
                    .frame(width: 1, height: 40)
                
                // Items
                VStack(spacing: 4) {
                    Image(systemName: "takeoutbag.and.cup.and.straw.fill")
                        .font(.title2)
                        .foregroundColor(.orange)
                    Text("\(context.state.totalItems)")
                        .font(.title2)
                        .bold()
                    Text("Số món")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
            }
            .padding()
            .activityBackgroundTint(.black.opacity(0.8))
            .activitySystemActionForegroundColor(.white)
            
        } dynamicIsland: { context in
            DynamicIsland {
                // MARK: - Expanded UI
                DynamicIslandExpandedRegion(.leading) {
                    VStack(alignment: .leading, spacing: 2) {
                        Label("\(context.state.totalOrders) đơn", systemImage: "cart.fill")
                            .font(.caption)
                            .foregroundColor(.blue)
                    }
                }
                
                DynamicIslandExpandedRegion(.trailing) {
                    VStack(alignment: .trailing, spacing: 2) {
                        Label("\(context.state.totalItems) món", systemImage: "takeoutbag.and.cup.and.straw.fill")
                            .font(.caption)
                            .foregroundColor(.orange)
                    }
                }
                
                DynamicIslandExpandedRegion(.center) {
                    VStack(spacing: 2) {
                        if context.state.lateOrders > 0 {
                            Label("\(context.state.lateOrders) đơn trễ", systemImage: "exclamationmark.triangle.fill")
                                .font(.caption)
                                .bold()
                                .foregroundColor(.red)
                        } else {
                            Label("Không có đơn trễ", systemImage: "checkmark.circle.fill")
                                .font(.caption)
                                .foregroundColor(.green)
                        }
                    }
                }
                
                DynamicIslandExpandedRegion(.bottom) {
                    Text("Cập nhật: \(context.state.lastUpdated.formatted(date: .omitted, time: .standard))")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .center)
                }
                
            } compactLeading: {
                // MARK: - Compact Leading
                Image(systemName: "cart.fill")
                    .foregroundColor(.blue)
            } compactTrailing: {
                // MARK: - Compact Trailing
                if context.state.lateOrders > 0 {
                    Text("\(context.state.lateOrders) 🆘")
                        .font(.caption2)
                        .foregroundColor(.red)
                        .bold()
                } else {
                    Text("\(context.state.totalOrders)")
                        .font(.caption2)
                        .foregroundColor(.green)
                }
            } minimal: {
                // MARK: - Minimal
                Image(systemName: context.state.lateOrders > 0 ? "exclamationmark.triangle.fill" : "cart.fill")
                    .foregroundColor(context.state.lateOrders > 0 ? .red : .blue)
            }
        }
    }
}
