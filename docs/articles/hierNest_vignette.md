# Getting Started with hierNest

## Introduction

The **hierNest** package implements penalized regression with a
hierarchical nested parameterization designed for settings in which
observations belong to a two-level group hierarchy — for example,
Diagnosis Related Groups (DRGs) nested within Major Diagnostic
Categories (MDCs) in electronic health record (EHR) data.

### Motivation

In health systems, patient populations are highly heterogeneous. A
patient hospitalized for heart failure has very different clinical risk
factors from one admitted for a traumatic injury. Fitting a single
pooled model ignores this heterogeneity, while fitting fully separate
models per DRG is statistically infeasible when subgroup sample sizes
are small and the number of predictors is large.

**hierNest** resolves this tension by decomposing each covariate’s
effect into three interpretable, hierarchically nested components:

$$\beta_{d} = \mu + \eta^{M{(d)}} + \delta_{d}$$

where:

- $\mu$ is the **overall common effect** shared across all subgroups,
- $\eta^{M{(d)}}$ is the **MDC-specific deviation** for the Major
  Diagnostic Category $M(d)$ that DRG $d$ belongs to,
- $\delta_{d}$ is the **DRG-specific deviation** unique to subgroup $d$.

Pairing this reparameterization with structured regularization (lasso or
overlapping group lasso) allows the model to borrow strength across
related subgroups while remaining flexible enough to capture genuine
heterogeneity.

### Two penalization strategies

The package provides two penalization methods:

1.  **hierNest-Lasso** — applies a standard lasso penalty to the
    reparameterized coefficients, with penalty weights adjusted for
    subgroup sample size. This is implemented via a modified design
    matrix that can be passed directly to `glmnet`. It is fast and
    serves as a useful baseline.

2.  **hierNest-OGLasso** — applies an overlapping group lasso penalty
    that additionally enforces *effect hierarchy*: an MDC-specific
    effect can be non-zero only if the corresponding overall effect is
    non-zero, and a DRG-specific effect can be non-zero only if the
    corresponding MDC effect is non-zero. This is the recommended method
    when the hierarchical structure is plausible.

### Package scope

This vignette covers:

