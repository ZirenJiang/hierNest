#' Extract subgroup-specific coefficients from a cv.hierNest object
#'
#' @description
#' Computes the composite subgroup-specific coefficient vectors from a
#' cross-validated hierarchical nested model. Each subgroup's coefficient
#' is the sum of the overall mean effect, its group (MDC) effect, and its
#' subgroup (DRG) effect: \eqn{\beta^{(s)} = \beta^{overall} + \beta^{group} + \beta^{subgroup}}.
#'
#' @param object A fitted \code{\link{cv.hierNest}} object.
#' @param s Value of the penalty parameter \code{lambda} at which coefficients
#'   are extracted. Either \code{"lambda.min"} (default, the lambda that minimizes
#'   CV error) or \code{"lambda.1se"} (largest lambda within 1 SE of the minimum).
#' @param type Character string specifying the format of the returned coefficients.
#'   \code{"subgroup"} (default) returns the composite subgroup-specific coefficients
#'   (one row per subgroup). \code{"hierarchical"} returns the raw hierarchical
#'   parameterization (overall, group, and subgroup effect rows).
#' @param ... Not used.
#'
#' @return A numeric matrix of coefficients. Columns correspond to covariates
#'   (including \code{"Intercept"}). For \code{type = "subgroup"}, rows are named
#'   by subgroup ID. For \code{type = "hierarchical"}, rows are labeled with
#'   overall, group, and subgroup identifiers.
#'
#' @seealso \code{\link{cv.hierNest}}, \code{\link{plot_contribution}}
#' @method coef cv.hierNest
#' @export
coef.cv.hierNest <- function(object,
                             s = c("lambda.min", "lambda.1se"),
                             type = c("subgroup", "hierarchical"),
                             ...) {
  s <- match.arg(s)
  type <- match.arg(type)

  lambda_val <- object[[s]]
  cvinx <- which(object$hierNest.fit$lambda == lambda_val)

  hier_info <- object$hier.info
  n_groups <- length(unique(hier_info[, 1]))
  n_subgroups <- length(unique(hier_info[, 2]))
  n_row <- 1 + n_groups + n_subgroups

  beta_mat <- matrix(as.numeric(object$hierNest.fit$beta[, cvinx]),
                     nrow = n_row)

  if (is.null(object$X.names)) {
    colnames(beta_mat) <- c("Intercept",
                            paste0("X", seq_len(ncol(beta_mat) - 1)))
  } else {
    colnames(beta_mat) <- c("Intercept", object$X.names)
  }

  # Build row names for the hierarchical parameterization
  rowname_hier <- "Overall"
  for (g in unique(hier_info[, 1])) {
    rowname_hier <- c(rowname_hier, paste0("Group ", g))
    subs <- unique(hier_info[which(hier_info[, 1] == g), 2])
    for (sg in subs) {
      rowname_hier <- c(rowname_hier, paste0("Subgroup ", sg))
    }
  }
  rownames(beta_mat) <- rowname_hier

  if (type == "hierarchical") {
    return(beta_mat)
  }

  # Compute composite subgroup coefficients: overall + group + subgroup
  subgroup_coef <- matrix(nrow = n_subgroups, ncol = ncol(beta_mat))
  colnames(subgroup_coef) <- colnames(beta_mat)

  overall_effect <- beta_mat[1, ]
  ix_row <- 1
  ix_sub <- 1
  sub_labels <- character(n_subgroups)

  for (g in unique(hier_info[, 1])) {
    ix_row <- ix_row + 1
    group_effect <- beta_mat[ix_row, ]
    for (sg in unique(hier_info[which(hier_info[, 1] == g), 2])) {
      ix_row <- ix_row + 1
      subgroup_effect <- beta_mat[ix_row, ]
      subgroup_coef[ix_sub, ] <- overall_effect + group_effect + subgroup_effect
      sub_labels[ix_sub] <- paste0("Subgroup ", sg)
      ix_sub <- ix_sub + 1
    }
  }
  rownames(subgroup_coef) <- sub_labels

  subgroup_coef
}
