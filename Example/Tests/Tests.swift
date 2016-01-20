import XCTest
import SwiftSerialize
import SwiftSerializeModule
import CoreLocation

class Tests: XCTestCase {
  func testSerialize() {
    let expectedObj = TestClass(string: "String 1", number: 54, location: CLLocationCoordinate2DMake(39, 49), array: [1, 2, 3], map: ["key1" : ["key2": 43]], set: Set([1.4, 1, 3.6, 66.6]))
    if let serializedObj = Serializer.serialize(expectedObj) {
      do {
        let obj = try Serializer.deserialize(serializedObj)
        XCTAssertEqual(expectedObj, (obj as! TestClass))
      } catch {
        XCTFail()
      }
    } else {
      XCTFail()
    }
  }
}
