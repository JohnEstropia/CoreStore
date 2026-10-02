//
// Demo
// Copyright © 2020 John Rommel Estropia, Inc. All rights reserved.

import Foundation
import UIKit

// MARK: - ImageDownloader

@MainActor
final class ImageDownloader {

    // MARK: Internal

    private(set) var image: UIImage?

    let url: URL?

    init(url: URL?) {

        self.url = url
        guard let url else {

            return
        }
        if let image = Self.cache[url] {

            self.image = image
        }
    }

    func fetchImage(completion: @escaping (UIImage) -> Void = { _ in }) {

        guard let url else {

            return
        }
        if let image = Self.cache[url] {

            self.image = image
            completion(image)
            return
        }

        self.task = Task { [weak self] in
            
            guard let self else {

                return
            }
            do {
                
                let (data, _) = try await URLSession.shared.data(from: url)
                guard
                    !Task.isCancelled,
                    let image = UIImage(data: data)
                else {

                    return
                }
                Self.cache[url] = image
                self.image = image
                completion(image)
            }
            catch {
                
                return
            }
        }
    }


    // MARK: Private

    private static var cache: [URL: UIImage] = [:]

    private var task: Task<Void, Never>?
}
