
# Pakiety -----------------------------------------------------------------

library(xml2)
library(rvest)   
library(tibble)
library(stringr)
library(cld2)

# Lokalizaja do zapisu ----------------------------------------------------

setwd("C:\\Users\\Krystian\\Desktop\\Projekty\\03_Art\\01_Dane")

# Alfabet -----------------------------------------------------------------

litery <- LETTERS[-c(17, 22, 24)]
litery <- litery[19:23]

# Scrapping ---------------------------------------------------------------

for(k in 1:length(litery)){
      
      dir.create(litery[k])
      print(litery[k])
  
      tworcy <- readLines(paste0("https://poezja.org/wz/letter/", litery[k], "/"), encoding = "UTF-8")
      autorzy <- tworcy[which(tworcy == '<h2>Autorzy</h2>'):which(tworcy == '<h2>Najpopularniejsze zbiory</h2>')]
      faktyczne <- autorzy[grep('<a href=',autorzy)] 
      faktyczne_2 <- faktyczne[grep('class=',faktyczne)]  
      temp_1 <- gsub(".*href=|title.*", "", faktyczne_2)
      linki_tworcy <- stringi::stri_extract_all_regex(temp_1, '(?<=").*?(?=")')
      df_tworcy <- data.frame(matrix(unlist(linki_tworcy), nrow=length(linki_tworcy), byrow=T),stringsAsFactors=FALSE)
      
      for(j in 1:length(linki_tworcy)){
      
            thepage <- readLines(df_tworcy[j,], encoding = "UTF-8")
            wiersze <- thepage[grep('a title.+href=',thepage)] 
            temp <- gsub(".*href=|><h4>.*", "", wiersze)
            linki <- stringi::stri_extract_all_regex(temp, '(?<=").*?(?=")')
            
            if(length(linki) == 0)  next
            
            df <- data.frame(matrix(unlist(linki), nrow=length(linki), byrow=T),stringsAsFactors=FALSE)
            
            for(i in 1:length(linki)){
      
                  print(i)
                  thepage_1 <- readLines(df[i,1], encoding = "UTF-8")
                  tytul <- gsub(".*<title>|</title>.*", "", paste(thepage_1, collapse=' '))
                  tytul_wiersza <- str_extract(tytul, ".*-") %>% gsub("[-?:*\"<>|/\\]","",.) %>% str_trim() 
                  print(tytul_wiersza)
                  autor_wiersza <- sub(".*-", "", tytul) %>% gsub("[-?:*\"<>|/\\]","",.) %>% str_trim() 
                  
                  if(i == 1) dir.create(paste0(litery[k], "/", autor_wiersza))
                  
                  jezyk <- detect_language(tytul_wiersza)
                  
                  if(!(jezyk %in% c(NA, "pl")))  next
                  
                  korpus <- gsub(".*<div class=\"col-12 col-lg-8\">|(<hr />|<p style|<p class).*", "", paste(thepage_1, collapse=' '))
                  korpus <- gsub("<p>", "", korpus)
                  l <- stringi::stri_split_lines(gsub("<b(r|r /)>", "\n", korpus))
                  wiersz <- tibble(unlist(l))
                  writeLines(wiersz$`unlist(l)`, paste0(getwd(), "/", litery[k], "/", autor_wiersza, "/", tytul_wiersza, ".txt"), useBytes=T)
            }
      }
}
      
      
      
      
