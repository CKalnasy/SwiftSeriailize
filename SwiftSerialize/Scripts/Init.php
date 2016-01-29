<?php

if (!isset($argv[1])) {
  exit_with_error('input file not specified in first arguement');
}

$init = new Init($argv[1], dirname(__dir__) . '/InitializerExtension.swift');
$init->create_init_file();

class Init {
  private $json;
  private $jsonFileLocation;
  private $out;

  public function __construct($jsonFileLocation, $outputFile) {
    $this->jsonFileLocation = $jsonFileLocation;
    $this->json = json_decode(file_get_contents(realpath($jsonFileLocation)), true);
    $this->out = fopen($outputFile, 'w');

    if (!is_array($this->json)) {
      fclose($this->out);
      exit_with_error('invalid json file');
    }
    if ($this->out === false) {
      exit_with_error('could not open output file ./InitializerExtension.swift');
    }
  }

  /**
   * Can only call create_init_file() once per lifecycle
   */
  public function create_init_file() {
    $this->print('// this file is auto-generated, do not edit it.', 0);
    $this->add_imports();
    $this->add_initializer_extension();
    $this->add_custom_class_init_functions();
  }

  private function add_imports() {
    $this->print('import Foundation', 0);
    foreach ($this->json as $module => $classes) {
      $this->print('import ' . $module, 0);
    }
  }

  private function add_initializer_extension() {
    $this->print('extension Initializer {', 0);
    $this->print('static func initClass(dict: [String: AnyObject]) throws -> Any? {', 2);
    $this->print('if let type = dict[kClassKey] as? String {', 4);
    $this->print('switch type {', 6);
    foreach ($this->json as $module => $classes) {
      foreach ($classes as $class => $location) {
        $this->print("case \"$class\":", 8);
        $this->print("return try init$class(dict)", 10);
      }
    }
    $this->print('default:', 8);
    $this->print('break', 10);
    $this->print('}', 6);
    $this->print('}', 4);
    $this->print('return nil', 4);
    $this->print('}', 2);
    $this->print('}', 0);
  }

  private function add_custom_class_init_functions() {
    $this->print('extension Initializer {', 0);
    foreach ($this->json as $module => $classes) {
      foreach ($classes as $class => $location) {
        $this->add_init_function($class, $location);
      }
    }
    $this->print('}', 0);
  }

  private function add_init_function($className, $fileLocation) {
    if (!$fileLocation) { // don't add function if no file exists (e.g. a swift class)
      return;
    }
    $this->print("private static func init$className(dict: [String: AnyObject]) throws -> $className {", 2);
    $this->print("let args = getArgs(dict)", 4);
    $args = $this->get_constructor_args($fileLocation);

    $indent = $this->declare_constructor_args($args);
    $listConverters = $this->add_return_statement($className, $args, $indent);
    $this->add_end_if_statements($args, $indent);

    $this->print('}', 2);

    $this->add_list_converters($listConverters);
  }

  // returns the current indentation
  private function declare_constructor_args($args) {
    // add every argument for the constructor
    $indent = 4;
    $i = 1;
    foreach ($args as $arg) {
      $arg = $args[$i-1];

      // if the type is a list, you can't cast to a specific generic type, so cast to `Any` for now
      $type = $arg->type;
      if ($arg->is_array() || $arg->is_set()) {
        $type = '[Any]';
      } else if ($arg->is_map()) {
        $type = '[String: Any]';
      }

      if ($arg->isOptional) {
        $this->print("let arg$i = args[\"$arg->name\"] as? $type", $indent);
      } else {
        $this->print("if let arg$i = args[\"$arg->name\"] as? $type {", $indent);
        $indent += 2;
      }
      $i++;
    }
    return $indent;
  }

  // returns list of converter functions needed
  private function add_return_statement($className, $args, $indent) {
    $listConverters = [ // array of all list generic type converting functions
      'array' => [],
      'map' => [],
      'set' => []
    ];
    $returnStatement = "return $className(";
    $j = 1;
    foreach ($args as $arg) {
      if ($j > 1) {
        $returnStatement .= ', ';
      }
      if ($arg->is_array()) {
        $genericType = $arg->get_generic_type();
        $returnStatement .= "$arg->name: convertArrayTo$genericType(arg$j)";
        $listConverters['array'][] = $genericType;
      } else if ($arg->is_map()) {
        $genericType = $arg->get_generic_type();
        $returnStatement .= "$arg->name: convertMapToString$genericType(arg$j)";
        $listConverters['map'][] = $genericType;
      } else if ($arg->is_set()) {
        $genericType = $arg->get_generic_type();
        $returnStatement .= "$arg->name: convertSetTo$genericType(arg$j)";
        $listConverters['set'][] = $genericType;
      } else {
        $returnStatement .= "$arg->name: arg$j";
      }
      $j++;
    }
    $returnStatement .= ')';
    $this->print($returnStatement, $indent);

    return $listConverters;
  }

  private function add_end_if_statements($args, $indent) {
    $i = count($args);
    foreach ($args as $arg) {
      if (!$arg->isOptional) {
        $indent -= 2;
        $this->print("} else { throw InitializerError.invalidArg({$i}) }", $indent);
      }
      $i--;
    }
  }

