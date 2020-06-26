require(rectr)
require(tidyverse)
require(quanteda)

readRDS("final_data_endefr.RDS") %>% mutate(content = paste(lede, body), lang = tolower(lang), id = row_number(), outlet = recode(lang, 'en' = 'NYT', 'de' = 'SZ', 'fr' = 'LF')) %>% select(content, lang, pubdate, headline, id, outlet) -> paris

excluded_id <- c(1729, 1815, 1843)

paris[-excluded_id,] %>% mutate(nc = nchar(content)) %>% group_by(lang) %>% summarise(median(nc), quantile(nc, 0.25), quantile(nc, 0.75))

require(tokenizers)

paris[-excluded_id,] %>% mutate(nc = map_int(tokens(content, what = "sentence"), length)) %>% group_by(lang) %>% summarise(median(nc), quantile(nc, 0.25), quantile(nc, 0.75))
