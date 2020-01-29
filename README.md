Reproducible Extraction of Cross-lingual Topics using R.
================

rectr
=====

The rectr package contains an example dataset "wiki" with English and German articles from Wikipedia about programming languages and locations in Germany.

``` r
require(rectr)
```

    ## Loading required package: rectr

``` r
require(tibble)
```

    ## Loading required package: tibble

``` r
require(dplyr)
```

    ## Loading required package: dplyr

    ## 
    ## Attaching package: 'dplyr'

    ## The following objects are masked from 'package:stats':
    ## 
    ##     filter, lag

    ## The following objects are masked from 'package:base':
    ## 
    ##     intersect, setdiff, setequal, union

``` r
wiki
```

    ## # A tibble: 342 x 3
    ##    title                     content                                       lang 
    ##    <chr>                     <chr>                                         <chr>
    ##  1 Wismar                    "Die Hansestadt Wismar liegt an der Ostseekü… de   
    ##  2 Bamberg                   "Bamberg (mittelalterlich: Babenberg, bamber… de   
    ##  3 Grube Messel              "Die Grube Messel in Messel im Landkreis Dar… de   
    ##  4 Adenine                   "Adenine, benannt nach der Nukleinbase Adeni… de   
    ##  5 Haskell (programming lan… "Haskell /ˈhæskəl/ is a standardized, genera… en   
    ##  6 SPARQL                    "SPARQL ist eine graph-basierte Abfragesprac… de   
    ##  7 Trier                     "Trier (französisch Trèves, luxemburgisch Tr… de   
    ##  8 ATS (programming languag… "ATS (Applied Type System) is a programming … en   
    ##  9 Nationalpark Niedersächs… "Der Nationalpark Niedersächsisches Wattenme… de   
    ## 10 Wittenberg                "Wittenberg, officially Lutherstadt Wittenbe… en   
    ## # … with 332 more rows

Download word embeddings
------------------------

Download and preprocess fastText word embeddings from Facebook. Make sure you are using a Unix machine, e.g. Linux or Mac, have at least 5G of disk space and a reasonably amount of RAM. It took around 20 minutes on my machine.

``` r
get_ft("en")
get_ft("de")
```

Read the downloaded word embeddings.

``` r
emb <- read_ft(c("en", "de"))
```

Create corpus
-------------

Create a multilingual corpus

``` r
wiki_corpus <- create_corpus(wiki$content, wiki$lang)
```

Create bag-of-embeddings dfm
----------------------------

Create a multilingual dfm

``` r
wiki_dfm <- dfm_boe(wiki_corpus, emb)
```

    ## 
     Progress: ─────                                                            100%
     Progress: ────────                                                         100%
     Progress: ───────────                                                      100%
     Progress: ──────────────                                                   100%
     Progress: ─────────────────                                                100%
     Progress: ────────────────────                                             100%
     Progress: ───────────────────────                                          100%
     Progress: ──────────────────────────                                       100%
     Progress: ─────────────────────────────                                    100%
     Progress: ────────────────────────────────                                 100%
     Progress: ───────────────────────────────────                              100%
     Progress: ──────────────────────────────────────                           100%
     Progress: ─────────────────────────────────────────                        100%
     Progress: ────────────────────────────────────────────                     100%
     Progress: ───────────────────────────────────────────────                  100%
     Progress: ──────────────────────────────────────────────────               100%
     Progress: ─────────────────────────────────────────────────────            100%
     Progress: ───────────────────────────────────────────────────────          100%
     Progress: ──────────────────────────────────────────────────────────       100%
     Progress: ─────────────────────────────────────────────────────────────    100%
     Progress: ───────────────────────────────────────────────────────────────  100%
     Progress: ──────────────────────────────────────────────────────────────── 100%

``` r
wiki_dfm
```

    ## dfm with a dimension of 342 x 300 and de/en language(s).

Filter dfm
----------

Filter the dfm for language differences

``` r
wiki_dfm_filtered <- filter_dfm(wiki_dfm, wiki_corpus, k = 2)
wiki_dfm_filtered
```

    ## dfm with a dimension of 342 x 5 and de/en language(s).
    ## Filtered with k =  2

