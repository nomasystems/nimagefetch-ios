//  Copyright © 2017 Nomasystems. All rights reserved.

import Foundation
import NMAImageFetch

extension NImageFetchView {
    
    public func setImage(_ request: ImageFetchRequest, animated: NImageFetchViewAnimated = .ifAsync, fallbackImage: UIImage? = nil) {
        self.__setImageFrom(request, animated: animated, fallbackImage: fallbackImage)
    }
    
    public func setImage(from urlRequest: URLRequest, animated: NImageFetchViewAnimated = .ifAsync) {
        self.__setImageFrom(urlRequest, animated: animated)
    }
    
}
