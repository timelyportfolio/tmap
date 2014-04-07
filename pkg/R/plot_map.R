

plot_map <- function(gp, gt) {
	draw.frame <- gt$draw.frame
	frame.lwd <- gt$frame.lwd
	
	nlayers <- length(gp)
	
	## add shape objects to layers
	#gp <- lapply(gp, function(g) {g$shp <- get(g$shp); g})
	
	## set bounding box and frame
	gp <- set_bounding_box(gp, gt)
	
	## plot shapes
	add <- c(FALSE, rep(TRUE, length(gp)-1))	
	for (l in 1:nlayers) {
		gpl <- gp[[l]]
		plot(gpl$shp, col=gpl$fill, bg=gt$bg.color, border = gpl$col, lwd=gpl$lwd, lty=gpl$lty, add=add[l], xpd=NA)
	}
	
	## set grid viewport (second line needed for small multiples)
	vps <- baseViewports()
	vps$figure[c("x", "y", "width", "height")] <- vps$plot[c("x", "y", "width", "height")]
	pushViewport(vps$inner, vps$figure, vps$plot)

	bb <- gp[[1]]$shp@bbox
 	ys <- convertY(unit(bb[2,], "native"), "npc", valueOnly=TRUE)
 	xs <- convertX(unit(bb[1,], "native"), "npc", valueOnly=TRUE)
	
	npc.w <- xs[2] - xs[1]
	npc.h <- ys[2] - ys[1]

	npc <- max(npc.w, npc.h)

	aspVpNpc <- npc.w / npc.h
	
	
 	ys.inch <- convertY(unit(bb[2,], "native"), "inch", valueOnly=TRUE)
 	xs.inch <- convertX(unit(bb[1,], "native"), "inch", valueOnly=TRUE)

	vpWidth <- xs.inch[2] - xs.inch[1]
 	vpHeight <- ys.inch[2] - ys.inch[1]

	aspVpInch <- vpWidth / vpHeight
	
 	#browser()
# 	## correct npc's such that the aspect ratio will be preserved
# 	if (npc==npc.w) {
# 		npc.h <- npc.w / aspVpInch
# 	} else {
# 		npc.w <- npc.h * aspVpInch
# 	}

	if (aspVpNpc > aspVpInch) {
		# portrait map on landscape device
		npc.h <- npc.w / aspVpInch
	} else {
		# landscape map on portrait device
		npc.w <- npc.h * aspVpInch
	}

	pushViewport(viewport(layout=grid.layout(nrow=3, ncol=3,
				widths=unit(c(1,npc.w, 1), c("null", "snpc", "null")),
				heights=unit(c(1,npc.h, 1), c("null", "snpc", "null")))))

	bg.col <- ifelse(draw.frame, "white", gt$bg.color)
		
	cellplot(1:3, 1, e=grid.rect(gp=gpar(col=bg.col, fill=bg.col)))
	cellplot(1:3, 3, e=grid.rect(gp=gpar(col=bg.col, fill=bg.col)))
	cellplot(1, 2, e=grid.rect(gp=gpar(col=bg.col, fill=bg.col)))
	cellplot(3, 2, e=grid.rect(gp=gpar(col=bg.col, fill=bg.col)))

	vp <- viewport(layout.pos.col=2, layout.pos.row=2)
	pushViewport(vp)

	if (draw.frame) grid.rect(gp=gpar(fill=NA, lwd=frame.lwd))
	vpArea <- vpWidth * vpHeight
	scaleFactor <- (sqrt(vpArea) / 100)
	for (l in 1:nlayers) {
		
		gpl <- gp[[l]]
		shp <- gpl$shp
		
		#npol <- length(shp)
		
		co <- coordinates(shp)
		
		bb <- shp@bbox
		
		co.npc <- co
		co.npc[,1] <- (co.npc[,1]-bb[1,1]) / (bb[1, 2]-bb[1,1])
		co.npc[,2] <- (co.npc[,2]-bb[2,1]) / (bb[2, 2]-bb[2,1])

		if (!is.na(gpl$bubble.size[1])) {

			plot_bubbles(co.npc, gpl$bubble.size, gpl$bubble.col, gpl$bubble.border, scaleFactor)
		}
		if (!is.na(gpl$text)) {
			
			cex <- gpl$text.cex
			if (is.character(cex)) {
				if (substr(cex, 1, 4)=="AREA") {
					nc <- nchar(cex)
					p <- if (nc>4) as.numeric(substr(cex, 5, nc)) else 2
					cex <- approx_areas(shp, units="norm")^(1/p)
				} else {
					cex <- shp[[gpl$text.cex]]
					cex <- cex / max(cex)
				}
			} else cex <- rep(cex, lenght.out=length(shp))
			
			plot_text(co.npc, shp[[gpl$text]], cex, gpl$text.cex.lowerbound, gpl$text.bg.color, gpl$text.bg.alpha, gpl$text.scale, gpl$text.print.tiny, gpl$text.fontface, gpl$text.fontfamily)
			
		}
	
	}
	upViewport(5)
	list(scaleFactor=scaleFactor, vp=vp)
}


plot_bubbles <- function(co.npc, sizes, bubble.col, bubble.border, scaleFactor) {
	npol <- nrow(co.npc)
	if (length(sizes)!=npol) {
		if (length(sizes)!=1) warning("less bubble size values than objects")
		sizes <- rep(sizes, length.out=npol)
	}
	
	sizes <- sizes * scaleFactor
	
	cols <- rep(bubble.col, length.out=npol)
	borders <- bubble.border
	
	if (length(sizes)!=1) {
		decreasing <- order(-sizes)
		co.npc2 <- co.npc[decreasing,]
		sizes2 <- sizes[decreasing]
		cols2 <- if (length(cols)==1) cols else cols[decreasing]
	} else {
		co.npc2 <- co.npc
		sizes2 <- sizes
		col2 <- cols
	}
	grid.circle(x=unit(co.npc2[,1], "npc"), y=unit(co.npc2[,2], "npc"),
				r=unit(sizes2, "inches"),
				gp=gpar(col=borders, fill=cols2))
}

