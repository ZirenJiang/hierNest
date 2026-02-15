
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

The `cv.hierNest()` function both fits models and selects tuning
parameters via $K$-fold cross validation.

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

<div class="plotly html-widget html-fill-item" id="htmlwidget-6635e9b85f61e36efe7e" style="width:100%;height:480px;"></div>
<script type="application/json" data-for="htmlwidget-6635e9b85f61e36efe7e">{"x":{"visdat":{"5462288d6f8f":["function () ","plotlyVisDat"]},"cur_data":"5462288d6f8f","attrs":{"5462288d6f8f":{"x":{},"y":{},"z":{},"colorscale":[["0","red"],["0.5","white"],["1","blue"]],"zmin":-0.7220898635785945,"zmax":0.7220898635785945,"colorbar":{"title":"Value"},"showscale":true,"alpha_stroke":1,"sizes":[10,100],"spans":[1,20],"type":"heatmap"}},"layout":{"margin":{"b":40,"l":60,"t":25,"r":10},"xaxis":{"domain":[0,1],"automargin":true,"title":"Predictors","tickmode":"array","tickvals":[1,2,3,4,5,6,7],"ticktext":["X30","X13","Intercept","X14","X24","X9","X29"]},"yaxis":{"domain":[0,1],"automargin":true,"title":"Subgroup effects","autorange":"reversed","tickmode":"array","tickvals":[1,2,3,4,5,6,7],"ticktext":["Overall mean effect","Group 1","Subgroup 1","Subgroup 2","Group 2","Subgroup 3","Subgroup 4"]},"scene":{"zaxis":{"title":"plot_val"}},"hovermode":"closest","showlegend":false,"legend":{"yanchor":"top","y":0.5}},"source":"A","config":{"modeBarButtonsToAdd":["hoverclosest","hovercompare"],"showSendToCloud":false},"data":[{"colorbar":{"title":"Value","ticklen":2,"len":0.5,"lenmode":"fraction","y":1,"yanchor":"top"},"colorscale":[["0","red"],["0.5","white"],["1","blue"]],"showscale":true,"x":[1,1,1,1,1,1,1,2,2,2,2,2,2,2,3,3,3,3,3,3,3,4,4,4,4,4,4,4,5,5,5,5,5,5,5,6,6,6,6,6,6,6,7,7,7,7,7,7,7],"y":[1,2,3,4,5,6,7,1,2,3,4,5,6,7,1,2,3,4,5,6,7,1,2,3,4,5,6,7,1,2,3,4,5,6,7,1,2,3,4,5,6,7,1,2,3,4,5,6,7],"z":[0.20677216030794571,-1.1971951163041602e-05,null,-0.0013575926539857004,0.19741206934129724,0.17846096622484275,0.013486494126654505,0.16892263064949464,null,-0.11592928123269229,0.10423637709566766,null,-0.043337964711142977,0.27885448256039774,-2.1981168646739588,null,null,null,0.33538033117411348,0.7226783474397187,null,-0.33309255904032808,-0.12847564929953931,null,-0.39736830044349042,null,null,null,0.27447673947992024,null,null,null,0.043974767057071484,0.18857021584815697,null,-0.19641253358941496,null,null,null,null,null,null,0.71090867021723503,null,null,null,null,null,null],"zmin":-0.7220898635785945,"zmax":0.7220898635785945,"type":"heatmap","xaxis":"x","yaxis":"y","frame":null}],"highlight":{"on":"plotly_click","persistent":false,"dynamic":false,"selectize":false,"opacityDim":0.20000000000000001,"selected":{"opacity":1},"debounce":0},"shinyEvents":["plotly_hover","plotly_click","plotly_selected","plotly_relayout","plotly_brushed","plotly_brushing","plotly_clickannotation","plotly_doubleclick","plotly_deselect","plotly_afterplot","plotly_sunburstclick"],"base_url":"https://plot.ly"},"evals":[],"jsHooks":[]}</script>

