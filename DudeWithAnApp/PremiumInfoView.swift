import Foundation
import SwiftUI
import StoreKit

struct PremiumInfoView: View {
    @Binding var isPresented: Bool
    @State var translations: AppTranslation?
    var apiService: APIService
    @ObservedObject var storeManager = StoreManager()
    var premiumProduct: SKProduct? {
        storeManager.products.first(where: { $0.productIdentifier == "001" })
    }
    var patreonProduct: SKProduct? {
        storeManager.products.first(where: { $0.productIdentifier == "003" })
    }

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
                    if let product = premiumProduct {
                        storeManager.buyProduct(product) //Premium button
                    }
                    }) {
                    Text(translations?.premiumViewButtonTextTry ?? "Loading...")
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.black)
                        .cornerRadius(10)
                }
                Button(action: {
                    if let product = patreonProduct {
                        storeManager.buyProduct(product) //Patreon button
                    }
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

                //Button(action: {
                    // add your action for restore purchases here
                //}) {
                //    Text(translations?.premiumViewButtonTextRestore ?? "Loading...")
                //        .foregroundColor(.white)
                 //       .padding(5)
                 //       .background(Color.blue)
                //        .cornerRadius(10)
               // }
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
            storeManager.getProducts(productIDs: ["001", "003"])
            SKPaymentQueue.default().add(storeManager)
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

class StoreManager: NSObject, ObservableObject, SKProductsRequestDelegate, SKPaymentTransactionObserver {
    
    @Published var products: [SKProduct] = []
    @Published var userHasPaid: Bool = UserDefaults.standard.bool(forKey: "userHasPaid") ? false : true
    
    override init() {
        super.init()
        
        // Explicitly check if the key exists
        if UserDefaults.standard.object(forKey: "userHasPaid") != nil {
            userHasPaid = UserDefaults.standard.bool(forKey: "userHasPaid")
        }
        else
        {
            userHasPaid = false
        }
    }
    
    func getProducts(productIDs: [String]) {
        let request = SKProductsRequest(productIdentifiers: Set(productIDs))
        request.delegate = self
        request.start()
    }
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        DispatchQueue.main.async {
            self.products = response.products
        }
    }
    
    func buyProduct(_ product: SKProduct) {
        let payment = SKPayment(product: product)
        SKPaymentQueue.default().add(payment)
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch transaction.transactionState {
            case .purchased:
                userHasPaid = true
                UserDefaults.standard.set(userHasPaid, forKey: "userHasPaid")
                SKPaymentQueue.default().finishTransaction(transaction)
            case .failed, .deferred, .purchasing, .restored:
                break
            @unknown default:
                break
            }
        }
    }
}
