#' Boxplot or bar chart of per-covariate contributions to the linear predictor
#'
#' @description
#' For each subject, computes the contribution of each covariate to the linear
#' predictor as \eqn{x_j \cdot \beta_j}{x_j * beta_j}, where \eqn{\beta_j} is
#' the subject's subgroup-specific coefficient for covariate \eqn{j}.
#'
#' When no \code{subject_id} is supplied, produces a boxplot showing the
#' distribution of contributions across all subjects. When a single
#' \code{subject_id} is supplied, produces a bar chart for that subject.
#'
#' @param object A fitted \code{\link{cv.hierNest}} object.
#' @param newx Numeric matrix of predictor values (\eqn{n \times p}), with the
#'   same columns as the original training data.
#' @param hier_info Numeric matrix encoding the hierarchical structure for
#'   the subjects in \code{newx}. First column is group (MDC) membership;
#'   second column is subgroup (DRG) membership. Must have \code{nrow(newx)} rows.
#' @param s Value of \code{lambda} to use for coefficient extraction.
#'   Either \code{"lambda.min"} (default) or \code{"lambda.1se"}.
#' @param subject_id Optional. A row index (integer) or row name (character)
#'   identifying a single subject in \code{newx}. If provided, a bar chart of
#'   that subject's covariate contributions is returned instead of a boxplot.
#' @param top_n Optional integer. If provided, only the top \code{top_n}
#'   covariates (by median absolute contribution across subjects, or by absolute
#'   contribution for a single subject) are shown.
#' @param include_intercept Logical; if \code{TRUE}, include the intercept
#'   contribution as a separate covariate. Default is \code{FALSE}.
#'
#' @return A \code{ggplot2} object.
#'
#' @details
#' The function uses \code{\link{coef.cv.hierNest}} to obtain the composite
#' subgroup-specific coefficients. Each subject is mapped to their subgroup
#' via \code{hier_info}, and the element-wise product \eqn{x_j \beta_j}
#' quantifies how much each covariate contributes to that subject's predicted
#' risk (linear predictor scale).
#'
#' Covariates are ordered on the x-axis by descending median absolute
#' contribution (boxplot) or descending absolute contribution (bar chart),
#' so the most influential variables appear on the left.
#'
#' @seealso \code{\link{coef.cv.hierNest}}, \code{\link{cv.hierNest}}
#' @importFrom stats median coef setNames
#' @export
plot_contribution <- function(object,
                              newx,
                              hier_info,
                              s = c("lambda.min", "lambda.1se"),
                              subject_id = NULL,
                              top_n = NULL,
                              include_intercept = FALSE) {

  if (!inherits(object, "cv.hierNest")) {
    cli::cli_abort("{.arg object} must be a {.cls cv.hierNest} object.")
  }

  s <- match.arg(s)
  n <- nrow(newx)
  p <- ncol(newx)

  if (nrow(hier_info) != n) {
    cli::cli_abort(
      "{.arg hier_info} must have the same number of rows as {.arg newx}."
    )
  }

  # Resolve subject_id to a row index if provided
  if (!is.null(subject_id)) {
    if (is.character(subject_id)) {
      if (is.null(rownames(newx))) {
        cli::cli_abort(
          "{.arg newx} has no row names; supply {.arg subject_id} as an integer index."
        )
      }
      sid <- match(subject_id, rownames(newx))
      if (is.na(sid)) {
        cli::cli_abort("Subject {.val {subject_id}} not found in row names of {.arg newx}.")
      }
    } else {
      sid <- as.integer(subject_id)
      if (sid < 1 || sid > n) {
        cli::cli_abort("{.arg subject_id} must be between 1 and {n}.")
      }
    }
  }

  # Get composite subgroup-specific coefficients
  beta <- coef(object, s = s, type = "subgroup")

  # Build a lookup: subgroup ID -> row index in beta
  sub_ids <- as.integer(gsub("Subgroup ", "", rownames(beta)))
  sub_map <- setNames(seq_along(sub_ids), sub_ids)

  # Determine which columns to use
  if (include_intercept) {
    covar_names <- colnames(beta)
    x_aug <- cbind(1, newx)
  } else {
    covar_names <- colnames(beta)[-1]
    beta <- beta[, -1, drop = FALSE]
    x_aug <- newx
  }
  n_covar <- length(covar_names)

  # Compute contribution matrix: n subjects x n_covar
  contribution <- matrix(nrow = n, ncol = n_covar)
  colnames(contribution) <- covar_names

  for (i in seq_len(n)) {
    sg <- as.character(hier_info[i, 2])
    sg_row <- sub_map[[sg]]
    if (is.na(sg_row)) {
      cli::cli_abort(
        "Subgroup {sg} in {.arg hier_info} row {i} not found in fitted model."
      )
    }
    contribution[i, ] <- x_aug[i, ] * beta[sg_row, ]
  }

  # --- Single-subject bar chart ---
  if (!is.null(subject_id)) {
    subj_contrib <- contribution[sid, ]
    ord <- order(abs(subj_contrib), decreasing = TRUE)

    if (!is.null(top_n)) {
      ord <- ord[seq_len(min(top_n, n_covar))]
    }

    subj_contrib <- subj_contrib[ord]
    subj_label <- if (is.character(subject_id)) subject_id else paste("Subject", sid)

    df <- data.frame(
      Covariate = factor(names(subj_contrib), levels = names(subj_contrib)),
      Contribution = as.numeric(subj_contrib)
    )

    return(
      ggplot2::ggplot(df, ggplot2::aes(x = .data$Covariate,
                                       y = .data$Contribution)) +
        ggplot2::geom_col(fill = "steelblue", alpha = 0.7) +
        ggplot2::geom_hline(yintercept = 0, linetype = "dashed",
                            color = "grey40") +
        ggplot2::labs(
          title = subj_label,
          x = "Covariate (descending order of magnitude)",
          y = expression(x[j] %.% beta[j])
        ) +
        ggplot2::theme_bw() +
        ggplot2::theme(
          axis.text.x = ggplot2::element_text(angle = 45, hjust = 1)
        )
    )
  }

  # --- All-subject boxplot ---
  med_abs <- apply(contribution, 2, function(x) stats::median(abs(x)))
  ord <- order(med_abs, decreasing = TRUE)

  if (!is.null(top_n)) {
    top_n <- min(top_n, n_covar)
    ord <- ord[seq_len(top_n)]
  }

  contrib_ordered <- contribution[, ord, drop = FALSE]

  df <- data.frame(
    Covariate = rep(colnames(contrib_ordered), each = n),
    Contribution = as.vector(contrib_ordered)
  )
  df$Covariate <- factor(df$Covariate, levels = colnames(contrib_ordered))

  ggplot2::ggplot(df, ggplot2::aes(x = .data$Covariate,
                                   y = .data$Contribution)) +
    ggplot2::geom_boxplot(fill = "steelblue", alpha = 0.7, outlier.size = 0.8) +
    ggplot2::geom_hline(yintercept = 0, linetype = "dashed", color = "grey40") +
    ggplot2::labs(
      x = "Covariate (descending order of magnitude)",
      y = expression(x[j] %.% beta[j])
    ) +
    ggplot2::theme_bw() +
    ggplot2::theme(
      axis.text.x = ggplot2::element_text(angle = 45, hjust = 1)
    )
}
