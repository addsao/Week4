//
//  ProductController.swift
//  FishStore
//
//  CONTROLLER quản lý danh mục và sản phẩm.
//
//  - Đọc category.txt + fish.txt khi khởi tạo.
//  - Cung cấp dữ liệu đã lọc / tìm kiếm cho View.
//  - Thêm / sửa / xóa sản phẩm và ghi lại vào fish.txt.
//
//  View KHÔNG đọc file trực tiếp mà luôn đi qua controller này.
//

import Foundation
import Combine

final class ProductController: ObservableObject {

    // MARK: - Dữ liệu cho View

    @Published private(set) var categories: [ProductCategory] = []
    @Published private(set) var products: [Product] = []
    @Published var errorMessage: String?

    private let storage: TxtStorage

    init(storage: TxtStorage = .shared) {
        self.storage = storage
        load()
    }

    // MARK: - Đọc file

    /// Đọc lại toàn bộ dữ liệu từ 2 file txt.
    func load() {
        categories = storage
            .readLines(TxtStorage.categoryFile)
            .compactMap(ProductCategory.init(line:))

        products = storage
            .readLines(TxtStorage.productFile)
            .compactMap(Product.init(line:))
    }

    /// Chép lại category.txt và fish.txt gốc từ Bundle rồi đọc lại.
    func resetSampleData() {
        storage.resetToDefault(TxtStorage.categoryFile)
        storage.resetToDefault(TxtStorage.productFile)
        load()
    }

    /// Đường dẫn fish.txt trong máy (để mở bằng Finder khi chạy Simulator).
    var dataFilePath: String {
        storage.url(for: TxtStorage.productFile).path
    }

    // MARK: - Truy vấn

    /// Sản phẩm nổi bật cho màn hình chính: 6 sản phẩm còn hàng đầu tiên.
    var featuredProducts: [Product] {
        Array(products.filter { $0.isInStock }.prefix(6))
    }

    func products(in categoryId: Int) -> [Product] {
        products.filter { $0.categoryId == categoryId }
    }

    func productCount(in categoryId: Int) -> Int {
        products.filter { $0.categoryId == categoryId }.count
    }

    /// Tìm theo từ khoá, có thể giới hạn trong 1 danh mục.
    func search(_ keyword: String, in categoryId: Int? = nil) -> [Product] {
        products.filter { product in
            (categoryId == nil || product.categoryId == categoryId) && product.matches(keyword)
        }
    }

    func product(id: Int) -> Product? {
        products.first { $0.id == id }
    }

    func category(id: Int) -> ProductCategory? {
        categories.first { $0.id == id }
    }

    func categoryName(of product: Product) -> String {
        category(id: product.categoryId)?.name ?? "Chưa phân loại"
    }

    func iconName(for product: Product) -> String {
        category(id: product.categoryId)?.iconName ?? "fish.fill"
    }

    var outOfStockCount: Int {
        products.filter { !$0.isInStock }.count
    }

    // MARK: - Kiểm tra dữ liệu nhập

    /// Trả về thông báo lỗi, hoặc nil nếu dữ liệu hợp lệ.
    func validate(name: String, price: Double?, stock: Int?, categoryId: Int) -> String? {
        if name.trimmed.isEmpty { return "Tên sản phẩm không được để trống." }
        guard let price, price >= 0 else { return "Giá phải là số và không âm." }
        if price > 1_000_000_000 { return "Giá quá lớn." }
        guard let stock, stock >= 0 else { return "Số lượng phải là số nguyên không âm." }
        if category(id: categoryId) == nil { return "Vui lòng chọn danh mục hợp lệ." }
        return nil
    }

    // MARK: - Thêm / sửa / xóa

    private var nextProductId: Int {
        (products.map(\.id).max() ?? 0) + 1
    }

    /// Thêm sản phẩm mới → ghi thêm 1 dòng vào cuối fish.txt.
    @discardableResult
    func addProduct(name: String,
                    categoryId: Int,
                    price: Double,
                    stock: Int,
                    description: String,
                    imageName: String) -> Product? {
        let product = Product(id: nextProductId,
                              name: name.trimmed,
                              categoryId: categoryId,
                              price: price,
                              stock: stock,
                              description: description.trimmed,
                              imageName: imageName.trimmed)
        do {
            try storage.appendLine(product.txtLine, to: TxtStorage.productFile)
            products.append(product)
            errorMessage = nil
            return product
        } catch {
            errorMessage = "Không ghi được fish.txt: \(error.localizedDescription)"
            return nil
        }
    }

    /// Sửa sản phẩm → ghi đè lại fish.txt.
    @discardableResult
    func updateProduct(_ product: Product) -> Bool {
        guard let index = products.firstIndex(where: { $0.id == product.id }) else { return false }
        let oldValue = products[index]
        products[index] = product
        if saveProducts() { return true }
        products[index] = oldValue        // ghi lỗi → trả lại như cũ
        return false
    }

    /// Xóa sản phẩm → ghi đè lại fish.txt.
    @discardableResult
    func deleteProduct(_ product: Product) -> Bool {
        let oldList = products
        products.removeAll { $0.id == product.id }
        if saveProducts() { return true }
        products = oldList
        return false
    }

    /// Cộng / trừ tồn kho nhiều sản phẩm cùng lúc (dùng khi đặt hoặc hủy đơn).
    /// `changes`: [productId: số lượng thay đổi], ví dụ [2: -10] là trừ 10 con.
    @discardableResult
    func applyStockChanges(_ changes: [Int: Int]) -> Bool {
        guard !changes.isEmpty else { return true }
        let oldList = products
        for (productId, delta) in changes {
            if let index = products.firstIndex(where: { $0.id == productId }) {
                products[index].stock = max(0, products[index].stock + delta)
            }
        }
        if saveProducts() { return true }
        products = oldList
        return false
    }

    private func saveProducts() -> Bool {
        do {
            try storage.writeLines(products.map(\.txtLine), to: TxtStorage.productFile)
            errorMessage = nil
            return true
        } catch {
            errorMessage = "Không ghi được fish.txt: \(error.localizedDescription)"
            return false
        }
    }
}
