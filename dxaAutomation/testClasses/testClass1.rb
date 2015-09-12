class TestClass
  
  def initialize(requirements, selDriver, nokoPage, scoreCoeff, testNam, fileNam, logFil, urlName, bizNam, gPlusI, allLink, zipCod)
    getLibs(requirements)
    
    @driver = selDriver
    @page = nokoPage
    
    @score = 0
    @coeffMod = scoreCoeff

    @testName = testNam

    unless fileNam == :DEFINED
      @@fileName = "../results/" + fileNam
    end

    unless logFil == :DEFINED
      @@logFile = "../results/" + logFil
    end

    @comment = nil

    unless urlName == :DEFINED
      @@url = urlName
    end

    unless bizNam == :DEFINED
      @@bizName = bizNam
    end

    unless allLink == :DEFINED
      @@allLinks = allLink
    end

    unless gPlusI == :DEFINED
      @@gPlusID = gPlusI 
    end  

    unless zipCod == :DEFINED
      @@zipCode = zipCod
    end

    @testRes = []

    @logNum = 0
    initDebugFile
  end	

  def appendScore(score)
    @testRes << score 
  end  

  def getAverage

    if @testRes.length == 0
      return 0
    end

    return @testRes.instance_eval { reduce(:+) / size.to_f } 
  end  

  def getLibs(requirements)
    
    requirements.each do |requirement|
      require requirement
    end	
  end

  def getMin
    return @testRes.min
  end

  def initDebugFile

    if @testName == :MULTIPLE
      return
    end

    File.open(@@logFile, "a") do |file|
      file.write("#{@testName}:\n")
    end
  end

  def logDebug(logText, fileName, lineNum, method=:NOT_ENTERED)

    File.open(@@logFile, "a") do |file|
      file.write("  Log #{@logNum}: #{fileName}:#{lineNum}: In function \"#{method}\": #{logText}\n")
    end

    @logNum = @logNum + 1
  end

  def logStatus
  end

  def writeScore

    unless @coeffMod.is_a? Array
    
      File.open(@@fileName, "a") do |file|
        file.write("\"#{@testName}\",\"#{@score.to_f.round(1)}\",\"#{@coeffMod.to_f}\"\r\n")
      end
    end	

    File.open(@@logFile, "a") do |file|
      file.write("\n")
    end
  end
end