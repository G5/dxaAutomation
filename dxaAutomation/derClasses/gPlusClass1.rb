require '../testClasses/testClass1'

class GPlusTest < TestClass
  
  def initialize(requirements, selDriver, nokoPage, scoreCoeff, testNam, fileNam=:DEFINED, logFil=:DEFINED, urlName=:DEFINED, bizNam=:DEFINED, gPlusI=:DEFINED, allLink=:DEFINED, zipCod=:DEFINED)
    super(requirements, selDriver, nokoPage, scoreCoeff, testNam, fileNam, logFil, urlName, bizNam, gPlusI, allLink, zipCod)

    #@testName = testNam
  end

  def performTest
    coeffList = @coeffMod.dup

    GooglePlus.api_key = File.read('../keys/gPlusAPIKey.txt')
    person = GooglePlus::Person.get(@@gPlusID)

    @testName = "Google+ Owner Verified"
    initDebugFile
    @coeffMod = coeffList[0]
    logDebug("Google+ listing was #{(person.verified ? "" : "not ")}verified (test #{(person.verified ? "passed" : "failed")}).", __FILE__, __LINE__, __method__)
    @score = @coeffMod * (person.verified ? 1 : 0)
    writeScore

    @driver.get "https://plus.google.com/#{@@gPlusID}/about"
    sleep(2)

    hasSiteLink = false
    homeLink = @driver.find_elements(:class, "d-s")

    homeLink.each do |link|
      
      if (@@url.include? link.text) and (link.attribute("href").to_s.include? @@url) 
        hasSiteLink = true
        break
      end
    end

    @testName = "Google+ Link to Website"
    initDebugFile
    @coeffMod = coeffList[1]
    @score = @coeffMod * (hasSiteLink ? 1 : 0)
    logDebug("A link to your website on your Google+ page was #{(hasSiteLink ? "" : "not ")}found (test #{(hasSiteLink ? "passed" : "failed")}).", __FILE__, __LINE__, __method__)
    writeScore

      
    @driver.find_element(:id, "#{@@gPlusID}-photos-tab").click
    sleep(2)

    hasPhotos = true

    begin
      noPhotoMssg = @driver.find_element(:class, "Otc")
      
      if noPhotoMssg.text.include? "no photos"
        hasPhotos = false
      end 

    rescue
    end

    @testName = "Google+ Images/Video"
    initDebugFile
    @coeffMod = coeffList[2]
    @score = @coeffMod * (hasPhotos ? 1 : 0)
    logDebug("There were #{(hasPhotos ? "" : "no ")}photos on your Google+ page (test #{(hasPhotos ? "passed" : "failed")}).", __FILE__, __LINE__, __method__)
    writeScore
  end	

  def putLinks
    puts @@allLinks
  end	
end
