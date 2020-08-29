//
// Demo
// Copyright © 2020 John Rommel Estropia, Inc. All rights reserved.

import Combine
import SwiftUI

// MARK: - NetworkImageView

struct NetworkImageView: View {
    
    // MARK: Internal
    
    init(url: URL?) {
        
        self.imageDownloader = .init(url: url)
    }
    
    
    // MARK: View
    
    var body: some View {
        
        if let image = self.imageDownloader.image {

            return AnyView(
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            )
        }
        else {

            return AnyView(
                Circle()
                    .colorMultiply(Color(UIColor.placeholderText))
                    .onAppear {

                        self.imageDownloader.fetchImage()
                    }
            )
        }
    }
    
    
    // MARK: Private
    
    @ObservedObject
    private var imageDownloader: ImageDownloader    
}

