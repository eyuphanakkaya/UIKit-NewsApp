//
//  HomeViewModel.swift
//  NewsApp
//
//  Created by Eyüphan Akkaya on 16.06.2026.
//

import Foundation

@MainActor
final class HomeViewModel {
    private let loader: FeedLoader
    
    private(set) var news: [NewsModel] = []
    private var allNews: [NewsModel] = []
    private(set) var isLoading: Bool = false
    private(set) var errorMessage: String = ""
    
    var onUpdate: (() -> Void)?
    
    init(loader: FeedLoader) {
        self.loader = loader
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
