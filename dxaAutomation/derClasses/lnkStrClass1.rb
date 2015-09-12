require '../testClasses/testClass1'

class LinkStruc < TestClass
  
  def initialize(requirements, selDriver, nokoPage, scoreCoeff, testNam, fileNam=:DEFINED, logFil=:DEFINED, urlName=:DEFINED, bizNam=:DEFINED, gPlusI=:DEFINED, allLink=:DEFINED, zipCod=:DEFINED)
    super(requirements, selDriver, nokoPage, scoreCoeff, testNam, fileNam, logFil, urlName, bizNam, gPlusI, allLink, zipCod)
  end

  def performTest
    webSEOLink = "http://www.webseoanalytics.com/members/seo-tools/link-structure.php"
    @driver.get webSEOLink

    input = @driver.find_element(:id, "url")
    input.send_keys(@@url)

    submitBtn = @driver.find_element(:id, "submitReport")
    @driver.action.click(submitBtn).perform
    foundRes = true

    wait = Selenium::WebDriver::Wait.new(:timeout => 30)

    begin
      wait.until {@driver.find_element(:class => "analysis_table_greenHead").displayed? }

    rescue
      logDebug("There was an error with loading #{webSEOLink}: test timed out, or input/submit elements could not be located.", __FILE__, __LINE__, __method__)
      foundRes = false
    end 

    if foundRes
      logDebug("Page: #{webSEOLink}, loaded successfully.", __FILE__, __LINE__, __method__)
      res = @driver.find_element(:class, "analysis_table_greenHead").text
      linkNum = 0

      res.split("\n").each do |line|
        
        linkNum = line if line.include? "VALID LINKS"
      end

      linkNum = linkNum.split(" ")[2].to_i
      logDebug("From reading results of page: #{webSEOLink}, #{linkNum} links were found.", __FILE__, __LINE__, __method__)
    
    else
      linkNum = 0
    end  

    @score = (linkNum >= 10? @coeffMod : 0) 
    writeScore
  end	

  def putLinks
    puts @@allLinks
  end	
end