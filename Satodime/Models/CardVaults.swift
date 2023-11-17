//
//  CardVaults.swift
//  Satodime
//
//  Created by Lionel Delvaux on 15/10/2023.
//

import Foundation

enum isCardAuthentic {
    case authentic
    case notAuthentic
    case unknown
}

class CardVaults {
    var isOwner: Bool
    // let isCardAuthentic: Bool
    let isCardAuthentic: isCardAuthentic
    let cardVersion: String
    let vaults: [VaultItem]
    var cardAuthenticity: CardAuthenticity?
    
    init(isOwner: Bool, isCardAuthentic: isCardAuthentic, cardVersion: String, vaults: [VaultItem], cardAuthenticity: CardAuthenticity? = nil) {
        self.isOwner = isOwner
        self.isCardAuthentic = isCardAuthentic
        self.cardVersion = cardVersion
        self.vaults = vaults
        self.cardAuthenticity = cardAuthenticity
    }
}
