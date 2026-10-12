//
//  ProductDetailView.swift
//  FishStore
//
//  Chi tiết sản phẩm: ảnh, giá, tồn kho, mô tả, chọn số lượng, thêm vào giỏ.
//  Nhận `productId` rồi tra cứu từ controller → luôn hiển thị dữ liệu mới nhất.
//

import SwiftUI

struct ProductDetailView: View {

    @EnvironmentObject private var productController: ProductController
    @EnvironmentObject private var cartController: CartController

    let productId: Int

    @State private var quantity = 1
    @State private var showEditForm = false

    var body: some View {
        Group {
            if let product = productController.product(id: productId) {
                detail(product)
            } else {
                EmptyStateView(icon: "questionmark.folder",
                               title: "Không tìm thấy sản phẩm",
                               message: "Sản phẩm có thể đã bị xóa khỏi fish.txt.")
            }
        }
        .navigationTitle("Chi tiết sản phẩm")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Nội dung

    private func detail(_ product: Product) -> some View {
        let tint = productController.tint(for: product)
        let inCart = cartController.quantityInCart(of: product.id)

        return ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                ProductImageView(imageName: product.imageName,
                                 fallbackSymbol: productController.iconName(for: product),
                                 tint: tint,
                                 symbolSize: 90)
                    .frame(height: 260)
                    .frame(maxWidth: .infinity)
                    .clipShape(RoundedRectangle(cornerRadius: 20))

                VStack(alignment: .leading, spacing: 8) {
                    Text(productController.categoryName(of: product))
                        .font(.caption.bold())
                        .foregroundStyle(tint)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(Capsule().fill(tint.opacity(0.14)))

                    Text(product.name)
                        .font(.title2.bold())

                    Text(product.formattedPrice)
                        .font(.title3.bold())
                        .foregroundStyle(AppTheme.price)

                    Label(product.stockText,
                          systemImage: product.isInStock ? "checkmark.circle.fill" : "xmark.circle.fill")
                        .font(.subheadline)
                        .foregroundStyle(stockColor(product))

                    if inCart > 0 {
                        Label("Đã có \(inCart) trong giỏ hàng", systemImage: "cart.fill")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                }

                VStack(alignment: .leading, spacing: 6) {
                    Text("Mô tả")
                        .font(.headline)
                    Text(product.description.isEmpty ? "Chưa có mô tả." : product.description)
                        .foregroundStyle(.secondary)
                }

                VStack(alignment: .leading, spacing: 6) {
                    Text("Mã sản phẩm: \(product.id)")
                    Text("Phí ship 30.000đ – miễn phí cho đơn từ 500.000đ")
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }
            .padding()
        }
        .background(AppTheme.background)
        .safeAreaInset(edge: .bottom) { bottomBar(product, inCart: inCart) }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("Sửa") { showEditForm = true }
            }
        }
        .sheet(isPresented: $showEditForm) {
            ProductFormView(editing: product)
        }
    }

    // MARK: - Thanh thêm vào giỏ

    private func bottomBar(_ product: Product, inCart: Int) -> some View {
        let available = product.stock - inCart

        return HStack(spacing: 12) {
            QuantityStepper(value: $quantity, range: 1...max(1, available))
                .disabled(available <= 0)

            Button {
                if cartController.add(product, quantity: min(quantity, max(1, available))) {
                    quantity = 1
                }
            } label: {
                Text(available > 0 ? "Thêm vào giỏ" : (product.isInStock ? "Đã lấy hết hàng" : "Hết hàng"))
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(RoundedRectangle(cornerRadius: 14)
                        .fill(available > 0 ? AppTheme.primary : Color.gray))
            }
            .disabled(available <= 0)
        }
        .padding()
        .background(.ultraThinMaterial)
    }

    private func stockColor(_ product: Product) -> Color {
        if !product.isInStock { return .gray }
        return product.isLowStock ? .orange : .green
    }
}
