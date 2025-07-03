//  Copyright © 2017 Nomasystems. All rights reserved.

import Foundation
import NMAImageFetch

extension NImageFetchView {
    
    public func setImage(_ request: ImageFetchRequest,
                         animated: NImageFetchViewAnimated = .ifAsync,
                         fallbackImage: UIImage? = nil,
                         completion: NImageFetchViewCompletion? = nil) {
        self.__setImageFrom(request, animated: animated, fallbackImage: fallbackImage, completion: completion)
    }
    
    public func setImage(from urlRequest: URLRequest,
                         animated: NImageFetchViewAnimated = .ifAsync,
                         completion: NImageFetchViewCompletion? = nil) {
        self.__setImageFrom(urlRequest, animated: animated, completion: completion)
    }
    
    // MARK: - Async
    
    @available(iOS 13.0.0, *)
    public func setImage(
        _ request: ImageFetchRequest,
        animated: NImageFetchViewAnimated = .ifAsync,
        fallbackImage: UIImage? = nil
    ) async throws {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            self.__setImageFrom(
                request,
                animated: animated,
                fallbackImage: fallbackImage
            ) { error in
                if let error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume()
                }
            }
        }
    }
}
