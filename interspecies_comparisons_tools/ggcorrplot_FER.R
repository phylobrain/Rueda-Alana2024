#' Visualization of a correlation matrix using ggplot2
#' @import ggplot2
#' @description \itemize{ \item ggcorrplot(): A graphical display of a
#'   correlation matrix using ggplot2. \item cor_pmat(): Compute a correlation
#'   matrix p-values. }
#' @param corr the correlation matrix to visualize
#' @param method character, the visualization method of correlation matrix to be
#'   used. Allowed values are "square" (default), "circle".
#' @param type character, "full" (default), "lower" or "upper" display.
#' @param ggtheme ggplot2 function or theme object. Default value is
#'   `theme_minimal`. Allowed values are the official ggplot2 themes including
#'   theme_gray, theme_bw, theme_minimal, theme_classic, theme_void, .... Theme
#'   objects are also allowed (e.g., `theme_classic()`).
#' @param title character, title of the graph.
#' @param show.legend logical, if TRUE the legend is displayed.
#' @param legend.title a character string for the legend title. lower
#'   triangular, upper triangular or full matrix.
#' @param show.diag logical, whether display the correlation coefficients on the
#'   principal diagonal.
#' @param colors a vector of 3 colors for low, mid and high correlation values.
#' @param outline.color the outline color of square or circle. Default value is
#'   "gray".
#' @param hc.order logical value. If TRUE, correlation matrix will be hc.ordered
#'   using hclust function.
#' @param hc.method the agglomeration method to be used in hclust (see ?hclust).
#' @param lab logical value. If TRUE, add correlation coefficient on the plot.
#' @param lab_col,lab_size size and color to be used for the correlation
#'   coefficient labels. used when lab = TRUE.
#' @param p.mat matrix of p-value. If NULL, arguments sig.level, insig, pch,
#'   pch.col, pch.cex is invalid.
#' @param sig.level significant level, if the p-value in p-mat is bigger than
#'   sig.level, then the corresponding correlation coefficient is regarded as
#'   insignificant.
#' @param insig character, specialized insignificant correlation coefficients,
#'   "pch" (default), "blank". If "blank", wipe away the corresponding glyphs;
#'   if "pch", add characters (see pch for details) on corresponding glyphs.
#' @param pch add character on the glyphs of insignificant correlation
#'   coefficients (only valid when insig is "pch"). Default value is 4.
#' @param pch.col,pch.cex the color and the cex (size) of pch (only valid when
#'   insig is "pch").
#' @param tl.cex,tl.col,tl.srt the size, the color and the string rotation of
#'   text label (variable names).
#' @param digits Decides the number of decimal digits to be displayed (Default:
#'   `2`).
#' @return
#' \itemize{
#'  \item ggcorrplot(): Returns a ggplot2
#'  \item cor_pmat(): Returns a matrix containing the p-values of correlations
#'  }
#' @examples
#' # Compute a correlation matrix
#' data(mtcars)
#' corr <- round(cor(mtcars), 1)
#' corr
#'
#' # Compute a matrix of correlation p-values
#' p.mat <- cor_pmat(mtcars)
#' p.mat
#'
#' # Visualize the correlation matrix
#' # --------------------------------
#' # method = "square" or "circle"
#' ggcorrplot(corr)
#' ggcorrplot(corr, method = "circle")
#'
#' # Reordering the correlation matrix
#' # --------------------------------
#' # using hierarchical clustering
#' ggcorrplot(corr, hc.order = TRUE, outline.color = "white")
#'
#' # Types of correlogram layout
#' # --------------------------------
#' # Get the lower triangle
#' ggcorrplot(corr,
#'   hc.order = TRUE, type = "lower",
#'   outline.color = "white"
#' )
#' # Get the upeper triangle
#' ggcorrplot(corr,
#'   hc.order = TRUE, type = "upper",
#'   outline.color = "white"
#' )
#'
#' # Change colors and theme
#' # --------------------------------
#' # Argument colors
#' ggcorrplot(corr,
#'   hc.order = TRUE, type = "lower",
#'   outline.color = "white",
#'   ggtheme = ggplot2::theme_gray,
#'   colors = c("#6D9EC1", "white", "#E46726")
#' )
#'
#' # Add correlation coefficients
#' # --------------------------------
#' # argument lab = TRUE
#' ggcorrplot(corr,
#'   hc.order = TRUE, type = "lower",
#'   lab = TRUE,
#'   ggtheme = ggplot2::theme_dark(),
#' )
#'
#' # Add correlation significance level
#' # --------------------------------
#' # Argument p.mat
#' # Barring the no significant coefficient
#' ggcorrplot(corr,
#'   hc.order = TRUE,
#'   type = "lower", p.mat = p.mat
#' )
#' # Leave blank on no significant coefficient
#' ggcorrplot(corr,
#'   p.mat = p.mat, hc.order = TRUE,
#'   type = "lower", insig = "blank"
#' )
#'
#' # Changing number of digits for correlation coeffcient
#' # --------------------------------
#' ggcorrplot(cor(mtcars),
#'   type = "lower",
#'   insig = "blank",
#'   lab = TRUE,
#'   digits = 3
#' )
#' @name ggcorrplot
#' @rdname ggcorrplot
#' @export

