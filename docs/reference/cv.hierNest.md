# Cross-validated hierarchical nested regularization for subgroup models

Fits regularization paths for hierarchical subgroup-specific penalized
learning problems, leveraging nested group structure (such as Major
Diagnostic Categories \[MDC\] and Diagnosis-Related Groups \[DRG\]) with
options for lasso or overlapping group lasso penalties. Performs
cross-validation to select tuning parameters for penalization and
subgroup structure.

This function enables information sharing across related subgroups by
reparameterizing covariate effects into overall, group-specific, and
subgroup-specific components and supports structured shrinkage through
hierarchical regularization. Users may select between the lasso
(hierNest-Lasso) and overlapping group lasso (hierNest-OGLasso)
frameworks, as described in Jiang et al. (2024, submitted, see details
below).

## Usage

``` r
cv.hierNest(
  x,
  y,
  group = NULL,
  family = c("gaussian", "binomial"),
  nlambda = 100,
  lambda.factor = NULL,
  pred.loss = c("default", "mse", "deviance", "mae", "misclass", "ROC"),
  lambda = NULL,
  pf_group = NULL,
  pf_sparse = NULL,
  intercept = FALSE,
  asparse1 = c(0.5, 20),
  asparse2 = c(0.01, 0.2),
  asparse1_num = 4,
  asparse2_num = 4,
  standardize = TRUE,
  lower_bnd = -Inf,
  upper_bnd = Inf,
  eps = 1e-08,
  maxit = 3e+06,
  hier_info = NULL,
  method = "overlapping",
  partition = "subgroup",
  cvmethod = "general"
)
```

## Arguments

- x:

  Matrix of predictors, of dimension \\n \times p\\; each row is an
  observation. Can be a dense or sparse matrix.

- y:

  Response variable. For \`family="gaussian"\`, should be numeric. For
  \`family="binomial"\`, should be a factor with two levels or a numeric
  vector with two unique values.

- group:

  Optional vector or factor indicating group assignments for variables.
  Used for custom grouping.

- family:

  Character string specifying the model family. Options are
  \`"gaussian"\` (default) for least-squares regression, or
  \`"binomial"\` for logistic regression.

- nlambda:

  Number of lambda values to use for regularization path. Default is
  100.

- lambda.factor:

  Factor determining the minimal value of lambda in the sequence, where
  \`min(lambda) = lambda.factor \* max(lambda)\`. See Details.

- pred.loss:

  Character string indicating loss to minimize during cross-validation.
  Options include \`"default"\`, \`"mse"\`, \`"deviance"\`, \`"mae"\`,
  \`"misclass"\`, and \`"ROC"\`.

- lambda:

  Optional user-supplied sequence of lambda values (overrides
  \`nlambda\`/\`lambda.factor\`).

- pf_group:

  Optional penalty factors on the groups, as a numeric vector. Default
  adjusts for group size.

- pf_sparse:

  Optional penalty factors on the l1-norm (for sparsity), as a numeric
  vector.

- intercept:

  Logical; whether to include an intercept in the model. Default is
  TRUE.

- asparse1:

  Relative weight(s) for the first (e.g., group) layer of the
  overlapping group lasso penalty. Default is c(0.5, 20).

- asparse2:

  Relative weight(s) for the second (e.g., subgroup) layer. Default is
  c(0.01, 0.2).

- asparse1_num:

  Number of values in asparse1 grid (for grid search). Default is 4.

- asparse2_num:

  Number of values in asparse2 grid (for grid search). Default is 4.

- standardize:

  Logical; whether to standardize predictors prior to model fitting.
  Default is TRUE.

- lower_bnd:

  Lower bound(s) for coefficient values. Default is `-Inf`.

- upper_bnd:

  Upper bound(s) for coefficient values. Default is `Inf`.

- eps:

  Convergence tolerance for optimization. Default is 1e-8.

- maxit:

  Maximum number of optimization iterations. Default is 3e6.

- hier_info:

  Required for \`method = "overlapping"\`; a matrix describing the
  hierarchical structure of the subgroups (see Details).

- method:

  Character; either \`"overlapping"\` for overlapping group lasso,
  \`"sparsegl"\` for sparse group lasso, or \`"general"\` for other
  hierarchical regularization. Default is \`"overlapping"\`.

- partition:

  Character string; determines subgroup partitioning. Default is
  \`"subgroup"\`.

- cvmethod:

  Cross-validation method. Options include \`"general"\` (default),
  \`"grid_search"\`, or \`"user_supply"\` (for user-supplied grid).

## Value

An object containing the fitted hierarchical model and cross-validation
results, including:

- fit:

  Fitted model object.

- lambda:

  Sequence of lambda values considered.

- cv_error:

  Cross-validation error/loss for each combination of tuning parameters.

- best_params:

  Best tuning parameters selected.

- ...:

  Additional diagnostic and output fields.

## Details

The hierarchical nested framework decomposes covariate effects into
overall, group, and subgroup-specific components, with regularization
encouraging fusion or sparsity across these hierarchical levels. The
function can fit both the lasso penalty (allowing arbitrary
zero/non-zero patterns) and the overlapping group lasso penalty
(enforcing hierarchical selection structure), as described in Jiang et
al. (2024, submitted).

The argument \`hier_info\` must be supplied for \`"overlapping"\`
method, and encodes the hierarchical relationship between groups and
subgroups (e.g., MDCs and DRGs).

Cross-validation is used to select tuning parameters, optionally over a
grid for hierarchical penalty weights (asparse1, asparse2), and the
regularization parameter lambda.

## References

Jiang, Z., Huo, L., Hou, J., & Huling, J. D. "Heterogeneous readmission
prediction with hierarchical effect decomposition and regularization".

## See also

\[glmnet::glmnet()\], \[hierNest::cv.sparsegl()\]

## Examples

``` r
library(hierNest)
data("example_data")
# \donttest{
cv.fit=cv.hierNest(example_data$X,
                  example_data$Y,
                  method="overlapping",
                  hier_info=example_data$hier_info,
                  family="binomial",
                  partition = "subgroup",  
                  cvmethod = "grid_search", 
                  asparse1 = c(0.5, 1), 
                  asparse2 = c(0.05, 0.20), 
                  nlambda = 50)# }
```
