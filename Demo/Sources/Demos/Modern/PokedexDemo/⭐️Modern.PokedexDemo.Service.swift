//
// Demo
// Copyright © 2020 John Rommel Estropia, Inc. All rights reserved.

import Foundation
import Combine
import CoreStore
import UIKit


// MARK: - Modern.PokedexDemo

extension Modern.PokedexDemo {

    // MARK: - Modern.PokedexDemo.Service

    final class Service: ObservableObject {
        
        /**
         ⭐️ Sample 1: Importing a list of JSON data into `ImportableUniqueObject`s whose `ImportSource` are tuples
         */
        private static func importPokedexEntries(
            from output: URLSession.DataTaskPublisher.Output
        ) -> Future<Void, Modern.PokedexDemo.Service.Error> {
            
            return .init { promise in
                
                Modern.PokedexDemo.dataStack.perform(
                    asynchronous: { transaction -> Void in

                        let json: Dictionary<String, Any> = try self.parseJSON(
                            try JSONSerialization.jsonObject(with: output.data, options: [])
                        )
                        let results: [Dictionary<String, Any>] = try self.parseJSON(
                            json["results"]
                        )
                        _ = try transaction.importUniqueObjects(
                            Into<Modern.PokedexDemo.PokedexEntry>(),
                            sourceArray: results.enumerated().map { (index, json) in
                                (index: index, json: json)
                            }
                        )
                    },
                    success: { result in

                        promise(.success(result))
                    },
                    failure: { error in
                        
                        switch error {
                        
                        case .userError(let error as Modern.PokedexDemo.Service.Error):
                            promise(.failure(error))
                            
                        case .userError(let error):
                            promise(.failure(.otherError(error)))
                            
                        case let error:
                            promise(.failure(.saveError(error)))
                        }
                    }
                )
            }
        }
        
        /**
         ⭐️ Sample 2: Importing a single JSON data into an `ImportableUniqueObject` whose `ImportSource` is a JSON `Dictionary`
         */
        private static func importSpecies(
            for details: ObjectSnapshot<Modern.PokedexDemo.Details>,
            from output: URLSession.DataTaskPublisher.Output
        ) -> Future<ObjectSnapshot<Modern.PokedexDemo.Species>, Modern.PokedexDemo.Service.Error> {
            
            return .init { promise in
                
                Modern.PokedexDemo.dataStack.perform(
                    asynchronous: { transaction -> Modern.PokedexDemo.Species in

                        let json: Dictionary<String, Any> = try self.parseJSON(
                            try JSONSerialization.jsonObject(with: output.data, options: [])
                        )
                        guard
                            let species = try transaction.importUniqueObject(
                                Into<Modern.PokedexDemo.Species>(),
                                source: json
                            )
                        else {
                            
                            throw Modern.PokedexDemo.Service.Error.unexpected
                        }
                        details.asEditable(in: transaction)?.species = species
                        return species
                    },
                    success: { species in
                        
                        promise(.success(species.asSnapshot(in: Modern.PokedexDemo.dataStack)!))
                    },
                    failure: { error in
                        
                        switch error {
                        
                        case .userError(let error as Modern.PokedexDemo.Service.Error):
                            promise(.failure(error))
                            
                        case .userError(let error):
                            promise(.failure(.otherError(error)))
                            
                        case let error:
                            promise(.failure(.saveError(error)))
                        }
                    }
                )
            }
        }
        
        /**
         ⭐️ Sample 3: Importing a list of JSON data into `ImportableUniqueObject`s whose `ImportSource` are JSON `Dictionary`s
         */
        private static func importForms(
            for details: ObjectSnapshot<Modern.PokedexDemo.Details>,
            from outputs: [URLSession.DataTaskPublisher.Output]
        ) -> Future<Void, Modern.PokedexDemo.Service.Error> {
            
            return .init { promise in
                
                Modern.PokedexDemo.dataStack.perform(
                    asynchronous: { transaction -> Void in

                        let forms = try transaction.importUniqueObjects(
                            Into<Modern.PokedexDemo.Form>(),
                            sourceArray: outputs.map { output in
                                
                                return try self.parseJSON(
                                    try JSONSerialization.jsonObject(with: output.data, options: [])
                                )
                            }
                        )
                        guard !forms.isEmpty else {
                            
                            throw Modern.PokedexDemo.Service.Error.unexpected
                        }
                        details.asEditable(in: transaction)?.forms = forms
                    },
                    success: {
                        
                        promise(.success(()))
                    },
                    failure: { error in
                        
                        switch error {
                        
                        case .userError(let error as Modern.PokedexDemo.Service.Error):
                            promise(.failure(error))
                            
                        case .userError(let error):
                            promise(.failure(.otherError(error)))
                            
                        case let error:
                            promise(.failure(.saveError(error)))
                        }
                    }
                )
            }
        }
        

