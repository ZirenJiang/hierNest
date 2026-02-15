# Calculate information criteria.

This function uses the degrees of freedom to calculate various
information criteria. This function uses the "unknown variance" version
of the likelihood. Only implemented for Gaussian regression. The
constant is ignored (as in \[stats::extractAIC()\]).

## Usage

``` r
estimate_risk(object, x, type = c("AIC", "BIC", "GCV"), approx_df = FALSE)
```

## Arguments

- object:

  fitted object from a call to \[sparsegl()\].

- x:

  Matrix. The matrix of predictors used to estimate the \`sparsegl\`
  object. May be missing if \`approx_df = TRUE\`.

- type:

  one or more of AIC, BIC, or GCV.

- approx_df:

  the \`df\` component of a \`sparsegl\` object is an approximation
  (albeit a fairly accurate one) to the actual degrees-of-freedom.
  However, the exact value requires inverting a portion of \`X'X\`. So
  this computation may take some time (the default computes the exact
  df).

## Value

a \`data.frame\` with as many rows as \`object\$lambda\`. It contains
columns \`lambda\`, \`df\`, and the requested risk types.

## References

Vaiter S, Deledalle C, Peyré G, Fadili J, Dossal C. (2012). *The Degrees
of Freedom of the Group Lasso for a General Design*.
<https://arxiv.org/pdf/1212.6478.pdf>.

## See also

\[sparsegl()\] method.
