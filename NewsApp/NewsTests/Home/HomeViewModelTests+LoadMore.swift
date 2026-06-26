//
//  HomeViewModelTests+LoadMore.swift
//  NewsTests
//
//  Created by Eyüphan Akkaya on 26.06.2026.
//

import XCTest
import NewsApp

extension HomeViewModelTests {
    func test_loadMore_doesNothing_whenHasMoreIsFalse() async {
        let (sut, client) = makeSUT()
        client.stubbedResult = [ uniqueItem() ]
        await sut.load()
        
        client.hasMore = false
        client.stubbedResult = [ uniqueItem(), uniqueItem() ]
        await sut.loadMore()
        
        XCTAssertEqual(sut.numberOfItems(), 1)
    }
    
    func test_loadMore_transitionsThroughLoadingToLoaded() async {
        let (sut, client) = makeSUT()
        
        client.hasMore = true
        
        await expect(sut, states: [.loading, .loaded]) {
            await sut.loadMore()
        }
    }
    
    func test_loadMore_transitionsThroughLoadingToNetworkError() async {
        let (sut, client) = makeSUT()
        client.hasMore = true
        client.stubbedError = anyNSError()
        
        await expect(sut, states: [.loading, .failed(.network)]) {
            await sut.loadMore()
        }
    }
    
    
    func test_loadMore_appendsNewItemsToExistingItems() async {
        let (sut, client) = makeSUT()
        client.stubbedResult = [ uniqueItem(), uniqueItem() ]
        
        await sut.load()
        
        client.hasMore = true
        client.stubbedResult = [ uniqueItem(), uniqueItem() ]
        await sut.loadMore()
        
        XCTAssertEqual(sut.numberOfItems(), 4)
    }
    
    func test_loadMore_deliversCorrectItemCount_onError() async {
        let (sut, client) = makeSUT()
        client.stubbedResult = [ uniqueItem(), uniqueItem() ]
        
        await sut.load()
        
        client.hasMore = true
        client.stubbedError = anyNSError()
        
        await sut.loadMore()
        
        XCTAssertEqual(sut.numberOfItems(), 2)
    }
}
