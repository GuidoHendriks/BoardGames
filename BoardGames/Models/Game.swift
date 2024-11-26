//
//  Game.swift
//  BoardGames
//
//  Created by Guido Hendriks on 25/11/2024.
//

import Foundation
import UIKit
import SwiftData

@Model
final class Game: Encodable {
    enum CodingKeys: CodingKey {
        case name
        case imageUrl
        case playerCount
        case ageRange
        case durationMinutes
        case complexity
        case sessions
        case isFavorite
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(imageUrl, forKey: .imageUrl)
        try container.encode(playerCount, forKey: .playerCount)
        try container.encode(ageRange, forKey: .ageRange)
        try container.encode(durationMinutes, forKey: .durationMinutes)
        try container.encode(complexity, forKey: .complexity)
        try container.encode(sessions, forKey: .sessions)
        try container.encode(isFavorite, forKey: .isFavorite)
    }
    
    var name: String
    
    var imageUrl: String?
    
    @Attribute(.externalStorage)
    var imageData: Data?
    
    @Attribute(.externalStorage)
    var thumbnailData: Data?
    
    var playerCount: PlayerCount
    var ageRange: AgeRange
    var durationMinutes: Int
    var complexity: Complexity
    var isFavorite = false
    
    @Relationship(deleteRule: .cascade)
    var sessions = [Session]()
    
    init(
        name: String,
        imageUrl: String? = nil,
        image: UIImage?,
        playerCount: PlayerCount,
        ageRange: AgeRange,
        durationMinutes: Int,
        complexity: Complexity
    ) {
        self.name = name
        self.imageUrl = imageUrl
        self.playerCount = playerCount
        self.ageRange = ageRange
        self.durationMinutes = durationMinutes
        self.complexity = complexity
        
        self.image = image
    }
    
    var image: UIImage? {
        get {
            guard let imageData else {
                return nil
            }
            
            return UIImage(data: imageData)
        }
        set {
            imageData = newValue?.pngData()
            thumbnailData = nil
        }
    }
    
    var thumbnail: UIImage? {
        get {
            if let thumbnailData {
                return UIImage(data: thumbnailData)
            }
            
            guard let imageData else {
                return nil
            }
            
            let thumbnail = UIImage(data: imageData)?
                .preparingThumbnail(of: CGSize(width: 300, height: 300))
            
            thumbnailData = thumbnail?.pngData()
            
            return thumbnail
        }
    }
}