# function body
ggcorrplot_FER <- function(corr,
                       coef_size = NULL,
                       method = c("square", "circle"),
                       type = c("full", "lower", "upper"),
                       ggtheme = ggplot2::theme_minimal,
                       title = "",
                       show.legend = TRUE,
                       legend.title = "Corr",
                       show.diag = FALSE,
                       colors = c("blue", "white", "red"),
                       outline.color = "gray",
                       hc.order = FALSE,
                       hc.method = "complete",
                       lab = FALSE,
                       lab_col = "black",
                       lab_size = 4,
                       p.mat = NULL,
                       sig.level = 0.05,
                       insig = c("pch", "blank"),
                       pch = 4,
                       pch.col = "black",
                       pch.cex = 5,
                       tl.cex = 12,
                       tl.col = "black",
                       tl.srt = 45,
                       digits = 2) {
  type <- match.arg(type)
  method <- match.arg(method)
  insig <- match.arg(insig)

  if(inherits(corr, "cor_mat")){
    # cor_mat object from rstatix
    cor.mat <- corr
    corr <- .tibble_to_matrix(cor.mat)
    p.mat <- .tibble_to_matrix(attr(cor.mat, "pvalue"))
  }

  if (!is.matrix(corr) & !is.data.frame(corr)) {
    stop("Need a matrix or data frame!")
  }
  corr <- as.matrix(corr)

  corr <- base::round(x = corr, digits = digits)

  if (hc.order) {
    ord <- .hc_cormat_order(corr)
    corr <- corr[ord, ord]
    if (!is.null(p.mat)) {
      p.mat <- p.mat[ord, ord]
      p.mat <- base::round(x = p.mat, digits = digits)
    }
  }

  # Get lower or upper triangle
  if (type == "lower") {
    corr <- .get_lower_tri(corr, show.diag)
    p.mat <- .get_lower_tri(p.mat, show.diag)
  }
  else if (type == "upper") {
    corr <- .get_upper_tri(corr, show.diag)
    p.mat <- .get_upper_tri(p.mat, show.diag)
  }

  # Melt corr and pmat
  corr <- reshape2::melt(corr, na.rm = TRUE)
  colnames(corr) <- c("Var1", "Var2", "value")
  corr$pvalue <- rep(NA, nrow(corr))
  corr$signif <- rep(NA, nrow(corr))

  if (!is.null(p.mat)) {
    p.mat <- reshape2::melt(p.mat, na.rm = TRUE)
    corr$coef <- corr$value
    corr$pvalue <- p.mat$value
    corr$signif <- as.numeric(p.mat$value <= sig.level)
    p.mat <- subset(p.mat, p.mat$value > sig.level)
    if (insig == "blank") {
      corr$value <- corr$value * corr$signif
    }
  }
  
    # heatmap
  p <-
    ggplot2::ggplot(
      data = corr,
      mapping = ggplot2::aes_string(x = "Var1", y = "Var2", fill = "value")
    )

  # modification based on method
  if (method == "square") {
    p <- p +
      ggplot2::geom_tile(color = outline.color)
  } else if (method == "circle") {
    # Melt corr and pmat
    coef_size <- reshape2::melt(coef_size, na.rm = TRUE)
    colnames(coef_size) <- c("Var1", "Var2", "value")
    corr$DE_Genes <- abs(coef_size$value)
    print(coef_size)
    print(corr)
    p <- ggplot2::ggplot(data = corr,
                         mapping = ggplot2::aes_string(x = "Var1", y = "Var2", fill = "value")) +
      ggplot2::geom_point(
        color = outline.color,
        shape = 21,
        ggplot2::aes_string(size = "DE_Genes")
      ) +
      ggplot2::scale_size(range = c(4, 10))
  }

  # adding colors
  p <-
    p + ggplot2::scale_fill_gradient2(
      low = colors[1],
      high = colors[3],
      mid = colors[2],
      midpoint = 0,
      limit = c(-1, 1),
      space = "Lab",
      name = legend.title
    )

  # depending on the class of the object, add the specified theme
  if (class(ggtheme)[[1]] == "function") {
    p <- p + ggtheme()
  } else if (class(ggtheme)[[1]] == "theme") {
    p <- p + ggtheme
  }


  p <- p +
    ggplot2::theme(
      axis.text.x = ggplot2::element_text(
        angle = tl.srt,
        vjust = 1,
        size = tl.cex,
        hjust = 1
      ),
      axis.text.y = ggplot2::element_text(size = tl.cex)
    ) +
    ggplot2::coord_fixed()

  label <- round(x = corr[, "value"], digits = digits)
  if(!is.null(p.mat) & insig == "blank"){
    ns <- corr$pvalue > sig.level
    if(sum(ns) > 0) label[ns] <- " "
  }

  # matrix cell labels
  if (lab) {
    p <- p +
      ggplot2::geom_text(
        mapping = ggplot2::aes_string(x = "Var1", y = "Var2"),
        label = label,
        color = lab_col,
        size = lab_size
      )
  }

  # matrix cell glyphs
  if (!is.null(p.mat) & insig == "pch") {
    p <- p + ggplot2::geom_point(
      data = p.mat,
      mapping = ggplot2::aes_string(x = "Var1", y = "Var2"),
      shape = pch,
      size = pch.cex,
      color = pch.col
    )
  }

  # add titles
  if (title != "") {
    p <- p +
      ggplot2::ggtitle(title)
  }

  # removing legend
  if (!show.legend) {
    p <- p +
      ggplot2::theme(legend.position = "none")
  }

  # removing panel
  p <- p +
    .no_panel()
  p
}



