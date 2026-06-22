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
    
    func test_load_requestsDataFromURL() async throws {
        let url = URL(string: "https://www.example.com")!
        let (sut, client) = makeSUT(url)
        
        client.stubbedResult = .success((validJSON(), anyHTTPURLResponse(for: url)))

        _ = try await sut.load()
        
        XCTAssertEqual(client.requestURLs, [url])
    }
    
    func test_loadTwice_requestsDataFromURL() async throws {
        let url = URL(string: "https://www.example.com")!
        let (sut, client) = makeSUT(url)
        
        client.stubbedResult = .success((validJSON(), anyHTTPURLResponse(for: url)))

        _ = try await sut.load()
        _ = try await sut.load()
        
        XCTAssertEqual(client.requestURLs, [url, url])
    }
    
    func test_load_deliversErrorOnClientError() async {
        let (sut, client) = makeSUT()
        let expectError =  NSError(domain: "Test", code: 0)
        
        client.stubbedResult = .failure(expectError)
        
        do {
            let result = try await sut.load()
            XCTFail("Expected error but got \(result)")
        } catch let receiveError as NSError {
            XCTAssertEqual(receiveError.domain, expectError.domain)
            XCTAssertEqual(receiveError.code, expectError.code)
        }
        
    }
    
    // MARK: - Helpers
    private func makeSUT(_ url: URL = URL(string: "https://dummy.url")!) -> (sut: FeedLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(baseURL: url, client: client)
        
        return (sut, client)
    }
    
    
    private final class HTTPClientSpy: HTTPClient {
        private(set) var requestURLs = [URL]()
        var stubbedResult: Result<(Data, HTTPURLResponse), Error> = .failure(
            NSError(domain: "HTTPClientSpy", code: 0)
        )
        
        func get(url: URL) async throws -> (Data, HTTPURLResponse) {
            requestURLs.append(url)
            return try stubbedResult.get()
        }
    }
    
    private func validJSON() -> Data {
        let json: [String: Any] = [
            "results": [],
            "nextPage": NSNull()
        ]
        return try! JSONSerialization.data(withJSONObject: json)
    }
    
    private func anyHTTPURLResponse(for url: URL) -> HTTPURLResponse {
        HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!
    }
}
