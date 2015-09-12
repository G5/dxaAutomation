require '../testClasses/testClass1'

class EnTrafClass < TestClass
  
  def initialize(requirements, selDriver, nokoPage, scoreCoeff, testNam, fileNam=:DEFINED, logFil=:DEFINED, urlName=:DEFINED, bizNam=:DEFINED, gPlusI=:DEFINED, allLink=:DEFINED, zipCod=:DEFINED)
    super(requirements, selDriver, nokoPage, scoreCoeff, testNam, fileNam, logFil, urlName, bizNam, gPlusI, allLink, zipCod)
  end

  def performTest
    @driver.get @@url
    sleep(2)

    print "\n>>>Is this page designed to engage traffic (please answer \"yes\" or \"no\", or provide a number between 1 and 10 to describe it's effectiveness in engaging site traffic)? "
    input = STDIN.gets.chomp.downcase

    until input =~ /^(\s*((yes|no)|(\d*((\.)\d*)?))\s*)$/ and (input =~ /\S/)
      print ">>>Invalid input. Enter \"yes\" or \"no\", or provide a number between 1 and 10: "
      input = STDIN.gets.chomp.downcase
    end

    input = input.delete(" ")

    if input =~ /(yes|no)/
    
      if input =~ /(yes)/
        logDebug("On the home page: #{@@url}, the user said that the page was designed to engage traffic.", __FILE__, __LINE__, __method__)
        @score = @coeffMod

      else
        logDebug("On the home page: #{@@url}, the user said that the page was not designed to engage traffic.", __FILE__, __LINE__, __method__)
        @score = 0
      end
    
    else
      logDebug("On the home page: #{@@url}, the user inputted a score of #{input.to_f}/10.0 to describe the page's effectiveness at engaging traffic.", __FILE__, __LINE__, __method__)
      
      if input.to_f > 10.0
        puts ">>>Number was bigger than 10 so it is being rounded to 10."
        input = 10.0
      end

      @score = @coeffMod * (input.to_f / 10.0)
    end

    writeScore
  end	

  def putLinks
    puts @@allLinks
  end	
end