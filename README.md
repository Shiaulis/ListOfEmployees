# List Of Employees

The small application that provides a list of employees from remote URLs and gives an ability to see the employees details.
**Disclamer:** All information in this data set are randomly generated.

### Prerequisites

iOS 11.4
Xcode 9.4.1
Swift 4.1

### Installing

Clone the repository

```
git clone https://github.com/Shiaulis/ListOfEmployees.git
```

Open **ListOfEmployees.xcodeproj** file.
Run the app on simulator or if you want to start it on your own device provide your team in project settings.

### Application architecture
Application works on MVP (Model-View-Presenter) design pattern.
There are several model classes which don’t know anything about UI. There are several view controllers that manage the views and provide an interaction between views and model. Views visualize information and provide an interaction with user.

The main model class is **Application Model** class. It initiates all model classes that are needed for app functionality:
* **RemoteDataFetcher**. This class provides connection to remote server by given set of URLs. This class works on URLSession API and provides all data, responses and errors received from the remote servers. On every remote request Application Model creates separate RemoteDataFetcher class instance. 
* **DataMapper** provides parsing of the received data and mapping to Employee structure. Also it provides contact identifier for each employee which it finds in the user’s contacts.
* **PersistentCacheStorage** saves the data if it is correct and can be parsed by DataMapper and also provides cached data when it is needed. Unlike first two classes it works on delegate pattern and notifies Application model about its states by delegate callbacks.
All data from model is passed to UI by **DataProvider** protocol.
All model classes work asynchronously on non-main queues to prevent any influence to UI.

The main UI class is **EmpoyeesListViewController**. It shows list of employees. Also it provides:
Pull to refresh action that gives an ability to get the newest data from servers.
Search that can filter employees list by given word.
Ability to open the employee card for more information.
Ability to open card from Contacts if it matches.

**EmployeeDetailsViewController** provides an access to all data received from employee card. Also it gives an ability to open card from Contacts if employee is found in Contacts list.

### Application Execution
- AppDelegate in self init creates the application model.
- In 'willFinishLaunchingWithOptions' appDelegate callback ApplicationModel creates all other needed model classes instances, asks Persistent storage to provide cached data if it exists.
- In 'didFinishLaunchingWithOptions' appDelegate callback we create the main application screen - EmoloyeesListViewController.
- After cached data is ready we parse it, match with contacts and store it to runtime 'employees' array. Also we post a notification 'employeesListDidChangeExternally' which is used to notify UI-related code about all data changes that weren't called from UI.
- As part of setup process we ask user to grant access to Contacts. After access is granted we read the data from cache again to re-parse it and find matches in contacts.
- After UI is created and before it can be shown, EmployeeListViewController initiates request remote data to update local employees list. When the data is received and parsed, completion handler at view controller will be called and UI will be updated.
- Using the same logic pull refresh action works.
- Tapping on contact card in EmployeesListViewController causes opening the contact card. If user changes it somehow we receive a system notification and data from cache will be re-parsed again to update contact cards buttons for employees.

### Things that also should be done:

* Add unit tests for every model class. They also should use more protocol to have an ability mock every other dependency.
* Add UI tests to check the controllers.
* Add more flexible error states handling (throwing more errors, reporting to the user about fault application states like inaccessible cache).
* Implement some unique identifier for each employee to prevent duplicates (contact with the same ID should be merged)
* When an error is received from remote server error message should be shown as some popover message instead of alert that prevents user interaction until OK button is tapped.

* The main list while search should present what exactly is found by the given word.
* Search bar colors should be more close to the application style (white field color with white placeholder)
* Status bar should adopt its color depending on which controller is shown (for main list and details view it should be white, for contact card - black)
* Implement using UITextView instead of UILabel in email value to detect email link and provide an ability for the user to click on it and compose a letter
* Contacts button in Details View should react on change in user contacts.
* Check app for accessibility features (color accommodation,  dynamic fonts etc.)
* Add logs to View Controllers.




## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details.
All images that are used in the app is provided by [FlatIcon](https://www.flaticon.com)
