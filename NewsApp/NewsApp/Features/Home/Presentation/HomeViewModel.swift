//
//  HomeViewModel.swift
//  NewsApp
//
//  Created by Eyüphan Akkaya on 16.06.2026.
//

import Foundation

@MainActor
final class HomeViewModel {
    private let loader: FeedLoader & PaginatedFeedLoader
    private let store: ReadingListStore
    
    private var news: [NewsModel] = []
    private var allNews: [NewsModel] = []
    
    private(set) var readingList: [NewsModel] = []
    
    private(set) var isLoading: Bool = false
    private(set) var errorMessage: String = ""
    
    var onUpdate: (() -> Void)?
    var onSelectItem: ((NewsModel) -> Void)?
    
    init(loader: FeedLoader & PaginatedFeedLoader, store: ReadingListStore) {
        self.loader = loader
        self.store = store
    }
    
    
    func load() async {
        isLoading = true
        
        defer { isLoading = false }
        
        do {
            allNews = try await loader.load()
            news = allNews
            
            onUpdate?()
        } catch {
            errorMessage = error.localizedDescription
            onUpdate?()
        }
    }
    
    func loadMore() async {
        guard loader.hasMore,
              !isLoading else { return }
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            let newItems = try await loader.loadMore()
            allNews += newItems
            news = allNews
            onUpdate?()
        } catch {
            errorMessage = error.localizedDescription
            onUpdate?()
        }
    }
    
}

extension HomeViewModel {
    
    func search(_ query: String) {
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
            print(error)
        }
    }
    
    func toggleBookmark(at index: Int) async {
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
            print(error)
        }
    }
    
    private func removeFromReadingList(_ id: String) async {
        do {
            try await store.delete(id)
            readingList.removeAll { $0.id == id }
        } catch {
            print(error)
        }
    }
}


extension HomeViewModel {
    func numberOfItems() -> Int {
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
