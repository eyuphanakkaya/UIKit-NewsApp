//
//  UserDefaultsReadingListStoreTests.swift
//  NewsTests
//
//  Created by Eyüphan Akkaya on 24.06.2026.
//

import XCTest
import NewsApp

final class UserDefaultsReadingListStoreTests: XCTestCase {
    
    func test_retrieve_emptyList() async throws {
        let sut = makeSUT()
        
        let result = try await sut.retrieve()
        
        XCTAssertTrue(result.isEmpty)
    }
    
    func test_insert_deliverInsertedItem() async throws {
        let sut = makeSUT()
        
        let item = await NewsModel(
            id: "1",
            title: "A title",
            imageURL: "https://image.com/image.jpg",
            creator: ["John"],
            pubDate: "2026-06-22",
            description: "Description")
        
        try await sut.insert(item)
        
        let result = try await sut.retrieve()
        
        XCTAssertEqual(result, [item])
    }
    
    
    func test_delete_deleteSelectedItem() async throws {
        let sut = makeSUT()
        
        let item = await NewsModel(
            id: "1",
            title: "A title",
            imageURL: "https://image.com/image.jpg",
            creator: ["John"],
            pubDate: "2026-06-22",
            description: "Description")
        
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
}
