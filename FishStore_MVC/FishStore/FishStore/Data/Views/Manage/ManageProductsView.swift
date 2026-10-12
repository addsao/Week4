//
//  ManageProductsView.swift
//  FishStore
//
//  Tab "Quản lý": thống kê, thêm / sửa / xóa sản phẩm (ghi vào fish.txt),
//  đọc lại file và khôi phục dữ liệu mẫu.
//

import SwiftUI

struct ManageProductsView: View {

    @EnvironmentObject private var productController: ProductController
    @EnvironmentObject private var orderController: OrderController

    @State private var searchText = ""
    @State private var showAddForm = false
    @State private var editingProduct: Product?
    @State private var productToDelete: Product?
    @State private var showResetConfirm = false

    var body: some View {
        NavigationStack {
            List {
                Section {
                    statsGrid
                        .listRowInsets(EdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8))
                        .listRowBackground(Color.clear)
                }

                ForEach(productController.categories) { category in
                    let items = productController.search(searchText, in: category.id)
                    if !items.isEmpty {
                        Section("\(category.name) (\(items.count))") {
                            ForEach(items) { product in
                                ManageProductRow(product: product)
                                    .contentShape(Rectangle())
                                    .onTapGesture { editingProduct = product }
                                    .swipeActions(edge: .trailing) {
                                        Button(role: .destructive) {
                                            productToDelete = product
                                        } label: {
                                            Label("Xóa", systemImage: "trash")
                                        }
                                        Button {
                                            editingProduct = product
                                        } label: {
                                            Label("Sửa", systemImage: "pencil")
                                        }
                                        .tint(AppTheme.primary)
                                    }
                            }
                        }
                    }
                }

                Section {
                    Text(productController.dataFilePath)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .textSelection(.enabled)
                } header: {
                    Text("Vị trí file fish.txt")
                } footer: {
                    Text("Chạy trên Simulator: copy đường dẫn này, mở Finder → Cmd+Shift+G để xem file.")
                }
            }
            .listStyle(.insetGrouped)
            .searchable(text: $searchText, prompt: "Tìm sản phẩm")
            .navigationTitle("Quản lý")
            .refreshable { productController.load() }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Menu {
                        Button {
                            productController.load()
                            orderController.load()
                        } label: {
                            Label("Đọc lại file txt", systemImage: "arrow.clockwise")
                        }
                        Button(role: .destructive) {
                            showResetConfirm = true
                        } label: {
                            Label("Khôi phục dữ liệu mẫu", systemImage: "arrow.counterclockwise")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showAddForm = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showAddForm) {
                ProductFormView()
            }
            .sheet(item: $editingProduct) { product in
                ProductFormView(editing: product)
            }
            .confirmationDialog("Xóa sản phẩm?",
                                isPresented: Binding(get: { productToDelete != nil },
                                                     set: { if !$0 { productToDelete = nil } }),
                                titleVisibility: .visible,
                                presenting: productToDelete) { product in
                Button("Xóa \(product.name)", role: .destructive) {
                    productController.deleteProduct(product)
                }
            } message: { _ in
                Text("Dòng sản phẩm này sẽ bị xóa khỏi fish.txt.")
            }
            .alert("Khôi phục dữ liệu mẫu?", isPresented: $showResetConfirm) {
                Button("Khôi phục", role: .destructive) { productController.resetSampleData() }
                Button("Hủy", role: .cancel) {}
            } message: {
                Text("category.txt và fish.txt sẽ được chép lại từ bản gốc trong app. Mọi thay đổi sản phẩm sẽ mất, đơn hàng vẫn giữ nguyên.")
            }
        }
    }

    private var statsGrid: some View {
        let columns = [GridItem(.flexible(), spacing: 8), GridItem(.flexible(), spacing: 8)]
        return LazyVGrid(columns: columns, spacing: 8) {
            StatTile(title: "Sản phẩm",
                     value: "\(productController.products.count)",
                     icon: "shippingbox.fill",
                     color: AppTheme.primary)
            StatTile(title: "Hết hàng",
                     value: "\(productController.outOfStockCount)",
                     icon: "exclamationmark.triangle.fill",
                     color: .orange)
            StatTile(title: "Đơn chờ xử lý",
                     value: "\(orderController.count(status: .pending))",
                     icon: "clock.fill",
                     color: .purple)
            StatTile(title: "Doanh thu (đã giao)",
                     value: orderController.revenue.vnd,
                     icon: "banknote.fill",
                     color: .green)
        }
    }
}

// MARK: - Một dòng sản phẩm trong trang quản lý

struct ManageProductRow: View {

    @EnvironmentObject private var productController: ProductController

    let product: Product

    var body: some View {
        HStack(spacing: 12) {
            ProductImageView(imageName: product.imageName,
                             fallbackSymbol: productController.iconName(for: product),
                             tint: productController.tint(for: product),
                             symbolSize: 20)
                .frame(width: 48, height: 48)
                .clipShape(RoundedRectangle(cornerRadius: 10))

            VStack(alignment: .leading, spacing: 3) {
                Text(product.name)
                    .font(.subheadline.bold())
                    .lineLimit(1)
                Text("#\(product.id) • \(product.formattedPrice)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Text(product.isInStock ? "\(product.stock)" : "Hết")
                .font(.caption.bold())
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .foregroundStyle(stockColor)
                .background(Capsule().fill(stockColor.opacity(0.15)))
        }
    }

    private var stockColor: Color {
        if !product.isInStock { return .gray }
        return product.isLowStock ? .orange : .green
    }
}
