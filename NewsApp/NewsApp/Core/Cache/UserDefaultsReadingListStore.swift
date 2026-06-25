//
//  UserDefaultsReadingListStore.swift
//  NewsApp
//
//  Created by Eyüphan Akkaya on 19.06.2026.
//

import Foundation

final public class UserDefaultsReadingListStore: ReadingListStore {
    
    private struct CodableNewsModel: Codable {
        let id: String
        let title: String
        let imageURL: String?
        let creator: [String]?
        let pubDate: String
        let description: String?
        
        init(_ model: NewsModel) {
            id = model.id
            title = model.title
            imageURL = model.imageURL
            creator = model.creator
            pubDate = model.pubDate
            description = model.description
        }
        
        var model: NewsModel {
            NewsModel(
                id: id,
                title: title,
                imageURL: imageURL,
                creator: creator,
                pubDate: pubDate,
                description: description
            )
        }
    }
    
    
    private let userDefaults: UserDefaults
    private let key: String
    
    public init(userDefaults: UserDefaults, key: String = "readingList") {
        self.userDefaults = userDefaults
        self.key = key
    }
    
    public func insert(_ item: NewsModel) async throws {
        var items = try loadItems()
        items.removeAll { $0.id == item.id }
        items.append(CodableNewsModel(item))
        try save(items)
    }
    
    public func delete(_ itemID: String) async throws {
        var items = try loadItems()
        items.removeAll { $0.id == itemID }
        try save(items)
    }
    
    public func retrieve() async throws -> [NewsModel] {
        try loadItems().map{$0.model}
    }
    
    private func loadItems() throws -> [CodableNewsModel] {
        guard let data = userDefaults.data(forKey: key) else { return [] }
        return try JSONDecoder().decode([CodableNewsModel].self, from: data)
    }
    
    private func save(_ items: [CodableNewsModel]) throws {
        let data = try JSONEncoder().encode(items)
        userDefaults.set(data, forKey: key)
    }
    
}
