Reproducing the analyses in the paper
================

Due to copyright reasons, we cannot bundle the full text of New York Times, Süddeutsche Zeitung and Le Fegaro news articles.

However, a processed version of the corpus and dfm is available. The data was generated using the following code.

``` r
require(rectr)
require(tibble)
require(dplyr)
require(quanteda)
paris <- readRDS("~/dev/infocrap/final_data_endefr.RDS") %>% mutate(content = paste(lede, content), lang = tolower(lang), id = row_number()) %>% select(content, lang, pubdate, headline, id)
```

``` r
get_ft("fr")
get_ft("de")
get_ft("en")
```

``` r
emb <- read_ft(c("fr", "de", "en"))
paris_corpus <- create_corpus(paris$content, paris$lang)
paris_dfm <- transform_dfm_boe(paris_corpus, emb)
docvars(paris_corpus, "headline") <- paris$headline
docvars(paris_corpus, "pubdate") <- paris$pubdate
docvars(paris_corpus, "id") <- paris$id

## Delete all text content, sorry, researchers!
paris_corpus[1:3391] <- NA
usethis::use_data(paris_corpus, overwrite = TRUE)
usethis::use_data(paris_dfm, overwrite = TRUE)
```

Reproduce the analysis in the paper.

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
get_sample <- function(i, paris_corpus, theta, threshold = 0.8) {
    tibble(hl = docvars(paris_corpus, "headline"), lang = docvars(paris_corpus, "lang"), prob = theta[,i]) %>% group_by(lang) %>% filter(prob > threshold) %>% sample_n(size = 5, weight = prob, replace = FALSE) %>% select(hl, lang, prob) %>% ungroup %>% arrange(lang, prob) %>% mutate(topic = i)
}

