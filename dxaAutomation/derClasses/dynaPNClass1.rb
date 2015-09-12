require '../testClasses/testClass1'

class DynamicPhone < TestClass
  
  def initialize(requirements, selDriver, nokoPage, scoreCoeff, testNam, fileNam=:DEFINED, logFil=:DEFINED, urlName=:DEFINED, bizNam=:DEFINED, gPlusI=:DEFINED, allLink=:DEFINED, zipCod=:DEFINED)
    super(requirements, selDriver, nokoPage, scoreCoeff, testNam, fileNam, logFil, urlName, bizNam, gPlusI, allLink, zipCod)
  end

  def performTest(callTrack)
    @score = (callTrack ? @coeffMod : 0)
    logDebug("Based off of the flag handed to this test from the \"Call Tracking/Recording Test\", the site #{(callTrack ? "has" : "does not have")} Dynamic Phone Numbers.", __FILE__, __LINE__)
    writeScore
  end

  def putLinks
    puts @@allLinks
  end	
end