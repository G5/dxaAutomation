require '../testClasses/testClass1'

class EngImgTest < TestClass
  
  def initialize(requirements, selDriver, nokoPage, scoreCoeff, testNam, fileNam=:DEFINED, logFil=:DEFINED, urlName=:DEFINED, bizNam=:DEFINED, gPlusI=:DEFINED, allLink=:DEFINED, zipCod=:DEFINED)
    super(requirements, selDriver, nokoPage, scoreCoeff, testNam, fileNam, logFil, urlName, bizNam, gPlusI, allLink, zipCod)
  end

  def goodDim(image)
    heightOk = false
    widthOk = false
    imgHeight = image.attribute("height")
    imgWidth = image.attribute("width")

    if imgHeight == "auto"
      heightOk = true

    else
      heightOk = (imgHeight.to_i >= 50)
    end 

    if imgWidth == "auto"
      widthOk = true

    else
      widthOk = (imgWidth.to_i >= 50)
    end 

    return (heightOk and widthOk)
  end 

  def performTest

    @@allLinks.each do |link|
      @driver.get link
      sleep(2)

      images = @driver.find_elements(:tag_name, "img")
      goodImg = 0

      images.each do |img|

        if goodDim(img)
          goodImg = goodImg + 1
        end
      end

      unless images.length == 0
        appendScore(goodImg.to_f / images.length.to_f)
        logDebug("On page: #{link}, the ratio of engaging images to total images is: #{goodImg.to_f / images.length.to_f}", __FILE__, __LINE__)

      else
        logDebug("On page: #{link}, no images found.", __FILE__, __LINE__)
        appendScore(0.0)
      end
    end

    logDebug("For all pages, the ratio of engaging images to total images is: #{getAverage}", __FILE__, __LINE__)
    @score = @coeffMod * getAverage
    writeScore
  end

  def putLinks
    puts @@allLinks
  end	
end