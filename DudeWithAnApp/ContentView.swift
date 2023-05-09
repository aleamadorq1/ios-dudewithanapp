import SwiftUI

struct ContentView: View {
    @State private var quotes: [Quote] = []
    @State private var currentQuote: Quote?
    @State private var currentIndex: Int = 0
    
    private let apiService = APIService()
    
    var body: some View {
        ZStack {
            // Background image
            Image("background1")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .edgesIgnoringSafeArea(.all)
            
            // Pantone-style Quote card
            VStack {
                if let quote = currentQuote {
                    PantoneQuoteView(quote: quote)
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
    
    var body: some View {
        VStack(alignment: .leading) {
            VStack(alignment: .leading) {
                Text(quote.quoteText)
                    .font(.custom("HelveticaNeue-Bold", size: dynamicFontSize(quote: quote)))
                    .padding(.horizontal, 30)
                    .padding(.top, 30)
                    .foregroundColor(.black)
                
                Text("-Author 1886")
                    .font(.custom("HelveticaNeue-Bold", size: 20))
                    .padding(.top, 20)
                    .padding(.horizontal, 30)
                    .foregroundColor(.black)
            }
            .frame(width: 300, height: 300)
            .background(Color.white.opacity(0.5))
            .border(Color.black, width: 2)
            
            Text("Dios te llama")
                .font(.custom("HelveticaNeue-Bold", size: 30))
                .padding(.top, 20)
                .padding(.horizontal, 30)
                .foregroundColor(.black)
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



struct ArtisticQuoteView: View {
    let words: [String]
    let maxWidth: CGFloat = 250.0
    let minFontSize: CGFloat = 14
    let maxFontSize: CGFloat = 28
    
    init(quote: Quote) {
        self.words = quote.quoteText.components(separatedBy: " ")
    }
    
    var body: some View {
        VStack {
            justifiedText()
                .frame(maxWidth: maxWidth)
        }
        .padding()
        .background(Color.white)
        .border(Color.black, width: 2)
    }
    
    func breakLongWord(_ word: String, maxWidth: CGFloat) -> [String] {
        var brokenWords: [String] = []
        var currentWord = ""
        for char in word {
            let testWord = currentWord + String(char)
            let textSize = testWord.size(usingFont: UIFont.systemFont(ofSize: minFontSize))
            
            if textSize.width > maxWidth {
                brokenWords.append(currentWord)
                currentWord = String(char)
            } else {
                currentWord = testWord
            }
        }
        brokenWords.append(currentWord)
        return brokenWords
    }

    func justifiedText() -> some View {
        var lines: [Text] = []
        var currentLine: Text? = nil
        var lineWidthUsed: CGFloat = 0
        
        for word in words {
            let fontSize = randomFontSize()
            let font = Font.system(size: fontSize)
            let wordSize = word.size(usingFont: UIFont.systemFont(ofSize: fontSize))
            
            if lineWidthUsed + wordSize.width > maxWidth {
                if let line = currentLine {
                    lines.append(line)
                }
                currentLine = Text(word).font(font)
                lineWidthUsed = wordSize.width
            }
            else {
                let spaceSize = " ".size(usingFont: UIFont.systemFont(ofSize: fontSize))
                lineWidthUsed += wordSize.width + spaceSize.width
                let newText = Text(word).font(font)
                if let line = currentLine {
                    currentLine = line + Text(" ") + newText
                } else {
                    currentLine = newText
                }
            }
            
            if let lastWord = words.last, word == lastWord, let line = currentLine {
                lines.append(line)
            }
        }
        
        return VStack(alignment: .leading, spacing: 0) {
            ForEach(lines.indices, id: \.self) { index in
                lines[index].padding(.bottom, 2)
            }
        }
    }

    func randomFontSize() -> CGFloat {
        return CGFloat.random(in: minFontSize..<maxFontSize)
    }
}

enum ImageFilter: CaseIterable {
    case none
    case sepia
    case grayscale
    case blur
    
    static func randomFilter() -> ImageFilter {
        return ImageFilter.allCases.randomElement() ?? .none
    }
}
extension String {
    func size(usingFont font: UIFont) -> CGSize {
        let attributedString = NSAttributedString(string: self, attributes: [.font: font])
        return attributedString.size()
    }
}

