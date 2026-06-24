//
//  UserDefaultsReadingListStoreTests.swift
//  NewsTests
//
//  Created by Eyüphan Akkaya on 24.06.2026.
//

import XCTest
import NewsApp

final class UserDefaultsReadingListStoreTests: XCTestCase {
    
    func test_retrieve_deliversEmptyListOnEmptyStore() async throws {
        let sut = makeSUT()
        
        let result = try await sut.retrieve()
        
        XCTAssertTrue(result.isEmpty)
    }
    
    func test_insert_deliversInsertedItem() async throws {
        let sut = makeSUT()
        let item = makeItem()

        
        try await sut.insert(item)
        
        let result = try await sut.retrieve()
        
        XCTAssertEqual(result, [item])
    }
    
    func test_insert_replacesExistingItemWithSameID() async throws {
        let sut = makeSUT()
        
        let first = makeItem(
            id: "1",
            title: "Old"
        )
        
        let updated = makeItem(
            id: "1",
            title: "New"
        )
        
        try await sut.insert(first)
        try await sut.insert(updated)
        
        let result = try await sut.retrieve()
        
        XCTAssertEqual(result, [updated])
    }
    
    
    func test_delete_removesInsertedItem() async throws {
        let sut = makeSUT()
        let item = makeItem()
        
        try await sut.insert(item)
        
        try await sut.delete(item.id)
        
        let result = try await sut.retrieve()
        
        XCTAssertEqual(result, [])
    }
    
    
    // MARK: - Helpers
    private func makeSUT() -> UserDefaultsReadingListStore {
         let sut = UserDefaultsReadingListStore(
            userDefaults: UserDefaults(suiteName: UUID().uuidString)!
        )
        return sut
    }
    
    
    private func makeItem(
        id: String = "1",
        title: String = "A title",
        imageURL: String? = "https://image.com/image.jpg",
        creator: [String]? = ["John"],
        pubDate: String = "2026-06-22",
        description: String? = "Description"
    ) -> NewsModel {
        let model = NewsModel(
            id: id,
            title: title,
            imageURL: imageURL,
            creator: creator,
            pubDate: pubDate,
            description: description
        )

        return model
    }
}
