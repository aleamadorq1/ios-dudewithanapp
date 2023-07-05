import SwiftUI
import UIKit

struct ContentView: View {
    @State private var quotes: [Quote] = []
    @State private var currentQuote: Quote?
    @State private var currentIndex: Int = 0
    @State private var animationActive = false
    @State private var iconsVisible: Bool = false
    @State private var likedQuotes: [Int] = UserDefaults.standard.array(forKey: "likedQuotes") as? [Int] ?? []
    @State private var isMyLikesViewActive: Bool = false
    @State private var isRefreshing: Bool = false
    @State private var dragOffset: CGFloat = 0.0
    @State private var showLikedQuotesView: Bool = false
    @State private var hideIconsTimer: Timer? = nil
    @State private var backgroundImage: String = ""
    @State private var isNightMode: Bool = UserDefaults.standard.bool(forKey: "isNightMode") ? true : false
    @State private var userHasPaid: Bool = UserDefaults.standard.bool(forKey: "userHasPaid") ? false : true
    @State private var showPremiumInfoSheet: Bool = false
    @StateObject var storeManager = StoreManager()
    
    private let apiService = APIService()
    private var refreshThreshold: CGFloat = 80.0

    var body: some View {

            ZStack {
                VStack {
                    if isRefreshing {
                        ProgressView()
                            .padding(.top, 0)
                    }
                    
                    Spacer()

                    if currentQuote != nil {
                        PantoneQuoteView(quote: $currentQuote, isNightMode: $isNightMode)
                    }

                    Spacer()

                    if iconsVisible {
                        HStack {
                            Spacer()
                            Button(action: {
                                showLikedQuotesView = true
                            }) {
                                Image(systemName: "book.fill")
                                    .foregroundColor(!isNightMode ? .black : .white)
                            }
                            Spacer()
                            Image(systemName: isQuoteLiked(currentQuote) ? "heart.fill" : "heart")
                                .foregroundColor(isQuoteLiked(currentQuote) ? Color.red : (!isNightMode  ? Color.black : Color.white))
                                .onTapGesture {
                                    withAnimation(.spring()) {
                                        toggleLike()
                                    }
                                    resetHideIconsTimer()
                                }
                            Spacer()
                            Image(systemName: "moon.fill")
                                .foregroundColor(!isNightMode ? .black : .white)
                                .onTapGesture {
                                        if storeManager.userHasPaid {
                                            // User has already paid, so just toggle the dark mode
                                            withAnimation {
                                                isNightMode.toggle()
                                                UserDefaults.standard.set(isNightMode, forKey: "isNightMode")
                                                backgroundImage = isNightMode  ? "dark" + String(Int.random(in:1...3)) : "clear" + String(Int.random(in:1...3))
                                                hideIconsTimer?.invalidate()  // Invalidate the timer
                                            }
                                        } else {
                                            // User has not paid, so show the PremiumInfoView
                                            withAnimation {
                                                showPremiumInfoSheet = true
                                                hideIconsTimer?.invalidate()  // Invalidate the timer
                                            }
                                        }
                                    }
                            Spacer()
                        }
                        .padding(.bottom, 20)
                        .transition(.scale)
                        .background(Color.clear.opacity(0))
                        
                        .sheet(isPresented: $showPremiumInfoSheet) {
                            PremiumInfoView(isPresented: $showPremiumInfoSheet, apiService: apiService, storeManager: storeManager)
                        }
                        
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
                                iconsVisible = true
                            }
                            resetHideIconsTimer()
                        }
                )
                .sheet(isPresented: $showLikedQuotesView) {
                    LikedQuotesView()
                }

            }
            .background(
                Image(backgroundImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .edgesIgnoringSafeArea(.all)
            )

        

    }

    func loadQuotes() {
        apiService.fetchAllQuotes() { result in
            switch result {
            case .success(let quotes):
                self.quotes = quotes
                self.currentQuote = quotes.first
                if self.backgroundImage.isEmpty {
                    self.backgroundImage = isNightMode  ? "dark" + String(Int.random(in:1...3)) : "clear" + String(Int.random(in:1...3))
                }
                self.isRefreshing = false
            case .failure(let error):
                print("Failed to fetch quotes: \(error.localizedDescription)")
                self.isRefreshing = false
            }
        }
    }

