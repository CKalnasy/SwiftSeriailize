import Foundation
import SwiftSerializeModule
import CoreLocation
extension Initializer {
  public static func initClass(dict: [String: AnyObject]) throws -> Any? {
    if let type = dict[kClassKey] as? String {
      switch type {
        case "TestClass":
          return try initTestClass(dict)
        case "CLLocationCoordinate2D":
          return try initCLLocationCoordinate2D(dict)
        default:
          break
      }
    }
    return nil
  }
}
extension Initializer {
  private static func initTestClass(dict: [String: AnyObject]) throws -> TestClass {
    let args = getArgs(dict)
    if let arg1 = args["string"] as? String {
      if let arg2 = args["number"] as? Float {
        if let arg3 = args["location"] as? CLLocationCoordinate2D {
          if let arg4 = args["array"] as? [Any] {
            if let arg5 = args["map"] as? [String: Any] {
              if let arg6 = args["set"] as? [Any] {
                return TestClass(string: arg1, number: arg2, location: arg3, array: convertArrayToInt(arg4), map: convertMapToStringAnyObject(arg5), set: convertSetToFloat(arg6))
              } else { throw InitializerError.invalidArg(6) }
            } else { throw InitializerError.invalidArg(5) }
          } else { throw InitializerError.invalidArg(4) }
        } else { throw InitializerError.invalidArg(3) }
      } else { throw InitializerError.invalidArg(2) }
    } else { throw InitializerError.invalidArg(1) }
  }
  private static func convertArrayToInt(array: [Any]) -> [Int] {
    var ret: [Int] = []
    for a in array {
      if let a = a as? Int {
        ret.append(a)
      }
    }
    return ret
  }
  private static func convertMapToStringAnyObject(map: [String: Any]) -> [String: AnyObject] {
    var ret: [String: AnyObject] = [:]
    for (key, value) in map {
      if let value = value as? [String: Any] {
        ret[key] = convertMapToStringAnyObject(value)
      }
      if let value = value as? AnyObject {
        ret[key] = value
      }
    }
    return ret
  }
  private static func convertSetToFloat(array: [Any]) -> Set<Float> {
    var ret: Set<Float> = []
    for a in array {
      if let a = a as? Float {
        ret = ret.union(Set([a]))
      }
    }
    return ret
  }
}
