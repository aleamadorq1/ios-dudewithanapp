//
//  Quote.swift
//  DudeWithAnApp
//
//  Created by Alejandro on 4/26/23.
//

import Foundation

struct Quote: Codable, Identifiable {
    let id: Int
    let quoteText: String
    let creationDate: String
}
