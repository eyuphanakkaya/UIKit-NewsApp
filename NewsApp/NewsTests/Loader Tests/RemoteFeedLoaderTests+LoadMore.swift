//
//  RemoteFeedLoaderTests+LoadMore.swift
//  NewsTests
//
//  Created by Eyüphan Akkaya on 26.06.2026.
//

import XCTest
import NewsApp

extension RemoteFeedLoaderTests {
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
}
