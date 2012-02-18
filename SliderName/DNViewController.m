//
//  DNViewController.m
//  SliderPuzzle
//
//  Created by Nimesh on 2/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DNViewController.h"
#import "DNTileView.h"

@interface DNViewController (Private)
/**
    Called to zoom into/out of the reference view
 */
- (IBAction) zoomInOut:(id)sender;
/**
    Sets up the board
 */
- (void) setupBoardForImage:(NSString *) image;
/**
    Called when any of the tiles are tapped
 */
- (void) tileTapped:(UITapGestureRecognizer *) tapGesture;
/**
    Adds white border to every tile
 */
- (UIImage *) borderedTile:(UIImage *) image;
/**
    This method is used to determine if the tile the user is trying to move
    has a valid move or not
    If it does, then the tile is moved and the model is updated
*/
- (void) moveSelectedTile:(DNTileView *) tile;

/**
    Animates the tile to its proper x and y location
*/
- (void) animateTileToLocation:(DNTileView *) tile andDirection:(PossibleMoves) direction;

/**
    Checks to see if the game has ended (all the tiles are in their
    correct position
*/
- (BOOL) hasGameEnded;

@end

@implementation DNViewController

@synthesize startGame, boardView, referenceView, zoomIntoReferenceView, isBoardInitialized, tiles, tileModel;

#pragma mark - Memory Mangement
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

- (void) dealloc {
    self.tileModel.delegate = nil;
    [self.tileModel release], tileModel = nil;
    for (DNTileView* view in self.tiles) {
        [view release], view = nil;
    }
    [self.tiles release], tiles = nil;
    [self.zoomIntoReferenceView release], zoomIntoReferenceView = nil;
    [self.referenceView release], referenceView = nil;
    [self.boardView release], boardView = nil;
    [self.startGame release], startGame = nil;
    [super dealloc];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    // Initially the board is not initialized
    self.isBoardInitialized = NO;
    
    // Initially hide the board view until it is created
    self.boardView.alpha = 0.0;
    
    // The zoom in button is not enabled until the board is created
    [self.zoomIntoReferenceView setUserInteractionEnabled:NO];
    
    NSMutableArray* array = [[NSMutableArray alloc] initWithCapacity:15];
    self.tiles = array;
    [array release];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    
    self.startGame = nil;
    self.boardView = nil;
    self.referenceView = nil;
    self.zoomIntoReferenceView = nil;
    for (DNTileView* view in self.tiles) {
        view = nil;
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

#pragma mark - Auto Rotation

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return YES;
}

- (void) willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    
    if(UIInterfaceOrientationIsLandscape(toInterfaceOrientation)) {
        // Landscape
        
    } else {
        //Portrait
        
    }
}

#pragma mark - Interface Actions
- (IBAction) startTheGame:(id)sender {
#ifdef DEBUG
    NSLog(@"Start Game");
#endif
    
    if(!self.isBoardInitialized) {
        // Initialize the model of the board
        DNTileModel* model = [[DNTileModel alloc] init];
        self.tileModel = model;
        self.tileModel.delegate = self;
        [model release];
        
        [self.tileModel initializeTheBoard];
        self.isBoardInitialized = YES;
    } else {
        for(DNTileView* view in self.tiles) {
            [view removeFromSuperview];
        }
        
        [self.tiles removeAllObjects];
        [self.tiles release], tiles = nil;
        
        NSMutableArray* array = [[NSMutableArray alloc] initWithCapacity:15];
        self.tiles = array;
        [array release];
        
        [self.tileModel resetBoard];
    }
}

