/// Original code from Yonatan http://blog.yonatan.me/2010/03/objectscript-json-decoderencoder.html
Class CacheJSON Extends %String
{

/*
		Original Code By: Yonatan
		Date: 03/14/2010
		Version: 1.0
		
		Modified by: Dan McCracken
		Date: 10/27/2011
		Version 1.1
		Description: Added method for encoding a simple cache object, containing simple datatypes.
					 Added method to return an object as an %ArrayOfDataTypes as a helper when creating a %ListOfDataTypes,
					 	containing an array of objects to be encoded.
					 Fixed a bug that allowed %String property types to be unescaped when they qualified for $ISVALIDNUM()
					 	Strings containing a period character need to be escaped with quotes.
					 Added classmethod to return an object loaded with the properties from an encoded JSON string.
			
	*/
Parameter EscapeChar As COSEXPRESSION = "$LB($LB(""\"",""\\""),$LB($C(13),""\n""),$LB($C(10),""\r""),$LB($C(9),""\t""),$LB("""""""",""\""""""),$LB($C(8),""\b""),$LB($C(12),""\f""))";

Parameter UnEscapeChar As COSEXPRESSION = "$LB(""\\"",""\n"",""\r"",""\t"",""\"""""",""\b"",""\f"")";

Parameter JSonSlice [ Final, Internal ] = 1;

Parameter JSonInString [ Final, Internal ] = 2;

Parameter JSonInArray [ Final, Internal ] = 3;

Parameter JSonInObject [ Final, Internal ] = 4;

ClassMethod GetEscapeChars() As %String
{
  Quit ..#EscapeChar
}

ClassMethod SetAux(what As %String, where As %Integer, delim As %String) As %DataType [ Internal ]
{
  s aux=##class(%ArrayOfDataTypes).%New() 
  d aux.SetAt(what,"what")
  d aux.SetAt(where,"where") 
  d aux.SetAt(delim,"delim")
 
  q aux
}

/// we know that it's not escaped becase there is _not_ an
/// odd number of backslashes at the end of the string so far
ClassMethod isEscaped(str As %String, c As %String) As %Boolean [ Internal ]
{
  s pos=$F(str,c)
  q ($L($E(str,1,pos))-$L($REPLACE($E(str,1,pos),"\","")))#2=1
}

/// Escapes the string. 
ClassMethod Escape(str As %String) As %String [ Internal ]
{
  for tI=1:1:$LL(..#EscapeChar) { 
    Set tCharPair=$LG(..#EscapeChar,tI)
    Set str=$Replace(str,$LG(tCharPair,1),$LG(tCharPair,2))
  }
  Quit str
}

ClassMethod Unescape(str As %String) As %String [ Internal ]
{
  For tI=1:1:$Length(str){
    Set tChar=$ListFind(..#UnEscapeChar,$E(str,tI,tI+1))
    if (tChar>0){
      Set $E(str,tI,tI+1)=$LG($LG(..#EscapeChar,tChar),1)
    }
  }
  Quit str
}

/// Decode a string JSON. 
ClassMethod Decode(str As %String) As %ArrayOfDataTypes
{
  #dim stack as %ListOfDataTypes
  s matchType=$ZCVT(str,"L")
 
  q:(matchType="true") "1"
  q:(matchType="false") "0"
  q:(matchType="null") ""  
  q:($ISVALIDNUM(matchType)) matchType 
  q:str?1"""".E1"""" ..Unescape($e(str,2,$l(str)-1))
  //$replace($e(str,2,$l(str)-1),"\""","""")
 
  // array or object notation
  s match=str?1(1"[".E1"]",1"{".E1"}")
  s stack=##class(%ListOfDataTypes).%New()
 
  if match {
    if $E(str,1)="[" {
      d stack.Insert(..#JSonInArray)
      s arr=##class(%ListOfDataTypes).%New()
    }  
    else {
      d stack.Insert(..#JSonInObject) 
      s obj=##class(%ArrayOfDataTypes).%New()
    }
   
    d stack.Insert(..SetAux(..#JSonSlice,1,"false"))
   
    s chars=$E(str,2,$L(str)-1)
   
    if chars="" {
      if stack.GetAt(1)=..#JSonInArray {
        q arr
      }
      else {
        q obj
      }  
    }

    s strlenChars=$L(chars)+1

    s escaped=0
    For c=1:1:strlenChars {
      s last=stack.Count()
      s top=stack.GetAt(last)
     
      s:(escaped=2) escaped=0
      s:(escaped=1) escaped=2
     
      s substrC2=$E(chars,c-1,c)
      if ($E(chars,c,c)="\")&&(escaped=0) s escaped=1
      
      if $e(chars,c)="" {
        s a=22
      }
     
      if (c=strlenChars || ($E(chars,c)=",")) && (top.GetAt("what")=..#JSonSlice) {
        // found a comma that is not inside a string, array, etc.,
        // OR we've reached the end of the character list
        s slice = $E(chars, top.GetAt("where"),c-1)
        d stack.Insert(..SetAux(..#JSonSlice,c+1,"false"))
        if stack.GetAt(1)=..#JSonInArray {
          // we are in an array, so just push an element onto the stack
          d arr.Insert(..Decode(slice)) 
        }
        elseif stack.GetAt(1)=..#JSonInObject {
          // we are in an object, so figure
          // out the property name and set an
          // element in an associative array,
          // for now 
                   
          s match=slice?." "1""""1.E1""""." "1":"1.E
          if match {
            //'name':value par
            s key1=$p(slice,":")
            s key=..Decode(key1)

            s val=..Decode($P(slice,":",2,$l(slice,":"))) 
            d obj.SetAt(val, key)
                    
          }
        }
      }
      elseif $E(chars,c)="""" && (top.GetAt("what")'=..#JSonInString) {
        // found a quote, and we are not inside a string
        d stack.Insert(..SetAux(..#JSonInString,c,$E(chars,c)))
      }
      elseif $E(chars,c)=top.GetAt("delim") && (top.GetAt("what")=..#JSonInString) && (escaped=0) {
        // found a quote, we're in a string, and it's not escaped (look 3 charachters behind, to see the \" is not \\" )
        s last=stack.Count()
        s st=stack.RemoveAt(last)
      }
      elseif ($E(chars,c)="[") && (top.GetAt("what")'=..#JSonInString) && ($CASE(top.GetAt("what"),..#JSonInString:1,..#JSonInArray:1,..#JSonSlice:1,:0)) { 
        // found a left-bracket, and we are in an array, object, or slice
        d stack.Insert(..SetAux(..#JSonInArray,c,"false"))
      }
      elseif $E(chars,c)="]" && (top.GetAt("what")=..#JSonInArray) {
        // found a right-bracket, and we're in an array
        s last=stack.Count()
        s st=stack.RemoveAt(last) 
      }
      ;modificacio 19/11/08: ..#JSonString -> #JSonInArray
      elseif $E(chars,c)="{" && ($CASE(top.GetAt("what"),..#JSonSlice:1,..#JSonInArray:1,..#JSonInObject:1,:0)) {
        // found a left-brace, and we are in an array, object, or slice
        d stack.Insert(..SetAux(..#JSonInObject,c,"false"))
      }
      elseif $E(chars,c)="}" && (top.GetAt("what")=..#JSonInObject) {
        // found a right-brace, and we're in an object 
        s last=stack.Count()
        s st=stack.RemoveAt(last) 
      }
     
    }  
   
    if stack.GetAt(1)=..#JSonInObject {
      q obj
    }
    elseif stack.GetAt(1)=..#JSonInArray {
      q arr
    }
  }
  q str
}

/// Encode a Cache string to a JSON string
ClassMethod Encode(data As %DataType) As %String
{

  if $IsObject(data) {  
    s key=""
   
    s typeData=data.%ClassName()

    if typeData="%ArrayOfDataTypes" {
      //type object
      s key=""
      s cad=""
      F {
        s pData=data.GetNext(.key)
        q:key=""
        s value=..Encode(pData)
        s cad=$S(cad'="":cad_",",1:"")_""""_..Escape(key)_""":"_value  
      } 
      q "{"_cad_"}"
    }
    elseif typeData="%ListOfDataTypes" {
      //type array 
     
      s cad=""
      f i=1:1:data.Count() {
        s tmp=..Encode(data.GetAt(i))
        s cad=$S(i>1:cad_",",1:"")_tmp
      }
     
      s cad="["_cad_"]"
      q cad
    }
  }
  elseif ($FIND(data,".")) {
	;; This $ISVALIDNUM below is causing some %String property types that are valid numbers (ie. .1293394) to be unescaped
  	;; $ISVALIDNUM allows for periods. Need to check for a . in another elseif and escape it like a string "".

	//type string
    q:data="" "null"
    q """"_..Escape(data)_""""
  }
  elseif $ISVALIDNUM(data) {
    // type number
    q data
    
  }
  else {
    //type string
    q:data="" "null"
    q """"_..Escape(data)_""""
  }
}

ClassMethod CreateStringPair(pKey As %String, pValue As %String) As %String
{
  Quit """"_pKey_""":"""_..Escape(pValue)_""""
}

ClassMethod Parse(pStr As CacheJSON) As %ArrayOfDataTypes
{
  Quit ##class(CacheJSON).Decode(pStr)
}

ClassMethod Stringify(pData As %DataType) As CacheJSON
{
  Quit ##class(CacheJSON).Encode(pData)
}

/// Return an encoded JSON string of the object.<br>
/// Uses all object properties that do not start with a % char.
Method GetJSONFromObject() As %String [ CodeMode = objectgenerator ]
{
	// Only create this method when compiling other classes this is extended upon
	If (%compiledclass.Name '= "Spectrum.Util.CacheJSON") {
		
		// Wrap the object in an array
		Do %code.WriteLine(" Set array = ##class(%ArrayOfDataTypes).%New()")
	
		// Rip through each property of the class.. that does not start with a %
		// Insert each property as a key=>value pair in the array
		For i = 1:1:%compiledclass.Properties.Count() {
	        Set prop = %compiledclass.Properties.GetAt(i).Name
	        IF ($EXTRACT(prop) '= "%") {
		        Do %code.WriteLine(" Do array.SetAt(.."_prop_","""_prop_""")")
	        }
	    }
    
	    // Return an encoded JSON string of the object
	    Do %code.WriteLine(" Quit ..Encode(array)")
	}
}

/// Returns the object as an %ArrayOfDataTypes key=>value pair set.
/// This is helpful when trying to return a %ListOfDataTypes in JSON form, by quickly building an array object to Insert.
/// Uses all object properties that do not start with a % char.
Method GetAsArrayOfDataTypes() As %ArrayOfDataTypes [ CodeMode = objectgenerator ]
{
	// Only create this method when compiling other classes this is extended upon
	If (%compiledclass.Name '= "Spectrum.Util.CacheJSON") {
		
		// Wrap the object in an array
		Do %code.WriteLine(" Set array = ##class(%ArrayOfDataTypes).%New()")
	
		// Rip through each property of the class.. that does not start with a %
		// Insert each property as a key=>value pair in the array
		For i = 1:1:%compiledclass.Properties.Count() {
	        Set prop = %compiledclass.Properties.GetAt(i).Name
	        IF ($EXTRACT(prop) '= "%") {
		        Do %code.WriteLine(" Do array.SetAt(.."_prop_","""_prop_""")")
	        }
	    }
    
	    // Return an %ArrayOfDataTypes representation of the object
	    Do %code.WriteLine(" Quit array")
	}
}

/// Returns an OREF populated with the values from the JSON
/// Uses all object properties that do not start with a % char.
ClassMethod GetObjectFromJSON(JSON As %String) As %RegisteredObject [ CodeMode = objectgenerator ]
{
	// Only create this method when compiling other classes this is extended upon
	If (%compiledclass.Name '= "Spectrum.Util.CacheJSON") {
		Do %code.WriteLine(" Set return = ##class("_%compiledclass.Name_").%New()")
	
		Do %code.WriteLine(" Set myDecodedArray = ..Decode(JSON)")
		
		// Rip through each property of the class.. that does not start with a %
		// Insert each property into the object to return
		For i = 1:1:%compiledclass.Properties.Count() {
	        Set prop = %compiledclass.Properties.GetAt(i).Name
	        IF ($EXTRACT(prop) '= "%") {
		        //Do %code.WriteLine(" Do array.SetAt(.."_prop_","""_prop_""")")
		        Do %code.WriteLine(" Set return."_prop_" = myDecodedArray.GetAt("""_prop_""")")
	        }
	    }
	    
		Do %code.WriteLine(" Quit return")
	}
}

}
