require '../testClasses/testClass1'

class ContReadTest < TestClass
  
  def initialize(requirements, selDriver, nokoPage, scoreCoeff, testNam, fileNam=:DEFINED, logFil=:DEFINED, urlName=:DEFINED, bizNam=:DEFINED, gPlusI=:DEFINED, allLink=:DEFINED, zipCod=:DEFINED)
    super(requirements, selDriver, nokoPage, scoreCoeff, testNam, fileNam, logFil, urlName, bizNam, gPlusI, allLink, zipCod)
  end

  def getScore(bulkText)
    @driver.get "https://readability-score.com/"

    textTab = @driver.find_element(:id, "ui-id-1")
    textTab.click
    sleep(1)

    textArea = @driver.find_element(:id, "text_to_score")
    textArea.click
    textArea.send_keys(bulkText)
    sleep(10)

    res = @driver.find_element(:id, "flesch_kincaid_reading_ease").text
    
    unless res =~ /^(\s*\d+\.\d+\s*)$/

      raise ArgumentError, ''
      logDebug("The formatting of the result was incompatible with \".to_f\" casts.", __FILE__, __LINE__, __method__)
    end

    return res.to_f
  end

  def scoreAllText
    bulkText = ""
    accPunct = ['.', '!', '?']
    
    @@allLinks.each do |link|      
      @driver.get link

      begin

        @driver.find_elements(:xpath, "//*").each do |elem|
          elemText = elem.text
        
          unless elemText =~ /\w/
            next
          end

          elemText = elemText.gsub("\n", ' ').gsub(/\s+/, ' ')
          bulkText << elemText

          unless accPunct.include? elemText[-1]
            bulkText << '.'
          end

          bulkText << ' '

          if bulkText.count(" ") > 500
            logDebug("More than 500 words were collected, so readability test is being performed on the first 500 words grabbed.", __FILE__, __LINE__, __method__)
            
            begin
              score = getScore(bulkText)
              logDebug("Successfully got results from: \"https://readability-score.com/\"", __FILE__, __LINE__, __method__)
              return score
          
            rescue
              logDebug("An error occured while trying to get results from: \"https://readability-score.com/\"", __FILE__, __LINE__, __method__)
              return 0
            end
          end
        end

      rescue
        next
      end
    end

    begin
      logDebug("Less than 500 words were collected, so readability test is being performed on all words grabbed.", __FILE__, __LINE__, __method__)

      score = getScore(bulkText)
      logDebug("Successfully got results from: \"https://readability-score.com/\"", __FILE__, __LINE__, __method__)
      return score

    rescue
      logDebug("An error occured while trying to get results from: \"https://readability-score.com/\"", __FILE__, __LINE__, __method__)
      return 0
    end
  end

  def syllCount(word)
    word.downcase!

    return 1 if word.length <= 3
    word.sub!(/(?:[^laeiouy]es|ed|[^laeiouy]e)$/, '')
    word.sub!(/^y/, '')
    word.scan(/[aeiouy]{1,2}/).size
  end

  def performTest    
    readScore = scoreAllText
    
    @score = @coeffMod * (((readScore >= 50) and (readScore <= 70)) ? 1 : 0)
    writeScore
  end

  def putLinks
    puts @@allLinks
  end	
end