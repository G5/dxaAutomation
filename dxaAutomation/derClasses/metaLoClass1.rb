require '../testClasses/testClass1'

class MetaLoSearch < TestClass
  
  def initialize(requirements, selDriver, nokoPage, scoreCoeff, testNam, fileNam=:DEFINED, logFil=:DEFINED, urlName=:DEFINED, bizNam=:DEFINED, gPlusI=:DEFINED, allLink=:DEFINED, zipCod=:DEFINED)
    super(requirements, selDriver, nokoPage, scoreCoeff, testNam, fileNam, logFil, urlName, bizNam, gPlusI, allLink, zipCod)

    #@testName = testNam
  end

  def determineLink(links, precedence)

    precedence.each do |term|

      links.each do |link|
      
        if link =~ /(.com|.net|.org)\/.*#{term}/
          logDebug("Found map link: #{link}, with term: #{term}.", __FILE__, __LINE__, __method__)
          return link
        end  
      end
    end  

    return :NOT_FOUND
  end  

  def locateMapElement(potentialMaps)

    potentialMaps.each do |mapParent|

      mapParent.find_elements(:xpath, ".//*").each do |subElement|
      
        if subElement.attribute("src").to_s.include? "maps.gstatic.com"
          logDebug("On page: @link, found subelement: #{subElement} of element #{mapParent}, with \"maps.gstatic.com\" contained within the source.", __FILE__, __LINE__, __method__)
          return true
        end
      end
    end

    return false
  end

  def locateMapParent(precedence) # Locate navigation bar by html type.
    potentialMaps = []

    precedence.each do |htmlType|
      genericElemsSearch = @driver.find_elements(:xpath, stringToXPath(htmlType))
      
      genericElemsSearch.each do |foundElem| 
    
        if foundElem.attribute(htmlType).downcase.include? "map"
          
          potentialMaps << foundElem  
          #return foundElem
        end
      end
    end

    return potentialMaps
    # return nil 
  end

  def searchScripts(driver)
    
    driver.find_elements(:tag_name, "script").each do |script|

      return true if script.attribute("src").to_s.include? "maps.gstatic.com"
    end
    
    return false  
  end  

  def stringToXPath(term)
   
    return "//*[@#{term}]"
  end

  def performTest
    mapPrec = ["map", "directions", "neighborhood", "contact"]

    probLink = determineLink(@@allLinks, mapPrec)
    @score = 0
    hasMap = false

    unless probLink == :NOT_FOUND
      @driver.get probLink
      @link = probLink

      htmlPrec = ["id","class"]

      hasMap = locateMapElement(locateMapParent(htmlPrec))

      unless hasMap

        hasMap = searchScripts(@driver)
      end    
    end  

    @score = @coeffMod * (hasMap ? 1 : 0)

    writeScore
  end	

  def putLinks
    puts @@allLinks
  end	
end
