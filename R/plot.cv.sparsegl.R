

plot.cv.sparsegl <- function(x, log_axis = c("xy", "x", "y", "none"),
                             sign.lambda = 1, ...) {
  rlang::check_dots_empty()
  cvobj <- x
  dat <- data.frame("X" = sign.lambda * cvobj$lambda,
                    "y" = cvobj$cvm,
                    "upper" = cvobj$cvupper,
                    "lower" = cvobj$cvlo)
  log_axis <- match.arg(log_axis)
  sign.lambda <- sign(sign.lambda)
  g <- dat %>%
    ggplot2::ggplot(ggplot2::aes(x = .data$X, y = .data$y)) +
    ggplot2::geom_errorbar(
      ggplot2::aes(ymin = .data$lower, ymax = .data$upper),
      color = 'darkgrey') +
    ggplot2::geom_point(color = 'darkblue') +
    ggplot2::xlab("Lambda") +
    ggplot2::ylab(cvobj$name) +
    ggplot2::theme_bw()
  switch(log_axis,
         xy = g + ggplot2::scale_x_log10() + ggplot2::scale_y_log10(),
         x = g + ggplot2::scale_x_log10(),
         y = g + ggplot2::scale_y_log10(),
         g)
}
