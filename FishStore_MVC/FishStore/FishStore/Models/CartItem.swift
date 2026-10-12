//
//  CartItem.swift
//  FishStore
//
//  Một dòng trong giỏ hàng = 1 sản phẩm + số lượng.
//  Mỗi sản phẩm chỉ có 1 dòng → dùng luôn id sản phẩm làm id.
//

import Foundation

struct CartItem: Identifiable, Hashable {

    var product: Product
    var quantity: Int

    var id: Int { product.id }

    init(product: Product, quantity: Int = 1) {
        self.product = product
        self.quantity = max(1, quantity)
    }

    /// Thành tiền = đơn giá × số lượng.
    var subtotal: Double { product.price * Double(quantity) }

    /// Còn tăng được số lượng không (không vượt tồn kho).
    var canIncrease: Bool { quantity < product.stock }
}
