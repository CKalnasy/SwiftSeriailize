import Foundation
import Serialize

let kClassKey = "@type"

public struct Serializer {
  public static func serialize(a: Any) -> NSData? {
    if let obj = serializeObject(a) {
      do {
        return try NSJSONSerialization.dataWithJSONObject(obj, options: NSJSONWritingOptions(rawValue: 0))
      } catch {
        return nil
      }
    }
    return nil
  }
  
  private static func serializeObject(a: Any) -> AnyObject? {
    if isBaseType(a) {
      return (a as! AnyObject)
    }
    if isList(a) {
      if let array = a as? NSArray {
        var ret:[AnyObject] = []
        for element in array {
          if let obj = serializeObject(element) {
            ret.append(obj)
          }
        }
        return ret
      } else if let map = a as? [String: Any] {
        var ret: [String: AnyObject] = [:]
        for (key, value) in map {
          if let value = serializeObject(value) {
            ret[key] = value
          }
        }
        return ret
      } else if let map = a as? [String: AnyObject] { // for some reason, this doesn't match above
        var ret: [String: AnyObject] = [:]
        for (key, value) in map {
          if let value = serializeObject(value) {
            ret[key] = value
          }
        }
        return ret
      } else if let set = a as? NSSet {
        var ret: [AnyObject] = []
        for s in set {
          if let obj = serializeObject(s) {
            ret.append(obj)
          }
        }
        return ret
      }
    }
    
    // continue using this library since it works with
    if isSerializeableType(a) {
      if let a = a as? Serializeable {
        return a.serialize()
      }
    }
    
    let mirror = Mirror(reflecting: a)
    if mirror.children.count > 0 {
      var obj = [String: AnyObject]();
      for case let (label?, value) in mirror.children {
        obj[label] = serializeObject(value)
      }
      obj[kClassKey] = String(mirror.subjectType)
      return obj
    }
    return a as? AnyObject
  }
  
  public static func deserialize(jsonData: NSData) throws -> Any? {
    do {
      if let json = try NSJSONSerialization.JSONObjectWithData(jsonData, options: .MutableContainers) as? NSDictionary {
        return deserialize(json)
      }
    } catch {
      return nil
    }
    return nil
  }
  
  public static func deserialize(a: AnyObject) -> Any? {
    if isBaseType(a) {
      return a
    }
    if isClass(a) {
      if let a = a as? [String: AnyObject] {
        if a[kClassKey] as? String != nil {
          do {
            return try Initializer.initClass(a)
          } catch {
            return nil
          }
        }
      }
    }
    if isList(a) {
      if let array = a as? NSArray {
        var ret: [Any] = []
        for element in array {
          if let element = deserialize(element) {
            ret.append(element)
          }
        }
        return ret
      } else if let map = a as? [String: AnyObject] {
        var ret: [String: Any] = [:]
        for (key, value) in map {
          if let value = deserialize(value) {
            ret[key] = value
          }
        }
        return ret
      } else if let set = a as? NSSet {
        var ret: [Any] = []
        for s in set {
          if let s = deserialize(s) {
            ret.append(s)
          }
        }
        return ret
      }
    }
    return nil
  }
  
  private static func swiftClassFromString(className: NSString) -> AnyClass? {
    let appName: NSString = "ApiTests"
    let classStringName = "_TtC\(appName.length)\(appName)\(className.length)\(className)"
    return NSClassFromString(classStringName)
  }
  
  private static func isList(a: Any) -> Bool {
    if let _ = a as? NSArray {
      return true
    }
    if let _ = a as? NSDictionary {
      return true
    }
    if let _ = a as? [String: Any] {
      return true
    }
    if let _ = a as? NSSet {
      return true
    }
    return false
  }
  
  private static func isClass(a: Any) -> Bool {
    if let map = a as? [String: AnyObject] {
      return map[kClassKey] != nil
    }
    return false
  }
  
  private static func isBaseType(a: Any) -> Bool {
    if let _ = a as? Int { return true }
    if let _ = a as? Float { return true }
    if let _ = a as? Double { return true }
    if let _ = a as? String { return true }
    if let _ = a as? Bool { return true }
    if let _ = a as? Int8 { return true }
    if let _ = a as? Int16 { return true }
    if let _ = a as? Int32 { return true }
    if let _ = a as? Int64 { return true }
    if let _ = a as? UInt { return true }
    if let _ = a as? UInt8 { return true }
    if let _ = a as? UInt16 { return true }
    if let _ = a as? UInt32 { return true }
    if let _ = a as? UInt64 { return true }
    if let _ = a as? Float80 { return true }
    if let _ = a as? Character { return true }
    return false
  }
  
  private static func isSerializeableType(a: Any) -> Bool {
    if let _ = a as? Int { return true }
    if let _ = a as? Float { return true }
    if let _ = a as? Double { return true }
    if let _ = a as? String { return true }
    if let _ = a as? Bool { return true }
    if let _ = a as? Int8 { return true }
    if let _ = a as? Int16 { return true }
    if let _ = a as? Int32 { return true }
    if let _ = a as? Int64 { return true }
    if let _ = a as? UInt { return true }
    if let _ = a as? UInt8 { return true }
    if let _ = a as? UInt16 { return true }
    if let _ = a as? UInt32 { return true }
    if let _ = a as? UInt64 { return true }
    if let _ = a as? Float80 { return true }
    if let _ = a as? Character { return true }
    if let _ = a as? NSObject { return true }
    if let _ = a as? NSNull { return true }
    if let _ = a as? NSNumber { return true }
    if let _ = a as? NSString { return true }
    if let _ = a as? NSURL { return true }
    if let _ = a as? NSDate { return true }
    if let _ = a as? NSData { return true }
    if let _ = a as? CGFloat { return true }
    if let _ = a as? UIImage { return true }
    return false
  }
}
