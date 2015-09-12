require '../testClasses/testClass1'

class MobDesTest < TestClass
  
  def initialize(requirements, selDriver, nokoPage, scoreCoeff, testNam, fileNam=:DEFINED, logFil=:DEFINED, urlName=:DEFINED, bizNam=:DEFINED, gPlusI=:DEFINED, allLink=:DEFINED, zipCod=:DEFINED)
    super(requirements, selDriver, nokoPage, scoreCoeff, testNam, fileNam, logFil, urlName, bizNam, gPlusI, allLink, zipCod)

    #@testName = testNam
  end

  def performTest
    @driver.get "https://www.google.com/webmasters/tools/mobile-friendly/?url=#{@@url}"
    @score = 0
    
    begin
      wait = Selenium::WebDriver::Wait.new(:timeout => 15)
      wait.until { @driver.find_element(:class => "result-container").displayed? }

    rescue
      logDebug("Could not load page: #{"https://www.google.com/webmasters/tools/mobile-friendly/?url=" + @@url}, or grab page results.", __FILE__, __LINE__, __method__)
      @score = 0
      writeScore
      return
    end

    logDebug("Successfully loaded page: #{"https://www.google.com/webmasters/tools/mobile-friendly/?url=" + @@url}", __FILE__, __LINE__, __method__)

    unless @driver.find_element(:class, "result-container").text.include? "not mobile-friendly"
      @score = @coeffMod
    end

    #puts @score, @coeffMod
    writeScore
  end	

  def putLinks
    puts @@allLinks
  end	
end