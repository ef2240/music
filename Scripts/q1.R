# Count number of users
print(users[, .N])

# Add flag to users indicating whether they are active or not
users$active <- users$profile_id %in% listens$profile_id
print(users[active == TRUE, .N])
