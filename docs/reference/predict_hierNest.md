# Predict Method for hierNest Objects

Provides predictions from a fitted hierarchical model (\`hierNest\`)
using new data.

## Usage

``` r
predict_hierNest(
  object,
  newx,
  hier_info,
  type = c("link", "response", "coefficients", "nonzero", "class"),
  ...
)
```

## Arguments

- object:

  A fitted hierNest model object.

- newx:

  A numeric matrix of new predictor values for prediction.

- hier_info:

  A numeric matrix with hierarchical grouping information. First column
  is MDC-level grouping; second column is DRG-level grouping.

- type:

  Character string specifying the type of prediction required. Options
  include "link", "response", "coefficients", "nonzero", and "class".

- ...:

  Additional arguments passed to lower-level prediction methods.

## Value

Predictions based on the specified \`type\`. Typically, returns:

- Numeric vector or matrix of predicted values (for "link" or
  "response").

- Model coefficients (for "coefficients").

- Nonzero coefficient indices (for "nonzero").

- Class labels for categorical outcomes (for "class").

## Details

This function prepares a hierarchical design matrix based on
\`hier_info\`, constructs the required Khatri-Rao product, and
reorganizes it before generating predictions from the provided
\`object\`.
