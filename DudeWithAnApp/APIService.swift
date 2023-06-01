//
//  APIService.swift
//  DudeWithAnApp
//
//  Created by Alejandro on 4/26/23.
//
import Foundation
import Alamofire

public class APIService {
    let allQuotesURL = "https://dudewithanapp.site/api/quote"
    let latestQuoteURL = "https://dudewithanapp.site/api/quote/latest"
    
    lazy var session: Session = {
        let configuration = URLSessionConfiguration.default
        let retryHandler = CustomRetryHandler()
        return Session(configuration: configuration, interceptor: retryHandler)
    }()
    
    public init() {}
    
    func fetchAllQuotes(completion: @escaping (Result<[Quote], Error>) -> Void) {
        session.request(allQuotesURL).responseData { response in
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
    }
    
    public func fetchLatestQuote(completion: @escaping (Result<Quote, Error>) -> Void) {
        session.request(latestQuoteURL).responseData { response in
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

class CustomRetryHandler: RequestInterceptor {
    private let maxRetryCount = 5
    private let retryDelay: TimeInterval = 1

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
