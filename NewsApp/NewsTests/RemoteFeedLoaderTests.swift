//
//  RemoteFeedLoaderTests.swift
//  NewsTests
//
//  Created by Eyüphan Akkaya on 22.06.2026.
//

import XCTest
import NewsApp

final class RemoteFeedLoaderTests: XCTestCase {
    
    func test_init_doesNotRequestDataFromURL() {
        let ( _ , client) = makeSUT()
        
        XCTAssertTrue(client.requestURLs.isEmpty)
    }
    
    // MARK: - Helpers
    private func makeSUT(_ url: URL = URL(string: "https://dummy.url")!) -> (sut: FeedLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(baseURL: url, client: client)
        
        return (sut, client)
    }
    
    
    private final class HTTPClientSpy: HTTPClient {
        var requestURLs = [URL]()
        
        func get(url: URL) async throws -> (Data, HTTPURLResponse) {
            requestURLs.append(url)
            return (Data(), HTTPURLResponse())
        }
    }

}
