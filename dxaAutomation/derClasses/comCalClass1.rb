require '../testClasses/testClass1'

class ComCalTest < TestClass
  
  def initialize(requirements, selDriver, nokoPage, scoreCoeff, testNam, fileNam=:DEFINED, logFil=:DEFINED, urlName=:DEFINED, bizNam=:DEFINED, gPlusI=:DEFINED, allLink=:DEFINED, zipCod=:DEFINED)
    super(requirements, selDriver, nokoPage, scoreCoeff, testNam, fileNam, logFil, urlName, bizNam, gPlusI, allLink, zipCod)
  end

  def askUser
    print "\n>>>The program has reached the most likely login page, which it does not have access to. Does this resident portal site have a community calendar? Please enter \"yes\" or \"no\" as to whether it has this functionality: "
    input = STDIN.gets.chomp.delete(" ").downcase

    until input =~ /^(yes|no)$/
      print ">>>Invalid input. Please enter \"yes\" or \"no\": "
      input = STDIN.gets.chomp.delete(" ").downcase
    end

    if input.include? "yes"
      logDebug("User confirmed that the login page had community calendar functionality. Test passed.", __FILE__, __LINE__, __method__)
      return true
    end

    logDebug("User confirmed that the login page did not have community calendar functionality. Test failed.", __FILE__, __LINE__, __method__)
    return false
  end

  def getCalLink
    maintRLink = nil

    @driver.find_elements(:tag_name, "a").each do |anch|

      if (anch.text.delete(" ").downcase.include? "calendar") or (anch.text.delete(" ").downcase.include? "events")
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

  def homeCalTest
    return secCalTest(@@url)
  end

  def primCalTest(link)
    @driver.get link
    sleep(1)
    logDebug("Primary calendar search performed with the link: #{link}", __FILE__, __LINE__, __method__)
    return askUser
  end

  def secCalTest(parLink)
    logDebug("Calendar search performed with the parent link: #{parLink}", __FILE__, __LINE__, __method__)
    @driver.get parLink
    sleep(1)
    comCalLink = getCalLink

    unless comCalLink
      logDebug("Could not find calendar link on page.", __FILE__, __LINE__, __method__)
      return false
    end

    logDebug("Found calendar link: #{comCalLink}", __FILE__, __LINE__, __method__)

    @driver.get comCalLink
    sleep(1)

    tables = @driver.find_elements(:tag_name, "table")

    if tables.length >= 1
      logDebug("A <table> element(s) was found on: #{comCalLink}", __FILE__, __LINE__, __method__)
      return true
    end

    logDebug("No <table> element(s) was found on the #{comCalLink}", __FILE__, __LINE__, __method__)
    return false
  end

  def performTest(searchFlag, parLink, childLink)
    comCalendar = false

    unless searchFlag == :NONE

      if searchFlag == :SECONDARY_SEARCH
        comCalendar = secCalTest(parLink)
      end

      if comCalendar
        logDebug("Found calendar in the secodary search with parent link: #{parLink}", __FILE__, __LINE__, __method__)
        @score = @coeffMod
        writeScore
        return
      end

      comCalendar = primCalTest((searchFlag == :PRIMARY_SEARCH ? parLink : childLink))

      if comCalendar
        logDebug("Found calendar in the primary search with link: #{(searchFlag == :PRIMARY_SEARCH ? parLink : childLink)}", __FILE__, __LINE__, __method__)
        @score = @coeffMod
      
      else
        @score = @coeffMod * (homeCalTest ? 0.5 : 0.0)
        logDebug("#{(@score == 0 ? "No Calendar found" : "Found calendar")} in home page search with link: #{@@url}", __FILE__, __LINE__, __method__)
      end

      writeScore
      return
    end

    if parLink
      @score = @coeffMod * (secCalTest(parLink) ? 1.0 : 0.0)
      logDebug("#{(@score == 0 ? "No Calendar found" : "Found calendar")} in secondary search with parent link: #{parLink}", __FILE__, __LINE__, __method__)

    else
      @score = @coeffMod * (homeCalTest ? 0.5 : 0.0)
      logDebug("#{(@score == 0 ? "No Calendar found" : "Found calendar")} in home page search with link: #{@@url}", __FILE__, __LINE__, __method__)
    end

    writeScore
  end

  def putLinks
    puts @@allLinks
  end	
end