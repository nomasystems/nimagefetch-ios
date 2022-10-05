# NMAImageFetch

`NMAImageFetch` is library for downloading and caching images efficiently using `UIKit` or `SwiftUI`.

## Prerequisites

* iOS 12.0+

## Installation

### Swift Package Manager

* File > Swift Packages > Add Package Dependency
* Add `https://github.com/nomasystems/nimagefetch-ios.git`
* Select "Up to next major" with "1.0.0"

## Usage

### Swift

```swift
    let imageFetchRequest = ImageFetchRequest(urlRequest: URLRequest(url: url))
    let pointSize = CGSize(width: 100, height: 100)
    imageFetchRequest.pointSize = pointSize
    let imageFetchTask = imageFetch.requestImage(imageFetchRequest) { result in
        switch result {
        case .success(let uiImage, _flags):
        case .failure(let error):
            switch error {
            case .cancelled: // The request had been cancelled.
            case .networkError(Error?) // The request could not be finished.
            }
        }
    }
```

### SwiftUI

### Load image from URL
```swift
ImageFetchView(url: url, animated: .always, fallbackImage: nil)
```

### Load image from URLRequest
```swift
ImageFetchView(urlRequest: URLRequest(url: url), animated: .ifAsync, fallbackImage: UIImage(named: "..."))
```

### Load image from ImageFetchRequest
```swift
ImageFetchView(imageFetchRequest: ImageFetchRequest(urlRequest: URLRequest(url: url)), animated: .never, fallbackImage: nil)
```

## Support

Any doubt or suggestion? Please check out [our issue tracker](https://github.com/nomasystems/nimagefetch-ios/issues).


