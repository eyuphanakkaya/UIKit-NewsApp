//
//  NewsModel.swift
//  NewsApp
//
//  Created by Eyüphan Akkaya on 16.06.2026.
//

import Foundation

struct NewsModel: Equatable {
    let id: String
    let title: String
    let imageURL: String?
    let creator: [String]?
    let pubDate: String
    let description: String?
    
    var creatorText: String? {
        creator?.joined(separator: ", ").capitalized
    }
}
