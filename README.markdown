# DLData

## Overview

DLData provides an abstraction layer atop CoreData. Its aims are to provide a simplified interface to CoreData, while allowing, with little additional effort, several data models to be used simultaneously within a single project. In addition, it provides a mechanism for persistent unique ID generation within application space. Another compelling feature is data seeding — given a single seed URL containing a JSON file, the database can be populated with an initial dataset.

## Installation

### Preferred

The preferred mechanism of installation of this library is to use Xcode workspaces. The DLData project is built to be use via a workspace. Workspaces are a simple but powerful construct, with the main advantage being that all of the projects in the workspace build to the same shared location, meaning that header files, etc, are in well-known locations. Furthermore, if the same library is used by multiple dependent projects, that library can be included just once and used by each of the other projects without risk of linker errors, etc.

Installation Steps:

1. Create a new workspace, if you don't already have one (^-cmd-N)
2. Add your existing project to the workspace
3. Add the DLData *project* (DLData/DLData.xcodeproj) to the same workspace (note: do not add the top-level DLData workspace)
4. Add DLData to your app's project (this allows you to add DLData as dependency)
5. In your app's target, specify DLData as a target dependency
6. In your app's target, specify DLData as a linked library
7. Finally, you need to setup your header search paths to work within the workspace:
  * For Debug, add the following directories (in this order):
    * include/
    * $(BUILT_PRODUCTS_DIR)/usr/local/lib/include/
  * For Release:
    * $(TARGET_BUILD_DIR)/include/

If you are unfamiliar with the workspace concept, you might find it beneficial to start with an empty project and an empty workspace, and follow the steps above.

### Easy (though not as cool)

Copy all of the files in the "Classes" and "Data Models" groups into your project...

## Two Minute Example

Using DLData is straightforward. Here, we set up all of our underlying CoreData (NSPersistentStoreCoordinator, et al) structures for the data model "CorporateMayhem":

```apple
#import <DLData/DLData.h>

...

// This preps the entire system for usage
DLDataManager *manager = [[DLDataManager alloc] initWithModelName:@"CorporateMayhem"];
```

Seed it with our data source:

```apple
// Grab the seed file from the app bundle and seed the store
NSURL *seedURL = [[NSBundle mainBundle] URLForResource:@"Main.seed" withExtension:@"json"];
[manager seedDataStore:seedURL];
```

We can fetch requests defined within the model:

```apple
// Get the count of all well paid employees across all companies:
NSUInteger wellPaidEmployees = [manager countForRequestNamed:@"wellPaidEmployees"];

// Now, get the actual NSManagedObject instances
NSError *error=nil;
NSArray *employees = [manager executeFetchRequestNamed:@"wellPaidEmployees" error:&error];
```

We can also just fetch a single entity of a given type, complete with sorting and matching criteria:

```apple
NSError *error=nil;
NSString *companyName = @"Foo Inc.";
NSPredicate *p = [NSPredicate predicateWithFormat:@"companyName == %@", companyName];
Company *company = [manager fetchOne:@"Company" matching:p sortedBy:nil];
```

Also, we can get the NSFetchRequest itself, if you need to configure (limit the number of results, sort, etc...):

```apple
NSFetchRequest *request = [manager fetchRequestNamed:@"wellPaidEmployees"];
[request setFetchLimit:5];
// And then execute that request:
NSError *error=nil;
NSArray *fiveWellPaidEmployees = [manager executeFetchRequest:request error:&error];
```

Substitution variables are also supported:

```apple
NSDictionary *subs = [NSDictionary dictionaryWithObject:company forKey:@"company"];
NSArray *employees = [manager executeFetchRequestNamed:@"companyWellPaidEmployees" 
                                 substitutionVariables:subs 
                                                 error:&error];
```

Easily create entities of a given type:

```apple
Employee *employee = [manager entityWithName:@"Employee"];
employee.company = company;
```

Delete objects:

```apple
[manager deleteEntity:company];
```

Generate a unique numeric ID:

```apple
unsigned long uniqueID = [DLUniqueIDGenerator generateUniqueID];
NSNumber *uniqueNumber = [DLUniqueIDGenerator generateUniqueNumber];
```

And, there is also undo/redo support, commit, rollback, delegation, built-in lightweight migration, and much more.

## DLDataManager

Almost all interaction with DLData is via the DLDataManager. This class is also the class you should subclass if you need more fine grained control over the internals of fetch requests (e.g., sorting a specific NSFetchRequest that is used throughout your system). Here, have an example:

```apple
@interface CorporateStore : DLDataManager {
}

- (Company*)addCompanyNamed:(NSString*)companyName;
- (Employee*)addEmployeeNamed:(NSString*)employee 
                    toCompany:(Company*)company;
- (Company*)companyNamed:(NSString*)companyName;
- (Employee*)employeeNamed:(NSString*)employeeName 
                forCompany:(Company*)company;

@end
```

Internally, the CorporateStore sets the name of the data model, and wraps the fetch request calls with appropriate sorting/matching criteria.

## DLDataManagerDelegate

