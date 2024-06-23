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

    ## Time difference of 2.073729 secs

``` r
sample_inx=sort(sample(1:NROW(data$X),NROW(data$X),TRUE))

## For now, please use our unique function of predict_hierNest to predict the outcome.
pred1=hierNest::predict_hierNest(fit1,newx = data$X[sample_inx,],hier_info=data$hier_info[sample_inx,],type = "response")

pred1[,80]
```

    ##   [1] 0.0381213036 0.5575840485 0.4370150525 0.2306261952 0.0453615711
    ##   [6] 0.0453615711 0.3871168411 0.1753960506 0.2166538403 0.2447024633
    ##  [11] 0.2180255928 0.3914872255 0.3914872255 0.3914872255 0.0408699910
    ##  [16] 0.0110649391 0.1756145931 0.3059210043 0.3059210043 0.4770143292
    ##  [21] 0.0817066326 0.1373528678 0.1373528678 0.3143914440 0.3143914440
    ##  [26] 0.0348826080 0.0348826080 0.9510475509 0.9510475509 0.9117722034
    ##  [31] 0.9117722034 0.9117722034 0.0154057226 0.4966303844 0.4966303844
    ##  [36] 0.4966303844 0.4952348758 0.0195524252 0.0195524252 0.0195524252
    ##  [41] 0.3669400825 0.3669400825 0.3669400825 0.6159948913 0.8999361311
    ##  [46] 0.8999361311 0.8999361311 0.0749793998 0.0749793998 0.0794570694
    ##  [51] 0.0003723529 0.2607474818 0.0010992564 0.0003297544 0.0003297544
    ##  [56] 0.0003297544 0.9206190434 0.9206190434 0.2526478301 0.1352048433
    ##  [61] 0.1352048433 0.0016271403 0.0016271403 0.0016271403 0.0016271403
    ##  [66] 0.0016271403 0.0016271403 0.0203080655 0.1513660163 0.1513660163
    ##  [71] 0.1513660163 0.8198132417 0.8198132417 0.7173135704 0.7173135704
    ##  [76] 0.1222361265 0.0035713813 0.0015139519 0.0015139519 0.0015139519
    ##  [81] 0.0025292162 0.0025292162 0.0520252472 0.1262630156 0.4849660298
    ##  [86] 0.6622536305 0.6622536305 0.9711494195 0.9711494195 0.0906417407
    ##  [91] 0.0906417407 0.1855320185 0.0156880886 0.0156880886 0.0230164127
    ##  [96] 0.6732021109 0.6732021109 0.2140358934 0.2140358934 0.9051556541
    ## [101] 0.9051556541 0.0366213483 0.0031654668 0.0031654668 0.2476626679
    ## [106] 0.2476626679 0.9531197454 0.9212155501 0.9212155501 0.9949523092
    ## [111] 0.9998607256 0.9669711527 0.9669711527 0.9051049025 0.9725398623
    ## [116] 0.9999529459 0.9999529459 0.9804807551 0.9804807551 0.9538907326
    ## [121] 0.9997401830 0.9997401830 0.9997401830 0.9997401830 0.9979774710
    ## [126] 0.9979774710 0.9979774710 0.9972831715 0.9958997706 0.9699794541
    ## [131] 0.9975521415 0.9557168218 0.9978054040 0.9772748445 0.9429762394
    ## [136] 0.9928026865 0.9928026865 0.9928026865 0.9999499044 0.9999499044
    ## [141] 0.2818039552 0.9996930054 0.9859420791 0.9993797037 0.9915004565
    ## [146] 0.9915004565 0.9915004565 0.9915004565 0.9915004565 0.9915004565
    ## [151] 0.0901713788 0.9536461561 0.9994535590 0.9892245701 0.9892245701
    ## [156] 0.8958690013 0.8958690013 0.6557912352 0.6557912352 0.9816836937
    ## [161] 0.0001987435 0.0143536610 0.0591456532 0.4573827945 0.4183411907
    ## [166] 0.4183411907 0.0087264203 0.0087264203 0.4189150536 0.0955145253
    ## [171] 0.6606833304 0.6606833304 0.8733489483 0.8733489483 0.8733489483
    ## [176] 0.9864326878 0.9864326878 0.0578743735 0.5736662711 0.5679470256
    ## [181] 0.0116553248 0.0116553248 0.4659585363 0.8594475997 0.7127693528
    ## [186] 0.7127693528 0.1253857833 0.3189061526 0.5986410724 0.4373381694
    ## [191] 0.8515664396 0.8515664396 0.9103956765 0.9103956765 0.5770252369
    ## [196] 0.5770252369 0.2015547318 0.2015547318 0.2015547318 0.0322220395

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
                   asparse1_num = 4,asparse2_num = 4, # number of grids for alpha_1 and alpha_2, total 25 grids will be selected
                   nlambda = 50, # length of lambda sequence for each pair of alpha_1 and alpha_2
                   intercept = FALSE)


