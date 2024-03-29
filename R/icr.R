#' Perform an intercoder reliability test
#'
#' Performs an intercoder reliability test by computing various intercoder
#' reliability estimates for the included variables
#'
#' @param data a [tibble][tibble::tibble-package] or a [tdcmm] model
#' @param unit_var Variable with unit identifiers
#' @param coder_var Variable with coder identifiers
#' @param ... Variables to compute intercoder reliability estimates for. Leave
#'   empty to compute for all variables (excluding `unit_var` and `coder_var``)
#'   in data.
#' @param levels Optional named vector with levels of test variables
#' @param na.omit Logical indicating whether `NA` values should be stripped
#'   before computation. Defaults to `FALSE`.
#' @param agreement Logical indicating whether simple percent agreement should
#'   be computed. Defaults to `TRUE`.
#' @param holsti Logical indicating whether Holsti's reliability estimate
#'   (mean pairwise agreement) should be computed. Defaults to `TRUE`.
#' @param kripp_alpha Logical indicating whether Krippendorff's Alpha should
#'   be computed. Defaults to `TRUE`.
#' @param cohens_kappa Logical indicating whether Cohen's Kappa should
#'   be computed. Defaults to `FALSE`.
#' @param fleiss_kappa Logical indicating whether Fleiss' Kappa should
#'   be computed. Defaults to `FALSE`.
#' @param brennan_prediger Logical indicating whether Brennan & Prediger's Kappa
#'   should be computed (extension to 3+ coders as proposed by von Eye (2006)).
#'   Defaults to `FALSE`.
#' @param lotus Logical indicating whether Fretwurst's Lotus should be
#'   computed. Defaults to `FALSE`
#' @param s_lotus Logical indicating whether Fretwurst's standardized Lotus
#'   (S-Lotus) should be computed. Defaults to `FALSE`.
#'
#' @return a [tdcmm] model
#'
#' @examples
#' fbposts %>% test_icr(post_id, coder_id, pop_elite, pop_othering)
#' fbposts %>% test_icr(post_id, coder_id, levels = c(n_pictures = "ordinal"), fleiss_kappa = TRUE)
#'
#' @family intercoder reliability
#'
#' @export
#'
#' @references Brennan, R. L., & Prediger, D. J. (1981). Coefficient Kappa: Some
#'   uses, misuses, and alternatives. Educational and Psychological Measurement,
#'   41(3), 687-699. https://doi.org/10.1177/001316448104100307
#'
#'   Cohen, J. (1960). A coefficient of agreement for nominal scales.
#'   Educational and Psychological Measurement, 20(1), 37-46.
#'   https://doi.org/10.1177/001316446002000104
#'
#'   Fleiss, J. L. (1971). Measuring nominal scale agreement among many raters.
#'   Psychological Bulletin, 76(5), 378-382. https://doi.org/10.1037/h0031619
#'
#'   Fretwurst, B. (2015). Reliabilität und Validität von Inhaltsanalysen.
#'   Mit Erläuterungen zur Berechnung des Reliabilitätskoeffizienten „Lotus“ mit SPSS.
#'   In W. Wirth, K. Sommer, M. Wettstein, & J. Matthes (Ed.),
#'   Qualitätskriterien in der Inhaltsanalyse (S. 176–203). Herbert von Halem.
#'
#'   Krippendorff, K. (2011). Computing Krippendorff's Alpha-Reliability.
#'   Retrieved from http://repository.upenn.edu/asc_papers/43
#'
#'   von Eye, A. (2006). An Alternative to Cohen's Kappa. European Psychologist, 11(1),
#'   12-24. https://doi.org/10.1027/1016-9040.11.1.12
test_icr <- function(data, unit_var, coder_var, ...,
                     levels = NULL, na.omit = FALSE,
                     agreement = TRUE, holsti = TRUE, kripp_alpha = TRUE,
                     cohens_kappa = FALSE, fleiss_kappa = FALSE, brennan_prediger = FALSE,
                     lotus = FALSE, s_lotus = FALSE
) {

  # Check if unit_var and coder_var are provided
  if (missing(unit_var) | missing(coder_var)) {
    stop("Please provide both a variable with unit identifiers and a variable with coder identifiers.")
  }

  exclude_vars <- c(as_label(expr({{ unit_var }})), as_label(expr({{ coder_var }})))
  test_vars <- grab_vars(data, enquos(...), alternative = "all", exclude_vars = exclude_vars)
  test_vars_str <- purrr::map_chr(test_vars, as_label)

  # If the data is grouped, use group_map function
  if (dplyr::is.grouped_df(data)) {
    out <- data %>% dplyr::group_map(.f = function(.x, .y) {
      tmp_out <- purrr::map_dfr(test_vars, compute_icr, .x, {{ unit_var }}, {{ coder_var }},
                                levels, na.omit,
                                agreement, holsti, kripp_alpha, cohens_kappa, fleiss_kappa, brennan_prediger,
                                lotus, s_lotus)
      # Add the group variable to the resulting data frames
      dplyr::mutate(tmp_out, group = .y[[1]])
    })
    # Bind all data frames together and reorder resulting data frame
    out <- dplyr::bind_rows(out) %>%
      dplyr::select(group, tidyselect::everything())
  } else {
    # Map icr computation over test_vars
    out <- purrr::map_dfr(test_vars, compute_icr, data, {{ unit_var }}, {{ coder_var }},
                          levels, na.omit,
                          agreement, holsti, kripp_alpha, cohens_kappa, fleiss_kappa, brennan_prediger,
                          lotus, s_lotus)
  }

  # Output
  return(new_tdcmm(out,
                   func = "test_icr",
                   data = data,
                   params = list(unit_var = as_name(enquo(unit_var)),
                                 coder_var = as_name(enquo(coder_var)),
                                 vars = test_vars_str,
                                 levels = levels,
                                 na.omit = na.omit,
                                 agreement = agreement,
                                 holsti = holsti,
                                 kripp_alpha = kripp_alpha,
                                 cohens_kappa = cohens_kappa,
                                 fleiss_kappa = fleiss_kappa,
                                 brennan_prediger = brennan_prediger,
                                 lotus = lotus,
                                 s_lotus = s_lotus)))
}

