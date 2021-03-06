#url = "http://www.bmwconcord.com/all-inventory/index.htm"
#library(XML)
#test case
#url = "http://www.balisechevybuickgmc.com/new-inventory/index.htm"
#url = "http://www.lonestarchevrolet.com/new-inventory/index.htm"
#url = "http://www.balisehonda.com/new-inventory/index.htm"
#url = "http://www.davesmith.com/new-inventory/"
#url = "http://www.balisefordcapecod.com/new-inventory/index.htm"
#url = "http://www.quirkford.com/new-inventory/?"
#url = "http://www.muziford.com/new-inventory/index.htm"
#url = "http://www.toyotaofbristol.com/exotic-new-inventory/index.htm"
#url = "http://www.commonwealthchevrolet.com/new-inventory/index.htm"
#url = "https://www.liatoyotaofwilbraham.com/new-inventory/index.htm"
#url = "http://www.herbchambersscion.com/new-inventory/index.htm"
#url = "http://www.nissan24auto.com/type/new-inventory/"----MAKE NA
#url = "http://www.kellynissanofbeverly.com/new-inventory/index.htm"
#url = "https://www.lianissanenfield.com/new-inventory/index.htm"
#url = "http://www.currynissanma.com/new-inventory/index.htm"
#url = "http://www.jackmaddenfordsales.com/new-inventory/index.htm"

#url = "http://www.bmwconcord.com/all-inventory/index.htm"
#grab the linklist
source("Case study-10.R")

getLinklist.3 = function(url){
  xdata = getURLContent(url, useragent = "R")
  doc = htmlParse(xdata,asText=T)  
  baselink = strsplit(url, "\\?")[[1]][1]
  href = unique(getHTMLLinks(doc)) 
  
  #pages are obey ?start= pattern
  index = grep("?start=",href, fixed = T)
  if(length(index)==0){
    return(url)
  }
  else{
    #number of cars per page
    number = as.numeric(gsub(".*=([0-9]+).*", "\\1", href[index]))
    
    #total number of cars in new inventory
    totalnumber = as.numeric(xpathSApply(doc, "//span[@id='current-search-count']",xmlValue))
    #each pages start number
    startnumber = seq(0, totalnumber-1, number)
    #all the links 
    Linklist = sapply(1:length(startnumber), function(i) paste0(baselink, gsub("[0-9]+", startnumber[i], href[index])))
    return(Linklist)
  }
}
  



#scrapping data
getdatacontent.3 = function(node, content){
  tt = xmlAttrs(node)[content]
  return(tt)
}

scrapeInfo.3 <- function(url)
{
  xdata = getURLContent(url, useragent = "R")
  doc = htmlParse(xdata, asText = TRUE)
  vin.node = getNodeSet(doc, "//div[@data-vin]")
  if(length(vin.node)==0){
      vin.node = getNodeSet(doc, "//text()[contains(.,'VIN#:')]")
      if(length(vin.node)==0){
        #vin.node = getNodeSet(doc, "//dd[@itemprop='serialNumber']/text()")
        #vins = xmlSApply(vin.node, xmlValue, trim=T)
        write(url,"linksForValidation.csv",append = T)
        return()
      }
      else{
        vins = gsub(".*([0-9A-z]{17}).*","\\1",xmlApply(vin.node, xmlValue))
        make.node = getNodeSet(doc, "//img[@class='p-image']")
        name = sapply(make.node, getdatacontent.3, content = "alt")
        tt = strsplit(name, " ")
        make = unname(sapply(tt, "[", 2))
      }
     }
  else{
      vins = unique(sapply(vin.node,getdatacontent.3, content = "data-vin"))
      #some page have two cars with same vin number  
      index = match(vins, sapply(vin.node,getdatacontent.3, content = "data-vin"))
      make = sapply(vin.node,getdatacontent.3, content = "data-make")[index]
     }
    
  model = "NA"
  trim = "NA"
  year = "NA"
  
  df <- data.frame(vins,make,model,trim, year, stringsAsFactors = F)
  colnames(df) <- c("VIN", "Make", "Model", "Trim", "Year")
  #print(url)
  return(df)
} 

#scrape car information from all the pages

alldata.3 = function(url){
  require(XML)
  require(RCurl)
  tryCatch({
    links = getLinklist.3(url)
    tt = lapply(links, scrapeInfo.3)
    cardata = Reduce(function(x, y) rbind(x, y), tt)
    return(cardata)
  },error = function(err){
    links = getLinklist.10(url)
    tt = lapply(links, scrapeInfo.10)
    cardata = Reduce(function(x, y) rbind(x, y), tt)
    return(cardata)
  })
}
#cc = alldata.3(url)




