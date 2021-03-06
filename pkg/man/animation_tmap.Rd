% Generated by roxygen2 (4.1.1): do not edit by hand
% Please edit documentation in R/animation_tmap.R
\name{animation_tmap}
\alias{animation_tmap}
\title{Create animation}
\usage{
animation_tmap(tm, filename = "animation.gif", width = 1000,
  height = 1000, delay = 40)
}
\arguments{
\item{tm}{tmap object. In order to create a series of tmap plots, which will be the frames of the animation, it is important to set nrow and ncol in \code{\link{tm_facets}}, for otherwise a small multiples plot is generated. Commonly, where one map is shown at a time, both nrow and ncol are set to 1.}

\item{filename}{filename of the video (should be a .gif or .mpg file)}

\item{width}{width of the animation file (in pixels)}

\item{height}{height of the animation file (in pixels)}

\item{delay}{delay time between images (in 1/100th of a second)}
}
\description{
Create a gif or mpeg animation from a tmap plot. The free tool ImageMagick is required.
}
\note{
Not only tmap plots are supported, but any series of R plots.
}
\examples{
\dontrun{
data(Europe)

(tm_shape(Europe) +
  tm_fill("yellow") +
  tm_borders() +
  tm_facets(by = "name", nrow=1,ncol=1) +
  tm_layout(scale=2)) \%>\%
animation_tmap(filename="European countries.gif", width=1200, height=800, delay=100)

data(World)
data(metro)
(tm_shape(World) +
  tm_polygons() +
tm_shape(metro) +
  tm_bubbles(paste0("pop", seq(1970, 2030, by=10)), border.col = "black", border.alpha = .5) +
tm_facets(free.scales.bubble.size = FALSE, nrow=1,ncol=1) +
tm_layout_World(scale=2, outer.margins=0,asp=0)) \%>\%
animation_tmap(filename="World population.gif", width=1200, height=550, delay=100)
}
}
\keyword{animation}

