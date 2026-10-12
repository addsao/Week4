//
//  ProductFormView.swift
//  FishStore
//
//  Form thêm mới / sửa sản phẩm.
//  Bấm Lưu → ProductController ghi vào fish.txt.
//

import SwiftUI

struct ProductFormView: View {

    @EnvironmentObject private var productController: ProductController
    @Environment(\.dismiss) private var dismiss

    /// nil = thêm mới, có giá trị = đang sửa.
    let editing: Product?

    @State private var name: String
    @State private var categoryId: Int
    @State private var priceText: String
    @State private var stockText: String
    @State private var descriptionText: String
    @State private var imageName: String
    @State private var errorMessage: String?

    init(editing: Product? = nil, defaultCategoryId: Int = 1) {
        self.editing = editing
        _name            = State(initialValue: editing?.name ?? "")
        _categoryId      = State(initialValue: editing?.categoryId ?? defaultCategoryId)
        _priceText       = State(initialValue: editing.map { String(Int($0.price)) } ?? "")
        _stockText       = State(initialValue: editing.map { String($0.stock) } ?? "")
        _descriptionText = State(initialValue: editing?.description ?? "")
        _imageName       = State(initialValue: editing?.imageName ?? "")
    }

    private var isEditing: Bool { editing != nil }

    var body: some View {
        NavigationStack {
            Form {
                Section("Thông tin") {
                    TextField("Tên sản phẩm (vd: Cá bảy màu)", text: $name)

                    Picker("Danh mục", selection: $categoryId) {
                        ForEach(productController.categories) { category in
                            Label(category.name, systemImage: category.iconName)
                                .tag(category.id)
                        }
                    }
                }

                Section("Giá & tồn kho") {
                    HStack {
                        TextField("Giá", text: $priceText)
                            .keyboardType(.numberPad)
                        Text("VNĐ").foregroundStyle(.secondary)
                    }
                    HStack {
                        TextField("Số lượng", text: $stockText)
                            .keyboardType(.numberPad)
                        Text("sản phẩm").foregroundStyle(.secondary)
                    }
                }

                Section("Mô tả") {
                    TextField("Mô tả ngắn về sản phẩm", text: $descriptionText, axis: .vertical)
                        .lineLimit(3...6)
                }

                Section {
                    TextField("Tên ảnh trong Assets (vd: guppy)", text: $imageName)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                } header: {
                    Text("Hình ảnh")
                } footer: {
                    Text("Để trống sẽ dùng icon của danh mục.")
                }

                if let errorMessage {
                    Section {
                        Label(errorMessage, systemImage: "exclamationmark.triangle.fill")
                            .foregroundStyle(.red)
                    }
                }
            }
            .navigationTitle(isEditing ? "Sửa sản phẩm" : "Thêm sản phẩm")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Hủy") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Lưu") { save() }
                        .bold()
                }
            }
        }
    }

    // MARK: - Lưu

    private func save() {
        // Chỉ giữ chữ số: "10.000" → 10000
        let priceDigits = priceText.filter(\.isNumber)
        let stockDigits = stockText.filter(\.isNumber)
        let price = Double(priceDigits)
        let stock = Int(stockDigits)

        if let error = productController.validate(name: name, price: price,
                                                  stock: stock, categoryId: categoryId) {
            errorMessage = error
            return
        }
        guard let price, let stock else { return }

        if var product = editing {
            product.name = name.trimmed
            product.categoryId = categoryId
            product.price = price
            product.stock = stock
            product.description = descriptionText.trimmed
            product.imageName = imageName.trimmed

            if productController.updateProduct(product) {
                dismiss()
            } else {
                errorMessage = productController.errorMessage ?? "Không lưu được."
            }
        } else {
            let added = productController.addProduct(name: name,
                                                     categoryId: categoryId,
                                                     price: price,
                                                     stock: stock,
                                                     description: descriptionText,
                                                     imageName: imageName)
            if added != nil {
                dismiss()
            } else {
                errorMessage = productController.errorMessage ?? "Không lưu được."
            }
        }
    }
}
