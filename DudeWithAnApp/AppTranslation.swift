//
//  AppTranslation.swift
//  DudeWithAnApp
//
//  Created by Alejandro on 6/28/23.
//

import Foundation

public struct AppTranslation: Codable, Identifiable, Equatable {
    public let id: Int
    public let appName: String
    public let premiumViewTitle: String
    public let premiumViewText1: String
    public let premiumViewText2: String
    public let premiumViewText3: String
    public let premiumViewButtonTextTry: String
    public let premiumViewButtonTextPatreon: String
    public let premiumViewButtonTextRestore: String
    public let languageCode: String
}
