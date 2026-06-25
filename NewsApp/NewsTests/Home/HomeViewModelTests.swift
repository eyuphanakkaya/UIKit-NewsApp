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
        
        var capturedStates: [HomeViewModel.ViewState] = []
        sut.onUpdate = {
            capturedStates.append(sut.state)
        }
        
        await sut.load()
        
        XCTAssertEqual(capturedStates, [.loading, .loaded])
    }
    
    func test_load_transitionsThroughLoadingToNetworkError() async {
        let (sut, client) = makeSUT()
        client.stubbedError = anyNSError()
        
        var capturedStates: [HomeViewModel.ViewState] = []
        sut.onUpdate = {
            capturedStates.append(sut.state)
        }
        
        await sut.load()
        
        XCTAssertEqual(capturedStates, [.loading, .failed(.network)])
    }
    
    
    // MARK: - Helpers
    private func makeSUT() -> (sut: HomeViewModel, client: FeedLoaderSpy) {
        let store = UserDefaultsReadingListStore(
            userDefaults: UserDefaults(suiteName: UUID().uuidString)!
        )
        
        let client = FeedLoaderSpy()
        let sut = HomeViewModel(loader: client, store: store)
        
        return (sut, client)
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

}
