require '../testClasses/testClass1'

class ComPosTest < TestClass
  
  def initialize(requirements, selDriver, nokoPage, scoreCoeff, testNam, fileNam=:DEFINED, logFil=:DEFINED, urlName=:DEFINED, bizNam=:DEFINED, gPlusI=:DEFINED, allLink=:DEFINED, zipCod=:DEFINED)
    super(requirements, selDriver, nokoPage, scoreCoeff, testNam, fileNam, logFil, urlName, bizNam, gPlusI, allLink, zipCod)
  end

  def performTest
    @driver.get "https://www.google.com/?gws_rd=ssl"
    input = @driver.find_element(:id, "lst-ib")
    input.send_keys(@@bizName)
    input.submit
    sleep(5)

    tmpURL = @@url.gsub(/((http[s]?:\/\/)|(www\.)|(\/.*))/, '')
    puts tmpURL

    links = @driver.find_element(:id, "res").find_elements(:tag_name, "cite")
    loopLimit = (links.length > 5 ? 5 : link.length)
    compPos = false

    for i in 0...loopLimit
      linkText = links[i].text.to_s

      next unless linkText =~ /^((http[s]?:\/\/)?(www\.)?(\w+)(\.((com)|(net)|(org)))((\/\S+)*))$/

      if linkText.include? tmpURL
        compPos = true
        break
      end       
    end 

    @score = @coeffMod * (compPos ? 1 : 0)
    writeScore
  end

  def putLinks
    puts @@allLinks
  end	
end