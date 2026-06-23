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
    
    func test_load_doesNotDeliverResultAfterSUTInstanceHasBeenDeallocated() async throws {
        let url = URL(string: "https://any-url.com")!
        let client = HTTPClientSpy()
        var sut: FeedLoader? = await RemoteFeedLoader(baseURL: url, client: client)
        
        var capturedResult: [NewsModel]? = nil
        let task = Task {
            capturedResult = try? await sut?.load()
        }
        
        sut = nil
        task.cancel()
        
        await task.value
        
        XCTAssertNil(capturedResult, "SUT deallocate before finish")
    }
    
    // MARK: - Helpers
    private func makeSUT(_ url: URL = URL(string: "https://dummy.url")!) -> (sut: FeedLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(baseURL: url, client: client)
        
        return (sut, client)
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