- (IBAction) zoomInOut:(id)sender {
#ifdef DEBUG
    NSLog(@"Zoom IN/OUT");
#endif
    if(self.referenceView.frame.size.width == 200) {
        // zoom in
        [UIView animateWithDuration:0.5
                         animations:^ {
                             self.referenceView.frame = CGRectMake(50, 369, 540, 540);
                             self.zoomIntoReferenceView.frame = CGRectMake(0, 0, 540, 540);
                         }];
    } else {
        // zoom out
        [UIView animateWithDuration:0.5
                         animations:^ {
                             self.referenceView.frame = CGRectMake(50, 709, 200, 200);
                             self.zoomIntoReferenceView.frame = CGRectMake(0, 0, 200, 200);
                         }];
    }
}

#pragma mark - DNTileModel Delegate
- (void) boardInitialized {
#ifdef DEBUG
    NSLog(@"Board Initialized");
#endif
    [self.tileModel createLegalRandomizedBoardWithNumberOfMoves:100];
}

- (void) randomizedBoardCreated {
#ifdef DEBUG
    NSLog(@"Board Randomized");
#endif
    [self setupBoardForImage:@"Globe"];
    
    [UIView animateWithDuration:1.0
                     animations:^ {
                         self.referenceView.frame = CGRectMake(50, 709, 200, 200);
                         self.boardView.alpha = 1.0;
                         [self.zoomIntoReferenceView setUserInteractionEnabled:YES];
                     }
                     completion:^(BOOL finished) {
                         [UIView animateWithDuration:0.5
                                          animations:^ {
                                              [self.startGame setTitle:@"Reset" forState:UIControlStateNormal];
                                          }];
                     }];
}

#pragma mark - Setup Board
- (void) setupBoardForImage:(NSString *)image {
    
    // Initialize the view of the board
    NSString* path = [[NSBundle mainBundle] pathForResource:image ofType:@"png"];
    UIImage* boardImage = [[UIImage alloc] initWithContentsOfFile:path];
    
    CGSize size = CGSizeMake(boardImage.size.width, boardImage.size.height);
    
    int tag = 0;
    for (int i = 0; i < 4; ++i) {
        for (int j = 0; j < 4; ++j) {
            
            CGRect tileRect = CGRectMake(i * size.width/4.0, (3 - j) * size.height/4.0, size.width/4.0, size.height/4.0);
#ifdef DEBUG
//            NSLog(@"Tile Rect = %.1f %.1f %.1f %.1f", tileRect.origin.x, tileRect.origin.y, tileRect.size.width, tileRect.size.height);
#endif
            UIGraphicsBeginImageContext(tileRect.size);
            CGContextRef context = UIGraphicsGetCurrentContext();
            CGContextScaleCTM(context, 1.0, -1.0);
            CGContextTranslateCTM(context, 0, -tileRect.size.height);
            CGContextTranslateCTM(context, -tileRect.origin.x, -tileRect.origin.y);
            CGContextDrawImage(context,CGRectMake(0.0, 0.0,size.width,  size.height), boardImage.CGImage);
            
            UIImage* image = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            
            DNTileView* tileIV = [[DNTileView alloc] initWithImage:[self borderedTile:image]];
            tileIV.frame = CGRectMake(0, 0, boardImage.size.width/4.0, boardImage.size.width/4.0);
            
            // The x and y position of the tile in the model
            int x, y;
            
            for (int a = 0; a < self.tileModel.board.count; ++a) {
                NSMutableArray* array = [self.tileModel.board objectAtIndex:a];
                for (int b = 0; b < [array count]; ++b) {
                    if([[array objectAtIndex:b] intValue] == tag) {
                        x = a;
                        y = b;
                        
                        break;
                    }
                }
            }
            
            UIView* tileView = [[UIView alloc] initWithFrame:CGRectMake(x * boardImage.size.width/4.0,
                                                                        y * boardImage.size.width/4.0, 
                                                                        boardImage.size.width/4.0, 
                                                                        boardImage.size.width/4.0)];
            
            tileIV.winConditionXPosition = i;
            tileIV.winConditionYPosition = j;
            
            // Since there are 4 columns (0 -3) in every previous row, we multiply 3
            // to the current row and add it to the column which is then added to the row
            // to obtain
            // 0 4 8  12
            // 1 5 9  13
            // 2 6 10 14
            // 3 7 11 15
            // as the win condition
            
            tileIV.currentXPosition = x;
            tileIV.currentYPosition = y;
            [self.tiles addObject:tileIV];
            [tileView addSubview:tileIV];
            [tileIV release];
            
            tileView.tag = tag;
            tag++;
            
            UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tileTapped:)];
            tap.numberOfTapsRequired = 1;
            [tileView addGestureRecognizer:tap];
            [tap release];
            
            [self.boardView addSubview:tileView];
        }
    }
    
    DNTileView* view = [self.tiles objectAtIndex:15];
    view.currentXPosition = -1;
    view.currentYPosition = -1;
    view.winConditionXPosition = -1;
    view.winConditionYPosition = -1;
    
    [[view superview] removeFromSuperview];
    
    [self.tiles replaceObjectAtIndex:15 withObject:view];
    
    [boardImage release];
}

