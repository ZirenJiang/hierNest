# hierNest

The `hierNest` package allows for the fitting of penalized GLMs with
covariate effects that vary by discrete and hierarchically-organized
groups. The methodology allows for the shrinkage of group-specific
models to a global model or to higher level groups. For example, if
groups are defined based on primary diagnoses and then diagnoses are
organized into body systems, `hierNest` will allow models to vary for
each diagnosis or could be collapsed via penalization to body-system
specific models or fully to a global model in common for all groups, all
on a variable-by-variable basis.

## Example

Load the package and an example dataset

``` r
library(hierNest)

data("example_data")

str(example_data)
#> List of 3
#>  $ X        : num [1:200, 1:30] -1.715 1.001 -1.551 -0.214 0.616 ...
#>   ..- attr(*, "dimnames")=List of 2
#>   .. ..$ : NULL
#>   .. ..$ : chr [1:30] "X1" "X2" "X3" "X4" ...
#>  $ Y        : num [1:200] 0 1 0 1 0 0 0 0 0 0 ...
#>  $ hier_info: num [1:200, 1:2] 1 1 1 1 1 1 1 1 1 1 ...
```

The data structure `hier_info` contains hierarchical information about
group membership. The last column represents the finest description of
group membership (eg primary diagnosis) and the first column represents
the coarsest definition of group (eg body system).

``` r
head(example_data$hier_info)
#>      [,1] [,2]
#> [1,]    1    1
#> [2,]    1    1
#> [3,]    1    1
#> [4,]    1    1
#> [5,]    1    1
#> [6,]    1    1
```

# Fit models and select tuning parameters via cross-validation

The
[`cv.hierNest()`](https://jaredhuling.github.io/hierNest/reference/cv.hierNest.md)
function both fits models and selects tuning parameters via $`K`$-fold
cross validation.

``` r
cv.fit=cv.hierNest(example_data$X,
                   example_data$Y,
                   method="overlapping",# For now, we only wrap-up the overlapping group lasso method in this function
                   hier_info=example_data$hier_info,
                   family="binomial",
                   partition = "subgroup", # partition = "subgroup" make sure the each n-fold is sampled within the subgroups to avoid extreme cases
                   cvmethod = "grid_search", # cvmethod = "grid_search" indicate the second cross-validation method
                   asparse1 = c(0.5,20), # Input the upper and lower bounds of alpha_1 and alpha_2
                   asparse2 = c(0.05,0.20), 
                   asparse1_num = 3, # number of grids for alpha_1 and alpha_2, total 3*3 = 9 grids will be screened
                   asparse2_num = 3, 
                   nlambda = 50, # length of lambda sequence for each pair of alpha_1 and alpha_2
                   )
```

# Results

## Plot the coefficients

By specifying the type = “coefficients”, we plot all non-zero
coefficient including the overall mean, group-specific, and subgroup
specific.

``` r
plot(cv.fit, type = "coefficients")
```

![](reference/figures/unnamed-chunk-3-1.png)

By specifying the type = “Subgroup effect”, we plot the covariate
effects for each subgroup.

``` r
plot(cv.fit, type = "Subgroup effects")
```

![](reference/figures/unnamed-chunk-4-1.png)

## Grab chosen lambda and coefficients

``` r
cv.fit$lambda.min    # lambda minimizing CV loss
#> [1] 0.00056551
```

``` r
cv.fit$min_alpha1    # alpha1 minimizing CV loss
#> [1] 0.5
```

``` r
cv.fit$min_alpha2    # lambda minimizing CV loss
#> [1] 0.2
```
