if (!require(ggplot2)) {
  install.packages("ggplot2", repos="http://cran.us.r-project.org")
}
library(ggplot2)
if (!require(data.table)) {
  install.packages("data.table", repos="http://cran.us.r-project.org")
}
library(data.table)
if (!require(plyr)) {
  install.packages("plyr", repos="http://cran.us.r-project.org")
}
library(plyr)


workingDir = '/Users/michaeltauberg/music_data/AlbumLength'

csvName = "songs_2000-2018_genre_album_numsongs.csv"
data_name = "2018"

setwd(workingDir)

dt = read.csv(csvName)
dt$num_songs_on_album = strtoi(dt$num_songs_on_album)
dt = dt[order(as.Date(dt$date, format="%m/%d/%y"), decreasing=TRUE),]
dt_albums = dt[!duplicated(dt[,c('artist','album')], fromLast=FALSE),] #fromlast to get highest value in "weeks_on_list" field

# remove singles and compilations from consideration
dt_albums = dt_albums[dt_albums$album_type == "album", ]




# get year from date
dt_albums$year = as.integer(format(as.Date(dt_albums$date, format="%m/%d/%Y"),"%y"))
dt_albums = dt_albums[dt_albums$year <= 19, ]
dt_albums$year = as.integer(strtoi(dt_albums$year) + 2000)
#dt_albums = dt_albums[dt_albums$year >= 2000, ]
dt_albums = dt_albums[!is.na(dt_albums$year),]
#dt_albums$year = factor(dt_albums$year)
dt_albums$month = as.integer(format(as.Date(dt_albums$date, format="%m/%d/%Y"),"%m"))
dt_albums$month = paste(dt_albums$year, dt_albums$month, sep="")
dt_albums$day = as.integer(format(as.Date(dt_albums$date, format="%m/%d/%Y"),"%d"))
dt_albums$full_date = paste(dt_albums$month, dt_albums$day, sep="")
#write.csv(dt_albums, "songs_2000_2018_albums_ordered.csv", row.names = FALSE)
dt_albums = dt_albums[!is.na(dt_albums$num_songs_on_album), ]

dt_albums = dt_albums[order(as.Date(dt_albums$date, format="%m/%d/%y"), decreasing=TRUE),]

write.csv(dt_albums, "dt_albums.csv", row.names = FALSE)
#############
# look for trends in all albums
#############

num_songs_stats = ddply(dt_albums, "year", summarise, 
                       mean=mean(strtoi(num_songs_on_album),na.rm=TRUE), median=median(strtoi(num_songs_on_album),na.rm=TRUE), min=min(strtoi(num_songs_on_album),na.rm=TRUE), max=max(strtoi(num_songs_on_album),na.rm=TRUE), sd=sd(strtoi(num_songs_on_album),na.rm=TRUE), nalbums=length(unique(album)))
p = ggplot(num_songs_stats, aes(x=year, y=mean)) + geom_point() + geom_smooth(method='lm', se = FALSE)
p = p + xlab("Year") + ylab("Num Songs per Album") 
p = p + ggtitle("Avg Number of Songs/Album per Year") + theme(plot.title = element_text(size=18))
p = p + theme(text = element_text(size=14), axis.text.x=element_text(angle=90, hjust=1))
p = p + ylim(10,17)
p = p + scale_x_discrete(limits = c(2000,2001,2002,2003,2004,2005,2006,2007,2008,2009,2010,2011,2012,2013,2014,2015,2016,2017,2018))
ggsave(filename = "./mean_songs_per_album_per_year.png", plot=p, width=7, height=5.5) 

num_songs_stats = ddply(dt_albums, "month", summarise, 
                        mean=mean(strtoi(num_songs_on_album),na.rm=TRUE), median=median(strtoi(num_songs_on_album),na.rm=TRUE), min=min(strtoi(num_songs_on_album),na.rm=TRUE), max=max(strtoi(num_songs_on_album),na.rm=TRUE), sd=sd(strtoi(num_songs_on_album),na.rm=TRUE))
num_songs_stats$month = seq(1:nrow(num_songs_stats))
p = ggplot(num_songs_stats, aes(x=month, y=mean)) + geom_point() + geom_smooth(method='lm', se = FALSE)
p = p + xlab("Month") + ylab("Num Songs per Album") 
p = p + ggtitle("Avg Number of Songs/Album per Month") + theme(plot.title = element_text(size=18))
p = p + theme(text = element_text(size=14), axis.text.x=element_text(angle=90, hjust=1))
p = p + ylim(10,17)
ggsave(filename = "./mean_songs_per_album_per_month.png", plot=p, width=7, height=5.5) 
fit = lm(num_songs_stats$mean ~ num_songs_stats$month)

#############
# now plot only rap albums
#############

rap_albums = dt_albums[dt_albums$broad_genre == "rap",]
rap_albums = rap_albums[!is.na(rap_albums$num_songs_on_album), ]

num_songs_stats = ddply(rap_albums, "year", summarise, 
                        mean=mean(strtoi(num_songs_on_album),na.rm=TRUE), median=median(strtoi(num_songs_on_album),na.rm=TRUE), min=min(strtoi(num_songs_on_album),na.rm=TRUE), max=max(strtoi(num_songs_on_album),na.rm=TRUE), sd=sd(strtoi(num_songs_on_album),na.rm=TRUE))
p = ggplot(num_songs_stats, aes(x=year, y=mean)) + geom_point() + geom_smooth(method = "lm", se = FALSE)
p = p + xlab("Year") + ylab("Num Songs per Rap Album") 
p = p + ggtitle("Avg Number of Rap Songs/Album per Year") + theme(plot.title = element_text(size=18))
p = p + theme(text = element_text(size=14), axis.text.x=element_text(angle=90, hjust=1))
p = p + ylim(10,17)
p = p + scale_x_discrete(limits = c(2000,2001,2002,2003,2004,2005,2006,2007,2008,2009,2010,2011,2012,2013,2014,2015,2016,2017,2018))
ggsave(filename = "./mean_rapsongs_per_album_per_year.png", plot=p, width=7, height=5.5) 
fit = lm(num_songs_stats$mean ~ num_songs_stats$year)

num_songs_stats = ddply(rap_albums, "month", summarise, 
                        mean=mean(strtoi(num_songs_on_album),na.rm=TRUE), median=median(strtoi(num_songs_on_album),na.rm=TRUE), min=min(strtoi(num_songs_on_album),na.rm=TRUE), max=max(strtoi(num_songs_on_album),na.rm=TRUE), sd=sd(strtoi(num_songs_on_album),na.rm=TRUE))
num_songs_stats$month = seq(1:nrow(num_songs_stats))
p = ggplot(num_songs_stats, aes(x=month, y=mean)) + geom_point() + geom_smooth(method='lm', se = FALSE)
p = p + xlab("Month") + ylab("Num Songs per Album") 
p = p + ggtitle("Avg Number of Rap Songs/Album per Month") + theme(plot.title = element_text(size=18))
p = p + theme(text = element_text(size=14), axis.text.x=element_text(angle=90, hjust=1))
p = p + ylim(5,25)
ggsave(filename = "./mean_rapsongs_per_album_per_month.png", plot=p, width=7, height=5.5) 
fit = lm(num_songs_stats$mean ~ num_songs_stats$month)




