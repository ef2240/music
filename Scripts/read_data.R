# Install and load data.table package
# install.packages("data.table")
library(data.table)

# Read input files
users <- read.delim("Input_data/users.tsv")
artists <- read.delim("Input_data/artists.tsv")
listens <- read.delim("Input_data/listens.tsv")

# Cast to data table
users <- data.table(users, key="profile_id")
artists <- data.table(artists, key="artist_id")
listens <- data.table(listens)
