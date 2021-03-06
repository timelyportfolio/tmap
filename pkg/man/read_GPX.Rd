% Generated by roxygen2 (4.1.1): do not edit by hand
% Please edit documentation in R/read_GPX.R
\name{read_GPX}
\alias{read_GPX}
\title{Read GPX file}
\usage{
read_GPX(file, layers = c("waypoints", "tracks", "routes", "track_points",
  "route_points"))
}
\arguments{
\item{file}{a GPX filename (including directory)}

\item{layers}{vector of GPX layers. Possible options are \code{"waypoints"}, \code{"tracks"}, \code{"routes"}, \code{"track_points"}, \code{"route_points"}. By dedault, all those layers are read.}
}
\value{
for each defiend layer, a shape is returned (only if the layer has any features). If only one layer is defined, the corresponding shape is returned. If more than one layer is defined, a list of shape objects, one for each layer, is returned.
}
\description{
Read a GPX file. By default, it reads all possible GPX layers, and only returns shapes for layers that have any features.
}
\examples{
\dontrun{
# download Amstel Gold Race route
tmpdir <- tempdir()
tmpfile <- tempfile()
download.file("http://www.gpstracks.nl/routes-fiets/f-limburg-amstel-gold-race-2014.zip", 
			  tmpfile, mode="wb")
unzip(tmpfile, exdir=tmpdir)

# read GPX file
AGR <- read_GPX(file.path(tmpdir, "f-limburg-amstel-gold-race-2014.gpx"))

# read OSM of Zuid-Limburg
ZLim <- read_osm(bb(AGR$tracks, ext=1.05))

# change route part names
levels(AGR$tracks$name) <- paste(c("First", "Second", "Third", "Final"), "loop")

# some manual text positioning to prevent overlapping
xmod <- sapply(as.character(AGR$waypoints$name), switch,
               Geulhemmerberg=-2, Brakkenberg=2, Antoniusbank=1, 
               Daalhemerweg=1.5, Mheerelindje=-2, Wesch=1, 
               Walemerberg=2, Eyserweg=2, Groenenweg=2, 0)

tm_shape(ZLim) + 
  tm_raster(saturation=.75) +
tm_shape(AGR$tracks) +
	tm_lines(col = "name", lwd = 4, title.col="Amstel Gold Race") + 
tm_shape(AGR$waypoints) +
	tm_bubbles(size=.1, col="gold", border.col = "black") + 
tm_text("name", size = .75, xmod = xmod, ymod=.5, bg.color="white", bg.alpha=.25) +
tm_layout(legend.position=c("right", "top"), legend.frame=TRUE, legend.bg.color = "gold")
}
}

