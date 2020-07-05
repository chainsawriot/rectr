require(rectr)
require(tidyverse)
require(quanteda)
require(lsa)

filter_dfmx <- function(input_dfm, k, corpus = NULL, exact_n, dimension = 100, alpha = 0.05, noise = FALSE) {
    if (is.null(corpus)) {
        ## check if the input_dfm has a corpus
        if (!is.null(input_dfm$corpus)) {
            corpus <- input_dfm$corpus
        } else {
            stop("Corpus not found.")
        }
    }
    svd_dfm <- RSpectra::svds(input_dfm$dfm, k = dimension, nu = dimension, nv = dimension)$u
    lang_vector <- quanteda::docvars(corpus, "lang")
    i <- rectr:::.check_lang_indep(svd_dfm, lang_vector, alpha, noise = noise)
    max_d <- (exact_n) + i
    input_dfm$dfm <- svd_dfm[,i:max_d]
    input_dfm$k <- k
    input_dfm$filtered <- TRUE
    return(input_dfm)
}

paris_dfm_filtered <- filter_dfmx(paris_dfm, k = 5, exact_n = 2)

id_row <- function(id, corpus) {
    which(id == docvars(corpus, "id"))
}
cal_sim <- function(id1, id2, thetax, corpus) {
    cosine(thetax[id_row(id1, corpus),], thetax[id_row(id2, corpus),])[1,1]
}

trial <- function(exact_n, paris_dfm, paris_dfm_bert) {
    paris_dfm_filtered <- filter_dfmx(paris_dfm, k = 5, exact_n = exact_n, dimension = 200)
    paris_dfm_bert_filtered <- filter_dfmx(paris_dfm_bert, k = 5, exact_n = exact_n, dimension = 200)
    paris_gmm <- calculate_gmm(paris_dfm_filtered)
    paris_gmm_bert <- calculate_gmm(paris_dfm_bert_filtered)
    paris_human_coding %>% mutate(rectr_topicsim = map2_dbl(a1id, a2id, cal_sim, thetax = paris_gmm$theta, corpus = paris_corpus), bert_topicsim = map2_dbl(a1id, a2id, cal_sim, thetax = paris_gmm_bert$theta, corpus = paris_corpus), human = (coder1 + coder2) / 2) -> paris_topic_sim
    x <- cor.test(paris_topic_sim$human, paris_topic_sim$rectr_topicsim)
    y <- cor.test(paris_topic_sim$human, paris_topic_sim$bert_topicsim)
    return(c(exact_n, x$estimate, y$estimate))
}


require(furrr)
plan(multiprocess)
res <- future_map(sample(rep(1:100, 30)), trial, paris_dfm = paris_dfm, paris_dfm_bert, .progress = TRUE)
saveRDS(res, "multiplication_robustness.RDS")

res <- readRDS("multiplication_robustness.RDS")

as.data.frame(do.call(rbind, res)) -> res2
colnames(res2) <- c("m", "af-rectr", "mb-rectr")

res2 %>% pivot_longer(-m, names_to = "model", values_to = "Correlation Coefficient") %>% ggplot(aes(x = m, y = `Correlation Coefficient`, col = model)) + geom_point(alpha = 0.3) + scale_color_brewer(palette = "Dark2") + geom_smooth(method = "loess", span = 0.3) + xlab("m - l") + geom_vline(xintercept = 11, linetype = "dotted") -> fig

height <- 6

ggsave("rectr_cmm_r1_fig10.pdf", fig, height = height, width = height * 1.77)

