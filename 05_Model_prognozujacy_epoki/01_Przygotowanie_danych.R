library(tidyverse)
library(tm)
library(tictoc)
library(readxl)

# Jezyk polski ------------------------------------------------------------

Sys.setlocale(category = "LC_ALL", locale="Polish") 

# Obecna lista plikow -----------------------------------------------------

old_files <- list.files("C:\\Users\\Krystian\\Downloads\\FINAL\\FINAL", full.names = TRUE, recursive = TRUE)

pisarze <- old_files %>% enframe() %>% 
  mutate(new = str_remove(value, "/[^/]*$")) %>% 
  mutate(new = str_extract(new, "/[^/]*$")) %>% 
  mutate(new = str_replace_all(new, "/", "")) %>% 
  mutate(new = str_replace_all(new, "_", " ")) %>% 
  mutate(new = gsub( " *\\(.*?\\) *", "", new)) %>% 
  mutate(new = str_replace_all(new, "-", " "))

# Info od Mirka -----------------------------------------------------------

epoki <- read_xlsx("C:/Users/Krystian/Desktop/AI_Art/AI_Art/step03_df_poems/lista_poetow_epoki.xlsx") %>% 
  janitor::clean_names()

epoki <- epoki %>% 
  mutate(autor_new = gsub( " *\\(.*?\\) *", "", autor)) %>% 
  mutate(autor_new = str_replace_all(autor_new, "-", " "))

# Dogranie epoki do wiersza -----------------------------------------------

wiersz_epoka <- pisarze %>% 
  inner_join(epoki %>% group_by(autor_new) %>% slice_max(1), by = c("new" = "autor_new")) %>% 
  count(value, epoka) 
  
# Przypisanie epoki do wiersza --------------------------------------------

lista <- tibble()

tic()
Sys.time()
for(i in 1:nrow(wiersz_epoka)){
  print(i)
  # Wczytanie wiersza -------------------------------------------------------
  sciezka_wiersza <- wiersz_epoka$value[i]
  
  wygenerowany_plik <- tibble(wiersz = readLines(sciezka_wiersza, encoding = "UTF-8"))
  
  # Przygotowanie tekstu: oczyszczanie oraz ostatnie slowa w wersie ---------
  
  oczyszczony_wiersz <- wygenerowany_plik %>% 
    select(wiersz) %>% 
    filter(!(wiersz %in% c(" ", ""))) %>% 
    mutate(wiersz = str_replace_all(wiersz, "—", "")) %>% 
    mutate(wiersz = str_replace_all(wiersz, "-", "")) %>% 
    mutate(wiersz = str_trim(wiersz)) %>% 
    pull %>% 
    removePunctuation() 
  
  lista[i, 1] <- paste(oczyszczony_wiersz, collapse=" ")
  lista[i, 2] <- wiersz_epoka$epoka[i]
}
toc()

lista <- lista %>% 
  rename(wiersz = `...1`, epoka = `...2`) 

# Zapis do pliku csv ------------------------------------------------------

con<-file('wiersze_epoki.csv',encoding="cp1250")

lista %>% 
  write.csv(con, row.names=FALSE)

