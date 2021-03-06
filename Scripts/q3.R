# # Install packages
# install.packages("ggplot2")
# install.packages("gridExtra")
# install.packages("RColorBrewer")
# install.packages("extrafont")

# Load package
library(ggplot2)
library(gridExtra)
library(RColorBrewer)
library(extrafont)

# Find distribution of genre listens by age + gender
setkey(listens, "artist_seed")
listen.details <- listens[artists]
setkey(listen.details, "profile_id")
listen.details <- users[listen.details]
listen.counts <- listen.details[!is.na(gender) & !is.na(age) & !is.na(genre), list(listens=sum(tracks_listened_to)), by=list(gender, age, genre)]

# Remove users older than 62 (out of sample size concerns)
listen.counts <- listen.counts[age <= 62]

# Roll up long tail of genres into "Other"
genre.counts <- listen.counts[, list(total=sum(listens)), by=genre]
top.genres <- genre.counts[order(total, decreasing=T)][1:5, genre]
levels(listen.counts$genre) <- c(levels(listen.counts$genre), "Other")
listen.counts$genre[!listen.counts$genre %in% top.genres] <- "Other"
listen.counts.rollup <- listen.counts[, list(listens=sum(listens)), by=list(genre, gender, age)]

# Calculate moving averages to create smoother, more stable visualization
calculateMovingAverage <- function(vec, window){
  filter(vec, rep(1/window, window), sides=2)
}
listen.counts.rollup <- listen.counts.rollup[order(age)]
listen.counts.moving <- listen.counts.rollup[, list(age, listens=calculateMovingAverage(listens, window=5)), by=list(genre, gender)][!is.na(listens)]

# Function to create stacked area charts
createStackedAreaChart <- function(male, data=listen.counts.moving){
  filtered <- data[gender == ifelse(male, "MALE", "FEMALE")][order(genre, decreasing=T)]
  text.points <- filtered[age == 40, list(genre, age, heights=(cumsum(listens) - .5 * as.numeric(listens)) / sum(listens))]
  chart <- ggplot(filtered, aes(x=age, y=listens))
  chart <- chart +
    geom_area(aes(fill=genre), position="fill") +
    scale_x_continuous(breaks=c(21, seq(30, 60, 10))) +
    scale_fill_manual(values=brewer.pal(6, "Set3")) +
    xlab("Age") +
    ggtitle(sprintf("%s Music Interests by Age", ifelse(male, "Male", "Female"))) +
    scale_y_continuous(expand=c(0, 0)) +
    theme(panel.grid=element_blank(),
          panel.background=element_blank(),
          axis.text.y=element_blank(),
          axis.title.y=element_blank(),
          axis.ticks.y=element_blank(),
          axis.text.x=element_text(size=14, colour="black"),
          axis.ticks.x=element_line(colour="black"),
          plot.title=element_text(face="bold", size=24, vjust=2),
          legend.position="none",
          text=element_text((family="Calibri"))) +
    geom_text(data=text.points, aes(x=age, y=heights, label=genre), fontface="bold", family="Calibri", size=7)
}

# Create and save male and female plots side by side
png("plot.png", width=1000, height=750)
male.plot <- createStackedAreaChart(male=T)
female.plot <- createStackedAreaChart(male=F)
grid.arrange(male.plot, female.plot, ncol=2)
dev.off()
