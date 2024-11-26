//
//  AddGame.swift
//  BoardGames
//
//  Created by Guido Hendriks on 25/11/2024.
//

import SwiftUI

struct AddGame: View {
    @Observable class LoadGameDetailsParserDelegate: NSObject, XMLParserDelegate {
        let callback: (Result) -> Void
        init(callback: @escaping (Result) -> Void) {
            self.callback = callback
        }
        
        private var currentElement: String?
        
        struct Result {
            var imageUrl: String?
            var complexity: Complexity?
            var minPlayers: Int?
            var maxPlayers: Int?
            var minAge: Int?
            var duration: Int?
        }
        
        private var result = Result()
        
        func parserDidStartDocument(_ parser: XMLParser) {
            currentElement = nil
        }
        
        func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
            currentElement = elementName
            
            switch elementName {
            case "averageweight":
                if let value = attributeDict["value"], let intValue = Double(value) {
                    result.complexity = .fromWeight(intValue)
                }
            case "minplayers":
                if let value = attributeDict["value"], let intValue = Int(value) {
                    result.minPlayers = intValue
                }
            case "maxplayers":
                if let value = attributeDict["value"], let intValue = Int(value) {
                    result.maxPlayers = intValue
                }
            case "minage":
                if let value = attributeDict["value"], let intValue = Int(value) {
                    result.minAge = intValue
                }
            case "playingtime":
                if let value = attributeDict["value"], let intValue = Int(value) {
                    result.duration = intValue
                }
            default:
                break
            }
        }
        
        func parser(_ parser: XMLParser, foundCharacters string: String) {
            guard currentElement == "image" else {
                return
            }
            
            result.imageUrl = string
        }
        
        func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
            currentElement = nil
        }
        
        func parserDidEndDocument(_ parser: XMLParser) {
            callback(result)
        }
    }
    
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var image: UIImage?
    @State private var imageUrl: String?
    
    @State private var name = ""
    @State private var duration = 0
    @State private var complexity: Complexity?
    
    @State private var minPlayers = 1
    @State private var hasMaxPlayers = false
    @State private var maxPlayers = 1
    
    @State private var minAge = 0
    @State private var hasMaxAge = false
    @State private var maxAge = 0
    
    @State private var showSearch = false
    @State private var selectedBggId: Int?
    
    var body: some View {
        Form {
            if let image {
                Section {
                    LabeledContent("Image") {
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 128)
                    }
                }
            }
            
            Section {
                HStack {
                    TextField("Name", text: $name)
                    
                    if selectedBggId != nil {
                        ProgressView()
                    } else if !name.isEmpty {
                        Button("Search BGG") {
                            showSearch = true
                        }
                    }
                }
                .animation(.default, value: name.isEmpty)
            }
            
            Section {
                Picker("Complexity", selection: $complexity) {
                    if complexity == nil {
                        Text("Pick a complexity...").tag(nil as Complexity?)
                    }
                    
                    Text("Easy").tag(Complexity.easy)
                    Text("Medium").tag(Complexity.medium)
                    Text("Hard").tag(Complexity.hard)
                }
                
                Stepper("Duration: \(duration)", value: $duration, in: 0...600, step: 5)
            }
            
            Section("Players") {
                Stepper("Min: \(minPlayers)", value: $minPlayers, in: 1...99)
                if hasMaxPlayers {
                    Stepper("Max: \(maxPlayers)", value: $maxPlayers, in: minPlayers...99)
                }
                
            }
            
            Section {
                Toggle("Has Max Players", isOn: $hasMaxPlayers)
            }
            
            Section("Age Range") {
                Stepper("Min: \(minAge)", value: $minAge, in: 0...99)
                if hasMaxAge {
                    Stepper("Max: \(maxAge)", value: $maxAge, in: minAge...99)
                }
                
            }
            
            Section {
                Toggle("Has Max Age", isOn: $hasMaxAge)
            }
        }
        .listSectionSpacing(8)
        .onChange(of: minPlayers) { oldValue, newValue in
            if maxPlayers < newValue {
                maxPlayers = newValue
            } else if maxPlayers == oldValue {
                maxPlayers = newValue
            }
        }
        .animation(.default, value: hasMaxPlayers)
        .onChange(of: minAge) { oldValue, newValue in
            if maxAge < newValue {
                maxAge = newValue
            } else if maxAge == oldValue {
                maxAge = newValue
            }
        }
        .animation(.default, value: hasMaxAge)
        .navigationTitle("Add Game")
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Add Game") {
                    guard let complexity else {
                        return
                    }
                    
                    let game = Game(
                        name: name,
                        imageUrl: imageUrl,
                        image: image,
                        playerCount: .init(
                            min: minPlayers,
                            max: hasMaxPlayers ? maxPlayers : .none
                        ),
                        ageRange: .init(
                            min: minAge,
                            max: hasMaxAge ? maxAge : .none
                        ),
                        durationMinutes: duration,
                        complexity: complexity
                    )
                    
                    modelContext.insert(game)
                    
                    dismiss()
                }
                .disabled(name.isEmpty || complexity == nil)
            }
            
            ToolbarItem(placement: .topBarLeading) {
                Button("Cancel", role: .cancel) {
                    dismiss()
                }
            }
        }
        .navigationDestination(isPresented: $showSearch) {
            SearchGame(name: name) { id in
                selectedBggId = id
                
                Task.detached {
                    let parser = XMLParser(contentsOf: .init(string: "https://boardgamegeek.com/xmlapi2/thing?id=\(id)&stats=1")!)
                    
                    let delegate = LoadGameDetailsParserDelegate { result in
                        Task {
                            if let imageUrl = result.imageUrl {
                                Task {
                                    let (data, _) = try await URLSession.shared.data(from: .init(string: imageUrl)!)
                                    if let image = UIImage(data: data) {
                                        Task { @MainActor in
                                            self.image = image
                                            self.imageUrl = imageUrl
                                        }
                                    }
                                }
                            }
                            
                            Task { @MainActor in
                                complexity = result.complexity ?? complexity
                                duration = result.duration ?? duration
                                
                                minPlayers = result.minPlayers ?? minPlayers
                                maxPlayers = result.maxPlayers ?? maxPlayers
                                hasMaxPlayers = true
                                
                                minAge = result.minAge ?? minAge
                                hasMaxAge = false
                            }
                        }
                    }
                    parser?.delegate = delegate
                    parser?.parse()
                    
                    Task { @MainActor in
                        selectedBggId = nil
                    }
                }
            }
        }
        .disabled(selectedBggId != nil)
    }
}

#Preview {
    NavigationStack {
        AddGame()
    }
}
