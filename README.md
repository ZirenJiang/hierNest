Guidance of hierNest version 1
================

``` r
library(hierNest)
library(rTensor)
## Load the example data with 4 MDC groups with 4 DRGs for each MDC. 
data=readRDS("./example_data.Rdata")


tt1=Sys.time()
fit1=hierNest::hierNest(data$X,
                        data$Y,
                        method="overlapping",  ## Overlapping group lasso method
                        hier_info=data$hier_info,  ## Should input the hierarchical information for the groups
                        random_asparse = TRUE,  ## Randomly draw the other two tuning parameter?
                        nlambda=100,
                        intercept = FALSE,  ## Set intercept = FALSE can potentially save a huge amount of time
                        family="binomial")
```

    ## Warning: Randomly select penalty factor 1

    ## Warning: Randomly select penalty factor 2

    ## [1] "-----------asasa-----------"
    ## [1] "logit_sparse"

``` r
tt2=Sys.time()
print(tt2-tt1)
```

    ## Time difference of 0.674571 secs

``` r
sample_inx=sort(sample(1:NROW(data$X),NROW(data$X),TRUE))

## For now, please use our unique function of predict_hierNest to predict the outcome.
pred1=hierNest::predict_hierNest(fit1,newx = data$X[sample_inx,],hier_info=data$hier_info[sample_inx,],type = "response")

pred1[,50]
```

    ##   [1] 0.3484564 0.3484564 0.3484564 0.3484564 0.3484564 0.3484564 0.3484564
    ##   [8] 0.3484564 0.3484564 0.3484564 0.3484564 0.3484564 0.3484564 0.3484564
    ##  [15] 0.3484564 0.3484564 0.3484564 0.3484564 0.3484564 0.3484564 0.3484564
    ##  [22] 0.3484564 0.3484564 0.3484564 0.3484564 0.3484564 0.3484564 0.3484564
    ##  [29] 0.3484564 0.3484564 0.3484564 0.3484564 0.3484564 0.3484564 0.3484564
    ##  [36] 0.3484564 0.3484564 0.3484564 0.3484564 0.3484564 0.3484564 0.3484564
    ##  [43] 0.3484564 0.3484564 0.3484564 0.2974055 0.2974055 0.2974055 0.2974055
    ##  [50] 0.2974055 0.2974055 0.2974055 0.2974055 0.2974055 0.2974055 0.2974055
    ##  [57] 0.2974055 0.2974055 0.2974055 0.2974055 0.2974055 0.2974055 0.2974055
    ##  [64] 0.2974055 0.2974055 0.2974055 0.2974055 0.2974055 0.2974055 0.2974055
    ##  [71] 0.2974055 0.2974055 0.2974055 0.2974055 0.2974055 0.2974055 0.2974055
    ##  [78] 0.2974055 0.2974055 0.2974055 0.2974055 0.2974055 0.2974055 0.2974055
    ##  [85] 0.2974055 0.2974055 0.2974055 0.2974055 0.2974055 0.2974055 0.2974055
    ##  [92] 0.2974055 0.2974055 0.2974055 0.2974055 0.2974055 0.7673307 0.7673307
    ##  [99] 0.7673307 0.7673307 0.7673307 0.7673307 0.7673307 0.7673307 0.7673307
    ## [106] 0.7673307 0.7673307 0.7673307 0.7673307 0.7673307 0.7673307 0.7673307
    ## [113] 0.7673307 0.7673307 0.7673307 0.7673307 0.7673307 0.7673307 0.7673307
    ## [120] 0.7673307 0.7673307 0.7673307 0.7673307 0.7673307 0.7673307 0.7673307
    ## [127] 0.7673307 0.7673307 0.7673307 0.7673307 0.7673307 0.7673307 0.7673307
    ## [134] 0.7673307 0.7673307 0.7673307 0.7673307 0.7673307 0.7673307 0.7673307
    ## [141] 0.7673307 0.7673307 0.7673307 0.7673307 0.7673307 0.4311612 0.4311612
    ## [148] 0.4311612 0.4311612 0.4311612 0.4311612 0.4311612 0.4311612 0.4311612
    ## [155] 0.4311612 0.4311612 0.4311612 0.4311612 0.4311612 0.4311612 0.4311612
    ## [162] 0.4311612 0.4311612 0.4311612 0.4311612 0.4311612 0.4311612 0.4311612
    ## [169] 0.4311612 0.4311612 0.4311612 0.4311612 0.4311612 0.4311612 0.4311612
    ## [176] 0.4311612 0.4311612 0.4311612 0.4311612 0.4311612 0.4311612 0.4311612
    ## [183] 0.4311612 0.4311612 0.4311612 0.4311612 0.4311612 0.4311612 0.4311612
    ## [190] 0.4311612 0.4311612 0.4311612 0.4311612 0.4311612 0.4311612 0.4311612
    ## [197] 0.4311612 0.4311612 0.4311612 0.4311612

