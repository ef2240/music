# Count number of users
print(users[, .N])

# Count number of active users
print(listens[, length(unique(profile_id))])
