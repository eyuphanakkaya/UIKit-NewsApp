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
    func makeSUT(
        _ url: URL = URL(string: "https://any-url.com")!,
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> (sut: FeedLoader & PaginatedFeedLoader , client: HTTPClientSpy) {
            let client = HTTPClientSpy()
            let sut = RemoteFeedLoader(baseURL: url, client: client)
            
            trackForMemoryLeaks(client, file: file, line: line)
            trackForMemoryLeaks(sut, file: file, line: line)
            
            return (sut, client)
        }
    
    func makeItem(
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
    
    func makeFeedJSON(
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
