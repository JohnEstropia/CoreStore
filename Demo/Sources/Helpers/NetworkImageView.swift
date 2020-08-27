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
    
    
    // MARK: - NetworkImageView.ImageDownloader
    
    fileprivate final class ImageDownloader: ObservableObject {
        
        // MARK: FilePrivate
        
        private(set) var image: UIImage?
        
        let url: URL?
        
        init(url: URL?) {
            
            self.url = url
            guard let url = url else {
                
                return
            }
            if let image = Self.cache[url] {
                
                self.image = image
            }
        }
        
        func fetchImage() {
            
            guard let url = url else {
                
                return
            }
            if let image = Self.cache[url] {
                
                self.objectWillChange.send()
                self.image = image
                return
            }
            self.cancellable = URLSession.shared
                .dataTaskPublisher(for: url)
                .receive(on: DispatchQueue.main)
                .sink(
                    receiveCompletion: { _ in },
                    receiveValue: { output in
                        
                        if let image = UIImage(data: output.data) {
                            
                            Self.cache[url] = image
                            self.objectWillChange.send()
                            self.image = image
                        }
                    }
                )
        }
        
        
        // MARK: Private
        
        private static var cache: [URL: UIImage] = [:]
        
        private var cancellable: AnyCancellable?
    }
}

