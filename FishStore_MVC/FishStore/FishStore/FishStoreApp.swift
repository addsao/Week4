//
//  FishStoreApp.swift
//  FishStore
//
//  Điểm bắt đầu của ứng dụng.
//  Tạo 3 Controller MỘT lần duy nhất và chia sẻ cho mọi View qua environmentObject.
//

import SwiftUI

@main
struct FishStoreApp: App {

    @StateObject private var productController = ProductController()
    @StateObject private var cartController = CartController()
    @StateObject private var orderController = OrderController()

    var body: some Scene {
        WindowGroup {
            ContentView()                       // Màn hình chính
                .environmentObject(productController)
                .environmentObject(cartController)
                .environmentObject(orderController)
        }
    }
}
