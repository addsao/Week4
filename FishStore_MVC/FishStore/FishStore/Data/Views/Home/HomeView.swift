//
//  HomeView.swift
//  FishStore
//
//  Màn hình chính: header, địa chỉ, tìm kiếm, banner, danh mục, sản phẩm nổi bật.
//

import SwiftUI

struct HomeView: View {

    @EnvironmentObject private var productController: ProductController
    @EnvironmentObject private var cartController: CartController
    @EnvironmentObject private var orderController: OrderController

    @Binding var selectedTab: AppTab
    @State private var searchText = ""

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    HomeHeaderView(
                        cartCount: cartController.totalQuantity,
                        notificationCount: orderController.count(status: .shipping),
                        onNotificationTap: { selectedTab = .orders },
                        onCartTap: { selectedTab = .cart }
                    )

                    LocationRowView(address: AppTheme.defaultAddress)

                    SearchBarView(text: $searchText)

                    if searchText.trimmed.isEmpty {
                        BannerView()

                        CategoryRowView(
                            categories: productController.categories,
                            onSeeAll: { selectedTab = .categories }
                        )

                        ProductSectionView(
                            title: "Sản phẩm nổi bật",
                            products: productController.featuredProducts
                        )
                    } else {
                        ProductSectionView(
                            title: "Kết quả cho \"\(searchText.trimmed)\"",
                            products: productController.search(searchText)
                        )
                    }
                }
                .padding(.vertical, 8)
            }
            .background(
                LinearGradient(colors: [AppTheme.primary.opacity(0.12), AppTheme.background],
                               startPoint: .top, endPoint: .center)
                    .ignoresSafeArea()
            )
            .scrollDismissesKeyboard(.immediately)
            .refreshable { productController.load() }
            .toolbar(.hidden, for: .navigationBar)
            .appDestinations()
        }
    }
}
