//
//  ArchivePostsTableViewController.m
//  Zen Habits Reader
//
//  Created by Keegan on 9/24/15.
//  Copyright © 2015 Keegan. All rights reserved.
//

#import "ArchivePostsTableViewController.h"
#import "KGNUtilities.h"
#import "PersistenceManager.h"
#import "PostWebViewController.h"

@implementation ArchivePostsTableViewController {
  __weak Year *_currentYear;
}

- (void)viewDidLoad {
  [super viewDidLoad];

  NSError *error;

  if (![self.fetchedResultsController performFetch:&error]) {
    NSLog(@"Unresolved error %@, %@", error, error.userInfo);
    exit(-1);
  }

  self.title = self.currentYearString;

  [AnalyticsManager reportNavigationToScreen:@"Archive Posts"];
}

- (NSFetchedResultsController *)createFetchedResultsController {
  NSManagedObjectContext *context =
      [PersistenceManager sharedInstance].managedObjectContext;
  NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];

  NSEntityDescription *entity = [NSEntityDescription entityForName:@"PostHeader"
                                            inManagedObjectContext:context];
  fetchRequest.entity = entity;

  NSSortDescriptor *sort =
      [[NSSortDescriptor alloc] initWithKey:@"date" ascending:YES];
  fetchRequest.sortDescriptors = @[sort];

  fetchRequest.fetchBatchSize = 20;

  NSPredicate *predicate = [NSPredicate
      predicateWithFormat:@"(month.year.theYear = %@)", self.currentYearString];
  fetchRequest.predicate = predicate;

  NSFetchedResultsController *theFetchedResultsController =
      [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                          managedObjectContext:context
                                            sectionNameKeyPath:@"month"
                                                     cacheName:nil];
  self.fetchedResultsController = theFetchedResultsController;
  theFetchedResultsController.delegate =
      (id<NSFetchedResultsControllerDelegate>)
          self;

  return theFetchedResultsController;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return [self sectionsCountForTableView];
}

- (NSInteger)sectionsCountForTableView {
  _currentYear =
      [[PersistenceManager sharedInstance] getYear:self.currentYearString];
  return _currentYear.months.count;
}

- (nullable NSString *)tableView:(UITableView *)tableView
         titleForHeaderInSection:(NSInteger)section {
  return [KGNUtilities monthOfYearAsString:section];
}
@end
