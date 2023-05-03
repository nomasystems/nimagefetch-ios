import XCTest
import NMAImageFetch
import NMAImageFetchSwift
import UIKit

final class NMAImageFetchTests: XCTestCase {

    override func setUp() async throws {
        await ImageFetch().purgeCaches()
    }

    func testPNGLoading() throws {
        let url = Bundle.module.url(forResource: "Mocks/Image", withExtension: "png")!
        let imageFetch = ImageFetch()
        let imageFetchRequest = ImageFetchRequest(urlRequest: URLRequest(url: url))
        let expectedImage = UIImage(contentsOfFile: url.path)
        let expectationWithoutCaching = expectation(description: "Image request finished without caching")
        _ = imageFetch.requestImage(imageFetchRequest) { result in
            expectationWithoutCaching.fulfill()
            switch result {
            case .success(let image, _):
                XCTAssertEqual(image.pngData(), expectedImage?.pngData())
            case .failure(_):
                XCTFail()
            }
        }
        let expectationWithCaching = expectation(description: "Image request finished width caching")
        _ = imageFetch.requestImage(imageFetchRequest) { result in
            expectationWithCaching.fulfill()
            switch result {
            case .success(let image, _):
                XCTAssertEqual(image.pngData(), expectedImage?.pngData())
            case .failure(_):
                XCTFail()
            }
        }
        waitForExpectations(timeout: 1)
    }

    func testVectorLoading() throws {
        let url = Bundle.module.url(forResource: "Mocks/Vector", withExtension: "pdf")!
        let imageFetch = ImageFetch()
        let imageFetchRequest = ImageFetchRequest(urlRequest: URLRequest(url: url))
        let pointSize = CGSize(width: 100, height: 100)
        imageFetchRequest.pointSize = pointSize
        let expectationWithoutCaching = expectation(description: "Image request finished without caching")
        _ = imageFetch.requestImage(imageFetchRequest) { result in
            expectationWithoutCaching.fulfill()
            switch result {
            case .success(let image, _):
                XCTAssertNotNil(image)
            case .failure(_):
                XCTFail()
            }
        }
        let expectationWithCaching = expectation(description: "Image request finished with caching")
        _ = imageFetch.requestImage(imageFetchRequest) { result in
            expectationWithCaching.fulfill()
            switch result {
            case .success(let image, _):
                XCTAssertNotNil(image)
            case .failure(_):
                XCTFail()
            }
        }
        waitForExpectations(timeout: 1)
    }

    func testCancel() {
        let url = Bundle.module.url(forResource: "Mocks/Image", withExtension: "png")!
        let imageFetch = ImageFetch()
        let imageFetchRequest = ImageFetchRequest(urlRequest: URLRequest(url: url))
        let expectationWithoutCaching = expectation(description: "Image request finished without caching")
        let imageFetchRequestTask = imageFetch.requestImage(imageFetchRequest) { result in
            expectationWithoutCaching.fulfill()
            switch result {
            case .success(_, _):
                XCTFail()
            case .failure(let error):
                switch error {
                case .cancelled:
                    XCTAssertTrue(true)
                    XCTAssertNil(error.statusCode)
                default:
                    XCTFail()
                }
            }
        }
        imageFetch.cancel(imageFetchRequestTask)
        waitForExpectations(timeout: 1)
    }

    func testImageNotFound() throws {
        let url = try XCTUnwrap(URL(string: "https://github.com/nomasystems/nimagefetch-ios/blob/main/404.png"))
        let imageFetch = ImageFetch()
        let imageFetchRequest = ImageFetchRequest(urlRequest: URLRequest(url: url))
        let expectationWithoutCaching = expectation(description: "Image request finished without caching")
        _ = imageFetch.requestImage(imageFetchRequest) { result in
            expectationWithoutCaching.fulfill()
            switch result {
            case .success(_, _):
                XCTFail()
            case .failure(let error):
                switch error {
                case .cancelled:
                    XCTFail()
                case .networkError(_):
                    XCTAssertTrue(true)
                    XCTAssertEqual(error.statusCode, 404)
                }
            }
        }
        waitForExpectations(timeout: 5)
    }

    func testPNGLoadingWithDownsampledSize() throws {
        let url = Bundle.module.url(forResource: "Mocks/Image", withExtension: "png")!
        let imageFetch = ImageFetch()
        let imageFetchRequest = ImageFetchRequest(urlRequest: URLRequest(url: url))
        let imageSize = CGSize(width: 30, height: 8) // Keeping aspect ratio
        imageFetchRequest.pointSize = imageSize
        let expectedImage = UIImage(contentsOfFile: url.path)
        let expectationWithoutCaching = expectation(description: "Image request finished without caching")
        _ = imageFetch.requestImage(imageFetchRequest) { result in
            expectationWithoutCaching.fulfill()
            switch result {
            case .success(let image, _):
                XCTAssertNotEqual(image.pngData(), expectedImage?.pngData())
                XCTAssertEqual(image.size, imageSize)
            case .failure(_):
                XCTFail()
            }
        }
        waitForExpectations(timeout: 1)
    }

    func testImageFetchViewWithoutCompletion() {
        let url = Bundle.module.url(forResource: "Mocks/Image", withExtension: "png")!
        let expectedImage = UIImage(contentsOfFile: url.path)
        let superView = UIView() //Added as subview to test animation launched
        let imageFetchView = NImageFetchView(frame: CGRect(origin: .zero, size: CGSize(width: 100, height: 100)))
        superView.addSubview(imageFetchView)
        imageFetchView.setImage(from: URLRequest(url: url), animated: .always)
        let waitExpectation = expectation(description: "Test after 1 second")
        let result = XCTWaiter.wait(for: [waitExpectation], timeout: 1)
        if result == XCTWaiter.Result.timedOut {
            XCTAssertEqual(imageFetchView.image?.pngData(), expectedImage?.pngData())
        } else {
            XCTFail("Delay interrupted")
        }
    }

    func testImageFetchViewWithCompletion() {
        let url = Bundle.module.url(forResource: "Mocks/Image", withExtension: "png")!
        let expectedImage = UIImage(contentsOfFile: url.path)
        let superView = UIView() //Added as subview to test animation launched
        let imageFetchView = NImageFetchView(frame: CGRect(origin: .zero, size: CGSize(width: 100, height: 100)))
        superView.addSubview(imageFetchView)
        let imageExpectation = expectation(description: "View fetch image")
        imageFetchView.setImage(from: URLRequest(url: url), animated: .always) {maybeError in
            imageExpectation.fulfill()
            XCTAssertNil(maybeError)
            XCTAssertEqual(imageFetchView.image?.pngData(), expectedImage?.pngData())
        }
        waitForExpectations(timeout: 1)
    }
}

