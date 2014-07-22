#' Read shape file
#' 
#' This function reads an ESRI shape file.
#' 
#' This function is a convenient wrapper of readOGR of the package sp. It also fixes a common bug when reading shape files that are in the Dutch rijksdriehoekstelsel.
#'
#' @param file a shape file name (including directory).
#' @return shape object
#' @import rgdal
#' @import sp
#' @export
read_shape <- function(file){
	
	# determine region ID
	if (file.exists(file)) {
		fullfilename <- file
	} else stop("unknown filename")

	dir <- dirname(fullfilename)
	base <- basename(fullfilename)
	if (substr(base, nchar(base)-3, nchar(base))==".shp")
		base <- substr(base, 1, nchar(base)-4)
	
	shp <- readOGR(dir, base, verbose=FALSE)
	
	## rd projection correction: add towgs84 parameter
	if (proj4string(shp) %in% c("+proj=sterea +lat_0=52.15616055555555 +lon_0=5.38763888888889 +k=0.999908 +x_0=155000 +y_0=463000 +ellps=bessel +units=m +no_defs",
								"+proj=sterea +lat_0=52.15616055555555 +lon_0=5.38763888888889 +k=0.9999079 +x_0=155000 +y_0=463000 +ellps=bessel +units=m +no_defs",
								"+proj=sterea +lat_0=52.156161 +lon_0=5.387639 +k=0.999908 +x_0=155000 +y_0=463000 +ellps=bessel +units=m +no_defs")) {
		suppressWarnings(set_projection(shp, current.projection="rd", overwrite.current.projection=TRUE))
	} else {
		shp
	}
}

#' Write shape file
#' 
#' This function writes an ESRI shape file.
#' 
#' This function is a convenient wrapper of writeOGR of the package sp.
#'
#' @param shp a shape object.
#' @param file file name (including directory)
#' @import sp
#' @export
write_shape <- function(shp, file) {
	shpname <- deparse(substitute(shp))
	dir <- dirname(file)
	base <- basename(file)
	if (!file.exists(dir)) stop("unknown directory")

	if (substr(base, nchar(base)-3, nchar(base))==".shp")
		base <- substr(base, 1, nchar(base)-4)
	if (!inherits(shp, "Spatial")) stop("shpname is not a Spatial object")
	writeOGR(shp, dir, base, driver = "ESRI Shapefile", overwrite_layer=TRUE)
}