## The following show two ways of cross-validation

Since our model have three tuning parameters
$\lambda, \alpha_1, \alpha_2$ that need to be selected through
cross-validation, the following implements two ways of cross-validation.

### Method 1: general cross-validation method

The first method randomly select $\alpha_1, \alpha_2$ corresponding to
each $\lambda$ value. Then, through the cross-validation, we select the
optimal combination of ($\lambda, \alpha_1, \alpha_2$) that produce
smallest MSE (or other loss).

``` r
## Cross validation for choosing the lambda parameter
cv.fit1=cv.hierNest(data$X,data$Y,method="overlapping",# For now, we only wrap-up the overlapping group lasso method in this function
                   hier_info=data$hier_info,family="binomial",
                   partition = "subgroup", # partition = "subgroup" make sure the each n-fold is sampled within the subgroups to avoid extreme cases
                   cvmethod = "general", # cvmethod = "general" indicate the first cross-validation method
                   asparse1=fit1$asparse1,asparse2=fit1$asparse2, ## Should input the tuning parameters asparse1 & asparse2 in order to be consistent with the model "fit1"
                   nlambda = 100,intercept = FALSE)  


## Estimated coefficients for the selected lambda value


# fit1$beta[,order(abs(fit1$lambda-cv.fit1$lambda.min))[1]]
```

### Method 2: grid search cross-validation method

The second method evenly select several grid points in the (predefined)
region of ($\alpha_1, \alpha_2$), each grid point represent a
combination of $\alpha_1$ and $\alpha_2$. Then, for each grid point, we
run our method with a shorter lambda sequence. We select the optimal
value of ($\lambda, \alpha_1, \alpha_2$) that produce smallest MSE (or
other loss) through cross-validation.

Note that, this type of cross-validation will generate different lambda
sequence compared with the previous fit1 model. Therefore, we need to
re-run our method with the selected value of
($\lambda, \alpha_1, \alpha_2$)

``` r
cv.fit2=cv.hierNest(data$X,data$Y,method="overlapping",# For now, we only wrap-up the overlapping group lasso method in this function
                   hier_info=data$hier_info,family="binomial",
                   partition = "subgroup", # partition = "subgroup" make sure the each n-fold is sampled within the subgroups to avoid extreme cases
                   cvmethod = "grid_search", # cvmethod = "grid_search" indicate the second cross-validation method
                   asparse1 = c(0.5,20),asparse2 = c(0.05,0.20), # For the second method, need to input the upper and lower bounds of alpha_1 and alpha_2
                   asparse1_num = 5,asparse2_num = 5, # number of grids for alpha_1 and alpha_2, total 25 grids will be selected
                   nlambda = 100,intercept = FALSE)


fit.selected=hierNest::hierNest(data$X,data$Y,method="overlapping", hier_info=data$hier_info,family="binomial",
                   asparse1 = cv.fit2$sparsegl.fit$asparse1, # Need to input selected alpha_1
                   asparse2 = cv.fit2$sparsegl.fit$asparse2, # Need to input selected alpha_2
                   lambda = cv.fit2$lambda.min, # Selected lambda value
                   intercept = FALSE)
```

## Include intercept will

``` r
tt1=Sys.time()
fit1.true=hierNest::hierNest(data$X,
                        data$Y,
                        method="overlapping",  ## Overlapping group lasso method
                        hier_info=data$hier_info,  ## Should input the hierarchical information for the groups
                        random_asparse = TRUE,  ## Randomly draw the other two tuning parameter?
                        nlambda=100,
                        intercept = TRUE,  ## Set intercept = FALSE can potentially save a huge amount of time
                        family="binomial")
```

    ## Warning: Randomly select penalty factor 1

    ## Warning: Randomly select penalty factor 2

    ## [1] "-----------asasa-----------"
    ## [1] "logit_sparse"

