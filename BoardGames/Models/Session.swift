//
//  Session.swift
//  BoardGames
//
//  Created by Guido Hendriks on 25/11/2024.
//

import Foundation
import SwiftData

@Model
class Session {
    var date: Date
    
    @Relationship(deleteRule: .noAction, inverse: \Game.sessions)
    var game: Game
    
    @Relationship(deleteRule: .noAction, inverse: \Player.sessions)
    var players = [Player]()
    
    init(date: Date, game: Game, players: [Player]) {
        self.date = date
        self.game = game
        self.players = players
    }
}

extension Session: Encodable {
    enum CodingKeys: CodingKey {
        case date
        case players
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(date, forKey: .date)
        try container.encode(players, forKey: .players)
    }
}
