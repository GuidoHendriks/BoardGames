//
//  GameDetails.swift
//  BoardGames
//
//  Created by Guido Hendriks on 25/11/2024.
//

import SwiftUI
import SwiftData

struct GameDetails: View {
    @Environment(\.modelContext) private var modelContext
    @State private var showNewSession = false
    
    let game: Game
    
    
    var body: some View {
        List {
            Section {
                LabeledContent("Age") {
                    Text(game.ageRange.stringRepresentation)
                }
                LabeledContent("Players") {
                    Text(game.playerCount.stringRepresentation)
                }
                LabeledContent("Duration") {
                    Text("\(game.durationMinutes) minutes")
                }
                LabeledContent("Complexity", value: game.complexity.name)
                LabeledContent("Sessions", value: "\(game.sessions.count)")
            } header: {
                if let image = game.image {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 160)
                        .listRowInsets(.init(top: 0, leading: 0, bottom: 16, trailing: 0))
                }
            }
            if !game.sessions.isEmpty {
                Section("Sessions") {
                    ForEach(game.sessions) { session in
                        HStack(alignment: .firstTextBaseline) {
                            Text(session.date, format: .dateTime.year().month().day())
                            
                            Spacer()
                            
                            VStack(alignment: .trailing) {
                                ForEach(session.players) { player in
                                    Text(player.name)
                                }
                            }
                            .foregroundStyle(.secondary)
                        }
                        .swipeActions(edge: .trailing) {
                            Button("Delete", role: .destructive) {
                                modelContext.delete(session)
                                try? modelContext.save()
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle(game.name)
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                Button("New Session") {
                    showNewSession = true
                }
                
                Button("Toggle Favorite", systemImage: game.isFavorite ? "star.fill" : "star") {
                    game.isFavorite.toggle()
                }
                .tint(game.isFavorite ? .orange : nil)
            }
        }
        .sheet(isPresented: $showNewSession) {
            NavigationStack {
                AddSession(game: game)
            }
        }
    }
}

#Preview {
    NavigationStack {
        let game =  Game(
            name: "Wingspan",
            imageUrl: nil,
            image: .init(named: "wingspan"),
            playerCount: .init(min: 1, max: 5),
            ageRange: .init(min: 8),
            durationMinutes: 80,
            complexity: .medium
        )
        
        GameDetails(game: game)
        .modelContainer(for: Game.self, inMemory: true) { result in
            guard case .success(let container) = result else {
                return
            }
            
            container.mainContext.insert(game)
            
            game.sessions.append(.init(
                date: Date(),
                game: game,
                players: [
                    .init(name: "Alice"),
                    .init(name: "Bob"),
                    .init(name: "Charlie")
                ]
            ))
        }

    }
}
