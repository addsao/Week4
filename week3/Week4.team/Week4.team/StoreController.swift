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
        let loadedCategories = ProductCategory.loadAll()
        self.categories = loadedCategories
        self.products = Product.loadAll()
        self.cart = CartItem.sampleCart
        self.orders = Order.sampleOrders
    }
    
    var filteredProducts: [Product] {
        products.filter { product in
            let matchesCategory = selectedCategory == nil || product.categoryId == selectedCategory?.id
            let matchesSearch = product.matches(keyword: searchText)
            return matchesCategory && matchesSearch
        }
    }
    
    var cartBadgeCount: Int {
        cart.totalQuantity
    }
    
    func addToCart(product: Product, quantity: Int = 1) {
        cart.add(product, quantity: quantity)
    }
    
    func removeFromCart(product: Product) {
        cart.remove(product)
    }
    
    func createOrder(customerName: String, phoneNumber: String, address: String, note: String = "") {
        guard !cart.isEmpty else { return }
        let newOrder = Order(
            from: cart,
            customerName: customerName,
            phoneNumber: phoneNumber,
            shippingAddress: address,
            note: note
        )
        orders.insert(newOrder, at: 0)
        cart.removeAll()
    }
}
