//
//  ImageDownloader.swift
//  Demo
//
//  Created by John Rommel Estropia on 2020/08/29.
//

import Foundation
import UIKit
import Combine

// MARK: - ImageDownloader

final class ImageDownloader: ObservableObject {
    
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
    
    func fetchImage(completion: @escaping (UIImage) -> Void = { _ in }) {
        
        guard let url = url else {
            
            return
        }
        if let image = Self.cache[url] {
            
            self.objectWillChange.send()
            self.image = image
            completion(image)
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
                        completion(image)
                    }
                }
            )
    }
    
    
    // MARK: Private
    
    private static var cache: [URL: UIImage] = [:]
    
    private var cancellable: AnyCancellable?
}
