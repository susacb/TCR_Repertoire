invsimpson <- ggplot() +
  #clonotype.data contains inverse simpson statistic calculations under invsimpson
  geom_bar(data=clonotype.data,aes(x=sample.type,y=invsimpson, fill=cd.type),stat="identity") +
  facet_grid(.~cd.type) +
  scale_y_log10("Diversity") +
  scale_x_discrete("") +
  scale_fill_brewer(palette = "Dark2") +
  theme(legend.position = "none")