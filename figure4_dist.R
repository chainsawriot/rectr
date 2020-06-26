require(ggplot2)
require(quanteda)
require(rectr)
require(tidyverse)

docvars(paris_corpus, "lang")

dimension <- 100

u_dfm <- RSpectra::svds(paris_dfm$dfm, k = dimension, nu = dimension, nv = dimension)$u

udfm_t <- tibble::as_tibble(u_dfm[,1:9])

colnames(udfm_t) <- paste0(1:9)

udfm_t$lang <- docvars(paris_corpus, "lang")

udfm_t %>% pivot_longer(-lang, names_to = "dimension", values_to = "U") -> x
x$method <- "aligned fastText"

## %>% ggplot(aes(x = dimension, y = U, col = lang)) + geom_jitter(shape = 16, position = position_jitter(0.2), alpha = 0.3)

summary(aov(pull(udfm_t[,4])~udfm_t$lang))

u_dfm <- RSpectra::svds(paris_dfm_bert$dfm, k = dimension, nu = dimension, nv = dimension)$u

udfm_t <- tibble::as_tibble(u_dfm[,1:9])

colnames(udfm_t) <- paste0(1:9)

udfm_t$lang <- docvars(paris_corpus, "lang")

udfm_t %>% pivot_longer(-lang, names_to = "dimension", values_to = "U") -> y

y$method <- "M-BERT"

bind_rows(x, y) %>% ggplot(aes(x = dimension, y = U, col = lang)) + geom_jitter(shape = 16, position = position_jitter(0.4), alpha = 0.3) + facet_grid(rows = vars(method)) + scale_color_brewer(palette = "Dark2")
