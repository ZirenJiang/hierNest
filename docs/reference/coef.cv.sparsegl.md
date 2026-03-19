# Extract coefficients from a \`cv.sparsegl\` object.

This function etracts coefficients from a cross-validated \[sparsegl()\]
model, using the stored \`"sparsegl.fit"\` object, and the optimal value
chosen for \`lambda\`.

## Usage

``` r
# S3 method for class 'cv.sparsegl'
coef(object, s = c("lambda.1se", "lambda.min"), ...)
```

## Arguments

- object:

  Fitted \[cv.sparsegl()\] object.

- s:

  Value(s) of the penalty parameter \`lambda\` at which coefficients are
  desired. Default is the single value \`s = "lambda.1se"\` stored in
  the CV object (corresponding to the largest value of \`lambda\` such
  that CV error estimate is within 1 standard error of the minimum).
  Alternatively \`s = "lambda.min"\` can be used (corresponding to the
  minimum of cross validation error estimate). If \`s\` is numeric, it
  is taken as the value(s) of \`lambda\` to be used.

- ...:

  Not used.

## Value

The coefficients at the requested value(s) for \`lambda\`.

## See also

\[cv.sparsegl()\] and \[predict.cv.sparsegl()\].
