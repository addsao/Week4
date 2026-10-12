//
//  OrderListView.swift
//  FishStore
//
//  Tab "Đơn hàng": danh sách đơn đọc từ orders.txt, lọc theo trạng thái.
//

import SwiftUI

struct OrderListView: View {

    @EnvironmentObject private var orderController: OrderController

    @State private var filter: OrderStatus? = nil

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                filterBar

                let orders = orderController.orders(status: filter)
                if orders.isEmpty {
                    EmptyStateView(icon: "doc.text.magnifyingglass",
                                   title: "Chưa có đơn hàng",
                                   message: filter == nil
                                       ? "Đơn hàng bạn đặt sẽ xuất hiện ở đây."
                                       : "Không có đơn \"\(filter?.rawValue ?? "")\".")
                } else {
                    List(orders) { order in
                        NavigationLink(value: order) {
                            OrderRowView(order: order)
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .background(AppTheme.background)
            .navigationTitle("Đơn hàng")
            .refreshable { orderController.load() }
            .appDestinations()
        }
    }

    private var filterBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                FilterChip(title: "Tất cả (\(orderController.orders.count))",
                           isSelected: filter == nil) { filter = nil }

                ForEach(OrderStatus.allCases) { status in
                    FilterChip(title: "\(status.rawValue) (\(orderController.count(status: status)))",
                               isSelected: filter == status) { filter = status }
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 10)
        }
    }
}

// MARK: - Một dòng đơn hàng

struct OrderRowView: View {
    let order: Order

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(order.code)
                    .font(.headline)
                Spacer()
                StatusBadge(status: order.status)
            }
            Text(order.itemsSummary)
                .font(.subheadline)
                .lineLimit(1)
            HStack {
                Label(order.orderDate.vnString, systemImage: "calendar")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer()
                Text(order.total.vnd)
                    .font(.subheadline.bold())
                    .foregroundStyle(AppTheme.price)
            }
        }
        .padding(.vertical, 6)
    }
}
