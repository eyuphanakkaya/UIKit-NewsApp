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
        let url = URL(string: "https://dummy.url")!
        let client = HTTPClientSpy()
        let _ = RemoteFeedLoader(baseURL: url, client: client)
        
        
        XCTAssertTrue(client.requestURLs.isEmpty)
    }
    
    // MARK: - Helpers
    private final class HTTPClientSpy: HTTPClient {
        var requestURLs = [URL]()
        
        func get(url: URL) async throws -> (Data, HTTPURLResponse) {
            requestURLs.append(url)
            return (Data(), HTTPURLResponse())
        }
    }

}
