//
//  OrderDetailView.swift
//  FishStore
//
//  Chi tiết đơn hàng: tiến trình, thông tin giao hàng, sản phẩm, tổng tiền,
//  nút hủy đơn và nút chuyển trạng thái (dành cho chủ cửa hàng).
//

import SwiftUI

struct OrderDetailView: View {

    @EnvironmentObject private var orderController: OrderController
    @EnvironmentObject private var productController: ProductController

    let orderId: Int

    @State private var showCancelConfirm = false

    var body: some View {
        if let order = orderController.order(id: orderId) {
            detail(order)
        } else {
            EmptyStateView(icon: "doc.questionmark",
                           title: "Không tìm thấy đơn hàng",
                           message: "Đơn có thể đã bị xóa khỏi orders.txt.")
        }
    }

    private func detail(_ order: Order) -> some View {
        List {
            Section {
                OrderProgressView(status: order.status)
                Text(order.status.message)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }

            Section("Thông tin giao hàng") {
                LabeledContent("Mã đơn", value: order.code)
                LabeledContent("Ngày đặt", value: order.orderDate.vnString)
                LabeledContent("Người nhận", value: order.customerName)
                LabeledContent("Điện thoại", value: order.phoneNumber)
                VStack(alignment: .leading, spacing: 4) {
                    Text("Địa chỉ")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(order.shippingAddress)
                }
                if !order.note.isEmpty {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Ghi chú")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text(order.note)
                    }
                }
            }

            Section("Sản phẩm (\(order.totalQuantity))") {
                ForEach(order.items) { item in
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(item.productName)
                            Text("\(item.unitPrice.vnd) × \(item.quantity)")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        Text(item.subtotal.vnd)
                            .font(.subheadline.bold())
                    }
                }
            }

            Section {
                SummaryRow(title: "Tạm tính", value: order.subtotal.vnd)
                SummaryRow(title: "Phí giao hàng",
                           value: order.shippingFee == 0 ? "Miễn phí" : order.shippingFee.vnd)
                SummaryRow(title: "Tổng cộng",
                           value: order.total.vnd,
                           isEmphasized: true,
                           valueColor: AppTheme.price)
            }

            if !order.status.isFinished {
                Section {
                    if let next = order.status.next {
                        Button {
                            orderController.advanceStatus(order)
                        } label: {
                            Label("Chuyển sang \"\(next.rawValue)\"", systemImage: next.iconName)
                        }
                    }
                    if order.status.canCancel {
                        Button(role: .destructive) {
                            showCancelConfirm = true
                        } label: {
                            Label("Hủy đơn hàng", systemImage: "xmark.circle")
                        }
                    }
                } footer: {
                    Text("Nút chuyển trạng thái dành cho chủ cửa hàng (demo).")
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle(order.code)
        .navigationBarTitleDisplayMode(.inline)
        .alert("Hủy đơn \(order.code)?", isPresented: $showCancelConfirm) {
            Button("Hủy đơn", role: .destructive) {
                orderController.cancel(order, productController: productController)
            }
            Button("Không", role: .cancel) {}
        } message: {
            Text("Số lượng sản phẩm sẽ được hoàn lại kho.")
        }
    }
}

// MARK: - Thanh tiến trình đơn hàng

struct OrderProgressView: View {
    let status: OrderStatus

    var body: some View {
        if status == .cancelled {
            Label("Đơn hàng đã bị hủy", systemImage: "xmark.circle.fill")
                .font(.headline)
                .foregroundStyle(.red)
        } else {
            HStack(alignment: .top, spacing: 0) {
                ForEach(OrderStatus.progressSteps) { step in
                    let done = step.step <= status.step
                    VStack(spacing: 6) {
                        Image(systemName: step.iconName)
                            .font(.subheadline)
                            .foregroundStyle(.white)
                            .frame(width: 34, height: 34)
                            .background(Circle().fill(done ? step.color : Color.gray.opacity(0.3)))
                        Text(step.rawValue)
                            .font(.caption2)
                            .multilineTextAlignment(.center)
                            .foregroundStyle(done ? Color.primary : Color.secondary)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .padding(.vertical, 6)
        }
    }
}
