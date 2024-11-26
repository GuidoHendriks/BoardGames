//
//  Player.swift
//  BoardGames
//
//  Created by Guido Hendriks on 25/11/2024.
//

import Foundation
import SwiftData

@Model
class Player {
    var name: String
    
    @Relationship(deleteRule: .deny)
    var sessions: [Session] = []
    
    init(name: String) {
        self.name = name
    }
}

extension Player: Encodable {
    enum CodingKeys: CodingKey {
        case name
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
    }
}
