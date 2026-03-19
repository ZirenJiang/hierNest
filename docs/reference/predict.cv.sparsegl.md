# Make predictions from a \`cv.sparsegl\` object.

This function makes predictions from a cross-validated \[cv.sparsegl()\]
object, using the stored \`sparsegl.fit\` object, and the value chosen
for \`lambda\`.

## Usage

``` r
# S3 method for class 'cv.sparsegl'
predict(
  object,
  newx,
  s = c("lambda.1se", "lambda.min"),
  type = c("link", "response", "coefficients", "nonzero", "class"),
  ...
)
```

## Arguments

- object:

  Fitted \[cv.sparsegl()\] object.

- newx:

  Matrix of new values for \`x\` at which predictions are to be made.
  Must be a matrix. This argument is mandatory.

- s:

  Value(s) of the penalty parameter \`lambda\` at which coefficients are
  desired. Default is the single value \`s = "lambda.1se"\` stored in
  the CV object (corresponding to the largest value of \`lambda\` such
  that CV error estimate is within 1 standard error of the minimum).
  Alternatively \`s = "lambda.min"\` can be used (corresponding to the
  minimum of cross validation error estimate). If \`s\` is numeric, it
  is taken as the value(s) of \`lambda\` to be used.

- type:

  Type of prediction required. Type \`"link"\` gives the linear
  predictors for \`"binomial"\`; for \`"gaussian"\` models it gives the
  fitted values. Type \`"response"\` gives predictions on the scale of
  the response (for example, fitted probabilities for \`"binomial"\`);
  for \`"gaussian"\` type \`"response"\` is equivalent to type
  \`"link"\`. Type \`"coefficients"\` computes the coefficients at the
  requested values for \`s\`. Type \`"class"\` applies only to
  \`"binomial"\` models, and produces the class label corresponding to
  the maximum probability. Type \`"nonzero"\` returns a list of the
  indices of the nonzero coefficients for each value of `s`.

- ...:

  Not used.

## Value

A matrix or vector of predicted values.

## See also

\[cv.sparsegl()\] and \[coef.cv.sparsegl()\].