#pragma mark - Adds border to a tile image
- (UIImage *) borderedTile:(UIImage *)image {
    CGImageRef bgimage = [image CGImage];
	float width = CGImageGetWidth(bgimage);
	float height = CGImageGetHeight(bgimage);
    
    // Create a temporary texture data buffer
	void *data = malloc(width * height * 4);
    
	// Draw image to buffer
	CGContextRef ctx = CGBitmapContextCreate(data,
                                             width,
                                             height,
                                             8,
                                             width * 4,
                                             CGImageGetColorSpace(image.CGImage),
                                             kCGImageAlphaPremultipliedLast);
	CGContextDrawImage(ctx, CGRectMake(0, 0, (CGFloat)width, (CGFloat)height), bgimage);
    
	//Set the stroke (pen) color
	CGContextSetStrokeColorWithColor(ctx, [UIColor whiteColor].CGColor);
    
	//Set the width of the pen mark
	CGFloat borderWidth = (float) width * 0.03;
	CGContextSetLineWidth(ctx, borderWidth);
    
	//Start at 0,0 and draw a square
	CGContextMoveToPoint(ctx, 0.0, 0.0);	
	CGContextAddLineToPoint(ctx, 0.0, height);
	CGContextAddLineToPoint(ctx, width, height);
	CGContextAddLineToPoint(ctx, width, 0.0);
	CGContextAddLineToPoint(ctx, 0.0, 0.0);
    
	//Draw it
	CGContextStrokePath(ctx);
    
    // write it to a new image
	CGImageRef cgimage = CGBitmapContextCreateImage(ctx);
	UIImage *newImage = [UIImage imageWithCGImage:cgimage];
	CFRelease(cgimage);
	CGContextRelease(ctx);
    
    free(data);
    
    // auto-released
	return newImage;
}

#pragma mark - Tap Gesture Recognizer
- (void) tileTapped:(UITapGestureRecognizer *)tapGesture {
    DNTileView* viewTapped = (DNTileView *)[self.tiles objectAtIndex:tapGesture.view.tag];
#ifdef DEBUG
//    NSLog(@"Win Condition position of the tile tapped is = %d %d", viewTapped.winConditionXPosition, viewTapped.winConditionYPosition);
//    NSLog(@"Current position of the tile tapped is = %d %d", viewTapped.currentXPosition, viewTapped.currentYPosition);
#endif
    
    [self moveSelectedTile:viewTapped];
}

