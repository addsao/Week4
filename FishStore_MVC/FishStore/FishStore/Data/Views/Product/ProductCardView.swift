//
//  ProductCardView.swift
//  FishStore
//
//  Thẻ hiển thị 1 sản phẩm. Bấm vào thẻ → chi tiết; bấm nút + → thêm vào giỏ.
//

import SwiftUI

struct ProductCardView: View {

    @EnvironmentObject private var productController: ProductController
    @EnvironmentObject private var cartController: CartController

    let product: Product

    var body: some View {
        NavigationLink(value: product) {
            VStack(alignment: .leading, spacing: 6) {
                ProductImageView(imageName: product.imageName,
                                 fallbackSymbol: productController.iconName(for: product),
                                 tint: productController.tint(for: product),
                                 symbolSize: 40)
                    .frame(height: 110)
                    .frame(maxWidth: .infinity)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(alignment: .topLeading) { stockBadge }

                Text(product.name)
                    .font(.subheadline.weight(.semibold))
                    .lineLimit(2, reservesSpace: true)

                Text(productController.categoryName(of: product))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)

                Text(product.formattedPrice)
                    .font(.subheadline.bold())
                    .foregroundStyle(AppTheme.price)
                    .padding(.trailing, 36)      // chừa chỗ cho nút +
            }
            .padding(10)
            .background(RoundedRectangle(cornerRadius: 16).fill(AppTheme.card))
            .shadow(color: .black.opacity(0.06), radius: 6, y: 3)
        }
        .buttonStyle(.plain)
        .overlay(alignment: .bottomTrailing) {
            Button {
                cartController.add(product)
            } label: {
                Image(systemName: "plus")
                    .font(.subheadline.bold())
                    .foregroundStyle(.white)
                    .frame(width: 30, height: 30)
                    .background(Circle().fill(product.isInStock ? AppTheme.primary : Color.gray))
            }
            .buttonStyle(.plain)
            .disabled(!product.isInStock)
            .padding(10)
        }
    }

    @ViewBuilder
    private var stockBadge: some View {
        if !product.isInStock {
            badge("Hết hàng", color: .gray)
        } else if product.isLowStock {
            badge("Sắp hết", color: AppTheme.accent)
        }
    }

    private func badge(_ text: String, color: Color) -> some View {
        Text(text)
            .font(.caption2.bold())
            .foregroundStyle(.white)
            .padding(.horizontal, 6)
            .padding(.vertical, 3)
            .background(Capsule().fill(color))
            .padding(6)
    }
}
