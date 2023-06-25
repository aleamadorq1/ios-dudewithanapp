//
//  LikedQuotesView.swift
//  DudeWithAnApp
//
//  Created by Alejandro on 6/3/23.
//
import SwiftUI
struct LikedQuotesView: View {
    @State private var likedQuotes: [Quote] = []
    private let apiService = APIService()

    var body: some View {
        ZStack {
            // Replace ContentView with your desired background view
            ContentView().blur(radius: 0.5)
                .opacity(0.5) // Adjust the overall opacity of the background view

            VStack {
                NavigationView {
                    List(likedQuotes, id: \.id) { quote in
                        NavigationLink(destination: PantoneQuoteView(quote: quote, backgroundColor: .white)) {
                            Text(quote.quoteText)
                        }
                        .listRowBackground(Color.white)
                    }
                    .listStyle(PlainListStyle())
                    .navigationTitle("My Likes")
                }
                .background(Color.black) // Set the background color of the NavigationView to clear
                .opacity(1.0) // Adjust the opacity of the NavigationView
            }
        }
        .background(ContentView().ignoresSafeArea())
        .opacity(0.5) // Set the overall opacity of the entire view except the specific elements
        .onAppear {
            loadLikedQuotes()
        }
    }

    private func loadLikedQuotes() {
        if let likedQuoteIDs = UserDefaults.standard.array(forKey: "likedQuotes") as? [Int] {
            for id in likedQuoteIDs {
                apiService.fetchQuote(id: id) { result in
                    DispatchQueue.main.async {
                        switch result {
                        case .success(let quote):
                            self.likedQuotes.append(quote)
                        case .failure(let error):
                            print("Error fetching quote: \(error)")
                        }
                    }
                }
            }
        }
    }
}

