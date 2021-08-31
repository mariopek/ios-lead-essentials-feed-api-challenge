//
//  ItemMapper.swift
//  FeedAPIChallenge
//
//  Created by Mario Pek on 8/31/21.
//  Copyright © 2021 Essential Developer Ltd. All rights reserved.
//

import Foundation

final class ItemMapper {
	private struct Root: Decodable {
		let items: [Item]
	}

	private struct Item: Decodable {
		let imageId: UUID
		let imageDescription: String?
		let imageLocation: String?
		let imageURL: URL

		enum CodingKeys: String, CodingKey {
			case imageId = "image_id"
			case imageDescription = "image_desc"
			case imageLocation = "image_loc"
			case imageURL = "image_url"
		}

		var image: FeedImage {
			return FeedImage(id: imageId, description: imageDescription, location: imageLocation, url: imageURL)
		}
	}

	private static var OK_200 = 200

	static func map(_ data: Data, _ response: HTTPURLResponse) -> FeedLoader.Result {
		guard response.statusCode == OK_200,
		      let root = try? JSONDecoder().decode(Root.self, from: data) else {
			return .failure(RemoteFeedLoader.Error.invalidData)
		}
		let items = root.items.map { $0.image }
		return .success(items)
	}
}
