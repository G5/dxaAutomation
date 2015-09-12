require '../testClasses/testClass1'

class GPCitation < TestClass
  
  def initialize(requirements, selDriver, nokoPage, scoreCoeff, testNam, fileNam=:DEFINED, logFil=:DEFINED, urlName=:DEFINED, bizNam=:DEFINED, gPlusI=:DEFINED, allLink=:DEFINED, zipCod=:DEFINED)
    super(requirements, selDriver, nokoPage, scoreCoeff, testNam, fileNam, logFil, urlName, bizNam, gPlusI, allLink, zipCod)
  end

def chooseListing
  puts "This program could not choose a listing based of business name or ZIP code. Please manually click on the listing that is the most accurate."
  puts "Once you have done this, please choose from the following options:"
  puts "1. Enter \"done\" into the command prompt and hit enter once you have clicked on the preferred listing."
  puts "2. If you wish to skip this part of the test, then please enter \"skip\" into the prompt and hit enter (note that if you choose this option you will fail this part of the test)."
  print "Choice: "

  input = STDIN.gets.chomp.downcase

  until input =~ /^([\s]*(done|skip)[\s]*)$/ 
    print "Invalid choice, enter \"done\" or \"skip\" into the prompt and hit enter to continue: "
    input = STDIN.gets.chomp.downcase
  end

  if input =~ /^([\s]*(done)[\s]*)$/
    return true
  end

  return false
end

def getGoogleRes

  begin
    sleep(1)
    googleRes = @driver.find_element(:class, "engine-bar-group")
    googleRes = googleRes.find_element(:css, ".engine-bar.engine-bar-complete")
    return googleRes.find_element(:tag_name, "span").text.delete("%")

  rescue
    logDebug("Could not load Google+ citation results on page: #{@driver.current_url}", __FILE__, __LINE__, __method__)
    return :LOAD_FAILED
  end
end

def loadCiteRes(result, userClick)
  
  unless userClick
    result.find_element(:tag_name, "a").click
  end

  begin
    wait = Selenium::WebDriver::Wait.new(:timeout => 15)
    wait.until { @driver.find_element(:css => ".progress-point.progress-current").displayed? }
    sleep(5)

    citeRes = @driver.find_element(:css, ".progress-point.progress-current")
    return citeRes.find_element(:tag_name, "h1").text.delete("%")

  rescue
    logDebug("Could not load total citation results on page: #{@driver.current_url}", __FILE__, __LINE__, __method__)
    return :LOAD_FAILED
  end
end

def loadResults(bizName, zipCode)
  inputs = @driver.find_elements(:css, ".form-control.input-lg")
  inputs[0].send_keys(bizName)
  inputs[1].send_keys(zipCode)
  logDebug("Successfully sent keys to input boxes on page: #{@driver.current_url}", __FILE__, __LINE__, __method__)

  submitBtn = @driver.find_element(:css, ".btn.btn-warning.btn-lg")
  submitBtn.click
  logDebug("Successfully clicked input button on page: #{@driver.current_url}", __FILE__, __LINE__, __method__)

  begin
    wait = Selenium::WebDriver::Wait.new(:timeout => 10)
    wait.until { @driver.find_element(:class => "search-result").displayed? }
    sleep(1)

  rescue
    logDebug("When loading results on page: #{@driver.current_url}, an error occured. Either search results were not loaded correctly or the test timed out.", __FILE__, __LINE__)
    return :LOAD_FAILED
  end
end

def getProbRes(verified)
  logDebug("Google+ listing was #{(verified ? "" : "not")} verified, therefore the search will take place on the #{(verified ? "" : "non-")}verified listings on page: #{@driver.current_url}.", __FILE__, __LINE__)
  results = @driver.find_elements(:class, "search-result")
  probRes = []

  results.each do |result|
    spanTxt = result.find_element(:tag_name, "span").text

    if (!verified) and (spanTxt =~ /\(?[\d]{3}\)?\s*[\d]{3}\s*-?\s*[\d]{4}/)
      probRes << result
    end

    if verified and (spanTxt.downcase.include? "verified")
      probRes << result
    end
  end 

  if probRes.length == 0
    logDebug("No results were found on page: #{@driver.current_url}", __FILE__, __LINE__, __method__)
    return :NO_RESULTS

  else
    return probRes
  end
