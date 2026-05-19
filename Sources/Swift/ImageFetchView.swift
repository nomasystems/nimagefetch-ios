//
//  ImageFetchView.swift
//  nimagefetch
//
//  Created by albertopeam on 1/10/22.
//  Copyright © 2022 Nomasystems. All rights reserved.
//

import NMAImageFetch
import SwiftUI

@available(iOS 13, *)
public struct ImageFetchView: UIViewRepresentable {
    private let imageFetchRequest: ImageFetchRequest
    private let animated: NImageFetchViewAnimated
    private let fallbackImage: UIImage?
    private let completion: NImageFetchViewCompletion?
    private let placeholderProvider: ImageFetchPlaceholderProvider?

    public init(url: URL,
                animated: NImageFetchViewAnimated = .ifAsync,
                fallbackImage: UIImage? = nil,
                placeholderProvider: ImageFetchPlaceholderProvider? = nil,
                completion: NImageFetchViewCompletion? = nil) {
        self.init(urlRequest: URLRequest(url: url), animated: animated, fallbackImage: fallbackImage, placeholderProvider: placeholderProvider, completion: completion)
    }

    public init(urlRequest: URLRequest,
                animated: NImageFetchViewAnimated = .ifAsync,
                fallbackImage: UIImage? = nil,
                placeholderProvider: ImageFetchPlaceholderProvider? = nil,
                completion: NImageFetchViewCompletion? = nil) {
        self.init(imageFetchRequest: ImageFetchRequest(urlRequest: urlRequest), animated: animated, fallbackImage: fallbackImage, placeholderProvider: placeholderProvider, completion: completion)
    }

    public init(imageFetchRequest: ImageFetchRequest,
                animated: NImageFetchViewAnimated = .ifAsync,
                fallbackImage: UIImage? = nil,
                placeholderProvider: ImageFetchPlaceholderProvider? = nil,
                completion: NImageFetchViewCompletion? = nil) {
        self.imageFetchRequest = imageFetchRequest
        self.animated = animated
        self.fallbackImage = fallbackImage
        self.placeholderProvider = placeholderProvider
        self.completion = completion
    }

    public func makeUIView(context: Context) -> NImageFetchView {
        let imageView: NImageFetchView = .init(frame: .zero)
        if let provider = placeholderProvider {
            imageView.configurePlaceholder(provider: provider)
        }
        imageView.setImage(imageFetchRequest, animated: animated, fallbackImage: fallbackImage, completion: completion)
        return imageView
    }

    public func updateUIView(_ uiView: NImageFetchView, context: Context) {}
}
