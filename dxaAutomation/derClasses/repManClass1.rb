require '../testClasses/testClass1'

class RepManTest < TestClass
  
  def initialize(requirements, selDriver, nokoPage, scoreCoeff, testNam, fileNam=:DEFINED, logFil=:DEFINED, urlName=:DEFINED, bizNam=:DEFINED, gPlusI=:DEFINED, allLink=:DEFINED, zipCod=:DEFINED)
    super(requirements, selDriver, nokoPage, scoreCoeff, testNam, fileNam, logFil, urlName, bizNam, gPlusI, allLink, zipCod)
  end

  def performTest
    coeffList = @coeffMod
    
    print "\n>>>Please enter the Reputation Manager API Key for the business. If this business does not have an API key then enter \"none\": "
    input = STDIN.gets.chomp.delete(" ")

    until input =~ /^((([a-zA-Z]|\d){10,30})|none)$/
      print "Invalid input. Please enter a key consisting of only letters (uppercase and lowercase) and numbers that is in between 10 and 30 characters, or \"none\" if the business does not have a Reputation Manager API Key: "
      input = STDIN.gets.chomp.delete(" ")
    end

    if input.include? "none"
      @score = 0
      writeScore
      return
    end

    repManInf = Nokogiri::HTML(open("https://reputation.g5search.com/api/locations/8089?api_key=#{repAPIKey}")).to_s
    repManInf = JSON.parse(repManInf[repManInf.index('{')..repManInf.rindex('}')])

    repManHash = repManInf["business_listings"]
    scoreHash = Hash.new

    for i in 0...repManHash.length
      scoreHash[repManHash[i]["reputation_site"]] = repManHash[i]["reputation_score"].to_i
    end

    @testName = "Google+"
    initDebugFile
    gPlusScore = (scoreHash["Google+"] == nil ? 0 : scoreHash["Google+"])
    logDebug("Google+ score read: #{gPlusScore}.", __FILE__, __LINE__, __method__)
    @coeffMod = coeffList[0]
    @score = @coeffMod * (gPlusScore.to_f / 100.0)
    writeScore
    
    @testName = "ApartmentRatings"
    initDebugFile
    aptRateScore = (scoreHash["ApartmentRatings"] == nil ? 0 : scoreHash["ApartmentRatings"])
    logDebug("ApartmentRatings score read: #{aptRateScore}.", __FILE__, __LINE__, __method__)
    @coeffMod = coeffList[1]
    @score = @coeffMod * (aptRateScore.to_f / 100.0)
    writeScore
    
    @testName = "Yelp"
    initDebugFile
    yelpScore = (scoreHash["Yelp"] == nil ? 0 : scoreHash["Yelp"])
    logDebug("Yelp score read: #{yelpScore}", __FILE__, __LINE__, __method__)
    @coeffMod = coeffList[2]
    @score = @coeffMod * (yelpScore.to_f / 100.0)
    writeScore
  end

  def putLinks
    puts @@allLinks
  end	
end