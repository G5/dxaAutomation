require '../testClasses/testClass1'

class HeadUnique < TestClass

  def initialize(requirements, selDriver, nokoPage, scoreCoeff, testNam, fileNam=:DEFINED, logFil=:DEFINED, urlName=:DEFINED, bizNam=:DEFINED, gPlusI=:DEFINED, allLink=:DEFINED, zipCod=:DEFINED)
    super(requirements, selDriver, nokoPage, scoreCoeff, testNam, fileNam, logFil, urlName, bizNam, gPlusI, allLink, zipCod)

    #@testName = testNam
  end

  def findDups(pageSrc)
    headerNum = 1
    headers = pageSrc.xpath("//h#{headerNum}").to_s.delete("\"").split("</h#{headerNum}>")
    headerHash = Hash.new
      
    while headers.length != 0

      for i in 0...headers.length

        headers[i] = headers[i].gsub(/(\<h\d.*\>)/, "")

        if headerHash[headers[i]] == :EXISTS
          logDebug("On page #{@link}, there was a duplicate header: \"#{headerHash.keys[0]}\" (test failed).", __FILE__, __LINE__, __method__)
          return true
        end

        headerHash[headers[i]] = :EXISTS 
      end

      headerNum = headerNum + 1
      headers = pageSrc.xpath("//h#{headerNum}").to_s.delete("\"").split("</h#{headerNum}>")
    end

    if headerHash.length == 0
      logDebug("On page #{@link}, there were no headers (test failed).", __FILE__, __LINE__, __method__)
      return true
    end

    logDebug("On page #{@link}, there were no duplicate headers (test passed).", __FILE__, __LINE__, __method__)
    return false
  end 

  def performTest

    @@allLinks.each do |link|
      @link = link

      pageSrc = pageSrc = Nokogiri::HTML(open(link))

      unless pageSrc.encoding.to_s == 'utf-8'
        logDebug("The encoding for the home page: #{link} was \"#{@page.encoding.to_s}\", so it is being changed to \"utf-8\".", __FILE__, __LINE__, __method__)
        html = open(@@url)
        pageSrc = Nokogiri::HTML(html.read)
        pageSrc.encoding = 'utf-8'
      end

      pageSrc = Nokogiri::HTML(open(link))
      appendScore(findDups(pageSrc) == false ? 1.0 : 0.0)
    end

    @score = @coeffMod * getAverage

    #puts @score, @coeffMod
    writeScore
  end	

  def putLinks
    puts @@allLinks
  end	
end

#RG, Nokogiri, Open-URI