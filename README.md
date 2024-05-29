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

    ## Time difference of 0.603581 secs

``` r
sample_inx=sort(sample(1:NROW(data$X),NROW(data$X),TRUE))

## For now, please use our unique function of predict_hierNest to predict the outcome.
pred1=hierNest::predict_hierNest(fit1,newx = data$X[sample_inx,],hier_info=data$hier_info[sample_inx,],type = "response")

pred1[,80]
```

    ##   [1] 0.51517977 0.20004752 0.20004752 0.40803533 0.40803533 0.40991374
    ##   [7] 0.39089696 0.58797130 0.58797130 0.14764913 0.13919513 0.13919513
    ##  [13] 0.33282588 0.33282588 0.07235264 0.07235264 0.40897799 0.40897799
    ##  [19] 0.33585102 0.11610345 0.11610345 0.11610345 0.36022358 0.67142112
    ##  [25] 0.67142112 0.23846174 0.23846174 0.19019924 0.19019924 0.45180623
    ##  [31] 0.45180623 0.04940130 0.04940130 0.69529911 0.69529911 0.05798859
    ##  [37] 0.37330602 0.35072979 0.35072979 0.10382803 0.30306379 0.30306379
    ##  [43] 0.30306379 0.07094765 0.47742467 0.27694125 0.18284890 0.18284890
    ##  [49] 0.18284890 0.14028451 0.14028451 0.10914764 0.49918943 0.36859997
    ##  [55] 0.15795554 0.06577438 0.24320120 0.54865973 0.44393247 0.06579626
    ##  [61] 0.05571185 0.05571185 0.05747866 0.05747866 0.16545594 0.18126972
    ##  [67] 0.18126972 0.18126972 0.08802312 0.08802312 0.20927716 0.20927716
    ##  [73] 0.51472676 0.51472676 0.47561764 0.11816617 0.11816617 0.09258120
    ##  [79] 0.34770204 0.41132593 0.77481925 0.77481925 0.18509152 0.07523210
    ##  [85] 0.30365585 0.19729895 0.25716201 0.25716201 0.48438962 0.94252833
    ##  [91] 0.77937419 0.77937419 0.77937419 0.35726819 0.90905796 0.91748815
    ##  [97] 0.91748815 0.91748815 0.91748815 0.91748815 0.96806157 0.98318055
    ## [103] 0.92889200 0.88409831 0.93027311 0.86590135 0.86590135 0.92836309
    ## [109] 0.96561254 0.96561254 0.99418495 0.90343201 0.96877443 0.84752808
    ## [115] 0.84752808 0.84752808 0.79656683 0.95269949 0.95269949 0.95269949
    ## [121] 0.94258202 0.94258202 0.90234863 0.90234863 0.94391024 0.97807662
    ## [127] 0.67393083 0.67393083 0.99727054 0.99727054 0.99727054 0.98306875
    ## [133] 0.98801781 0.96753688 0.33107901 0.94005304 0.94005304 0.94005304
    ## [139] 0.96668656 0.97291854 0.74507872 0.57931896 0.57931896 0.03743885
    ## [145] 0.03743885 0.07365051 0.74170393 0.24324272 0.24324272 0.16597197
    ## [151] 0.02505560 0.02505560 0.02505560 0.02505560 0.31238063 0.31238063
    ## [157] 0.31238063 0.31238063 0.45154909 0.45154909 0.34999793 0.54844465
    ## [163] 0.54844465 0.15927719 0.24148149 0.24148149 0.12733988 0.12733988
    ## [169] 0.06995093 0.06995093 0.06995093 0.72681335 0.72681335 0.72681335
    ## [175] 0.08034750 0.08034750 0.49205649 0.49523426 0.49523426 0.17186372
    ## [181] 0.27896129 0.88033411 0.11585556 0.42748010 0.34636846 0.34636846
    ## [187] 0.93700916 0.68642743 0.68642743 0.01494354 0.30846113 0.30846113
    ## [193] 0.31881651 0.37187936 0.77190971 0.77190971 0.41597474 0.23674729
    ## [199] 0.23674729 0.23674729

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

    ## Time difference of 13.07386 secs

