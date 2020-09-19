//
// Demo
// Copyright © 2020 John Rommel Estropia, Inc. All rights reserved.

// MARK: - Advanced

extension Advanced {
    
    // MARK: - Advanced.EvolutionDemo

    /**
     Sample execution of progressive migrations. This example demonstrates the following concepts:

     - How to inspect the current model version of the store (if it exists)
     - How to do two-way migration chains (upgrades + downgrades)
     - How to support multiple versions of the model on the same app
     - How to migrate between `NSManagedObject` schema (`xcdatamodel` files) and `CoreStoreObject` schema.
     - How to use `XcodeSchemaMappingProvider`s for `NSManagedObject` stores, and `CustomSchemaMappingProvider`s for `CoreStoreObject` stores
     - How to manage migration models using namespacing technique

     Note that ideally, your app should be supporting just the latest version of the model, and provide one-way progressive migrations from all the earlier versions.
     */
    enum EvolutionDemo {}
}
