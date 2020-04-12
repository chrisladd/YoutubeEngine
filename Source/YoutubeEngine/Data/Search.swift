import Foundation

public enum Type: Parameter {
    case video
    case channel

    var parameterValue: String {
        switch self {
        case .video:
            return "video"
        case .channel:
            return "channel"
        }
    }
}

public struct Search {
    public enum Filter {
        case term(String, [Type: [Part]])
        case fromChannel(String, [Part])
        case relatedTo(String, [Part])
    }

    public let filter: Filter
    public let limit: Int?
    public let pageToken: String?

    public init(_ filter: Filter, limit: Int? = nil, pageToken: String? = nil) {
        self.filter = filter
        self.limit = limit
        self.pageToken = pageToken
    }

    var types: [Type] {
        if case .term(_, let parts) = filter {
            return Array(parts.keys)
        }
        return [.video]
    }

    var videoParts: [Part] {
        switch filter {
        case .term(_, let parts):
            return parts[.video] ?? []
        case .fromChannel(_, let videoParts):
            return videoParts
        case .relatedTo(_, let videoParts):
            return videoParts
        }
    }

    var channelParts: [Part] {
        switch filter {
        case .term(_, let parts):
            return parts[.channel] ?? []
        default:
            return []
        }
    }

    var part: Part {
        return .snippet
    }
}

public enum SearchItem: Equatable {
    case channelItem(Channel)
    case videoItem(Video)

    public var video: Video? {
        if case .videoItem(let video) = self {
            return video
        }
        return nil
    }

    public var channel: Channel? {
        if case .channelItem(let channel) = self {
            return channel
        }
        return nil
    }
}

extension Search: PageRequest {

    typealias Item = SearchItem

    var method: Method { return .GET }
    var command: String { return "search" }

    var parameters: [String: String] {
        var parameters: [String: String] = [
            "part": part.parameterValue,
            "type": types.joinParameters()
        ]

        parameters["maxResults"] = limit.map(String.init)
        parameters["pageToken"] = pageToken

        switch filter {
        case .term(let query, _):
            parameters["q"] = query
        case .fromChannel(let channelId, _):
            parameters["channelId"] = channelId
        case .relatedTo(let videoId, _):
            parameters["videoId"] = videoId
        }

        return parameters
    }
}
