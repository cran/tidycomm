## ---- include = FALSE----------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>"
)

## ----setup, message = FALSE, warning = FALSE, include = FALSE------------
library(tidycomm)

## ------------------------------------------------------------------------
fbposts

## ------------------------------------------------------------------------
fbposts %>% 
  test_icr(post_id, coder_id, pop_elite, pop_people, pop_othering)

## ------------------------------------------------------------------------
fbposts %>% 
  test_icr(post_id, coder_id)

## ------------------------------------------------------------------------
fbposts %>% 
  test_icr(post_id, coder_id, fleiss_kappa = TRUE, agreement = FALSE)

## ------------------------------------------------------------------------
fbposts %>% 
  test_icr(post_id, coder_id, levels = c(n_pictures = "ordinal"))

## ------------------------------------------------------------------------
# Introduce some missing values
fbposts$type[1] <- NA
fbposts$type[2] <- NA
fbposts$pop_elite[5] <- NA

fbposts %>% 
  test_icr(post_id, coder_id)

## ------------------------------------------------------------------------
fbposts %>% 
  test_icr(post_id, coder_id, na.omit = TRUE)

