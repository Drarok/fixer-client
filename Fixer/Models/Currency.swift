//
//  Currency.swift
//  Fixer
//
//  Created by Mat Gadd on 09/01/2018.
//  Copyright © 2018 Mat Gadd. All rights reserved.
//

import Foundation

struct Currency {

    static let all = [
        Currency(id: "AUD", flag: "🇦🇺"),
        Currency(id: "BGN", flag: "🇧🇬"),
        Currency(id: "BRL", flag: "🇧🇷"),
        Currency(id: "CAD", flag: "🇨🇦"),
        Currency(id: "CHF", flag: "🇨🇭"),
        Currency(id: "CNY", flag: "🇨🇳"),
        Currency(id: "CZK", flag: "🇨🇿"),
        Currency(id: "DKK", flag: "🇩🇰"),
        Currency(id: "EUR", flag: "🇪🇺"),
        Currency(id: "GBP", flag: "🇬🇧"),
        Currency(id: "HKD", flag: "🇭🇰"),
        Currency(id: "HRK", flag: "🇭🇷"),
        Currency(id: "HUF", flag: "🇭🇺"),
        Currency(id: "IDR", flag: "🇮🇩"),
        Currency(id: "ILS", flag: "🇮🇱"),
        Currency(id: "INR", flag: "🇮🇳"),
        Currency(id: "JPY", flag: "🇯🇵"),
        Currency(id: "KRW", flag: "🇰🇷"),
        Currency(id: "MXN", flag: "🇲🇽"),
        Currency(id: "MYR", flag: "🇲🇾"),
        Currency(id: "NOK", flag: "🇳🇴"),
        Currency(id: "NZD", flag: "🇳🇿"),
        Currency(id: "PHP", flag: "🇵🇭"),
        Currency(id: "PLN", flag: "🇵🇱"),
        Currency(id: "RON", flag: "🇷🇴"),
        Currency(id: "RUB", flag: "🇷🇺"),
        Currency(id: "SEK", flag: "🇸🇪"),
        Currency(id: "SGD", flag: "🇸🇬"),
        Currency(id: "THB", flag: "🇹🇭"),
        Currency(id: "TRY", flag: "🇹🇷"),
        Currency(id: "USD", flag: "🇺🇸"),
        Currency(id: "ZAR", flag: "🇿🇦"),
    ]

    static let base = all[8] // EUR
    static var rates: [String : Double] = [:]

    let id: String
    let flag: String

    var locale: Locale {
        let components = [
            NSLocale.Key.currencyCode.rawValue: id,
        ]
        let identifier = Locale.identifier(fromComponents: components)
        return Locale(identifier: identifier)
    }

    var name: String {
        return Locale.current.localizedString(forCurrencyCode: id) ?? id
    }

    static func convert(_ amount: Double, from: Currency, to: Currency) -> Double {
        let fromRate = rates[from.id] ?? 1.0
        let toRate = rates[to.id] ?? 1.0

        return amount / fromRate * toRate
    }

}

extension Currency: Equatable {

    static func ==(lhs: Currency, rhs: Currency) -> Bool {
        return lhs.id == rhs.id
    }

}
