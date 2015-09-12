require '../testClasses/testClass1'

class RedirTest < TestClass
  
  def initialize(requirements, selDriver, nokoPage, scoreCoeff, testNam, fileNam=:DEFINED, logFil=:DEFINED, urlName=:DEFINED, bizNam=:DEFINED, gPlusI=:DEFINED, allLink=:DEFINED, zipCod=:DEFINED)
    super(requirements, selDriver, nokoPage, scoreCoeff, testNam, fileNam, logFil, urlName, bizNam, gPlusI, allLink, zipCod)
  end

  def performTest
    @driver.get @@url
    sleep(2)
    @score = 0

    unless @driver.current_url.downcase.include? @@url.gsub(/(http[s]?:\/\/(www\.)?)/, '').gsub(/(\/.*)/, '').downcase
      @score = @coeffMod
    end

    logDebug("The home page #{(@score == @coeffMod ? "has" : "does not have")} a 301 redirect.", __FILE__, __LINE__, __method__)
    writeScore
  end	

  def putLinks
    puts @@allLinks
  end	
end