require '../testClasses/testClass1'

class AltTxtTest < TestClass
  
  def initialize(requirements, selDriver, nokoPage, scoreCoeff, testNam, fileNam=:DEFINED, logFil=:DEFINED, urlName=:DEFINED, bizNam=:DEFINED, gPlusI=:DEFINED, allLink=:DEFINED, zipCod=:DEFINED)
    super(requirements, selDriver, nokoPage, scoreCoeff, testNam, fileNam, logFil, urlName, bizNam, gPlusI, allLink, zipCod)
  end

  def performTest
    initDebugFile

    @@allLinks.each do |link|
      @driver.get link
      logDebug("Current page: #{link}", __FILE__, __LINE__, __method__)
      images = @driver.find_elements(:tag_name, "img")

      if images.length == 0
        logDebug("No images found on page.", __FILE__, __LINE__, __method__)
        next
      end

      altTextRatio = 0

      images.each do |image|
        imageAlt = image.attribute("alt").to_s

        unless imageAlt =~ /[a-zA-Z]/
          next
        end

        if imageAlt.downcase.include? @@bizName.downcase
          next
        end  

        altTextRatio = altTextRatio + 1 
      end

      appendScore((altTextRatio.to_f / images.length) >= 0.75 ? 1 : 0)
      logDebug("Image ratio on page was: #{(altTextRatio.to_f / images.length)}", __FILE__, __LINE__, __method__)
    end

    @score = getAverage * @coeffMod
    writeScore
  end	

  def putLinks
    puts @@allLinks
  end	
end