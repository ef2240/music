# Count number of users
print(users[, .N])

# Create dataset of active users and find length
active.users <- users[users$profile_id %in% listens$profile_id]
print(active.users[, .N])
