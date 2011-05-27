# DLData

## Overview

DLData provides an abstraction layer atop CoreData. Its aims are to provide a simplified interface to CoreData, while allowing, with little additional effort, several data models to be used simultaneously within a single project. In addition, it provides a mechanism for persistent unique ID generation within application space. Another compelling feature is data seeding — given a single seed URL containing a JSON file, the database can be populated with an initial dataset.

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

And, there is also undo/redo support, commit, rollback, delegation, built-in lightweight migration, and much more. Stay tuned!