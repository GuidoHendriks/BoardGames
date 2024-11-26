//
//  DataControl.swift
//  BoardGames
//
//  Created by Guido Hendriks on 25/11/2024.
//

import SwiftUI
import SwiftData
import UniformTypeIdentifiers

struct DataControl: View {
    @Environment(\.modelContext) private var modelContext
    @State private var copiedExport = false
    
    var body: some View {
        List {
            Button {
                if let games = try? modelContext.fetch(FetchDescriptor<Game>()) {
                    let encoder = JSONEncoder()
                    encoder.dateEncodingStrategy = .iso8601
                    
                    let data = try? encoder.encode(games)
                    
                    UIPasteboard.general.setValue(String(data: data!, encoding: .utf8)!, forPasteboardType: UTType.plainText.identifier)
                    
                    withAnimation {
                        copiedExport = true
                    }
                }
            } label: {
                HStack {
                    Text("Export Data")
                    if copiedExport {
                        Spacer()
                        Text("Copied to clipboard")
                            .foregroundStyle(.white)
                            .font(.subheadline)
                            .padding(.vertical, 2)
                            .padding(.horizontal, 12)
                            .background(.green, in: .capsule)
                            .task {
                                do {
                                    try await Task.sleep(for: .seconds(5))
                                    withAnimation {
                                        copiedExport = false
                                    }
                                } catch {}
                            }
                    }
                }
                
            }
        }
        .navigationBarTitle("Data")
    }
}
