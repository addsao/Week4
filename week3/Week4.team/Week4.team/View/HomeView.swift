//
//  HomeView.swift
//  Week4.team
//
//  Created by MAY 02 on 5/10/26.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var controller: StoreController

    var body: some View {
        NavigationStack {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 12) {
                    HomeHeaderView(
                        storeName: "Cá Cảnh Xinh",
                        subtitle: "Thế giới thủy sinh trong tầm tay ♡"
                    )
                    
                    LocationRowView()
                    
                    SearchBarView(searchText: $controller.searchText)
                    
                    BannerView()
                        .padding(.vertical, 4)
                    
                    CategoryRowView(
                        categories: controller.categories,
                        selectedCategory: $controller.selectedCategory
                    )
                    .padding(.vertical, 4)
                    
                    ProductSectionView(
                        title: controller.selectedCategory?.name ?? "Sản phẩm nổi bật",
                        products: controller.filteredProducts
                    )
                }
                .padding(.bottom, 20)
            }
        }
    }
}

#Preview {
    HomeView()
        .environmentObject(StoreController())
}
