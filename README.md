# firebase recipe
Rakam's Firebase recipe is pre-defined data models that you can adopt and use when you're analyzing Firebase data on Rakam.
Here you'll find detailed definitions and examples about these data models, metrics, measures and dimensions:

Active user= “Users who have logged a user_engagement event 24h after their user_first_touch event’’
“All users’” isn’t always equal to “new users” + “active users”
Example: A user has logged user_first_touch event at 21:00 on May 5.
Until 21:00 on May 6, his all events will be counted as New user.
After 21:01 on May 6, his all events will be counted as Active User
As a result, He will be counted as both active and new user on May 6 and All user < “new users” + “active users”
