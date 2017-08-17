As always let's start with **famous quotes:**
"*Focus and Simplicity. Simple can be harder than complex: You have to work hard to get your thinking clean to make it simple. But it's worth it in the end because once you get there, you can move mountains.*" - **Steve Jobs**

Thank you to Paul Hudson for writing [Hacking with Swift](https://www.hackingwithswift.com/read). Infact all his books Rocks! :+1:

Thank you to Jacob Bart [core data tutorials](https://cocoacasts.com/category/core-data/) Rocks! :+1:

Made this small simple little app while learning Swift programming for iOS & Core data.
If you have searched the internet for core data related stuff you are sure to have landed on [COCOACASTS](https://cocoacasts.com/) web site. Jacob Bart has already made several tutorials on swift programming & 51 tutorials on core data itself. It's pretty overwhelming & that to for FREE. If we read & understand personally guess majority of the doubts on core data will get cleared for sure. Only thing  which we have to do is just practice it. That's what I am doing below.
App content & what it does.
1. The app already has all the tutorials details like title, author, category, url, date of published inside the jacob-data.plist.
2. The app will read all the tutorial data from "jacob-data.plist" & store it permanently.
3. We display the stored data using tableview. 
4. Now since I have understood a bit of NSFetchedResultsController have used it to display category wise tutorials & how many tutorials are there for each category is displayed beside category name.
5. Filter button & Update buttons are now implemented. When you click the filter button it will give you an list of all the category that you can select & it will show you only tutorials of that particular category on your screen.
6. Update button is again very simple. Created an update1.plist file which is used to update tutorials. New tutorials are added & old tutorials links or date are updated according to the data provided inside update1.plist file.
7. When you click the tutorials the app will take you to authors main web site. We display it using SFSafariViewController.
8. TODO Location Notification
9. TODO Cloudkit Push.

Cheers!
