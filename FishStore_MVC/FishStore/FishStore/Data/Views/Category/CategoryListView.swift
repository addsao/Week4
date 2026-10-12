//
//  CategoryListView.swift
//  FishStore
//
//  Tab "Danh mục": danh sách danh mục đọc từ category.txt.
//

import SwiftUI

struct CategoryListView: View {

    @EnvironmentObject private var productController: ProductController

    var body: some View {
        NavigationStack {
            Group {
                if productController.categories.isEmpty {
                    EmptyStateView(icon: "tray",
                                   title: "Chưa có danh mục",
                                   message: "Kiểm tra lại file category.txt đã được thêm vào project chưa.")
                } else {
                    List(productController.categories) { category in
                        NavigationLink(value: category) {
                            HStack(spacing: 14) {
                                Image(systemName: category.iconName)
                                    .font(.title3)
                                    .foregroundStyle(category.tint)
                                    .frame(width: 48, height: 48)
                                    .background(RoundedRectangle(cornerRadius: 12)
                                        .fill(category.tint.opacity(0.14)))

                                VStack(alignment: .leading, spacing: 3) {
                                    Text(category.name)
                                        .font(.headline)
                                    Text("\(productController.productCount(in: category.id)) sản phẩm")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                            .padding(.vertical, 4)
                        }
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .navigationTitle("Danh mục")
            .refreshable { productController.load() }
            .appDestinations()
        }
    }
}
