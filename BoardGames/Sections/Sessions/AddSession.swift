//
//  AddSession.swift
//  BoardGames
//
//  Created by Guido Hendriks on 25/11/2024.
//

import SwiftUI
import SwiftData

struct AddSession: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @Query(sort: \Player.name) private var availablePlayers: [Player]
    
    @State private var selectedPlayers: Set<Player> = []
    @State private var date = Date()
    
    let game: Game
    
    var body: some View {
        Form {
            Section {
                Text(game.name)
                
                DatePicker("Date", selection: $date, displayedComponents: .date)
            }
            
            Section("Players") {
                ForEach(availablePlayers) { player in
                    Button {
                        withAnimation {
                            if selectedPlayers.contains(player) {
                                selectedPlayers.remove(player)
                            } else {
                                selectedPlayers.insert(player)
                            }
                        }
                    } label: {
                        HStack {
                            Text(player.name)
                            
                            Spacer()
                            
                            if selectedPlayers.contains(player) {
                                Image(systemName: "checkmark")
                                    .imageScale(.small)
                            }
                        }
                    }
                    .foregroundStyle(.primary)
                }
            }
        }
        .navigationTitle("New Session")
        .toolbar {
            Button("Save") {
                let session = Session(
                    date: date,
                    game: game,
                    players: Array(selectedPlayers)
                )
                
                game.sessions.append(session)
                
                dismiss()
            }
            .disabled(selectedPlayers.isEmpty)
        }
    }
}

#Preview {
    NavigationStack {
        AddSession(game: .init(name: "Wingspan", imageUrl: nil, image: nil, playerCount: .init(min: 2), ageRange: .init(min: 0), durationMinutes: 0, complexity: .easy))
            .modelContainer(
                for: [Player.self, Game.self, Session.self],
                inMemory: true
            ) { result in
                guard case .success(let container) = result else {
                    return
                }
                
                for i in 1...5 {
                    let player = Player(name: "Player \(i)")
                    container.mainContext.insert(player)
                }
            }
    }
}
