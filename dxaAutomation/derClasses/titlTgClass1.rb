require '../testClasses/testClass1'

class TitleTTest < TestClass
  
  def initialize(requirements, selDriver, nokoPage, scoreCoeff, testNam, fileNam=:DEFINED, logFil=:DEFINED, urlName=:DEFINED, bizNam=:DEFINED, gPlusI=:DEFINED, allLink=:DEFINED, zipCod=:DEFINED)
    super(requirements, selDriver, nokoPage, scoreCoeff, testNam, fileNam, logFil, urlName, bizNam, gPlusI, allLink, zipCod)

    #@testName = testNam
  end

  def performTest

    @@allLinks.each do |link|

      pageSrc = Nokogiri::HTML(open(link))

      unless pageSrc.encoding.to_s == 'utf-8'
        logDebug("The encoding for the page: #{link} was \"#{link.encoding.to_s}\", so it is being changed to \"utf-8\".", __FILE__, __LINE__, __method__)
        html = open(link)
        link = Nokogiri::HTML(html.read)
        link.encoding = 'utf-8'
      end

      keyWords = nil

      metaTags = pageSrc.xpath("//meta").to_s.delete("<").split(">")

      metaTags.each do |metaTag|

        keyWords = metaTag; break if metaTag.include? "keyword"
      end

      if keyWords == nil
        logDebug("On page: #{link}, no keywords found.", __FILE__, __LINE__, __method__)
      end

      title = pageSrc.xpath("//title").to_s.gsub(/(<[\/]?title>)/, '')
      pass = true

      if title.delete("\n").gsub(/^(\s*\n?)$/, '') == ""
        logDebug("On page: #{link}, title field is empty (test failed).", __FILE__, __LINE__, __method__)
        pass = false
      end 

      tmpTitle = title.downcase.tr(' -', '')

      if pass and (tmpTitle.include? @@bizName.delete(" ").downcase)
        logDebug("On page: #{link}, there was a business name found in the title (test failed).", __FILE__, __LINE__, __method__)
        pass = false
      end

      unless (!pass) or ((keyWords == "") or (keyWords == nil))
        keyWords = keyWords[(keyWords.index("content=") + 9)..-2].tr('!?.-', '').split(", ")

        keyWords.each do |kWord|
          
          if tmpTitle.include? kWord.delete(" ").downcase
            logDebug("On page: #{link}, the keyword: \"kWord\" was found in your title: \"#{title}\".", __FILE__, __LINE__, __method__)
            pass = false
            break
          end
        end 
      end
    
      if pass
        logDebug("On page: #{link}, the title: \"#{title}\" had no keywords or business names in them (test passed).", __FILE__, __LINE__, __method__)
      end
      #puts "link: #{link}, pass? #{pass}"
      appendScore((pass ? 1.0 : 0.0))
    end

    logDebug("An average of #{getAverage} pages has acceptable title tags.", __FILE__, __LINE__, __method__)
    @score = @coeffMod * getAverage
    #puts @score, @coeffMod
    writeScore
  end	

  def putLinks
    puts @@allLinks
  end	
end
