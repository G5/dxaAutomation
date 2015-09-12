require 'rubygems'
require 'selenium-webdriver'
require 'algorithms'
require 'pry'

def askForInfo
  mainURL, bizName, gPlusID, zipCode = nil, nil, nil, nil

  loop do
    puts
    print ">>>Please enter the url of the main page using the format \"http://www.example.com\" (if the url has no \"www.\", that is also fine): "
    input = gets.chomp.delete(" ").downcase

    until input =~ /^(http[s]?:\/\/(www.)?[\w|\-|_|[0-9]]+\.(com|net|org)\/?([\w|\-|_|[0-9]]+\/?)*)$/
      print "Invalid input. Please enter the url of the main page using the format \"http://www.example.com\" (if the url has no \"www.\", that is also fine): "
      input = gets.chomp.delete(" ").downcase
    end

    mainURL = input.dup

    print ">>>Please enter the business name: "
    input = gets.chomp

    until input =~ /[a-zA-Z]/
      print "Invalid input (no letters were entered). Please re-enter the business name: "
      input = gets.chomp
    end

    bizName = input.dup

    print ">>>Please enter the Google+ page url of the business (the format must be \"https://plus.google.com/<21-digit-google-plus-code>/about\"): "
    input = gets.chomp.delete(" ").downcase

    until input =~ /^((http[s]?:\/\/plus.google.com\/[\d]{21}\/?(about\/?)?))$/
      print "Invalid input (the url must be of the format \"https://plus.google.com/<21-digit-google-plus-code>/about\"). Please re-enter the url: "
      input = gets.chomp.delete(" ").downcase
    end

    gPlusID = (input.dup.scan(/[\d]{21}/))[0] 

    print ">>>Please enter the zip code of the business: "
    input = gets.chomp.delete(" ").downcase

    until input =~ /^([\d]{5})$/
      print "Invalid input (the zip code must be 5 digits long). Please re-enter the zip code: "
      input = gets.chomp.delete(" ").downcase
    end

    zipCode = input.dup

    print ">>>Is everything listed correct? Please enter \"yes\" if you are sure, and \"no\" if you wish to revise the previously entered info: "
    input = gets.chomp.delete(" ").downcase

    until input =~ /^((yes)|(no))$/
      print "Invalid format. Please enter \"yes\" or \"no\": "
      input = gets.chomp.delete(" ").downcase
    end

    if input.include? "yes"
      break
    end
  end

  return mainURL, bizName, gPlusID, zipCode
end

def findComp(driver, wait, mainURL, urlQueue, urlSplay, avoidURL)
  # 1. Check if size is reached or competitors not found, exit if so. 
  # 2. Search for url's competition.
  # 3. Push all urls into Queue and Splay. Only push to queue/splay if elem does not exist in either.
  # 4. Call findCompetition on popped urls in loop with bfsTol decremented.
 
  return if (urlSplay.size >= 15) or (loadSpyFu(driver, mainURL, wait) == false)

  findURLs(driver).each do |url|

    next if urlSplay[url] == :EXISTS

    next if avoidURL.include? url
    urlSplay[url] = :EXISTS
    urlQueue.push(url)
  end

  until urlQueue.empty?
    findComp(driver, wait, urlQueue.pop, urlQueue, urlSplay, avoidURL)
    
    return if urlSplay.size >= 15
  end	
end

def findURLs(driver)
  urls = (driver.find_element(:class, "domain-overview-top-competitors-graph").text.split("\n"))[0]
  urls = urls.split(".com").each {|url| url << ".com"}
  return urls
end	

def formatURLs(urlRunList)
  tmp = []

  urlRunList.each do |url|
    tmp << ("http://www." + url.gsub("www.", "").gsub(/(http[s]?:\/\/)/, ""))
  end  

  return tmp.dup
end

def generateFiles(compTable)

  print "\n>>>Results and details files from former files will be deleted. Do you wish to continue? Please answer \"yes\" or \"no\": "
  input = STDIN.gets.chomp.delete(" ").downcase

  until input =~ /^((yes)|(no))$/
    print "Invalid input. Please answer \"yes\" or \"no\" as to whether you want to continue (and delete files from the former test): "
    input = STDIN.gets.chomp.delete(" ").downcase
  end

  if input.include? "no"
    exit
  end

  if File.exist? ("removeList.txt")

    File.read("removeList.txt").split(",").each do |fileName|
      
      if File.exist?("../results/" + fileName)
        system "rm ../results/#{fileName}"
      end
    end 

    system "rm removeList.txt" 
  end

  system "touch removeList.txt"
  
  compTable.each do |bizInfo|

    if File.exist?("../results/#{bizInfo[1].delete(" ")}Results.csv")
      system "rm ../results/#{bizInfo[1].delete(" ")}Results.csv"
    end

    system "touch ../results/#{bizInfo[1].delete(" ")}Results.csv"
    File.open("./removeList.txt", "a") { |f| f.write("#{bizInfo[1].delete(" ")}Results.csv,") }

    if File.exist?("../results/#{bizInfo[1].delete(" ")}Details.txt")
      system "rm ../results/#{bizInfo[1].delete(" ")}Details.txt"
    end

    system "touch ../results/#{bizInfo[1].delete(" ")}Details.txt"
    File.open("./removeList.txt", "a") { |f| f.write("#{bizInfo[1].delete(" ")}Details.txt,") }
  end
