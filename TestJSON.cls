Class JSON.TestJSON Extends %UnitTest.TestCase
{

Method TestJSON()
{
  #Dim tException As %Exception.AbstractException
  Try {    
    Set tEscapeChars=##class(RSA.Data.DT.Simple.JSON).GetEscapeChars()
    Set tEscapeChars=tEscapeChars_$LB($LB("[","["),$LB("]","]"),$LB("{","{"),$LB("}","}"),$LB(":",":"))
    for tI=1:1:$LL(tEscapeChars){
      For tJ=1:1:$LL(tEscapeChars){
        for tK=1:1:$LL(tEscapeChars){
         
        Set tChar1=$LG(tEscapeChars,tI)
        Set tChar2=$LG(tEscapeChars,tJ)
        Set tChar3=$LG(tEscapeChars,tK)
       
        Set tJSON="{""name"":"""_$LG(tChar1,2)_$LG(tChar2,2)_$LG(tChar3,2)_" is char""}"
        Set tObj=##class(RSA.Data.DT.Simple.JSON).Parse(tJSON)
        Set tName=tObj.GetAt("name")
        Do $$$AssertEquals(tName,$LG(tChar1,1)_$LG(tChar2,1)_$LG(tChar3,1)_" is char","Escaping for "_$LG(tChar1,2)_$LG(tChar2,2)_$LG(tChar3,2))
       
        Set tJSON="{""name"":""the "_$LG(tChar1,2)_$LG(tChar2,2)_$LG(tChar3,2)_" is char""}"
        Set tObj=##class(RSA.Data.DT.Simple.JSON).Parse(tJSON)
        Set tName=tObj.GetAt("name")
        Do $$$AssertEquals(tName,"the "_$LG(tChar1,1)_$LG(tChar2,1)_$LG(tChar3,1)_" is char","Escaping middle for "_$LG(tChar1,2)_$LG(tChar2,2)_$LG(tChar3,2))
       
        Set tJSON="{""name"":""the "_$LG(tChar1,2)_$LG(tChar2,2)_$LG(tChar3,2)_"""}"
        Set tObj=##class(RSA.Data.DT.Simple.JSON).Parse(tJSON)
        Set tName=tObj.GetAt("name")
        Do $$$AssertEquals(tName,"the "_$LG(tChar1,1)_$LG(tChar2,1)_$LG(tChar3,1),"Escaping end for "_$LG(tChar1,2)_$LG(tChar2,2)_$LG(tChar3,2))
       
       
        if (tK=1){
          if (tI=1){
            Set tJSON="{""name"":"""_$LG(tChar1,2)_" is char""}"
            Set tObj=##class(RSA.Data.DT.Simple.JSON).Parse(tJSON)
            Set tName=tObj.GetAt("name")
            Do $$$AssertEquals(tName,$LG(tChar1,1)_" is char","Escaping for "_$LG(tChar1,2))
     
            Set tJSON="{""name"":""the "_$LG(tChar1,2)_" is char""}"
            Set tObj=##class(RSA.Data.DT.Simple.JSON).Parse(tJSON)
            Set tName=tObj.GetAt("name")
            Do $$$AssertEquals(tName,"the "_$LG(tChar1,1)_" is char","Escaping middle for "_$LG(tChar1,2))
     
            Set tJSON="{""name"":""the "_$LG(tChar1,2)_"""}"
            Set tObj=##class(RSA.Data.DT.Simple.JSON).Parse(tJSON)
            Set tName=tObj.GetAt("name")
            Do $$$AssertEquals(tName,"the "_$LG(tChar1,1),"Escaping end for "_$LG(tChar1,2))
           
            for tC=97:1:122{
              Set tJSON="{""name"":"""_$LG(tChar1,2)_$C(tC)_"""}"
              Set tObj=##class(RSA.Data.DT.Simple.JSON).Parse(tJSON)
              Set tName=tObj.GetAt("name")
              Do $$$AssertEquals(tName,$LG(tChar1,1)_$C(tC),"Escaping for "_$LG(tChar1,2)_$C(tC))
            }
          }
       
          Set tJSON="{""name"":"""_$LG(tChar1,2)_$LG(tChar2,2)_" is char""}"
          Set tObj=##class(RSA.Data.DT.Simple.JSON).Parse(tJSON)
          Set tName=tObj.GetAt("name")
          Do $$$AssertEquals(tName,$LG(tChar1,1)_$LG(tChar2,1)_" is char","Escaping for "_$LG(tChar1,2)_$LG(tChar2,2))
       
          Set tJSON="{""name"":""the "_$LG(tChar1,2)_$LG(tChar2,2)_" is char""}"
          Set tObj=##class(RSA.Data.DT.Simple.JSON).Parse(tJSON)
          Set tName=tObj.GetAt("name")
          Do $$$AssertEquals(tName,"the "_$LG(tChar1,1)_$LG(tChar2,1)_" is char","Escaping middle for "_$LG(tChar1,2)_$LG(tChar2,2))
       
          Set tJSON="{""name"":""the "_$LG(tChar1,2)_$LG(tChar2,2)_"""}"
          Set tObj=##class(RSA.Data.DT.Simple.JSON).Parse(tJSON)
          Set tName=tObj.GetAt("name")
          Do $$$AssertEquals(tName,"the "_$LG(tChar1,1)_$LG(tChar2,1),"Escaping end for "_$LG(tChar1,2)_$LG(tChar2,2))
          }
        }
      }
    }
  } catch tException {
    Do $$$AssertEquals(1,0,"Exception thrown - " _ tException.Code_ ": " _ tException.Name _ " " _ tException.Data _ " " _ tException.Location)
  }
}
Method TestLeadingZerosValuesAreEscaped()
{
	Set input = "000123"
	set output = ##class(App.API.Helper.CacheJSON).Encode(input)
	set expected = """"_input_""""
	Do $$$AssertEquals(output, expected, "Checking that a number with leading zeros is escaped")
}

Method TestZeroValueIsNotEscaped()
{
	Set input = "0"
	set output = ##class(App.API.Helper.CacheJSON).Encode(input)
	set expected = input
	Do $$$AssertEquals(output, expected, "Checking that a zero value is not escaped")
}

Method TestZeroFollowedByDecimalIsNotQuoted()
{
	Set input = "0.1"
	set output = ##class(App.API.Helper.CacheJSON).Encode(input)
	set expected = """"_input_""""
	Do $$$AssertEquals(output, expected, "Checking that a zero value followed by a decimal is not escaped")
}

Method TestMultipleZerosFollowedByDecimalIsQuoted()
{
	Set input = "00.1"
	set output = ##class(App.API.Helper.CacheJSON).Encode(input)
	set expected = """"_input_""""
	Do $$$AssertEquals(output, expected, "Checking that a zero value followed by a decimal is not escaped")
}
}