#' Create animation
#' 
#' Create a gif or mpeg animation from a tmap plot. The free tool ImageMagick is required.
#'
#' @param tm tmap object. In order to create a series of tmap plots, which will be the frames of the animation, it is important to set nrow and ncol in \code{\link{tm_facets}}, for otherwise a small multiples plot is generated. Commonly, where one map is shown at a time, both nrow and ncol are set to 1.
#' @param filename filename of the video (should be a .gif or .mpg file)
#' @param width width of the animation file (in pixels)
#' @param height height of the animation file (in pixels)
#' @param delay delay time between images (in 1/100th of a second)
#' @note Not only tmap plots are supported, but any series of R plots.
#' @keywords animation
#' @examples
#' \dontrun{
#' data(Europe)
#' 
#' (tm_shape(Europe) + 
#'   tm_fill("yellow") + 
#'   tm_borders() + 
#'   tm_facets(by = "name", nrow=1,ncol=1) + 
#'   tm_layout(scale=2)) %>%
#' animation_tmap(filename="European countries.gif", width=1200, height=800, delay=100)
#' 
#' data(World)
#' data(metro)
#' (tm_shape(World) +
#'   tm_polygons() +
#' tm_shape(metro) + 
#'   tm_bubbles(paste0("pop", seq(1970, 2030, by=10)), border.col = "black", border.alpha = .5) +
#' tm_facets(free.scales.bubble.size = FALSE, nrow=1,ncol=1) + 
#' tm_layout_World(scale=2, outer.margins=0,asp=0)) %>%
#' animation_tmap(filename="World population.gif", width=1200, height=550, delay=100)
#' }
#' @export
animation_tmap <- function(tm, filename="animation.gif", width=1000, height=1000, delay=40) {
	
	# determine OS to pass on system vs. shell command
	if (.Platform$OS.type == "unix") {         
		syscall <- system
    	} else {
        	syscall <- shell
    	}
	checkIM <- shell("convert -version")
	if (checkIM!=0) stop("Could not find ImageMagick. Make sure it is installed and included in the systems PATH")
	
	# create plots
	d <- paste(tempdir(), "/tmap_plots", sep="/")
	dir.create(d)
	png(filename=paste(d, "plot%03d.png", sep="/"), width=width, height=height)
	print(tm)
	dev.off()

	# convert pngs to one gif using ImageMagick
	output <- syscall(paste("convert -delay ", delay, " ", d, "/*.png \"", filename, "\"", sep=""))
	
	# cleaning up plots and temporary variables
	unlink(d, recursive = TRUE)
	rm(syscall)
	
	invisible()	
}
