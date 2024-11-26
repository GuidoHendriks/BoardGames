//
//  Complexity.swift
//  BoardGames
//
//  Created by Guido Hendriks on 26/11/2024.
//


enum Complexity: String, Codable, CaseIterable {
    case easy = "easy"
    case medium = "medium"
    case hard = "hard"
    
    var name: String {
        switch self {
        case .easy:
            return "Easy"
        case .medium:
            return "Medium"
        case .hard:
            return "Hard"
        }
    }
    
    static func fromWeight(_ value: Double) -> Self {
        if value < 2 {
            return .easy
        }
        
        if value < 3 {
            return .medium
        }
        
        return .hard
    }
}
