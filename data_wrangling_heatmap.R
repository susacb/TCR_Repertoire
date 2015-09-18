#dataframe wrangling for json transformation and rcharts heatmap plotting
vbeta.heatmap.data <- filter(vbetas, initials == "TT", cd.type == "CD8")
vbeta.heatmap.data$samp.type <- factor(vbeta.heatmap.data$samp.type)
vbeta.heatmap.data <- select(vbeta.heatmap.data, samp.type, vbeta, clonality.logist)
vbeta.heatmap.matrix <- transform(vbeta.heatmap.data, samp.type = as.integer(samp.type), vbeta = as.factor(vbeta))
vbeta.heatmap.matrix <- transform(vbeta.heatmap.matrix, vbeta = as.integer(vbeta))
vbeta.heatmap.matrix <- data.matrix(vbeta.heatmap.matrix)
colnames(vbeta.heatmap.matrix) <- c("x","y","value")