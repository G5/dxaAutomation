require '../testClasses/testClass1'

class MaintReqTest < TestClass
  
  def initialize(requirements, selDriver, nokoPage, scoreCoeff, testNam, fileNam=:DEFINED, logFil=:DEFINED, urlName=:DEFINED, bizNam=:DEFINED, gPlusI=:DEFINED, allLink=:DEFINED, zipCod=:DEFINED)
    super(requirements, selDriver, nokoPage, scoreCoeff, testNam, fileNam, logFil, urlName, bizNam, gPlusI, allLink, zipCod)
  end

  def askUser
    print "\n>>>The program has reached the most likely login page, which it does not have access to. Does this resident portal site have maintenance requests? Please enter \"yes\" or \"no\" as to whether it has this functionality: "
    input = STDIN.gets.chomp.delete(" ").downcase

    until input =~ /^(yes|no)$/
      print ">>>Invalid input. Please enter \"yes\" or \"no\": "
      input = STDIN.gets.chomp.delete(" ").downcase
    end

    if input.include? "yes"
      logDebug("User confirmed that the login page has maintenance request functionality.", __FILE__, __LINE__, __method__)
      return true
    end

    logDebug("User confirmed that the login page did not have maintenance request functionality.", __FILE__, __LINE__, __method__)
    return false
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

  def getInputs
    inputs = []

    @driver.find_elements(:tag_name, "input").each do |input|
      
      if input.displayed?
        inputs << input
      end
    end

    return inputs
  end

  def getMRLink
    maintRLink = nil

    @driver.find_elements(:tag_name, "a").each do |anch|

      if anch.text.delete(" ").downcase.include? "maintenancerequest"
        maintRLink = anch.attribute("href").to_s
        break
      end
    end

    return maintRLink
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

  def homeMRTest
    return secResTest(@@url)
  end

  def primResTest(link)
    @driver.get link
    sleep(1)
    logDebug("Primary search performed with link: #{link}", __FILE__, __LINE__, __method__)
    return askUser
  end

  def secResTest(parLink)
    logDebug("Maintenance request search performed with the parent link: #{parLink}", __FILE__, __LINE__, __method__)
    @driver.get parLink
    sleep(1)
    maintRLink = getMRLink

    unless maintRLink
      logDebug("Could not find maintainence requests on page.", __FILE__, __LINE__, __method__)
      return false
    end

    logDebug("Found maintenance request link: #{maintRLink}", __FILE__, __LINE__, __method__)

    @driver.get maintRLink
    sleep(1)

    inputs = getInputs
    logInBtns = findLogIn

    if (inputs.length >= 2) and (logInBtns.length >= 1)
      logDebug("At least 2 inputs and one button were found on page, which suggests there are maintenance requests.", __FILE__, __LINE__, __method__)
      return true
    end

    logDebug("There were not enough elements to suggest that there were maintenace requests on the page.", __FILE__, __LINE__, __method__)
    return false
  end

  def performTest(searchFlag, parLink, childLink)
    maintReq = false

    unless searchFlag == :NONE

      if searchFlag == :SECONDARY_SEARCH
        maintReq = secResTest(parLink)
      end

      if maintReq
        logDebug("Found maintenance requests in the secodary search with parent link: #{parLink}", __FILE__, __LINE__, __method__)
        @score = @coeffMod
        writeScore
        return
      end

      maintReq = primResTest((searchFlag == :PRIMARY_SEARCH ? parLink : childLink))

      if maintReq
        logDebug("Found maintenance requests in the primary search with link: #{(searchFlag == :PRIMARY_SEARCH ? parLink : childLink)}", __FILE__, __LINE__, __method__)
        @score = @coeffMod
      
      else
        logDebug("#{(@score == 0 ? "No maintainence requests found" : "Maintainence requests found")} in the home page search with link: #{@@url}", __FILE__, __LINE__, __method__)
        @score = @coeffMod * (homeMRTest ? 0.5 : 0.0)
      end

      writeScore
      return
    end

    if parLink
      logDebug("#{(@score == 0 ? "No maintainence requests found" : "Maintainence requests found")} in secondary search with parent link: #{parLink}", __FILE__, __LINE__, __method__)
      @score = @coeffMod * (secResTest(parLink) ? 1.0 : 0.0)

    else
      logDebug("#{(@score == 0 ? "No maintainence requests found" : "Maintainence requests found")} in the home page search with link: #{@@url}", __FILE__, __LINE__, __method__)
      @score = @coeffMod * (homeMRTest ? 0.5 : 0.0)
    end

    writeScore
  end

  def putLinks
    puts @@allLinks
  end	
end