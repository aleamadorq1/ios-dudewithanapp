//
//  APIService.swift
//  DudeWithAnApp
//
//  Created by Alejandro on 4/26/23.
//

import Foundation

public class APIService {
    let allQuotesURL = "https://dudewithanapp.site/api/quote"
    let latestQuoteURL = "https://dudewithanapp.site/api/quote/latest"
    public init() {}
    
    func fetchAllQuotes(completion: @escaping (Result<[Quote], Error>) -> Void) {
        guard let url = URL(string: allQuotesURL) else { return }
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let data = data else { return }
            do {
                let quotes = try JSONDecoder().decode([Quote].self, from: data)
                completion(.success(quotes))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    public func fetchLatestQuote(completion: @escaping (Result<Quote, Error>) -> Void) {
        guard let url = URL(string: latestQuoteURL) else { return }
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let data = data else { return }
            do {
                let quote = try JSONDecoder().decode(Quote.self, from: data)
                completion(.success(quote))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}