end

def searchRes(results, attribute, attribTag)
  refinedRes = []
  logDebug("This search attempts to match #{(attribTag == :NAME ? "business name" : "zip code")}. This is the #{(attribTag == :NAME ? "primary" : "secondary")} search.", __FILE__, __LINE__)

  results.each do |result|

    if attribTag == :NAME

      if result.find_element(:tag_name, "a").text.downcase == attribute.downcase
        refinedRes << result
        logDebug("When searching results, there was a business name match. The result anchor tag was: \"#{result.find_element(:tag_name, "a").text}\", and the business name is: \"#{attribute.downcase}\".", __FILE__, __LINE__)
      end

    elsif attribTag == :ZIP

      if result.text.include? attribute
        logDebug("When searching results, there was a zip code match. The result text was: \"#{result.text}\", and the real zip code is: \"#{attribute}\". Program assumes this is the correct result. Returning result.", __FILE__, __LINE__)
        return result
      end

    else
      raise ArgumentError
    end
  end
  
  if (refinedRes.length == 0)  
    logDebug("There were no results that matched. Returning no result and a #{:NO_MATCH} label.", __FILE__, __LINE__, __method__)
    return nil, :NO_MATCH

  elsif refinedRes.length == 1
    logDebug("A single result was found. Returning result and a #{:FOUND} label.", __FILE__, __LINE__, __method__)
    return refinedRes[0], :FOUND

  else
    logDebug("There were multiple results found. Returning results container and a #{:SEARCH_AGAIN} label.", __FILE__, __LINE__, __method__)
    return refinedRes, :SEARCH_AGAIN
  end
end

  def performTest
    coeffList = @coeffMod
    @coeffMod = coeffList[0]
    @testName = "Google+ Consistent Citations"
    initDebugFile

    @driver.get "https://moz.com/local/search"
    sleep(2)

    GooglePlus.api_key = File.read('../keys/gPlusAPIKey.txt')
    person = GooglePlus::Person.get(@@gPlusID)

    if loadResults(@@bizName, @@zipCode) == :LOAD_FAILED
      @score = 0
      writeScore
      return
    end

    results = getProbRes(person.verified)

    if results == :NO_RESULTS
      @score = 0
      writeScore
      return
    end

    results, searchFlag = searchRes(results, @@bizName, :NAME)

    if searchFlag == :NO_MATCH
      @score = 0
      writeScore
      return
    end

    if searchFlag == :SEARCH_AGAIN
      results, searchFlag = searchRes(results, @@zipCode, :ZIP)
    end

    if searchFlag == :NO_MATCH
      logDebug("Even after the secondary search, no results were found. Test failed.", __FILE__, __LINE__, __method__)
      @score = 0
      writeScore
      return
    end

    userClick = false

    if searchFlag == :SEARCH_AGAIN
      logDebug("Could not refine results, so asking user to select most accurate listing.", __FILE__, __LINE__, __method__)

      unless chooseListing
        logDebug("User chose to skip choosing the proper listing. Test failed.", __FILE__, __LINE__, __method__)
        @score = 0
        writeScore
        return
      end

      userClick = true
    end  

    totCitScore = loadCiteRes(results, userClick)

    if totCitScore == :LOAD_FAILED
      @score = 0
      writeScore
      return
    end

    gPCitScore = getGoogleRes

    if gPCitScore == :LOAD_FAILED
      @score = 0
      writeScore
      return
    end
    
    @score = @coeffMod * (gPCitScore.to_i > 75 ? 1 : 0)
    writeScore
  end	

  def putLinks
    puts @@allLinks
  end	
end
