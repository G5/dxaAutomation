require '../testClasses/testClass1'

class CallTrackTest < TestClass
  
  def initialize(requirements, selDriver, nokoPage, scoreCoeff, testNam, fileNam=:DEFINED, logFil=:DEFINED, urlName=:DEFINED, bizNam=:DEFINED, gPlusI=:DEFINED, allLink=:DEFINED, zipCod=:DEFINED)
    super(requirements, selDriver, nokoPage, scoreCoeff, testNam, fileNam, logFil, urlName, bizNam, gPlusI, allLink, zipCod)
  end

  def askForAds
    print "\n>>>Do you wish to continue to google ads testing? Please enter \"yes\" or \"no\": "
    option = STDIN.gets.chomp

    until option =~ /^(\s*(yes|no)\s*)$/
      print ">>>Invalid input. Please enter \"yes\" or \"no\": "
      option = STDIN.gets.chomp
    end

    if option.include? "yes"
      logDebug("After the search term was attempted, user requested to continue to ad search section.", __FILE__, __LINE__, __method__)

      return :AD_SEARCH
    end

    logDebug("After the search was attempted, user requested to not continue to ad search section. Test failed.", __FILE__, __LINE__, __method__)
    return :NO_AD_SEARCH
  end

  def findAdCont

    begin
      adTopCont = @driver.find_element(:id, "tads")
      logDebug("Top banner ads found successfully.", __FILE__, __LINE__, __method__)

    rescue
      logDebug("No ad elements in top banner.", __FILE__, __LINE__, __method__)
      adTopCont = :NONE
    end

    begin
      adRHSCont = @driver.find_element(:id, "rhs_block")
      logDebug("Right hand side banner ads found successfully.", __FILE__, __LINE__, __method__)

    rescue
      logDebug("No ad elements in right hand side banner.", __FILE__, __LINE__, __method__)
      adRHSCont = :NONE
    end

    return adTopCont, adRHSCont
  end

  def findMatch(tmpURL, phoneNums, adTopCont, adRHSCont)

    unless adTopCont == :NONE

      begin

        adTopCont.find_elements(:class, "ads-ad").each do |topAd|
          logDebug("Looping through top ad container with ad \##{adTopCont.find_elements(:class, "ads-ad").index(topAd)}: #{topAd}", __FILE__, __LINE__, __method__)
          adURL = getAdURL(topAd)

          unless adURL.include? tmpURL
            logDebug("Ad element #{topAd} url: \"#{adURL}\" did not contain desired url: \"#{tmpURL}\". Going to next element.", __FILE__, __LINE__, __method__)
            next
          end

          adPNum1 = getAdPhone1(topAd)

          unless adPNum1 == :NOT_FOUND
            logDebug("Phone number: \"#{adPNum1}\" found in ad: #{topAd}.", __FILE__, __LINE__, __method__)

            unless matchNums(phoneNums, adPNum1)
              logDebug("There was no match between: \"#{adPNum1}\", and #{phoneNums}. Therefore, a call tracking number was used.", __FILE__, __LINE__, __method__)
              @score = @coeffMod
              return true
            end
          end

          adPNum2 = getAdPhone2(topAd)

          unless adPNum2 == :NOT_FOUND
            logDebug("Phone number: \"#{adPNum2}\" found in ad: #{topAd}.", __FILE__, __LINE__, __method__)

            unless matchNums(phoneNums, adPNum2)
              logDebug("There was no match between: \"#{adPNum2}\", and #{phoneNums}. Therefore, a call tracking number was used. Test passed.", __FILE__, __LINE__, __method__)
              @score = @coeffMod
              return true
            end
          end

          @score = 0
          logDebug("There was a match between: \"#{adPNum2}\", and #{phoneNums}. Therefore, a call tracking number was not used. Test failed.", __FILE__, __LINE__, __method__)
          return true
        end

      rescue 
        logDebug("An error occured while trying to locate ads within top ad container.", __FILE__, __LINE__, __method__)
      end
    end

    unless adRHSCont == :NONE

      begin

        adRHSCont.find_elements(:class, "ads-ad").each do |rhsAd|
          logDebug("Looping through right hand side ad container with ad \##{adRHSCont.find_elements(:class, "ads-ad").index(rhsAd)}: #{rhsAd}", __FILE__, __LINE__, __method__)
          adURL = getAdURL(rhsAd)

          unless adURL.include? tmpURL
            logDebug("Ad element #{rhsAd} url: \"#{adURL}\" did not contain desired url: \"#{tmpURL}\". Going to next element.", __FILE__, __LINE__, __method__)
            next
          end

          adPNum1 = getAdPhone1(topAd)

          unless adPNum1 == :NOT_FOUND
            logDebug("Phone number: \"#{adPNum1}\" found in ad: #{rhsAd}.", __FILE__, __LINE__, __method__)

            unless matchNums(phoneNums, adPNum1)
              logDebug("There was no match between: \"#{adPNum1}\", and #{phoneNums}. Therefore, a call tracking number was used. Test passed.", __FILE__, __LINE__, __method__)
              @score = @coeffMod
              return true
            end
          end

          logDebug("There was a match between: \"#{adPNum1}\", and #{phoneNums}. Therefore, a call tracking number was not used. Test failed.", __FILE__, __LINE__, __method__)
          @score = 0
          return true
        end

      rescue 
        logDebug("An error occured while trying to locate ads within the right hand side ad container.", __FILE__, __LINE__, __method__)
      end
    end

    logDebug("Could not find any listings that belong to the desired business.", __FILE__, __LINE__, __method__)
    return false
  end

  def getAdPhone1(ad)
    phoneNum = nil

    begin
      phoneNum = ad.find_element(:class, "_r2b").text.delete(" ").tr('().-', '')
      logDebug("The element with class: \"_r2b\" was located successfully.", __FILE__, __LINE__, __method__)

    rescue
      logDebug("The element with class: \"_r2b\" could not be located.", __FILE__, __LINE__, __method__)
      return :NOT_FOUND
    end

    return phoneNum
  end

  def getAdPhone2(ad)
    phoneNum = nil

    begin
      phoneNum = ad.find_element(:class, "_xnd").text.delete(" ").tr('().-', '')
      logDebug("The element with class: \"_xnd\" was located successfully.", __FILE__, __LINE__, __method__)

    rescue
      logDebug("The element with class: \"_xnd\" could not be located.", __FILE__, __LINE__, __method__)
      return :NOT_FOUND
    end

    return phoneNum
  end
  
  def getAdURL(ad)
    
    begin
      url = ad.find_element(:tag_name, "cite").text.downcase

    rescue
      logDebug("Could not get ad url for element: #{ad}", __FILE__, __LINE__, __method__)
      return :NOT_FOUND
    end

    return url
  end

  def getListings(phoneNums)
    tmpURL = @@url.gsub(/(http[s]?:\/\/(www\.)?)/, '').gsub(/(\/.*)/, '').downcase
    searchNum = 1
    puts "\n>>>Now, the program will search google ads for call tracking numbers."

    loop do
      print "\n>>>Attempt #{searchNum}: Please enter a search term to generate ads for the selected site. Additionally you may enter \"auto\" followed by \"pass\" or \"fail\" to automatically pass or fail the test: "
      searchTerm = STDIN.gets.chomp

      until searchTerm =~/\w/
        print ">>>Invalid input. Please enter a search term or \"auto\" followed by \"pass\" or \"fail\": "
        searchTerm = STDIN.gets.chomp
      end

      if searchTerm =~ /^(\s*(auto\s*(pass|fail))\s*)$/

        if searchTerm.include? "pass"
          logDebug("User chose to auto pass the Google ads portion of the test.", __FILE__, __LINE__, __method__)
          @score = @coeffMod

        else
          logDebug("User chose to auto fail the Google ads portion of the test.", __FILE__, __LINE__, __method__)
          @score = 0
        end
        
        return
      end

      logDebug("Current search term: \"#{searchTerm}\".", __FILE__, __LINE__, __method__)

      @driver.get "https://www.google.com/?gws_rd=ssl"
      sleep(1)

      input = @driver.find_element(:id, "lst-ib")
      input.send_keys(searchTerm)
      input.submit
      sleep(2)

      adTopCont, adRHSCont = findAdCont

      if findMatch(tmpURL, phoneNums, adTopCont, adRHSCont)
        return
      end

      searchNum = searchNum + 1
    end
  end

  def getPhoneNums
    @driver.get @@url
    sleep(2)
    phoneNums = []

    @driver.find_elements(:xpath, "//*").each do |elem|
      phoneScan = elem.text.scan(/(\d{3}\)?\s?\.?-?\s?\d{3}\s?\.?-?\s?\d{4})/)

      unless phoneScan.length == 0
        phNum = phoneScan[0][0].delete(" ").tr(").-", '')
        
        unless phoneNums.include? phNum
          phoneNums << phNum
        end
      end
    end

    if phoneNums.length == 0
      logDebug("No phone numbers were found on the SERP.", __FILE__, __LINE__, __method__)
      return :NO_PHONE_NUM
    end

    logDebug("Phone numbers found on the SERP: #{phoneNums}", __FILE__, __LINE__, __method__)
    return phoneNums
  end

  def getSERP(phoneNums)
    tmpURL = @@url.gsub(/(http[s]?:\/\/(www\.)?)/, '').gsub(/(\/.*)/, '').downcase
    searchNum = 1

    loop do
      print "\n>>>Attempt #{searchNum}: Please enter a search term to generate your site as the first on a Google SERP. Additionally you may enter \"auto\" followed by \"pass\" or \"fail\" to automatically pass or fail the test: "
      searchTerm = STDIN.gets.chomp

      until searchTerm =~ /\w/
        print ">>>Invalid input. Please enter a search term or \"auto\" followed by \"pass\" or \"fail\": "
        searchTerm = STDIN.gets.chomp
      end

      if searchTerm =~ /^(\s*(auto\s*(pass|fail))\s*)$/

        if searchTerm.include? "pass"
          @score = @coeffMod
          logDebug("Auto pass option selected. Test passed.", __FILE__, __LINE__, __method__)
          return :NO_AD_SEARCH

        else
          @score = 0
          logDebug("Auto fail option selected. User asked if he/she desires to continue to ads searching. Test failed.", __FILE__, __LINE__, __method__)

          return askForAds
        end
      end

      logDebug("Current search term: \"#{searchTerm}\"", __FILE__, __LINE__, __method__)

      @driver.get "https://www.google.com/?gws_rd=ssl"
      sleep(1)

      input = @driver.find_element(:id, "lst-ib")
      input.send_keys(searchTerm)
      input.submit
      sleep(2)

      if testFirstRes(tmpURL, phoneNums)

        if @score == 0
          logDebug("Call tracking number was not found. User asked if he/she desires to continue to ads searching.", __FILE__, __LINE__, __method__)
          return askForAds
        end

        logDebug("Call tracking number was found.", __FILE__, __LINE__, __method__)
        return :NO_AD_SEARCH
      end

      searchNum = searchNum + 1
    end
  end

  def matchNums(phoneNums, listedPhone)

    phoneNums.each do |phoneNum|

      if phoneNum == listedPhone
        logDebug("There was a match in the phone number list #{phoneNums} and the phone number \"#{listedPhone}\".", __FILE__, __LINE__, __method__)
        return true
      end
    end  

    logDebug("There was no match in the phone number list #{phoneNums} and the phone number \"#{listedPhone}\".", __FILE__, __LINE__, __method__)
    return false
  end

  def testFirstRes(tmpURL, phoneNums)
    firstRes = nil
    firstURL = nil
    
    begin
      firstRes = @driver.find_element(:class, "srg").find_element(:class, "g")
      firstURL = firstRes.find_element(:tag_name, "cite").text

      unless firstURL.include? tmpURL
        print "\n>>>The first result does not belong to your business. Please try another search term."
        logDebug("The SERP top result did not belong to the desired business.", __FILE__, __LINE__, __method__)
        return false
      end

    rescue
      print "\n>>>Could not recognize results. Please try a new search term."
      logDebug("The SERP top result could not be located.", __FILE__, __LINE__, __method__)
      return false
    end

    begin
      listedPhone = firstRes.find_element(:tag_name, "nobr").text.delete(" ").tr('()-.', '')

      unless matchNums(phoneNums, listedPhone)
        @score = @coeffMod
        #puts 25
        return true
      end

      @score = 0
      return true

    rescue
      print "\n>>>Could not get phone number from first element. Please try again. If you wish to continue to ad search, please auto pass/fail this test and choose to continue when prompted."
      logDebug("The SERP top result did not have a phone number.", __FILE__, __LINE__, __method__)
      return falses
    end
  end

  def performTest
    phoneNums = getPhoneNums

    if phoneNums == :NO_PHONE_NUM
      @score = 0
      writeScore
      return @score
    end

    if getSERP(phoneNums) == :NO_AD_SEARCH

      writeScore
      return @score
    end

    getListings(phoneNums)
    writeScore
    return @score
  end

  def putLinks
    puts @@allLinks
  end	
end