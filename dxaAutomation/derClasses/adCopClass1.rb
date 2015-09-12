require '../testClasses/testClass1'

class AdCopClass < TestClass
  
  def initialize(requirements, selDriver, nokoPage, scoreCoeff, testNam, fileNam=:DEFINED, logFil=:DEFINED, urlName=:DEFINED, bizNam=:DEFINED, gPlusI=:DEFINED, allLink=:DEFINED, zipCod=:DEFINED)
    super(requirements, selDriver, nokoPage, scoreCoeff, testNam, fileNam, logFil, urlName, bizNam, gPlusI, allLink, zipCod)
  end

  def performTest
    adsense = false

    @page.xpath("//script").to_s.split(/(\<[\/]?script\>)/).each do |script|
      
      if (script.include? "googlesyndication") or (script.include? "doubleclick") or (script.include? "bat.js")
        adsense = true
        break
      end 
    end

    logDebug("There was #{(adsense ? "" : "no")} adsense found in the page source. Test #{(adsense ? "passed" : "failed")}.", __FILE__, __LINE__, __method__)

    @score = @coeffMod * (adsense ? 1 : 0)
    writeScore
    return adsense
  end

  def putLinks
    puts @@allLinks
  end	
end