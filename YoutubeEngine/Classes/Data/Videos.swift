import Foundation

public struct Videos {

   public enum Filter {
      case popular
      case byIds([String])
   }

   public let filter: Filter
   public let parts: [Part]
   public let limit: Int?
   public let pageToken: String?

   public init(_ filter: Filter, parts: [Part] = [.snippet], limit: Int? = nil, pageToken: String? = nil) {
      self.filter = filter
      self.parts = parts.isEmpty ? [.snippet] : parts
      self.limit = limit
      self.pageToken = pageToken
   }
}

public struct Video: Equatable {
   public let id: String
   public let snippet: Snippet?
   public let statistics: VideoStatistics?
   public let contentDetails: VideoContentDetails?
}

public func == (lhs: Video, rhs: Video) -> Bool {
   return lhs.id == rhs.id &&
      lhs.snippet == rhs.snippet &&
      lhs.statistics == rhs.statistics &&
      lhs.contentDetails == rhs.contentDetails
}

public struct VideoStatistics: Equatable {
   public let views: Int?
   public let likes: Int?
   public let dislikes: Int?
}

public func == (lhs: VideoStatistics, rhs: VideoStatistics) -> Bool {
   return lhs.views == rhs.views &&
      lhs.likes == rhs.likes &&
      lhs.dislikes == rhs.dislikes
}

public struct VideoContentDetails: Equatable {
   public let duration: DateComponents
}

public func == (lhs: VideoContentDetails, rhs: VideoContentDetails) -> Bool {
   return lhs.duration == rhs.duration
}

extension Videos: PageRequest {

   typealias Item = Video

   var method: Method { return .GET }
   var command: String { return "videos" }

   var parameters: [String: String] {
      var parameters: [String: String] = ["part": self.parts.joinParameters()]

      switch self.filter {
      case .popular(_):
         parameters["chart"] = "mostPopular"
      case .byIds(let ids):
         parameters["id"] = ids.joinParameters()
      }

      parameters["maxResults"] = self.limit.map(String.init)
      parameters["pageToken"] = self.pageToken

      return parameters
   }
}

extension Video: PartibleObject, SearchableObject {
   func merge(with other: Video) -> Video {
      return Video(id: self.id,
                   snippet: self.snippet ?? other.snippet,
                   statistics: self.statistics ?? other.statistics,
                   contentDetails: self.contentDetails ?? other.contentDetails)
   }

   static func request(for parts: [Part], objects: [Video]) -> AnyPageRequest<Video> {
      return AnyPageRequest(Videos(.byIds(objects.map { $0.id }), parts: parts))
   }

   var searchItemType: Type {
      return .video
   }

   func toSearchItem() -> SearchItem {
      return .videoItem(self)
   }

   static func from(searchItem: SearchItem) -> Video? {
      return searchItem.video
   }
}