Should you choose, the DLDataManagerDelegate can be used to configure some key components in the data store lifecycle, such as lightweight migration.

```apple
@protocol DLDataManagerDelegate<NSObject>
@optional
- (BOOL)dataManagerSupportsUndo:(DLDataManager*)dataManager;
- (BOOL)dataManagerSupportsLightweightMigration:(DLDataManager*)dataManager;
- (void)dataManager:(DLDataManager*)dataManager
     createdObjects:(NSSet*)createdObjects
     updatedObjects:(NSSet*)updatedObjects
     deletedObjects:(NSSet*)deletedObjects;
@end
```

View the DLDataTests for various examples of things you can do with DLData.

## Data Seeding

One of the more compelling features of DLData is that you can seed your CoreData data store with a single line of code. To seed data, simply specify a main URL, or a set of URL:

```apple
// Grab the seed file from the app bundle and seed the store
NSURL *seedURL = [[NSBundle mainBundle] URLForResource:@"Main.seed" withExtension:@"json"];
[manager seedDataStore:seedURL];
```

Within each file, a mix of data and "seedlings" is specified. Seedlings are links to other seed files (which may be either local or remote). Eventually, this allows us to fill out our data hierarchies (i.e., relationships) wherever seed data should reside. Each seed file (that isn't a pass-through seed -- see below) specifies a type of data, and various instances of that type. Relationships can be specified within the same seed file, or can be split out into other seedlings. This propagates down each data hierarchy. Let us look at an example:

Main.seed.json

```json
{ "seedlings" : 
  [
    {"seedUrl" : "http://somevalidurl.com/CompanyA.seed.json"},
    {"seedFile" : "CompanyB.seed.json"}
  ]
}
```

CompanyB.seed.json

```json
{ "Company" :
  {
    "companyName" : "Foo Inc.",
    "companyID" : "<uniqueID>",
    "employees" : 
    {
      "seedlings" : 
      [
        {"seedFile" : "CompanyBEmployees.seed.json"}
      ]
    }
  }
}
```

CompanyBEmployees.seed.json

```json
{ "seedlings" : 
  [
    { "seedFile" : "CompanyBManagement.seed.json"},
    { "seedFile" : "CompanyBSlaves.seed.json"}
  ]
}
```

CompanyBManagement.seed.json

```json
{ "Employee" : 
  {
    "employeeName" : "Greg Gerg",
    "employeeSalary" : 100000000,
    "employeeID" : "<uniqueID>"
  }
}
```

CompanyBSlaves.seed.json

```json
{ "Employee" : 
  [
    { 
      "employeeName" : "Poor Sapp",
      "employeeID" : "<uniqueID>",
      "employeeSalary" : 1
    },
    {
      "employeeName" : "Ms. Melody Treated",
      "employeeID" : "<uniqueID>",
      "employeeSalary" : 2
    },
    { "employeeName" : "Dr. Knowledge J. Destitute",
      "employeeID" : "<uniqueID>",
      "employeeSalary" : 3
    },
    { "employeeName" : "Andrew Hannon",
      "employeeID" : "<uniqueID>",
      "employeeSalary" : 0
    }
  ]
}
```

CompanyA.seed.json is similar, though it lives on some server instead of within the application bundle.

### Explanation

The top file, main.seed.json, specifies seed files for two companies. It is effectively a pass-through seed file -- it doesn't explicitly define any instances, but rather the location of files that specify instances (which themselves might be pass-through seeds).

CompanyB.seed.json specifies the companyName and a unique ID (generated by using the <uniqueID> tag). Instead of listing every employee of the company, that relationship is specified using embedded seedlings.

This brings us to CompanyBEmployees.seed.json, which is a pass-through seed file to two separate seed files, one specifying management, the other specifying other employees, here colorfully referred to as "slaves."

CompanyBManagement.seed.json and CompanyBSlaves.seed.json list instances of the entity class Employee with their names, salaries and uniquely generated employeeIDs. This fills out the hierarchy for this data model. 

### Future Work

In the future, it might be useful to be able to reference the same object (such as a Department instance) throughout the seeding infrastructure. For example, if two employees belong to the same department, list that department for both employees and resolve that it is, in fact, the same object. Currently, this approach would result in duplicates of the Department instance, but in the future, some mechanism (such as introspection) could be used to rectify duplicates. However, seeing as how this contrived example could be specified in such a way that duplicates would not be an issue (by specifying the hierarchy like so: Main -> Companies -> Departments -> Employees/Managers), no effort has been made in this area.

## Other Cool Things

Want to use the same data model — perhaps "CorporateMayhem.xcdatamodel" — as the basis of two distinct data managers? No problem!

```apple
DLDataManager *managerA = [[DLDataManager alloc] initWithDataStoreModelName:@"CorporateMayhem" 
                                                              andStoreAlias:@"ManagerA"];
DLDataManager *managerB = [[DLDataManager alloc] initWithDataStoreModelName:@"CorporateMayhem" 
                                                              andStoreAlias:@"ManagerB"];
```

Now that single data model will create two distinct underlying data stores (e.g., two sqlite databases) based on the same model. Pretty nifty, eh?
