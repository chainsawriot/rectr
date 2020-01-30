Keyword analysis
================

Due to copyright reasons, we cannot bundle the full text of New York Times, Süddeutsche Zeitung and Le Fegaro news articles in this package.

The first few rows of the data look like so.

``` r
require(rectr)
require(tibble)
require(dplyr)
require(quanteda)
readRDS("~/dev/infocrap/final_data_endefr.RDS")
```

    ## # A tibble: 3,391 x 10
    ##    path  id    pubdate headline lede  body  lang  content    nt tokenized_conte…
    ##    <chr> <chr> <chr>   <chr>    <chr> <chr> <chr> <chr>   <int> <list>          
    ##  1 ./pa… arti… 2 Nove… "Maladi… "Ave… "Dan… FR    "Avec …  1026 <chr [1,138]>   
    ##  2 ./pa… arti… 2 Nove… "« Cela… "LE … "Pat… FR    "LE FI…   734 <chr [820]>     
    ##  3 ./pa… arti… 2 Nove… "L'Iran… "L'a… "de … FR    "L'anc…   984 <chr [1,081]>   
    ##  4 ./pa… arti… 2 Nove… "Matthi… "Le … "Mat… FR    "Le pr…  1077 <chr [1,213]>   
    ##  5 ./pa… arti… 2 Nove… "Les 31… "Lan… "EUR… FR    "Lancé…  1012 <chr [1,115]>   
    ##  6 ./pa… arti… 2 Nove… "Genera… "Apr… "À l… FR    "Après…   800 <chr [874]>     
    ##  7 ./pa… arti… 2 Nove… "La dis… "Seu… "Les… FR    "Seul …  1171 <chr [1,318]>   
    ##  8 ./pa… arti… 2 Nove… "Les ca… "Ils… "Ce … FR    "Ils d…   552 <chr [612]>     
    ##  9 ./pa… arti… 2 Nove… "Le pré… "FRA… "À l… FR    "FRANÇ…   506 <chr [589]>     
    ## 10 ./pa… arti… 2 Nove… "La nui… "  Ç… "Au … FR    "  ÇA …   516 <chr [552]>     
    ## # … with 3,381 more rows

Unfortunately, one must have the original data to reproduce this part of the analysis. Also, the code is not optimized. Thus, don't run this on your machine.

Actual reproduction
===================

Reproduce the analyses in the paper.

``` r
require(rectr)
```

    ## Loading required package: rectr

``` r
require(tidyverse)
```

    ## Loading required package: tidyverse

    ## ── Attaching packages ─────────────────────────────────────── tidyverse 1.3.0 ──

    ## ✔ ggplot2 3.2.1     ✔ purrr   0.3.3
    ## ✔ tibble  2.1.3     ✔ dplyr   0.8.3
    ## ✔ tidyr   1.0.0     ✔ stringr 1.4.0
    ## ✔ readr   1.3.1     ✔ forcats 0.4.0

    ## ── Conflicts ────────────────────────────────────────── tidyverse_conflicts() ──
    ## ✖ dplyr::filter() masks stats::filter()
    ## ✖ dplyr::lag()    masks stats::lag()

``` r
require(quanteda)
```

    ## Loading required package: quanteda

    ## Package version: 1.9.9009

    ## Parallel computing: 2 of 4 threads used.

    ## See https://quanteda.io for tutorials and examples.

    ## 
    ## Attaching package: 'quanteda'

    ## The following object is masked from 'package:utils':
    ## 
    ##     View

``` r
paris_corpus
```

    ## Corpus consisting of 3,391 documents and 4 docvars.

``` r
paris_dfm
```

    ## dfm with a dimension of 3391 x 300 and fr/en/de language(s).

``` r
emb <- read_ft(c("fr", "de", "en"))
paris_dfm_filtered <- filter_dfm(paris_dfm, paris_corpus, k = 5)
paris_dfm_filtered
```

    ## dfm with a dimension of 3391 x 11 and fr/en/de language(s).
    ## Filtered with k =  5

``` r
paris_gmm <- calculate_gmm(paris_dfm_filtered, seed = 42)
paris_gmm
```

    ## 5-topic rectr model trained with a dfm with a dimension of 3391 x 11 and fr/en/de language(s).
    ## Filtered with k =  5

``` r
textdata <- readRDS("~/dev/infocrap/final_data_endefr.RDS")
max_docfreq <- (nrow(textdata) * 0.99) %>% ceiling

dfm(textdata$content, tolower = TRUE, stem = TRUE, remove = stopwords("en"), remove_number = TRUE, remove_punct = TRUE) %>% dfm_trim(min_docfreq = 3, max_docfreq = max_docfreq) %>% dfm_tfidf -> dfm_tfidf

eng_dfm <- dfm_tfidf[textdata$lang == 'EN',]

keywords <- function(topic = 1, thetax, eng_dfm, textdata, lang = "EN") {
    print(topic)
    dfm_col <- ncol(eng_dfm)
    cor_t1 <- map_dbl(1:dfm_col, ~ cor(as.vector(eng_dfm[,.]), thetax[textdata$lang == lang,topic]))
    tibble(token = colnames(eng_dfm), cor = cor_t1, topic = topic)
}

keywords_matrix <- map_dfr(1:5, keywords, thetax = paris_gmm$theta, eng_dfm = eng_dfm, textdata = textdata)
```

    ## [1] 1
    ## [1] 2
    ## [1] 3
    ## [1] 4
    ## [1] 5

