//
// NIODataDragonContentProvider / LoLBookOfChampions
//
// Created by Jeff Roberts on 1/24/15.
// Copyright (c) 2015 Riot Games. All rights reserved.
//


#import "NIODataDragonContentProvider.h"
#import "NIODataDragonSqliteOpenHelper.h"
#import "NIOUriMatcher.h"
#import "DataDragonContract.h"
#import <Bolts/Bolts.h>

#define REALM_URI			1
#define	CHAMPION_URI		2

@interface NIODataDragonContentProvider ()
@property (strong, nonatomic) NIODataDragonSqliteOpenHelper *databaseHelper;
@property (strong, nonatomic) NIOUriMatcher *urlMatcher;
@property (assign, nonatomic) NSInteger databaseVersion;
@end

@implementation NIODataDragonContentProvider
-(instancetype)init {
	self = [super init];
	if ( self ) {
    }

	return self;
}

-(NSInteger)deleteWithURL:(NSURL *)url
			withSelection:(NSString *)selection
		withSelectionArgs:(NSArray *)selectionArgs
				withError:(NSError **)error {
	*error = [NSError errorWithDomain:@"content.provider.datadragon" code:27 userInfo:nil];
	return 0;
}

-(NSURL *)insertWithURL:(NSURL *)url
			 withValues:(NSDictionary *)values
			  withError:(NSError **)error {
	return nil;
}

-(void)onCreate {
	[super onCreate];

	self.databaseVersion = 1;
	self.databaseHelper = [[NIODataDragonSqliteOpenHelper alloc] initWithName:[DataDragonContract DB_NAME] withVersion:self.databaseVersion];
	self.urlMatcher = [[NIOUriMatcher alloc] initWith:NO_MATCH];
	[self.urlMatcher addURL:[Realm URI] withMatchCode:REALM_URI];
	[self.urlMatcher addURL:[Champion URI] withMatchCode:CHAMPION_URI];
}

-(FMResultSet *)queryWithURL:(NSURL *)uri
			  withProjection:(NSArray *)projection
			   withSelection:(NSString *)selection
		   withSelectionArgs:(NSArray *)selectionArgs
				 withGroupBy:(NSString *)groupBy
				  withHaving:(NSString *)having
					withSort:(NSString *)sort
				   withError:(NSError **)error {

	BFTask *promise;
	NSInteger matchedURI = [self.urlMatcher match:uri];
	switch (matchedURI) {
		case REALM_URI:
			promise = [self queryRealmWithProjection:projection
									   withSelection:selection
								   withSelectionArgs:selectionArgs
										 withGroupBy:groupBy
										  withHaving:having
											withSort:sort];
			break;

		default:
			promise = [BFTask taskWithError:[NSError errorWithDomain:@"content.provider.datadragon"
																code:99
															userInfo:nil]];
			DDLogError(@"Unmatched URI %@", [uri absoluteString]);
	}

	[promise waitUntilFinished];

	if ( promise.error ) {
		*error = promise.error;
		return nil;
	} else {
		return promise.result;
	}
}

-(BFTask *)queryRealmWithProjection:(NSArray *)projection
					  withSelection:(NSString *)selection
				  withSelectionArgs:(NSArray *)selectionArgs
						withGroupBy:(NSString *)groupBy
						 withHaving:(NSString *)having
						   withSort:(NSString *)sort {
	return nil;
}

-(NSInteger)updateWithURL:(NSURL *)url
			withSelection:(NSString *)selection
		withSelectionArgs:(NSArray *)selectionArgs
				withError:(NSError **)error {
	return 27;
}

@end