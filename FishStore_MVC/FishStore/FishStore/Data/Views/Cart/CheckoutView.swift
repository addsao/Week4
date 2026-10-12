//
//  CheckoutView.swift
//  FishStore
//
//  Nhập thông tin người nhận và xác nhận đặt hàng.
//  OrderController sẽ ghi đơn vào orders.txt và trừ kho trong fish.txt.
//

import SwiftUI

struct CheckoutView: View {

    @EnvironmentObject private var cartController: CartController
    @EnvironmentObject private var productController: ProductController
    @EnvironmentObject private var orderController: OrderController

    /// Gọi khi đặt hàng xong và người dùng bấm "Xem đơn hàng".
    let onFinished: (Order) -> Void

    @State private var name = ""
    @State private var phone = ""
    @State private var address = AppTheme.defaultAddress
    @State private var note = ""
    @State private var errorMessage: String?
    @State private var placedOrder: Order?

    init(onFinished: @escaping (Order) -> Void) {
        self.onFinished = onFinished
    }

    var body: some View {
        Form {
            Section("Người nhận") {
                TextField("Họ và tên", text: $name)
                    .textContentType(.name)
                TextField("Số điện thoại (10 số)", text: $phone)
                    .keyboardType(.phonePad)
                    .textContentType(.telephoneNumber)
                TextField("Địa chỉ giao hàng", text: $address, axis: .vertical)
                    .lineLimit(1...3)
            }

            Section("Ghi chú") {
                TextField("Ví dụ: gọi trước khi giao", text: $note)
            }

            Section("Sản phẩm (\(cartController.totalQuantity))") {
                ForEach(cartController.items) { item in
                    HStack {
                        Text(item.product.name)
                            .lineLimit(1)
                        Text("× \(item.quantity)")
                            .foregroundStyle(.secondary)
                        Spacer()
                        Text(item.subtotal.vnd)
                    }
                    .font(.subheadline)
                }
            }

            Section {
                SummaryRow(title: "Tạm tính", value: cartController.subtotal.vnd)
                SummaryRow(title: "Phí giao hàng",
                           value: cartController.shippingFee == 0 ? "Miễn phí" : cartController.shippingFee.vnd)
                SummaryRow(title: "Tổng thanh toán",
                           value: cartController.total.vnd,
                           isEmphasized: true,
                           valueColor: AppTheme.price)
                Label("Thanh toán khi nhận hàng (COD)", systemImage: "banknote")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }

            if let errorMessage {
                Section {
                    Label(errorMessage, systemImage: "exclamationmark.triangle.fill")
                        .foregroundStyle(.red)
                }
            }

            Section {
                Button {
                    placeOrder()
                } label: {
                    Text("Xác nhận đặt hàng")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                }
                .disabled(cartController.isEmpty)
            }
        }
        .navigationTitle("Thanh toán")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Đặt hàng thành công 🎉",
               isPresented: Binding(get: { placedOrder != nil },
                                    set: { if !$0 { placedOrder = nil } }),
               presenting: placedOrder) { order in
            Button("Xem đơn hàng") { onFinished(order) }
        } message: { order in
            Text("Mã đơn \(order.code) – tổng \(order.total.vnd).\nCửa hàng sẽ liên hệ \(order.phoneNumber) để xác nhận.")
        }
    }

    private func placeOrder() {
        let order = orderController.placeOrder(cart: cartController,
                                               productController: productController,
                                               customerName: name,
                                               phone: phone,
                                               address: address,
                                               note: note)
        if let order {
            errorMessage = nil
            placedOrder = order
        } else {
            errorMessage = orderController.errorMessage
        }
    }
}