end

def getCompTable(urlSplay)
  urlRunList = []
  puts

  loop do
    puts ">>>Here is the list of competitors that was found for your site:"
    urlCount = 1

    urlSplay.each do |key, value|
      puts "#{urlCount}. #{key}"
      urlCount = urlCount + 1
    end

    puts
    print ">>>Please enter which competitors you wish to run the DXA Analysis on by typing the numbers that coorespond to the urls, seperated by commas. You may also enter \"none\" if you do not wish to run the DXA on any competitors: "
    input = gets.chomp.delete(" ").downcase

    until input =~ /^((\d+(\,\d+)*)|(none))$/
      print "Invalid format. Please enter a comma separated list of numbers or \"none\" if you do not with to run the DXA on any competitors: "
      input = gets.chomp.delete(" ").downcase
    end

    if input.include? "none"
      return []
    end

    tmp = []

    input.split(",").each {|num| tmp << num.to_i}
    input = tmp.dup.uniq.sort
    count = 1
    
    urlSplay.each do |url|
      
      if input.include? count
        urlRunList << url[0]
      end

      count = count + 1
    end

    urlRunList = formatURLs(urlRunList)
    puts "This is the list of websites you chose:"
    puts urlRunList
    print "Do you wish to continue? Please enter \"yes\" to continue or \"no\" to revise the list: "
    input = gets.chomp.delete(" ").downcase

    until input =~ /^((yes)|(no))$/ 
      print "Invalid input. Please enter \"yes\" to continue or \"no\" to revise the list: "
      input = gets.chomp.delete(" ").downcase
    end

    puts

    if input.include? "yes"
      break
    end

    urlRunList.clear
  end

  return getInfo(urlRunList)
end  

def getInfo(urlRunList)
  compTable = []
  bizAttribs = []
  tmp = []
  promptTable = [["Name", :NON_EMPTY], ["Google+ page url", :GOOGLE_PLUS], ["Zip code", :ZIP_CODE]]

  urlRunList.each do |url|
    bizAttribs << url 
    puts ">>>For the url #{url}:"

    loop do 

      promptTable.each do |prompt|
        print "#{prompt[0]} of the business: "
        input = gets.chomp

        case prompt[1]

        when :NON_EMPTY

          until input =~ /[a-zA-Z]/
            print "Invalid input (no letters were entered). Please re-enter the business #{prompt[0].downcase}: "
            input = gets.chomp
          end

          tmp << input.dup

        when :GOOGLE_PLUS
          input = input.delete(" ").downcase

          until input =~ /^((http[s]?:\/\/plus.google.com\/[\d]{21}\/?(about\/?)?))$/
            print "Invalid input (the url must be of the format \"https://plus.google.com/<21-digit-google-plus-code>/about\"). Please re-enter the #{prompt[0].downcase}: "
            input = gets.chomp.delete(" ").downcase
          end

          input = (input.scan(/[\d]{21}/))[0]
          tmp << input.dup

        when :ZIP_CODE
          input = input.delete(" ").downcase

          until input =~ /^([\d]{5})$/
            print "Invalid input (the zip code must be 5 digits long and all numbers). Please re-enter the #{prompt[0].downcase}: "
            input = gets.chomp.delete(" ").downcase
          end

          tmp << input.dup

        else
          raise "Argument type not recognized."
        end
      end

      puts
      print "Is everything listed correct? Please enter \"yes\" if you are sure, and \"no\" if you wish to revise the previously entered info: "
      input = gets.chomp.delete(" ").downcase

      until input =~ /^((yes)|(no))$/
        print "Invalid format. Please enter \"yes\" or \"no\": "
        input = gets.chomp.delete(" ").downcase
      end

      puts

      if input.include? "yes"
        break
      
      else
        tmp.clear
      end
    end

    bizAttribs << tmp.dup
    tmp.clear
    bizAttribs.flatten!
    compTable << bizAttribs.dup
    bizAttribs.clear
  end  

  return compTable
end

def loadSpyFu(driver, url, wait)
  driver.get "http://www.spyfu.com/overview/domain?query=#{url}"
  
  begin
    wait.until { driver.find_element(:class => "domain-overview-top-competitors-header").displayed? }
  
  rescue
    return false
  end

  return true
end	

driver = Selenium::WebDriver.for :firefox
wait = Selenium::WebDriver::Wait.new(:timeout => 10)

compTable = []
mainURL, bizName, gPlusID, zipCode = askForInfo

urlQueue = Containers::Queue.new
urlSplay = Containers::SplayTreeMap.new

findComp(driver, wait, mainURL, urlQueue, urlSplay, mainURL)
compTable = getCompTable(urlSplay)

compTable.reverse!
compTable << [mainURL, bizName, gPlusID, zipCode]
compTable.reverse!

driver.close

generateFiles(compTable)

bizName = nil
paramBiz = nil

compTable.each do |bizInfo|
  bizName = bizInfo[1].delete(" ")
  paramBiz = bizInfo[1].split(" ").join(",")
  system "ruby driver1.rb #{bizInfo[0]} #{paramBiz} #{bizInfo[2]} #{bizInfo[3]} #{bizName + "Results.csv"} #{bizName + "Details.txt"}"
end
