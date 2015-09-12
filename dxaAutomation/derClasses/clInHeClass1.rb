require '../testClasses/testClass1'

class ClearInfHeaders < TestClass
  
  def initialize(requirements, selDriver, nokoPage, scoreCoeff, testNam, fileNam=:DEFINED, logFil=:DEFINED, urlName=:DEFINED, bizNam=:DEFINED, gPlusI=:DEFINED, allLink=:DEFINED, zipCod=:DEFINED)
    super(requirements, selDriver, nokoPage, scoreCoeff, testNam, fileNam, logFil, urlName, bizNam, gPlusI, allLink, zipCod)
  end

  def getGrammarScore(allHeadText, totalHead)
    @driver.get "https://www.grammarly.com/1"
    sleep(5)

    begin
      textArea = @driver.find_element(:tag_name, "textarea")
      textArea.click
      textArea.send_keys(allHeadText)
      
      print "\n>>>For this test, all of the header text gathered from the website has been inputted into the upload box on the driver's current page. Please read the header text and then hit the \"Check your text\" button and read the results. Using the grammar results and what you have read in the headers, please input \"clear\" or \"unclear\" into the terminal to describe the headings, or enter a number between 0 and 10 do describe the headers' clarity: "
      input = STDIN.gets.chomp.downcase

      until (input =~ /^(\s*((clear|unclear)|(\d*((\.)\d*)?))\s*)$/) and (input =~ /\S/) # Should work up to here.
        print ">>>Invalid input. Enter \"clear\" or \"unlcear\", or provide a number between 0 and 10: "
        input = STDIN.gets.chomp.downcase
      end

      clarityScore = 0

      if input =~ /(clear|unclear)/ 
    
        if input =~ /(unclear)/
          clarityScore = 0.0
          logDebug("User inputted \"unclear\" option.", __FILE__, __LINE__, __method__)

        else
          logDebug("User inputted \"clear\" option.", __FILE__, __LINE__, __method__)
          clarityScore = 10.0
        end
    
      else
        clarityScore = input.to_f         
        logDebug("User inputted: #{clarityScore}.", __FILE__, __LINE__, __method__)
      
        if clarityScore > 10.0
          puts "Number was bigger than 10 so it is being rounded to 10."
          clarityScore = 10.0
        end
      end 


      print "\n>>>Now, using the grammar results and what you have read in the headers, please input \"informative\" or \"not informative\" into the terminal to describe the headings, or enter a number between 0 and 10 do describe the headers' descriptiveness: "
      input = STDIN.gets.chomp.delete(" ").downcase

      until (input =~ /^(\s*((informative|no(n|t)\s*-?\s*informative)|(\d*((\.)\d*)?))\s*)$/) and (input =~ /\S/)
        print "Invalid input. Enter \"informative\" or \"not informative\", or provide a number between 0 and 10: "
        input = STDIN.gets.chomp.delete(" ").downcase
      end

      informScore = 0

      if input =~ /(informative|no(n|t)\s*[-]?\s*informative)/
    
        if input =~ /(no(n|t)\s*[-]?\s*informative)/
          informScore = 0.0
          logDebug("User inputted \"not informative\" option.", __FILE__, __LINE__, __method__)

        else
          logDebug("User inputted \"informative\" option.", __FILE__, __LINE__, __method__)
          informScore = 10.0
        end
    
      else
        informScore = input.to_f
        logDebug("User inputted: #{clarityScore}.", __FILE__, __LINE__, __method__)
      
        if informScore > 10.0
          puts "Number was bigger than 10 so it is being rounded to 10."
          informScore = 10.0
        end
      end

      return ((clarityScore + informScore) / 20.0)

    rescue
      logDebug("There was an error with loading the page, or finding the text area for submitting.", __FILE__, __LINE__, __method__)
      #raise ArgumentError, "Could not locate submit elements on page. Website could have potentially changed format."
    end
  end

  def getHeaderText(link)
    pageSrc = Nokogiri::HTML(open(link))

    unless pageSrc.encoding.to_s == 'utf-8'
      logDebug("The page encoding is: \'#{pageSrc.encoding.to_s}\', setting it to: \'utf-8\'.", __FILE__, __LINE__, __method__)
      html = open(link)
      pageSrc = Nokogiri::HTML(html.read)
      pageSrc.encoding = 'utf-8'
    end

    headerNum = 1
    bulkText = ""

    headers = pageSrc.xpath("//h1")
    accPunctuation = ['.', '!', '?']
    headTotal = 0

    until headers == pageSrc.xpath("//NONEXISTENT_ELEMENT")
      logDebug("Looping through headers. Current header value: \"h#{headerNum}\".", __FILE__, __LINE__, __method__)

      headers.each do |header|
        headerTxt = header.text.to_s

        unless (headerTxt =~ /\w/)
          next
        end
        
        bulkText << headerTxt
        headTotal = headTotal + 1

        unless accPunctuation.include? headerTxt[-1]
          bulkText << '.'
        end

        bulkText << ' '
      end

      logDebug("h#{headerNum} text: #{bulkText}", __FILE__, __LINE__, __method__)

      headerNum = headerNum + 1
      headers = pageSrc.xpath("//h#{headerNum}")
    end

    bulkText = bulkText.delete("\n")

    unless bulkText =~ /\w/
      #raise "No headers found."
      return '', 0
    end

    return bulkText, headTotal
  end

  def performTest
    allHeadText = ""
    totalHead = 0

    @@allLinks.each do |link|
      logDebug("Looping through pages. Currently grabbing header info from page: \"#{link}\".", __FILE__, __LINE__, __method__)
      headText, headInPage = getHeaderText(link)
      
      allHeadText << headText
      totalHead = totalHead + headInPage
    end

    if !(allHeadText =~ /\w/) or (totalHead == 0)
      logDebug("There were no headers on any of the pages (the bulk text string was empty).", __FILE__, __LINE__, __method__)
      @score = 0
      writeScore
      return
    end

    wordCount = allHeadText.scan(/(\w+(\.|!|\?)?\s*)/).length
    
    if wordCount < 40
      logDebug("There were not enough words to plug into grammarly (the readability site that is used in this test).", __FILE__, __LINE__, __method__)
      @score = 0

    else
      @score = (getGrammarScore(allHeadText, totalHead) / 10.0)
    end
    
    @score = @coeffMod * @score
    writeScore
  end

  def putLinks
    puts @@allLinks
  end	
end