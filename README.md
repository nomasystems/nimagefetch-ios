# NMAImageFetch

`NMAImageFetch` is library for downloading and caching images efficiently using `UIKit`.

## Prerequisites

* iOS 12.0+

## Installation

### Swift Package Manager

* File > Swift Packages > Add Package Dependency
* Add `https://github.com/nomasystems/nimagefetch-ios.git`
* Select "Up to next major" with "1.0.0"

## Usage

### Loading an image using a NImageFetchView(subclass of UIImageView)

```swift
let imageView: NImageFetchView = .init(frame: .zero)

imageView.setImage(from: URLRequest(url: url))
```

### Loading an image using an UIImageView
```swift
let imageView: UIImageView = .init(frame: .zero)

let imageFetchRequest = ImageFetchRequest(urlRequest: URLRequest(url: url))
_ = ImageFetch.shared.requestImage(imageFetchRequest) { result in
    switch result {
        case let .success(uiImage, _):
            self.imageView.image = uiImage
        case .failure(let error):
            switch error {
                case .cancelled:
                    break
                case let .networkError(err):
                    print(err?.localizedDescription ?? "unknown network error")
            }
    }
}
```
### Cancel loading

```swift
let imageView: UIImageView = .init(frame: .zero)

let imageFetchRequest = ImageFetchRequest(urlRequest: URLRequest(url: url))
let task = ImageFetch.shared.requestImage(fetchRequest) { _ in }
if let task = task {
    ImageFetch.shared.cancel(task)
}
```

### Clear caches

```swift
ImageFetch.shared.purgeCaches()
```

## Support

Any doubt or suggestion? Please check out [our issue tracker](https://github.com/nomasystems/nimagefetch-ios/issues).


