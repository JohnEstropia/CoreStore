//
// Demo
// Copyright © 2020 John Rommel Estropia, Inc. All rights reserved.

import Foundation
import Combine
import CoreStore


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

        static func parseJSON<Output>(_ json: Any?) throws -> Output {

            switch json {

            case let json as Output:
                return json

            case let any:
                throw Modern.PokedexDemo.Service.Error.parseError(
                    expected: Output.self,
                    actual: type(of: any)
                )
            }
        }

        static func parseJSON<JSONType, Output>(_ json: Any?, transformer: (JSONType) -> Output?) throws -> Output {

            switch json {

            case let json as JSONType:
                let transformed = transformer(json)
                if let json = transformed {

                    return json
                }
                throw Modern.PokedexDemo.Service.Error.parseError(
                    expected: Output.self,
                    actual: type(of: transformed)
                )

            case let any:
                throw Modern.PokedexDemo.Service.Error.parseError(
                    expected: Output.self,
                    actual: type(of: any)
                )
            }
        }

        func fetchPokedexEntries() {

            self.cancellable["pokedexEntries"] = self.pokedexEntries
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

            self.cancellable["pokemonForm.\(pokedexEntry.$id)"] = URLSession.shared
                .dataTaskPublisher(for: pokedexEntry.$url)
                .eraseToAnyPublisher()
                .sink(
                    receiveCompletion: { _ in },
                    receiveValue: { output in

//                        do {
//
//                            let json: Dictionary<String, Any> = try Self.parseJSON(
//                                try JSONSerialization.jsonObject(with: output.data, options: [])
//                            )
//                            let results: [Dictionary<String, Any>] = try Self.parseJSON(
//                                json["results"]
//                            )
//                            Modern.PokedexDemo.dataStack.perform(
//                                asynchronous: { transaction -> Void in
//
//                                    _ = try transaction.importUniqueObjects(
//                                        Into<Modern.PokedexDemo.PokedexEntry>(),
//                                        sourceArray: results.enumerated().map { (index, json) in
//                                            (index: index, json: json)
//                                        }
//                                    )
//                                },
//                                success: { result in
//
//                                    promise(.success(result))
//                                },
//                                failure: { error in
//
//                                    promise(.failure(.saveError(error)))
//                                }
//                            )
//                        }
//                        catch {
//
//                        }
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
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()


        // MARK: - Modern.PokedexDemo.Service.Error

        enum Error: Swift.Error {

            case networkError(URLError)
            case parseError(expected: Any.Type, actual: Any.Type)
            case saveError(CoreStoreError)
            case otherError(Swift.Error)
        }
    }
}