fit.selected=hierNest::hierNest(data$X,data$Y,method="overlapping", hier_info=data$hier_info,family="binomial",
                   asparse1 = cv.fit2$sparsegl.fit$asparse1, # Need to input selected alpha_1
                   asparse2 = cv.fit2$sparsegl.fit$asparse2, # Need to input selected alpha_2
                   lambda = cv.fit2$lambda.min, # Selected lambda value
                   intercept = FALSE)

cv.fit2$lambda
```

### Method 3: user supply pairs of asparse1 and asparse2

hierNest also support the user-supplied pairs of $(\alpha_1, \alpha_2)$,
see the following code:

``` r
cv.fit3=hierNest::cv.hierNest(data$X,data$Y,method="overlapping",# For now, we only wrap-up the overlapping group lasso method in this function
                   hier_info=data$hier_info,family="binomial",
                   partition = "subgroup", # partition = "subgroup" make sure the each n-fold is sampled within the subgroups to avoid extreme cases
                   cvmethod = "user_supply", # cvmethod = "grid_search" indicate the second cross-validation method
                   asparse1 = c(1:15),asparse2 = c((1:15)/20), # For the second method, need to input the upper and lower bounds of alpha_1 and alpha_2
                   nlambda = 50,intercept = FALSE)
```

    ## [1] "-----------asasa-----------"
    ## [1] "logit_sparse"
    ## [1] "-----------asasa-----------"
    ## [1] "logit_sparse"
    ## [1] "-----------asasa-----------"
    ## [1] "logit_sparse"
    ## [1] "-----------asasa-----------"
    ## [1] "logit_sparse"
    ## [1] "-----------asasa-----------"
    ## [1] "logit_sparse"
    ## [1] "-----------asasa-----------"
    ## [1] "logit_sparse"
    ## [1] "-----------asasa-----------"
    ## [1] "logit_sparse"
    ## [1] "-----------asasa-----------"
    ## [1] "logit_sparse"
    ## [1] "-----------asasa-----------"
    ## [1] "logit_sparse"
    ## [1] "-----------asasa-----------"
    ## [1] "logit_sparse"
    ## [1] "-----------asasa-----------"
    ## [1] "logit_sparse"
    ## [1] "-----------asasa-----------"
    ## [1] "logit_sparse"
    ## [1] "-----------asasa-----------"
    ## [1] "logit_sparse"
    ## [1] "-----------asasa-----------"
    ## [1] "logit_sparse"
    ## [1] "-----------asasa-----------"
    ## [1] "logit_sparse"
    ## [1] "-----------asasa-----------"
    ## [1] "logit_sparse"
    ## [1] "binomial leave out"
    ## [1] "-----------asasa-----------"
    ## [1] "logit_sparse"
    ## [1] "-----------asasa-----------"
    ## [1] "logit_sparse"
    ## [1] "-----------asasa-----------"
    ## [1] "logit_sparse"
    ## [1] "-----------asasa-----------"
    ## [1] "logit_sparse"
    ## [1] "-----------asasa-----------"
    ## [1] "logit_sparse"
    ## [1] "-----------asasa-----------"
    ## [1] "logit_sparse"
    ## [1] "-----------asasa-----------"
    ## [1] "logit_sparse"
    ## [1] "-----------asasa-----------"
    ## [1] "logit_sparse"
    ## [1] "-----------asasa-----------"
    ## [1] "logit_sparse"
    ## [1] "-----------asasa-----------"
    ## [1] "logit_sparse"
    ## [1] "cverror_binomial"

``` r
## selected index of the cross-validation
cv.fit3$lambda[cv.fit3$cv.inx]
```

    ## [1] 0.000557882

``` r
cv.fit3$lambda.min
```

    ## [1] 0.000557882

``` r
## Final cv.fit, the selected pair of (lambda, alpha_1, alpha_2) can be extracted using cv.inx
cv.fit3$sparsegl.fit
```

    ## 
    ## Call:  overlapping_gl(x = x, y = y, group = group, family = family,  
    ##     nlambda = ..4, lambda.factor = ..5, lambda = lambda, pf_group = ..6,  
    ##     pf_sparse = ..7, intercept = ..1, asparse1 = ..2, asparse2 = ..3,  
    ##     standardize = ..8, lower_bnd = ..9, upper_bnd = ..10, weights = weights,  
    ##     offset = offset, eps = ..11, maxit = ..12, cn = cn, drgix = drgix,  
    ##     drgiy = drgiy, cn_s = cn_s, cn_e = cn_e) 
    ## 
    ## Summary of Lambda sequence:
    ##           lambda index nnzero active_grps
    ## Max.    1.57e-03     1      7           1
    ## 3rd Qu. 5.08e-04   188     23          14
    ## Median  1.50e-04   376    145          24
    ## 1st Qu. 4.85e-05   563    120          31
    ## Min.    1.57e-05   750    124          31

``` r
## Selected alpha1
cv.fit3$sparsegl.fit$asparse1[cv.fit3$cv.inx]
```

    ## [1] 1

``` r
## Selected alpha2
cv.fit3$sparsegl.fit$asparse2[cv.fit3$cv.inx]
```

    ## [1] 0.05

## Exclude intercept can potentially save a huge amount of time

In practice, we observe that including an intercept in the model (by
setting `intercept = TRUE`) significantly increases the algorithm’s
runtime. To address this issue, we have revised our program to
incorporate the intercept into the first column of the design matrix,
applying no penalty to it. Now, users can set `intercept = FALSE`
directly, and our program will automatically generate a column of all
1s, with the coefficient (beta\[1,\]) representing the overall
intercept.

Generally speaking, set `intercept = TRUE` and `intercept = FALSE` is
equivalent in the algorithm. However, there may be some differences in
the computing. See the following code for comparison:

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

    ## Time difference of 15.77186 secs

``` r
fit1.true$npasses
```

    ## [1] 87536

``` r
fit1.true$beta[1,]  # When intercept = TRUE, beta[1,] will be 0 as it act the same as intercept
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
fit1.true$b0 # b0 is the estimate of intercept
```

    ##            [,1]       [,2]       [,3]       [,4]       [,5]       [,6]
    ## [1,] -0.1603426 -0.0598016 -0.2713422 -0.1676062 -0.1748894 -0.1809149
    ##            [,7]      [,8]      [,9]     [,10]      [,11]      [,12]     [,13]
    ## [1,] -0.2944664 -0.178564 -0.922575 -1.024548 -0.4369251 -0.1981895 -1.021694
    ##          [,14]      [,15]      [,16]     [,17]      [,18]     [,19]     [,20]
    ## [1,] -1.030576 -0.9515101 -0.4614815 -1.143995 -0.4749667 -1.363719 -0.341315
    ##          [,21]     [,22]     [,23]     [,24]      [,25]     [,26]     [,27]
    ## [1,] -1.269686 -1.452247 -0.466414 -1.574376 -0.8290846 -1.185777 -1.573835
    ##           [,28]     [,29]      [,30]     [,31]     [,32]     [,33]     [,34]
    ## [1,] -0.8967948 -1.543658 -0.7953291 -1.233222 -1.213217 -1.681066 -1.414492
    ##          [,35]     [,36]    [,37]     [,38]     [,39]     [,40]     [,41]
    ## [1,] -1.322193 -1.779573 -1.61109 -1.575718 -2.011968 -1.691553 -2.723299
    ##          [,42]     [,43]     [,44]     [,45]     [,46]     [,47]     [,48]
    ## [1,] -1.505395 -2.271566 -1.450158 -2.371251 -3.436077 -1.899168 -1.170806
    ##         [,49]     [,50]     [,51]     [,52]     [,53]     [,54]     [,55]
    ## [1,] -2.98405 -3.128181 -2.291769 -1.451864 -1.896172 -1.743323 -4.575084
    ##         [,56]     [,57]     [,58]     [,59]     [,60]     [,61]     [,62]
    ## [1,] -3.24382 -4.967322 -3.173091 -2.509738 -2.397902 -2.144072 -4.395071
    ##          [,63]     [,64]     [,65]     [,66]     [,67]     [,68]     [,69]
    ## [1,] -4.993466 -2.364329 -3.788366 -5.938339 -6.367332 -5.289184 -3.296062
    ##          [,70]     [,71]     [,72]     [,73]     [,74]     [,75]     [,76]
    ## [1,] -3.294635 -3.081636 -8.038076 -3.277302 -8.361178 -5.709593 -5.709624
    ##          [,77]     [,78]     [,79]     [,80]     [,81]     [,82]     [,83]
    ## [1,] -7.425395 -7.258298 -4.661885 -8.922877 -8.158845 -3.972018 -9.034325
    ##          [,84]     [,85]     [,86]     [,87]     [,88]     [,89]     [,90]
    ## [1,] -8.058652 -5.634313 -5.634364 -10.76885 -10.76925 -11.17305 -11.17311
    ##          [,91]     [,92]     [,93]     [,94]     [,95]     [,96]     [,97]
    ## [1,] -10.10401 -7.350061 -4.337765 -8.118473 -4.603109 -12.84649 -7.280499
    ##       [,98]     [,99]    [,100]
    ## [1,] -5.024 -10.03214 -10.97799

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

    ## Time difference of 1.543692 secs

``` r
fit1.false$npasses
```

    ## [1] 9638

``` r
fit1.false$beta[1,] # When intercept = FALSE, beta[1,] will be the estimate of intercept
```

    ##         s0         s1         s2         s3         s4         s5         s6 
    ## -0.1603426 -0.5852169 -0.5153598 -0.2342650 -0.2156839 -0.2025073 -0.5629334 
    ##         s7         s8         s9        s10        s11        s12        s13 
    ## -0.2350856 -0.9258311 -0.9560253 -0.9974698 -0.7985035 -0.2953967 -0.2849919 
    ##        s14        s15        s16        s17        s18        s19        s20 
    ## -1.1179553 -1.1768603 -1.2024799 -0.3996086 -1.2473267 -1.2561443 -0.4708107 
    ##        s21        s22        s23        s24        s25        s26        s27 
    ## -0.4683258 -1.0563998 -1.2404882 -1.3667523 -1.4125760 -1.4603299 -1.0151518 
    ##        s28        s29        s30        s31        s32        s33        s34 
    ## -1.0459055 -1.4308429 -1.0649957 -1.4876457 -1.3564344 -1.5302693 -1.5380853 
    ##        s35        s36        s37        s38        s39        s40        s41 
    ## -1.6027960 -1.7843145 -1.5244162 -1.6705872 -1.4792449 -1.5960008 -1.4103837 
    ##        s42        s43        s44        s45        s46        s47        s48 
    ## -1.4749032 -1.7268905 -1.9288174 -1.9372681 -1.7510813 -2.1658219 -2.0609934 
    ##        s49        s50        s51        s52        s53        s54        s55 
    ## -1.9413615 -2.5001122 -2.7261329 -2.4407449 -2.6508993 -2.5269213 -2.5218917 
    ##        s56        s57        s58        s59        s60        s61        s62 
    ## -2.7114399 -2.9918407 -2.9931171 -3.3827486 -3.3835874 -3.2679549 -2.8348446 
    ##        s63        s64        s65        s66        s67        s68        s69 
    ## -2.9837254 -2.7440260 -2.7987753 -3.0926856 -3.1597219 -3.3323747 -3.6883242 
    ##        s70        s71        s72        s73        s74        s75        s76 
    ## -4.1821536 -4.0091974 -4.6343496 -4.6354237 -4.6364333 -4.3942381 -4.3945690 
    ##        s77        s78        s79        s80        s81        s82        s83 
    ## -4.2199269 -4.7599873 -4.1439509 -4.2707931 -4.5580979 -4.8924317 -4.9291222 
    ##        s84        s85        s86        s87        s88        s89        s90 
    ## -5.1686950 -5.1698397 -5.1709893 -5.4351016 -5.4362165 -5.5466083 -5.5477058 
    ##        s91        s92        s93        s94        s95        s96        s97 
    ## -5.5487822 -5.5497143 -5.5718881 -5.6050888 -5.8651554 -5.8662552 -5.8672136 
    ##        s98        s99 
    ## -5.9305914 -5.9615594