``` r
fit1.true$npasses
```

    ## [1] 72451

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

    ##            [,1]      [,2]     [,3]        [,4]      [,5]       [,6]       [,7]
    ## [1,] -0.1603426 0.4012432 0.159001 -0.05564396 0.3356778 -0.1650513 -0.1723424
    ##            [,8]       [,9]      [,10]      [,11]      [,12]      [,13]
    ## [1,] -0.2477432 -0.2613119 -0.1816155 -0.1865295 -0.1870049 -0.1614152
    ##          [,14]    [,15]      [,16]      [,17]     [,18]      [,19]     [,20]
    ## [1,] -1.038714 -1.05922 -0.9715288 -0.2250965 -1.133199 -0.2690028 -0.489303
    ##           [,21]     [,22]      [,23]      [,24]     [,25]      [,26]     [,27]
    ## [1,] -0.3060926 -1.222821 -0.6530613 -0.4982132 -1.435903 -0.9610517 -1.399939
    ##          [,28]      [,29]     [,30]     [,31]      [,32]     [,33]     [,34]
    ## [1,] -0.416801 -0.6007606 -1.307609 -1.499083 -0.9387692 -1.769875 -1.292507
    ##          [,35]     [,36]     [,37]     [,38]      [,39]     [,40]     [,41]
    ## [1,] -1.380392 -1.624815 -1.794573 -1.014787 -0.7840299 -1.794861 -1.394218
    ##          [,42]     [,43]     [,44]     [,45]     [,46]     [,47]     [,48]
    ## [1,] -1.019695 -2.795425 -1.332704 -1.428211 -1.467652 -1.182156 -2.157523
    ##          [,49]     [,50]     [,51]    [,52]     [,53]     [,54]     [,55]
    ## [1,] -1.839777 -2.568096 -1.715998 -1.74983 -2.305961 -2.211334 -1.407062
    ##          [,56]     [,57]     [,58]     [,59]     [,60]     [,61]     [,62]
    ## [1,] -3.621621 -1.456714 -2.685616 -4.519888 -4.123196 -2.868153 -2.792018
    ##          [,63]     [,64]     [,65]     [,66]     [,67]     [,68]   [,69]
    ## [1,] -3.720557 -3.291424 -5.163734 -6.087329 -4.980221 -5.355883 -5.2276
    ##          [,70]     [,71]     [,72]     [,73]     [,74]     [,75]     [,76]
    ## [1,] -5.868945 -5.321187 -5.608321 -4.188924 -3.345325 -2.665882 -2.638868
    ##         [,77]     [,78]     [,79]     [,80]     [,81]     [,82]    [,83]
    ## [1,] -8.23544 -4.433153 -7.862783 -3.792772 -2.959166 -6.374523 -4.87106
    ##          [,84]     [,85]     [,86]     [,87]     [,88]     [,89]    [,90]
    ## [1,] -3.883354 -9.167329 -6.630698 -6.630648 -6.630597 -7.702255 -10.7178
    ##          [,91]     [,92]     [,93]     [,94]    [,95]     [,96]     [,97]
    ## [1,] -11.30309 -9.310668 -12.45454 -10.29021 -9.75905 -6.131057 -8.081683
    ##          [,98]     [,99]    [,100]
    ## [1,] -4.836589 -8.764355 -8.890497

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

    ## Time difference of 0.3858378 secs

``` r
fit1.false$npasses
```

    ## [1] 3350

``` r
fit1.false$beta[1,] # When intercept = FALSE, beta[1,] will be the estimate of intercept
```

    ##         s0         s1         s2         s3         s4         s5         s6 
    ## -0.1603426 -0.1584371 -0.1590683 -0.1594904 -0.1597726 -0.1599614 -0.1600877 
    ##         s7         s8         s9        s10        s11        s12        s13 
    ## -0.1601721 -0.1602286 -0.1602664 -0.1602916 -0.1603085 -0.1603198 -0.1603274 
    ##        s14        s15        s16        s17        s18        s19        s20 
    ## -0.1603324 -0.1603358 -0.1603381 -0.1603396 -0.1603406 -0.1603413 -0.1603417 
    ##        s21        s22        s23        s24        s25        s26        s27 
    ## -0.1603420 -0.1603422 -0.1603424 -0.1620387 -0.1612759 -0.1869054 -0.1628130 
    ##        s28        s29        s30        s31        s32        s33        s34 
    ## -0.1866531 -0.1993063 -0.1623498 -0.1616851 -0.2219143 -0.1652975 -0.2342438 
    ##        s35        s36        s37        s38        s39        s40        s41 
    ## -0.2410569 -0.1625760 -0.1618364 -0.1613417 -0.1825431 -0.1624171 -0.1617301 
    ##        s42        s43        s44        s45        s46        s47        s48 
    ## -0.1612706 -0.2789323 -0.1625078 -0.2690698 -0.1840392 -0.2519632 -0.3554415 
    ##        s49        s50        s51        s52        s53        s54        s55 
    ## -0.3391646 -0.3280421 -0.4331004 -0.2032048 -0.5539501 -0.5482898 -0.2205718 
    ##        s56        s57        s58        s59        s60        s61        s62 
    ## -0.3574970 -0.5062287 -0.8826900 -0.9927109 -0.9714686 -1.0401058 -0.5536047 
    ##        s63        s64        s65        s66        s67        s68        s69 
    ## -0.2983059 -0.3123857 -0.5697870 -1.1075171 -1.2122478 -0.8267880 -1.2644895 
    ##        s70        s71        s72        s73        s74        s75        s76 
    ## -1.1179969 -0.9935496 -0.4771682 -0.4887474 -0.6094749 -0.6245371 -0.8110001 
    ##        s77        s78        s79        s80        s81        s82        s83 
    ## -0.8825372 -1.3780609 -1.5000484 -1.5193537 -1.5269434 -1.5394069 -1.5707095 
    ##        s84        s85        s86        s87        s88        s89        s90 
    ## -1.7109907 -1.6783114 -1.6921613 -1.1617673 -1.4129772 -1.7945821 -1.6286182 
    ##        s91        s92        s93        s94        s95        s96        s97 
    ## -1.6341079 -1.8060786 -1.8074137 -2.2884129 -1.9760490 -2.0301346 -2.2035794 
    ##        s98        s99 
    ## -2.5613588 -2.3934672
