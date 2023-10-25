//
//  ContentView.swift
//  SwiftUIActor
//
//  Created by Neo Hsu on 2023/10/24.
//

import SwiftUI

class ContentViewModel: ObservableObject {
    @Published var planer = TravelPlaner()
    @Published var fHotels = [Hotel]()

    func testBook(){
        let hotels = [Hotel(name: "h1", phoneNumber: 123), Hotel(name: "h2", phoneNumber: 456), Hotel(name: "h3", phoneNumber: 456)]
        
        Task { @MainActor in
            await planer.book(hotels: hotels, checkAvailability: { hotel in
                let isHotelAvailable = await API_checkAvailability(hotel: hotel)
                    if isHotelAvailable {
                        await MainActor.run {
                            fHotels.append(hotel)
                        }
                    }
                return isHotelAvailable
            })
        }
    }
    
    private func API_checkAvailability(hotel: Hotel) async -> Bool {
        // 當真的實作api 需要wait的function
        var res = false
        if hotel.phoneNumber == 456 {
            res = true
        }
        return res
    }
    
}

struct ContentView: View {
//    @State var planer = TravelPlaner()
    @StateObject var viewModel = ContentViewModel()
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            ForEach(viewModel.fHotels){ hotel in
                Text(hotel.name)
                
            }
            Text("Hello, world!")
        }

        .padding()
        .task {
            viewModel.testBook()
        }
    }
    
    
}

struct Hotel: Identifiable{
    var id = UUID()
    
    var name: String
    var phoneNumber: Int
}

actor TravelPlaner {
    // 已經訂好的飯店
    var myHotels: [Hotel] = []

    func book(hotels: [Hotel], checkAvailability: @Sendable (Hotel) async -> Bool) async {
        // 針對傳入的飯店一個一個檢查
        for hotel in hotels {
            // 連到外部服務去檢查有沒有空房
            if await checkAvailability(hotel) {
                myHotels.append(hotel)
            }
        }
    }
}