By specifying the type = “Subgroup effect”, we plot the covaraite
effects for each subgroup.

``` r
plot(cv.fit, type = "Subgroup effects")
```

<div class="plotly html-widget html-fill-item" id="htmlwidget-ebc1f8007de088e60f40" style="width:100%;height:480px;"></div>
<script type="application/json" data-for="htmlwidget-ebc1f8007de088e60f40">{"x":{"visdat":{"546264b4e8da":["function () ","plotlyVisDat"]},"cur_data":"546264b4e8da","attrs":{"546264b4e8da":{"x":{},"y":{},"z":{},"colorscale":[["0","red"],["0.5","white"],["1","blue"]],"zmin":-2.0807337487630186,"zmax":2.0807337487630186,"colorbar":{"title":"Value"},"showscale":true,"alpha_stroke":1,"sizes":[10,100],"spans":[1,20],"type":"heatmap"}},"layout":{"margin":{"b":40,"l":60,"t":25,"r":10},"xaxis":{"domain":[0,1],"automargin":true,"title":"Predictors","tickmode":"array","tickvals":[1,2,3,4,5,6,7],"ticktext":["Intercept","X9","X13","X14","X24","X29","X30"]},"yaxis":{"domain":[0,1],"automargin":true,"title":"Subgroup effects","autorange":"reversed","tickmode":"array","tickvals":[1,2,3,4],"ticktext":["Sub-Group 1","Sub-Group 2","Sub-Group 3","Sub-Group 4"]},"scene":{"zaxis":{"title":"plot_val"}},"hovermode":"closest","showlegend":false,"legend":{"yanchor":"top","y":0.5}},"source":"A","config":{"modeBarButtonsToAdd":["hoverclosest","hovercompare"],"showSendToCloud":false},"data":[{"colorbar":{"title":"Value","ticklen":2,"len":0.5,"lenmode":"fraction","y":1,"yanchor":"top"},"colorscale":[["0","red"],["0.5","white"],["1","blue"]],"showscale":true,"x":[1,1,1,1,2,2,2,2,3,3,3,3,4,4,4,4,5,5,5,5,6,6,6,6,7,7,7,7],"y":[1,2,3,4,1,2,3,4,1,2,3,4,1,2,3,4,1,2,3,4,1,2,3,4,1,2,3,4],"z":[-2.1981168646739588,-2.1981168646739588,-1.1400581860601267,-1.8627365334998454,-0.19641253358941496,-0.19641253358941496,-0.19641253358941496,-0.19641253358941496,0.052993349416802352,0.27315900774516233,0.12558466593835166,0.44777711320989239,-0.46156820833986739,-0.85893650878335781,-0.33309255904032808,-0.33309255904032808,0.27447673947992024,0.27447673947992024,0.50702172238514875,0.31845150653699172,0.71090867021723503,0.71090867021723503,0.71090867021723503,0.71090867021723503,0.20676018835678267,0.20540259570279698,0.5826451958740857,0.41767072377589742],"zmin":-2.0807337487630186,"zmax":2.0807337487630186,"type":"heatmap","xaxis":"x","yaxis":"y","frame":null}],"highlight":{"on":"plotly_click","persistent":false,"dynamic":false,"selectize":false,"opacityDim":0.20000000000000001,"selected":{"opacity":1},"debounce":0},"shinyEvents":["plotly_hover","plotly_click","plotly_selected","plotly_relayout","plotly_brushed","plotly_brushing","plotly_clickannotation","plotly_doubleclick","plotly_deselect","plotly_afterplot","plotly_sunburstclick"],"base_url":"https://plot.ly"},"evals":[],"jsHooks":[]}</script>

## Grab chosen lambda and coefficients

``` r
cv.fit$lambda.min    # lambda minimizing CV loss
#> [1] 0.0008235796
```

``` r
cv.fit$min_alpha1    # alpha1 minimizing CV loss
#> [1] 0.5
```

``` r
cv.fit$min_alpha2    # lambda minimizing CV loss
#> [1] 0.2
```
