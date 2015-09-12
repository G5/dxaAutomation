require '../testClasses/testClass1'

class CTAEveryPage < TestClass
  
  def initialize(requirements, selDriver, nokoPage, scoreCoeff, testNam, fileNam=:DEFINED, logFil=:DEFINED, urlName=:DEFINED, bizNam=:DEFINED, gPlusI=:DEFINED, allLink=:DEFINED, zipCod=:DEFINED)
    super(requirements, selDriver, nokoPage, scoreCoeff, testNam, fileNam, logFil, urlName, bizNam, gPlusI, allLink, zipCod)
  end

  def askCTA
    print "\n>>>Does the current page have a call(s) to action? Please enter \"yes\" or \"no\". Additionally, you can manually pass or fail this test by typing \"auto\" and then \"pass\" or \"fail\": "
    input = STDIN.gets.chomp.downcase

    until (input =~ /\w/) and (input =~ /^(\s*((yes|no)|(auto\s*(pass|fail)))\s*)$/)
      print ">>>Invalid input. Please enter \"yes\" or \"no\", or manually overide the test: "
      input = STDIN.gets.chomp.downcase
    end

    if (input =~ /(yes|no)/) and !(input =~ /(auto)/)
      
      if input =~ /(yes)/ 
        logDebug("User confirmed that there were calls to action. Continuing.", __FILE__, __LINE__, __method__)
        return :CONTINUE, :PASS

      else
        logDebug("User confirmed that there were no calls to action. Exiting test.", __FILE__, __LINE__, __method__)
        return :OVERIDE, :FAIL
      end

    else

      if input =~ /(pass)/
        logDebug("User auto passed test. Exiting test.", __FILE__, __LINE__, __method__)
        return :OVERIDE, :PASS

      else
        logDebug("User auto failed test. Exiting test.", __FILE__, __LINE__, __method__)
        return :OVERIDE, :FAIL
      end
    end
  end

  def performTest

    @@allLinks.each do |link|
      logDebug("Current page is: #{link}", __FILE__, __LINE__, __method__)
      @link = link
      @driver.get link

      overFlag, passFlag = askCTA

      if overFlag == :OVERIDE
        @score = (passFlag == :PASS ? @coeffMod : 0)
        writeScore
        return
      end
    end

   logDebug("User looped through, and passed all pages.", __FILE__, __LINE__, __method__)    
    @score = @coeffMod
    writeScore
  end

  def putLinks
    puts @@allLinks
  end	
end