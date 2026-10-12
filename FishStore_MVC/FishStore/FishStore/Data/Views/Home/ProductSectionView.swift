//
//  ProductSectionView.swift
//  FishStore
//
//  Tiêu đề + lưới 2 cột ProductCardView.
//

import SwiftUI

struct ProductSectionView: View {
    let title: String
    let products: [Product]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
                .padding(.horizontal)

            if products.isEmpty {
                EmptyStateView(icon: "magnifyingglass",
                               title: "Không có sản phẩm",
                               message: "Thử từ khoá khác hoặc thêm sản phẩm trong tab Quản lý.")
                    .frame(height: 260)
            } else {
                ProductGridView(products: products)
            }
        }
    }
}

/// Lưới 2 cột sản phẩm, dùng ở Home và trang danh mục.
struct ProductGridView: View {
    let products: [Product]

    private let columns = [GridItem(.flexible(), spacing: 12),
                           GridItem(.flexible(), spacing: 12)]

    var body: some View {
        LazyVGrid(columns: columns, spacing: 12) {
            ForEach(products) { product in
                ProductCardView(product: product)
            }
        }
        .padding(.horizontal)
    }
}
