//  Copyright © 2017 Nomasystems. All rights reserved.

import Foundation
import NMAImageFetch

extension ImageFetch  {
    
    public enum ImageFetchError: Error {
        case cancelled
        case networkError(Error?)
        
        /// Represents the http status code of the network response
        public var statusCode: Int? {
            switch self {
                case .cancelled:
                    return nil
                case let .networkError(error):
                    return (error as? NSError)?.userInfo[NMAImageFetch.NImageFetchErrorStatusCodeKey] as? Int
            }
        }
    }
    
    public enum Result {
        case success(UIImage, ImageFetchFlags)
        case failure(ImageFetchError)
    }

    public func requestImage(_ request: ImageFetchRequest, resultHandler: @escaping (Result) -> Void) -> ImageFetchTask? {
        let task = __fetchImage(for: request) { (image, error, flag) in
            if let image = image {
                resultHandler(Result.success(image, flag))
            } else {
                let nsError = error! as NSError
                let imageFetchError: ImageFetchError
                if nsError.code == __NImageFetchErrorCode.cancelledError.rawValue {
                    imageFetchError = .cancelled
                } else {
                    let underlyingError = nsError.userInfo[NSUnderlyingErrorKey] as? Error ?? error
                    imageFetchError = .networkError(underlyingError)
                }
                
                resultHandler(Result.failure(imageFetchError))
            }
        }
        return task
    }
    
}
