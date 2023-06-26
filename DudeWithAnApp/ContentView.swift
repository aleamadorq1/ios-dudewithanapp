import SwiftUI
import UIKit

struct ContentView: View {
    @State private var quotes: [Quote] = []
    @State private var currentQuote: Quote?
    @State private var currentIndex: Int = 0
    @State private var animationActive = false
    @State private var iconsVisible: Bool = false
    @State private var likedQuotes: [Int] = UserDefaults.standard.array(forKey: "likedQuotes") as? [Int] ?? []
    @State private var iconJustTapped: Bool = false
    @State private var isMyLikesViewActive: Bool = false
    @State private var isRefreshing: Bool = false
    @State private var dragOffset: CGFloat = 0.0

    private let apiService = APIService()
    private var refreshThreshold: CGFloat = 80.0
    
    var body: some View {
        NavigationView {
            ZStack {
                let bgColor = Color("background3", bundle: nil)
                Image("clear2")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .edgesIgnoringSafeArea(.all)
                    .overlay(Color.clear.opacity(bgColor.isLight() ? 0.7 : 0.3))

                VStack {
                    if isRefreshing {
                        ProgressView()
                            .padding(.top, 10)
                    }

                    Spacer()
                    NavigationLink(destination: LikedQuotesView(), isActive: $isMyLikesViewActive) {
                        EmptyView()
                    }
                    if let quote = currentQuote {
                        PantoneQuoteView(quote: quote, backgroundColor: bgColor)
                    }
                    Spacer()
                    if iconsVisible {
                        HStack {
                            Spacer()
                            Image(systemName: "book.fill")
                                .foregroundColor(bgColor.isLight() ? .black : .white)
                                .onTapGesture {
                                    isMyLikesViewActive.toggle()
                                }
                            Spacer()
                            Image(systemName: isQuoteLiked(currentQuote) ? "heart.fill" : "heart")
                                .foregroundColor(isQuoteLiked(currentQuote) ? Color.red : (bgColor.isLight() ? Color.black : Color.white))
                                .onTapGesture {
                                    withAnimation(.easeInOut) {
                                        toggleLike()
                                    }
                                    iconJustTapped = true
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                        withAnimation {
                                            iconsVisible = false
                                            iconJustTapped = false
                                        }
                                    }
                                }
                            Spacer()
                            Image(systemName: "moon.fill").foregroundColor(bgColor.isLight() ? .black : .white)
                            Spacer()
                        }
                        .padding(.bottom, 10)
                        .transition(.scale)
                    }
                }
                .onAppear {
                    loadQuotes()
                }
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            if value.translation.height > 0, !isRefreshing {
                                dragOffset = value.translation.height
                            }
                        }
                        .onEnded { value in
                            if !isRefreshing && dragOffset > refreshThreshold {
                                withAnimation {
                                    isRefreshing = true
                                }
                                loadQuotes()
                            }
                            dragOffset = 0
                        }
                )
                .simultaneousGesture(
                    DragGesture()
                        .onEnded { value in
                            let horizontalTranslation = value.translation.width
                            let threshold: CGFloat = 100

                            if horizontalTranslation > threshold {
                                previousQuote()
                            } else if horizontalTranslation < -threshold {
                                nextQuote()
                            }
                        }
                )
                .simultaneousGesture(
                    TapGesture()
                        .onEnded { _ in
                            withAnimation {
                                if iconsVisible == false {
                                    iconsVisible = true
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 6) {
                                        withAnimation {
                                            if !iconJustTapped && !isMyLikesViewActive {
                                                iconsVisible = false
                                            }
                                        }
                                    }
                                } else {
                                    iconJustTapped = true
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                                        withAnimation {
                                            if !isMyLikesViewActive {
                                                iconsVisible = false
                                                iconJustTapped = false
                                            }
                                        }
                                    }
                                }
                            }
                        }
                )
            }
        }
    }
    
    private func loadQuotes() {
        apiService.fetchAllQuotes { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let quotes):
                    self.quotes = quotes
                    self.currentIndex = 0
                    self.currentQuote = quotes.first
                    self.isRefreshing = false // Reset refreshing state
                case .failure(let error):
                    print("Error fetching quotes: \(error)")
                    self.isRefreshing = false // Reset refreshing state
                }
            }
        }
    }
    
    private func nextQuote() {
        if currentIndex + 1 < quotes.count {
            withAnimation(.easeInOut(duration: 0.5)) {
                currentIndex += 1
                currentQuote = quotes[currentIndex]
            }
        }
    }
    
    private func previousQuote() {
        if currentIndex - 1 >= 0 {
            withAnimation(.easeInOut(duration: 0.5)) {
                currentIndex -= 1
                currentQuote = quotes[currentIndex]
            }
        }
    }
    
    private func isQuoteLiked(_ quote: Quote?) -> Bool {
        guard let quote = quote else { return false }
        return likedQuotes.contains(quote.id)
    }

    private func toggleLike() {
        guard let quote = currentQuote else { return }
        if isQuoteLiked(quote) {
            if let index = likedQuotes.firstIndex(of: quote.id) {
                likedQuotes.remove(at: index)
            }
        } else {
            likedQuotes.append(quote.id)
        }
        UserDefaults.standard.set(likedQuotes, forKey: "likedQuotes")
    }
}

