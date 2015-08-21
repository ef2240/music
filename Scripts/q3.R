# Find distribution of genre listens by age/gender
setkey(listens, "artist_seed")
listen.details <- listens[artists]
setkey(listen.details, "profile_id")
listen.details <- users[listen.details]
listen.counts <- listen.details[!is.na(gender) & !is.na(age) & !is.na(genre), list(listens=sum(tracks_listened_to)), by=list(gender, age, genre)]

# Remove users 60 or older (out of sample size concerns)
listen.counts <- listen.counts[age <= 60]

# Focus on top 10 genres
genre.counts <- listen.counts[, list(total=sum(listens)), by=genre]
top10.genres <- genre.counts[order(total, decreasing=T)][1:10, genre]
listen.counts.top10 <- listen.counts[genre %in% top10.genres]

# Create stacked area charts
createStackedAreaChart <- function(male){
  chart <- ggplot(listen.counts.top10[gender == ifelse(male, "MALE", "FEMALE")][order(genre, decreasing=T)], aes(x=age, y=listens))
  chart + geom_area(aes(fill=genre), position="fill") + theme(panel.grid=element_blank(), panel.background=element_blank(), axis.text.y=element_blank(), axis.title.y=element_blank(), axis.ticks.y=element_blank(), axis.text.x=element_text(size=14, colour="black"), axis.ticks.x=element_line(colour="black")) + ggtitle(sprintf("%s Music Interests by Age", ifelse(male, "Male", "Female"))) + scale_y_continuous(expand=c(0, 0))
}
createStackedAreaChart(male=T)
