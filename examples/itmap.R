data(World)
data(metro)
metro$growth <- (metro$pop2020 - metro$pop2010) / (metro$pop2010 * 10) * 100

require(dplyr)

(tm_shape(World) +
	tm_polygons("income_grp", palette="-Blues", contrast=.7, id="name", title="Income group") +
	tm_shape(metro) +
	tm_bubbles("pop2010", col = "growth", 
			   border.col = "black", border.alpha = .5, 
			   style="fixed", breaks=c(-Inf, seq(0, 6, by=2), Inf),
			   palette="-RdYlBu", contrast=1, 
			   title.size="Metro population", 
			   title.col="Growth rate (%)", id="name") + 
	tm_layout(legend.bg.color = "grey90", legend.bg.alpha=.5, legend.frame=TRUE, asp=0)) %>% 
itmap() -> itm


#try to fix zoom issue caused by scale -1 on y
itm$x$config$beforeZoom = htmlwidgets::JS("
function(oldz,newz){
	this.zooming = true;
	this.zoomchange = newz - oldz;
	return newz
}
")
itm$x$config$onZoom = htmlwidgets::JS("
function(newz){this.zooming = false; return newz}
")
itm$x$config$beforePan = htmlwidgets::JS("
function(oldp, newp){
  if(this.zooming){
	debugger;
	if((this.zoomchange > 0 && newp.y < oldp.y) ||
	   (this.zoomchange < 0 && newp.y > oldp.y)) 
	{
		//expect pan change to be same sign as zoom change
		newp.y = oldp.y - (newp.y - oldp.y)
	}
	//newp.y = newp.y + 25 * 
	//		 (this.zoomchange === Math.abs(this.zoomchange)? 1 : -1) *
	//		 Math.max(.75,Math.min(this.getZoom(),1.25));
  }
  return newp;
}
")
itm$x$config$onPan = htmlwidgets::JS("
function(newp){
  return newp;
}
")
itm
