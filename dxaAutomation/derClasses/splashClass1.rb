require '../testClasses/testClass1'

class SplashTest < TestClass
  
  def initialize(requirements, selDriver, nokoPage, scoreCoeff, testNam, fileNam=:DEFINED, logFil=:DEFINED, urlName=:DEFINED, bizNam=:DEFINED, gPlusI=:DEFINED, allLink=:DEFINED, zipCod=:DEFINED)
    super(requirements, selDriver, nokoPage, scoreCoeff, testNam, fileNam, logFil, urlName, bizNam, gPlusI, allLink, zipCod)

    #@testName = testNam
  end

  def findSplElems(elemPrec, attribPrec, elemTerms)
    validElems = []
    elemHash = Hash.new
    nextElem = false

    elemPrec.each do |elemType|
      
      @driver.find_elements(:tag_name, elemType).each do |foundElem|
        nextElem = false  
      
        attribPrec[elemType].each do |attrib|

          elemTerms[attrib].each do |term|
            #puts "#{elemType}-->#{attrib}-->#{term}"

            if (foundElem.attribute(attrib).to_s.downcase.delete(" ").include? term.downcase.delete(" ")) and (elemHash[foundElem] != :EXISTS)
              #puts "FOUND***************\n\n#{foundElem}-->#{attrib}-->#{term}-->#{foundElem.attribute(attrib)}\n\n"
              logDebug("Found splash element: #{foundElem} with tag name: #{elemType}, attribute: #{attrib}, and term: #{term}.", __FILE__, __LINE__)
              validElems << foundElem
              elemHash[foundElem] = :EXISTS
              nextElem = true
              break
            end
          end

          break if nextElem
        end 
      end
    end

    return validElems
  end

  def userDetermine
    print "The test has determined that the driver's current page is highly likely to be a splash page. Please enter \"yes\" or \"no\" as to whether you think it is a splash page: "
    input = STDIN.gets.chomp.downcase

    until input =~/^(\s*(yes|no)\s*)$/
      print "Invalid input. Please enter \"yes\" or \"no\" as to whether you think it is a splash page: "
      input = STDIN.gets.chomp.downcase
    end

    if input =~ /(yes)/
      logDebug("The user said that the current page was a splash page.", __FILE__, __LINE__, __method__)
      return 0
    end

    logDebug("The user said that the current page was not a splash page.", __FILE__, __LINE__, __method__)
    return 1
  end

  def performTest
    elemPrec = ["a", "input", "button", "section", "span"]

    attribPrec = Hash.new
    attribPrec["a"] = ["text", "value", "name"]
    attribPrec["input"] = ["name", "type", "value", "text"]
    attribPrec["button"] = ["text", "value", "name"]
    attribPrec["section"] = ["text", "name", "type", "value"]
    attribPrec["span"] = ["text", "value", "name"]

    elemTerms = Hash.new
    elemTerms["text"] = ["know more", "find out", "scroll", "click here", "get started", "starter", "learn more", "explore"]
    elemTerms["name"] = ["submit"]
    elemTerms["value"] = ["notify", "submit", "notify me"]
    elemTerms["type"] = ["submit"]

    @driver.get @@url
    sleep(5)

    potSplElems = findSplElems(elemPrec, attribPrec, elemTerms)# .each {|elem| print elem, "\n"}
    @score = @coeffMod

    if potSplElems.length >= 1
      logDebug("The program detected multiple page elements that are typically indicative of a splash page. Program will ask user whether it's a splash page or not.", __FILE__, __LINE__, __method__)
      @score = @coeffMod * userDetermine
    end
  
    writeScore
  end

  def putLinks
    puts @@allLinks
  end	
end