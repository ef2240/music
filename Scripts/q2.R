# Calculate average age of active vs inactive users
print(users[, list(average.age=mean(age, na.rm=T)), by=active])

# Run test for significance
print(t.test(age ~ active, data=users))
