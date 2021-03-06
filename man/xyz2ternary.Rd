% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/drillers.R
\name{xyz2ternary}
\alias{xyz2ternary}
\title{Convert triaxial data to biaxial.}
\usage{
xyz2ternary(X, col.x = 1, are.percents = TRUE)
}
\arguments{
\item{X}{object to be projected}

\item{col.x}{numeric; the column to set as the 1-axis}

\item{are.percents}{logical; are the values in \code{X} percentages \eqn{[0,100]} ?}
}
\description{
Tri-axial data will be collapsed into a two-dimensional space, within
an isoceles triangle.
}
\details{
The projection goes as \deqn{
x'_{i} = x_{j} + x_{k}/2}
\deqn{
x'_{j} = \sqrt(3) x_{k} / 2
}
where \eqn{x} is the data in original axis system.  This assumes a normalization
where \eqn{\sum x = 1}
}
\author{
Andrew J. Barbour <andy.barbour@gmail.com>
}
\seealso{
\code{\link{sand_silt_clay}}, \code{\link{hydrogeo.p}}
}

