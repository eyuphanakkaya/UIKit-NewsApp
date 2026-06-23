//
//  RemoteFeedLoader.swift
//  NewsApp
//
//  Created by Eyüphan Akkaya on 16.06.2026.
//

import Foundation

final public class RemoteFeedLoader: FeedLoader, PaginatedFeedLoader {
    private let baseURL: URL
    private let client: HTTPClient
    
    private var nextPage: String? = nil
    private(set) public var hasMore: Bool = true
    
    public init(baseURL: URL, client: HTTPClient) {
        self.baseURL = baseURL
        self.client = client
    }
    
    public func load() async throws -> [NewsModel] {
        nextPage = nil
        hasMore = true
        return try await fetch()
    }
    
    public func loadMore() async throws -> [NewsModel] {
        guard hasMore else { return [] }
        return try await fetch()
    }
    
    
    private func fetch() async throws -> [NewsModel] {
        let url = makeURL(page: nextPage)
        let (data, response) = try await client.get(url: url)
        let result = try RemoteFeedMapper.map(data, from: response)
        nextPage = result.nextPage
        hasMore = result.nextPage != nil
        return result.news
    }
    
    private func makeURL(page: String?) -> URL {
        guard let page,
              var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: false) else {
            return baseURL
        }
        var queryItems = components.queryItems ?? []
        queryItems.append(URLQueryItem(name: "page", value: page))
        components.queryItems = queryItems
        return components.url ?? baseURL
    }
}
