//
//  AgeRange.swift
//  BoardGames
//
//  Created by Guido Hendriks on 26/11/2024.
//

struct AgeRange: Codable {
    var min: Int
    var max: Int?
    
    var stringRepresentation: String {
        if let max {
            "\(min)-\(max)"
        } else {
            "\(min)+"
        }
    }
}
