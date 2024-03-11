require(tidyverse)
require(rvest)
require('RSelenium')


# Requires Selenium server, started as
# sudo docker run -d -p 4444:4444 -p 5900:5900 \
#                 -v  $BASEDIR/derivatives/WMH-MNI:/host \
#                 selenium/standalone-firefox-debug:2.53.1

BASEDIR <- '/mnt/data/consolidation/Research/Projects/02_Active/WU-WMH-Disconnectivity'

system(paste0('sudo -kS docker run -d -p 4444:4444 -p 5900:5900 -v  ', BASEDIR, '/derivatives/WMH_MNI_cropped/archives/:/host selenium/standalone-firefox-debug:latest')
       , rstudioapi::askForPassword("sudo password")
       , intern = TRUE
       , ignore.stderr = TRUE
       , ignore.stdout = FALSE
       , wait = TRUE)
url <- "https://kuceyeski-wcm-web.s3.us-east-1.amazonaws.com/upload.html"

remDr <- remoteDriver(
  remoteServerAddr = "localhost",
  port = 4444L,
  browserName = "firefox",
)
remDr$open()
remDr$navigate(url = url)
remDr$findElement(using = 'id', value = 'email')$sendKeysToElement(list('e.schlemm@uke.de'))
remDr$findElement(using = 'id', value = 'fileupload')$sendKeysToElement(list('/host/archive01.zip'))
remDr$findElement(using = 'id', value = 'addres1_pairwise')$clickElement()

remDr$findElement(using = 'xpath', "//*/option[@value = 'cocolaus157subj']")$clickElement()
remDr$findElement(using = 'xpath', "//select[@id = 'addparc1_dilselect']/option[@value = '2']")$clickElement()
remDr$findElement(using = 'id', value = 'addparc1_output_allref')$clickElement()

remDr$findElement(using = 'xpath', "//*/option[@value = 'cocolaus262subj']")$clickElement()
remDr$findElement(using = 'xpath', "//select[@id = 'addparc2_dilselect']/option[@value = '2']")$clickElement()
remDr$findElement(using = 'id', value = 'addparc2_output_allref')$clickElement()

remDr$findElement(using = 'xpath', "//*/option[@value = 'cocolaus491subj']")$clickElement()
remDr$findElement(using = 'xpath', "//select[@id = 'addparc3_dilselect']/option[@value = '2']")$clickElement()
remDr$findElement(using = 'id', value = 'addparc3_output_allref')$clickElement()

remDr$findElement(using = 'id', value = 'upload')$clickElement()
remDr$close()

container.id <- system("sudo -kS docker container ls | awk 'NR==2 {print $1}'"
                       , rstudioapi::askForPassword("sudo password")
                       , intern = TRUE
                       , ignore.stderr = TRUE
                       , ignore.stdout = FALSE
                       , wait = TRUE)
system(paste0('sudo -kS docker container stop ', container.id)
       , rstudioapi::askForPassword("sudo password")
       , intern = FALSE
       , ignore.stderr = TRUE
       , ignore.stdout = TRUE
       , wait = TRUE)
