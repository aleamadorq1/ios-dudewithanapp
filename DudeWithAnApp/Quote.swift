//
//  Quote.swift
//  DudeWithAnApp
//
//  Created by Alejandro on 4/26/23.
//

import Foundation

public struct Quote: Codable, Identifiable, Equatable {
    public let id: Int
    public let quoteText: String
    public let secondaryText: String
    public let url: String
    public let creationDate: String
    
    public init(id: Int, quoteText: String, secondaryText: String, url: String, creationDate: String) {
            self.id = id
            self.quoteText = quoteText
            self.secondaryText = secondaryText
            self.url = url
            self.creationDate = creationDate
        }
}
