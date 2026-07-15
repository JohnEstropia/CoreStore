//
// Demo
// Copyright © 2020 John Rommel Estropia, Inc. All rights reserved.

import CoreData
import CoreStore
import Foundation
import Observation


// MARK: - Modern.PokedexDemo

extension Modern.PokedexDemo {
    
    // MARK: - Modern.PokedexDemo.Service
    
    @MainActor
    @Observable
    final class Service {
        
        /**
         ⭐️ Sample 1: Importing a list of JSON data into `ImportableUniqueObject`s whose `ImportSource` are tuples
         */
        private static func importPokedexEntries(from data: Data) async throws {
            
            do {
                
                try await Modern.PokedexDemo.dataStack.async.perform { transaction -> Void in
                    
                    let json: Dictionary<String, Any> = try self.parseJSON(
                        try JSONSerialization.jsonObject(with: data, options: [])
                    )
                    let results: [Dictionary<String, Any>] = try self.parseJSON(
                        json["results"]
                    )
                    _ = try transaction.importUniqueObjects(
                        Into<Modern.PokedexDemo.PokedexEntry>(),
                        sourceArray: results.enumerated().map { index, json in
                            (index: index, json: json)
                        }
                    )
                }
            }
            catch {
                
                throw self.mapError(error)
            }
        }
        
        /**
         ⭐️ Sample 2: Importing a single JSON data into an `ImportableUniqueObject` whose `ImportSource` is a JSON `Dictionary`
         */
        private static func importSpecies(
            for detailsObjectID: NSManagedObjectID,
            from data: Data
        ) async throws -> ObjectSnapshot<Modern.PokedexDemo.Species> {
            
            let speciesObjectID = try await Modern.PokedexDemo.dataStack.async.perform { transaction -> NSManagedObjectID in
                
                let json: Dictionary<String, Any> = try self.parseJSON(
                    try JSONSerialization.jsonObject(with: data, options: [])
                )
                guard
                    let species = try transaction.importUniqueObject(
                        Into<Modern.PokedexDemo.Species>(),
                        source: json
                    )
                else {
                    
                    throw Modern.PokedexDemo.Service.Error.unexpected
                }
                transaction
                    .edit(Into<Modern.PokedexDemo.Details>(), detailsObjectID)?
                    .species = species
                return species.objectID()
            }
            guard
                let species: Modern.PokedexDemo.Species = Modern.PokedexDemo.dataStack.fetchExisting(speciesObjectID),
                let snapshot = species.asSnapshot()
            else {
                
                throw Modern.PokedexDemo.Service.Error.unexpected
            }
            return snapshot
        }
        
        /**
         ⭐️ Sample 3: Importing a list of JSON data into `ImportableUniqueObject`s whose `ImportSource` are JSON `Dictionary`s
         */
        private static func importForms(
            for detailsObjectID: NSManagedObjectID,
            from dataArray: [Data]
        ) async throws {
            
            do {
                
                try await Modern.PokedexDemo.dataStack.async.perform { transaction -> Void in
                    
                    let forms = try transaction.importUniqueObjects(
                        Into<Modern.PokedexDemo.Form>(),
                        sourceArray: dataArray.map { data in
                            
                            try self.parseJSON(
                                try JSONSerialization.jsonObject(with: data, options: [])
                            ) as [String: Any]
                        }
                    )
                    guard !forms.isEmpty else {
                        
                        throw Modern.PokedexDemo.Service.Error.unexpected
                    }
                    transaction
                        .edit(Into<Modern.PokedexDemo.Details>(), detailsObjectID)?
                        .forms = forms
                }
            }
            catch {
                
                throw self.mapError(error)
            }
        }
        
        
        // MARK: Internal
        
        private(set) var isLoading: Bool = false
        
        init() {}
        
        static nonisolated func parseJSON<Output>(
            _ json: Any?,
            file: StaticString = #file,
            line: Int = #line
        ) throws -> Output {
            
            switch json {
                
            case let json as Output:
                return json
                
            case let any:
                throw Modern.PokedexDemo.Service.Error.parseError(
                    expected: Output.self,
                    actual: type(of: any),
                    file: "\(file):\(line)"
                )
            }
        }
        
        static nonisolated func parseJSON<JSONType, Output>(
            _ json: Any?,
            transformer: (JSONType) throws -> Output?,
            file: StaticString = #file,
            line: Int = #line
        ) throws -> Output {
            
            switch json {
                
            case let json as JSONType:
                let transformed = try transformer(json)
                if let json = transformed {
                    
                    return json
                }
                throw Modern.PokedexDemo.Service.Error.parseError(
                    expected: Output.self,
                    actual: type(of: transformed),
                    file: "\(file):\(line)"
                )
                
            case let any:
                throw Modern.PokedexDemo.Service.Error.parseError(
                    expected: Output.self,
                    actual: type(of: any),
                    file: "\(file):\(line)"
                )
            }
        }
        
        func fetchPokedexEntries() {
            
            self.pokedexEntriesTask?.cancel()
            self.pokedexEntriesTask = Task { [weak self] in
                
                await self?.runFetchPokedexEntries()
            }
        }
        
