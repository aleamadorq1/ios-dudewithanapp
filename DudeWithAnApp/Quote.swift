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
    public let creationDate: String?
    public let isActive: Int?
    public let isDeleted: Int?
    public let isCSV: Int?
    
    public init(id: Int, quoteText: String, secondaryText: String, url: String, creationDate: String, isActive: Int, isCSV: Int) {
            self.id = id
            self.quoteText = quoteText
            self.secondaryText = secondaryText
            self.url = url
            self.creationDate = creationDate
            self.isActive = isActive
            self.isDeleted = 0
            self.isCSV = 0
        }
}
