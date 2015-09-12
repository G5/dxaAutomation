require '../testClasses/testClass1'

class ComPosTest < TestClass
  
  def initialize(requirements, selDriver, nokoPage, scoreCoeff, testNam, fileNam=:DEFINED, logFil=:DEFINED, urlName=:DEFINED, bizNam=:DEFINED, gPlusI=:DEFINED, allLink=:DEFINED, zipCod=:DEFINED)
    super(requirements, selDriver, nokoPage, scoreCoeff, testNam, fileNam, logFil, urlName, bizNam, gPlusI, allLink, zipCod)
  end

  def findAdCont

    begin
      adTopCont = @driver.find_element(:id, "tads").find_elements(:class, "ads-ad")

      if adTopCont.length == 0
        adTopCont = :NONE
      end

    rescue
      logDebug("No top ad banner found.", __FILE__, __LINE__, __method__)
      adTopCont = :NONE
    end

    begin
      adRHSCont = @driver.find_element(:id, "rhs_block").find_elements(:class, "ads-ad")

      if adRHSCont.length == 0
        adRHSCont = :NONE
      end

    rescue
      logDebug("No right hand side ad banner found.", __FILE__, __LINE__, __method__)
      adRHSCont = :NONE
    end

    return adTopCont, adRHSCont
  end

  def getAdURL(ad)
    
    begin
      url = ad.find_element(:tag_name, "cite").text.downcase

    rescue
      logDebug("No url found in ad: #{ad}.", __FILE__, __LINE__, __method__)
      return :NOT_FOUND
    end

    logDebug("The url found in ad: #{ad}, is: #{url}", __FILE__, __LINE__, __method__)
    return url
  end

  def searchBiz(tmpURL)
    print "\n>>>Performing a business name search on Google to generate ads."
    @driver.get "https://www.google.com/?gws_rd=ssl"
    sleep(1)
    input = @driver.find_element(:id, "lst-ib")
    input.send_keys(@@bizName)
    input.submit
    sleep(2)

    logDebug("Current search term: \"#{@@bizName}\".", __FILE__, __LINE__, __method__)

    adTopCont, adRHSCont = findAdCont
    topAdFlag = searchAds(adTopCont, tmpURL)

    if topAdFlag == true
      return true
    end

    rhsAdFlag = searchAds(adRHSCont, tmpURL)

    if rhsAdFlag == true
      return true
    end

    return false
  end

  def searchAds(ads, tmpURL)
    
    if ads == :NONE
      return :NO_ADS
    end

    loopLimit = (ads.length < 3 ? ads.length : 3)

    for i in 0...loopLimit
      adUrl = getAdURL(ads[i])

      next if adUrl == :NOT_FOUND

      if adUrl.include? tmpURL
        logDebug("A match was found with ad: #{ads[i]}, whose url is: #{adUrl}.", __FILE__, __LINE__, __method__)
        return true
      end
    end

    logDebug("No matches were found.", __FILE__, __LINE__, __method__)
    return false
  end

  def userSearch(tmpURL)
    print "\n\n>>>You will now be prompted to enter search terms to generate ads for your business. Do you wish to continue? Please enter \"yes\" or \"no\": "
    option = STDIN.gets.chomp

    until option =~ /^(\s*(yes|no)\s*)$/
      print ">>>Invalid input. Please enter \"yes\" or \"no\": "
      option = STDIN.gets.chomp
    end

    if option.include? "no"
      return 0
    end

    searchNum = 1

    loop do
      print "\n>>>Attempt #{searchNum}: Please enter a search term to generate ads for the selected site. Additionally you may enter \"auto\" followed by \"pass\" or \"fail\" to automatically pass or fail the test: "
      searchTerm = STDIN.gets.chomp

      until searchTerm =~/\w/
        print ">>>Invalid input. Please enter a search term or \"auto\" followed by \"pass\" or \"fail\": "
        searchTerm = STDIN.gets.chomp
      end

      if searchTerm =~ /^(\s*(auto\s*(pass|fail))\s*)$/

        if searchTerm.include? "pass"
          logDebug("User auto passed ad testing. Test passed.", __FILE__, __LINE__, __method__)
          return @coeffMod
        end

        logDebug("User auto failed ad testing. Test failed.", __FILE__, __LINE__, __method__)
        return 0
      end

      logDebug("Current search term: \"#{searchTerm}\".", __FILE__, __LINE__, __method__)

      @driver.get "https://www.google.com/?gws_rd=ssl"
      sleep(1)

      input = @driver.find_element(:id, "lst-ib")
      input.send_keys(searchTerm)
      input.submit
      sleep(2)

      adTopCont, adRHSCont = findAdCont
      topAdFlag = searchAds(adTopCont, tmpURL)

      if topAdFlag == true
        return @coeffMod
      end

      rhsAdFlag = searchAds(adRHSCont, tmpURL)

      if rhsAdFlag == true
        return @coeffMod
      end

      searchNum = searchNum + 1
    end
  end

  def performTest
    tmpURL = @@url.gsub(/(http[s]?:\/\/(www\.)?)/, '').gsub(/(\/.*)/, '').downcase

    foundFlag = searchBiz(tmpURL)

    if foundFlag
      logDebug("Business name search: #{@@bizName} was successful. Test passed.", __FILE__, __LINE__, __method__)
      @score = @coeffMod
      writeScore
      return
    end

    logDebug("Business name search: #{@@bizName} was not successful. Moving to ad search.", __FILE__, __LINE__, __method__)
    @score = userSearch(tmpURL)
    #puts @score
    writeScore
  end

  def putLinks
    puts @@allLinks
  end	
end