``` r
tt2=Sys.time()
print(tt2-tt1)
```

    ## Time difference of 16.80476 secs

``` r
fit1.true$npasses
```

    ## [1] 94262

``` r
fit1.true$beta[1,]
```

    ##  s0  s1  s2  s3  s4  s5  s6  s7  s8  s9 s10 s11 s12 s13 s14 s15 s16 s17 s18 s19 
    ##   0   0   0   0   0   0   0   0   0   0   0   0   0   0   0   0   0   0   0   0 
    ## s20 s21 s22 s23 s24 s25 s26 s27 s28 s29 s30 s31 s32 s33 s34 s35 s36 s37 s38 s39 
    ##   0   0   0   0   0   0   0   0   0   0   0   0   0   0   0   0   0   0   0   0 
    ## s40 s41 s42 s43 s44 s45 s46 s47 s48 s49 s50 s51 s52 s53 s54 s55 s56 s57 s58 s59 
    ##   0   0   0   0   0   0   0   0   0   0   0   0   0   0   0   0   0   0   0   0 
    ## s60 s61 s62 s63 s64 s65 s66 s67 s68 s69 s70 s71 s72 s73 s74 s75 s76 s77 s78 s79 
    ##   0   0   0   0   0   0   0   0   0   0   0   0   0   0   0   0   0   0   0   0 
    ## s80 s81 s82 s83 s84 s85 s86 s87 s88 s89 s90 s91 s92 s93 s94 s95 s96 s97 s98 s99 
    ##   0   0   0   0   0   0   0   0   0   0   0   0   0   0   0   0   0   0   0   0

``` r
fit1.true$b0
```

    ##            [,1]      [,2]      [,3]       [,4]       [,5]      [,6]       [,7]
    ## [1,] -0.1603426 0.4012432 0.2822551 -0.1359825 -0.4929591 -0.499999 -0.1833005
    ##            [,8]       [,9]      [,10]      [,11]     [,12]     [,13]     [,14]
    ## [1,] -0.3613253 -0.3168835 -0.3963748 -0.7559568 -1.011708 -1.033647 -1.020808
    ##          [,15]     [,16]      [,17]      [,18]     [,19]      [,20]     [,21]
    ## [1,] -1.048096 -1.139538 -0.5080599 -0.5043593 -1.154345 -0.9850828 -1.083997
    ##           [,22]      [,23]     [,24]     [,25]     [,26]     [,27]     [,28]
    ## [1,] -0.9014365 -0.3360808 -1.279449 -1.554871 -1.348561 -1.401498 -1.508468
    ##           [,29]     [,30]     [,31]     [,32]     [,33]      [,34]      [,35]
    ## [1,] -0.6701044 -1.474528 -1.630472 -1.662832 -0.647111 -0.7830432 -0.6361524
    ##           [,36]     [,37]      [,38]     [,39]     [,40]     [,41]     [,42]
    ## [1,] -0.7929118 -1.983863 -0.8213435 -1.896699 -1.599025 -2.125854 -1.642164
    ##          [,43]    [,44]     [,45]     [,46]     [,47]     [,48]     [,49]
    ## [1,] -1.457452 -1.75042 -1.603122 -2.239385 -2.944257 -3.164421 -2.602291
    ##          [,50]     [,51]     [,52]     [,53]     [,54]     [,55]     [,56]
    ## [1,] -3.485581 -2.209066 -4.211545 -4.802944 -1.718428 -2.170365 -2.786261
    ##          [,57]     [,58]     [,59]     [,60]     [,61]     [,62]     [,63]
    ## [1,] -2.673749 -4.822463 -2.715599 -4.596158 -3.978275 -2.203425 -3.518061
    ##          [,64]     [,65]     [,66]     [,67]     [,68]     [,69]     [,70]
    ## [1,] -1.870231 -5.193514 -4.561585 -3.480456 -5.374979 -2.457703 -6.689979
    ##          [,71]     [,72]     [,73]     [,74]     [,75]     [,76]     [,77]
    ## [1,] -4.299135 -3.150086 -6.586067 -3.646558 -6.994076 -6.594701 -6.078255
    ##          [,78]     [,79]     [,80]     [,81]     [,82]     [,83]    [,84]
    ## [1,] -6.330575 -7.411438 -4.732192 -3.688314 -9.029187 -9.319072 -3.52248
    ##          [,85]     [,86]    [,87]     [,88]    [,89]     [,90]     [,91]
    ## [1,] -7.817475 -3.533353 -9.88323 -10.37469 -4.87216 -6.032901 -4.503853
    ##         [,92]     [,93]     [,94]     [,95]     [,96]     [,97]    [,98]
    ## [1,] -10.7687 -4.938301 -5.207342 -12.24142 -9.538117 -12.02543 -8.19168
    ##         [,99]    [,100]
    ## [1,] -13.4163 -13.98679

