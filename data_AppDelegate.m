
#import "data_AppDelegate.h"
#import "EchoServer.h";
#import "ValueInfo.h";

static BOOL threadStarted = NO;

@implementation data_AppDelegate

@synthesize table;
@synthesize text;

- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView {
  
  if (!threadStarted) {
    [NSThread detachNewThreadSelector:@selector(run) toTarget:self withObject:nil];
    threadStarted = YES;    
  }
  
  return [[EchoServer getDict] count];
  //return 1000;
}

- (void)run {
  while (TRUE) {
    [table reloadData];
    sleep(1);
  }
}

//- (void)tableViewSelectionIsChanging:(NSNotification *)aNotification {
- (BOOL)tableView:(NSTableView *)aTableView shouldSelectRow:(int)rowIndex {
  NSArray *keys = [[EchoServer getDict] allKeys];
  
  NSArray *sortedArray = [keys sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
  NSString *key = [sortedArray objectAtIndex:rowIndex];
  ValueInfo *vi = [[EchoServer getDict] objectForKey:key];

//  NSString *str = [[NSString alloc] initWithData:vi.data encoding:NSASCIIStringEncoding];
  [text setStringValue:[vi.data description]];
  
  [table selectRow:rowIndex byExtendingSelection:false];
  return true;
}

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex {
  NSString *col = [[aTableColumn headerCell] stringValue];
  
  NSArray *keys = [[EchoServer getDict] allKeys];
  
  NSArray *sortedArray = [keys sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
  NSString *key = [sortedArray objectAtIndex:rowIndex];
  ValueInfo *vi = [[EchoServer getDict] objectForKey:key];

  if ([col isEqualToString:@"key"])
    return key;
  if ([col isEqualToString:@"inserted ago"])
    return [ NSString stringWithFormat: @"%d", lround([[NSDate date] timeIntervalSince1970] - vi.insertedAt)];
  if ([col isEqualToString:@"expires in"]) {
    if (vi.expiry == 0)
      return @"never";
    int left = vi.expiry - lround([[NSDate date] timeIntervalSince1970] - vi.insertedAt);
    if (left < 1) {
      [[EchoServer getDict] removeObjectForKey:key];
      return @"---";
    }
      
    return [ NSString stringWithFormat: @"%d", left ];
  }
  if ([col isEqualToString:@"key size"])
    return [ NSString stringWithFormat: @"%d", [key length]];
  if ([col isEqualToString:@"hits"])
    return [ NSString stringWithFormat: @"%d", vi.hits];
  if ([col isEqualToString:@"value size"])
    return [ NSString stringWithFormat: @"%d", [vi.data length]];
  
  return @"";
}

- (void) dealloc {
  [table release];
  [super dealloc];
}


@end