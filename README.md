# CacheJSON

CacheJSON is a JSON encoder/decoder for [Intersystems Cache](http://www.intersystems.com) based applications and systems.

It can be used as a stand-alone utility class or extended inside your own custom classes to "JSON Enable" your objects.

The primary features of CacheJSON are:

* Decode a single JSON object into an %ArrayOfDataTypes
* Decode nested arrays of JSON objects into a %ListOfObjects containing %ArrayOfDataTypes
* Decode a single JSON object into a custom Cache object
* Encode an %ArrayOfDataTypes to a JSON string
* Encode a custom Cache object class to a JSON string
* Encode a %ListOfObjects containing %ArrayOfDataTypes into a JSON string
* Embed an array as the value of an element
* Convert a Cache object instance into an %ArrayOfDataTypes

The original code originated from the [Intersystem's Zen Google Group Community](http://groups.google.com/group/intersystems-zen), however, the base for this class was taken from [Yontan's Blog](http://blog.yonatan.me/2010/03/objectscript-json-decoderencoder.html) and added to GitHub by [@mccrackend](http://twitter.com/#!/mccrackend)for proper tracking of enhancements and maintenance.

Cache does not come with any native JSON support, necessitating a third party utility to translate JSON strings to & from Cache objects for web applications.

## Information & Help

* For information about Intersystems products visit their [website](http://www.intersystems.com).
* Post to the [Intersystems Zen Google Group](http://groups.google.com/group/intersystems-zen) for help or questions.
* See the [GitHub issue tracker](https://github.com/PlanetCache/CacheJSON/issues).
* Visit the Intersystems [online documentation](http://docs.intersystems.com/).
* Send a message to [@PlanetCache](http://twitter.com/#!/PlanetCache) on Twitter.

## Installation

### Extending an existing %Persistent object

Import the class into your `namespace` and compile.

Then simply extend `CacheJSON` on the class you wish to use it with:

``` ruby
Class Sample.Person Extends (%Persistent, %Populate, CacheJSON) [ ClassType = persistent, Inheritance = right ]
````

### Stand-alone utility

Import the class into your `namespace` and compile.

Then call the `CacheJSON` class methods from your code.

``` ruby
Set encodedList = ##class(CacheJSON).Encode(list)
````

## Usage

Below I'll go through some of the common uses and flows you can use with CacheJSON.

### Encode an %ArrayOfObjects

An `%ArrayOfObjects` is a simple Key/Value pair dictionary object used in Cache.  CacheJSON will parse this object into a JSON string with the same key/value pairs contained in this object.  Below is sample code to create this array and encode it to a JSON string.

``` ruby
Set myArray = ##class(%ArrayOfDataTypes).%New()
Do myArray.SetAt("Dan","FirstName")
Do myArray.SetAt("McCracken","LastName")
Do myArray.SetAt("01/01/1983","DOB")
Set jsonString = ##class(CacheJSON).Encode(myArray)
````

Creates a string like so:

``` ruby
{"DOB":"01/01/1983","FirstName":"Dan","LastName":"McCracken"}
````