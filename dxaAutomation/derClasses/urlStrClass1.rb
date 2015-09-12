require '../testClasses/testClass1'

class URLStruc < TestClass
  
  def initialize(requirements, selDriver, nokoPage, scoreCoeff, testNam, fileNam=:DEFINED, logFil=:DEFINED, urlName=:DEFINED, bizNam=:DEFINED, gPlusI=:DEFINED, allLink=:DEFINED, zipCod=:DEFINED)
    super(requirements, selDriver, nokoPage, scoreCoeff, testNam, fileNam, logFil, urlName, bizNam, gPlusI, allLink, zipCod)

    #@testName = testNam
  end

  def performTest
    
    @@allLinks.each do |link|
      lenScore = 100.0

      lenScore = 100.0 - (5 * (link.length - 30)) if link.length > 30

      lenScore = 0.0 if lenScore < 0.0
      lenScore = lenScore / 100.0

      logDebug("\"#{link}\" has a length of #{link.length}. Its length is #{(link.length > 30 ? "too long" : "okay")}.", __FILE__, __LINE__, __method__)

      charScore = 100.0
      badChars = ['&', '=', '?']

      badChars.each do |badChar|
        charScore = charScore - (10 * link.count(badChar))
        logDebug("There were #{link.count(badChar)} \"#{badChar}\"'s in your link.", __FILE__, __LINE__, __method__)
      end

      charScore = 0.0 if charScore < 0.0
      charScore = charScore / 100.0

      keyWScore = 0

      pageSrc = pageSrc = Nokogiri::HTML(open(link))

      unless pageSrc.encoding.to_s == 'utf-8'
        logDebug("The encoding for the page: #{link} was \"#{link.encoding.to_s}\", so it is being changed to \"utf-8\".", __FILE__, __LINE__, __method__)
        html = open(pageSrc)
        pageSrc = Nokogiri::HTML(html.read)
        pageSrc = 'utf-8'
      end

      metaTags = pageSrc.xpath("//meta").to_s.delete("<").split(">")
      keyWords = nil

      metaTags.each do |tag|
        tagStr = tag.to_s

        if tag.to_s =~ /(name=\"keywords\" content=\"([\w|\s|-],?)+\")$/
          keyWords = (tagStr[tagStr.index("content=")..-1])
          keyWords = keyWords[(keyWords.index("\"") + 1)...keyWords.rindex("\"")].split(/,\s*/)
        end
      end

      keyWScore = 100.0
      tmpURL = link.downcase

      unless keyWords == nil
        keyWScore = 0

        keyWords.each do |kWord|
          keyWScore = keyWScore + 1 if tmpURL.include? kWord.downcase
        end

        logDebug("There were #{keyWScore} keywords found in link: #{link}", __FILE__, __LINE__, __method__)

        keyWScore = 100.0 * (1.0 - (keyWScore.to_f / keyWords.length.to_f))
      end

      keyWScore = keyWScore / 100.0

      tmpScore = (0.34 * lenScore) + (0.33 * charScore) + (0.33 * keyWScore)
      appendScore(tmpScore)
      #puts "lenScore: #{lenScore}, charScore: #{charScore}, keyWScore: #{keyWScore}"
      #puts "link: #{link}-->score: #{tmpScore}"
    end

    @score = @coeffMod * getAverage

    #puts @score, @coeffMod
    @@allLinks.delete(@@url)
    writeScore
  end	

  def putLinks
    puts @@allLinks
  end	
end

# Nokogiri, s