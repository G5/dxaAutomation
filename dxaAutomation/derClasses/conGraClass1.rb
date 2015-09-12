require '../testClasses/testClass1'

class ConGraphTest < TestClass
  
  def initialize(requirements, selDriver, nokoPage, scoreCoeff, testNam, fileNam=:DEFINED, logFil=:DEFINED, urlName=:DEFINED, bizNam=:DEFINED, gPlusI=:DEFINED, allLink=:DEFINED, zipCod=:DEFINED)
    super(requirements, selDriver, nokoPage, scoreCoeff, testNam, fileNam, logFil, urlName, bizNam, gPlusI, allLink, zipCod)
  end

  def performTest    
    @driver.get @@url
    sleep(4)

    print "\n>>>Does this landing page have consistent graphic elements (please answer \"yes\" or \"no\", or provide a number between 0 and 10 to describe the consistentcy of its graphic elements)? "
    input = STDIN.gets.chomp.downcase

    until (input =~ /^(\s*((yes|no)|(\d*((\.)\d*)?))\s*)$/) and (input =~ /\S/)
      print ">>>Invalid input. Enter \"yes\" or \"no\", or provide a number between 1 and 10: "
      input = STDIN.gets.chomp.downcase
    end

    input = input.delete(" ")

    if input =~ /(yes|no)/
    
      if input =~ /(yes)/
        input = 10.0
        logDebug("User inputted \"yes\" when asked whether the landing page has consistent graphic elements or not.", __FILE__, __LINE__, __method__)

      else
        logDebug("User inputted \"no\" when asked whether the landing page has consistent graphic elements or not.", __FILE__, __LINE__, __method__)
        input = 0.0
      end
    
    else
      logDebug("User inputted: #{input.to_f} when asked about the level of consistency of graphic elements on the page.", __FILE__, __LINE__, __method__)
      
      if input.to_f > 10.0
        print ">>>Number was bigger than 10 so it is being rounded to 10."
        input = 10.0
      end
    end
    
    @score = @coeffMod * (input.to_f / 10.0)

    writeScore
  end

  def putLinks
    puts @@allLinks
  end	
end