//
//  ForEachSection.swift
//  CoreStore
//
//  Created by John Rommel Estropia on 2021/02/13.
//  Copyright © 2021 John Rommel Estropia. All rights reserved.
//

#if canImport(Combine) && canImport(SwiftUI)

import Combine
import SwiftUI


// MARK: - ForEachSection

@available(iOS 13.0, tvOS 13.0, watchOS 6.0, macOS 10.15, *)
public struct ForEachSection<Object: DynamicObject, Sections: View>: View {
    
    // MARK: Internal
    
    public init(
        in listSnapshot: LiveList<Object>.Items,
        @ViewBuilder sections: @escaping (
            _ sectionID: ListSnapshot<Object>.SectionID,
            _ objects: [ObjectPublisher<Object>]
        ) -> Sections
    ) {
        
        self.listSnapshot = listSnapshot
        self.sections = sections
    }
    
    
    // MARK: View
    
    public var body: some View {
        
        ForEach(self.listSnapshot.sectionIDs, id: \.self) { sectionID in
            
            self.sections(
                sectionID,
                self.listSnapshot.items(inSectionWithID: sectionID)
            )
        }
    }
    
    
    // MARK: Private
    
    private let listSnapshot: LiveList<Object>.Items
    
    private let sections: (
        _ sectionID: ListSnapshot<Object>.SectionID,
        _ objects: [ObjectPublisher<Object>]
    ) -> Sections
}

#endif