    func nextQuote() {
        if currentIndex + 1 < quotes.count {
            withAnimation(.easeInOut(duration: 0.5)) {
                currentIndex += 1
                currentQuote = quotes[currentIndex]
            }
        } else {
            loadQuotes()
        }
    }

    func previousQuote() {
        if currentIndex > 0 {
            withAnimation(.easeInOut(duration: 0.5)) {
                currentIndex -= 1
                currentQuote = quotes[currentIndex]
            }
        }
    }

    func isQuoteLiked(_ quote: Quote?) -> Bool {
        guard let quote = quote else { return false }
        return likedQuotes.contains(quote.id)
    }

    func toggleLike() {
        guard let quote = currentQuote else { return }

        if isQuoteLiked(quote) {
            likedQuotes.removeAll(where: { $0 == quote.id })
        } else {
            likedQuotes.append(quote.id)
        }

        UserDefaults.standard.set(likedQuotes, forKey: "likedQuotes")
    }

    func resetHideIconsTimer() {
        hideIconsTimer?.invalidate()
        hideIconsTimer = Timer.scheduledTimer(withTimeInterval: 4, repeats: false) { _ in
            withAnimation {
                iconsVisible = false
            }
        }
    }
}

struct PantoneQuoteView: View {
    @Binding var quote: Quote?
    @Binding var isNightMode: Bool // Add this line

    var body: some View {
        VStack {
            VStack(alignment: .leading) {
                if let quote = quote {
                    Text(quote.quoteText)
                        .font(.custom("HelveticaNeue-Bold", size: dynamicFontSize(quote: quote)))
                        .padding(.horizontal, 30)
                        .padding(.top, 30)
                        .foregroundColor(!isNightMode  ? .black : .white)
                    
                    if let url = URL(string: quote.url) {
                        Link(quote.secondaryText, destination: url)
                            .font(.custom("HelveticaNeue-Bold", size: dynamicFontSizeForSecondaryText(quote: quote)))
                            .padding(.top, 20)
                            .padding(.horizontal, 30)
                            .foregroundColor(!isNightMode  ? .black : .white)
                    } else {
                        Text(quote.secondaryText)
                            .font(.custom("HelveticaNeue-Bold", size: dynamicFontSizeForSecondaryText(quote: quote)))
                            .padding(.top, 20)
                            .padding(.horizontal, 30)
                            .foregroundColor(!isNightMode  ? .black : .white)
                    }
                }
            }
            .frame(width: 300, height: 300)
            .background(!isNightMode ? .white.opacity(0.5) : .black.opacity(0.2))
            .border(!isNightMode ? .black : .white, width: 6)
            
            HStack (spacing: 0) {
                Spacer() // Push the text to the right end of the VStack
                Image("Ico") // Add this line
                        .resizable() // Resizable to scale the image
                        .aspectRatio(contentMode: .fit) // Keeps the aspect ratio intact
                        .frame(width: 50, height: 50) // Set a frame for the icon
                        .padding(.trailing, 10)
                        .padding(.leading, 0)
                        .cornerRadius(10)
                Text("  Got Jesus?")
                    .font(.custom("HelveticaNeue-Bold", size: 26))
                    .padding(.top, 9)
                    .padding(.bottom, 9)
                    .padding(.leading, 0)
                    .padding(.trailing, 50)
                    //.padding(.leading, 10)
                    .cornerRadius(10)
                    .foregroundColor(!isNightMode ? .black : .white)
                    .background(!isNightMode ? .white.opacity(0.5) : .black.opacity(0.2))
            }
        }
    }

    func dynamicFontSize(quote: Quote) -> CGFloat {
        let length = quote.quoteText.count
        if length < 25 {
            return 35
        } else if length < 55 {
            return 30
        } else if length < 100{
            return 25
        } else if length < 150{
            return 20
        } else if length < 220{
            return 16
        }
        else
        {
            return 14
        }
    }

    func dynamicFontSizeForSecondaryText(quote: Quote) -> CGFloat {
        let length = quote.secondaryText.count
        if length < 25 {
            return 20
        } else if length < 50 {
            return 18
        } else {
            return 16
        }
    }
}