set.seed(42)
map_dfr(1:5, get_sample, paris_corpus, theta = paris_gmm$theta) %>% print(n = 100)
```

    ## # A tibble: 75 x 4
    ##    hl                                                          lang   prob topic
    ##    <chr>                                                       <chr> <dbl> <int>
    ##  1 "Nahost-Deutschland; Hassparolen gegen Israel, Überfälle, … de    0.853     1
    ##  2 "Stadt der Zukunft; Stell dir vor, es ist Krieg, und alle … de    0.866     1
    ##  3 "SERBIEN; Ein Land empfiehlt sich\n"                        de    0.931     1
    ##  4 "G 8; Russlands Rückkehr\n"                                 de    0.987     1
    ##  5 "FRANKREICH; Heikle Bitte um Beistand\n"                    de    1.00      1
    ##  6 "Paris Terrorist Attacks Kill Over 100; France Declares St… en    0.976     1
    ##  7 "Ways to Respond to the Paris Attacks\n"                    en    0.983     1
    ##  8 "Mass Surveillance Isn't the Answer\n"                      en    0.991     1
    ##  9 "Germany Rebukes Its Own Agency for Criticizing Saudi Poli… en    0.998     1
    ## 10 "Paris Is on Edge as Fate of Attacks' Organizer Is Still a… en    1.00      1
    ## 11 "COP21 : les forces de l'ordre en alerte  face à un risque… fr    0.889     1
    ## 12 "Les magistrats mettent en garde à propos des limites de l… fr    0.981     1
    ## 13 "Le général de Villiers auprès des renforts de « Sentinell… fr    0.999     1
    ## 14 "Paris sonne l'alarme face à l'extension de Daech dans le … fr    0.999     1
    ## 15 "Un tir qui plombe les efforts de Paris\n"                  fr    1.00      1
    ## 16 "Logistiker will nach Erding; Die Stadt weist im Westen ei… de    0.830     2
    ## 17 "Von Abgründen und Lernkurven; Etliche Krisen haben dieses… de    0.885     2
    ## 18 "Europas neue Allianz\n"                                    de    0.999     2
    ## 19 "Neuer Betrugsverdacht gegen VW; Die Europäische Anti-Korr… de    1.00      2
    ## 20 "Keine Kohle für Kohle; Die Allianz will nicht mehr in Unt… de    1.00      2
    ## 21 "The Hidden Costs of Terror\n"                              en    0.821     2
    ## 22 "U.S. May Soon Reject Some Driver's Licenses as Air Travel… en    0.918     2
    ## 23 "Apple Executive Seeks a Touch of Chic at Retail Stores\n"  en    0.938     2
    ## 24 "What Happens When Mother Earth Gets Angry\n"               en    1         2
    ## 25 "Britain Plans End to Coal Power by 2025\n"                 en    1         2
    ## 26 "La French Tech séduit l'Amérique\n"                        fr    0.902     2
    ## 27 "Adblockers : les éditeurs préparent leur riposte\n"        fr    0.947     2
    ## 28 "Le Kazakhstan privatise et cherche des investisseurs\n"    fr    0.999     2
    ## 29 "Élisabeth Borne dessine une RATP « durable »\n"            fr    1.00      2
    ## 30 "Christopher Dembik : « Il ne faut pas être inutilement al… fr    1.00      2
    ## 31 "Ohne Schengen kein Euro; Für EU-Kommissionschef Jean-Clau… de    0.903     3
    ## 32 "Zur Freiheit; Im März wurde Eric Gujer nach einem Machtka… de    0.937     3
    ## 33 "Frankreich macht mobil; Vor dem Kongress präsentiert Präs… de    0.952     3
    ## 34 "Ende der Einigkeit; Die SPD-Kreisvorsitzende Bela Bach kr… de    0.998     3
    ## 35 "Alle gegen rechts; Frankreichs Premier warnt vor Krieg, s… de    1         3
    ## 36 "Let My People Vote\n"                                      en    0.864     3
    ## 37 "French City Yearns to Shed Heavy Yoke of Past Shame\n"     en    0.928     3
    ## 38 "Why did the 'Twitter revolutions' fail?\n"                 en    0.989     3
    ## 39 "Iowa Poll Has Cruz Doubling Support, Passing Carson and N… en    1.00      3
    ## 40 "France's Far-Right National Front Gains in Elections\n"    en    1.00      3
    ## 41 "Les indignés du président\n"                               fr    0.871     3
    ## 42 "Face à la menace FN,   la droite reporte les hostilités\n" fr    1.00      3
    ## 43 "Valls agite le spectre de la « guerre civile »\n"          fr    1.00      3
    ## 44 "La décision de Hollande suscite le malaise à gauche\n"     fr    1.00      3
    ## 45 "Ile-de-France : Pécresse appelle à un « triple vote sanct… fr    1         3
    ## 46 "Streiche gegen die Skepsis; Das Internationale Olympische… de    0.961     4
    ## 47 "Der Großmeister der Familie; Schach ist Krieg, Schach ist… de    0.979     4
    ## 48 "Eine Villa am See und Netzer als Chauffeur; Wie Robert Lo… de    0.993     4
    ## 49 "In der Klose-Lücke; Mario Gomez soll der Nationalmannscha… de    1.00      4
    ## 50 "„Privatsache“; Entlastendes Platini-Dokument umstritten\n" de    1.00      4
    ## 51 "Trade Fair Moves Out as Davis Cup Moves In\n"              en    1.00      4
    ## 52 "With Messi Out, Neymar's Star Grows Ever Brighter\n"       en    1         4
    ## 53 "Djokovic Rises Ever Higher, With No Obstacles in Sight\n"  en    1         4
    ## 54 "Ireland Secures Berth\n"                                   en    1         4
    ## 55 "Red Bulls Trail in Series as Crew Score Early Goal\n"      en    1         4
    ## 56 "Le Qatar va entrer en mêlée\n"                             fr    1.00      4
    ## 57 "Le match de football Angleterre-France maintenu mardi à L… fr    1.00      4
    ## 58 "Une vague d'émotion déferle sur les terrains\n"            fr    1.00      4
    ## 59 "Le PSG corrige Lyon et creuse l'écart\n"                   fr    1         4
    ## 60 "Roger Federer tombe de son nuage à Bercy\n"                fr    1         4
    ## 61 "Der Nacht-Vergolder; Tobias Lintz vom „Holy Home“ und „Un… de    0.812     5
    ## 62 "Farbenblind; 80 Prozent aller Models auf Laufstegen und M… de    0.876     5
    ## 63 "Der Zwist der Götter und die Ruhe; René Girard, der relig… de    0.911     5
    ## 64 "LEUTE\n"                                                   de    0.937     5
    ## 65 "Immer auf der Jagd; Der Münchner Fotoreporter Reto Zimpel… de    0.966     5
    ## 66 "A Barolo Waits for an Event\n"                             en    0.943     5
    ## 67 "The Deer in My Sights\n"                                   en    0.972     5
    ## 68 "Domesticating Her Design Ideas\n"                          en    0.999     5
    ## 69 "Paris Street Spared in Carnage Embodies What Attackers Lo… en    1.00      5
    ## 70 "As Days Shorten, Takeout Puts Time on the Clock\n"         en    1.00      5
    ## 71 "Pool Design Binôme à 360°\n"                               fr    0.984     5
    ## 72 "La petite robe noire existe-t-elle encore ?\n"             fr    0.999     5
    ## 73 "2003 Alain Bashung par Olivier Nuc\n"                      fr    0.999     5
    ## 74 "Les grandes heures de Breguet\n"                           fr    1.00      5
    ## 75 "Un Rodin peut en cacher un autre\n"                        fr    1.00      5

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
    ## [37] withr_2.1.2        grid_3.6.2         nlme_3.1-143       jsonlite_1.6      
    ## [41] gtable_0.3.0       lifecycle_0.1.0    DBI_1.1.0          magrittr_1.5      
    ## [45] scales_1.1.0       RcppParallel_4.4.4 cli_2.0.1          stringi_1.4.5     
    ## [49] fs_1.3.1           flexmix_2.3-15     xml2_1.2.2         stopwords_1.0     
    ## [53] generics_0.0.2     vctrs_0.2.2        fastmatch_1.1-0    tools_3.6.2       
    ## [57] glue_1.3.1         hms_0.5.3          yaml_2.2.0         colorspace_1.4-1  
    ## [61] rvest_0.3.5        knitr_1.26         haven_2.2.0        modeltools_0.2-22
