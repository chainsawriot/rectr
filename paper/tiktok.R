require(quanteda)
require(rectr)

tiktok <- readRDS("tiktok.RDS")

tiktok_corpus <- create_corpus(tiktok$content, tiktok$lang)
docvars(tiktok_corpus, "hl") <- tiktok$headline

require(tokenizers)

tiktok_dfm <- transform_dfm_boe(tiktok_corpus, noise = TRUE, remove_stopwords = FALSE)

saveRDS(tiktok_dfm, "tiktok_dfm.RDS")

tiktok_dfm <- readRDS("tiktok_dfm.RDS")

tiktok_dfm_f <- filter_dfm(tiktok_dfm, k = 4, noise = TRUE)

tiktok_gmm <- calculate_gmm(tiktok_dfm_f, seed = 721831)

require(tidyverse)
require(quanteda)

get_sample <- function(i, paris_corpus, theta, threshold = 0.8, replace = FALSE, size = 5) {
    tibble(hl = docvars(paris_corpus, "hl"), lang = docvars(paris_corpus, "lang"), prob = theta[,i]) %>% group_by(lang) %>% filter(prob > threshold) %>% sample_n(size = size, weight = prob, replace = replace) %>% select(hl, lang, prob) %>% ungroup %>% arrange(lang, prob) %>% mutate(topic = i)
}

set.seed(721831)
map_dfr(1:4, get_sample, tiktok_corpus, theta = tiktok_gmm$theta, replace = TRUE) %>% unique -> hl
hl %>% select(topic, lang, hl) %>% rio::export("tiktok_hl.csv")
