# Find distribution of genre listens by age/gender
setkey(listens, "artist_seed")
listen.details <- listens[artists]
setkey(listen.details, "profile_id")
listen.details <- users[listen.details]
listen.counts <- listen.details[!is.na(gender) & !is.na(age) & !is.na(genre), list(listens=sum(tracks_listened_to)), by=list(gender, age, genre)]

# Remove users 60 or older (out of sample size concerns)
listen.counts <- listen.counts[age <= 60]

# Roll up long tail on genres into "Other"
genre.counts <- listen.counts[, list(total=sum(listens)), by=genre]
top.genres <- genre.counts[order(total, decreasing=T)][1:6, genre]
levels(listen.counts$genre) <- c(levels(listen.counts$genre), "Other")
listen.counts$genre[!listen.counts$genre %in% top.genres] <- "Other"
listen.counts.rollup <- listen.counts[, list(listens=sum(listens)), by=list(genre, gender, age)]

# Create stacked area charts
createStackedAreaChart <- function(male){
  chart <- ggplot(listen.counts.rollup[gender == ifelse(male, "MALE", "FEMALE")][order(genre, decreasing=T)], aes(x=age, y=listens))
  chart + geom_area(aes(fill=genre), position="fill") + theme(panel.grid=element_blank(), panel.background=element_blank(), axis.text.y=element_blank(), axis.title.y=element_blank(), axis.ticks.y=element_blank(), axis.text.x=element_text(size=14, colour="black"), axis.ticks.x=element_line(colour="black"), plot.title=element_text(size=16, vjust=2)) + ggtitle(sprintf("%s Music Interests by Age", ifelse(male, "Male", "Female"))) + scale_y_continuous(expand=c(0, 0))
}
createStackedAreaChart(male=T)
