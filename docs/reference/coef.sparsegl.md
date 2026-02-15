# Extract model coefficients from a \`sparsegl\` object.

Computes the coefficients at the requested value(s) for \`lambda\` from
a \[sparsegl()\] object.

## Usage

``` r
# S3 method for class 'sparsegl'
coef(object, s = NULL, ...)
```

## Arguments

- object:

  Fitted \[sparsegl()\] object.

- s:

  Value(s) of the penalty parameter \`lambda\` at which coefficients are
  required. Default is the entire sequence.

- ...:

  Not used.

## Value

The coefficients at the requested values for \`lambda\`.

## Details

\`s\` is the new vector of \`lambda\` values at which predictions are
requested. If \`s\` is not in the lambda sequence used for fitting the
model, the \`coef\` function will use linear interpolation to make
predictions. The new values are interpolated using a fraction of
coefficients from both left and right \`lambda\` indices.

## See also

\[sparsegl()\] and \[predict.sparsegl()\].
