import Foundation
import CoreLocation

public struct TestClass {
  var string: String
  var number: Float
  var location: CLLocationCoordinate2D
  var array: [Int]
  var map: [String: AnyObject]
  var set: Set<Float>
  
  public init(string: String, number: Float, location: CLLocationCoordinate2D, array: [Int], map: [String: AnyObject], set: Set<Float>) {
    self.string = string
    self.number = number
    self.location = location
    self.array = array
    self.map = map
    self.set = set
  }
}

extension TestClass: Equatable {}
public func ==(lhs: TestClass, rhs: TestClass) -> Bool {
  do {
    let map1 = try String(data: NSJSONSerialization.dataWithJSONObject(lhs.map as NSDictionary, options: NSJSONWritingOptions(rawValue: 0)), encoding: NSUTF8StringEncoding)
    let map2 = try String(data: NSJSONSerialization.dataWithJSONObject(rhs.map, options: NSJSONWritingOptions(rawValue: 0)), encoding: NSUTF8StringEncoding)
    return lhs.string == rhs.string && lhs.number == rhs.number && lhs.location.latitude == rhs.location.latitude && lhs.location.longitude == rhs.location.longitude && lhs.array == rhs.array && map1 == map2 && lhs.set == rhs.set
  } catch {
    return false
  }
}
