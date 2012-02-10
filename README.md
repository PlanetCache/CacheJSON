# CacheJSON

CacheJSON is a JSON encoder/decoder for [Intersystems Cache](http://www.intersystems.com) based applications and systems.

It can be used as a stand-alone utility class or extended inside your own custom classes to "JSON Enable" your objects.

A handy way to validate that the JSON is legal is to copy the string into this site http://json.parser.online.fr/

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

An `%ArrayOfDataTypes` is a simple Key/Value pair dictionary object used in Cache.  `CacheJSON` will parse this object into a JSON string with the same key/value pairs contained in this object.  Below is sample code to create this array and encode it to a JSON string.

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

### Encode a %ListOfDataTypes containing arrays

A `%ListOfDataTypes` is a simple array object used in Cache.  Insert a bunch of `%ArrayOfDataTypes` into the list, and `CacheJSON` will translate this into a JSON array.  Below is sample code using a list:

``` ruby
Set arr1 = ##class(%ArrayOfDataTypes).%New()
Do arr1.SetAt("Dan","FirstName")
Do arr1.SetAt("McCracken","LastName")
Do arr1.SetAt("01/01/1983","DOB")

Set arr2 = ##class(%ArrayOfDataTypes).%New()
Do arr2.SetAt("Ron","FirstName")
Do arr2.SetAt("Sweeney","LastName")
Do arr2.SetAt("12/31/1978","DOB")

Set list = ##class(%ListOfDataTypes).%New()
Set sc = list.Insert(arr1)
Set sc = list.Insert(arr2)
Set encodedList = ##class(CacheJSON).Encode(list)
````

Creates a string like so:

``` ruby
[{"DOB":"01/01/1983","FirstName":"Dan","LastName":"McCracken"},{"DOB":"12/31/1978","FirstName":"Ron","LastName":"Sweeney"}]
````

### Encode an array as an element value

Set the value of an item to another `%ArrayOfDataTypes`.  Example below:

``` ruby
Set message = ##class(%ArrayOfDataTypes).%New()
Do message.SetAt("Posting to Campfire from Cache!","body")
Set payload = ##class(%ArrayOfDataTypes).%New()
Do payload.SetAt(message,"message")
Set jsonPost = ##class(CacheJSON).Encode(payload)
````

Creates a string like so:

``` ruby
{"message":{"body":"Posting to Campfire from Cache!"}}
````

### Encode a %Persistent object

After you extend the persistent class with the `CacheJSON` class (see instructions above), you can call a method to simply project the object as a JSON string.  Example below:

``` ruby
Set obj = ##class(Sample.Person).%OpenId(1)
Set jsonString = obj.GetJSONFromObject()
````

Creates a string like so:

``` ruby
{"DOB":40434,"MyBool":null,"Name":"Bolt  Usain","SSN":"722-81-1666"}
````

### Decode a single JSON object

Given a JSON string representing a single object:

``` ruby
{"DOB":57311,"Name":"Dan McCracken","SSN":"192-20-3003"}
````

`CacheJSON` creates an `%ArrayOfDataTypes` object containing all the properties using the Decode() method.

``` ruby
Set myDecodedArray = ##class(CacheJSON).Decode(encodedString)
Do $System.OBJ.Dump(myDecodedArray)

+----------------- general information ---------------
|      oref value: 3
|      class name: %Library.ArrayOfDataTypes
| reference count: 1
+----------------- attribute values ------------------
|        Data("DOB") = 57311
|       Data("Name") = "Dan McCracken"
|        Data("SSN") = "192-20-3003"
|        ElementType = "%String"
````

### Decode an array of JSON objects

Given a JSON string representing an array of JSON objects:

``` ruby
[{"DOB":33997,"Name":"Koivu,Phyllis Z.","SSN":"676-82-4467"},{"DOB":61685,"Name":"Kelvin,Kristen S.","SSN":"546-95-9170"},{"DOB":53364,"Name":"DeLillo,Alexandra O.","SSN":"566-60-9488"}]
````

`CacheJSON` will decode this array into a `%ListOfDataTypes` with nodes containing `%ArrayOfDataTypes` that represent each decoded object individually.

``` ruby
Set myDecodedArray = ##class(User.Util.CacheJSON).Decode(arrString)
Do $System.OBJ.Dump(myDecodedArray)
+----------------- general information ---------------
|      oref value: 7
|      class name: %Library.ListOfDataTypes
| reference count: 1
+----------------- attribute values ------------------
|            Data(1) = "12@%Library.ArrayOfDataTypes"
|            Data(2) = "14@%Library.ArrayOfDataTypes"
|            Data(3) = "16@%Library.ArrayOfDataTypes"
|        ElementType = ""
|               Size = 3  <Set>

Do $System.OBJ.Dump(myDecodedArray.GetAt(1))
+----------------- general information ---------------
|      oref value: 12
|      class name: %Library.ArrayOfDataTypes
| reference count: 1
+----------------- attribute values ------------------
|        Data("DOB") = 33997
|       Data("Name") = "Koivu,Phyllis Z."
|        Data("SSN") = "676-82-4467"
|        ElementType = "%String"
````

### Decode a single JSON object into a custom Cache object

Given a JSON string with keys that map to a custom Cache object:

``` ruby
{"DOB":57311,"Name":"Dan McCracken","SSN":"192-20-3003"}
````

When `CacheJSON` is extended on the object you're trying to map the JSON string to, you can create a new object containing the JSON values as properties using the GetObjectFromJSON() method.

``` ruby
USER> Set newPerson = ##class(Sample.Person).GetObjectFromJSON(encodedJSON)
USER> Write newPerson.Name
Dan McCracken
````

### Convert a Cache object into an %ArrayOfDataTypes

This is a helper method that will translate your object into an `%ArrayOfDataTypes`, allowing you to quickly build up a `%ListOfDataTypes` to Encode() as a return value for your methods.  Using this method inside a quick loop generates a desired list:

``` ruby
Set list = ##class(%ListOfDataTypes).%New()
For x=1:1:3 {
	Set obj = ##class(Sample.Person).%OpenId(x)
	Set sc = list.Insert(obj.GetAsArrayOfDataTypes())
}
Set encodedList = ##class(Sample.Person).Encode(list)
````

This code generates an array of 3 JSON encoded Person objects that look like this:

``` ruby
[{"DOB":33997,"Name":"Koivu,Phyllis Z.","SSN":"676-82-4467","Spouse":null},{"DOB":61685,"Name":"Kelvin,Kristen S.","SSN":"546-95-9170","Spouse":null},{"DOB":53364,"Name":"DeLillo,Alexandra O.","SSN":"566-60-9488","Spouse":null}]
````

## Tests

There is a set of tests included in the repository that originated from [Yontan's Blog](http://blog.yonatan.me/2010/03/objectscript-json-decoderencoder.html) that is a standard Cache `%UnitTest.TestCase`.

To run the test, use a command like:

``` ruby
Do ##class(%UnitTest.Manager).RunTest("TestJSON:TestJSON","/noload/norecursive/nodelete")
````

## Contributing

If you find something that looks like a bug:

1. Check the [GitHub issue tracker](http://github.com/PlanetCache/CacheJSON/issues) to see if it's a known issue.
2. If you don't see anything, create an issue with information on how to reproduce it.

If you want to contribute an enhancement or a fix:

1. Fork the project on GitHub.
2. Make your changes and (optionally) update the test class.
3. Commit the changes to your forked repo.
4. Send a pull request.