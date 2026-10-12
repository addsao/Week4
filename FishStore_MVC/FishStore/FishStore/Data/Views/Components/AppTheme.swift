//
//  AppTheme.swift
//  FishStore
//
//  Màu sắc và thông tin cửa hàng dùng chung cho toàn bộ giao diện.
//

import SwiftUI

enum AppTheme {
    static let primary    = Color(red: 0.07, green: 0.42, blue: 0.85)   // xanh dương
    static let accent     = Color(red: 1.00, green: 0.45, blue: 0.20)   // cam
    static let price      = Color(red: 0.86, green: 0.16, blue: 0.16)   // đỏ giá tiền
    static let background = Color(.systemGroupedBackground)
    static let card       = Color(.secondarySystemGroupedBackground)

    static let storeName      = "Cá Cảnh Xinh"
    static let slogan         = "Thế giới thủy sinh trong tầm tay"
    static let defaultAddress = "Phường Trấn Biên, Thành phố Đồng Nai"

    /// Bảng màu cho các danh mục.
    static let categoryPalette: [Color] = [
        Color(red: 1.00, green: 0.45, blue: 0.20),
        Color(red: 0.20, green: 0.65, blue: 0.30),
        Color(red: 0.10, green: 0.55, blue: 0.85),
        Color(red: 0.45, green: 0.45, blue: 0.50),
        Color(red: 0.25, green: 0.35, blue: 0.60),
        Color(red: 0.85, green: 0.50, blue: 0.10),
        Color(red: 0.20, green: 0.45, blue: 0.95),
        Color(red: 0.90, green: 0.30, blue: 0.30)
    ]
}

extension ProductCategory {
    /// Màu riêng của danh mục.
    var tint: Color {
        AppTheme.categoryPalette[abs(id) % AppTheme.categoryPalette.count]
    }
}

extension OrderStatus {
    var color: Color {
        switch self {
        case .pending:   return .orange
        case .preparing: return .blue
        case .shipping:  return .purple
        case .delivered: return .green
        case .cancelled: return .red
        }
    }
}

extension ProductController {
    /// Màu của danh mục chứa sản phẩm.
    func tint(for product: Product) -> Color {
        category(id: product.categoryId)?.tint ?? AppTheme.primary
    }
}
