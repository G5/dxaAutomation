require '../testClasses/testClass1'

class NavBarLSTest < TestClass
  
  def initialize(requirements, selDriver, nokoPage, scoreCoeff, testNam, fileNam=:DEFINED, logFil=:DEFINED, urlName=:DEFINED, bizNam=:DEFINED, gPlusI=:DEFINED, allLink=:DEFINED, zipCod=:DEFINED)
    super(requirements, selDriver, nokoPage, scoreCoeff, testNam, fileNam, logFil, urlName, bizNam, gPlusI, allLink, zipCod)
  end

  def findNavBarLinks(navBars, mainURL)
    hasLinks = false
    validURLs = []

    navBars.each do |navBar|
    
      navBar.find_elements(:xpath, ".//*").each do |element|  
        elemStr = element.attribute("href").to_s

        unless elemStr == ""
          validURLs << elemStr
          hasLinks = true unless hasLinks
        end
      end

      if hasLinks
        siftBadLinks(validURLs, mainURL)
        logDebug("Found links: #{validURLs} within navigation bar: #{navBar}. Returning urls.", __FILE__, __LINE__, __method__)
        return validURLs
      end
    end

    logDebug("No links found withing navigation bars: #{navBars}.", __FILE__, __LINE__, __method__)
    raise
  end

  def findLinksInElem(element, mainURL)
    logDebug("Attempting to find links in element: #{element}.", __FILE__, __LINE__, __method__)
    validURLs = []
    
    element.find_elements(:xpath, ".//*").each do |child|
      childHREF = child.attribute("href").to_s

      unless childHREF == ""

        unless childHREF =~ /(index.[a-z]{2,5}[\s]*)$/

          unless childHREF =~ /(\(0\);)|(#)|(.gov)/

            if (childHREF =~ /(http[s]?:\/\/)/) or (childHREF =~ /((.com[\/]?[\s]*)$)|((.net[\/]?[\s]*)$)|((.org[\/]?[\s]*)$)/) 

              validURLs << childHREF
            end  
          end
        end  
      end
    end
    
    if validURLs.length == 0
      logDebug("Did not find any links in element: #{element}. Continuing search.", __FILE__, __LINE__, __method__)
      return nil
    end

    logDebug("Found urls: #{validURLs}, within element: #{element}. Returning array.", __FILE__, __LINE__, __method__)
    return validURLs
  end

  def locateNavBar(driver, mainURL, precedence, wordList, searchNum)
    genericElemsSearch = nil
    potentialNavBars = nil
    logDebug("Performing a #{(searchNum == 1 ? "primary" : "secondary")} search to try and find the navigation bar.", __FILE__, __LINE__, __method__)

    genericElemsSearch = [] if searchNum == 1
    potentialNavBars = [] if searchNum == 2

    precedence.each do |htmlType|
      genericElemsSearch = driver.find_elements(:xpath, stringToXPath(htmlType))
      
      genericElemsSearch.each do |foundElem| 
        tryNewElem = false
    
        wordList.each do |keyword| 

          if foundElem.attribute(htmlType).downcase.include? keyword 
            
            if searchNum == 1
              
              unless findLinksInElem(foundElem, mainURL) == nil
                logDebug("Found navigation bar: #{foundElem} in primary search with tag name: #{htmlType}, and term: #{keyword}.", __FILE__, __LINE__, __method__)
                return foundElem 

              else
                tryNewElem = true
                break
              end
            end

            if searchNum == 2
              parent = foundElem.find_element(:xpath, "..")

              unless potentialNavBars.include? parent
                logDebug("Found potential parent of navigation bar: #{parent}", __FILE__, __LINE__, __method__)
                potentialNavBars << parent
              end
            end

            break if tryNewElem
          end
        end  
      end
    end

    if searchNum == 2
      logDebug("All potential parents found during search: #{potentialNavBars}.", __FILE__, __LINE__, __method__)
      return potentialNavBars 
    end

    return nil 
  end

  def siftBadLinks(links, mainURL)
    links.delete("")
    links.delete(mainURL)

    badLinkAttributes = ["#", "index", "(0);", ".gov"]

    links.each do |link|

      unless link..is_a?(String)
        links.delete(link)
        next
      end

      unless link.include? "http" or link.include? ".com"
        links.delete(link)
        next
      end
      
      badLinkAttributes.each do |attribute|

        if link.include? attribute
          links.delete(link)
          next
        end
      end
    end
  end

  def stringToXPath(term)
   
    return "//*[@#{term}]"
  end

  def performTest
    mainURL = @@url

    driver = @driver
    driver.get mainURL

    sleep(1) 

    elemPrecedence1 = ["class", "id","li"]
    elemPrecedence2 = ["ul", "p", "alt", "li", "area"] 
    navContainsList = ["nav", "menu"]
    navKeyWordList = ["home", "floor", "plans", "contact", "amenities", "resident", "appl", "directions", "community", "news", "move"]

    navBarSearch = locateNavBar(driver, mainURL, elemPrecedence1, navContainsList, 1)
    firstSearchWorked = true

    unless navBarSearch
      navBarSearch = locateNavBar(driver, mainURL, elemPrecedence2, navKeyWordList, 2)
      firstSearchWorked = false
    end

    validURLs = []

    if firstSearchWorked
      logDebug("Finding links in navigation bar elements resulting from primary search.", __FILE__, __LINE__, __method__)
      validURLs = findLinksInElem(navBarSearch, mainURL)

    else
      
      begin
        logDebug("Finding links in navigation bar parents resulting from secondary search.", __FILE__, __LINE__, __method__)
        validURLs = findNavBarLinks(navBarSearch, mainURL)
        
      rescue
        logDebug("No links could be found in navigation bar parents.", __FILE__, __LINE__, __method__)
        @score = 0
        writeScore
        return 
      end  
    end

    validURLs = validURLs.uniq

    if validURLs.include? mainURL
      validURLs[validURLs.index(mainURL)] = ""
    end

    if validURLs.include? (mainURL + '/')
      validURLs[validURLs.index((mainURL + '/'))] = ""
    end

    validURLs = validURLs - [""]

    logDebug("There #{(validURLs.length >= 6 ? "are" : "aren\'t")} enough urls in the navigation bar to pass. Test #{(validURLs.length >= 6 ? "passed" : "failed")}.", __FILE__, __LINE__, __method__)
    @score = @coeffMod * (validURLs.length >= 6 ? 1 : 0)
    writeScore
  end

  def putLinks
    puts @@allLinks
  end	
end