//
//  PaginatedFeedLoader.swift
//  NewsApp
//
//  Created by Eyüphan Akkaya on 22.06.2026.
//

import Foundation

protocol PaginatedFeedLoader {
    func loadMore() async throws -> [NewsModel]
    var hasMore: Bool { get }
}
