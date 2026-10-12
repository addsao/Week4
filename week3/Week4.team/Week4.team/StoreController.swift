//
//  StoreController.swift
//  Week4.team
//
//  Created by MAY 02 on 5/10/26.
//

import SwiftUI
import Combine

class StoreController: ObservableObject {
    @Published var categories: [ProductCategory] = []
    @Published var products: [Product] = []
    @Published var cart: [CartItem] = []
    @Published var orders: [Order] = []
    
    @Published var searchText: String = ""
    @Published var selectedCategory: ProductCategory? = nil
    
    init() {
        loadData()
    }
    
    func loadData() {
        self.categories = ProductCategory.loadAll()
        self.products = Product.loadAll()
        self.cart = CartItem.sampleCart
        self.orders = Order.sampleOrders
    }
    
    // Logic lọc sản phẩm theo Category và Tìm kiếm
    var filteredProducts: [Product] {
        products.filter { product in
            let matchesCategory: Bool
            if let selected = selectedCategory {
                matchesCategory = (product.categoryId == selected.id)
            } else {
                matchesCategory = true
            }
            
            let matchesSearch = product.matches(keyword: searchText)
            return matchesCategory && matchesSearch
        }
    }
    
    // Toggle chọn category (bấm 1 lần thì chọn, bấm lần nữa thì bỏ chọn về tất cả)
    func selectCategory(_ category: ProductCategory) {
        if selectedCategory?.id == category.id {
            selectedCategory = nil
        } else {
            selectedCategory = category
        }
    }
}
