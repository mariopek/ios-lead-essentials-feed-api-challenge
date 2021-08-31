//
//  Copyright © 2018 Essential Developer. All rights reserved.
//

import Foundation

public final class RemoteFeedLoader: FeedLoader {
	private let url: URL
	private let client: HTTPClient

	public enum Error: Swift.Error {
		case connectivity
		case invalidData
	}

	public init(url: URL, client: HTTPClient) {
		self.url = url
		self.client = client
	}

	public func load(completion: @escaping (FeedLoader.Result) -> Void) {
		client.get(from: url, completion: { result in
			switch result {
			case let .success((data, response)):
				guard response.statusCode == 200,
				      let root = try? JSONDecoder().decode(Root.self, from: data) else {
					completion(.failure(Error.invalidData))
					return
				}
				completion(.success(root.items.map { $0.image }))
			case .failure:
				completion(.failure(Error.connectivity))
			}
		})
	}
}

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
