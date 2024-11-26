//
//  Players.swift
//  BoardGames
//
//  Created by Guido Hendriks on 25/11/2024.
//

import SwiftUI
import SwiftData

public struct Players: View {
    @State private var showAddPlayer = false
    
    @Query(sort: \Player.name) var players: [Player]
    
    public var body: some View {
        List(players) { player in
            Text(player.name)
        }
        .navigationTitle("Players")
        .toolbar {
            Button("Add Player", systemImage: "plus") {
                showAddPlayer = true
            }
        }
        .sheet(isPresented: $showAddPlayer) {
            NavigationStack {
                AddPlayer()
            }
        }
    }
}
