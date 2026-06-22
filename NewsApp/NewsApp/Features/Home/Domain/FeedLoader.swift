//
//  FeedLoader.swift
//  NewsApp
//
//  Created by Eyüphan Akkaya on 16.06.2026.
//

import Foundation

public protocol FeedLoader: Sendable {
    func load() async throws -> [NewsModel]
}