#pragma mark - Move Tile
- (void) moveSelectedTile:(DNTileView *) tile {
    
    // Check if the tile can be moved UP, DOWN, RIGHT, LEFT
    // If it can, then the model is udpated in the call automatically
    // move the tile appropriately
    
    // Move tile UP
    if([self.tileModel canMoveTileWithXPos:tile.currentXPosition
                                      yPos:tile.currentYPosition
                              andDirection:UP]) {
        // Move the tile UP
        int index = [self.tiles indexOfObject:tile];
#ifdef DEBUG
//        NSLog(@"Can Move tile UP");
        NSLog(@"Old current position of tile = %d %d", ((DNTileView *)[self.tiles objectAtIndex:index]).currentXPosition, ((DNTileView *)[self.tiles objectAtIndex:index]).currentYPosition);
#endif
        
        // Update the tile (view)
        tile.currentYPosition -= 1;
        [self.tiles replaceObjectAtIndex:index withObject:tile];
        
#ifdef DEBUG
        NSLog(@"New Board after moving tile = %@", self.tileModel.board);
        NSLog(@"New current position of tile = %d %d", ((DNTileView *)[self.tiles objectAtIndex:index]).currentXPosition, ((DNTileView *)[self.tiles objectAtIndex:index]).currentYPosition);
#endif
        
        // Animate the tile to appropriate location
        [self animateTileToLocation:tile andDirection:UP];
        
    } else if([self.tileModel canMoveTileWithXPos:tile.currentXPosition
                                             yPos:tile.currentYPosition
                                     andDirection:RIGHT]) {
        // Move Tile RIGHT
        int index = [self.tiles indexOfObject:tile];
#ifdef DEBUG
//        NSLog(@"Can Move tile RIGHT");
        NSLog(@"Old current position of tile = %d %d", ((DNTileView *)[self.tiles objectAtIndex:index]).currentXPosition, ((DNTileView *)[self.tiles objectAtIndex:index]).currentYPosition);
#endif
        
        // Update the tile (view)
        tile.currentXPosition += 1;
        [self.tiles replaceObjectAtIndex:index withObject:tile];
        
#ifdef DEBUG
        NSLog(@"New Board after moving tile = %@", self.tileModel.board);
        NSLog(@"New current position of tile = %d %d", ((DNTileView *)[self.tiles objectAtIndex:index]).currentXPosition, ((DNTileView *)[self.tiles objectAtIndex:index]).currentYPosition);
#endif
        
        // Animate the tile to appropriate location
        [self animateTileToLocation:tile andDirection:RIGHT];
        
    } else if([self.tileModel canMoveTileWithXPos:tile.currentXPosition
                                             yPos:tile.currentYPosition
                                     andDirection:DOWN]) {
        // Move Tile DOWN
        int index = [self.tiles indexOfObject:tile];
#ifdef DEBUG
//        NSLog(@"Can Move tile DOWN");
        NSLog(@"Old current position of tile = %d %d", ((DNTileView *)[self.tiles objectAtIndex:index]).currentXPosition, ((DNTileView *)[self.tiles objectAtIndex:index]).currentYPosition);
#endif
        
        // Update the tile (view)
        tile.currentYPosition += 1;
        [self.tiles replaceObjectAtIndex:index withObject:tile];
        
#ifdef DEBUG
        NSLog(@"New Board after moving tile = %@", self.tileModel.board);
        NSLog(@"New current position of tile = %d %d", ((DNTileView *)[self.tiles objectAtIndex:index]).currentXPosition, ((DNTileView *)[self.tiles objectAtIndex:index]).currentYPosition);
#endif
        
        // Animate the tile to appropriate location
        [self animateTileToLocation:tile andDirection:DOWN];
        
    } else if([self.tileModel canMoveTileWithXPos:tile.currentXPosition
                                             yPos:tile.currentYPosition
                                     andDirection:LEFT]) {
        // Move Tile LEFT
        int index = [self.tiles indexOfObject:tile];
#ifdef DEBUG
//        NSLog(@"Can Move tile LEFT");
        NSLog(@"Old current position of tile = %d %d", ((DNTileView *)[self.tiles objectAtIndex:index]).currentXPosition, ((DNTileView *)[self.tiles objectAtIndex:index]).currentYPosition);
#endif
        
        // Update the tile (view)
        tile.currentXPosition -= 1;
        [self.tiles replaceObjectAtIndex:index withObject:tile];
        
#ifdef DEBUG
        NSLog(@"New Board after moving tile = %@", self.tileModel.board);
        NSLog(@"New current position of tile = %d %d", ((DNTileView *)[self.tiles objectAtIndex:index]).currentXPosition, ((DNTileView *)[self.tiles objectAtIndex:index]).currentYPosition);
#endif
        
        // Animate the tile to appropriate location
        [self animateTileToLocation:tile andDirection:LEFT];
    }
}

