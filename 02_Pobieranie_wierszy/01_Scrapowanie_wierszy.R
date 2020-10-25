library(xml2)
library(rvest)   
library(tibble)

# Wystarczy tutaj podnienic link ------------------------------------------
thepage <- readLines("https://poezja.org/wz/Szymborska_Wis%C5%82awa/", encoding = "UTF-8")

#View(thepage)

wiersze <- thepage[grep('a title.+href=',thepage)] 

temp <- gsub(".*href=|><h4>.*", "", wiersze)

linki <- stringi::stri_extract_all_regex(temp, '(?<=").*?(?=")')

# Tutaj usuwamy ewentualne wiersze nie napisane po polsku -----------------
#linki <- linki[-grep('esperanto', linki)]

df <- data.frame(matrix(unlist(linki), nrow=length(linki), byrow=T),stringsAsFactors=FALSE)

lista_wiersze <- tibble()

for(i in 1:length(linki)){
    print(i)
    thepage_1 <- readLines(df[i,1], encoding = "UTF-8")
    
    tytul <- gsub(".*<title>|</title>.*", "", paste(thepage_1, collapse=' '))
    korpus <- gsub(".*<div class=\"col-12 col-lg-8\">|<hr />.*", "", paste(thepage_1, collapse=' '))
    korpus <- gsub("<p>", "", korpus)
    l <- stringi::stri_split_lines(gsub("<br>", "\n", korpus))
    wiersz <- tibble(unlist(l))
    lista_wiersze <-rbind(lista_wiersze, c(" "), rbind(tytul, c(" "), wiersz))
}

# Tutaj zmieniamy tytul pliku ---------------------------------------------
writeLines(lista_wiersze$`unlist(l)`, 'Szymborska.txt', useBytes=T)
     