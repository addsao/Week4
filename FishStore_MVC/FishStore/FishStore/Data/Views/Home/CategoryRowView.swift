//
//  CategoryRowView.swift
//  FishStore
//
//  Lưới icon danh mục (4 cột) trên màn hình chính – dữ liệu từ category.txt.
//

import SwiftUI

struct CategoryRowView: View {
    let categories: [ProductCategory]
    var onSeeAll: (() -> Void)? = nil

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 8), count: 4)

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Danh mục")
                    .font(.headline)
                Spacer()
                if let onSeeAll {
                    Button("Xem tất cả", action: onSeeAll)
                        .font(.subheadline)
                }
            }

            LazyVGrid(columns: columns, spacing: 14) {
                ForEach(categories) { category in
                    NavigationLink(value: category) {
                        CategoryIconView(category: category)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(14)
        .background(RoundedRectangle(cornerRadius: 18).fill(AppTheme.card))
        .padding(.horizontal)
    }
}

struct CategoryIconView: View {
    let category: ProductCategory

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: category.iconName)
                .font(.title2)
                .foregroundStyle(category.tint)
                .frame(width: 58, height: 58)
                .background(RoundedRectangle(cornerRadius: 16).fill(category.tint.opacity(0.14)))

            Text(category.name)
                .font(.caption.weight(.semibold))
                .multilineTextAlignment(.center)
                .lineLimit(2, reservesSpace: true)
                .minimumScaleFactor(0.85)
        }
        .frame(maxWidth: .infinity)
    }
}
