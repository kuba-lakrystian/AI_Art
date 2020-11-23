library(tidyverse)
library(icesTAF)

# Jezyk polski ------------------------------------------------------------

Sys.setlocale(category = "LC_ALL", locale="Polish") 

# Obecna lista plikow -----------------------------------------------------

old_files <- list.files("C:/Users/Krystian/Desktop/wiersze_temp", full.names = TRUE, recursive = TRUE)

# Usuwamy nawiasy, przecinki, dodatemy "_" --------------------------------

new_files <- old_files %>% 
  str_replace_all(., "\\(", "") %>% 
  str_replace_all(., "\\)", "") %>% 
  str_replace_all(., ",", "") %>% 
  str_replace_all(., " ", "_")

# Tworzymy nowe wersje nazw folderow ----------------------------------------

map(str_extract(new_files, ".*/") %>% unique(), ~ dir.create(.))

# Wklejamy nowe nazwy plikow ----------------------------------------------

file.copy(from = old_files, to = new_files)

# Usuwamy obecne, ze spacjami ---------------------------------------------

file.remove(old_files)
map(substr(str_extract(old_files, ".*/") %>% unique(),1,nchar(str_extract(old_files, ".*/") %>% unique())-1), ~ rmdir(.))


