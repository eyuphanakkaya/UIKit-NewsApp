//
//  PaginatedFeedLoader.swift
//  NewsApp
//
//  Created by Eyüphan Akkaya on 22.06.2026.
//

import Foundation

public protocol PaginatedFeedLoader: Sendable {
    func loadMore() async throws -> [NewsModel]
    var hasMore: Bool { get }
}
