//
//  ProductListView.swift
//  FishStore
//
//  Danh sách sản phẩm trong 1 danh mục: tìm kiếm + sắp xếp.
//

import SwiftUI

struct ProductListView: View {

    @EnvironmentObject private var productController: ProductController

    let category: ProductCategory

    @State private var searchText = ""
    @State private var sortOption: SortOption = .normal
    @State private var showAddForm = false

    enum SortOption: String, CaseIterable, Identifiable {
        case normal    = "Mặc định"
        case priceAsc  = "Giá tăng dần"
        case priceDesc = "Giá giảm dần"
        case name      = "Tên A – Z"
        case stock     = "Còn nhiều hàng"

        var id: String { rawValue }
    }

    private var displayedProducts: [Product] {
        let list = productController.search(searchText, in: category.id)
        switch sortOption {
        case .normal:    return list
        case .priceAsc:  return list.sorted { $0.price < $1.price }
        case .priceDesc: return list.sorted { $0.price > $1.price }
        case .name:      return list.sorted { $0.name.localizedStandardCompare($1.name) == .orderedAscending }
        case .stock:     return list.sorted { $0.stock > $1.stock }
        }
    }

    var body: some View {
        ScrollView {
            let products = displayedProducts
            if products.isEmpty {
                EmptyStateView(icon: category.iconName,
                               title: "Chưa có sản phẩm",
                               message: searchText.isEmpty
                                   ? "Danh mục \(category.name) chưa có sản phẩm nào."
                                   : "Không tìm thấy \"\(searchText)\".",
                               actionTitle: "Thêm sản phẩm",
                               action: { showAddForm = true })
                    .frame(height: 420)
            } else {
                VStack(spacing: 8) {
                    Text("\(products.count) sản phẩm")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)
                    ProductGridView(products: products)
                        .padding(.bottom)
                }
            }
        }
        .background(AppTheme.background)
        .navigationTitle(category.name)
        .searchable(text: $searchText, prompt: "Tìm trong \(category.name)")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Menu {
                    Picker("Sắp xếp", selection: $sortOption) {
                        ForEach(SortOption.allCases) { option in
                            Text(option.rawValue).tag(option)
                        }
                    }
                    Divider()
                    Button {
                        showAddForm = true
                    } label: {
                        Label("Thêm sản phẩm", systemImage: "plus")
                    }
                } label: {
                    Image(systemName: "line.3.horizontal.decrease.circle")
                }
            }
        }
        .sheet(isPresented: $showAddForm) {
            ProductFormView(defaultCategoryId: category.id)
        }
    }
}
