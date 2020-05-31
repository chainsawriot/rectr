require(reticulate)
use_miniconda("miniconda3", required = TRUE)
source_python("bert.py")
x <- readRDS("final_data_endefr.RDS")
require(tidyverse)
readRDS("final_data_endefr.RDS") %>% mutate(content = paste(lede, body), lang = tolower(lang), id = row_number()) %>% select(content, lang, pubdate, headline, id) -> paris

bert_sentence(paris$content[1])

list_of_embedding <- map(paris$content, bert_sentence)

dfm_bert <- do.call(rbind, list_of_embedding)
saveRDS(dfm_bert, "dfm_bert.RDS")

require(rectr)

res <- list(dfm = dfm_bert, corpus = paris_corpus, k = NULL, filtered = FALSE)
class(res) <- append(class(res), "rectr_dfm")

res_filtered <- filter_dfm(res, k = 5, corpus = paris_corpus)

mod <- calculate_gmm(res_filtered, seed = 42)

paris_human_coding

require(lsa)
cal_sim <- function(id1, id2, thetax) {
    cosine(thetax[id1,], thetax[id2,])[1,1]
}

paris_human_coding %>% mutate(rectr_topicsim = map2_dbl(a1id, a2id, cal_sim, thetax = mod$theta), human = (coder1 + coder2) / 2) -> paris_topic_sim

cor.test(paris_topic_sim$human, paris_topic_sim$rectr_topicsim)

