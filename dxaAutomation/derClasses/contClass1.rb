require '../testClasses/testClass1'

class ContentPP < TestClass
  
  def initialize(requirements, selDriver, nokoPage, scoreCoeff, testNam, fileNam=:DEFINED, logFil=:DEFINED, urlName=:DEFINED, bizNam=:DEFINED, gPlusI=:DEFINED, allLink=:DEFINED, zipCod=:DEFINED)
    super(requirements, selDriver, nokoPage, scoreCoeff, testNam, fileNam, logFil, urlName, bizNam, gPlusI, allLink, zipCod)
  end

  def performTest
    wordCount = 0
    wordSplay = Containers::SplayTreeMap.new
    enoughWords = false
    testPassed = true
    
    @@allLinks.each do |link|

      @driver.get link
      sleep(2)

      begin

        status = Timeout::timeout(10) {

          enoughWords = false

          @driver.find_elements(:xpath, "//*").each do |elem|
            elemText = elem.text.gsub("\n", " ")

            next if elemText.delete(" ") == ""

            next if elemText.include? "<"

            next unless elemText =~ /[a-zA-Z]/

            next unless wordSplay[elemText] == nil
            wordSplay[elemText] = elemText
            wordCount = wordCount + elem.text.to_s.split(" ").length

            if wordCount > 250
              enoughWords = true
              break
            end  
          end
        }

        if enoughWords
          appendScore(1.0)
          logDebug("There was an adequate number of words found on page: #{link}", __FILE__, __LINE__, __method__)
        
        else
          appendScore(0.0)
          logDebug("There were not an adequate number of words found on page: #{link}", __FILE__, __LINE__, __method__)
        end

        wordSplay.clear

      rescue
        wordSplay.clear
        appendScore(0.0)
        next
      end  
    end
 
    @score = @coeffMod * getAverage

    logDebug("An average of #{getAverage} pages had adequate content.", __FILE__, __LINE__, __method__)
    writeScore
  end	

  def putLinks
    puts @@allLinks
  end	
end