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
            news = try await loader.load()
            print(news.count, "EYUPHAN")
            await MainActor.run {
                onUpdate?()
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
}
