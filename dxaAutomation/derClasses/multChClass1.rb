require '../testClasses/testClass1'

class MultChanTest < TestClass
  
  def initialize(requirements, selDriver, nokoPage, scoreCoeff, testNam, fileNam=:DEFINED, logFil=:DEFINED, urlName=:DEFINED, bizNam=:DEFINED, gPlusI=:DEFINED, allLink=:DEFINED, zipCod=:DEFINED)
    super(requirements, selDriver, nokoPage, scoreCoeff, testNam, fileNam, logFil, urlName, bizNam, gPlusI, allLink, zipCod)
  end

  def performTest
    @driver.get @@url
    sleep(4)

    print "\n>>>Does this page have multiple channels for engagement? Please answer \"yes\" or \"no\", or provide a number between 0 and 10 to describe the effectiveness of the multiple engagement channels: "
    input = STDIN.gets.chomp.downcase

    until (input =~ /^(\s*((yes|no)|(\d*((\.)\d*)?))\s*)$/) and (input =~ /\S/)
      print ">>>Invalid input. Enter \"yes\" or \"no\", or provide a number between 0 and 10: "
      input = STDIN.gets.chomp.downcase
    end

    input = input.delete(" ")

    if input =~ /(yes|no)/
    
      if input =~ /(yes)/
        logDebug("The user said that the home page: #{@@url}, has multiple channels for engagment. Test passed.", __FILE__, __LINE__, __method__)
        input = 10.0

      else
        logDebug("The user said that the home page: #{@@url}, does not have multiple channels for engagment. Test failed.", __FILE__, __LINE__, __method__)
        input = 0.0
      end
    
    else
      logDebug("The graded the extent to which the home page: #{@@url}, has multiple channels of engagement as #{input}/10.0.", __FILE__, __LINE__, __method__)
      
      if input.to_f > 10.0
        puts ">>>Number was bigger than 10 so it is being rounded to 10."
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