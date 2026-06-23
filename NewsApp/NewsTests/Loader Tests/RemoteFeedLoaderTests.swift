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
        
        client.completeWithSuccess(makeFeedJSON(), for: url)

        _ = try await sut.load()
        
        XCTAssertEqual(client.requestURLs, [url])
    }
    
    func test_loadTwice_requestsDataFromURL() async throws {
        let url = URL(string: "https://www.example.com")!
        let (sut, client) = makeSUT(url)
        
        client.completeWithSuccess(makeFeedJSON(), for: url)

        _ = try await sut.load()
        _ = try await sut.load()
        
        XCTAssertEqual(client.requestURLs, [url, url])
    }
    
    func test_load_deliversErrorOnClientError() async {
        let (sut, client) = makeSUT()
        let expectError =  NSError(domain: "Test", code: 0)
        
        client.completeWithError(expectError)
        
        do {
            let result = try await sut.load()
            XCTFail("Expected error but got \(result)")
        } catch let receiveError as NSError {
            XCTAssertEqual(receiveError.domain, expectError.domain)
            XCTAssertEqual(receiveError.code, expectError.code)
        }
    }
    
    
    func test_load_deliversErrorOnInvalidJSON() async {
        let (sut, client) = makeSUT()
        let invalidJson = Data("invalid json".utf8)
        
        client.completeWithSuccess(invalidJson)
        
        do {
            let result = try await sut.load()
            XCTFail("Expected error but got \(result)")
        } catch {
            XCTAssertTrue(error is DecodingError, "Expected DecodingError but got \(error)")
        }
    }
    
    
    func test_load_deliversSuccessOnEmptyList() async throws {
        let (sut, client) = makeSUT()

        client.completeWithSuccess(makeFeedJSON())
        
        let result = try await sut.load()
        
        XCTAssertEqual(result, [])
    }
    
    func test_load_deliverSuccessOnValidJSON() async throws {
        let (sut, client) = makeSUT()
        
        let item1  = makeItem(
            id: "1",
            title: "First News",
            imageURL: "https://image.com/1.jpg",
            creator: ["John Doe"],
            pubDate: "2026-06-22 21:50:00",
            description: "First description"
        )
        
        let item2 = makeItem(
            id: "2",
            title: "Second News",
            imageURL: nil,
            creator: ["Jane Doe"],
            pubDate: "2026-06-23 10:00:00",
            description: "Second description"
        )
        
        client.completeWithSuccess(
            makeFeedJSON([
            item1.json,
            item2.json
        ]))
        
        
        let result = try await sut.load()
        
        XCTAssertEqual(result, [item1.model, item2.model])
    }
    
    func test_load_resetsStateAfterLoadMore() async throws {
        let url = URL(string: "https://www.example.com")!

        let (sut, client) = makeSUT(url)
        
        client.completeWithSuccess(makeFeedJSON(nextPage: "token123"), for: url)
        
        _ = try await sut.load()
        
        client.completeWithSuccess(makeFeedJSON(), for: url)
        _ = try await sut.load()
        
        XCTAssertEqual(client.requestURLs, [url, url])
    }
    
    
    func test_loadMore_doesNotRequestDataWhenHasNoMore() async throws {
        let (sut, client) = makeSUT()
        
        client.completeWithSuccess(makeFeedJSON())
        
        _ = try await sut.load()
        
        _ = try await sut.loadMore()
        
        XCTAssertEqual(client.requestURLs.count, 1)
    }
    
    func test_loadMore_requestsNextPageURL() async throws {
        let url = URL(string: "https://www.example.com")!
        let (sut, client) = makeSUT(url)
        
        client.completeWithSuccess(makeFeedJSON(nextPage: "token123"), for: url)
        
        _ = try await sut.load()
        
        let expectedURL = URL(string: "https://www.example.com?page=token123")!
        client.completeWithSuccess(makeFeedJSON(), for: expectedURL)
        
        _ = try await sut.loadMore()
        
        XCTAssertEqual(client.requestURLs, [url, expectedURL])
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
    private func makeSUT(_ url: URL = URL(string: "https://any-url.com")!) -> (sut: FeedLoader & PaginatedFeedLoader , client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(baseURL: url, client: client)
        
        trackForMemoryLeaks(client)
        trackForMemoryLeaks(sut)
        
        return (sut, client)
    }
    
    private func makeItem(
        id: String = "1",
        title: String = "A title",
        imageURL: String? = "https://image.com/image.jpg",
        creator: [String]? = ["John"],
        pubDate: String = "2026-06-22",
        description: String? = "Description"
    ) -> (
        model: NewsModel,
        json: [String: Any]
    ) {
        let model = NewsModel(
            id: id,
            title: title,
            imageURL: imageURL,
            creator: creator,
            pubDate: pubDate,
            description: description
        )

        let json: [String: Any] = [
            "article_id": id,
            "title": title,
            "image_url": imageURL as Any,
            "creator": creator as Any,
            "pubDate": pubDate,
            "description": description as Any
        ]

        return (model, json)
    }
    
    private func makeFeedJSON(
        _ items: [[String: Any]] = [],
        nextPage: String? = nil
    ) -> Data {
        let json: [String: Any] = [
            "results": items,
            "nextPage": nextPage as Any
        ]
        return try! JSONSerialization.data(withJSONObject: json)
    }
}
