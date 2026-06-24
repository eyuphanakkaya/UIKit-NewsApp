//
//  RemoteFeedMapper.swift
//  NewsApp
//
//  Created by Eyüphan Akkaya on 16.06.2026.
//
import Foundation

enum RemoteFeedMapper {
    
    enum Error: Swift.Error {
        case invalidData
    }
    
    struct Root: Decodable {
        private let results: [NewsModelDTO]
        let nextPage: String?
        
        private struct NewsModelDTO: Decodable {
            let article_id: String
            let title: String
            let image_url: String?
            let creator: [String]?
            let pubDate: String
            let description: String?
        }
        
        var news: [NewsModel] {
            results.map{
                NewsModel(
                    id: $0.article_id,
                    title: $0.title,
                    imageURL: $0.image_url,
                    creator: $0.creator,
                    pubDate: $0.pubDate,
                    description: $0.description
                )
            }
        }
    }
    
    
    static func map(_ data: Data, from response: HTTPURLResponse) throws -> (news: [NewsModel], nextPage: String?){
        guard response.statusCode == 200 else {
            throw Error.invalidData
        }
        let decoder = JSONDecoder()
        let item = try decoder.decode(Root.self, from: data)
        return (item.news, item.nextPage)
    }
}