#' Compute the matrix of correlation p-values
#'
#' @param x numeric matrix or data frame
#' @param ... other arguments to be passed to the function cor.test.
#' @rdname ggcorrplot
#' @export

cor_pmat <- function(x, ...) {

  # initializing values
  mat <- as.matrix(x)
  n <- ncol(mat)
  p.mat <- matrix(NA, n, n)
  diag(p.mat) <- 0

  # creating the p-value matrix
  for (i in 1:(n - 1)) {
    for (j in (i + 1):n) {
      tmp <- stats::cor.test(mat[, i], mat[, j], ...)
      p.mat[i, j] <- p.mat[j, i] <- tmp$p.value
    }
  }

  # name rows and columns of the p-value matrix
  colnames(p.mat) <- rownames(p.mat) <- colnames(mat)

  # return the final matrix
  p.mat
}



#+++++++++++++++++++++++
# Helper Functions
#+++++++++++++++++++++++

# Get lower triangle of the correlation matrix
.get_lower_tri <- function(cormat, show.diag = FALSE) {
  if (is.null(cormat)) {
    return(cormat)
  }
  cormat[upper.tri(cormat)] <- NA
  if (!show.diag) {
    diag(cormat) <- NA
  }
  return(cormat)
}

# Get upper triangle of the correlation matrix
.get_upper_tri <- function(cormat, show.diag = FALSE) {
  if (is.null(cormat)) {
    return(cormat)
  }
  cormat[lower.tri(cormat)] <- NA
  if (!show.diag) {
    diag(cormat) <- NA
  }
  return(cormat)
}

# hc.order correlation matrix
.hc_cormat_order <- function(cormat, hc.method = "complete") {
  dd <- stats::as.dist((1 - cormat) / 2)
  hc <- stats::hclust(dd, method = hc.method)
  hc$order
}

.no_panel <- function() {
  ggplot2::theme(
    axis.title.x = ggplot2::element_blank(),
    axis.title.y = ggplot2::element_blank()
  )
}


# Convert a tbl to matrix
.tibble_to_matrix <- function(x){
  x <-  as.data.frame(x)
  rownames(x) <- x[, 1]
  x <- x[, -1]
  as.matrix(x)
}

