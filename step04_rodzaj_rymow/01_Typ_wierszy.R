library(tidyverse)
library(tm)
library(tictoc)

# Jezyk polski ------------------------------------------------------------

Sys.setlocale(category = "LC_ALL", locale="Polish") 

# Obecna lista plikow -----------------------------------------------------

old_files <- list.files("C:\\Users\\Krystian\\Downloads\\FINAL\\FINAL", full.names = TRUE, recursive = TRUE)

lista <- tibble()

tic()
Sys.time()
for(i in 1:length(old_files)){
      print(i)
      # Wczytanie wiersza -------------------------------------------------------
      sciezka_wiersza <- old_files[i]
      
      wygenerowany_plik <- tibble(wiersz = readLines(sciezka_wiersza, encoding = "UTF-8"))
      
      # Przygotowanie tekstu: oczyszczanie oraz ostatnie slowa w wersie ---------
      
      oczyszczony_wiersz <- wygenerowany_plik %>% 
        select(wiersz) %>% 
        filter(!(wiersz %in% c(" ", ""))) %>% 
        mutate(wiersz = str_replace_all(wiersz, "—", "")) %>% 
        mutate(wiersz = str_replace_all(wiersz, "-", "")) %>% 
        mutate(wiersz = str_trim(wiersz)) %>% 
        pull %>% 
        removePunctuation() %>% 
        word(.,-1)
      
      # Bierzemy ostatnie dwie litery do porownan -------------------------------
      # tysiace - slonce - jest rym, a trzy ostatnie nie pasuja
      
      koncowki <- oczyszczony_wiersz %>% 
        str_sub(., start = -2) 
        
      # Sprawdzamy, ile jakich rymow --------------------------------------------
      
      # AABB:
      # Tutaj moga generowac sie warningi, ze nieparzystych jest wiecej, niz parzystych, ale to jest ok, bo po prostu tego ostatniego wersu nie porownujemy
      ile_aabb <- sum(koncowki[seq_along(koncowki) %%2 == 1] == koncowki[seq_along(koncowki) %%2 == 0])
      
      # ABAB
      ile_abab <- sum(koncowki[seq_along(koncowki) %%2 == 1] == lag(koncowki[seq_along(koncowki) %%2 == 1]), na.rm = TRUE) + 
        sum(koncowki[seq_along(koncowki) %%2 == 0] == lag(koncowki[seq_along(koncowki) %%2 == 0]), na.rm = TRUE)  
      
      # ABBA
      
      pierwszy <- koncowki[seq_along(koncowki) %%4 == 1]
      drugi <- koncowki[seq_along(koncowki) %%4 == 2]
      trzeci <- koncowki[seq_along(koncowki) %%4 == 3]
      czwarty <- koncowki[seq_along(koncowki) %%4 == 0]
      
      # Moga byc rozne dlugosci - bierzemy tyle pierwszych wersow, aby ich liczba wciac dzielila sie przez 4
      minimum <- min(length(pierwszy), length(drugi), length(trzeci), length(czwarty))
      
      ile_abba <- sum(pierwszy[1:minimum] == czwarty[1:minimum]) + 
        sum(drugi[1:minimum] == trzeci[1:minimum])  
      
      licznosci <- c(ile_aabb, ile_abab, ile_abba)
      
      najczestsze <- max(licznosci)
      
      if(is.na(najczestsze)) {
        lista = lista %>% bind_rows(tibble(sciezka_wiersza = sciezka_wiersza, 
                                           aabb = ile_aabb,
                                           abab = ile_abab,
                                           abba = ile_abba,
                                           typ_rymow = 'Balagan'))
        next
      }
      
      if(sum(licznosci == najczestsze) > 1) {
        lista = lista %>% bind_rows(tibble(sciezka_wiersza = sciezka_wiersza, 
                                           aabb = ile_aabb,
                                           abab = ile_abab,
                                           abba = ile_abba,
                                           typ_rymow = 'N/A'))
        
      } else {
        lista = lista %>% bind_rows(tibble(sciezka_wiersza = sciezka_wiersza, 
                                           aabb = ile_aabb,
                                           abab = ile_abab,
                                           abba = ile_abba,
                                           typ_rymow = case_when(najczestsze == ile_aabb ~ "AABB",
                                                                 najczestsze == ile_abab ~ "ABAB",
                                                                 najczestsze == ile_abba ~ "ABBA")))
      }
}
toc()

lista %>% View()

lista %>% count(typ_rymow)

# Zapis do csv ------------------------------------------------------------

con<-file('rymy.csv',encoding="cp1250")

lista %>% 
  write.csv(con)