#pragma mark - Animates the tile to location
- (void) animateTileToLocation:(DNTileView *) tile andDirection:(PossibleMoves)direction {
    UIView* parent = [tile superview];

    switch (direction) {
        case UP: {
            [UIView animateWithDuration:0.5
                             animations:^ {
                                 CGRect frame = parent.frame;
                                 frame.origin.y -= self.boardView.frame.size.width/4.0;
                                 parent.frame = frame;
                             }
                             completion:^(BOOL finished) {                                 
                                 // Check if the game has ended
                                 // If it has ended, show an alert view
                                 if([self hasGameEnded]) {
                                     UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Congratulations!"
                                                                                     message:@"The puzzle is solved"
                                                                                    delegate:nil
                                                                           cancelButtonTitle:@"Ok"
                                                                           otherButtonTitles:nil];
                                     [alert show];
                                     [alert release];
                                 }
                             }];
            break;
        }
            
        case RIGHT: {
            [UIView animateWithDuration:0.5
                             animations:^ {
                                 CGRect frame = parent.frame;
                                 frame.origin.x += self.boardView.frame.size.width/4.0;
                                 parent.frame = frame;
                             }
                             completion:^(BOOL finished) {                                 
                                 // Check if the game has ended
                                 // If it has ended, show an alert view
                                 if([self hasGameEnded]) {
                                     UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Congratulations!"
                                                                                     message:@"The puzzle is solved"
                                                                                    delegate:nil
                                                                           cancelButtonTitle:@"Ok"
                                                                           otherButtonTitles:nil];
                                     [alert show];
                                     [alert release];
                                 }
                             }];
            break;
        }
            
        case DOWN: {
            [UIView animateWithDuration:0.5
                             animations:^ {
                                 CGRect frame = parent.frame;
                                 frame.origin.y += self.boardView.frame.size.width/4.0;
                                 parent.frame = frame;
                             }
                             completion:^(BOOL finished) {                                 
                                 // Check if the game has ended
                                 // If it has ended, show an alert view
                                 if([self hasGameEnded]) {
                                     UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Congratulations!"
                                                                                     message:@"The puzzle is solved"
                                                                                    delegate:nil
                                                                           cancelButtonTitle:@"Ok"
                                                                           otherButtonTitles:nil];
                                     [alert show];
                                     [alert release];
                                 }
                             }];
            break;
        }
            
        case LEFT: {
            [UIView animateWithDuration:0.5
                             animations:^ {
                                 CGRect frame = parent.frame;
                                 frame.origin.x -= self.boardView.frame.size.width/4.0;
                                 parent.frame = frame;
                             }
                             completion:^(BOOL finished) {                                 
                                 // Check if the game has ended
                                 // If it has ended, show an alert view
                                 if([self hasGameEnded]) {
                                     UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Congratulations!"
                                                                                     message:@"The puzzle is solved"
                                                                                    delegate:nil
                                                                           cancelButtonTitle:@"Ok"
                                                                           otherButtonTitles:nil];
                                     [alert show];
                                     [alert release];
                                 }
                             }];
            break;
        }
            
        default:
            break;
    }
}

#pragma mark - Has Game Ended
- (BOOL) hasGameEnded {
    // Loop over every tile and see if it is in the correct place
    // if YES, then the game has ended

    for(DNTileView* view in self.tiles) {
        if(view.currentXPosition != view.winConditionXPosition ||
           view.currentYPosition != view.winConditionYPosition)
            return  NO;
    }
    return YES;
}

@end
