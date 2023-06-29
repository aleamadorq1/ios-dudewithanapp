import Foundation
import SwiftUI

struct PremiumInfoView: View {
    @Binding var isPresented: Bool
    @State var translations: AppTranslation?
    var apiService: APIService

    var body: some View {
        NavigationView {
            VStack {
                Text(translations?.premiumViewTitle ?? "Loading...")
                    .font(.custom("HelveticaNeue-Bold", size: 25))
                    .padding()
                
                Text(translations?.premiumViewText1 ?? "Loading...")
                    .font(.custom("HelveticaNeue-Light", size: 14))
                    .padding()
                
                Button(action: {
                    // add your action for premium here
                }) {
                    Text(translations?.premiumViewButtonTextTry ?? "Loading...")
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.black)
                        .cornerRadius(10)
                }
                Button(action: {
                    // add your action for patreon here
                }) {
                    Text(translations?.premiumViewButtonTextPatreon ?? "Loading...")
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.gray)
                        .cornerRadius(10)
                }
                
                Text(translations?.premiumViewText2 ?? "Loading...")
                    .padding()
                    .font(.custom("HelveticaNeue-Light", size: 14))
                Text(translations?.premiumViewText3 ?? "Loading...")
                    .padding()
                    .font(.custom("HelveticaNeue-Light", size: 14))

                Button(action: {
                    // add your action for restore purchases here
                }) {
                    Text(translations?.premiumViewButtonTextRestore ?? "Loading...")
                        .foregroundColor(.white)
                        .padding(5)
                        .background(Color.blue)
                        .cornerRadius(10)
                }
            }
            .font(.custom("HelveticaNeue-Light", size: 20))
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        isPresented = false
                    }) {
                        Image(systemName: "arrow.backward")
                    }
                }
            }
        }
        .onAppear {
            if let languageIdentifier = Locale.preferredLanguages.first {
                let languageCode = apiService.getLanguagePart(from: languageIdentifier)
                apiService.fetchAppTranslations(language: languageCode) { result in
                    switch result {
                    case .success(let fetchedTranslations):
                        DispatchQueue.main.async {
                            translations = fetchedTranslations
                        }
                    case .failure(let error):
                        print(error)
                    }
                }
            }
        }
    }
}
