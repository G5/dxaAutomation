require '../testClasses/testClass1'

class ContentPP < TestClass
  
  def initialize(requirements, selDriver, nokoPage, scoreCoeff, testNam, fileNam=:DEFINED, logFil=:DEFINED, urlName=:DEFINED, bizNam=:DEFINED, gPlusI=:DEFINED, allLink=:DEFINED, zipCod=:DEFINED)
    super(requirements, selDriver, nokoPage, scoreCoeff, testNam, fileNam, logFil, urlName, bizNam, gPlusI, allLink, zipCod)
  end

  def performTest
    wordHash = Hash.new
    
    @@allLinks.each do |link|
      enoughWords = false
      wordCount = 0

      @driver.get link
      sleep(1)

      begin

        status = Timeout::timeout(10) {

          @driver.find_elements(:xpath, "//*").each do |elem|
            elemText = elem.text.gsub("\n", " ")

            next if elemText.delete(" ") == ""

            next if elemText.include? "<"

            next unless elemText =~ /[a-zA-Z]/

            next if wordHash[elemText] == :DEFINED

            wordHash[elemText] = :DEFINED
            wordCount = wordCount + elem.text.to_s.split(" ").length

            if wordCount > 250
              enoughWords = true
              break
            end  
          end
        }

        if enoughWords
          logDebug("There was an adequate number of words found on the page: #{link}", __FILE__, __LINE__, __method__)
          appendScore(1.0)
        
        else
          logDebug("There were not an adequate number of words found on the page: #{link}", __FILE__, __LINE__, __method__)
          appendScore(0.0)
        end

        wordHash.clear

      rescue
        logDebug("On page: #{link}, the test timed out, so the current page fails (not an adequate number of words).", __FILE__, __LINE__, __method__)
        appendScore(0.0)
        wordHash.clear
        next
      end  
    end
 
    logDebug("An average of: #{getAverage} pages had adequate content.", __FILE__, __LINE__, __method__)
    @score = getAverage * @coeffMod
    writeScore
  end	

  def putLinks
    puts @@allLinks
  end	
end