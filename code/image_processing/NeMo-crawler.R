require(tidyverse)
require(rvest)


# Requires Selenium server, started as
# sudo docker run -d -p 4444:4444 -p 5900:5900 \
#                 -v  $BASEDIR/derivatives/WMH-MNI:/host \
#                 selenium/standalone-firefox-debug:2.53.1


url <- "https://kuceyeski-wcm-web.s3.us-east-1.amazonaws.com/upload.html"

require('RSelenium')
remDr <- remoteDriver(
  remoteServerAddr = "localhost",
  port = 4444L,
  browserName = "firefox",
)
remDr$open()
remDr$navigate(url = url)
remDr$findElement(using = 'id', value = 'email')$sendKeysToElement(list('test2@email.com'))
remDr$findElement(using = 'id', value = 'fileupload')$sendKeysToElement(list('/host/test.nii.gz'))
remDr$findElement(using = 'id', value = 'addres1_pairwise')$clickElement()
remDr$findElement(using = 'xpath', "//*/option[@value = 'shen268']")$clickElement()
remDr$findElement(using = 'id', value = 'addparc1_output_allref')$clickElement()
remDr$findElement(using = 'id', value = 'upload')$clickElement()
remDr$close()
