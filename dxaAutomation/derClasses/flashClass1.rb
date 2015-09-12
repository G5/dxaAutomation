require '../testClasses/testClass1'

class FlashTest < TestClass
  
  def initialize(requirements, selDriver, nokoPage, scoreCoeff, testNam, fileNam=:DEFINED, logFil=:DEFINED, urlName=:DEFINED, bizNam=:DEFINED, gPlusI=:DEFINED, allLink=:DEFINED, zipCod=:DEFINED)
    super(requirements, selDriver, nokoPage, scoreCoeff, testNam, fileNam, logFil, urlName, bizNam, gPlusI, allLink, zipCod)
  end

  def performTest
    
    @@allLinks.each do |link|
      @driver.get link
      sleep(2)
      
      if @driver.page_source.include? ".swf"
        logDebug("On the page: #{link}, flash was detected (so test was failed). Exiting test.", __FILE__, __LINE__, __method__)
        @score = 0
        writeScore
        return true
      end
    end

    logDebug("No flash was detected on any page (so test was passed). Exiting test.", __FILE__, __LINE__, __method__)
    @score = @coeffMod
    writeScore
    return false
  end

  def putLinks
    puts @@allLinks
  end	
end