## ---- include = FALSE---------------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>"
)

## ----setup, message = FALSE, warning = FALSE, include = FALSE-----------------
library(tidycomm)

## -----------------------------------------------------------------------------
WoJ

## -----------------------------------------------------------------------------
WoJ %>% 
  crosstab(reach, employment)

## -----------------------------------------------------------------------------
WoJ %>% 
  crosstab(reach, employment, add_total = TRUE, percentages = TRUE)

## -----------------------------------------------------------------------------
WoJ %>% 
  crosstab(reach, employment, chi_square = TRUE)

## -----------------------------------------------------------------------------
WoJ %>% 
  crosstab(reach, employment, country, percentages = TRUE)

## -----------------------------------------------------------------------------
WoJ %>% 
  t_test(temp_contract, autonomy_selection, autonomy_emphasis)

## -----------------------------------------------------------------------------
WoJ %>% 
  t_test(temp_contract)

## -----------------------------------------------------------------------------
WoJ %>% 
  t_test(employment, autonomy_selection, autonomy_emphasis)

WoJ %>% 
  t_test(employment, autonomy_selection, autonomy_emphasis, levels = c("Full-time", "Freelancer"))

## -----------------------------------------------------------------------------
WoJ %>% 
  unianova(employment, autonomy_selection, autonomy_emphasis)

## -----------------------------------------------------------------------------
WoJ %>% 
  unianova(employment, descriptives = TRUE)

## -----------------------------------------------------------------------------
WoJ %>% 
  unianova(employment, autonomy_selection, autonomy_emphasis, post_hoc = TRUE)

## -----------------------------------------------------------------------------
WoJ %>% 
  unianova(employment, autonomy_selection, autonomy_emphasis, post_hoc = TRUE) %>% 
  dplyr::select(Var, post_hoc) %>% 
  tidyr::unnest(post_hoc)

## -----------------------------------------------------------------------------
WoJ %>% 
  correlate(work_experience, autonomy_selection, autonomy_emphasis)

## -----------------------------------------------------------------------------
WoJ %>% 
  correlate()

## -----------------------------------------------------------------------------
WoJ %>% 
  correlate(work_experience, autonomy_selection, autonomy_emphasis) %>% 
  to_correlation_matrix()

