//
//  Product.swift
//  FishStore
//
//  Sản phẩm (cá, cây, bể, thiết bị...) – đọc từ fish.txt
//
//  Định dạng 1 dòng:
//    id, "tên", categoryId, giá, tồn kho, "mô tả", "tên ảnh"
//  Ví dụ:
//    1, "Cá bảy màu", 1, 10000, 45, "Cá guppy nhiều màu", "guppy"
//
//  "mô tả" và "tên ảnh" có thể bỏ trống → dòng ngắn như slide vẫn đọc được:
//    1, "Cá bảy màu", 1, 10000, 45
//

import Foundation

struct Product: Identifiable, Hashable {

    let id: Int
    var name: String
    var categoryId: Int
    var price: Double
    var stock: Int
    var description: String
    var imageName: String

    /// Còn từ mức này trở xuống thì coi là "sắp hết hàng".
    static let lowStockThreshold = 5

    init(id: Int,
         name: String,
         categoryId: Int,
         price: Double,
         stock: Int,
         description: String = "",
         imageName: String = "") {
        self.id = id
        self.name = name
        self.categoryId = categoryId
        self.price = max(0, price)
        self.stock = max(0, stock)
        self.description = description
        self.imageName = imageName
    }

    // MARK: - Đọc / ghi txt

    init?(line: String) {
        let f = TxtFormat.splitFields(line)
        guard f.count >= 5,
              let id = Int(f[0]),
              let categoryId = Int(f[2]),
              let price = Double(f[3]),
              let stock = Int(f[4]) else {
            print("⚠️ fish.txt – bỏ qua dòng sai định dạng: \(line)")
            return nil
        }
        self.init(id: id,
                  name: f[1],
                  categoryId: categoryId,
                  price: price,
                  stock: stock,
                  description: f.count > 5 ? f[5] : "",
                  imageName: f.count > 6 ? f[6] : "")
    }

    var txtLine: String {
        "\(id), \(TxtFormat.quote(name)), \(categoryId), \(Int(price)), \(stock), "
        + "\(TxtFormat.quote(description)), \(TxtFormat.quote(imageName))"
    }

    // MARK: - Thuộc tính tính toán

    var isInStock: Bool { stock > 0 }

    var isLowStock: Bool { isInStock && stock <= Product.lowStockThreshold }

    var formattedPrice: String { price.vnd }

    var stockText: String {
        if !isInStock { return "Hết hàng" }
        if isLowStock { return "Chỉ còn \(stock) sản phẩm" }
        return "Còn \(stock) sản phẩm"
    }

    /// Tìm kiếm không phân biệt hoa thường và dấu: "ca neon" khớp "Cá Neon Tetra".
    func matches(_ keyword: String) -> Bool {
        let key = keyword.trimmed.searchKey
        if key.isEmpty { return true }
        return name.searchKey.contains(key) || description.searchKey.contains(key)
    }
}
