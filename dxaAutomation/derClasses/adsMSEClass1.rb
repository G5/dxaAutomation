require '../testClasses/testClass1'

class AdsOnMSE < TestClass
  
  def initialize(requirements, selDriver, nokoPage, scoreCoeff, testNam, fileNam=:DEFINED, logFil=:DEFINED, urlName=:DEFINED, bizNam=:DEFINED, gPlusI=:DEFINED, allLink=:DEFINED, zipCod=:DEFINED)
    super(requirements, selDriver, nokoPage, scoreCoeff, testNam, fileNam, logFil, urlName, bizNam, gPlusI, allLink, zipCod)
  end

  def performTest(adFlag)
    adsense = false

    logDebug("The adsense flag was: #{adFlag}. Test #{(adFlag ? "passed" : "failed")}.", __FILE__, __LINE__, __method__)

    @score = @coeffMod * (adFlag ? 1 : 0)
    writeScore
  end

  def putLinks
    puts @@allLinks
  end	
end