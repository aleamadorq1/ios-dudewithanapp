//
//  LikedQuotesView.swift
//  DudeWithAnApp
//
//  Created by Alejandro on 6/3/23.
//
import SwiftUI

struct LikedQuotesView: View {
    @State private var likedQuotes: [Quote] = []
    @Environment(\.presentationMode) var presentationMode
    private let apiService = APIService()

    var body: some View {
        ZStack {

            VStack {
                NavigationView {
                    List(likedQuotes, id: \.id) { quote in
                            NavigationLink(destination: PantoneQuoteWrapperView(quote: quote)) {
                                Text(quote.quoteText)
                            }
                        }
                    .listStyle(PlainListStyle())
                    .navigationTitle("❤️")
                    .toolbar {
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button("Back") {
                                presentationMode.wrappedValue.dismiss()
                            }
                        }
                    }
                }
            }
        }
        .opacity(0.8)
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

struct PantoneQuoteWrapperView: View {
    @State private var quote: Quote?
    @State private var isNightMode: Bool = false
    
    init(quote: Quote) {
        _quote = State(initialValue: quote)
    }
    
    var body: some View {
        PantoneQuoteView(quote: $quote, isNightMode: $isNightMode )
    }
}
