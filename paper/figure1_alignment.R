require(tidyverse)
require(ggrepel)

en_em <- readRDS("wiki.en.trimmed.RDS")
de_em <- readRDS("wiki.de.trimmed.RDS")

en_animal <- c("cat", "dog", "mouse", "bird")
de_animal <- c("katze", "hund", "maus", "vogel")
en_ism <- c("communism", "capitalism", "conservatism", "liberalism")

en_country <- c("germany", "france", "china", "switzerland")
de_country <- c("deutschland", "frankreich", 'china', 'schweiz')
de_ism <- c("kommunismus", "kapitalismus", "konservatismus", "liberalismus")

en_examples <- en_em[en_em$X1 %in% c(en_animal, en_country, en_ism),]
de_examples <- de_em[de_em$X1 %in% c(de_country, de_animal, de_ism),]

en_examples$lang <- "en"
de_examples$lang <- "de"


rbind(en_examples, de_examples) %>% select(-X1, -lang) %>% dist %>% cmdscale(k = 2, eig = TRUE) -> scaled

scaled$points %>% as_tibble %>% mutate(word = c(en_examples$X1, de_examples$X1), lang = ifelse(c(en_examples$lang, de_examples$lang) == "en", "en", "de")) %>% ggplot(aes(x = V1, y = V2, col = lang)) + geom_point() + geom_text_repel(aes(label = word), size = 5) + xlab("Scaled vector space 1") + ylab("Scaled vector space 2") + scale_color_brewer(palette = "Dark2") -> fig

height <- 6

ggsave("rectr_cmm_r1_fig1.pdf", fig, height = height, width = height * 1.77)

## plot(scaled$points[,1], scaled$points[,2], type = "n", xlab = "Scaled vector space 1", ylab = "Scaled vector space 2")
## text(scaled$points[,1], scaled$points[,2], c(en_examples$X1, de_examples$X1), col = ifelse(c(en_examples$lang, de_examples$lang) == "en", "red", "blue"))

## amav <- function(x) {
##     as.vector(as.matrix(x))
## }

## lsa::cosine(amav(en_em[en_em$X1 == "hell",2:301]), amav(de_em[de_em$X1 == "hell",2:301]))
