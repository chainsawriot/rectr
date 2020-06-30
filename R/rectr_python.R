### heavily inspired by
## https://github.com/quanteda/spacyr/blob/master/R/spacy_install.R
## https://github.com/bnosac/golgotha/blob/master/R/embed.R

.bert_cleanse <- function(text, lang) {
    quanteda::tokens(text) %>% quanteda::tokens_remove(quanteda::stopwords(lang)) %>% paste(collapse = " ")
}


.have_conda <- function() {
    is.null(tryCatch(reticulate::conda_binary(conda), error = function(e) NULL))
}

#' @export
mbert_env_setup <- function(envname = "rectr_condaenv") {
    if (!.have_conda()) {
        cat("No conda was found in this system.")
        ans <- utils::menu(c("No", "Yes"), title = paste0("Do you want to install miniconda in ", miniconda_path()))
        if (ans == 1) {
            stop("Setup aborted.\n")
        } else {
            reticulate::install_miniconda()
        }
    }
    if (envname %in% reticulate::conda_list()$name) {
        stop(paste0("Conda environment ", envname, " already exists.\n"))
    }
    ## The actual installation
    ## https://github.com/rstudio/reticulate/issues/779
    system2("conda", args = c("env", "create",  paste0("-f=", system.file("python", "rectr.yml", package = 'rectr')), "-n", envname))
}


.initialize_conda <- function(envname = "rectr_condaenv", noise = TRUE) {
    if (is.null(getOption('python_init'))) {
        reticulate::use_miniconda(envname, required = TRUE)
        options('python_init' = TRUE)
        if (noise) {
            print(paste0("Conda environment ", envname, " is initialized.\n"))
        }
    }
}

#' @export
download_mbert <- function(path = "./", envname = "rectr_condaenv", noise = TRUE) {
    .initialize_conda(envname, noise = noise)
    reticulate::source_python(system.file("python", "bert.py", package = 'rectr'))
    bert_download(normalizePath(path))
}

.bert_emb <- function(content, bert_instance, max_length, noise) {
    bert_instance$embedding(content = content, max_length = max_length, noise = noise)
}

.bert <- function(content, lang, path = "./", noise = FALSE, remove_stopwords = TRUE, max_length = 512L, bert_sentence_tokenization = TRUE, envname = "rectr_condaenv") {
    if (remove_stopwords) {
        content <- purrr::map2_chr(content, lang, .bert_cleanse)
    }
    if (bert_sentence_tokenization) {
        sentences <- tokenizers::tokenize_sentences(content)
    } else {
        sentences <- purrr::map(content, ~ list(.))
    }
    ## loading Python
    .initialize_conda(envname = envname, noise = noise)
    ##reticulate::source_python(system.file("python", "bert.py", package = 'rectr'))
    bert_model <- reticulate::import_from_path("bert", system.file("python", package = "rectr"))
    if (!.have_bert(path)) {
        stop("BERT model not found. Please download it with: download_mbert()")
    }
    bert_instance <- bert_model$MBERT(path = normalizePath(path))
    list_of_embedding <- purrr::map(sentences, .bert_emb, bert_instance = bert_instance, max_length = max_length, noise = noise)
    dfm_bert <- do.call(rbind, list_of_embedding)
    return(dfm_bert)
}

.have_bert <- function(path) {
    "config.json" %in% list.files(normalizePath(path)) & "pytorch_model.bin" %in% list.files(normalizePath(path))
}