- The structure of the required `hier_info` input.
- Simulating or loading data suitable for `hierNest`.
- Fitting a model with
  [`hierNest()`](https://ZirenJiang.github.io/hierNest/reference/hierNest.md)
  at a fixed penalty.
- Selecting tuning parameters with
  [`cv.hierNest()`](https://ZirenJiang.github.io/hierNest/reference/cv.hierNest.md).
- Extracting and interpreting coefficients.
- Generating predictions on new data with
  [`predict_hierNest()`](https://ZirenJiang.github.io/hierNest/reference/predict_hierNest.md).
- Visualizing results with
  [`plot()`](https://rdrr.io/r/graphics/plot.default.html).

------------------------------------------------------------------------

## Installation

Install the package from CRAN (when available) or from source:

``` r
# From CRAN
install.packages("hierNest")

# From source (development version)
# install.packages("devtools")
devtools::install_github("ZirenJiang/hierNest")
```

Load the package:

``` r
library(hierNest)
```

------------------------------------------------------------------------

## The `hier_info` matrix

All `hierNest` functions require a `hier_info` argument that encodes the
two-level hierarchy. This is an $n \times 2$ integer matrix where:

- Column 1 gives the **group index** (e.g., MDC) for each observation,
  taking values in $\{ 1,\ldots,n_{\text{MDC}}\}$.
- Column 2 gives the **subgroup index** (e.g., DRG) for each
  observation, taking values in $\{ 1,\ldots,n_{\text{DRG}}\}$.

Subgroup indices must be *globally unique* across groups — two DRGs in
different MDCs must have different integer codes.

``` r
# Illustration: 3 MDCs with 2 DRGs each (6 DRGs total)
#
# MDC 1 -> DRG 1, DRG 2
# MDC 2 -> DRG 3, DRG 4
# MDC 3 -> DRG 5, DRG 6
#
# For an observation in MDC 2 / DRG 4:
#   hier_info[i, ] = c(2, 4)
```

------------------------------------------------------------------------

## Example data

The package ships with a built-in example dataset that illustrates the
required data structure.

``` r
data("example_data")

# Dimensions
cat("X dimensions:", dim(example_data$X), "\n")
#> X dimensions: 200 30
cat("Y length:     ", length(example_data$Y), "\n")
#> Y length:      200
cat("hier_info dimensions:", dim(example_data$hier_info), "\n")
#> hier_info dimensions: 200 2

# Peek at hier_info
head(example_data$hier_info)
#>      [,1] [,2]
#> [1,]    1    1
#> [2,]    1    1
#> [3,]    1    1
#> [4,]    1    1
#> [5,]    1    1
#> [6,]    1    1

# Group sizes
table_mdc <- table(example_data$hier_info[, 1])
cat("\nObservations per MDC group:\n")
#> 
#> Observations per MDC group:
print(table_mdc)
#> 
#>   1   2 
#> 100 100

table_drg <- table(example_data$hier_info[, 2])
cat("\nObservations per DRG subgroup (first 10):\n")
#> 
#> Observations per DRG subgroup (first 10):
print(head(table_drg, 10))
#> 
#>  1  2  3  4 
#> 50 50 50 50

# Outcome distribution (binary)
cat("\nOutcome distribution:\n")
#> 
#> Outcome distribution:
print(table(example_data$Y))
#> 
#>   0   1 
#> 108  92
```

------------------------------------------------------------------------

## Fitting the model

### `hierNest()` — fit at a single penalty level

[`hierNest()`](https://ZirenJiang.github.io/hierNest/reference/hierNest.md)
fits the full regularization path for a single pair of hyperparameters
$\left( \alpha_{1},\alpha_{2} \right)$. It is useful for exploration or
when tuning parameters have already been selected.

``` r
library(hierNest)
fit <- hierNest(
  x         = example_data$X,
  y         = example_data$Y,
  hier_info = example_data$hier_info,
  family    = "binomial",
  asparse1  = 1,    # weight for MDC-level group penalty
  asparse2  = 1     # weight for DRG-level subgroup penalty
)

# The fit contains a lambda sequence and corresponding coefficient paths
length(fit$lambda)
dim(fit$beta)   # rows = reparameterized coefficients, cols = lambda values
```

Key arguments:

| Argument      | Description                                                               |
|---------------|---------------------------------------------------------------------------|
| `x`           | $n \times p$ predictor matrix                                             |
| `y`           | Response (numeric for Gaussian, 0/1 or factor for binomial)               |
| `hier_info`   | $n \times 2$ group/subgroup index matrix                                  |
| `family`      | `"gaussian"` or `"binomial"`                                              |
| `asparse1`    | $\alpha_{1}$: relative weight for the MDC-level overlapping group penalty |
| `asparse2`    | $\alpha_{2}$: relative weight for the DRG-level overlapping group penalty |
| `nlambda`     | Length of the $\lambda$ sequence (default 100)                            |
| `standardize` | Whether to standardize predictors before fitting (default `TRUE`)         |
| `method`      | For now, only `"overlapping"` (hierNest-OGLasso, default)                 |

------------------------------------------------------------------------

### `cv.hierNest()` — cross-validated tuning parameter selection

In practice, the penalty hyperparameters $\lambda$, $\alpha_{1}$, and
$\alpha_{2}$ need to be chosen by cross-validation.
[`cv.hierNest()`](https://ZirenJiang.github.io/hierNest/reference/cv.hierNest.md)
wraps the fitting procedure with cross-validation and returns the
optimal parameter combination.

#### Cross-validation methods

The `cvmethod` argument controls how $\alpha_{1}$ and $\alpha_{2}$ are
selected:

- `"general"` — uses a single pair of $\alpha_{1}$ and $\alpha_{2}$
  (supplied as scalars) and runs standard cross-validation over the
  $\lambda$ sequence only.
- `"grid_search"` — searches a grid of $\alpha_{1} \times \alpha_{2}$
  pairs. The ranges are specified via `asparse1` and `asparse2` (each a
  length-2 vector giving the lower and upper bound), with `asparse1_num`
  and `asparse2_num` controlling the grid resolution.
- `"user_supply"` — the user provides explicit paired vectors of
  $\left( \alpha_{1},\alpha_{2} \right)$ values to evaluate.

#### Recommended: grid search

``` r
cv.fit <- cv.hierNest(
  x           = example_data$X,
  y           = example_data$Y,
  method      = "overlapping",
  hier_info   = example_data$hier_info,
  family      = "binomial",
  partition   = "subgroup",    # stratify CV folds within subgroups
  cvmethod    = "grid_search",
  asparse1    = c(0.5, 20),    # search alpha_1 over [0.5, 20]
  asparse2    = c(0.05, 0.20), # search alpha_2 over [0.05, 0.20]
  asparse1_num = 3,            # 3 x 3 = 9 grid points
  asparse2_num = 3,
  nlambda     = 50,            # lambda values per grid point
  pred.loss   = "ROC"          # maximize AUROC
)
```

> **Note on `partition = "subgroup"`:** This stratifies the
> cross-validation folds so that each fold contains observations from
> all DRG subgroups (to the extent possible). This avoids degenerate
> folds where a small subgroup is entirely absent from the training
> data.

#### Single hyperparameter pair (fast)

``` r
cv.fit.simple <- cv.hierNest(
  x         = example_data$X,
  y         = example_data$Y,
  method    = "overlapping",
  hier_info = example_data$hier_info,
  family    = "binomial",
  partition = "subgroup",
  cvmethod  = "general",
  asparse1  = 1,
  asparse2  = 0.1,
  nlambda   = 100,
  pred.loss = "ROC"
)
```

#### User-supplied grid

``` r
cv.fit.user <- cv.hierNest(
  x         = example_data$X,
  y         = example_data$Y,
  method    = "overlapping",
  hier_info = example_data$hier_info,
  family    = "binomial",
  partition = "subgroup",
  cvmethod  = "user_supply",
  asparse1  = c(0.5, 1, 5, 10),   # explicit (alpha1, alpha2) pairs
  asparse2  = c(0.05, 0.1, 0.1, 0.2),
  nlambda   = 50
)
```

------------------------------------------------------------------------

## Inspecting the cross-validated fit

After running
[`cv.hierNest()`](https://ZirenJiang.github.io/hierNest/reference/cv.hierNest.md),
several components of the returned object are of interest.

``` r
# Optimal tuning parameters selected by cross-validation
cv.fit$lambda.min   # lambda minimising CV loss
cv.fit$min_alpha1   # alpha_1 selected
cv.fit$min_alpha2   # alpha_2 selected


# Number of non-zero coefficients in the reparameterized model
# at the optimal lambda
nnz <- sum(cv.fit$hierNest.fit$beta[,
           which(cv.fit$hierNest.fit$lambda == cv.fit$lambda.min)] != 0)
cat("Non-zero reparameterized coefficients:", nnz, "\n")
```

------------------------------------------------------------------------

## Visualizing the estimated effects

The [`plot()`](https://rdrr.io/r/graphics/plot.default.html) method for
`cv.hierNest` objects provides two heatmap visualizations.

### Coefficient heatmap

Plotting with `type = "coefficients"` shows the estimated overall,
MDC-specific, and DRG-specific components for each selected predictor,
at the cross-validation optimal $\lambda$.

``` r
# Returns a plotly interactive heatmap
p_coef <- plot(cv.fit, type = "coefficients")
p_coef
```

Each row of the heatmap corresponds to one level in the hierarchy
(overall mean, then each MDC, then each DRG within that MDC). Each
column is a selected predictor. Blue cells indicate a positive
contribution; red cells indicate negative. Rows with all zeros are
suppressed.

### Subgroup effect heatmap

Plotting with `type = "Subgroup effects"` reconstructs the *total*
effect for each DRG subgroup:
${\widehat{\beta}}_{d} = \widehat{\mu} + {\widehat{\eta}}^{M{(d)}} + {\widehat{\delta}}_{d}$.

``` r
p_sub <- plot(cv.fit, type = "Subgroup effects")
p_sub
```

This visualization is useful for comparing risk profiles across
subgroups — subgroups with similar colors for a given predictor share
similar risk processes for that covariate.

------------------------------------------------------------------------

## Methodological background

The statistical framework underlying **hierNest** is described in detail
in:

> Jiang, Z., Huo, L., Hou, J., Vaughan-Sarrazin, M., Smith, M. A., &
> Huling, J. D. (2026+). *Heterogeneous readmission prediction with
> hierarchical effect decomposition and regularization*.

### Hierarchical reparameterization

For participant $i$ with DRG $D_{i} = d$, the logistic regression model
is:

$$\text{logit}\left( \Pr\left( Y_{i} = 1 \mid X_{i},D_{i} = d \right) \right) = X_{i}^{\top}\beta_{d}$$

The hierNest reparameterization decomposes $\beta_{d}$ as:

$$\beta_{d} = \mu + \eta^{M{(d)}} + \delta_{d}$$

This is encoded via a modified design matrix $X_{H}$ constructed as the
Khatri–Rao (column-wise Kronecker) product of $X$ and the hierarchy
indicator matrix
$H = \left\lbrack \mathbf{1}_{n}\;;\; H_{M}\;;\; H_{D} \right\rbrack$.

### Overlapping group lasso penalty

The overlapping group lasso penalty on the grouped coefficient vector
$\theta_{j} = \{\mu_{j},\{\eta_{Mj}\}_{M},\{\delta_{dj}\}_{d}\}$ for the
$j$-th predictor is:

$$P_{\text{og}}(\theta) = \lambda\sum\limits_{j = 1}^{p}\left\lbrack \left| \theta_{j} \right|_{2} + \sum\limits_{M \in \mathcal{M}}\left( \alpha_{1}\left| \theta_{Mj} \right|_{2} + \alpha_{2}\left| \eta_{Mj} \right| \right) \right\rbrack$$

This penalty enforces a hierarchical zero pattern: $\mu_{j} = 0$ implies
all $\eta_{Mj} = 0$ and $\delta_{dj} = 0$; $\eta_{Mj} = 0$ implies all
$\delta_{dj} = 0$ for $d \in M$.

### Computation

For `method = "overlapping"`, the majorization-minimization (MM)
algorithm described in Algorithm 1 of the paper is used, with sequential
strong rules to skip inactive predictor groups and accelerate
computation. The design matrix is stored as a sparse matrix to minimise
memory requirements.

------------------------------------------------------------------------

## Session information

``` r
sessionInfo()
#> R version 4.3.2 (2023-10-31 ucrt)
#> Platform: x86_64-w64-mingw32/x64 (64-bit)
#> Running under: Windows 11 x64 (build 26200)
#> 
#> Matrix products: default
#> 
#> 
#> locale:
#> [1] LC_COLLATE=Chinese (Simplified)_China.utf8 
#> [2] LC_CTYPE=Chinese (Simplified)_China.utf8   
#> [3] LC_MONETARY=Chinese (Simplified)_China.utf8
#> [4] LC_NUMERIC=C                               
#> [5] LC_TIME=Chinese (Simplified)_China.utf8    
#> 
#> time zone: America/Chicago
#> tzcode source: internal
#> 
#> attached base packages:
#> [1] stats     graphics  grDevices utils     datasets  methods   base     
#> 
#> other attached packages:
#> [1] hierNest_1.0.0
#> 
#> loaded via a namespace (and not attached):
#>  [1] Matrix_1.6-5       gtable_0.3.6       jsonlite_1.8.8     dplyr_1.1.4       
#>  [5] compiler_4.3.2     tidyselect_1.2.1   tidyr_1.3.1        jquerylib_0.1.4   
#>  [9] systemfonts_1.0.6  scales_1.4.0       textshaping_0.3.7  yaml_2.3.8        
#> [13] fastmap_1.1.1      lattice_0.22-5     ggplot2_4.0.0      R6_2.6.1          
#> [17] generics_0.1.4     knitr_1.51         htmlwidgets_1.6.4  dotCall64_1.1-1   
#> [21] tibble_3.2.1       desc_1.4.3         bslib_0.7.0        pillar_1.11.1     
#> [25] RColorBrewer_1.1-3 rlang_1.1.6        cachem_1.0.8       xfun_0.56         
#> [29] fs_1.6.6           sass_0.4.9         S7_0.2.0           lazyeval_0.2.2    
#> [33] otel_0.2.0         viridisLite_0.4.2  plotly_4.10.4      cli_3.6.2         
#> [37] pkgdown_2.2.0      magrittr_2.0.3     digest_0.6.34      grid_4.3.2        
#> [41] rstudioapi_0.16.0  rTensor_1.4.8      lifecycle_1.0.4    vctrs_0.6.5       
#> [45] data.table_1.17.8  evaluate_0.23      glue_1.8.0         farver_2.1.1      
#> [49] ragg_1.5.0         purrr_1.0.2        httr_1.4.7         rmarkdown_2.30    
#> [53] pkgconfig_2.0.3    tools_4.3.2        htmltools_0.5.8.1
```
