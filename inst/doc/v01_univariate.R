## ---- include = FALSE----------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>"
)

## ----setup, message = FALSE, warning = FALSE, include = FALSE------------
library(tidycomm)

## ------------------------------------------------------------------------
WoJ

## ------------------------------------------------------------------------
WoJ %>% 
  describe(autonomy_selection, autonomy_emphasis, work_experience)

## ------------------------------------------------------------------------
WoJ %>% 
  describe()

## ------------------------------------------------------------------------
WoJ %>% 
  dplyr::group_by(country) %>% 
  describe(autonomy_emphasis, autonomy_selection)

## ------------------------------------------------------------------------
WoJ %>% 
  tab_frequencies(employment)

## ------------------------------------------------------------------------
WoJ %>% 
  tab_frequencies(employment, country)

## ------------------------------------------------------------------------
WoJ %>% 
  dplyr::group_by(country) %>% 
  tab_frequencies(employment)
