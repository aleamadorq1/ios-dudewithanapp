import Foundation
import Alamofire

public class APIService {
    let allQuotesURL = "https://dudewithanapp.site/api/quote/published"
    let latestQuoteURL = "https://dudewithanapp.site/api/quote/latest"
    let specificQuoteURL = "https://dudewithanapp.site/api/quote/"
    let appTranslationURL = "https://dudewithanapp.site/api/apptranslation"
    
    let bearerToken: String = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJuYW1laWQiOiIyIiwidW5pcXVlX25hbWUiOiJpb3NhcHBAZHVkZXdpdGhhbmFwcC5zaXRlIiwibmJmIjoxNjg2NzA5OTM5LCJleHAiOjE4NDQ1NjI3MzksImlhdCI6MTY4NjcwOTkzOX0.47S4dpmb6ZIe1PiIxm63GWMoyMRWlEGe9sGEBJIQzVI"

        lazy var session: Session = {
            let configuration = URLSessionConfiguration.default
            let interceptor = CustomInterceptor(bearerToken: bearerToken)
            return Session(configuration: configuration, interceptor: interceptor)
        }()
        
        public init() {}
    
    func fetchAllQuotes(completion: @escaping (Result<[Quote], Error>) -> Void) {
        if let languageIdentifier = Locale.preferredLanguages.first {
            let languageCode = getLanguagePart(from: languageIdentifier)
            session.request(allQuotesURL + ("?language=" + languageCode)).responseData { response in
                switch response.result {
                case .success(let data):
                    do {
                        let quotes = try JSONDecoder().decode([Quote].self, from: data)
                        completion(.success(quotes))
                    } catch {
                        completion(.failure(error))
                    }
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        } else {
            // Handle the case where no preferred languages are found
        }
    }

    
    func getLanguagePart(from localeIdentifier: String) -> String {
        let parts = localeIdentifier.split(separator: "-")
        return String(parts[0])
    }

    public func fetchLatestQuote(completion: @escaping (Result<Quote, Error>) -> Void) {
        if let languageIdentifier = Locale.preferredLanguages.first {
            let languageCode = getLanguagePart(from: languageIdentifier)
            session.request(latestQuoteURL + ("?language=" + languageCode)).responseData { response in
                switch response.result {
                case .success(let data):
                    do {
                        let quote = try JSONDecoder().decode(Quote.self, from: data)
                        completion(.success(quote))
                    } catch {
                        completion(.failure(error))
                    }
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        } else {
            // Handle the case where no preferred languages are found
        }
    }

    public func fetchQuote(id: Int, completion: @escaping (Result<Quote, Error>) -> Void) {
        if let languageIdentifier = Locale.preferredLanguages.first {
            let languageCode = getLanguagePart(from: languageIdentifier)
            
            session.request(specificQuoteURL + "\(id)"+"/translated?language=" + languageCode).responseData { response in
                switch response.result {
                case .success(let data):
                    do {
                        let quote = try JSONDecoder().decode(Quote.self, from: data)
                        completion(.success(quote))
                    } catch {
                        completion(.failure(error))
                    }
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
    }
    
    func fetchAppTranslations(language: String, completion: @escaping (Result<AppTranslation, Error>) -> Void) {
        let parameters: [String: Any] = ["language": language]

        session.request(appTranslationURL, method: .get, parameters: parameters).responseData { response in
            switch response.result {
            case .success(let data):
                do {
                    let translations = try JSONDecoder().decode(AppTranslation.self, from: data)
                    completion(.success(translations))
                } catch {
                    completion(.failure(error))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}

class CustomInterceptor: RequestInterceptor {
    private let bearerToken: String
    private let maxRetryCount = 5
    private let retryDelay: TimeInterval = 5
    
    init(bearerToken: String) {
        self.bearerToken = bearerToken
    }
    
    func adapt(_ urlRequest: URLRequest, for session: Session, completion: @escaping (Result<URLRequest, Error>) -> Void) {
        var modifiedRequest = urlRequest
        modifiedRequest.setValue("Bearer \(bearerToken)", forHTTPHeaderField: "Authorization")
        completion(.success(modifiedRequest))
    }
    
    func retry(_ request: Request, for session: Session, dueTo error: Error, completion: @escaping (RetryResult) -> Void) {
        guard let statusCode = request.response?.statusCode else {
            completion(.doNotRetry)
            return
        }
        
        if statusCode == 401 {
            // Handle specific status code, if needed
            completion(.doNotRetry)
            return
        }
        
        let retryCount = request.retryCount
        if retryCount < maxRetryCount {
            completion(.retryWithDelay(retryDelay))
        } else {
            completion(.doNotRetry)
        }
    }
}
