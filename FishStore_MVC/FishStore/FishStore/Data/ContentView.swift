//
//  ContentView.swift
//  FishStore
//
//  Màn hình gốc: thanh tab 5 mục + thông báo nhanh (toast).
//

import SwiftUI

enum AppTab: Hashable {
    case home, categories, cart, orders, manage
}

struct ContentView: View {

    @EnvironmentObject private var productController: ProductController
    @EnvironmentObject private var cartController: CartController

    @State private var selectedTab: AppTab = .home
    @State private var toastText: String?

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView(selectedTab: $selectedTab)
                .tabItem { Label("Trang chủ", systemImage: "house.fill") }
                .tag(AppTab.home)

            CategoryListView()
                .tabItem { Label("Danh mục", systemImage: "square.grid.2x2.fill") }
                .tag(AppTab.categories)

            CartView(selectedTab: $selectedTab)
                .tabItem { Label("Giỏ hàng", systemImage: "cart.fill") }
                .badge(cartController.totalQuantity)
                .tag(AppTab.cart)

            OrderListView()
                .tabItem { Label("Đơn hàng", systemImage: "doc.text.fill") }
                .tag(AppTab.orders)

            ManageProductsView()
                .tabItem { Label("Quản lý", systemImage: "gearshape.fill") }
                .tag(AppTab.manage)
        }
        .tint(AppTheme.primary)
        // Sản phẩm thay đổi (sửa giá, xóa, trừ kho) → cập nhật lại giỏ hàng
        .onReceive(productController.$products) { products in
            cartController.sync(with: products)
        }
        // Hiện toast khi giỏ hàng có thông báo mới
        .onReceive(cartController.$message) { message in
            guard let message else { return }
            showToast(message)
            cartController.message = nil
        }
        .overlay(alignment: .bottom) {
            if let toastText {
                ToastView(text: toastText)
                    .padding(.bottom, 70)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
    }

    private func showToast(_ text: String) {
        withAnimation(.spring()) { toastText = text }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
            if toastText == text {
                withAnimation { toastText = nil }
            }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(ProductController())
        .environmentObject(CartController())
        .environmentObject(OrderController())
}
