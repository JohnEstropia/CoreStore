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

        func fetchPokemonForm(for pokedexEntry: ObjectSnapshot<Modern.PokedexDemo.PokedexEntry>) {

            if let pokedexForm = pokedexEntry.$pokemonForm?.snapshot {
                
                self.fetchPokemonDisplay(for: pokedexForm)
                return
            }
            self.cancellable["pokemonForm.\(pokedexEntry.$id)"] = URLSession.shared
                .dataTaskPublisher(for: pokedexEntry.$pokemonFormURL)
                .mapError({ .networkError($0) })
                .flatMap(
                    { output in

                        return Future<ObjectSnapshot<Modern.PokedexDemo.PokemonForm>, Modern.PokedexDemo.Service.Error> { promise in
                            
                            Modern.PokedexDemo.dataStack.perform(
                                asynchronous: { transaction -> Modern.PokedexDemo.PokemonForm in

                                    let json: Dictionary<String, Any> = try Self.parseJSON(
                                        try JSONSerialization.jsonObject(with: output.data, options: [])
                                    )
                                    guard let pokedexForm = try transaction.importUniqueObject(
                                        Into<Modern.PokedexDemo.PokemonForm>(),
                                        source: json
                                    ) else {
                                        
                                        throw Modern.PokedexDemo.Service.Error.unexpected
                                    }
                                    if let pokedexEntry = pokedexEntry.asEditable(in: transaction) {
                                        
                                        pokedexForm.pokedexEntry = pokedexEntry
                                        pokedexEntry.updateHash = .init()
                                    }
                                    return pokedexForm
                                },
                                success: { pokemonForm in
                                    
                                    promise(.success(pokemonForm.asSnapshot(in: Modern.PokedexDemo.dataStack)!))
                                },
                                failure: { error in
                                    
                                    switch error {
                                    
                                    case .userError(let error):
                                        switch error {
                                        
                                        case let error as Modern.PokedexDemo.Service.Error:
                                            promise(.failure(error))
                                            
                                        case let error:
                                            promise(.failure(.otherError(error)))
                                        }
                                        
                                    case let error:
                                        promise(.failure(.saveError(error)))
                                    }
                                }
                            )
                        }
                    }
                )
                .sink(
                    receiveCompletion: { completion in
                        
                        switch completion {

                        case .finished:
                            break
                            
                        case .failure(let error):
                            print(error)
                        }
                    },
                    receiveValue: { pokemonForm in

                        self.fetchPokemonDisplay(for: pokemonForm)
                    }
                )
        }
        
        func fetchPokemonDisplay(for pokemonForm: ObjectSnapshot<Modern.PokedexDemo.PokemonForm>) {

            if let pokemonDisplay = pokemonForm.$pokemonDisplay?.snapshot {
                
                return
            }
            self.cancellable["pokemonDisplay.\(pokemonForm.$id)"] = URLSession.shared
                .dataTaskPublisher(for: pokemonForm.$pokemonDisplayURL)
                .mapError({ .networkError($0) })
                .flatMap(
                    { output in

                        return Future<Void, Modern.PokedexDemo.Service.Error> { promise in
                            
                            Modern.PokedexDemo.dataStack.perform(
                                asynchronous: { transaction -> Void in

                                    let json: Dictionary<String, Any> = try Self.parseJSON(
                                        try JSONSerialization.jsonObject(with: output.data, options: [])
                                    )
                                    guard let pokemonDisplay = try transaction.importUniqueObject(
                                        Into<Modern.PokedexDemo.PokemonDisplay>(),
                                        source: json
                                    ) else {
                                        
                                        throw Modern.PokedexDemo.Service.Error.unexpected
                                    }
                                    if let pokemonForm = pokemonForm.asEditable(in: transaction) {
                                        
                                        pokemonDisplay.pokedexForm = pokemonForm
                                        pokemonForm.pokedexEntry?.updateHash = .init()
                                    }
                                },
                                success: {
                                    
                                    promise(.success(()))
                                },
                                failure: { error in
                                    
                                    switch error {
                                    
                                    case .userError(let error):
                                        switch error {
                                        
                                        case let error as Modern.PokedexDemo.Service.Error:
                                            promise(.failure(error))
                                            
                                        case let error:
                                            promise(.failure(.otherError(error)))
                                        }
                                        
                                    case let error:
                                        promise(.failure(.saveError(error)))
                                    }
                                }
                            )
                        }
                    }
                )
                .sink(
                    receiveCompletion: { completion in
                        
                        switch completion {

                        case .finished:
                            break
                            
                        case .failure(let error):
                            print(error)
                        }
                    },
                    receiveValue: { output in

                    }
                )
        }


        // MARK: Private

        private var cancellable: Dictionary<String, AnyCancellable> = [:]

        private lazy var pokedexEntries: AnyPublisher<Void, Modern.PokedexDemo.Service.Error> = URLSession.shared
            .dataTaskPublisher(
                for: URL(string: "https://pokeapi.co/api/v2/pokemon?limit=10000&offset=0")!
            )
            .mapError({ .networkError($0) })
            .flatMap(
                { output in

                    return Future<Void, Modern.PokedexDemo.Service.Error> { promise in

                        do {

                            let json: Dictionary<String, Any> = try Self.parseJSON(
                                try JSONSerialization.jsonObject(with: output.data, options: [])
                            )
                            let results: [Dictionary<String, Any>] = try Self.parseJSON(
                                json["results"]
                            )
                            Modern.PokedexDemo.dataStack.perform(
                                asynchronous: { transaction -> Void in

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

                                    promise(.failure(.saveError(error)))
                                }
                            )
                        }
                        catch let error as Modern.PokedexDemo.Service.Error {

                            promise(.failure(error))
                        }
                        catch {

                            promise(.failure(.otherError(error)))
                        }
                    }
                }
            )
            .eraseToAnyPublisher()


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
