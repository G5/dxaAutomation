require 'rubygems'
require 'selenium-webdriver'
require 'nokogiri'
require 'open-uri'
require 'open_uri_redirections'

require '../testClasses/testClass1'

require '../derClasses/brandClass1'
require '../derClasses/redirClass1'
require '../derClasses/contPPClass1'
require '../derClasses/lnkStrClass1'
require '../derClasses/urlStrClass1'
require '../derClasses/headTgClass1'
require '../derClasses/hUniqClass1'
require '../derClasses/altTxtClass1'
require '../derClasses/metaLoClass2'
require '../derClasses/titlTgClass1'
require '../derClasses/gPlusClass1'
require '../derClasses/gPCitClass1'
require '../derClasses/mobDesClass1'
require '../derClasses/enTrafClass1'
require '../derClasses/adCopClass1'
require '../derClasses/comPosClass2'
require '../derClasses/clrCTAClass1'
require '../derClasses/adsMSEClass1'
require '../derClasses/repManClass1'
require '../derClasses/webLSClass1'
require '../derClasses/splashClass1'
require '../derClasses/conGraClass1'
require '../derClasses/navLSClass1'
require '../derClasses/engImgClass1'
require '../derClasses/clInHeClass1'
require '../derClasses/scanCoClass1'
require '../derClasses/contReClass1'
require '../derClasses/flashClass1'
require '../derClasses/autoAVClass1'
require '../derClasses/ctaPrmClass1'
require '../derClasses/ctaEPClass1'
require '../derClasses/multChClass1'
require '../derClasses/onLeasClass1'
require '../derClasses/gCardClass1'
require '../derClasses/onPayClass1'
require '../derClasses/mobDPClass1'
require '../derClasses/mainRqClass1'
require '../derClasses/comCalClass1'
require '../derClasses/webAnClass1'
require '../derClasses/callTRClass1'
require '../derClasses/dynaPNClass1'

