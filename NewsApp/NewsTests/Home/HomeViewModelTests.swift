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
    
    func test_load_transitionsThroughLoadingToLoaded() async {
        let (sut, _) = makeSUT()
    
        await expect(sut, states: [.loading, .loaded])
    }
    
    func test_load_transitionsThroughLoadingToNetworkError() async {
        let (sut, client) = makeSUT()
        client.stubbedError = anyNSError()
        
        await expect(sut, states: [.loading, .failed(.network)])
    }
    
    func test_load_deliversCorrectItemCount_onSuccess() async {
        let (sut, client) = makeSUT()
        client.stubbedResult = [
            uniqueItem(),
            uniqueItem(),
            uniqueItem()
        ]
        
        await sut.load()
        
        XCTAssertEqual(sut.numberOfItems(), 3)
    }
    
    func test_load_deliversCorrectItemCount_onError() async {
        let (sut, client) = makeSUT()
        client.stubbedError = anyNSError()
        
        await sut.load()
        
        XCTAssertEqual(sut.numberOfItems(), 0)
    }
    
    // MARK: - Helpers
    private func makeSUT(
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
    
    private func expect(_ sut: HomeViewModel, states: [HomeViewModel.ViewState]) async {
        var capturedStates: [HomeViewModel.ViewState] = []
        sut.onUpdate = { [weak sut] in
            guard let sut else { return }
            capturedStates.append(sut.state)
        }
        
        await sut.load()
        
        XCTAssertEqual(capturedStates, states)
    }
    
    
    final private class FeedLoaderSpy: HomeViewModel.FeedLoad {
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
    
    private func uniqueItem(
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
