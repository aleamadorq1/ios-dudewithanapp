import SwiftUI
import UIKit

struct ContentView: View {
    @State private var quotes: [Quote] = []
    @State private var currentQuote: Quote?
    @State private var currentIndex: Int = 0
    
    private let apiService = APIService()
    
    var body: some View {
        ZStack {
            // Background image
            let bgColor = Color("background1", bundle: nil)
            Image("background1")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .edgesIgnoringSafeArea(.all)
                .overlay(Color.clear.opacity(bgColor.isLight() ? 0.7 : 0.3))

            // Pantone-style Quote card
            VStack {
                if let quote = currentQuote {
                    PantoneQuoteView(quote: quote, backgroundColor: bgColor)
                }
            }
            .onAppear {
                loadQuotes()
            }
            .gesture(
                DragGesture()
                    .onEnded { value in
                        let horizontalTranslation = value.translation.width
                        let threshold: CGFloat = 100
                        
                        if horizontalTranslation > threshold {
                            // Swipe right
                            previousQuote()
                        } else if horizontalTranslation < -threshold {
                            // Swipe left
                            nextQuote()
                        }
                    }
            )
        }
    }
    
    private func loadQuotes() {
        apiService.fetchAllQuotes { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let quotes):
                    self.quotes = quotes
                    self.currentIndex = quotes.count - 1
                    self.currentQuote = quotes.last
                case .failure(let error):
                    print("Error fetching quotes: \(error)")
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
}
struct PantoneQuoteView: View {
    let quote: Quote
    let backgroundColor: Color

    var body: some View {
        VStack(alignment: .leading) {
            VStack(alignment: .leading) {
                Text(quote.quoteText)
                    .font(.custom("HelveticaNeue-Bold", size: dynamicFontSize(quote: quote)))
                    .padding(.horizontal, 30)
                    .padding(.top, 30)
                    .foregroundColor(backgroundColor.isLight() ? .black : .white)
                
                Text("-Author, 1887")
                    .font(.custom("HelveticaNeue-Bold", size: 20))
                    .padding(.top, 20)
                    .padding(.horizontal, 30)
                    .foregroundColor(backgroundColor.isLight() ? .black : .white)
            }
            .frame(width: 300, height: 300)
            .background(Color.white.opacity(0.3))
            .border(backgroundColor.isLight() ? .black : .white, width: 2)

            Text("Dios te llama")
                .font(.custom("HelveticaNeue-Bold", size: 30))
                .padding(.top, 20)
                .padding(.horizontal, 30)
                .foregroundColor(backgroundColor.isLight() ? .black : .white)
        }
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
        let uiColor = self.uiColor()
        let colorComponents = uiColor.cgColor.components
        let red = colorComponents?[0] ?? 0
        let green = colorComponents?[1] ?? 0
        let blue = colorComponents?[2] ?? 0
        let yiq = (red * 299 + green * 587 + blue * 114) / 1000
        return yiq >= 0.5
    }
}