def badLink(href, mainURL)

  unless href =~ /(http[s]?:\/\/)?(www.)?.*[.]{1}(com|net|org)[\/]?(((.+[\/]?)*)$)/
    return true
  end

  if href =~ /(.css)/
    return true
  end 

  unless href =~ /(#{mainURL})/
    return true
  end

  return false
end 

def getAllLinks(driver, homePage)
  driver.get homePage
  sleep(3)
  links = []

  driver.find_elements(:xpath, "//*").each do |elem|
    href = elem.attribute("href").to_s
    
    if badLink(href, homePage)
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

def getObjList
  baseReq = ['rubygems']
  selTemp = baseReq + ['selenium-webdriver']
  nokoTemp = baseReq + ['nokogiri', 'open-uri', 'open_uri_redirections']

  objList = []

  objList << [BrandSearch, selTemp, "#1 Rank: Branded Search", 1] #0
  objList << [RedirTest, selTemp, "301 Redirect", 2] #1
  objList << [ContentPP, (selTemp + ['timeout', 'algorithms']), "Content Per Page", 3] #2
  objList << [LinkStruc, selTemp, "Link Structure", 4] #3
  objList << [TitleTTest, nokoTemp, "Title Tag Strategy", 5] #4
  objList << [URLStruc, nokoTemp, "URL Structure Strategy", 6] #5
  objList << [HeadTagsTest, (nokoTemp), :MULTIPLE, [7, 7]] #6
  objList << [HeadUnique, nokoTemp, "Unique Header Tags", 8] #7
  objList << [AltTxtTest, selTemp, "Image ALT Text", 9] #8
  objList << [MetaLoSearch, selTemp, "Meta Location Data", 10] #9
  objList << [GPlusTest, (selTemp + ['google_plus']), :MULTIPLE, [11, 11, 11]] #10
  objList << [GPCitation, (selTemp + ['google_plus']), :MULTIPLE, [12, 12]] #11
  objList << [MobDesTest, selTemp, "Mobile Site Design", 13] #12
  objList << [EnTrafClass, selTemp, "Designed to Engage Traffic", 14] #13
  objList << [AdCopClass, baseReq, "Ad Copy Specific to Market", 15] #14
  objList << [ComPosTest, selTemp, "Competitive Position", 16] #15
  objList << [ClearCTATest, selTemp, "Landing Page: Clear CTA's", 17] #16
  objList << [AdsOnMSE, [], "Ads on Multiple Search Engines", 18] #17
  objList << [RepManTest, selTemp, :MULTIPLE, [18, 18, 18]] #18
  objList << [PageSpeedTest, selTemp, "Website Load Speed", 19] #19
  objList << [SplashTest, selTemp, "Splash Page", 20] #20
  objList << [ConGraphTest, selTemp, "Consistent Graphic Elements", 21] #21
  objList << [NavBarLSTest, selTemp, "Navigation Location/Structure", 22] #22
  objList << [EngImgTest, selTemp, "Engaging Images", 23] #23
  objList << [ClearInfHeaders, ((selTemp + nokoTemp).uniq), "Clear and Informative Headers", 24] #24
  objList << [SCANContTest, selTemp, "SCAN able Content", 25] #25
  objList << [ContReadTest, selTemp, "Content Readability", 26] #26
  objList << [FlashTest, selTemp, "Elements of Flash", 27] #27
  objList << [AutoAudVid, selTemp, "Automatic Audio/Video", 28] #28
  objList << [CTAPromTest, selTemp, "Calls to Action: Prominent", 29] #29
  objList << [CTAEveryPage, selTemp, "Calls to Action on Every Page", 30] #30
  objList << [MultChanTest, selTemp, "Multiple Channels for Engagement", 31] #31
  objList << [OnLeaseTest, selTemp, "Online Leasing", 32] #32
  objList << [GCardTest, selTemp, "Guest Card Requirements", 33] #33
  objList << [OnPayTest, selTemp, "Online Payments", 34] #34
  objList << [MobPayTest, selTemp, "Mobile Device Payments", 35] #35
  objList << [MaintReqTest, selTemp, "Maintenance Requests", 36] #36
  objList << [ComCalTest, selTemp, "Community Calendar", 37] #37
  objList << [WebAnalytics, nokoTemp, "Website Analytics", 38] #38
  objList << [CallTrackTest, selTemp, "Call Tracking/Recording", 39] #38
  objList << [DynamicPhone, [], "Dynamic Phone Numbers", 40] #39
end

def runTests(objList, selDriver, nokoPage, url, bizName, gPlusID, allLinks, zipCode, fileName, logFile)
  puts '',"#{bizName.upcase}-->RUNNING TESTS:"
  test = nil
  adCopy = nil
  searchFlag, primLink, secLink = nil, nil, nil
  flashPres = false
  callTrack = false    
  selParam = :NOT_FOUND
  nokoParam = :NOT_FOUND

  for objNum in 0...objList.length
    objBlock = objList[objNum]
    currTest = nil
    test = objBlock[0]
    currTestName = objBlock[2]

    if objNum == 0
      currTest = test.new(objBlock[1], selDriver, :NOT_FOUND, objBlock[3], objBlock[2], fileName, logFile, url, bizName, gPlusID, allLinks, zipCode)
      currTest.performTest
      next
    end

    case objNum
    
    when 1..3, 8..13, 15..16, 18..37, 39
      selParam = selDriver
      nokoParam = :NOT_FOUND

    when 14, 38
      selParam = :NOT_FOUND
      nokoParam = nokoPage

    else
      selParam = :NOT_FOUND
      nokoParam = :NOT_FOUND
    end

    currTest = test.new(objBlock[1], selParam, nokoParam, objBlock[3], objBlock[2])

    begin

      if currTestName == "URL Structure Strategy"
        currTest.writeScore
        next
      end

      if currTestName == "Ad Copy Specific to Market"
        adCopy = currTest.performTest
        next
      end

      if currTestName == "Ads on Multiple Search Engines"
        currTest.performTest(adCopy)
        next
      end

      if currTestName == "Content Readability"
        flashPres = currTest.performTest
        next
      end

      if currTestName == "Automatic Audio/Video"
        currTest.setFlashFlag(flashPres)
      end

      if currTestName == "Online Payments"
        searchFlag, primLink, secLink = currTest.performTest
        next
      end

      if ["Online Payments", "Mobile Device Payments", "Maintenance Requests", "Community Calendar"].include? currTestName
        currTest.performTest(searchFlag, primLink, secLink)
        next
      end

      if currTestName == "Call Tracking/Recording"
        callTrack = (currTest.performTest.to_i > 0 ? true : false)
        next
      end

      if currTestName == "Dynamic Phone Numbers"
        currTest.performTest(callTrack)
        next
      end

      currTest.performTest

    rescue
      currTest.writeScore
      next
    end
  end
end

url = ARGV[0]
bizName = ARGV[1].split(",").join(" ")
gPlusID = ARGV[2].to_i
zipCode = ARGV[3]
fileName = ARGV[4]
logFile = ARGV[5]

driver = Selenium::WebDriver.for :firefox
pageSrc = Nokogiri::HTML(open(url))

unless pageSrc.encoding.to_s == 'utf-8'
  html = open(url)
  pageSrc = Nokogiri::HTML(html.read)
  pageSrc.encoding = 'utf-8'
end

allLinks = []
allLinks << url

begin
  
  getAllLinks(driver, url).each do |link|
    allLinks << link
  end

rescue
end

allLinks.uniq!

objList = getObjList
runTests(objList, driver, pageSrc, url, bizName, gPlusID, allLinks, zipCode, fileName, logFile)
puts

driver.close