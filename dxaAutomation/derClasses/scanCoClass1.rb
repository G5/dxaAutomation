require '../testClasses/testClass1'

class SCANContTest < TestClass
  
  def initialize(requirements, selDriver, nokoPage, scoreCoeff, testNam, fileNam=:DEFINED, logFil=:DEFINED, urlName=:DEFINED, bizNam=:DEFINED, gPlusI=:DEFINED, allLink=:DEFINED, zipCod=:DEFINED)
    super(requirements, selDriver, nokoPage, scoreCoeff, testNam, fileNam, logFil, urlName, bizNam, gPlusI, allLink, zipCod)
  end

  def getInput
    print "\n>>>Does this page have SCAN able content (please answer \"yes\" or \"no\", or provide a number between 0 and 10 to describe it's SCANability)? If you wish to auto pass or fail this test then please type \"auto\" and \"pass\" or \"fail\" to overide the test: "
    input = STDIN.gets.chomp.downcase

    until input =~ /^(\s*((yes|no)|(\d*((\.)\d*)?)|(auto\s*(pass|fail)))\s*)$/ and (input =~ /\S/)
      print ">>>Invalid input. Enter \"yes\" or \"no\", provide a number between 0 and 10, or manually overide the test: "
      input = STDIN.gets.chomp.downcase
    end

    input = input.delete(" ")

    if input =~ /(yes|no)/
    
      if input =~ /(yes)/
        logDebug("User said that home page: #{@driver.current_url} has SCAN able content.", __FILE__, __LINE__, __method__)
        input = 10.0
      
      else
        logDebug("User said that home page: #{@driver.current_url} does not have SCAN able content.", __FILE__, __LINE__, __method__)
        input = 0.0
      end
    
    elsif input =~ /(auto(pass|fail))/

      if input =~ /(pass)/
        logDebug("During prompt on page: #{@driver.current_url}, user auto passed tests.", __FILE__, __LINE__, __method__)
        return :PASS

      else
        logDebug("During prompt on page: #{@driver.current_url}, user auto failed tests.", __FILE__, __LINE__, __method__)
        return :FAIL
      end

    else
      logDebug("User graded the pages SCAN ability as a #{input}/10.0.", __FILE__, __LINE__, __method__)
      
      if input.to_f > 10.0
        puts ">>>Number was bigger than 10 so it is being rounded to 10."
        input = 10.0
      end
    end

    return (input.to_f / 10.0)
  end

  def scanTest(link)
    
    @driver.get link
    sleep(1)

    input = getInput

    if input == :PASS
      return :OVERIDE, 1
    end

    if input == :FAIL
      return :OVERIDE, 0
    end

    appendScore(input)
  end

  def performTest

    @@allLinks.each do |link|
      
      flag, testVal = scanTest(link)

      if flag == :OVERIDE
        @score = @coeffMod * testVal
        writeScore
        return
      end
    end

    logDebug("User did not auto pass/fail the test. The average number of pages that have SCAN able content in \"@@allLinks\" is: #{getAverage}.", __FILE__, __LINE__, __method__)
    @score = @coeffMod * getAverage
    writeScore
  end

  def putLinks
    puts @@allLinks
  end	
end