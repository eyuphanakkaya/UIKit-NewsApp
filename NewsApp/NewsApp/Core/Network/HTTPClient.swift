//
//  HTTPClient.swift
//  NewsApp
//
//  Created by Eyüphan Akkaya on 16.06.2026.
//

import Foundation

public protocol HTTPClient: Sendable {
    func get(url: URL) async throws -> (Data, HTTPURLResponse)
}
