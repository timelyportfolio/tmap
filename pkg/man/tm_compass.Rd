% Generated by roxygen2 (4.1.1): do not edit by hand
% Please edit documentation in R/tm_misc_elements.R
\name{tm_compass}
\alias{tm_compass}
\title{Map compass}
\usage{
tm_compass(north = 0, type = NA, fontsize = 0.8, size = NA,
  show.labels = 1, cardinal.directions = c("N", "E", "S", "W"),
  color.dark = "black", color.light = "white", position = NA)
}
\arguments{
\item{north}{north direction in degrees: 0 means up, 90 right, etc.}

\item{type}{compass type, one of: \code{"arrow"}, \code{"4star"}, \code{"8star"}, \code{"radar"}, \code{"rose"}. The default is controlled by \code{\link{tm_style}} (which uses \code{"arrow"} for the default style)}

\item{fontsize}{relative font size}

\item{size}{size of the compass in number of text lines. The default values depend on the \code{type}: for \code{"arrow"} it is 2, for \code{"4star"} and \code{"8star"} it is 4, and for \code{"radar"} and \code{"rose"} it is 6.}

\item{show.labels}{number that specifies which labels are shown: 0 means no labels, 1 (default) means only north, 2 means all four cardinal directions, and 3 means the four cardinal directions and the four intercardinal directions (e.g. north-east).}

\item{cardinal.directions}{labels that are used for the cardinal directions north, east, south, and west.}

\item{color.dark}{color of the dark parts of the compass, typically (and by default) black.}

\item{color.light}{color of the light parts of the compass, typically (and by default) white.}

\item{position}{position of the text. Vector of two values, specifing the x and y coordinates. Either this vector contains "left", "center" or "right" for the first value and "top", "center", or "bottom" for the second value, or this vector contains two numeric values between 0 and 1 that specifies the x and y value of the left bottom corner of the compass. The default value is controlled by the argument \code{"attr.position"} of \code{\link{tm_layout}}.}
}
\description{
Creates a map compass.
}
\examples{
data(NLD_muni)
qtm(NLD_muni, theme = "NLD") + tm_compass()
qtm(NLD_muni, theme = "NLD") + tm_compass(type="4star")
qtm(NLD_muni, theme = "NLD") + tm_compass(type="8star")
qtm(NLD_muni, theme = "NLD") + tm_compass(type="rose", position=c("left", "top"))
qtm(NLD_muni, theme = "NLD") + tm_compass(type="radar", position=c("left", "top"), show.labels = 3)
}

