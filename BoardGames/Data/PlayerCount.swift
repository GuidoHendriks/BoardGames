//
//  PlayerCount.swift
//  BoardGames
//
//  Created by Guido Hendriks on 26/11/2024.
//


struct PlayerCount: Codable {
    var min: Int
    var max: Int?
    var best: Int?
    
    var stringRepresentation: String {
        if let max {
            if let best {
                return "\(min)-\(max) (\(best))"
            } else {
                return "\(min)-\(max)"
            }
        } else {
            return "\(min)+"
        }
    }
}