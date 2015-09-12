require '../testClasses/testClass1'

class OnPayTest < TestClass
  
  def initialize(requirements, selDriver, nokoPage, scoreCoeff, testNam, fileNam=:DEFINED, logFil=:DEFINED, urlName=:DEFINED, bizNam=:DEFINED, gPlusI=:DEFINED, allLink=:DEFINED, zipCod=:DEFINED)
    super(requirements, selDriver, nokoPage, scoreCoeff, testNam, fileNam, logFil, urlName, bizNam, gPlusI, allLink, zipCod)

    #@testName = testNam
  end

  def findLogIn
    terms = ["login", "signin", "logmein", "go", "send"]
    logInElems = []
    potElems = @driver.find_elements(:tag_name, "button") + @driver.find_elements(:tag_name, "input") + @driver.find_elements(:tag_name, "a")
    
    potElems.each do |elem|
      
      terms.each do |term|
        elemText = elem.text.delete(" ").downcase

        unless elemText =~ /\w/
          elemText = elem.attribute("value").to_s.delete(" ").downcase
        end

        if elemText.include? term and hasAction(elem)
          
          unless logInElems.include? elem 
            logInElems << elem
            break
          end
        end
      end
    end

    return logInElems
  end

  def findLink(term)
    
    @driver.find_elements(:tag_name, "a").each do |anch|
      
      if anch.text.downcase.delete(" ").include? term
        logDebug("Found link on page with term", __FILE__, __LINE__)
        return anch.attribute("href").to_s
      end
    end

    logDebug("Did not find any links with term: \"#{term}\".", __FILE__, __LINE__)
    return :NOT_FOUND
  end

  def getInputs
    inputs = []

    @driver.find_elements(:tag_name, "input").each do |input|
      
      if input.displayed?
        inputs << input
      end
    end

    return inputs
  end

  def hasAction(elem)

    if elem.attribute("type").to_s.include? "submit"
      return true
    end

    if elem.attribute("onclick").to_s.include? "submit();"
      return true
    end

    return false
  end

  def primaryRes(link)
    @driver.get link
    sleep(1)
    logDebug("Current page is: #{@driver.current_url}", __FILE__, __LINE__, __method__)

    inputs = getInputs
    logDebug("Number of inputs found on page: #{inputs.length}", __FILE__, __LINE__)

    logInBtns = findLogIn
    logDebug("Number of buttons found on page: #{logInBtns.length}", __FILE__, __LINE__)

    if ((inputs.length >= 2) and logInBtns.length >= 1)
      logDebug("Found link: #{link}, in primary search.", __FILE__, __LINE__)
      return :PRIMARY_SEARCH, link, nil

    else
      logDebug("Attempting to find links with text: \"login\"", __FILE__, __LINE__)
      newLink = findLink("login")

      if newLink == :NOT_FOUND
        logDebug("Attempting to find links with text: \"portal\"", __FILE__, __LINE__)
        newLink = findLink("portal")
      end

      if newLink == :NOT_FOUND
        logDebug("Did not find desired log in link, but returning link: #{link} in primary link position for future use.", __FILE__, __LINE__)
        return :NONE, link, nil   
      end

      newLink = secondaryRes(newLink)

      logDebug("Returning label: #{(newLink == nil ? :NONE : :SECONDARY_SEARCH)} primary link: #{link}, and secondary link: #{newLink}", __FILE__, __LINE__)
      return (newLink == nil ? :NONE : :SECONDARY_SEARCH), link, newLink
    end
  end

  def secondaryRes(link)
    @driver.get link
    sleep(1)
    logDebug("Current page is: #{@driver.current_url}", __FILE__, __LINE__, __method__)

    inputs = getInputs
    logDebug("Number of inputs found on page: #{inputs.length}.", __FILE__, __LINE__, __method__)

    logInBtns = findLogIn
    logDebug("Number of log in buttons found on page: #{logInBtns.length}.", __FILE__, __LINE__, __method__)

    if ((inputs.length >= 2) and logInBtns.length >= 1)
      logDebug("Found an input scheme so returning link for future use.", __FILE__, __LINE__, __method__)
      return link

    else
      logDebug("Found no input scheme. Returning.", __FILE__, __LINE__, __method__)
      return nil
    end
  end

  def userScore
    print "\n>>>The program has reached the most likely login page, which it does not have access to. Does the resident portal site have online payment functionality? Please enter \"yes\" or \"no\" as to whether it has this functionality: "
    input = STDIN.gets.chomp.delete(" ").downcase

    until input =~ /^(yes|no)$/
      print ">>>Invalid input. Please enter \"yes\" or \"no\": "
      input = STDIN.gets.chomp.delete(" ").downcase
    end

    if input.include? "yes"
      logDebug("User said that the log in page has online payment functionality.", __FILE__, __LINE__, __method__)
      @score = @coeffMod
      return
    end

    @score = 0
    logDebug("User said that the log in page does not have online payment functionality.", __FILE__, __LINE__, __method__)
  end

  def performTest
    @driver.get @@url
    sleep(1)
    logDebug("Current page is: #{@driver.current_url}", __FILE__, __LINE__, __method__)
    resLink = findLink("resident")

    if resLink == :NOT_FOUND
      @score = 0
      writeScore
      return :NONE, nil, nil
    end

    searchFlag, primLink, secLink = primaryRes(resLink)

    if searchFlag == :NONE
      logDebug("No log in page was found.", __FILE__, __LINE__, __method__)
      @score = 0
    
    else
      logDebug("A log in page was found.", __FILE__, __LINE__, __method__)
      userScore 
    end

    writeScore
    return searchFlag, primLink, secLink
  end

  def putLinks
    puts @@allLinks
  end	
end