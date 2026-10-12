//
//  CartController.swift
//  FishStore
//
//  CONTROLLER quản lý giỏ hàng (lưu trong bộ nhớ khi app đang chạy).
//

import Foundation
import Combine

final class CartController: ObservableObject {

    @Published private(set) var items: [CartItem] = []

    /// Thông báo ngắn để View hiện toast ("Đã thêm ... vào giỏ").
    @Published var message: String?

    // MARK: - Tổng tiền

    var isEmpty: Bool { items.isEmpty }

    /// Tổng số lượng (hiện trên badge giỏ hàng).
    var totalQuantity: Int { items.reduce(0) { $0 + $1.quantity } }

    var subtotal: Double { items.reduce(0) { $0 + $1.subtotal } }

    var shippingFee: Double { Order.shippingFee(for: subtotal) }

    var total: Double { subtotal + shippingFee }

    /// Còn thiếu bao nhiêu để được miễn phí ship.
    var amountToFreeShipping: Double {
        max(0, Order.freeShippingThreshold - subtotal)
    }

    func quantityInCart(of productId: Int) -> Int {
        items.first { $0.product.id == productId }?.quantity ?? 0
    }

    // MARK: - Thao tác

    /// Thêm sản phẩm. Không cho vượt quá tồn kho.
    @discardableResult
    func add(_ product: Product, quantity: Int = 1) -> Bool {
        guard quantity > 0 else { return false }
        guard product.isInStock else {
            message = "\(product.name) đã hết hàng"
            return false
        }

        let current = quantityInCart(of: product.id)
        guard current + quantity <= product.stock else {
            message = "Chỉ còn \(product.stock) sản phẩm \(product.name)"
            return false
        }

        if let index = items.firstIndex(where: { $0.product.id == product.id }) {
            items[index].quantity += quantity
            items[index].product = product
        } else {
            items.append(CartItem(product: product, quantity: quantity))
        }
        message = "Đã thêm \(product.name) vào giỏ"
        return true
    }

    func increase(_ item: CartItem) {
        guard let index = items.firstIndex(where: { $0.id == item.id }) else { return }
        guard items[index].canIncrease else {
            message = "Đã đạt số lượng tối đa trong kho"
            return
        }
        items[index].quantity += 1
    }

    /// Giảm 1. Nếu đang là 1 thì xóa khỏi giỏ.
    func decrease(_ item: CartItem) {
        guard let index = items.firstIndex(where: { $0.id == item.id }) else { return }
        if items[index].quantity > 1 {
            items[index].quantity -= 1
        } else {
            items.remove(at: index)
        }
    }

    func remove(_ item: CartItem) {
        items.removeAll { $0.id == item.id }
    }

    func remove(at offsets: IndexSet) {
        items.remove(atOffsets: offsets)
    }

    func clear() {
        items.removeAll()
    }

    /// Đồng bộ với danh sách sản phẩm mới nhất:
    /// cập nhật giá, bỏ sản phẩm đã xóa / hết hàng, giảm số lượng nếu vượt tồn kho.
    func sync(with products: [Product]) {
        let updated: [CartItem] = items.compactMap { item in
            guard let product = products.first(where: { $0.id == item.product.id }),
                  product.isInStock else { return nil }
            return CartItem(product: product, quantity: min(item.quantity, product.stock))
        }
        if updated != items { items = updated }
    }
}
