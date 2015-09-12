require '../testClasses/testClass1'

class PageSpeedTest < TestClass
  
  def initialize(requirements, selDriver, nokoPage, scoreCoeff, testNam, fileNam=:DEFINED, logFil=:DEFINED, urlName=:DEFINED, bizNam=:DEFINED, gPlusI=:DEFINED, allLink=:DEFINED, zipCod=:DEFINED)
    super(requirements, selDriver, nokoPage, scoreCoeff, testNam, fileNam, logFil, urlName, bizNam, gPlusI, allLink, zipCod)

    #@testName = testNam
  end

  def performTest
    gPageSpdAPIKey = File.read("../keys/gPageSpdAPIKey.txt")
    system "curl -s \"https://www.googleapis.com/pagespeedonline/v1/runPagespeed?url=#{@@url}&key=#{gPageSpdAPIKey}\" > pageSpeedInfo.txt"

    speedInfo = File.open("pageSpeedInfo.txt", 'rb') { |file| file.read }
    speedInfo = JSON.parse(speedInfo)
    system 'rm -f pageSpeedInfo.txt'

    logDebug("A pagespeed score of #{speedInfo['score'].to_f} was retrieved from the Google Developers Console.", __FILE__, __LINE__, __method__)
    
    @score = @coeffMod * (speedInfo['score'].to_f / 100.0)

    writeScore
  end

  def putLinks
    puts @@allLinks
  end	
end