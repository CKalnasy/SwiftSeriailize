import Foundation
import CoreLocation

enum InitializerError: ErrorType {
  case invalidArg(Int)
}

// MARK: Swift built-in type initializers
internal struct Initializer {
  static func initCLLocationCoordinate2D(dict: [String: AnyObject]) throws -> CLLocationCoordinate2D {
    let args = getArgs(dict)
    if let arg1 = args["latitude"] as? CLLocationDegrees {
      if let arg2 = args["longitude"] as? CLLocationDegrees {
        return CLLocationCoordinate2D(latitude: arg1, longitude: arg2)
      } else { throw InitializerError.invalidArg(2) }
    } else { throw InitializerError.invalidArg(1) }
  }
}

// MARK: private helpers
extension Initializer {
  static func getArgs(dict: [String: AnyObject]) -> [String: Any] {
    var args: [String: Any] = [:]
    for (key, value) in dict {
      if isProperty(key) {
        args[key] = Serializer.deserialize(value)
      }
    }
    return args
  }
  
  private static func isProperty(property: String) -> Bool {
    // keys that begin with `@` are not apart of the actual object (it's metadata)
    return property.substringToIndex(property.startIndex.advancedBy(1)) != "@"
  }
}
