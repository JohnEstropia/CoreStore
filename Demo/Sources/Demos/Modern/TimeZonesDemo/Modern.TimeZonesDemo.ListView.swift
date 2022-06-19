//
// Demo
// Copyright © 2020 John Rommel Estropia, Inc. All rights reserved.

import CoreStore
import SwiftUI

// MARK: - Modern.TimeZonesDemo

extension Modern.TimeZonesDemo {
    
    // MARK: - Modern.TimeZonesDemo.ListView

    struct ListView: View {
        
        // MARK: Internal
        
        init(title: String, objects: [Modern.TimeZonesDemo.TimeZone]) {
            
            self.title = title
            self.values = objects.map {
                (title: $0.name, subtitle: $0.abbreviation)
            }
        }
        
        init(title: String, value: Any?) {
            
            self.title = title
            switch value {
                
            case (let array as [Any])?:
                self.values = array.map {
                    (
                        title: String(describing: $0),
                        subtitle: String(reflecting: type(of: $0))
                    )
                }
                
            case let item?:
                self.values = [
                    (
                        title: String(describing: item),
                        subtitle: String(reflecting: type(of: item))
                    )
                ]
                
            case nil:
                self.values = []
            }
        }
        
        
        // MARK: View
        
        var body: some View {
            List {
                ForEach(self.values, id: \.title) { item in
                    Modern.TimeZonesDemo.ItemView(
                        title: item.title,
                        subtitle: item.subtitle
                    )
                }
            }
            .navigationBarTitle(self.title)
        }
        
        
        // MARK: Private
        
        private let title: String
        private let values: [(title: String, subtitle: String)]
    }
}


#if DEBUG

struct _Demo_Modern_TimeZonesDemo_ListView_Preview: PreviewProvider {
    
    // MARK: PreviewProvider
    
    static var previews: some View {
        
        Modern.TimeZonesDemo.ListView(
            title: "Title",
            objects: try! Modern.TimeZonesDemo.dataStack.fetchAll(
                From<Modern.TimeZonesDemo.TimeZone>()
                    .orderBy(.ascending(\.$name))
            )
        )
    }
}

#endif
