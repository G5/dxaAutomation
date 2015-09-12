#require './testClass1'
require '../testClasses/testClass1'

class GCardTest < TestClass
  
  def initialize(requirements, selDriver, nokoPage, scoreCoeff, testNam, fileNam=:DEFINED, logFil=:DEFINED, urlName=:DEFINED, bizNam=:DEFINED, gPlusI=:DEFINED, allLink=:DEFINED, zipCod=:DEFINED)
    super(requirements, selDriver, nokoPage, scoreCoeff, testNam, fileNam, logFil, urlName, bizNam, gPlusI, allLink, zipCod)
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

  def determineCon(links)
    terms = ["contact", "contact us"]
    potAppLinks = []

    links.each do |link|
      
      terms.each do |term|
        
        if link.to_s.include? term
          potAppLinks << link
          break
        end
      end
    end

    if potAppLinks.length == 0
      logDebug("No links were found amongst \"@@allLinks\" with the terms: #{terms}.", __FILE__, __LINE__, __method__)
      return :NOT_FOUND

    else
      logDebug("Matched links amongst \"@@allLinks\" with terms: #{terms}, are: #{potAppLinks}", __FILE__, __LINE__, __method__)
      return potAppLinks
    end
  end

  def findContactLink
    
    @driver.find_elements(:tag_name, "a").each do |anch|
      
      if anch.text.downcase.include? "contact"
        logDebug("On home page: #{@@url}, found contact link: #{anch.attribute("href").to_s}.", __FILE__, __LINE__, __method__)
        return [anch.attribute("href").to_s]
      end
    end

    logDebug("On home page: #{@@url}, did not find contact link (test failed).", __FILE__, __LINE__, __method__)
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

  def testOnlinePay(link, bTagOrder, bHTMLOrder, bAttribTerms, sTagOrder, sHTMLOrder, sAttribTerms)
    @driver.get(link)

    buttonNum = findElems(bTagOrder, bHTMLOrder, bAttribTerms, false)
    logDebug("Buttons found on page: #{buttonNum}", __FILE__, __LINE__, __method__)

    inputNum = findValInputs
    logDebug("Input elements found on page: #{buttonNum}", __FILE__, __LINE__, __method__)
    
    selectNum = @driver.find_elements(:tag_name, "select").length
    logDebug("Select elements found on page: #{buttonNum}", __FILE__, __LINE__, __method__)

    pdfNum = findPDFs
    logDebug("PDF's found on page: #{buttonNum}", __FILE__, __LINE__, __method__)

    inputBNum = findElems(sTagOrder, sHTMLOrder, sAttribTerms, true)
    logDebug("Bad input elements found on page: #{buttonNum}", __FILE__, __LINE__, __method__)
      
    if buttonNum > 0 or inputBNum > 0
  
      if (inputNum - inputBNum) > 3
        logDebug("The link has a #{:INPUT_SUBMIT} scheme for its guest card.", __FILE__, __LINE__, __method__)
        return :INPUT_SUBMIT

      else
        
        if selectNum > 0
          return :SELECT_SUBMIT
          logDebug("The link has a #{:SELECT_SUBMIT} scheme for its guest card.", __FILE__, __LINE__, __method__)

        else
          logDebug("The link has a #{:BAD_INPUT} scheme for its guest card.", __FILE__, __LINE__, __method__)
          return :BAD_INPUT
        end
      end

    else

      if pdfNum > 0
        logDebug("The link has a #{:PDF} scheme for its guest card.", __FILE__, __LINE__, __method__)
        return :PDF

      else
        logDebug("The link does not have guest card requirements.", __FILE__, __LINE__, __method__)
        return :NONE
      end
    end
  end

  def performTest
    @driver.get @@url
    contactLinks = findContactLink

    if contactLinks == :NOT_FOUND
      contactLinks = determineCon(@@allLinks)
    end

    if contactLinks == :NOT_FOUND
      @score = 0
      writeScore
      return
    end

    bTagOrder, bHTMLOrder, bAttribTerms, sTagOrder, sHTMLOrder, sAttribTerms = declareTables
    onlinePay = :NONE

    contactLinks.each do |link|
      logDebug("Looping through links to determine guest card application scheme. Current link: #{@link}", __FILE__, __LINE__, __method__)
      onlinePay = testOnlinePay(link, bTagOrder, bHTMLOrder, bAttribTerms, sTagOrder, sHTMLOrder, sAttribTerms)

      case onlinePay

      when :INPUT_SUBMIT
        appendScore(1.0)

      when :SELECT_SUBMIT
        appendScore(0.5)

      when :BAD_INPUT
        appendScore(0.5)

      when :PDF
        appendScore(0.25)

      when :NONE
        appendScore(0.0)

      else
        appendScore(0.0)
      end 
    end

    logDebug("Using the worst submit-scheme found, the final score is: #{getMin}/1.0.", __FILE__, __LINE__, __method__)
    @score = getMin * @coeffMod
    writeScore
  end

  def putLinks
    puts @@allLinks
  end	
end