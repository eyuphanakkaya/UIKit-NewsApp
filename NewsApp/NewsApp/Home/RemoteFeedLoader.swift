//
//  RemoteFeedLoader.swift
//  NewsApp
//
//  Created by Eyüphan Akkaya on 16.06.2026.
//

import Foundation

final class RemoteFeedLoader: FeedLoader {
    private let url: URL
    private let client: HTTPClient
    
    init(url: URL, client: HTTPClient) {
        self.url = url
        self.client = client
    }
    
    func load() async throws -> [NewsModel] {
        let (data, response) = try await client.get(url: url)
        return try RemoteFeedMapper.map(data, from: response)
    }
}
