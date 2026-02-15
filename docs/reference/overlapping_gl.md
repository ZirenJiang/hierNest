# Fit an Overlapping Group Lasso Model

This function fits an overlapping group lasso model with hierarchical
regularization, allowing both sparsity within groups and across groups.

## Usage

``` r
overlapping_gl(
  x,
  y,
  group = NULL,
  family = c("gaussian", "binomial"),
  nlambda = 100,
  lambda.factor = ifelse(nobs < nvars, 0.01, 1e-04),
  lambda = NULL,
  pf_group = sqrt(bs),
  pf_sparse = rep(1, nvars),
  intercept = TRUE,
  asparse1 = 1,
  asparse2 = 0.05,
  standardize = TRUE,
  lower_bnd = -Inf,
  upper_bnd = Inf,
  weights = NULL,
  offset = NULL,
  warm = NULL,
  trace_it = 0,
  dfmax = as.integer(max(group)) + 1L,
  pmax = min(dfmax * 1.2, as.integer(max(group))),
  eps = 1e-08,
  maxit = 3e+06,
  cn,
  drgix,
  drgiy,
  cn_s,
  cn_e,
  random_asparse = FALSE
)
```

## Arguments

- x:

  A numeric matrix of predictor variables (no missing values allowed).

- y:

  A numeric vector of response variable values.

- group:

  An integer vector defining the group membership for each predictor.
  Default is NULL (each predictor forms its own group).

- family:

  A character string specifying the model family. Options are "gaussian"
  (default) and "binomial".

- nlambda:

  Number of lambda values. Default is 100.

- lambda.factor:

  Factor determining minimum lambda as a fraction of maximum lambda.
  Default depends on dimensionality.

- lambda:

  Numeric vector of lambda values. If provided, overrides \`nlambda\`
  and \`lambda.factor\`.

- pf_group:

  Penalty factor for groups. Default is square root of group size.

- pf_sparse:

  Penalty factor for individual predictors. Default is 1 for each
  predictor.

- intercept:

  Logical; whether to include an intercept. Default is TRUE.

- asparse1:

  Sparsity penalty factor controlling group-level sparsity. Default is
  1.

- asparse2:

  Sparsity penalty factor controlling within-group sparsity. Default is
  0.05.

- standardize:

  Logical; if TRUE, standardizes predictors before fitting. Default is
  TRUE.

- lower_bnd:

  Numeric vector specifying lower bounds for coefficients. Default is
  -Inf.

- upper_bnd:

  Numeric vector specifying upper bounds for coefficients. Default is
  Inf.

- weights:

  Optional numeric vector of observation weights. Currently limited
  functionality.

- offset:

  Optional numeric vector specifying a known component to be included in
  the linear predictor.

- warm:

  Optional initial values for optimization.

- trace_it:

  Integer indicating the verbosity level. Default is 0 (no output).

- dfmax:

  Maximum number of groups allowed in the model. Default derived from
  groups.

- pmax:

  Maximum number of predictors allowed in the model. Default derived
  from groups.

- eps:

  Numeric convergence threshold for optimization. Default is 1e-08.

- maxit:

  Maximum number of iterations for optimization. Default is 3e+06.

- cn:

  Additional internal numeric parameter for optimization.

- drgix, drgiy:

  Numeric vectors specifying indices for specific group and predictor
  structures.

- cn_s, cn_e:

  Numeric vectors specifying starting and ending indices for
  substructures.

- random_asparse:

  Logical; if TRUE, randomly selects sparsity parameters. Default is
  FALSE.

## Value

An object of class \`sparsegl\` containing:

- call:

  The matched function call.

- lambda:

  The lambda values used for fitting.

- asparse1, asparse2:

  Sparsity parameters used.

- nobs:

  Number of observations.

- pf_group, pf_sparse:

  Penalty factors used.

- coefficients:

  Estimated coefficients.

Additional components relevant to model diagnostics and fitting.
