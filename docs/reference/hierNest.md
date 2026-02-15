# Fit Hierarchical Nested Regularization Model (hierNest)

Fits a hierarchical nested penalized regression model for
subgroup-specific effects using overlapping group lasso penalties. This
function encodes the hierarchical structure (e.g., MDC and DRG) via a
reparameterized design matrix and enables information borrowing across
related subgroups.

## Usage

``` r
hierNest(
  x,
  y,
  group = NULL,
  family = c("gaussian", "binomial"),
  nlambda = 100,
  lambda.factor = NULL,
  lambda = NULL,
  pf_group = NULL,
  pf_sparse = NULL,
  intercept = FALSE,
  asparse1 = 1,
  asparse2 = 0.05,
  standardize = TRUE,
  lower_bnd = -Inf,
  upper_bnd = Inf,
  eps = 1e-08,
  maxit = 3e+06,
  hier_info = NULL,
  random_asparse = FALSE,
  method = "overlapping"
)
```

## Arguments

- x:

  Matrix of predictors (\\n \times p\\), where each row is an
  observation.

- y:

  Response variable (numeric for "gaussian", binary or factor for
  "binomial").

- group:

  Optional grouping vector (not required for "overlapping" method).

- family:

  Model family; either "gaussian" for least squares or "binomial" for
  logistic regression.

- nlambda:

  Number of lambda values in the regularization path (default: 100).

- lambda.factor:

  Factor for minimal value of lambda in the sequence.

- lambda:

  Optional user-supplied lambda sequence.

- pf_group:

  Penalty factor(s) for each group; defaults to sqrt(group size).

- pf_sparse:

  Penalty factors for individual predictors (L1 penalty).

- intercept:

  Logical; should an intercept be included? Default is FALSE.

- asparse1:

  Relative weight for group-level penalty (default: 1).

- asparse2:

  Relative weight for subgroup-level penalty (default: 0.05).

- standardize:

  Logical; standardize predictors? Default is TRUE.

- lower_bnd:

  Lower bound for coefficients (default: -Inf).

- upper_bnd:

  Upper bound for coefficients (default: Inf).

- eps:

  Convergence tolerance (default: 1e-8).

- maxit:

  Maximum number of optimization iterations (default: 3e6).

- hier_info:

  Required. Matrix encoding the hierarchical structure (see Details).

- random_asparse:

  Logical; use random sparse penalty? Default: FALSE.

- method:

  Type of hierarchical regularization ("overlapping" \[default\],
  "sparsegl", or "general").

## Value

Returns a model fit object as produced by
[`hierNest::overlapping_gl`](https://jaredhuling.org/hierNest/reference/overlapping_gl.md),
including selected coefficients, cross-validation results, and tuning
parameters.

## Details

This function builds a hierarchical design matrix reflecting
group/subgroup structure (e.g., Major Diagnostic Categories \[MDCs\] and
Diagnosis Related Groups \[DRGs\]), encoding overall, group-specific,
and subgroup-specific effects. It fits a penalized model using
overlapping group lasso, as described in Jiang et al. (2024, submitted).
The main computational engine is
[`hierNest::overlapping_gl`](https://jaredhuling.org/hierNest/reference/overlapping_gl.md).

## References

Jiang, Z., Huo, L., Hou, J., Vaughan-Sarrazin, M., Smith, M. A., &
Huling, J. D. (2024). Heterogeneous readmission prediction with
hierarchical effect decomposition and regularization.

## See also

\[hierNest::overlapping_gl()\]

## Examples

``` r
# Example with toy data
library(hierNest)
data("example_data")
# \donttest{
fit = hierNest(example_data$X,
              example_data$Y,
              hier_info=example_data$hier_info,
              family="binomial",
              asparse1 = 1,
              asparse2 = 1)# }
```