struct PantoneQuoteView: View {
    let quote: Quote
    let backgroundColor: Color

    var body: some View {
        VStack(alignment: .leading) {
            Text(quote.quoteText)
                .font(.custom("HelveticaNeue-Bold", size: dynamicFontSize(quote: quote)))
                .padding(.horizontal, 30)
                .padding(.top, 30)
                .foregroundColor(backgroundColor.isLight() ? .black : .white)
            
            if let url = URL(string: quote.url) {
                Link(quote.secondaryText, destination: url)
                    .font(.custom("HelveticaNeue-Bold", size: dynamicFontSizeForSecondaryText(quote: quote)))
                    .padding(.top, 20)
                    .padding(.horizontal, 30)
                    .foregroundColor(backgroundColor.isLight() ? .black : .white)
            } else {
                Text(quote.secondaryText)
                    .font(.custom("HelveticaNeue-Bold", size: dynamicFontSizeForSecondaryText(quote: quote)))
                    .padding(.top, 20)
                    .padding(.horizontal, 30)
                    .foregroundColor(backgroundColor.isLight() ? .black : .white)
            }
        }
        .frame(width: 300, height: 300)
        .background(backgroundColor.isLight() ? .white.opacity(0.2) : .black.opacity(0.2))
        .border(backgroundColor.isLight() ? .black : .white, width: 6)
        
        Text("Daily Quotes")
            .font(.custom("HelveticaNeue-Bold", size: 30))
            .padding(.top, 20)
            .padding(.horizontal, 0)
            .padding(.leading, 10)
            .foregroundColor(backgroundColor.isLight() ? .black : .white)
    }

    func dynamicFontSize(quote: Quote) -> CGFloat {
        let length = quote.quoteText.count
        if length < 50 {
            return 30
        } else if length < 100 {
            return 24
        } else {
            return 20
        }
    }
    func dynamicFontSizeForSecondaryText(quote: Quote) -> CGFloat {
        let length = quote.secondaryText.count
        if length < 20 {
            return 20
        } else {
            return 16
        }
    }

}



extension String {
    func size(usingFont font: UIFont) -> CGSize {
        let attributedString = NSAttributedString(string: self, attributes: [.font: font])
        return attributedString.size()
    }
}
extension Color {
    func uiColor() -> UIColor {
        let components = self.cgColor?.components ?? [0, 0, 0, 0]
        return UIColor(red: components[0], green: components[1], blue: components[2], alpha: components[3])
    }
    
    func isLight() -> Bool {
        return true
    }
}


