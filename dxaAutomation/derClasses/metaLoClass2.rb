require '../testClasses/testClass1'

class MetaLoSearch < TestClass
  
  def initialize(requirements, selDriver, nokoPage, scoreCoeff, testNam, fileNam=:DEFINED, logFil=:DEFINED, urlName=:DEFINED, bizNam=:DEFINED, gPlusI=:DEFINED, allLink=:DEFINED, zipCod=:DEFINED)
    super(requirements, selDriver, nokoPage, scoreCoeff, testNam, fileNam, logFil, urlName, bizNam, gPlusI, allLink, zipCod)

    #@testName = testNam
  end

  def performTest
    initDebugFile
    @driver.get @@url
    sleep(2)

    if @driver.page_source.delete(" ") =~ /(itemtype=\"https?:\/\/(www\.)?schema\.org\/?(\w+\/?)*\")/
      @score = @coeffMod
      logDebug("Meta location was found in the source code of the home page: #{@@url}", __FILE__, __LINE__, __method__)

    else
      @score = 0
      logDebug("No meta location was found in the source code of the home page: #{@@url}", __FILE__, __LINE__, __method__)
    end

    writeScore
  end	

  def putLinks
    puts @@allLinks
  end	
end