### Internal functions ###

## Compute intercoder reliability estimates for one test variable
##
## Computes intercoder reliability estimates for one test variable
##
## @param test_var Variable to compute estimates for
## @inheritParams test_icr
##
## @family intercoder reliability
##
## @keywords internal
compute_icr <- function(test_var, data, unit_var, coder_var,
                        levels = c(), na.omit = FALSE,
                        agreement = TRUE, holsti = TRUE, kripp_alpha = TRUE,
                        cohens_kappa = FALSE, fleiss_kappa = FALSE, brennan_prediger = FALSE,
                        lotus = FALSE, s_lotus = FALSE) {

  ucm <- unit_coder_matrix(data, {{ unit_var }}, {{ coder_var }}, {{ test_var}})

  # Check ucm
  if (length(na.omit(ucm)) == 0) {
    stop("Empty units-coders matrix detected. ",
         "This is most likely due to none of the units having been coded by all coders. ",
         "See vignette('v04_icr') for details.", call. = FALSE)
  }

  # Get variable level
  var_string <- as_name(enquo(test_var))
  if (hasName(levels, var_string)) {
    var_level <- levels[[var_string]]

    if (!var_level %in% c("nominal", "ordinal", "interval", "ratio")) {
      stop("Variable level must be one of 'nominal', 'ordinal', 'interval', or 'ratio'.")
    }

  } else {
    var_level <- "nominal"
  }

  # Check for missing values
  if (any(is.na(ucm))) {
    if (na.omit) {
      ucm <- na.omit(ucm)
    } else {
      warning(glue("Variable '{var_string}' contains missing values.",
                   "Consider setting na.omit = TRUE or recoding missing values",
                   .sep = " "),
              call. = FALSE)
    }
  }

  # List descriptives
  test_vals <- tibble::tibble(
    Variable = var_string,
    n_Units = dim(ucm)[1],
    n_Coders = dim(ucm)[2],
    n_Categories = length(unique(na.omit(as.vector(ucm)))),
    Level = var_level
  )

  # Compute reliability estimates
  if (agreement) {
    test_vals <- test_vals %>%
      dplyr::bind_cols(
        Agreement = icr_agreement(ucm)
      )
  }

  if (holsti) {
    test_vals <- test_vals %>%
      dplyr::bind_cols(
        Holstis_CR = icr_holstis_CR(ucm)
      )
  }

  if (kripp_alpha) {
    test_vals <- test_vals %>%
      dplyr::bind_cols(
        Krippendorffs_Alpha = icr_kripp_alpha(ucm, var_level)
      )
  }

  if (cohens_kappa) {
    test_vals <- test_vals %>%
      dplyr::bind_cols(
        Cohens_Kappa = icr_cohens_kappa(ucm)
      )
  }

  if (fleiss_kappa) {
    test_vals <- test_vals %>%
      dplyr::bind_cols(
        Fleiss_Kappa = icr_fleiss_kappa(ucm)
      )
  }

  if (brennan_prediger) {
    test_vals <- test_vals %>%
      dplyr::bind_cols(
        Brennan_Predigers_Kappa = icr_brennan_prediger(ucm)
      )
  }

  if (lotus) {
    test_vals <- test_vals %>%
      dplyr::bind_cols(
        Lotus = icr_lotus(ucm)
      )
  }

  if (s_lotus) {
    test_vals <- test_vals %>%
      dplyr::bind_cols(
        S_Lotus = icr_lotus(ucm, standardize = TRUE)
      )
  }


  test_vals
}

## Generate units-coders matrix
##
## Generates a units-coders matrix for a test variable
##
## @inheritParams compute_icr
##
## @family intercoder reliability
##
## @keywords internal
unit_coder_matrix <- function(data, unit_var, coder_var, test_var) {

  data %>%
    dplyr::select({{ unit_var }}, {{ coder_var }}, {{ test_var }}) %>%
    tidyr::spread({{ coder_var }}, {{ test_var }}) %>%
    dplyr::select(-1) %>%
    as.matrix()
}
