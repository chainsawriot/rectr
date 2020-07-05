
require(lsa)
require(quanteda)
require(rectr)
require(tidyverse)

paris_dfm_filtered <- filter_dfm(paris_dfm, k = 5)
paris_dfm_bert_filtered <- filter_dfm(paris_dfm_bert, k = 5)


id_row <- function(id, corpus) {
    which(id == docvars(corpus, "id"))
}
cal_sim <- function(id1, id2, thetax, corpus) {
    cosine(thetax[id_row(id1, corpus),], thetax[id_row(id2, corpus),])[1,1]
}

trial <- function(trial_num, paris_dfm_filtered, paris_dfm_bert_filtered) {
    paris_gmm <- calculate_gmm(paris_dfm_filtered)
    paris_gmm_bert <- calculate_gmm(paris_dfm_bert_filtered)
    paris_human_coding %>% mutate(rectr_topicsim = map2_dbl(a1id, a2id, cal_sim, thetax = paris_gmm$theta, corpus = paris_corpus), bert_topicsim = map2_dbl(a1id, a2id, cal_sim, thetax = paris_gmm_bert$theta, corpus = paris_corpus), human = (coder1 + coder2) / 2) -> paris_topic_sim
    x <- cor.test(paris_topic_sim$human, paris_topic_sim$rectr_topicsim)
    y <- cor.test(paris_topic_sim$human, paris_topic_sim$bert_topicsim)
    return(c(x$estimate, y$estimate))
}

require(furrr)

plan(multiprocess)

res <- future_map(1:100, trial, paris_dfm_filtered = paris_dfm_filtered, paris_dfm_bert_filtered = paris_dfm_bert_filtered, .progress = TRUE)

saveRDS(res, "rectr_corrs.RDS")
require(stm)

trial_stm <- function(trial, paris_tdtm_dfm, paris_ft_dfm) {
    translated_stm <- stm(paris_tdtm_dfm$documents, paris_tdtm_dfm$vocab, K = 5, init.type = "Random")
    ft_stm  <- stm(paris_ft_dfm$documents, paris_ft_dfm$vocab, K = 5, init.type = "Random")
    paris_human_coding %>% mutate(tstm_topicsim = map2_dbl(a1id, a2id, cal_sim, thetax = translated_stm$theta, corpus = paris_corpus), ft_topicsim = map2_dbl(a1id, a2id, cal_sim, thetax = ft_stm$theta, corpus = paris_corpus) , human = (coder1 + coder2) / 2) -> paris_topic_sim
    x <- cor.test(paris_topic_sim$human, paris_topic_sim$tstm_topicsim)
    y <- cor.test(paris_topic_sim$human, paris_topic_sim$ft_topicsim)
    return(c(x$estimate, y$estimate))
}

res2 <- future_map(1:100, trial_stm, paris_tdtm_dfm = paris_tdtm_dfm, paris_ft_dfm = paris_ft_dfm, .progress = TRUE)
saveRDS(res2, "stm_corrs.RDS")

require(lsa)
require(quanteda)
require(rectr)
require(tidyverse)


res <- readRDS("rectr_corrs.RDS")
res2 <- readRDS("stm_corrs.RDS")

tibble("af-rectr" = map_dbl(res, 1), "mb-rectr" = map_dbl(res, 2), "tdtm-stm" = map_dbl(res2, 1), "ft-stm" = map_dbl(res2, 2)) %>% pivot_longer(everything(), names_to = "model", values_to = "corr") %>% ggplot(aes(x = corr, y = fct_relevel(model, "af-rectr", "mb-rectr"))) + geom_point(alpha = 0.6) + xlab("Correlation Coefficient") + ylab("model") -> fig

height <- 6

ggsave("rectr_cmm_r1_fig9.pdf", fig, height = height, width = height * 1.77)


tibble(af = map_dbl(res, 1), mb = map_dbl(res, 2), tdtm = map_dbl(res2, 1), ft = map_dbl(res2, 2)) %>% pivot_longer(everything(), names_to = "model", values_to = "corr") %>% group_by(model) %>% summarise(mean(corr))