Estimate GMM
------------

Estimate a Guassian Mixture Model

``` r
wiki_gmm <- calculate_gmm(wiki_dfm_filtered, seed = 46709394)
wiki_gmm
```

    ## 2-topic rectr model trained with a dfm with a dimension of 342 x 5 and de/en language(s).
    ## Filtered with k =  2

The document-topic matrix is available in `wiki_gmm$theta`.

Rank the articles according to the theta1.

``` r
wiki %>% mutate(theta1 = wiki_gmm$theta[,1]) %>% arrange(theta1) %>% select(title, lang, theta1) %>% print(n = 400)
```

    ## # A tibble: 342 x 3
    ##     title                                                        lang     theta1
    ##     <chr>                                                        <chr>     <dbl>
    ##   1 Lustre (Programmiersprache)                                  de    3.40e-322
    ##   2 GNU Pascal                                                   de    3.80e-234
    ##   3 Pharo (Programmiersprache)                                   de    2.64e-194
    ##   4 Embedded SQL                                                 de    2.75e-163
    ##   5 Windows PowerShell                                           de    1.44e-159
    ##   6 Java Command Language                                        de    9.55e-137
    ##   7 Embedded SQL                                                 en    9.33e-130
    ##   8 Tcllib                                                       en    3.91e-129
    ##   9 Tcl/Java                                                     en    3.79e-127
    ##  10 StepTalk                                                     en    2.26e-116
    ##  11 StepTalk                                                     de    4.85e-110
    ##  12 QML                                                          de    4.60e-107
    ##  13 Extensible Application Markup Language                       de    3.19e-105
    ##  14 Lua (programming language)                                   en    3.62e-100
    ##  15 Java (programming language)                                  en    8.88e- 99
    ##  16 NewLISP                                                      en    4.55e- 98
    ##  17 Windows PowerShell                                           en    6.64e- 95
    ##  18 Synchronized Multimedia Integration Language                 en    7.21e- 94
    ##  19 XSL Transformation                                           de    1.11e- 91
    ##  20 Curl (programming language)                                  en    7.26e- 91
    ##  21 Clojure                                                      en    3.22e- 90
    ##  22 JavaScript                                                   de    5.74e- 90
    ##  23 C++                                                          de    7.51e- 90
    ##  24 Objective-C                                                  en    6.63e- 88
    ##  25 GNU Pascal                                                   en    2.94e- 86
    ##  26 C (Programmiersprache)                                       de    1.01e- 84
    ##  27 Extensible Application Markup Language                       en    1.82e- 84
    ##  28 JavaScript                                                   en    2.02e- 84
    ##  29 Synchronized Multimedia Integration Language                 de    1.30e- 80
    ##  30 Clojure                                                      de    2.78e- 80
    ##  31 Boo (Programmiersprache)                                     de    9.74e- 80
    ##  32 Oz (Programmiersprache)                                      de    1.80e- 79
    ##  33 Tcl                                                          en    9.18e- 79
    ##  34 Common Lisp                                                  en    2.27e- 78
    ##  35 Vala (Programmiersprache)                                    de    2.87e- 77
    ##  36 Boo (programming language)                                   en    4.38e- 77
    ##  37 Lua                                                          de    9.94e- 77
    ##  38 F Sharp (programming language)                               en    2.03e- 76
    ##  39 PHP                                                          de    1.97e- 75
    ##  40 Java (Programmiersprache)                                    de    1.18e- 74
    ##  41 QML                                                          en    1.34e- 74
    ##  42 Common Lisp                                                  de    2.29e- 74
    ##  43 Ada (Programmiersprache)                                     de    5.30e- 73
    ##  44 C-Sharp                                                      de    1.41e- 72
    ##  45 Python (programming language)                                en    3.85e- 72
    ##  46 PEARL                                                        de    3.87e- 72
    ##  47 Ruby (programming language)                                  en    3.92e- 72
    ##  48 XQuery                                                       de    4.73e- 71
    ##  49 SPARQL                                                       en    6.89e- 70
    ##  50 Go (programming language)                                    en    9.38e- 70
    ##  51 XSLT                                                         en    3.98e- 69
    ##  52 Hack (programming language)                                  en    1.92e- 68
    ##  53 XProc                                                        de    3.13e- 67
    ##  54 MATLAB                                                       en    4.76e- 67
    ##  55 DrRacket                                                     de    1.23e- 65
    ##  56 Tcllib                                                       de    1.56e- 65
    ##  57 Scala (programming language)                                 en    9.23e- 65
    ##  58 Squeak                                                       en    1.56e- 64
    ##  59 PHP                                                          en    2.24e- 64
    ##  60 Io (programming language)                                    en    3.50e- 64
    ##  61 OCaml                                                        en    5.50e- 64
    ##  62 Rebol                                                        en    3.25e- 63
    ##  63 Vala (programming language)                                  en    1.92e- 62
    ##  64 Objective-C                                                  de    2.59e- 62
    ##  65 C++                                                          en    2.71e- 62
    ##  66 Fortran                                                      en    3.25e- 61
    ##  67 Adenine                                                      de    5.17e- 61
    ##  68 COBOL                                                        de    1.67e- 60
    ##  69 Objective CAML                                               de    2.26e- 60
    ##  70 XQuery                                                       en    7.76e- 60
    ##  71 NewLISP                                                      de    3.05e- 58
    ##  72 Lout                                                         de    8.52e- 58
    ##  73 Opal (programming language)                                  en    1.47e- 57
    ##  74 Racket (programming language)                                en    2.26e- 57
    ##  75 C Sharp (programming language)                               en    3.14e- 57
    ##  76 Pharo                                                        en    8.07e- 57
    ##  77 Tcl                                                          de    9.30e- 57
    ##  78 Lisp                                                         de    1.81e- 56
    ##  79 Haskell (programming language)                               en    4.00e- 55
    ##  80 Gofer (programming language)                                 en    8.21e- 55
    ##  81 Smalltalk (Programmiersprache)                               de    1.16e- 54
    ##  82 Adenine (programming language)                               en    6.03e- 53
    ##  83 Ruby (Programmiersprache)                                    de    7.90e- 53
    ##  84 Smalltalk                                                    en    2.00e- 52
    ##  85 C (programming language)                                     en    3.90e- 52
    ##  86 Python (Programmiersprache)                                  de    3.19e- 51
    ##  87 MetaPost                                                     de    3.74e- 51
    ##  88 Fortran                                                      de    5.96e- 51
    ##  89 Ada (programming language)                                   en    3.77e- 50
    ##  90 Erlang (programming language)                                en    9.70e- 50
    ##  91 Clean (programming language)                                 en    1.20e- 49
    ##  92 Standard ML                                                  en    1.48e- 49
    ##  93 D (programming language)                                     en    7.29e- 49
    ##  94 Euler (programming language)                                 en    1.77e- 48
    ##  95 Perl                                                         en    3.90e- 48
    ##  96 Scala (Programmiersprache)                                   de    4.15e- 48
    ##  97 SQL                                                          en    4.50e- 48
    ##  98 Haskell (Programmiersprache)                                 de    1.19e- 47
    ##  99 ISWIM                                                        en    1.94e- 47
    ## 100 Miranda (programming language)                               en    2.09e- 46
    ## 101 ATS (programming language)                                   en    1.53e- 45
    ## 102 Io (Programmiersprache)                                      de    3.85e- 45
    ## 103 Mercury (programming language)                               en    4.23e- 45
    ## 104 Perl (Programmiersprache)                                    de    5.68e- 45
    ## 105 F-Sharp                                                      de    9.56e- 45
    ## 106 Lisp (programming language)                                  en    2.21e- 44
    ## 107 Paul Graham (computer programmer)                            en    3.17e- 44
    ## 108 Gofer                                                        de    3.69e- 44
    ## 109 Matlab                                                       de    5.11e- 44
    ## 110 Erlang (Programmiersprache)                                  de    1.43e- 43
    ## 111 XProc                                                        en    6.63e- 43
    ## 112 APL (programming language)                                   en    1.30e- 42
    ## 113 COBOL                                                        en    2.56e- 42
    ## 114 Miranda (Programmiersprache)                                 de    1.16e- 41
    ## 115 Lout (software)                                              en    5.72e- 41
    ## 116 Euler (Programmiersprache)                                   de    6.65e- 41
    ## 117 SuperCollider                                                en    6.80e- 41
    ## 118 Prolog                                                       en    1.97e- 40
    ## 119 Julia (programming language)                                 en    5.45e- 40
    ## 120 APL (Programmiersprache)                                     de    3.15e- 39
    ## 121 SQL                                                          de    7.29e- 39
    ## 122 PEARL (programming language)                                 en    2.05e- 38
    ## 123 MetaPost                                                     en    2.33e- 38
    ## 124 Metafont                                                     en    2.42e- 38
    ## 125 Lustre (programming language)                                en    1.59e- 37
    ## 126 Modelica                                                     en    2.06e- 37
    ## 127 Mercury (Programmiersprache)                                 de    2.80e- 37
    ## 128 Oz (programming language)                                    en    3.54e- 36
    ## 129 Datalog                                                      en    3.58e- 36
    ## 130 REBOL                                                        de    4.66e- 36
    ## 131 Logo (programming language)                                  en    2.14e- 35
    ## 132 J (Programmiersprache)                                       de    4.18e- 35
    ## 133 Go (Programmiersprache)                                      de    6.19e- 35
    ## 134 CycL                                                         en    7.74e- 35
    ## 135 Self (Programmiersprache)                                    de    1.50e- 34
    ## 136 SPARQL                                                       de    1.94e- 34
    ## 137 Curl (Programmiersprache)                                    de    2.30e- 34
    ## 138 ML (programming language)                                    en    3.70e- 34
    ## 139 Julia (Programmiersprache)                                   de    8.39e- 34
    ## 140 Self (programming language)                                  en    8.96e- 34
    ## 141 CycL                                                         de    1.72e- 33
    ## 142 MUMPS                                                        en    4.57e- 33
    ## 143 ML (Programmiersprache)                                      de    1.17e- 32
    ## 144 F-logic                                                      en    4.64e- 32
    ## 145 F-Logic                                                      de    1.50e- 31
    ## 146 Hack (Programmiersprache)                                    de    2.76e- 31
    ## 147 Standard ML                                                  de    3.55e- 31
    ## 148 J (programming language)                                     en    6.18e- 31
    ## 149 Opal (Programmiersprache)                                    de    1.12e- 30
    ## 150 Strongtalk                                                   en    1.82e- 30
    ## 151 Strongtalk                                                   de    1.51e- 29
    ## 152 Web Ontology Language                                        de    2.98e- 29
    ## 153 Prolog (Programmiersprache)                                  de    4.82e- 29
    ## 154 R (programming language)                                     en    1.08e- 28
    ## 155 D (Programmiersprache)                                       de    1.33e- 28
    ## 156 Coq                                                          en    1.50e- 27
    ## 157 Squeak                                                       de    1.89e- 27
    ## 158 MUMPS                                                        de    1.56e- 26
    ## 159 Maple (software)                                             en    1.82e- 26
    ## 160 SuperCollider                                                de    7.74e- 25
    ## 161 Maple (Software)                                             de    8.64e- 24
    ## 162 Applied Type System                                          de    2.06e- 23
    ## 163 Web Ontology Language                                        en    2.32e- 23
    ## 164 Logo (Programmiersprache)                                    de    1.88e- 22
    ## 165 Clean (Programmiersprache)                                   de    2.67e- 21
    ## 166 Joy (programming language)                                   en    7.22e- 21
    ## 167 METAFONT                                                     de    1.44e- 19
    ## 168 Modelica                                                     de    2.35e- 19
    ## 169 Datalog                                                      de    4.73e- 19
    ## 170 Paul Graham                                                  de    8.59e- 17
    ## 171 ISWIM                                                        de    8.66e- 16
    ## 172 R (Programmiersprache)                                       de    4.41e- 13
    ## 173 Joy (Programmiersprache)                                     de    7.50e- 10
    ## 174 Coq (Software)                                               de    1.61e-  9
    ## 175 Fagus Factory                                                en    1.00e+  0
    ## 176 Bauhaus                                                      en    1.00e+  0
    ## 177 Haus am Horn                                                 en    1.00e+  0
    ## 178 Berlin Modernism Housing Estates                             en    1.00e+  0
    ## 179 Martin Luther's Birth House                                  en    1.00e+  0
    ## 180 Musterhaus Am Horn                                           de    1.00e+  0
    ## 181 Bauhaus                                                      de    1.00e+  0
    ## 182 Prehistoric pile dwellings around the Alps                   en    1.00e+  0
    ## 183 Klassisches Weimar                                           de    1.00e+  0
    ## 184 Limes (Grenzwall)                                            de    1.00e+  0
    ## 185 Grube Messel                                                 de    1.00e+  0
    ## 186 Bauhaus Dessau Foundation                                    en    1.00e+  0
    ## 187 Limes                                                        en    1.00e+  0
    ## 188 Siedlungen der Berliner Moderne                              de    1.00e+  0
    ## 189 Hufeisensiedlung                                             en    1.00e+  0
    ## 190 Kulturlandschaft Dresdner Elbtal                             de    1.00e+  0
    ## 191 Dessau-Wörlitz Garden Realm                                  en    1.00e+  0
    ## 192 Sanssouci                                                    en    1.00e+  0
    ## 193 Zollverein Coal Mine Industrial Complex                      en    1.00e+  0
    ## 194 Lutherhaus                                                   en    1.00e+  0
    ## 195 Weimar                                                       en    1.00e+  0
    ## 196 Igel Column                                                  en    1.00e+  0
    ## 197 Wismar                                                       de    1.00e+  0
    ## 198 Bamberg                                                      de    1.00e+  0
    ## 199 Trier                                                        de    1.00e+  0
    ## 200 Nationalpark Niedersächsisches Wattenmeer                    de    1.00e+  0
    ## 201 Wittenberg                                                   en    1.00e+  0
    ## 202 Goslar                                                       de    1.00e+  0
    ## 203 Margravial Opera House                                       en    1.00e+  0
    ## 204 Maulbronn Monastery                                          en    1.00e+  0
    ## 205 Weimar                                                       de    1.00e+  0
    ## 206 Wismar                                                       en    1.00e+  0
    ## 207 Bremer Rathaus                                               de    1.00e+  0
    ## 208 Würzburg Residence                                           en    1.00e+  0
    ## 209 Glienicke Palace                                             en    1.00e+  0
    ## 210 New Garden, Potsdam                                          en    1.00e+  0
    ## 211 Upper Harz Water Regale                                      en    1.00e+  0
    ## 212 Kloster Maulbronn                                            de    1.00e+  0
    ## 213 Speyer Cathedral                                             en    1.00e+  0
    ## 214 Lorch, Hesse                                                 en    1.00e+  0
    ## 215 Konstantinbasilika                                           de    1.00e+  0
    ## 216 Welterbe in Deutschland                                      de    1.00e+  0
    ## 217 Barbara Baths                                                en    1.00e+  0
    ## 218 Lübeck                                                       de    1.00e+  0
    ## 219 Herkules (Kassel)                                            de    1.00e+  0
    ## 220 Lübeck                                                       en    1.00e+  0
    ## 221 Oberharzer Wasserregal                                       de    1.00e+  0
    ## 222 Sanssouci                                                    de    1.00e+  0
    ## 223 Kaiserthermen (Trier)                                        de    1.00e+  0
    ## 224 Rammelsberg                                                  en    1.00e+  0
    ## 225 Ingelheimer Kaiserpfalz                                      de    1.00e+  0
    ## 226 Babelsberg                                                   en    1.00e+  0
    ## 227 Heilandskirche am Port von Sacrow                            de    1.00e+  0
    ## 228 Wattenmeer (Nordsee)                                         de    1.00e+  0
    ## 229 Porta Nigra                                                  en    1.00e+  0
    ## 230 Pfaueninsel                                                  en    1.00e+  0
    ## 231 Hildesheimer Dom                                             de    1.00e+  0
    ## 232 Stadtkirche Lutherstadt Wittenberg                           de    1.00e+  0
    ## 233 Dessau-Wörlitzer Gartenreich                                 de    1.00e+  0
    ## 234 Hercules monument (Kassel)                                   en    1.00e+  0
    ## 235 Prähistorische Pfahlbauten um die Alpen                      de    1.00e+  0
    ## 236 Museum Island                                                en    1.00e+  0
    ## 237 Aula Palatina                                                en    1.00e+  0
    ## 238 Muskau Park                                                  en    1.00e+  0
    ## 239 Welterbe Römische Baudenkmäler, Dom und Liebfrauenkirche in… de    1.00e+  0
    ## 240 Großsiedlung Siemensstadt                                    en    1.00e+  0
    ## 241 Zeche Zollverein                                             de    1.00e+  0
    ## 242 Bergpark Wilhelmshöhe                                        en    1.00e+  0
    ## 243 Melanchthonhaus (Wittenberg)                                 en    1.00e+  0
    ## 244 Reichenau (Insel)                                            de    1.00e+  0
    ## 245 Stiftung Bauhaus Dessau                                      de    1.00e+  0
    ## 246 Goslar                                                       en    1.00e+  0
    ## 247 Aachen Cathedral Treasury                                    en    1.00e+  0
    ## 248 Kloster Lorsch                                               de    1.00e+  0
    ## 249 Trier Amphitheater                                           en    1.00e+  0
    ## 250 Eibingen Abbey                                               en    1.00e+  0
    ## 251 Roman Monuments, Cathedral of St. Peter and Church of Our L… en    1.00e+  0
    ## 252 Rammelsberg                                                  de    1.00e+  0
    ## 253 Lutherstadt Eisleben                                         de    1.00e+  0
    ## 254 Porta Nigra                                                  de    1.00e+  0
    ## 255 Trierer Dom                                                  de    1.00e+  0
    ## 256 Reichenau Island                                             en    1.00e+  0
    ## 257 Trier                                                        en    1.00e+  0
    ## 258 Lower Saxon Wadden Sea National Park                         en    1.00e+  0
    ## 259 Dresden Elbe Valley                                          en    1.00e+  0
    ## 260 Trier Imperial Baths                                         en    1.00e+  0
    ## 261 Wartburg                                                     en    1.00e+  0
    ## 262 Bremen City Hall                                             en    1.00e+  0
    ## 263 Speyerer Dom                                                 de    1.00e+  0
    ## 264 Holstentor                                                   de    1.00e+  0
    ## 265 Primeval Beech Forests of the Carpathians and the Ancient B… en    1.00e+  0
    ## 266 Eisleben                                                     en    1.00e+  0
    ## 267 Neuer Garten Potsdam                                         de    1.00e+  0
    ## 268 Regensburg                                                   de    1.00e+  0
    ## 269 Palaces and Parks of Potsdam and Berlin                      en    1.00e+  0
    ## 270 Fagus-Werk                                                   de    1.00e+  0
    ## 271 Martin Luther's Death House                                  en    1.00e+  0
    ## 272 Quedlinburg                                                  en    1.00e+  0
    ## 273 Messel pit                                                   en    1.00e+  0
    ## 274 Lorch (Rheingau)                                             de    1.00e+  0
    ## 275 Bamberg                                                      en    1.00e+  0
    ## 276 Cologne Cathedral                                            en    1.00e+  0
    ## 277 List of World Heritage Sites in Germany                      en    1.00e+  0
    ## 278 Museumsinsel (Berlin)                                        de    1.00e+  0
    ## 279 Wieskirche                                                   de    1.00e+  0
    ## 280 Augusteum und Lutherhaus Wittenberg                          de    1.00e+  0
    ## 281 Imperial Palace of Goslar                                    en    1.00e+  0
    ## 282 Lutherstadt Wittenberg                                       de    1.00e+  0
    ## 283 Schlösser und Gärten von Potsdam und Berlin                  de    1.00e+  0
    ## 284 Fürst-Pückler-Park Bad Muskau                                de    1.00e+  0
    ## 285 Stadtkirche Wittenberg                                       en    1.00e+  0
    ## 286 Bremen Roland                                                en    1.00e+  0
    ## 287 Buchenurwälder in den Karpaten und alte Buchenwälder in Deu… de    1.00e+  0
    ## 288 Kaiserpfalz Goslar                                           de    1.00e+  0
    ## 289 Stralsund                                                    de    1.00e+  0
    ## 290 Lorsch Abbey                                                 en    1.00e+  0
    ## 291 Babelsberg Palace                                            en    1.00e+  0
    ## 292 Pfaueninsel                                                  de    1.00e+  0
    ## 293 Obergermanisch-Raetischer Limes#Der Limes heute              de    1.00e+  0
    ## 294 Nationalpark Schleswig-Holsteinisches Wattenmeer             de    1.00e+  0
    ## 295 Abtei St. Hildegard (Rüdesheim am Rhein)                     de    1.00e+  0
    ## 296 Völklingen Ironworks                                         en    1.00e+  0
    ## 297 Rüdesheim am Rhein                                           de    1.00e+  0
    ## 298 Cathedral of Trier                                           en    1.00e+  0
    ## 299 Großsiedlung Siemensstadt                                    de    1.00e+  0
    ## 300 Schlösser Augustusburg und Falkenlust                        de    1.00e+  0
    ## 301 Wartburg                                                     de    1.00e+  0
    ## 302 Quedlinburg                                                  de    1.00e+  0
    ## 303 Babelsberg                                                   de    1.00e+  0
    ## 304 Igeler Säule                                                 de    1.00e+  0
    ## 305 St. Michael's Church, Hildesheim                             en    1.00e+  0
    ## 306 Würzburger Residenz                                          de    1.00e+  0
    ## 307 Imperial Palace Ingelheim                                    en    1.00e+  0
    ## 308 Liebfrauenkirche (Trier)                                     de    1.00e+  0
    ## 309 Stift Corvey                                                 de    1.00e+  0
    ## 310 Wieskirche                                                   en    1.00e+  0
    ## 311 Classical Weimar (World Heritage Site)                       en    1.00e+  0
    ## 312 Wadden Sea                                                   en    1.00e+  0
    ## 313 Kölner Dom                                                   de    1.00e+  0
    ## 314 Imperial Abbey of Corvey                                     en    1.00e+  0
    ## 315 Schloss Glienicke                                            de    1.00e+  0
    ## 316 Liebfrauenkirche, Trier                                      en    1.00e+  0
    ## 317 St. Michael (Hildesheim)                                     de    1.00e+  0
    ## 318 Rüdesheim am Rhein                                           en    1.00e+  0
    ## 319 Welterbe Kulturlandschaft Oberes Mittelrheintal              de    1.00e+  0
    ## 320 Bremer Roland                                                de    1.00e+  0
    ## 321 Hildesheim Cathedral                                         en    1.00e+  0
    ## 322 Limes Germanicus                                             en    1.00e+  0
    ## 323 Martin Luthers Sterbehaus                                    de    1.00e+  0
    ## 324 Rhine Gorge                                                  en    1.00e+  0
    ## 325 Martin Luthers Geburtshaus                                   de    1.00e+  0
    ## 326 Melanchthonhaus Wittenberg                                   de    1.00e+  0
    ## 327 Regensburg                                                   en    1.00e+  0
    ## 328 Aachener Dom                                                 de    1.00e+  0
    ## 329 Augustusburg and Falkenlust Palaces, Brühl                   en    1.00e+  0
    ## 330 Hufeisensiedlung                                             de    1.00e+  0
    ## 331 Völklinger Hütte                                             de    1.00e+  0
    ## 332 Aachen Cathedral                                             en    1.00e+  0
    ## 333 Schleswig-Holstein Wadden Sea National Park                  en    1.00e+  0
    ## 334 Markgräfliches Opernhaus                                     de    1.00e+  0
    ## 335 Schloss Babelsberg                                           de    1.00e+  0
    ## 336 Amphitheater (Trier)                                         de    1.00e+  0
    ## 337 Bergpark Wilhelmshöhe                                        de    1.00e+  0
    ## 338 Barbarathermen                                               de    1.00e+  0
    ## 339 Church of the Redeemer, Sacrow                               en    1.00e+  0
    ## 340 Holstentor                                                   en    1.00e+  0
    ## 341 Aachener Domschatzkammer                                     de    1.00e+  0
    ## 342 Stralsund                                                    en    1.00e+  0
