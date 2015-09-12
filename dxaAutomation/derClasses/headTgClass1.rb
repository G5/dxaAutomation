require '../testClasses/testClass1'

class HeadTagsTest < TestClass
  
  def initialize(requirements, selDriver, nokoPage, scoreCoeff, testNam, fileNam=:DEFINED, logFil=:DEFINED, urlName=:DEFINED, bizNam=:DEFINED, gPlusI=:DEFINED, allLink=:DEFINED, zipCod=:DEFINED)
    super(requirements, selDriver, nokoPage, scoreCoeff, testNam, fileNam, logFil, urlName, bizNam, gPlusI, allLink, zipCod)
  end

  def getHeader(headLabel)
    header = @page.xpath("//#{headLabel.to_s}")

    if (header == nil) or (header == @page.xpath("//some_non_existent_element"))
      logDebug("On home page: #{@@url}, there was no #{headLabel} found.", __FILE__, __LINE__, __method__)
      return :NOT_FOUND
    end
    
    header = (header.to_s.gsub(/<[\/]?h\d( \w+=\"(\w+\s*)+\")*>/, "SENTINEL").split("SENTINEL")) - [""]
    logDebug("On home page: #{@@url}, a #{headLabel} was found.", __FILE__, __LINE__, __method__)
    return header
  end

  def getKeywords

    metaTags = @page.xpath("//meta")
    
    if metaTags == nil
      logDebug("On home page: #{@@url}, no meta tags were found (therefore no keywords).", __FILE__, __LINE__, __method__)
      return :NO_META_TAGS
    end

    metaTags = metaTags.to_s.delete("<").split(">")
    keywords = nil

    metaTags.each do |metaTag|

      if metaTag.include? "keyword"
        keywords = metaTag
        break
      end
    end

    if keywords == nil
      logDebug("On home page: #{@@url}, no meta tags containing keywords were found (therefore no keywords).", __FILE__, __LINE__, __method__)
      return :NO_KEYWORDS
    end

    if keywords.index("content=") == nil
      return :NO_KEYWORDS
    end

    keywords = keywords[(keywords.index("content=\"") + 9)...keywords.rindex("\"")].split(", ")
    logDebug("On home page: #{@@url}, keywords were successfully found.", __FILE__, __LINE__, __method__)
    return keywords
  end 

  def scoreHeader(keywords, header)
    
    if (header == :NOT_FOUND)
      return 0.0
    end

    tmpHeader = header.to_s.delete(" ").downcase 

    unless (keywords == :NO_KEYWORDS) or (keywords == :NO_META_TAGS)

      keywords.each do |keyword|
        
        if tmpHeader.include? keyword.delete(" ").downcase
          logDebug("In header: #{header}, the keyword: #{keyword} was found. Test failed.", __FILE__, __LINE__, __method__)
          return 0.0
        end 
      end
    end

    if tmpHeader.include? @@bizName.delete(" ").downcase
      logDebug("In header: #{header}, the business name: \"#{@@bizName}\" was found. Test failed.", __FILE__, __LINE__, __method__)
      return 0.0
    end

    logDebug("In header: #{header}, there were no keywords or the business name. Test passed.", __FILE__, __LINE__, __method__)
    return 1.0
  end

  def performTest
    @testName = "Home Page Header Tag 1"
    initDebugFile
    coeffList = @coeffMod

    unless @page.encoding.to_s == 'utf-8'
      logDebug("The encoding for the home page: #{@@url} was \"#{@page.encoding.to_s}\", so it is being changed to \"utf-8\"", __FILE__, __LINE__, __method__)
      html = open(@@url)
      @page = Nokogiri::HTML(html.read)
      @page.encoding = 'utf-8'
    end

    keywords = getKeywords
    
    h1 = getHeader(:h1)
    @coeffMod = coeffList[0]
    @score = @coeffMod * scoreHeader(keywords, h1)
    writeScore

    @testName = "Home Page Header Tag 2"
    initDebugFile

    h2 = getHeader(:h2)
    @coeffMod = coeffList[1]
    @score = @coeffMod * scoreHeader(keywords, h2)
    writeScore
  end

  def putLinks
    puts @@allLinks
  end	
end