``` r
keywords_matrix %>% group_by(topic) %>% top_n(n = 10, wt = cor) %>% summarise(desc = paste(token, collapse = ", ")) -> rectr_keywords
```

``` r
rectr_keywords
```

    ## # A tibble: 5 x 2
    ##   topic desc                                                                    
    ##   <int> <chr>                                                                   
    ## 1     1 terrorist, offici, suspect, milit, islam, state, kill, syria, attack, e…
    ## 2     2 chang, climat, carbon, global, energi, billion, reduc, environment, gre…
    ## 3     3 parti, candid, voter, trump, polit, elect, poll, democrat, presidenti, …
    ## 4     4 germain, match, champion, coach, game, team, leagu, player, championshi…
    ## 5     5 collect, show, music, classic, art, style, exhibit, color, piec, featur

``` r
sessionInfo()
```

    ## R version 3.6.2 (2019-12-12)
    ## Platform: x86_64-pc-linux-gnu (64-bit)
    ## Running under: Ubuntu 18.04.3 LTS
    ## 
    ## Matrix products: default
    ## BLAS:   /usr/lib/x86_64-linux-gnu/blas/libblas.so.3.7.1
    ## LAPACK: /usr/lib/x86_64-linux-gnu/lapack/liblapack.so.3.7.1
    ## 
    ## locale:
    ##  [1] LC_CTYPE=en_US.UTF-8       LC_NUMERIC=C              
    ##  [3] LC_TIME=en_US.UTF-8        LC_COLLATE=en_US.UTF-8    
    ##  [5] LC_MONETARY=en_US.UTF-8    LC_MESSAGES=en_US.UTF-8   
    ##  [7] LC_PAPER=en_US.UTF-8       LC_NAME=C                 
    ##  [9] LC_ADDRESS=C               LC_TELEPHONE=C            
    ## [11] LC_MEASUREMENT=en_US.UTF-8 LC_IDENTIFICATION=C       
    ## 
    ## attached base packages:
    ## [1] stats     graphics  grDevices utils     datasets  methods   base     
    ## 
    ## other attached packages:
    ##  [1] quanteda_1.9.9009 forcats_0.4.0     stringr_1.4.0     dplyr_0.8.3      
    ##  [5] purrr_0.3.3       readr_1.3.1       tidyr_1.0.0       tibble_2.1.3     
    ##  [9] ggplot2_3.2.1     tidyverse_1.3.0   rectr_0.0.5      
    ## 
    ## loaded via a namespace (and not attached):
    ##  [1] Rcpp_1.0.3         mvtnorm_1.0-11     lubridate_1.7.4    lattice_0.20-38   
    ##  [5] utf8_1.1.4         assertthat_0.2.1   digest_0.6.23      RSpectra_0.16-0   
    ##  [9] R6_2.4.1           cellranger_1.1.0   backports_1.1.5    stats4_3.6.2      
    ## [13] reprex_0.3.0       evaluate_0.14      httr_1.4.1         pillar_1.4.3      
    ## [17] rlang_0.4.4        lazyeval_0.2.2     readxl_1.3.1       rstudioapi_0.10   
    ## [21] data.table_1.12.8  Matrix_1.2-18      rmarkdown_2.0      munsell_0.5.0     
    ## [25] broom_0.5.3        compiler_3.6.2     spacyr_1.2         modelr_0.1.5      
    ## [29] xfun_0.12          pkgconfig_2.0.3    htmltools_0.4.0    nnet_7.3-12       
    ## [33] tidyselect_1.0.0   fansi_0.4.1        crayon_1.3.4       dbplyr_1.4.2      
    ## [37] withr_2.1.2        SnowballC_0.6.0    grid_3.6.2         nlme_3.1-143      
    ## [41] jsonlite_1.6       gtable_0.3.0       lifecycle_0.1.0    DBI_1.1.0         
    ## [45] magrittr_1.5       scales_1.1.0       RcppParallel_4.4.4 cli_2.0.1         
    ## [49] stringi_1.4.5      fs_1.3.1           flexmix_2.3-15     xml2_1.2.2        
    ## [53] stopwords_1.0      generics_0.0.2     vctrs_0.2.2        fastmatch_1.1-0   
    ## [57] tools_3.6.2        glue_1.3.1         hms_0.5.3          yaml_2.2.0        
    ## [61] colorspace_1.4-1   rvest_0.3.5        knitr_1.26         haven_2.2.0       
    ## [65] modeltools_0.2-22
