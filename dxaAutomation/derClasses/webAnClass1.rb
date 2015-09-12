require '../testClasses/testClass1'

class WebAnalytics < TestClass
  
  def initialize(requirements, selDriver, nokoPage, scoreCoeff, testNam, fileNam=:DEFINED, logFil=:DEFINED, urlName=:DEFINED, bizNam=:DEFINED, gPlusI=:DEFINED, allLink=:DEFINED, zipCod=:DEFINED)
    super(requirements, selDriver, nokoPage, scoreCoeff, testNam, fileNam, logFil, urlName, bizNam, gPlusI, allLink, zipCod)

    #@testName = testNam
  end

  def performTest

    unless @page.encoding.to_s == 'utf-8'
      html = open(@@url)
      @page = Nokogiri::HTML(html.read)
      @page.encoding = 'utf-8'
    end

    @page.xpath("//script").each do |script|
      #puts script.to_s, "***************************************************"
      
      if script.to_s =~ /(ga\S*\(.*\'UA-\d{4,10}-\d{1,2}\'.*\)\;)/
        logDebug("On page: #{@@url} a Google Analytics script was found (test passed).", __FILE__, __LINE__)
        @score = @coeffMod
        writeScore
        #puts "PASS"
        return
      end
    end

    #puts "FAIL"
    logDebug("On page: #{@@url} no Google Analytics script was found (test failed).", __FILE__, __LINE__)
    @score = 0
    writeScore
  end

  def putLinks
    puts @@allLinks
  end	
end