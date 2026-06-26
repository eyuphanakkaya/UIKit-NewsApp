//
//  HomeViewModelTests.swift
//  NewsTests
//
//  Created by Eyüphan Akkaya on 25.06.2026.
//

import XCTest
import NewsApp

@MainActor
final class HomeViewModelTests: XCTestCase {
    
    func test_init_stateIsIdle() {
        let (sut, _) = makeSUT()
        XCTAssertEqual(sut.state, .idle)
    }
    
    func test_search_deliversMatchingItems_onQuery() async {
        let (sut, client) = makeSUT()
        
        await expect(sut, client, query: "Swift") {
            XCTAssertEqual(sut.numberOfItems(), 2)
        }
    }
    
    func test_search_deliversNoItems_onNonMatchingQuery() async {
        let (sut, client) = makeSUT()
        
        await expect(sut, client, query: "Apple") {
            XCTAssertEqual(sut.numberOfItems(), 0)
        }
    }
    
    func test_search_deliversAllItems_onEmptyQueryAfterFiltering() async {
        let (sut, client) = makeSUT()
        client.stubbedResult = [
            uniqueItem(title: "Swift tutorial"),
            uniqueItem(title: "iOS Development"),
            uniqueItem(title: "Swift concurrency")
        ]
        
        await sut.load()
        
        sut.search("Swift")
        sut.search("")
        
        XCTAssertEqual(sut.numberOfItems(), 3)
    }
    
    func test_search_deliversItems_insenstiveToCase() async {
        let (sut, client) = makeSUT()
        
        await expect(sut, client, query: "swift") {
            XCTAssertEqual(sut.numberOfItems(), 2)
        }

    }
    
    
    func test_toggleBookmark_addsItemToReadingList_whenNotBookmarked() async {
        let (sut, client) = makeSUT()
        let item = uniqueItem(id: "1")
        client.stubbedResult = [ item ]
        
        await sut.load()
        await sut.toggleBookmark(at: 0)
        
        XCTAssertEqual(sut.readingList.first?.id, item.id)
    }
    
    func test_toggleBookmark_removesItemFromReadingList_whenBookmarked() async {
        let (sut, client) = makeSUT()
        let item = uniqueItem(id: "1")
        client.stubbedResult = [ item ]
        
        await sut.load()
        await sut.toggleBookmark(at: 0)
        await sut.toggleBookmark(at: 0)
        
        XCTAssertTrue(sut.readingList.isEmpty)
    }
    
    // MARK: - Helpers
    func makeSUT(
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> (sut: HomeViewModel, client: FeedLoaderSpy) {
        let store = UserDefaultsReadingListStore(
            userDefaults: UserDefaults(suiteName: UUID().uuidString)!
        )
        
        let client = FeedLoaderSpy()
        let sut = HomeViewModel(loader: client, store: store)
        
        trackForMemoryLeaks(client, file: file, line: line)
        trackForMemoryLeaks(sut,file: file, line: line)
        
        return (sut, client)
    }
    
    func expect(
        _ sut: HomeViewModel,
        states: [HomeViewModel.ViewState],
        action: () async -> Void,
        file: StaticString = #filePath,
        line: UInt = #line
    ) async {
        var capturedStates: [HomeViewModel.ViewState] = []
        
        sut.onUpdate = { [weak sut] in
            guard let sut else { return }
            capturedStates.append(sut.state)
        }
        
        await action()
        
        XCTAssertEqual(capturedStates, states, file: file, line: line)
    }
    
    private func expect(
        _ sut: HomeViewModel,
        _ client: FeedLoaderSpy,
        query: String,
        assertions: () -> Void
    ) async {
        client.stubbedResult = [
            uniqueItem(title: "Swift tutorial"),
            uniqueItem(title: "iOS Development"),
            uniqueItem(title: "swift concurrency")
        ]
        
        await sut.load()
        
        sut.search(query)
        
        assertions()
    }
    
    
    final class FeedLoaderSpy: HomeViewModel.FeedLoad {
        var hasMore: Bool = false
        var stubbedError: Error?
        var stubbedResult: [NewsModel] = []

        func load() async throws -> [NewsModel] {
            if let error = stubbedError { throw error }
            return stubbedResult
        }
        
        func loadMore() async throws -> [NewsModel] {
            if let error = stubbedError { throw error }
            return stubbedResult
        }
        
    }
    
    func uniqueItem(
        id: String = UUID().uuidString,
        title: String = "any title"
    ) -> NewsModel {
        NewsModel(
            id: id,
            title: title,
            imageURL: "https://image.com/image.jpg",
            creator: ["John"],
            pubDate: "2026-06-22",
            description: "Description"
        )
    }

}
