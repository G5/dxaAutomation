require '../testClasses/testClass1'

class CTAPromTest < TestClass
  
  def initialize(requirements, selDriver, nokoPage, scoreCoeff, testNam, fileNam=:DEFINED, logFil=:DEFINED, urlName=:DEFINED, bizNam=:DEFINED, gPlusI=:DEFINED, allLink=:DEFINED, zipCod=:DEFINED)
    super(requirements, selDriver, nokoPage, scoreCoeff, testNam, fileNam, logFil, urlName, bizNam, gPlusI, allLink, zipCod)
  end

  def performTest
    @driver.get @@url
    sleep(4)

    print "\n>>>Does this landing page have a prominent CTA(s)? Please answer \"yes\" or \"no\", or provide a number between 0 and 10 to describe the prominence of its CTA's)? "
    input = STDIN.gets.chomp.downcase

    until (input =~ /^(\s*((yes|no)|(\d*((\.)\d*)?))\s*)$/) and (input =~ /\S/)
      print ">>>Invalid input. Enter \"yes\" or \"no\", or provide a number between 0 and 10: "
      input = STDIN.gets.chomp.downcase
    end

    input = input.delete(" ")

    if input =~ /(yes|no)/
    
      if input =~ /(yes)/
        logDebug("On the home page: #{@@url}, the user said that the CTA's were prominent.", __FILE__, __LINE__, __method__)
        input = 10.0

      else
        logDebug("On the home page: #{@@url}, the user said that the CTA's were not prominent.", __FILE__, __LINE__, __method__)
        input = 0.0
      end
    
    else
      logDebug("On the home page: #{@@url}, the user graded the prominence of the CTA's as #{input.to_f} out of 10.", __FILE__, __LINE__, __method__)
      
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