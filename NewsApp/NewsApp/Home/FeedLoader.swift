//
//  FeedLoader.swift
//  NewsApp
//
//  Created by Eyüphan Akkaya on 16.06.2026.
//

import Foundation

protocol FeedLoader {
    func load() async throws -> [NewsModel]
}
