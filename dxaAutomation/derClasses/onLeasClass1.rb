require '../testClasses/testClass1'

class OnLeaseTest < TestClass
  
  def initialize(requirements, selDriver, nokoPage, scoreCoeff, testNam, fileNam=:DEFINED, logFil=:DEFINED, urlName=:DEFINED, bizNam=:DEFINED, gPlusI=:DEFINED, allLink=:DEFINED, zipCod=:DEFINED)
    super(requirements, selDriver, nokoPage, scoreCoeff, testNam, fileNam, logFil, urlName, bizNam, gPlusI, allLink, zipCod)
  end

  def badLink(href, mainURL, anyFlag)

    unless href =~ /(http[s]?:\/\/)?(www.)?.*[.]{1}(com|net|org)[\/]?(((.+[\/]?)*)$)/
      return true
    end

    if href =~ /(.css)/
      return true
    end 

    unless anyFlag
    
      unless href =~ /(#{mainURL})/
        return true
      end
    end

    return false
  end 

  def declareTables
    bTagOrder = ["a", "input", "button"]
    bHTMLOrder = ["class", "id", "type", "href", "name", "data-target", "data-load-msg", "data-action", "onclick", "value", "data-call-to-action"]

    bAttribTerms = Hash.new
    bAttribTerms["class"] = ["btn", "primary", "form", "js", "normal", "button", "submit", "success", "large", "right"]
    bAttribTerms["id"] = ["create", "app", "btn", "continue", "submit", "edit", "input"]
    bAttribTerms["type"] = ["submit"]
    bAttribTerms["href"] = ["#", "javascript", "void", "(0);"]
    bAttribTerms["name"] = ["submit", "save", "op"]
    bAttribTerms["data-target"] = ["create", "applicant"]
    bAttribTerms["data-load-msg"] = ["create"]
    bAttribTerms["data-action"] = ["submit"]
    bAttribTerms["onclick"] = ["javascript", "document", "create", "applicant", "submit"]
    bAttribTerms["value"] = ["save", "continue", "submit"]
    bAttribTerms["data-call-to-action"] = ["rent", "now"]

    sTagOrder = ["input", "submit"]
    sHTMLOrder = ["type", "class", "id", "value", "name"]

    sAttribTerms = Hash.new
    sAttribTerms["type"] = ["submit"]
    sAttribTerms["class"] = ["button", "btn", "push", "normal"]
    sAttribTerms["id"] = ["submit", "button", "btn"]
    sAttribTerms["value"] = ["submit", "continue"]
    sAttribTerms["name"] = ["submit", "continue", "index"]

    return bTagOrder, bHTMLOrder, bAttribTerms, sTagOrder, sHTMLOrder, sAttribTerms
  end

  def determineApp(links)
    terms = ["apply", "app", "application"]
    potAppLinks = []

    links.each do |link|
      
      terms.each do |term|
        
        if link.to_s.include? term
          logDebug("Found application link: #{link} in \"@@allLinks\" with term: #{term}.", __FILE__, __LINE__, __method__)
          potAppLinks << link
          break
        end
      end
    end

    if potAppLinks.length == 0
      logDebug("No application links found in \"@@allLinks\".", __FILE__, __LINE__, __method__)
      return :NOT_FOUND

    else
       logDebug("All application links found on page: #{potAppLinks}.", __FILE__, __LINE__, __method__)
      return potAppLinks
    end
  end

  def findApplyLink
    
    @driver.find_elements(:tag_name, "a").each do |anch|
      
      if anch.text.downcase.include? "apply" or anch.text.downcase.include? "application"
        logDebug("Found application link: #{anch.attribute("href").to_s}", __FILE__, __LINE__, __method__)
        return [anch.attribute("href").to_s]
      end
    end

    logDebug("Did not find application link.", __FILE__, __LINE__, __method__)
    return :NOT_FOUND
  end

  def findElems(tagOrder, htmlOrder, attribTerms, badButton)
    foundButtons = []
    buttonCount = 0

    tagOrder.each do |tag|

      @driver.find_elements(:tag_name, tag).each do |foundElem|
        nextElem = false

        htmlOrder.each do |htmlType| 
          
          attribTerms[htmlType].each do |term|

            if foundElem.attribute(htmlType).to_s.downcase.include? term

              if badButton
                
                unless foundElem.attribute("type") == ""
                  foundButtons << foundElem unless foundButtons.include? foundElem
                  buttonCount = buttonCount + 1
                end

                nextElem = true
                break

              else
                foundButtons << foundElem unless foundButtons.include? foundElem
                nextElem = true
                buttonCount = buttonCount + 1
                break
              end
            end
          end

          break if nextElem
        end
      end
    end

    return buttonCount
  end

  def findPDFs
    pdfNum = 0

    @driver.find_elements(:xpath, "//*").each do |elem|

      pdfNum = pdfNum + 1 if elem.attribute("href").to_s.include? ".pdf"
    end 

    return pdfNum
  end

  def findValInputs
    valInputNum = 0

    @driver.find_elements(:tag_name, "input").each do |input|

      valInputNum = valInputNum + 1 unless input.attribute("type").to_s.downcase == "hidden" 
    end

    return valInputNum
  end 

  def getAllLinks(homePage, anyFlag)
    @driver.get homePage
    logDebug("Current page is: #{@driver.current_url}", __FILE__, __LINE__, __method__)
    sleep(3)
    links = []

    @driver.find_elements(:xpath, "//*").each do |elem|
      href = elem.attribute("href").to_s
      
      if badLink(href, homePage, anyFlag)
        next
      end

      links << href
    end 

    links = links - [homePage]
    links = links - [homePage + '/']

    if links.length == 0
      raise "No links found on page."
    end 

    return links
  end 

  def testOnlinePay(link, bTagOrder, bHTMLOrder, bAttribTerms, sTagOrder, sHTMLOrder, sAttribTerms)
    @driver.get(link)
    sleep(1)
    logDebug("Current page is: #{@driver.current_url}", __FILE__, __LINE__, __method__)

    buttonNum = findElems(bTagOrder, bHTMLOrder, bAttribTerms, false)
    logDebug("Number of buttons found: #{buttonNum}.", __FILE__, __LINE__, __method__)

    inputNum = findValInputs
    logDebug("Number of inputs found: #{inputNum}.", __FILE__, __LINE__, __method__)

    selectNum = @driver.find_elements(:tag_name, "select").length
    logDebug("Number of select elements found: #{selectNum}.", __FILE__, __LINE__, __method__)

    pdfNum = findPDFs
    logDebug("Number of PDF\'s found: #{pdfNum}.", __FILE__, __LINE__, __method__)

    inputBNum = findElems(sTagOrder, sHTMLOrder, sAttribTerms, true)
    logDebug("Number of bad inputs found: #{inputBNum}.", __FILE__, __LINE__, __method__)
      
    if buttonNum > 0 or inputBNum > 0
      
      if (inputNum - inputBNum) > 3
        logDebug("Current page has a #{:INPUT_SUBMIT} submit scheme.", __FILE__, __LINE__, __method__)
        return :INPUT_SUBMIT
      
      else
        
        if selectNum > 0
          logDebug("Current page has a #{:SELECT_SUBMIT} submit scheme.", __FILE__, __LINE__, __method__)
          return :SELECT_SUBMIT

        else
          logDebug("Current page has a #{:BAD_INPUT} submit scheme.", __FILE__, __LINE__, __method__)
          return :BAD_INPUT
        end
      end

    else

      if pdfNum > 0
        logDebug("Current page has a #{:PDF} submit scheme.", __FILE__, __LINE__, __method__)
        return :PDF

      else
        logDebug("Current page has a #{:NONE} submit scheme.", __FILE__, __LINE__, __method__)
        return :NONE
      end
    end
  end

  def performTest
    @driver.get @@url
    sleep(1)
    logDebug("Current page is: #{@driver.current_url}", __FILE__, __LINE__, __method__)
    applyLink = findApplyLink

    if applyLink == :NOT_FOUND
      applyLink = determineApp(@@allLinks)
    end

    if applyLink == :NOT_FOUND
      @score = 0
      writeScore
      return
    end

    bTagOrder, bHTMLOrder, bAttribTerms, sTagOrder, sHTMLOrder, sAttribTerms = declareTables
    onlinePay = :NONE

    applyLink.each do |link|
      onlinePay = testOnlinePay(link, bTagOrder, bHTMLOrder, bAttribTerms, sTagOrder, sHTMLOrder, sAttribTerms)

      case onlinePay

      when :INPUT_SUBMIT
        appendScore(1.0)

      when :SELECT_SUBMIT
        appendScore(0.5)

      when :BAD_INPUT
        appendScore(0.5)

      when :PDF
        appendScore(0.5)

      when :NONE
        appendScore(0.0)

      else
        appendScore(0.0)
      end 
    end

    logDebug("Using the worst scheme for scoring, the score is: #{getMin}.", __FILE__, __LINE__, __method__)
    @score = getMin * @coeffMod
    writeScore
  end

  def putLinks
    puts @@allLinks
  end	
end