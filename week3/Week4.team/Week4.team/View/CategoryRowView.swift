//
//  CategoryRowView.swift
//  Week4.team
//
//  Created by MAY 01 on 5/10/26.
//


import SwiftUI

struct CategoryRowView: View {
    let categories: [ProductCategory]
    @Binding var selectedCategory: ProductCategory?

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 16) {
                ForEach(categories) { category in
                    VStack(spacing: 8) {
                        ZStack {
                            Circle()
                                .fill(selectedCategory?.id == category.id ? Color.blue.opacity(0.2) : Color.blue.opacity(0.08))
                                .frame(width: 60, height: 60)
                            
                            Image(systemName: category.systemIconName)
                                .font(.system(size: 26))
                                .foregroundColor(selectedCategory?.id == category.id ? .blue : .blue.opacity(0.8))
                        }
                        
                        Text(category.name)
                            .font(.caption)
                            .fontWeight(selectedCategory?.id == category.id ? .bold : .regular)
                            .foregroundColor(.primary)
                            .multilineTextAlignment(.center)
                            .frame(width: 75)
                            .lineLimit(2)
                    }
                    .onTapGesture {
                        if selectedCategory?.id == category.id {
                            selectedCategory = nil // Bấm lại thì hủy chọn, hiện toàn bộ
                        } else {
                            selectedCategory = category
                        }
                    }
                }
            }
            .padding(.horizontal)
        }
    }
}
