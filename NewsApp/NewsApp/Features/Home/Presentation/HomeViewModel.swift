//
//  HomeViewModel.swift
//  NewsApp
//
//  Created by Eyüphan Akkaya on 16.06.2026.
//

import Foundation

@MainActor
final public class HomeViewModel {
    public typealias FeedLoad = FeedLoader & PaginatedFeedLoader
    private let loader: FeedLoad
    private let store: ReadingListStore
    
    private var news: [NewsModel] = []
    private var allNews: [NewsModel] = []
    
    private(set) public var readingList: [NewsModel] = []
    
    public enum ViewState: Equatable {
        case idle
        case loading
        case loaded
        case failed(AppError)
    }
    
    public enum AppError: Error, Equatable {
        case network
        case storage
    }
    
    private(set) public var state: ViewState = .idle
    
    public var onUpdate: (() -> Void)?
    var onSelectItem: ((NewsModel) -> Void)?
    
    public init(loader: FeedLoad, store: ReadingListStore) {
        self.loader = loader
        self.store = store
    }
    
    
    public func load() async {
        transition(to: .loading)
        
        do {
            allNews = try await loader.load()
            news = allNews
            transition(to: .loaded)
        } catch {
            transition(to: .failed(.network))
        }
    }
    
    public func loadMore() async {
        guard loader.hasMore else { return }
        
        transition(to: .loading)
        
        do {
            let newItems = try await loader.loadMore()
            allNews += newItems
            news = allNews
            transition(to: .loaded)
        } catch {
            transition(to: .failed(.network))
        }
    }
    
    private func transition(to newState: ViewState) {
        state = newState
        onUpdate?()
    }
    
}

extension HomeViewModel {
    
    public func search(_ query: String) {
        guard !query.isEmpty else {

            news = allNews
            onUpdate?()
            return
        }

        news = allNews.filter {
            $0.title.localizedCaseInsensitiveContains(query)
        }

        onUpdate?()
    }
}

extension HomeViewModel {
    func fetchReadingList() async {
        do {
            readingList = try await store.retrieve()
            onUpdate?()
        } catch {
            transition(to: .failed(.storage))
        }
    }
    
    public func toggleBookmark(at index: Int) async {
        let item = news[index]

        if readingList.contains(where: { $0.id == item.id }) {
            await removeFromReadingList(item.id)
        } else {
            await addToReadingList(item)
        }

        onUpdate?()
    }
    
    
    private func addToReadingList(_ news: NewsModel) async {
        do {
            try await store.insert(news)
            readingList.append(news)
        } catch {
            transition(to: .failed(.storage))
        }
    }
    
    private func removeFromReadingList(_ id: String) async {
        do {
            try await store.delete(id)
            readingList.removeAll { $0.id == id }
        } catch {
            transition(to: .failed(.storage))
        }
    }
}


extension HomeViewModel {
    public func numberOfItems() -> Int {
        news.count
    }
    
    func item(at index: Int) -> NewsCellViewModel {
        let item = news[index]

        return NewsCellViewModel(
            title: item.title,
            description: item.description,
            creator: item.creatorText,
            date: item.pubDate,
            imageURL: item.imageURL,
            isBookmarked: readingList.contains { $0.id == item.id }
        )
    }
    
    func didSelectItem(at index: Int) {
        let item = news[index]

        onSelectItem?(item)
    }
}