        // MARK: Internal

        private(set) var isLoading: Bool = false {
            
            willSet {
                
                self.objectWillChange.send()
            }
        }
        
        private(set) var lastError: (error: Modern.PokedexDemo.Service.Error, retry: () -> Void)? {
            
            willSet {
                
                self.objectWillChange.send()
            }
        }

        init() {}

        static func parseJSON<Output>(
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

        static func parseJSON<JSONType, Output>(
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

            self.cancellable["pokedexEntries"] = self.pokedexEntries
                .receive(on: DispatchQueue.main)
                .handleEvents(
                    receiveSubscription: { [weak self] _ in

                        guard let self = self else {

                            return
                        }
                        self.lastError = nil
                        self.isLoading = true
                    }
                )
                .sink(
                    receiveCompletion: { [weak self] completion in

                        guard let self = self else {

                            return
                        }
                        self.isLoading = false
                        switch completion {

                        case .finished:
                            self.lastError = nil

                        case .failure(let error):
                            print(error)
                            self.lastError = (
                                error: error,
                                retry: { [weak self] in

                                    self?.fetchPokedexEntries()
                                }
                            )
                        }
                    },
                    receiveValue: {}
                )
        }
        
        func fetchDetails(for pokedexEntry: ObjectSnapshot<Modern.PokedexDemo.PokedexEntry>) {
            
            self.fetchSpeciesIfNeeded(for: pokedexEntry)
        }


        // MARK: Private

        private var cancellable: Dictionary<String, AnyCancellable> = [:]

        private lazy var pokedexEntries: AnyPublisher<Void, Modern.PokedexDemo.Service.Error> = URLSession.shared
            .dataTaskPublisher(
                for: URL(string: "https://pokeapi.co/api/v2/pokemon?limit=10000&offset=0")!
            )
            .mapError({ .networkError($0) })
            .flatMap(Self.importPokedexEntries(from:))
            .eraseToAnyPublisher()

        private func fetchSpeciesIfNeeded(for pokedexEntry: ObjectSnapshot<Modern.PokedexDemo.PokedexEntry>) {
            
            guard let details = pokedexEntry.$details?.snapshot else {
                
                return
            }
            if let species = details.$species?.snapshot {
                
                self.fetchFormsIfNeeded(for: species)
                return
            }
            self.cancellable["species.\(pokedexEntry.$id)"] = URLSession.shared
                .dataTaskPublisher(for: pokedexEntry.$speciesURL)
                .mapError({ .networkError($0) })
                .flatMap({ Self.importSpecies(for: details, from: $0) })
                .sink(
                    receiveCompletion: { completion in
                        
                        switch completion {

                        case .finished:
                            break
                            
                        case .failure(let error):
                            print(error)
                        }
                    },
                    receiveValue: { species in

                        self.fetchFormsIfNeeded(for: species)
                    }
                )
        }
        
        private func fetchFormsIfNeeded(for species: ObjectSnapshot<Modern.PokedexDemo.Species>) {
            
            guard
                let details = species.$details?.snapshot,
                details.$forms.isEmpty
            else {
                
                return
            }
            self.cancellable["forms.\(species.$id)"] = species
                .$formsURLs
                .map(
                    {
                        URLSession.shared
                            .dataTaskPublisher(for: $0)
                            .mapError({ Modern.PokedexDemo.Service.Error.networkError($0) })
                            .eraseToAnyPublisher()
                    }
                )
                .reduce(
                    into: Just<[URLSession.DataTaskPublisher.Output]>([])
                        .setFailureType(to: Modern.PokedexDemo.Service.Error.self)
                        .eraseToAnyPublisher(),
                    { (result, publisher) in
                        result = result
                            .zip(publisher, { $0 + [$1] })
                            .eraseToAnyPublisher()
                    }
                )
                .flatMap({ Self.importForms(for: details, from: $0) })
                .sink(
                    receiveCompletion: { completion in
                        
                        switch completion {

                        case .finished:
                            break
                            
                        case .failure(let error):
                            print(error)
                        }
                    },
                    receiveValue: { _ in }
                )
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
