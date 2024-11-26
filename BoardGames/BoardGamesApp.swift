//
//  BoardGamesApp.swift
//  BoardGames
//
//  Created by Guido Hendriks on 25/11/2024.
//

import SwiftUI
import SwiftData

@main
struct BoardGamesApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Game.self,
            Player.self,
            Session.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    
    @State private var gamesStack = NavigationPath()

    var body: some Scene {
        WindowGroup {
            TabView {
                Tab("Games", systemImage: "list.bullet") {
                    NavigationStack(path: $gamesStack) {
                        Games(navigationPath: $gamesStack)
                    }
                }
                Tab("Players", systemImage: "person.3") {
                    NavigationStack {
                        Players()
                    }
                }
                Tab("Data", systemImage: "arrow.up.arrow.down.square") {
                    NavigationStack {
                        DataControl()
                    }
                }
            }
        }
        .modelContainer(sharedModelContainer)
    }
}