        func fetchDetails(for pokedexEntry: ObjectSnapshot<Modern.PokedexDemo.PokedexEntry>) {
            
            guard let details = pokedexEntry.$details?.snapshot else {
                
                return
            }
            if let species = details.$species?.snapshot {
                
                self.fetchFormsIfNeeded(
                    key: species.$id,
                    detailsObjectID: details.objectID(),
                    species: species
                )
                return
            }
            let key = pokedexEntry.$id
            guard self.detailTasks[key] == nil else {
                
                return
            }
            let speciesURL = pokedexEntry.$speciesURL
            let detailsObjectID = details.objectID()
            self.detailTasks[key] = Task { [weak self] in
                
                guard let self else {
                    
                    return
                }
                defer {
                    
                    self.detailTasks.removeValue(forKey: key)
                }
                await self.fetchSpecies(
                    key: key,
                    detailsObjectID: detailsObjectID,
                    speciesURL: speciesURL
                )
            }
        }
        
        
        // MARK: Private
        
        @ObservationIgnored
        private static let pokedexURL = URL(
            string: "https://pokeapi.co/api/v2/pokemon?limit=10000&offset=0"
        )!
        
        @ObservationIgnored
        private var pokedexEntriesTask: Task<Void, Never>?
        
        @ObservationIgnored
        private var detailTasks: [String: Task<Void, Never>] = [:]
        
        private static func mapError(_ error: CoreStoreError) -> Modern.PokedexDemo.Service.Error {
            
            switch error {
            case .userError(let error as Modern.PokedexDemo.Service.Error):
                return error
                
            case .userError(let error):
                return .otherError(error)
                
            case let error:
                return .saveError(error)
            }
        }
        
        private func runFetchPokedexEntries() async {
            
            self.isLoading = true
            defer {
                
                self.isLoading = false
                self.pokedexEntriesTask = nil
            }
            
            do {
                
                let (data, _) = try await URLSession.shared.data(from: Self.pokedexURL)
                try Task.checkCancellation()
                try await Self.importPokedexEntries(from: data)
            }
            catch is CancellationError {
                
                return
            }
            catch let error as Modern.PokedexDemo.Service.Error {
                
                print(error)
            }
            catch let error as URLError {
                
                print(Modern.PokedexDemo.Service.Error.networkError(error))
            }
            catch {
                
                print(Modern.PokedexDemo.Service.Error.otherError(error))
            }
        }
        
        private func fetchSpecies(
            key: String,
            detailsObjectID: NSManagedObjectID,
            speciesURL: URL
        ) async {
            
            do {
                
                let (data, _) = try await URLSession.shared.data(from: speciesURL)
                try Task.checkCancellation()
                
                let species = try await Self.importSpecies(
                    for: detailsObjectID,
                    from: data
                )
                guard species.$details?.snapshot?.$forms.isEmpty == true else {
                    
                    return
                }
                await self.fetchForms(
                    detailsObjectID: detailsObjectID,
                    formsURLs: species.$formsURLs
                )
            }
            catch is CancellationError {
                
                return
            }
            catch let error as Modern.PokedexDemo.Service.Error {
                
                print(error)
            }
            catch let error as URLError {
                
                print(Modern.PokedexDemo.Service.Error.networkError(error))
            }
            catch {
                
                print(Modern.PokedexDemo.Service.Error.otherError(error))
            }
        }
        
        private func fetchFormsIfNeeded(
            key: String,
            detailsObjectID: NSManagedObjectID,
            species: ObjectSnapshot<Modern.PokedexDemo.Species>
        ) {
            
            guard species.$details?.snapshot?.$forms.isEmpty == true else {
                
                return
            }
            guard self.detailTasks[key] == nil else {
                
                return
            }
            
            let formsURLs = species.$formsURLs
            self.detailTasks[key] = Task { [weak self] in
                
                guard let self else {
                    
                    return
                }
                defer {
                    
                    self.detailTasks.removeValue(forKey: key)
                }
                await self.fetchForms(
                    detailsObjectID: detailsObjectID,
                    formsURLs: formsURLs
                )
            }
        }
        
        private func fetchForms(
            detailsObjectID: NSManagedObjectID,
            formsURLs: [URL]
        ) async {
            
            do {
                
                var dataArray: [Data] = []
                dataArray.reserveCapacity(formsURLs.count)
                
                for url in formsURLs {
                    let (data, _) = try await URLSession.shared.data(from: url)
                    try Task.checkCancellation()
                    dataArray.append(data)
                }
                try await Self.importForms(
                    for: detailsObjectID,
                    from: dataArray
                )
            }
            catch is CancellationError {
                
                return
            }
            catch let error as Modern.PokedexDemo.Service.Error {
                
                print(error)
            }
            catch let error as URLError {
                
                print(Modern.PokedexDemo.Service.Error.networkError(error))
            }
            catch {
                
                print(Modern.PokedexDemo.Service.Error.otherError(error))
            }
        }
        
        
        // MARK: - Modern.PokedexDemo.Service.Error
        
        enum Error: Swift.Error {
            
            case networkError(URLError)
            case parseError(expected: Any.Type, actual: Any.Type, file: String)
            case saveError(CoreStoreError)
            case otherError(Swift.Error)
            case unexpected
        }
    }
}
