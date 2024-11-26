//
//  Games.swift
//  BoardGames
//
//  Created by Guido Hendriks on 25/11/2024.
//

import SwiftUI
import SwiftData

struct Games: View {
    @Environment(\.modelContext) private var modelContext
    
    @Binding var navigationPath: NavigationPath
    @State private var showAddGame = false
    
    @Query(sort: \Game.name) private var games: [Game]
    var unplayedGames: [Game] {
        games.filter { $0.sessions.isEmpty }
    }
    
    var body: some View {
        List(games) { game in
            NavigationLink(value: game) {
                HStack(spacing: 16) {
                    if let image = game.thumbnail {
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 48)
                    } else {
                        Rectangle()
                            .frame(width: 48)
                            .foregroundStyle(.clear)
                    }
                    
                    VStack(alignment: .leading, spacing: 2) {
                        
                        HStack {
                            HStack(spacing: 4) {
                                if game.isFavorite {
                                    Image(systemName: "star.fill")
                                        .imageScale(.small)
                                        .foregroundStyle(.orange)
                                }
                                
                                Text("\(game.name)")
                                    .font(.headline)
                            }
                            
                            HStack(spacing: 2) {
                                HStack(spacing: 3) {
                                    Image(systemName: "person.2")
                                        .imageScale(.small)
                                    
                                    Text(game.playerCount.stringRepresentation)
                                }
                            }
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        }
                        
                        HStack(spacing: 0) {
                            Text(game.complexity.name)
                            
                            Text(" · ")
                            
                            Text(game.ageRange.stringRepresentation)
                        }
                    }
                }
            }
            .swipeActions(edge: .leading) {
                Button("Favorite", systemImage: game.isFavorite ? "star.slash" : "star") {
                    game.isFavorite.toggle()
                }
                .tint(.orange)
            }
            .listRowInsets(.init(
                top: 12,
                leading: 12,
                bottom: 12,
                trailing: 16
            ))
        }
        .navigationTitle("Games")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("Add Game", systemImage: "plus") {
                    showAddGame.toggle()
                }
            }
            
            ToolbarItem(placement: .topBarLeading) {
                Menu("Random Game") {
                    ForEach(Complexity.allCases, id: \.self) { complexity in
                        Button("\(complexity.name)") {
                            openRandomGame(with: complexity)
                        }
                    }
                } primaryAction: {
                    openRandomGame()
                }
            }
        }
        .navigationDestination(for: Game.self) { game in
            GameDetails(game: game)
        }
        .sheet(isPresented: $showAddGame) {
            NavigationStack {
                AddGame()
            }
        }
    }
    
    private func openRandomGame(with complexity: Complexity? = nil) {
        let isIncluded: (Game) -> Bool = { game in
            if let complexity = complexity {
                return game.complexity == complexity
            } else {
                return true
            }
        }
        
        guard let randomGame = unplayedGames.filter(isIncluded).randomElement() ?? games.filter(isIncluded).randomElement() else {
            return
        }
        
        navigationPath.append(randomGame)
    }
}

#Preview {
    NavigationStack {
        Games(navigationPath: .constant(.init()))
            .modelContainer(for: Game.self, inMemory: true) { result in
                guard case .success(let container) = result else {
                    return
                }
                
                let games: [Game] = [
                    .init(
                        name: "Splendor",
                        image: UIImage(named: "splendor"),
                        playerCount: .init(
                            min: 2,
                            max: 4,
                            best: 3
                        ),
                        ageRange: .init(
                            min: 10,
                            max: nil
                        ),
                        durationMinutes: 30,
                        complexity: .easy
                    ),
                    .init(
                        name: "Tapestry",
                        image: UIImage(named: "tapestry"),
                        playerCount: .init(
                            min: 1,
                            max: 4,
                            best: 3
                        ),
                        ageRange: .init(min: 12, max: nil),
                        durationMinutes: 120,
                        complexity: .medium
                    ),
                    .init(
                        name: "Wingspan",
                        image: nil,
                        playerCount: .init(
                            min: 1,
                            max: 5,
                            best: 3
                        ),
                        ageRange: .init(min: 12, max: nil),
                        durationMinutes: 60,
                        complexity: .easy
                    ),
                ]
                
                for game in games {
                    container.mainContext.insert(game)
                }
            }
    }
}