  private function add_list_converters($listConverters) {
    foreach ($listConverters as $listType => $genericTypes) {
      $genericTypes = array_unique($genericTypes);
      foreach ($genericTypes as $type) {
        if ($listType == 'array') {
          $this->add_array_converter($type);
        } else if ($listType == 'map') {
          $this->add_map_converter($type);
        } else if ($listType == 'set') {
          $this->add_set_converter($type);
        }
      }
    }
  }

  private function get_constructor_args($fileLocation) {
    $ret = [];
    $fileLocation = self::concat_file_to_directory($fileLocation, $this->jsonFileLocation);
    $str = file_get_contents($fileLocation);
    $initMatches = [];
    if (preg_match('/public[ ]+init[ ]*\(.+\)/', $str, $initMatches) === 1) {
      $str = remove_spaces($initMatches[0]);

      // get all args
      $begin = 0;
      while(strlen($str) > 0) {
        $begin = strpos($str, '(') !== false ? strpos($str, '(') + 1 : 0;

        // get name
        $colon = strpos($str, ':');
        $name = substr($str, $begin, $colon - $begin);

        // get type
        $end = strpos($str, ',') ?: strpos($str, ')');
        $isOptional = false;
        if ($str[$end-1] === '?') {
          $isOptional = true;
        }
        // if the type is optional, we need to remove the `?` from the end (i.e. -$isOptional)
        $type = substr($str, $colon + 1, $end - $colon - 1 - $isOptional);
        $ret[] = new Argument($name, $type, $isOptional);

        // remove last arg
        $str = substr($str, $end + 1);
      }
    }
    return $ret;
  }

  private function add_array_converter($type) {
    $this->print("private static func convertArrayTo$type(array: [Any]) -> [$type] {", 2);
    $this->print("var ret: [$type] = []", 4);
    $this->print("for a in array {", 4);
    $this->print("if let a = a as? $type {", 6);
    $this->print("ret.append(a)", 8);
    $this->print("}", 6);
    $this->print("}", 4);
    $this->print("return ret", 4);
    $this->print('}', 2);
  }

  private function add_map_converter($type) {
    $this->print("private static func convertMapToString$type(map: [String: Any]) -> [String: $type] {", 2);
    $this->print("var ret: [String: $type] = [:]", 4);
    $this->print("for (key, value) in map {", 4);
    $this->print("if let value = value as? [String: Any] {", 6);
    $this->print("ret[key] = convertMapToString$type(value)", 8);
    $this->print("}", 6);
    $this->print("if let value = value as? $type {", 6);
    $this->print("ret[key] = value", 8);
    $this->print("}", 6);
    $this->print("}", 4);
    $this->print("return ret", 4);
    $this->print('}', 2);
  }

  private function add_set_converter($type) {
    $this->print("private static func convertSetTo$type(array: [Any]) -> Set<$type> {", 2);
    $this->print("var ret: Set<$type> = []", 4);
    $this->print("for a in array {", 4);
    $this->print("if let a = a as? $type {", 6);
    $this->print("ret = ret.union(Set([a]))", 8);
    $this->print("}", 6);
    $this->print("}", 4);
    $this->print("return ret", 4);
    $this->print('}', 2);
  }

  // helpers
  // gets the file location relative to the directory of directory
  private static function concat_file_to_directory($fileLocation, $directory) {
    return realpath(dirname($directory) . '/' . $fileLocation);
  }

  // prints the string with indents and a new line
  private function print($str, $indent) {
    $this->print_indents($indent);
    fwrite($this->out, $str . PHP_EOL);
  }

  private function print_indents($indent) {
    $str = '';
    for ($i = 0; $i < $indent; $i++) {
      $str .= ' ';
    }
    fwrite($this->out, $str);
  }
}

class Argument {
  public $name;
  public $type;
  public $isOptional;

  function __construct($name, $type, $isOptional) {
    $this->name = $name;
    $this->type = remove_spaces($type);
    $this->isOptional = $isOptional;
  }

  // ignore NSDictionary since it doesn't support generics
  function is_map() {
    return ($this->type[0] === '[' && strpos($this->type, ':') !== false) ||
      substr($this->type, 0, 11) === "Dictionary<";
  }

  // ditto NSArray
  function is_array() {
    return ($this->type[0] === '[' && strpos($this->type, ':') === false) ||
      substr($this->type, 0, 6) === "Array<";
  }

  // ditto NSSet
  function is_set() {
    return substr($this->type, 0, 4) === "Set<";
  }

  function get_generic_type() {
    $begin = strpos($this->type, '[') ?: strpos($this->type, ':') ?: strpos($this->type, '<');
    $end = strpos($this->type, ']') ?: strpos($this->type, '>');
    return substr($this->type, $begin + 1, $end - $begin - 1);
  }
}

function exit_with_error($str) {
  echo $str . PHP_EOL;
  exit();
}

function remove_spaces($str) {
  return str_replace([' ', '\t', '\n', '\r', '\0', '\x0B'], '', $str);
}
