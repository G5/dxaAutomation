require '../testClasses/testClass1'

class AutoAudVid < TestClass
  
  def initialize(requirements, selDriver, nokoPage, scoreCoeff, testNam, fileNam=:DEFINED, logFil=:DEFINED, urlName=:DEFINED, bizNam=:DEFINED, gPlusI=:DEFINED, allLink=:DEFINED, zipCod=:DEFINED)
    super(requirements, selDriver, nokoPage, scoreCoeff, testNam, fileNam, logFil, urlName, bizNam, gPlusI, allLink, zipCod)
  end

  def askAutoPlay
    print "\n>>>Does the current page have autoplay? Please enter \"yes\" or \"no\". Additionally, you can manually pass or fail this test by typing \"auto\" and then \"pass\" or \"fail\": "
    input = STDIN.gets.chomp.downcase

    until input =~ /\w/ and input =~ /^(\s*((yes|no)|(auto\s*(pass|fail)))\s*)$/ 
      print ">>>Invalid input. Please enter \"yes\" or \"no\", or manually overide the test: "
      input = STDIN.gets.chomp.downcase
    end

    if (input =~ /(yes|no)/)
      
      if input =~ /(yes)/ 
        return :OVERIDE, :FAIL

      else
        return :CONTINUE, :PASS
      end

    else

      if input =~ /(pass)/
        return :OVERIDE, :PASS

      else
        return :OVERIDE, :FAIL
      end
    end
  end

  def performTest

    if @flashFlag
      puts "\n>>>We have detected flash on this page so there is a high chance that this site contains autoplay features."
    end

    @@allLinks.each do |link|
      @driver.get link
      logDebug("Current page: #{link}", __FILE__, __LINE__, __method__)

      overFlag, passFlag = askAutoPlay

      if overFlag == :OVERIDE
        logDebug("Test auto overriden. Test #{(passFlag == :PASS ? "passed" : "failed")}.", __FILE__, __LINE__, __method__)
        @score = (passFlag == :PASS ? @coeffMod : 0)
        writeScore
        return
      end
    end

    logDebug("Each page passed the autoplay test (no autoplay on any page). Test passed.", __FILE__, __LINE__, __method__)
    @score = @coeffMod
    writeScore
  end

  def setFlashFlag(flashFlag)
    logDebug("@flashFlag set as" + (flashFlag ? "true" : "false") + ".", __FILE__, __LINE__, __method__)
    @flashFlag = flashFlag
  end

  def putLinks
    puts @@allLinks
  end	
end