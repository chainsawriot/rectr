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

set.seed(421)
map_dfr(1:5, get_sample, paris_corpus, theta = paris_gmm$theta) %>% print(n = 100)
```

    ## # A tibble: 75 x 4
    ##    hl                                                          lang   prob topic
    ##    <chr>                                                       <chr> <dbl> <int>
    ##  1 "SYRIEN; „Tornados“ als Politik\n"                          de    0.917     1
    ##  2 "Ernste Worte in ernster Lage; Wie groß ist die Terrorgefa… de    0.949     1
    ##  3 "USA warnen vor neuen Angriffen; CIA-Chef Brennan hatte Ke… de    0.975     1
    ##  4 "SYRIEN-POLITIK; Krieg, und was dann?\n"                    de    1.00      1
    ##  5 "AUSSENANSICHT; Vorsicht vor falschen Bündnissen; Eine All… de    1.00      1
    ##  6 "Belgium Lowers Terror Attack Alert Level for Brussels\n"   en    0.902     1
    ##  7 "How Terror Hardens Us\n"                                   en    0.984     1
    ##  8 "Emergency Edict in France Spurs Intense Policing\n"        en    0.988     1
    ##  9 "France Pushes Allies to Weigh ISIS Action\n"               en    0.998     1
    ## 10 "Cellphone Contacts in Paris Attacks Suggest Coordination … en    1.00      1
    ## 11 "Obama défie la Chine en Asie du Sud-Est\n"                 fr    0.949     1
    ## 12 "Contrer la stratégie de l'État islamique à l'égard des je… fr    0.978     1
    ## 13 "« Les attentats de Paris vont stimuler le recrutement de … fr    1.00      1
    ## 14 "Le scénario noir tant redouté par les forces de l'ordre e… fr    1.00      1
    ## 15 "Comment le « cerveau » présumé du premier projet d'attent… fr    1.00      1
    ## 16 "Kaltstart; In der Abgasaffäre gerät nun auch Renault ins … de    0.999     2
    ## 17 "Die Bremser\n"                                             de    1.00      2
    ## 18 "Beten für Klima, Mensch und Schöpfung\n"                   de    1.00      2
    ## 19 "KLIMAPOLITIK; Für die Menschheit; VON MICHAEL BAUCHMÜLLER… de    1.00      2
    ## 20 "POLITIK UND MARKT; Brasilien reicht Klage ein\n"           de    1.00      2
    ## 21 "Small-Business Owners Devise Creative Ways to Keep Top Wo… en    0.934     2
    ## 22 "President Rejects Keystone Pipeline, Invoking Climate\n"   en    1.00      2
    ## 23 "The Secrets in Greenland's Ice Sheet\n"                    en    1.00      2
    ## 24 "The Investment Impact of Climate Change\n"                 en    1.00      2
    ## 25 "Some See Long-Term Decline for Battered Coal Industry\n"   en    1         2
    ## 26 "COP21 : de l'eau dans le gaz entre Paris et Washington\n"  fr    0.868     2
    ## 27 "Laurent Adamowicz : « J'étais au coeur de l'affaire Tapie… fr    0.912     2
    ## 28 "Philippe Carli quitte le groupe Amaury\n"                  fr    0.994     2
    ## 29 "Les décideurs du groupe Amadeus\n"                         fr    1.00      2
    ## 30 "La Chine, futur premier pays consommateur de vin au monde… fr    1.00      2
    ## 31 "Entschlossene Favoritin; Hillary Clinton fordert im TV-Du… de    0.857     3
    ## 32 "Das Brauchtum liefert die Basis; Jungbauernschaft Altener… de    0.896     3
    ## 33 "Erdinger Gallier; Beim traditionellen Stehempfang der Jun… de    0.926     3
    ## 34 "Kooperation ja, Integration nein; Dänemark entscheidet üb… de    0.998     3
    ## 35 "Alle gegen rechts; Frankreichs Premier warnt vor Krieg, s… de    1         3
    ## 36 "Trump and Carson Face a Foreign Policy Test Before a Jewi… en    0.947     3
    ## 37 "The Farce Awakens\n"                                       en    0.974     3
    ## 38 "Obama Accuses Trump of Taking Advantage of Working-Class … en    0.997     3
    ## 39 "Rising Democratic Star Makes Mark on Party by Openly Defy… en    0.999     3
    ## 40 "Rivals at Debate Attack Clinton on Foreign Policy and Fin… en    1.00      3
    ## 41 "L'histoire est un des fronts de la guerre\n"               fr    0.899     3
    ## 42 "Le président consulte, l'opposition s'organise, les Franç… fr    0.987     3
    ## 43 "Quelles alliances avec quelles régions ?\n"                fr    0.999     3
    ## 44 "Une abstention toujours forte malgré un net recul\n"       fr    1.00      3
    ## 45 "Marion Maréchal-Le Pen distancerait Christian Estrosi en … fr    1         3
    ## 46 "Patriotismus als Verbandszeug; Nach den Terroranschlägen … de    1.00      4
    ## 47 "Das erste Endspiel; Oberstes Sportgericht entscheidet übe… de    1.00      4
    ## 48 "Der Heimschläfer; Nachwuchsprofi Maximilian Marterer von … de    1.00      4
    ## 49 "1000 Polizisten sichern Risiko-Spiel gegen Piräus\n"       de    1.00      4
    ## 50 "Kühle Demonstration in der „Hölle Nord“; Herbstmeister Rh… de    1         4
    ## 51 "Former I.A.A.F. Chief Is Accused of Taking Bribes to Hide… en    1.00      4
    ## 52 "Real Madrid Embarrassed at Home in El Clásico\n"           en    1         4
    ## 53 "Red Bulls Trail in Series as Crew Score Early Goal\n"      en    1         4
    ## 54 "Lionel Messi May Return for Clásico Showdown at Real Madr… en    1         4
    ## 55 "Chelsea Tumbles Toward Relegation Zone\n"                  en    1         4
    ## 56 "La Solitaire du Figaro 2016 accélère en côtes\n"           fr    0.940     4
    ## 57 "Marion Bartoli saisit la mode au bond\n"                   fr    0.972     4
    ## 58 "Une juge « au profil classique » mène l'enquête\n"         fr    0.999     4
    ## 59 "Fifa : le camp Platini dénonce un procès en sorcellerie\n" fr    1.00      4
    ## 60 "Football : Angers tient tête au PSG, Caen en danger\n"     fr    1         4
    ## 61 "Revolución! Das neue Gucci, das neue Saint Laurent – stän… de    0.850     5
    ## 62 "Allmächtiger; Gott ist ein fieser belgischer Kleinbürger:… de    0.955     5
    ## 63 "Aus Gegenwart geschmiedet; Claude Lanzmann hat „Shoah“, d… de    0.990     5
    ## 64 "Warten auf die Schwalben; Eine großartige Wiederentdeckun… de    0.992     5
    ## 65 "SCHAUPLATZ OSLO; Von dieser Hütte sollt ihr lernen\n"      de    0.999     5
    ## 66 "News Media Scrambles to Cover Paris Shootings\n"           en    0.975     5
    ## 67 "A Parable on Bigotry, Citizenship and Shopping\n"          en    0.981     5
    ## 68 "Le Garage Adds a French Touch to Bushwick, Brooklyn\n"     en    0.988     5
    ## 69 "After Four Decades, a Premiere\n"                          en    0.993     5
    ## 70 "Thinking With His Hands\n"                                 en    1.00      5
    ## 71 "Vinaver : « L'affaire Bettencourt, entre farce et tragédi… fr    0.854     5
    ## 72 "Aurélien Bory sait arrondir les angles\n"                  fr    0.857     5
    ## 73 "La nuit des « transvestis »\n"                             fr    0.951     5
    ## 74 "Chandigarh fait fortune dans le mobilier\n"                fr    0.996     5
    ## 75 "Balthus, grand seigneur à la Villa Médicis\n"              fr    1.00      5
