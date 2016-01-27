# SwiftSerialize

[![CI Status](http://img.shields.io/travis/CKalnasy/SwiftSerialize.svg?style=flat)](https://travis-ci.org/CKalnasy/SwiftSerialize)
[![Version](https://img.shields.io/cocoapods/v/SwiftSerialize.svg?style=flat)](http://cocoapods.org/pods/SwiftSerialize)
[![License](https://img.shields.io/cocoapods/l/SwiftSerialize.svg?style=flat)](http://cocoapods.org/pods/SwiftSerialize)
[![Platform](https://img.shields.io/cocoapods/p/SwiftSerialize.svg?style=flat)](http://cocoapods.org/pods/SwiftSerialize)

## Usage

```Swift
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

let obj = TestClass(string: "String 1", number: 54, location: CLLocationCoordinate2DMake(39, 49), array: [1, 2, 3], map: ["key1" : ["key2": 43]], set: Set([1.4, 1, 3.6, 66.6]))
let serializedObj = Serializer.serialize(obj)
let deserializedObj = try! Serializer.deserialize(serializedObj)
```

## Limitations & Workarounds

If a dictionary is passed to the serializer, the key MUST be of type String.

Swift does not provide enough information about a struct at runtime to create an instance of a struct on the fly.
So, instead you'll run a script that'll auto-generate a file so you can create instances of a structs you specify on the fly.
Create a json file like `/Example/Tests/api.json` in this format:
```
{
  "module_name": {
    "class_name": "relative path to file"
  }
}
```

If the class is a built-in Swift class (but not a "primitive" type like Int, String, Float, etc.), set the relative path to the empty string (i.e. "") and either use the initializer provided in the library already if it exists or create your own. See the Built-in Swift Classes section to see which classes are included in the library.

The first public initializer found in the file is the one that will be used in deserializing

Then run the initializer script (/SwiftSerialize/Init.php) and pass the path of the json file as the only argument.
`php SwiftSerialize/Init.php Example/Tests/api.json`

## Built-in Swift Classes

Initializers for built-in Swift classes (but not "primitive" types like Int, String, Float, etc.) have to created by hand (which isn't hard at all!).
So add them in your own project or even better, submit a pull request to this repo with the initializers you made!

List of currently supported built-in Swift classes:
- CLLocationCoordinate2D

## Installation

SwiftSerialize is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "SwiftSerialize"
```

## Running the Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

Run `php SwiftSerialize/Init.php Example/Tests/api.json` in the root of the project to auto generate the initializers for the test cases

## Contributing

Will accept all valid pull requests, feature requests, and other issues. Want to help, just ask!

## License

SwiftSerialize is available under the MIT license. See the LICENSE file for more info.
