//
//  CartView.swift
//  FishStore
//
//  Tab "Giỏ hàng": danh sách sản phẩm đã chọn, tăng / giảm số lượng, tổng tiền.
//

import SwiftUI

struct CartView: View {

    @EnvironmentObject private var cartController: CartController

    @Binding var selectedTab: AppTab
    @State private var showCheckout = false
    @State private var showClearConfirm = false

    var body: some View {
        NavigationStack {
            Group {
                if cartController.isEmpty {
                    EmptyStateView(icon: "cart",
                                   title: "Giỏ hàng trống",
                                   message: "Hãy chọn vài chú cá xinh cho bể của bạn nhé!",
                                   actionTitle: "Mua sắm ngay",
                                   action: { selectedTab = .home })
                } else {
                    cartList
                }
            }
            .background(AppTheme.background)
            .navigationTitle("Giỏ hàng")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button("Xóa hết", role: .destructive) { showClearConfirm = true }
                        .disabled(cartController.isEmpty)
                }
            }
            .confirmationDialog("Xóa toàn bộ giỏ hàng?", isPresented: $showClearConfirm, titleVisibility: .visible) {
                Button("Xóa hết", role: .destructive) { cartController.clear() }
            }
            .navigationDestination(isPresented: $showCheckout) {
                CheckoutView { _ in
                    showCheckout = false
                    selectedTab = .orders
                }
            }
            .appDestinations()
        }
    }

    // MARK: - Danh sách

    private var cartList: some View {
        List {
            Section {
                ForEach(cartController.items) { item in
                    CartRowView(item: item)
                }
                .onDelete { cartController.remove(at: $0) }
            } header: {
                Text("\(cartController.totalQuantity) sản phẩm")
            }

            Section {
                SummaryRow(title: "Tạm tính", value: cartController.subtotal.vnd)
                SummaryRow(title: "Phí giao hàng",
                           value: cartController.shippingFee == 0 ? "Miễn phí" : cartController.shippingFee.vnd,
                           valueColor: cartController.shippingFee == 0 ? .green : .primary)
                SummaryRow(title: "Tổng cộng",
                           value: cartController.total.vnd,
                           isEmphasized: true,
                           valueColor: AppTheme.price)
            } footer: {
                if cartController.amountToFreeShipping > 0 {
                    Text("Mua thêm \(cartController.amountToFreeShipping.vnd) để được miễn phí giao hàng 🚚")
                } else {
                    Text("Đơn hàng của bạn được miễn phí giao hàng 🎉")
                }
            }
        }
        .listStyle(.insetGrouped)
        .safeAreaInset(edge: .bottom) {
            Button {
                showCheckout = true
            } label: {
                HStack {
                    Text("Đặt hàng")
                    Spacer()
                    Text(cartController.total.vnd)
                }
                .font(.headline)
                .foregroundStyle(.white)
                .padding()
                .background(RoundedRectangle(cornerRadius: 14).fill(AppTheme.primary))
            }
            .padding()
            .background(.ultraThinMaterial)
        }
    }
}

// MARK: - Một dòng giỏ hàng

struct CartRowView: View {

    @EnvironmentObject private var productController: ProductController
    @EnvironmentObject private var cartController: CartController

    let item: CartItem

    var body: some View {
        HStack(spacing: 12) {
            ProductImageView(imageName: item.product.imageName,
                             fallbackSymbol: productController.iconName(for: item.product),
                             tint: productController.tint(for: item.product),
                             symbolSize: 24)
                .frame(width: 64, height: 64)
                .clipShape(RoundedRectangle(cornerRadius: 12))

            VStack(alignment: .leading, spacing: 4) {
                Text(item.product.name)
                    .font(.subheadline.bold())
                    .lineLimit(2)
                Text(item.product.formattedPrice)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(item.subtotal.vnd)
                    .font(.subheadline.bold())
                    .foregroundStyle(AppTheme.price)
            }

            Spacer(minLength: 4)

            HStack(spacing: 10) {
                Button {
                    cartController.decrease(item)
                } label: {
                    Image(systemName: item.quantity > 1 ? "minus.circle.fill" : "trash.circle.fill")
                        .font(.title2)
                        .foregroundStyle(item.quantity > 1 ? AppTheme.primary : Color.red)
                }
                .buttonStyle(.borderless)

                Text("\(item.quantity)")
                    .font(.headline)
                    .frame(minWidth: 24)

                Button {
                    cartController.increase(item)
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                        .foregroundStyle(item.canIncrease ? AppTheme.primary : Color.gray)
                }
                .buttonStyle(.borderless)
                .disabled(!item.canIncrease)
            }
        }
        .padding(.vertical, 4)
    }
}
