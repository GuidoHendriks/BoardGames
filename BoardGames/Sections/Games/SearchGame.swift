//
//  SearchGame.swift
//  BoardGames
//
//  Created by Guido Hendriks on 25/11/2024.
//

import SwiftUI

@Observable
class ParserDelegate: NSObject, XMLParserDelegate {
    let callback: ([SearchResult]) -> Void
    init(callback: @escaping ([SearchResult]) -> Void) {
        self.callback = callback
    }
    
    struct PartialResult {
        var id: Int?
        var name: String?
        var year: Int?
    }
    
    struct SearchResult : Identifiable{
        let id: Int
        let name: String
        let year: Int
    }
    
    private var partialResult: PartialResult = .init()
    private var searchResults: [SearchResult] = []
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        
        switch elementName {
        case "item":
            partialResult.id = Int(attributeDict["id"]!)
        case "name":
            if attributeDict["type"] == "primary" {
                partialResult.name = attributeDict["value"]
            }
        case "yearpublished":
            partialResult.year = Int(attributeDict["value"]!)
        default:
            break
        }
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        guard elementName == "item" else {
            return
        }
        
        if let id = partialResult.id, let name = partialResult.name, let year = partialResult.year {
            searchResults.append(.init(id: id, name: name, year: year))
        }
        
        partialResult = .init()
    }
    
    func parserDidEndDocument(_ parser: XMLParser) {
        callback(searchResults)
        searchResults = []
    }
}

struct SearchGame: View {
    @Environment(\.dismiss) private var dismiss
    
    @State private var results: [ParserDelegate.SearchResult] = []
    
    let name: String
    let callback: (Int) -> Void
    
    var body: some View {
        List(results) { result in
            Button {
                callback(result.id)
                dismiss()
            } label: {
                VStack(alignment: .leading) {
                    Text("\(result.name)")
                    Text(verbatim: "\(result.year)")
                        .foregroundStyle(.secondary)
                }
            }
            .foregroundStyle(.primary)
        }
        .navigationTitle("Search Results")
        .task {
            await loadResults(exact: true)
        }
    }
    
    nonisolated private func loadResults(exact: Bool) async {
        let parser = XMLParser(contentsOf: .init(string: "https://boardgamegeek.com/xmlapi2/search?query=\(name)&type=boardgame&exact=\(exact ? 1 : 0)")!)
        
        let delegate = ParserDelegate { results in
            Task { @MainActor in
                self.results = results
                
                if results.isEmpty && exact {
                    await loadResults(exact: false)
                }
            }
        }
        parser?.delegate = delegate
        
        _ = parser?.parse()
    }
}

#Preview {
    NavigationStack {
        SearchGame(name: "Tapestry") { _ in
            //
        }
    }
}