plot_text <- function(co.npc, labels, cex, text.cex.lowerbound, text.bg.color, text.bg.alpha, text.scale, text.print.tiny, text.fontface, text.fontfamily) {
	
	text_sel <- (cex >= text.cex.lowerbound)
	
	if (text.print.tiny) {
		cex[!text_sel] <- text.cex.lowerbound
		text_sel <- rep(TRUE, length.out=length(shp))
	}
	
	#cex[!text_sel] <- 0
	cex <- cex * text.scale
	
	bgcols <- col2rgb(text.bg.color)
	bgcols <- rgb(bgcols[1,], bgcols[2,], bgcols[3,], 
				  alpha=text.bg.alpha, maxColorValue=255)
	
	tG <- textGrob(labels[text_sel], x=unit(co.npc[text_sel,1], "npc"), y=unit(co.npc[text_sel,2], "npc"), gp=gpar(cex=cex[text_sel], fontface=text.fontface, fontfamily=text.fontfamily))
	nlines <- rep(1, length(labels))
	
	tGH <- mapply(labels[text_sel], cex[text_sel], nlines[text_sel], FUN=function(x,y,z){
		convertHeight(grobHeight(textGrob(x, gp=gpar(cex=y, fontface=text.fontface, fontfamily=text.fontfamily))),"npc", valueOnly=TRUE) * z/(z-0.25)}, USE.NAMES=FALSE)
	
	tGW <- mapply(labels[text_sel], cex[text_sel], FUN=function(x,y){
		convertWidth(grobWidth(textGrob(x, gp=gpar(cex=y, fontface=text.fontface, fontfamily=text.fontfamily))),"npc", valueOnly=TRUE)}, USE.NAMES=FALSE)
	
	tGX <- tG$x
	tGY <- tG$y
	bcktG <- rectGrob(x=tGX, y=tGY, width=tGW, height=tGH, gp=gpar(fill=bgcols, col=NA))
	grid.draw(bcktG)
	grid.draw(tG)
}


plot_all <- function(gp) {
	main_vp <- current.viewport()
	gt <- gp$geo_theme
	
	gp[c("geo_theme")] <- NULL
	
	margins <- gt$margins
	title.position <- gt$title.position
	
	gridLayoutMap <- viewport(layout=grid.layout(3, 3, 
								 heights=unit(c(margins[3], 1, margins[1]), 
								 			 c("npc", "null", "npc")), 
								 widths=unit(c(margins[2], 1, margins[4]), 
								 			c("npc", "null", "npc"))))
	opar <- par("mai", "xaxs", "yaxs")
	if (!gt$legend.only) {
		pushViewport(gridLayoutMap)
		cellplot(2, 2, e={
			par(new=TRUE, fig=gridFIG(), mai=c(0,0,0,0), xaxs="i", yaxs="i")
			result <- plot_map(gp, gt)
			scaleFactor <- result[[1]]
			vp <- result[[2]]
		})
		
		upViewport()
	}
	
	#find which layer is choropleth
	choroID <- which(sapply(gp, function(x)!is.na(x$varnames$choro.fill[1])))[1]
	bubbleSizeID <- which(sapply(gp, function(x)!is.na(x$varnames$bubble.size[1])))[1]
	bubbleColID <- which(sapply(gp, function(x)!is.na(x$varnames$bubble.col[1])))[1]
	
	# possible conflict between choro and bubble: for the time being, choose the first, or choose bubbles
	if (!is.na(choroID)) {
		isChoroLegend <- TRUE
	} else if (!is.na(bubbleSizeID) || !is.na(bubbleColID)) {
		isChoroLegend <- FALSE
	} else {
		isChoroLegend <- NA
	}
	if (gt$legend.in.frame) {
		seekViewport(vp$name)	
	} else {
		pushViewport(gridLayoutMap)
		pushViewport(viewport(layout.pos.row=2, layout.pos.col=2))
	}
	if (!is.na(isChoroLegend)) {
		if (isChoroLegend) {
			gc <- gp[[choroID]]
			if (gt$show.legend.text || gt$type.legend.plot!="none") {
				legendPlot(gt=gt, 
						   legend.palette=gc$choro.legend.palette, 
						   legend.labels=gc$choro.legend.labels, 
						   values=gc$choro.values, 
						   breaks=gc$choro.breaks, 
						   legend.bubbles=FALSE, 
						   legend.bubble.sizes=NULL, 
						   legend.bubble.labels=NULL, 
						   plot.bubble.borders=TRUE)
			}
		} else {
			gb <- gp[[bubbleSizeID]]
			gt$type.legend.plot <- ifelse(is.na(bubbleSizeID), "none", "bubble")
			legendPlot(gt=gt, 
					   legend.palette = if(is.na(bubbleColID)) gb$bubble.col else gb$bubble.legend.palette, 
					   legend.labels=gb$bubble.legend.labels, 
					   legend.bubbles=!is.na(bubbleSizeID), 
					   legend.bubble.sizes=gb$bubble.legend.sizes * scaleFactor, 
					   legend.bubble.labels=gb$bubble.legend.size_labels, 
					   plot.bubble.borders=TRUE)
		}
	}
	seekViewport(main_vp$name)
	do.call("par", opar)
}