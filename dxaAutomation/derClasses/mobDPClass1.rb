require '../testClasses/testClass1'

class MobPayTest < TestClass
  
  def initialize(requirements, selDriver, nokoPage, scoreCoeff, testNam, fileNam=:DEFINED, logFil=:DEFINED, urlName=:DEFINED, bizNam=:DEFINED, gPlusI=:DEFINED, allLink=:DEFINED, zipCod=:DEFINED)
    super(requirements, selDriver, nokoPage, scoreCoeff, testNam, fileNam, logFil, urlName, bizNam, gPlusI, allLink, zipCod)
  end

  def askUser
    print "This login is internal, and therefore, there is no way to know if the site it leads to is mobile-friendly. Please enter \"yes\" or \"no\" as to whether you think the externally linked site will have mobile compatibility or not: "
    input = STDIN.gets.chomp.delete(" ").downcase

    until input =~ /^(yes|no)$/
      print "Invalid input. Please enter \"yes\" or \"no\": "
      input = STDIN.gets.chomp.delete(" ").downcase
    end

    if input.include? "yes"
      logDebug("The user said that login page: #{@driver.current_url} has device payments. Test passed.", __FILE__, __LINE__, __method__)
      @score = @coeffMod
      return
    end

    logDebug("The user said that login page: #{@driver.current_url} does not have device payments. Test failed.", __FILE__, __LINE__, __method__)
    @score = 0
  end

  def mobileTest(link)
    @driver.get "https://www.google.com/webmasters/tools/mobile-friendly/?url=#{link}"
    
    begin
      wait = Selenium::WebDriver::Wait.new(:timeout => 15)
      wait.until { @driver.find_element(:class => "result-container").displayed? }

    rescue

      begin
        @driver.get "https://www.google.com/webmasters/tools/mobile-friendly/?url=#{link}"
        wait.until { @driver.find_element(:class => "result-container").displayed? }
    
      rescue
        logDebug("Could not load page: https://www.google.com/webmasters/tools/mobile-friendly/?url=#{link}. Test auto fails.", __FILE__, __LINE__, __method__)
        return false
      end
    end

    unless @driver.find_element(:class, "result-container").text.include? "not mobile-friendly"
      logDebug("Results say that #{link} is mobile friendly. Continuing.", __FILE__, __LINE__, __method__)
      return true
    end

    logDebug("Results say that #{link} is not mobile friendly. Test failed.", __FILE__, __LINE__, __method__)
    return false
  end

  def performTest(searchFlag, primLink, secLink)

    if searchFlag == :NONE
      logDebug("An online portal was not found. Test auto failed.", __FILE__, __LINE__, __method__)
      @score = 0
      writeScore
      return
    end

    resLink = (searchFlag == :PRIMARY_SEARCH ? primLink : secLink)

    mobCompatible = mobileTest(resLink)
    @driver.get resLink
    @link = resLink

    unless mobCompatible
      @score = 0
      writeScore
      return
    end
    
    if resLink.include? @@url
      askUser

    else
      @score = @coeffMod
      logDebug("The login page: #{resLink}, is externally linked and mobile friendly. Therefore it is implied to have mobile device payments. Test passed.", __FILE__, __LINE__, __method__)
    end
    
    writeScore
  end

  def putLinks
    puts @@allLinks
  end	
end