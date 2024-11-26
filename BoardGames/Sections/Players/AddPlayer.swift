//
//  AddPlayer.swift
//  BoardGames
//
//  Created by Guido Hendriks on 25/11/2024.
//

import SwiftUI
import SwiftData

struct AddPlayer: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var name = ""
    
    var body: some View {
        Form {
            TextField("Name", text: $name)
        }
        .navigationTitle("Add Player")
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    dismiss()
                }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Add") {
                    let newPlayer = Player(name: name)
                    
                    modelContext.insert(newPlayer)
                    
                    dismiss()
                }
            }
        }
    }
}
