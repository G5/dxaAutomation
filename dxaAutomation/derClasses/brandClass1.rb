require '../testClasses/testClass1'

class BrandSearch < TestClass

  def initialize(requirements, selDriver, nokoPage, scoreCoeff, testNam, fileNam=:DEFINED, logFil=:DEFINED, urlName=:DEFINED, bizNam=:DEFINED, gPlusI=:DEFINED, allLink=:DEFINED, zipCod=:DEFINED)
    super(requirements, selDriver, nokoPage, scoreCoeff, testNam, fileNam, logFil, urlName, bizNam, gPlusI, allLink, zipCod)
  end

  def performTest
    @driver.get "http://www.google.com/?gws_rd=ssl"

    input = @driver.find_element(:id, "lst-ib") 
    input.send_keys(@@bizName) 
    input.submit
    sleep(2)

    firstRes = @driver.find_element(:class, "r").find_element(:tag_name, "a")
    
    if firstRes.attribute("href").to_s.include? @@url
      @score = @coeffMod
      logDebug("First result url text on Google SERP contained testClass business url \"@@url\". Test passed.", __FILE__, __LINE__, __method__)

    else
      @score = 0
      logDebug("First result url text did not contain testClass business url \"@@url\". Test failed.", __FILE__, __LINE__, __method__)
    end

    #puts @score, @coeffMod
    writeScore
  end	

  def putLinks
    puts @@allLinks
  end	
end

#RG, Selenium