``` r
tt1=Sys.time()
fit1.false=hierNest::hierNest(data$X,
                        data$Y,
                        method="overlapping",  ## Overlapping group lasso method
                        hier_info=data$hier_info,  ## Should input the hierarchical information for the groups
                        random_asparse = TRUE,  ## Randomly draw the other two tuning parameter?
                        nlambda=100,
                        intercept = FALSE,  ## Set intercept = FALSE can potentially save a huge amount of time
                        family="binomial")
```

    ## Warning: Randomly select penalty factor 1
    ## Randomly select penalty factor 2

    ## [1] "-----------asasa-----------"
    ## [1] "logit_sparse"

``` r
tt2=Sys.time()
print(tt2-tt1)
```

    ## Time difference of 0.462944 secs

``` r
fit1.false$npasses
```

    ## [1] 3939

``` r
fit1.false$beta[1,]
```

    ##         s0         s1         s2         s3         s4         s5         s6 
    ## -0.1603426 -0.1584371 -0.1590683 -0.1594904 -0.1597726 -0.1599614 -0.1600877 
    ##         s7         s8         s9        s10        s11        s12        s13 
    ## -0.1601721 -0.1602286 -0.1602664 -0.1602916 -0.1603085 -0.1603198 -0.1603274 
    ##        s14        s15        s16        s17        s18        s19        s20 
    ## -0.1603324 -0.1603358 -0.1603381 -0.1603396 -0.1603406 -0.1603413 -0.1603417 
    ##        s21        s22        s23        s24        s25        s26        s27 
    ## -0.1603420 -0.1603422 -0.1603424 -0.1603425 -0.1603425 -0.1603426 -0.1809907 
    ##        s28        s29        s30        s31        s32        s33        s34 
    ## -0.1951180 -0.1624835 -0.1617745 -0.1613003 -0.1880423 -0.2175854 -0.1626855 
    ##        s35        s36        s37        s38        s39        s40        s41 
    ## -0.1619096 -0.1974008 -0.2216799 -0.2664737 -0.1622803 -0.1616386 -0.3045434 
    ##        s42        s43        s44        s45        s46        s47        s48 
    ## -0.3094927 -0.1624154 -0.1617290 -0.2824433 -0.1628621 -0.3691345 -0.2474008 
    ##        s49        s50        s51        s52        s53        s54        s55 
    ## -0.1531276 -0.1778192 -0.1524950 -0.4802754 -0.3661138 -0.3307631 -0.5119552 
    ##        s56        s57        s58        s59        s60        s61        s62 
    ## -0.5052707 -0.9432874 -0.9748076 -0.2451175 -1.0155076 -1.0481419 -0.7829303 
    ##        s63        s64        s65        s66        s67        s68        s69 
    ## -0.3030353 -1.1627124 -0.5277279 -1.0085993 -1.2032726 -1.2447912 -0.4966181 
    ##        s70        s71        s72        s73        s74        s75        s76 
    ## -1.1780033 -1.2738533 -1.3208007 -1.3397792 -1.3434725 -1.0776762 -0.8505239 
    ##        s77        s78        s79        s80        s81        s82        s83 
    ## -1.3451021 -1.3857346 -1.3891310 -0.6999084 -1.3720568 -1.4467972 -1.6563231 
    ##        s84        s85        s86        s87        s88        s89        s90 
    ## -1.5260065 -1.8341975 -1.4415145 -1.5919053 -1.8419440 -1.6679004 -2.1187137 
    ##        s91        s92        s93        s94        s95        s96        s97 
    ## -2.0473548 -2.0296302 -1.9201826 -1.9189193 -1.8083056 -1.7921354 -2.2497001 
    ##        s98        s99 
    ## -2.2622585 -2.2978657
