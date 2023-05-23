//
//  Quote.swift
//  DudeWithAnApp
//
//  Created by Alejandro on 4/26/23.
//

import Foundation

struct Quote: Codable, Identifiable, Equatable {
    let id: Int
    let quoteText: String
    let secondaryText: String
    let url: String
    let creationDate: String
}
