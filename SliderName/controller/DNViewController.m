//
//  DNViewController.m
//  SliderPuzzle
//
//  Created by Nimesh on 2/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//
//  This is the class that pulls all the strings together.
//  Creates the tile model, and the tile view.
//  Creates a randomized legally solvable board
//  Splits an image into the required grid (in this case a 4x4)
//  Handles the clicking/dragging of tiles or a row (or column) of tiles
//

#import "DNViewController.h"
#import "DNTileView.h"

// Private category on the View Controller class
@interface DNViewController (Private)
/**
    Called  when the user drags (moves) the reference view in/out of view
 */
- (void) moveInOut:(UIPanGestureRecognizer *) panGesture;
/**
    Sets up the board
 */
- (void) setupBoardForImage:(NSString *) image;
/**
    Called when any of the tiles are tapped
 */
- (void) tileTapped:(UITapGestureRecognizer *) tapGesture;
/**
    Called when any of the tiles are dragged
*/
- (void) tileDragged:(UIPanGestureRecognizer *) panGesture;
/**
    Adds white border to every tile
 */
- (UIImage *) borderedTile:(UIImage *) image;
/**
    Recursive function to determine if the tile above/below/right/left
    can be moved, in that case move all the tile(s)
*/
- (BOOL) canMoveTile:(DNTileView *) tile inDirection:(PossibleMoves) direction;

/**
    This method is used to determine if the tile the user is trying to move
    has a valid move or not
    If it does, then the tile is moved and the model is updated
*/
- (BOOL) moveSelectedTile:(DNTileView *) tile andDirection:(PossibleMoves) direction;

/**
    Animates the tile to its proper x and y location
*/
- (void) animateTileToLocation:(DNTileView *) tile andDirection:(PossibleMoves) direction;

@end

@implementation DNViewController

@synthesize startGame, boardView, referenceView, isBoardInitialized, move, tileCanBeDragged, finishDragging, draggedBy, firstX, firstY, tileWidth, tileHeight, tiles, tileModel;

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
    
    // Add the pan gesture to the reference view
    UIPanGestureRecognizer* pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(moveInOut:)];
    [self.referenceView addGestureRecognizer:pan];
    [pan setMinimumNumberOfTouches:1];
    [pan setMaximumNumberOfTouches:1];
    [pan release];
    
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
        
        // Start/Reset button
        self.startGame.frame = CGRectMake(432, 662, 161, 37);
        
        // Board view
        self.boardView.frame = CGRectMake(242, 50, 540, 540);
        
        // The reference view
        if(self.referenceView.frame.origin.x < 0)
            self.referenceView.frame = CGRectMake(-1000,
                                                  self.referenceView.frame.origin.y,
                                                  1024, 768);
        else 
            self.referenceView.frame = CGRectMake(0,
                                                  self.referenceView.frame.origin.y,
                                                  1024, 768);
        
    } else {
        //Portrait
        
        // Start/Reset button
        self.startGame.frame = CGRectMake(304, 762, 161, 37);
        
        // Board view
        self.boardView.frame = CGRectMake(114, 150, 540, 540);
        
        // The reference view
        if(self.referenceView.frame.origin.x < 0)
            self.referenceView.frame = CGRectMake(-740,
                                                  self.referenceView.frame.origin.y,
                                                  768, 1024);
        else 
            self.referenceView.frame = CGRectMake(0,
                                                  self.referenceView.frame.origin.y,
                                                  768, 1024);
    }
}

#pragma mark - Interface Actions
- (IBAction) startTheGame:(id)sender {
#ifdef DEBUG
    NSLog(@"Start Game");
#endif
    
    if(!self.isBoardInitialized) {
        // Initialize the model of the board
        self.tileModel = [DNTileModel sharedModel];
        self.tileModel.delegate = self;
        
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
                         if(UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation])) {
                             self.referenceView.frame = CGRectMake(-740, 0, 768, 1024);
                         } else {
                             self.referenceView.frame = CGRectMake(-1000, 0, 1024, 768);
                         }
                         self.boardView.alpha = 1.0;
                     }
                     completion:^(BOOL finished) {
                         [UIView animateWithDuration:0.5
                                          animations:^ {
                                              [self.startGame setTitle:@"Reset" forState:UIControlStateNormal];
                                          }];
                     }];
}

#pragma mark - Moves the reference view in/out of view
- (void) moveInOut:(UIPanGestureRecognizer *) panGesture {
    
    switch (panGesture.state) {
        case UIGestureRecognizerStateBegan: {
            
            break;
        }
            
        case UIGestureRecognizerStateChanged: {
            CGPoint translation = [panGesture translationInView:self.referenceView];
            if(translation.x > 0) {
                // move in the reference view
                if(UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation])) {
                    self.referenceView.frame = CGRectMake(- 760 + translation.x,
                                                          self.referenceView.frame.origin.y,
                                                          768, 1024);
                } else {
                    self.referenceView.frame = CGRectMake(-1020 + translation.x,
                                                          self.referenceView.frame.origin.y,
                                                          1024, 768);
                }
            } else {
                // move in the reference view
                if(UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation])) {
                    self.referenceView.frame = CGRectMake(0 + translation.x,
                                                          self.referenceView.frame.origin.y,
                                                          768, 1024);
                } else {
                    self.referenceView.frame = CGRectMake(0 + translation.x,
                                                          self.referenceView.frame.origin.y,
                                                          1024, 768);
                }
            }
            break;
        }
        
        case UIGestureRecognizerStateEnded: {
            if(UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation])) {
                if(self.referenceView.frame.origin.x > -380) {
                    [UIView animateWithDuration:0.3
                                     animations:^ {
                                         CGRect frame = self.referenceView.frame;
                                         frame.origin.x = 0.0;
                                         self.referenceView.frame = frame;
                                     }];
                } else {
                    [UIView animateWithDuration:0.3
                                     animations:^ {
                                         CGRect frame = self.referenceView.frame;
                                         frame.origin.x = -740;
                                         self.referenceView.frame = frame;
                                     }];
                }
            } else {
                if(self.referenceView.frame.origin.x > -512) {
                    [UIView animateWithDuration:0.3
                                     animations:^ {
                                         CGRect frame = self.referenceView.frame;
                                         frame.origin.x = 0.0;
                                         self.referenceView.frame = frame;
                                     }];
                } else {
                    [UIView animateWithDuration:0.3
                                     animations:^ {
                                         CGRect frame = self.referenceView.frame;
                                         frame.origin.x = -1000;
                                         self.referenceView.frame = frame;
                                     }];
                }
            }
            
            
            break;
        }
            
        default:
            break;
    }
    
    
}

#pragma mark - Setup Board
- (void) setupBoardForImage:(NSString *)image {
    
    // Initialize the view of the board
    NSString* path = [[NSBundle mainBundle] pathForResource:image ofType:@"png"];
    UIImage* boardImage = [[UIImage alloc] initWithContentsOfFile:path];
    
    CGSize size = CGSizeMake(boardImage.size.width, boardImage.size.height);
    
    self.tileWidth = boardImage.size.width/4.0;
    self.tileHeight = boardImage.size.height/4.0;
    
    int tag = 0;
    for (int i = 0; i < 4; ++i) {
        for (int j = 0; j < 4; ++j) {
            
            CGRect tileRect = CGRectMake(i * self.tileWidth, (3 - j) * self.tileHeight, self.tileWidth, self.tileHeight);
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
            tileIV.frame = CGRectMake(0, 0, self.tileWidth, self.tileHeight);
            
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
            
            UIView* tileView = [[UIView alloc] initWithFrame:CGRectMake(x * self.tileWidth,
                                                                        y * self.tileHeight, 
                                                                        self.tileWidth, 
                                                                        self.tileHeight)];
            
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
            
            UIPanGestureRecognizer* pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(tileDragged:)];
            pan.maximumNumberOfTouches = 1;
            pan.minimumNumberOfTouches = 1;
            [tileView addGestureRecognizer:pan];
            [pan release];
            
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
    NSLog(@"Current position of the tile tapped is = %d %d", viewTapped.currentXPosition, viewTapped.currentYPosition);
#endif
    
    if([self canMoveTile:viewTapped inDirection:UP]) {
#ifdef DEBUG
        NSLog(@"Moving UP");
#endif
    }
    else if([self canMoveTile:viewTapped inDirection:RIGHT]) {
#ifdef DEBUG
        NSLog(@"Moving RIGHT");
#endif
    }
    else if ([self canMoveTile:viewTapped inDirection:DOWN]) {
#ifdef DEBUG
        NSLog(@"Moving DOWN");
#endif
    } else if([self canMoveTile:viewTapped inDirection:LEFT]) {
#ifdef DEBUG
        NSLog(@"Moving LEFT");
#endif
    }
}

#pragma mark - Tile Dragged
- (void) tileDragged:(UIPanGestureRecognizer *)panGesture {
    DNTileView* viewDragged = (DNTileView *)[self.tiles objectAtIndex:panGesture.view.tag];
#ifdef DEBUG
    //    NSLog(@"Win Condition position of the tile tapped is = %d %d", viewTapped.winConditionXPosition, viewTapped.winConditionYPosition);
    NSLog(@"Current position of the tile dragged is = %d %d", viewDragged.currentXPosition, viewDragged.currentYPosition);
#endif
    // swtich between the various pan gesture states
    switch (panGesture.state) {
            // check to see if the tile the user is trying to drag is draggable
        case UIGestureRecognizerStateBegan: {
            self.move = [self.tileModel canDragTileWithXPos:viewDragged.currentXPosition yPos:viewDragged.currentYPosition];
            if(self.move != NONE) {
                self.tileCanBeDragged = YES;
                self.firstX = [viewDragged superview].center.x;
                self.firstY = [viewDragged superview].center.y;
            } else {
                self.firstX = 0;
                self.firstY = 0;
                self.tileCanBeDragged = NO;
            }
            break;
        }
            
        case UIGestureRecognizerStateChanged: {
            if(self.tileCanBeDragged) {
                switch (self.move) {
                    case THREEUP: {
                        CGPoint translation = [panGesture translationInView:self.boardView];
                        if(translation.y < 0.0) {
#ifdef DEBUG
                            NSLog(@"Translation y = %f", translation.y);
#endif
                            int translatedX = self.firstX;
                            int translatedY = self.firstY + translation.y;
                            
                            if(translatedY <= self.firstY - self.tileHeight)
                                translatedY = self.firstY - self.tileHeight;
                            
                            [[viewDragged superview] setCenter:CGPointMake(translatedX, translatedY)];
                            int counter = 2;
                            
                            for (DNTileView* view in self.tiles) {
                                if(view.currentXPosition == viewDragged.currentXPosition &&
                                   view.currentYPosition == viewDragged.currentYPosition - 1) {
                                    tileOne = view;
                                    counter--;
                                }
                                
                                if(view.currentXPosition == viewDragged.currentXPosition &&
                                   view.currentYPosition == viewDragged.currentYPosition - 2) {
                                    tileTwo = view;
                                    counter--;
                                }
                                
                                if(counter <= 0)
                                    break;
                            }
                            
                            translatedY = self.firstY - self.tileHeight + translation.y;
                            if(translatedY <= self.firstY - self.tileHeight * 2)
                                translatedY = self.firstY - self.tileHeight * 2;
                            
                            [[tileOne superview] setCenter:CGPointMake(translatedX, 
                                                                       translatedY)];
                            
                            
                            translatedY = self.firstY - self.tileHeight * 2 + translation.y;
                            if(translatedY <= self.firstY - self.tileHeight * 3)
                                translatedY = self.firstY - self.tileHeight * 3;
                            
                            [[tileTwo superview] setCenter:CGPointMake(translatedX, 
                                                                       translatedY)];
                            
                            if(translation.y <= -67.0) {
                                self.finishDragging = YES;
                                self.draggedBy = translation.y;
                            } else {
                                self.finishDragging = NO;
                                self.draggedBy = translation.y;
                            }
                        }
                        break;
                    }
                        
                    case TWOUP: {
                        CGPoint translation = [panGesture translationInView:self.boardView];
                        if(translation.y < 0.0) {
#ifdef DEBUG
                            NSLog(@"Translation y = %f", translation.y);
#endif
                            int translatedX = self.firstX;
                            int translatedY = self.firstY + translation.y;
                            
                            if(translatedY <= self.firstY - self.tileHeight)
                                translatedY = self.firstY - self.tileHeight;
                            
                            [[viewDragged superview] setCenter:CGPointMake(translatedX, translatedY)];
                            
                            int counter = 1;
                            
                            for (DNTileView* view in self.tiles) {
                                if(view.currentXPosition == viewDragged.currentXPosition &&
                                   view.currentYPosition == viewDragged.currentYPosition - 1) {
                                    tileOne = view;
                                    counter--;
                                }
                                
                                if(counter <= 0)
                                    break;
                            }
                                                        
                            translatedY = self.firstY - self.tileHeight + translation.y;
                            if(translatedY <= self.firstY - self.tileHeight * 2)
                                translatedY = self.firstY - self.tileHeight * 2;
                            
                            [[tileOne superview] setCenter:CGPointMake(translatedX, 
                                                                       translatedY)];
                            
                            if(translation.y <= -67.0) {
                                self.finishDragging = YES;
                                self.draggedBy = translation.y;
                            } else {
                                self.finishDragging = NO;
                                self.draggedBy = translation.y;
                            }
                        }
                        break;
                    }
                        
                    case UP: {
                        CGPoint translation = [panGesture translationInView:self.boardView];
                        if(translation.y < 0.0) {
#ifdef DEBUG
                            NSLog(@"Translation y = %f", translation.y);
#endif
                            int translatedX = self.firstX;
                            int translatedY = self.firstY + translation.y;
                            
                            if(translatedY <= self.firstY - self.tileHeight)
                                translatedY = self.firstY - self.tileHeight;
                            
                            [[viewDragged superview] setCenter:CGPointMake(translatedX, translatedY)];
                            
                            if(translation.y <= -67.0) {
                                self.finishDragging = YES;
                                self.draggedBy = translation.y;
                            } else {
                                self.finishDragging = NO;
                                self.draggedBy = translation.y;
                            }
                        }
                        break;
                    }
                        
                    case THREERIGHT: {
                        CGPoint translation = [panGesture translationInView:self.boardView];
                        if(translation.x > 0.0) {
#ifdef DEBUG
                            NSLog(@"Translation x = %f", translation.x);
#endif
                            int translatedX = self.firstX + translation.x;
                            int translatedY = self.firstY;
                            
                            if(translatedX >= self.firstX + self.tileWidth)
                                translatedX = self.firstX + self.tileWidth;
                            
                            [[viewDragged superview] setCenter:CGPointMake(translatedX, translatedY)];
                            int counter = 2;
                            
                            for (DNTileView* view in self.tiles) {
                                if(view.currentXPosition == viewDragged.currentXPosition + 1 &&
                                   view.currentYPosition == viewDragged.currentYPosition) {
                                    tileOne = view;
                                    counter--;
                                }
                                
                                if(view.currentXPosition == viewDragged.currentXPosition + 2 &&
                                   view.currentYPosition == viewDragged.currentYPosition) {
                                    tileTwo = view;
                                    counter--;
                                }
                                
                                if(counter <= 0)
                                    break;
                            }
                            
                            translatedX = self.firstX + self.tileWidth + translation.x;
                            if (translatedX >= self.firstX + self.tileWidth * 2)
                                translatedX = self.firstX + self.tileWidth * 2;
                            
                            [[tileOne superview] setCenter:CGPointMake(translatedX,
                                                                       translatedY)];
                            
                            translatedX = self.firstX + self.tileWidth * 2 + translation.x;
                            if(translatedX >= self.firstX + self.tileWidth * 3)
                                translatedX = self.firstX + self.tileWidth * 3;
                            
                            [[tileTwo superview] setCenter:CGPointMake(translatedX, 
                                                                       translatedY)];
                            
                            if(translation.x >= 67.0) {
                                self.finishDragging = YES;
                                self.draggedBy = translation.y;
                            } else {
                                self.finishDragging = NO;
                                self.draggedBy = translation.y;
                            }
                        }
                        break;
                    }
                        
                    case TWORIGHT: {
                        CGPoint translation = [panGesture translationInView:self.boardView];
                        if(translation.x > 0.0) {
#ifdef DEBUG
                            NSLog(@"Translation x = %f", translation.x);
#endif
                            int translatedX = self.firstX + translation.x;
                            int translatedY = self.firstY;
                            
                            if(translatedX >= self.firstX + self.tileWidth)
                                translatedX = self.firstX + self.tileWidth;
                            
                            [[viewDragged superview] setCenter:CGPointMake(translatedX, translatedY)];
                            int counter = 1;
                            
                            for (DNTileView* view in self.tiles) {
                                if(view.currentXPosition == viewDragged.currentXPosition + 1 &&
                                   view.currentYPosition == viewDragged.currentYPosition) {
                                    tileOne = view;
                                    counter--;
                                }
                                
                                if(counter <= 0)
                                    break;
                            }
                            
                            translatedX = self.firstX + self.tileWidth + translation.x;
                            if (translatedX >= self.firstX + self.tileWidth * 2)
                                translatedX = self.firstX + self.tileWidth * 2;
                            
                            [[tileOne superview] setCenter:CGPointMake(translatedX,
                                                                       translatedY)];
                            
                            if(translation.x >= 67.0) {
                                self.finishDragging = YES;
                                self.draggedBy = translation.y;
                            } else {
                                self.finishDragging = NO;
                                self.draggedBy = translation.y;
                            }
                        }
                        break;
                    }
                        
                    case RIGHT: {
                        CGPoint translation = [panGesture translationInView:self.boardView];
                        if(translation.x > 0.0) {
#ifdef DEBUG
                            NSLog(@"Translation x = %f", translation.x);
#endif
                            int translatedX = self.firstX + translation.x;
                            int translatedY = self.firstY;
                            
                            if(translatedX >= self.firstX + self.tileWidth)
                                translatedX = self.firstX + self.tileWidth;
                            
                            [[viewDragged superview] setCenter:CGPointMake(translatedX, translatedY)];
                            
                            if(translation.x >= 67.0) {
                                self.finishDragging = YES;
                                self.draggedBy = translation.y;
                            } else {
                                self.finishDragging = NO;
                                self.draggedBy = translation.y;
                            }
                        }
                        break;
                    }
                        
                    case THREEDOWN: {
                        CGPoint translation = [panGesture translationInView:self.boardView];
                        if(translation.y > 0.0) {
#ifdef DEBUG
                            NSLog(@"Translation y = %f", translation.y);
#endif
                            int translatedX = self.firstX;
                            int translatedY = self.firstY + translation.y;
                            
                            if(translatedY >= self.firstY + self.tileHeight)
                                translatedY = self.firstY + self.tileHeight;
                            
                            [[viewDragged superview] setCenter:CGPointMake(translatedX, translatedY)];
                            int counter = 2;
                            
                            for (DNTileView* view in self.tiles) {
                                if(view.currentXPosition == viewDragged.currentXPosition &&
                                   view.currentYPosition == viewDragged.currentYPosition + 1) {
                                    tileOne = view;
                                    counter--;
                                }
                                
                                if(view.currentXPosition == viewDragged.currentXPosition &&
                                   view.currentYPosition == viewDragged.currentYPosition + 2) {
                                    tileTwo = view;
                                    counter--;
                                }
                                
                                if(counter <= 0)
                                    break;
                            }
                            
                            translatedY = self.firstY + self.tileHeight + translation.y;
                            if(translatedY >= self.firstY + self.tileHeight * 2)
                                translatedY = self.firstY + self.tileHeight * 2;
                            
                            [[tileOne superview] setCenter:CGPointMake(translatedX, 
                                                           translatedY)];
                            
                            translatedY = self.firstY + self.tileHeight * 2 + translation.y;
                            if(translatedY >= self.firstY + self.tileHeight * 3)
                                translatedY = self.firstY + self.tileHeight * 3;
                            
                            [[tileTwo superview] setCenter:CGPointMake(translatedX, 
                                                           translatedY)];
                            
                            if(translation.y >= 67.0) {
                                self.finishDragging = YES;
                                self.draggedBy = translation.y;
                            } else {
                                self.finishDragging = NO;
                                self.draggedBy = translation.y;
                            }
                        }
                        break;
                    }
                        
                    case TWODOWN: {
                        CGPoint translation = [panGesture translationInView:self.boardView];
                        if(translation.y > 0.0) {
#ifdef DEBUG
                            NSLog(@"Translation y = %f", translation.y);
#endif
                            int translatedX = self.firstX;
                            int translatedY = self.firstY + translation.y;
                            
                            if(translatedY >= self.firstY + self.tileHeight)
                                translatedY = self.firstY + self.tileHeight;
                            
                            [[viewDragged superview] setCenter:CGPointMake(translatedX, translatedY)];
                            int counter = 1;
                            
                            for (DNTileView* view in self.tiles) {
                                if(view.currentXPosition == viewDragged.currentXPosition &&
                                   view.currentYPosition == viewDragged.currentYPosition + 1) {
                                    tileOne = view;
                                    counter--;
                                }
                                
                                if(counter <= 0)
                                    break;
                            }
                            
                            translatedY = self.firstY + self.tileHeight + translation.y;
                            if(translatedY >= self.firstY + self.tileHeight * 2)
                                translatedY = self.firstY + self.tileHeight * 2;
                            
                            [[tileOne superview] setCenter:CGPointMake(translatedX, 
                                                                       translatedY)];
                            
                            if(translation.y >= 67.0) {
                                self.finishDragging = YES;
                                self.draggedBy = translation.y;
                            } else {
                                self.finishDragging = NO;
                                self.draggedBy = translation.y;
                            }
                        }
                        break;
                    }
                        
                    case DOWN: {
                        CGPoint translation = [panGesture translationInView:self.boardView];
                        if(translation.y > 0.0) {
#ifdef DEBUG
                            NSLog(@"Translation y = %f", translation.y);
#endif
                            int translatedX = self.firstX;
                            int translatedY = self.firstY + translation.y;
                            
                            if(translatedY >= self.firstY + self.tileHeight)
                                translatedY = self.firstY + self.tileHeight;
                            
                            [[viewDragged superview] setCenter:CGPointMake(translatedX, translatedY)];
                            
                            if(translation.y >= 67.0) {
                                self.finishDragging = YES;
                                self.draggedBy = translation.y;
                            } else {
                                self.finishDragging = NO;
                                self.draggedBy = translation.y;
                            }
                        }
                        break;
                    }
                        
                    case THREELEFT: {
                        CGPoint translation = [panGesture translationInView:self.boardView];
                        if(translation.x < 0.0) {
#ifdef DEBUG
                            NSLog(@"Translation x = %f", translation.x);
#endif
                            int translatedX = self.firstX + translation.x;
                            int translatedY = self.firstY;
                            
                            if(translatedX <= self.firstX - self.tileWidth)
                                translatedX = self.firstX - self.tileWidth;
                            
                            [[viewDragged superview] setCenter:CGPointMake(translatedX, translatedY)];
                            int counter = 2;
                            
                            for (DNTileView* view in self.tiles) {
                                if(view.currentXPosition == viewDragged.currentXPosition - 1 &&
                                   view.currentYPosition == viewDragged.currentYPosition) {
                                    tileOne = view;
                                    counter--;
                                }
                                
                                if(view.currentXPosition == viewDragged.currentXPosition - 2 &&
                                   view.currentYPosition == viewDragged.currentYPosition) {
                                    tileTwo = view;
                                    counter--;
                                }
                                
                                if(counter <= 0)
                                    break;
                            }
                            
                            translatedX = self.firstX - self.tileWidth + translation.x;
                            if(translatedX <= self.firstX - self.tileWidth * 2)
                                translatedX = self.firstX - self.tileWidth * 2;
                            
                            [[tileOne superview] setCenter:CGPointMake(translatedX, translatedY)];
                            
                            translatedX = self.firstX - self.tileWidth * 2 + translation.x;
                            if(translatedX <= self.firstX - self.tileWidth * 3)
                                translatedX = self.firstX - self.tileWidth * 3;
                            
                            [[tileTwo superview] setCenter:CGPointMake(translatedX,
                                                                       translatedY)];
                            
                            if(translation.x <= -67.0) {
                                self.finishDragging = YES;
                                self.draggedBy = translation.y;
                            } else {
                                self.finishDragging = NO;
                                self.draggedBy = translation.y;
                            }
                        }
                        break;
                    }
                        
                    case TWOLEFT: {
                        CGPoint translation = [panGesture translationInView:self.boardView];
                        if(translation.x < 0.0) {
#ifdef DEBUG
                            NSLog(@"Translation x = %f", translation.x);
#endif
                            int translatedX = self.firstX + translation.x;
                            int translatedY = self.firstY;
                            
                            if(translatedX <= self.firstX - self.tileWidth)
                                translatedX = self.firstX - self.tileWidth;
                            
                            [[viewDragged superview] setCenter:CGPointMake(translatedX, translatedY)];
                            int counter = 1;
                            
                            for (DNTileView* view in self.tiles) {
                                if(view.currentXPosition == viewDragged.currentXPosition - 1 &&
                                   view.currentYPosition == viewDragged.currentYPosition) {
                                    tileOne = view;
                                    counter--;
                                }
                                
                                if(counter <= 0)
                                    break;
                            }
                            
                            translatedX = self.firstX - self.tileWidth + translation.x;
                            if(translatedX <= self.firstX - self.tileWidth * 2)
                                translatedX = self.firstX - self.tileWidth * 2;
                            
                            [[tileOne superview] setCenter:CGPointMake(translatedX, translatedY)];
                            
                            if(translation.x <= -67.0) {
                                self.finishDragging = YES;
                                self.draggedBy = translation.y;
                            } else {
                                self.finishDragging = NO;
                                self.draggedBy = translation.y;
                            }
                        }
                        break;
                    }
                        
                    case LEFT: {
                        CGPoint translation = [panGesture translationInView:self.boardView];
                        if(translation.x < 0.0) {
#ifdef DEBUG
                            NSLog(@"Translation x = %f", translation.x);
#endif
                            int translatedX = self.firstX + translation.x;
                            int translatedY = self.firstY;
                            
                            if(translatedX <= self.firstX - self.tileWidth)
                                translatedX = self.firstX - self.tileWidth;
                            
                            [[viewDragged superview] setCenter:CGPointMake(translatedX, translatedY)];
                            
                            if(translation.x <= -67.0) {
                                self.finishDragging = YES;
                                self.draggedBy = translation.y;
                            } else {
                                self.finishDragging = NO;
                                self.draggedBy = translation.y;
                            }
                        }
                        break;
                    }
                        
                    default:
                        break;
                }
            }
            break;
        }
            
        case UIGestureRecognizerStateEnded: {
            if(self.tileCanBeDragged) {
                switch (self.move) {
                    case THREEUP: {
                        if(self.finishDragging) {
#ifdef DEBUG
                            NSLog(@"Board before = %@", self.tileModel.board);
#endif
                            // update the 3 tiles in the model
                            [self.tileModel moveTileWithXPos:tileTwo.currentXPosition yPos:tileTwo.currentYPosition inDirection:UP];
                            [self.tileModel moveTileWithXPos:tileOne.currentXPosition yPos:tileOne.currentYPosition inDirection:UP];
                            [self.tileModel moveTileWithXPos:viewDragged.currentXPosition
                                                        yPos:viewDragged.currentYPosition inDirection:UP];
#ifdef DEBUG
                            NSLog(@"Board after = %@", self.tileModel.board);
#endif
                           // Move the tiles UP
                            int index = [self.tiles indexOfObject:viewDragged];
                            int index2 = [self.tiles indexOfObject:tileOne];
                            int index3 = [self.tiles indexOfObject:tileTwo];
                            
                            // Update the tile (view)
                            viewDragged.currentYPosition -= 1;
                            tileOne.currentYPosition -= 1;
                            tileTwo.currentYPosition -= 1;
                            
                            [self.tiles replaceObjectAtIndex:index3 withObject:tileTwo];
                            [self.tiles replaceObjectAtIndex:index2 withObject:tileOne];
                            [self.tiles replaceObjectAtIndex:index withObject:viewDragged];
                            
                            [UIView animateWithDuration:0.5
                                             animations:^ {
                                                 int finishedX = firstX;
                                                 int finishedY = firstY - self.tileHeight;
                                                 [[tileTwo superview] setCenter:CGPointMake(finishedX, self.firstY - self.tileHeight * 3)];
                                                 [[tileOne superview] setCenter:CGPointMake(finishedX, self.firstY - self.tileHeight * 2)];
                                                 [[viewDragged superview] setCenter:CGPointMake(finishedX, finishedY)];
                                                 self.tileCanBeDragged = NO;
                                                 self.finishDragging = NO;
                                             }
                                             completion:^(BOOL finished) {
                                                 // Check if the game has ended
                                                 // If it has ended, show an alert view
                                                 if([self.tileModel hasGameEnded]) {
                                                     UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Congratulations!"
                                                                                                     message:@"The puzzle is solved"
                                                                                                    delegate:nil
                                                                                           cancelButtonTitle:@"Ok"
                                                                                           otherButtonTitles:nil];
                                                     [alert show];
                                                     [alert release];
                                                 }
                                             }];
                        } else {
                            self.tileCanBeDragged = NO;
                            self.finishDragging = NO;
                            [UIView animateWithDuration:0.5
                                             animations:^ {
                                                 int finishedX = self.firstX;
                                                 int finishedY = self.firstY;
                                                 [[viewDragged superview] setCenter:CGPointMake(finishedX, finishedY)];
                                                 [[tileOne superview] setCenter:CGPointMake(finishedX, finishedY - self.tileHeight)];
                                                 [[tileTwo superview] setCenter:CGPointMake(finishedX, finishedY - self.tileHeight * 2)];
                                             }
                                             completion:nil];
                        }
                        break;
                    }
                        
                    case TWOUP: {
                        if(self.finishDragging) {
#ifdef DEBUG
                            NSLog(@"Board before = %@", self.tileModel.board);
#endif
                            // update the 2 tiles in the model
                            [self.tileModel moveTileWithXPos:tileOne.currentXPosition yPos:tileOne.currentYPosition inDirection:UP];
                            [self.tileModel moveTileWithXPos:viewDragged.currentXPosition
                                                        yPos:viewDragged.currentYPosition inDirection:UP];
#ifdef DEBUG
                            NSLog(@"Board after = %@", self.tileModel.board);
#endif
                            
                            // Move the tiles UP
                            int index = [self.tiles indexOfObject:viewDragged];
                            int index2 = [self.tiles indexOfObject:tileOne];
                            
                            // Update the tile (view)
                            viewDragged.currentYPosition -= 1;
                            tileOne.currentYPosition -= 1;
                            
                            [self.tiles replaceObjectAtIndex:index2 withObject:tileOne];
                            [self.tiles replaceObjectAtIndex:index withObject:viewDragged];
                            
                            [UIView animateWithDuration:0.5
                                             animations:^ {
                                                 int finishedX = self.firstX;
                                                 int finishedY = self.firstY - self.tileHeight;
                                                 [[tileOne superview] setCenter:CGPointMake(finishedX, self.firstY - self.tileHeight * 2)];
                                                 [[viewDragged superview] setCenter:CGPointMake(finishedX, finishedY)];
                                                 self.tileCanBeDragged = NO;
                                                 self.finishDragging = NO;
                                             }
                                             completion:^(BOOL finished) {
                                                 // Check if the game has ended
                                                 // If it has ended, show an alert view
                                                 if([self.tileModel hasGameEnded]) {
                                                     UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Congratulations!"
                                                                                                     message:@"The puzzle is solved"
                                                                                                    delegate:nil
                                                                                           cancelButtonTitle:@"Ok"
                                                                                           otherButtonTitles:nil];
                                                     [alert show];
                                                     [alert release];
                                                 }
                                             }];
                        } else {
                            self.tileCanBeDragged = NO;
                            self.finishDragging = NO;
                            [UIView animateWithDuration:0.5
                                             animations:^ {
                                                 int finishedX = self.firstX;
                                                 int finishedY = self.firstY;
                                                 [[viewDragged superview] setCenter:CGPointMake(finishedX, finishedY)];
                                                 [[tileOne superview] setCenter:CGPointMake(finishedX, finishedY - self.tileHeight)];
                                             }
                                             completion:nil];
                        }
                        break;
                    }
                        
                    case UP: {
                        if(self.finishDragging) {
                            [self.tileModel moveTileWithXPos:viewDragged.currentXPosition
                                                        yPos:viewDragged.currentYPosition inDirection:UP];
                            
                            // Move the tile UP
                            int index = [self.tiles indexOfObject:viewDragged];
                            
                            // Update the tile (view)
                            viewDragged.currentYPosition -= 1;
                            [self.tiles replaceObjectAtIndex:index withObject:viewDragged];
                            
                            [UIView animateWithDuration:0.5
                                             animations:^ {
                                                 int finishedX = firstX;
                                                 int finishedY = firstY - self.tileHeight;
                                                 [[viewDragged superview] setCenter:CGPointMake(finishedX, finishedY)];
                                                 self.tileCanBeDragged = NO;
                                                 self.finishDragging = NO;
                                             }
                                             completion:^(BOOL finished) {
                                                 // Check if the game has ended
                                                 // If it has ended, show an alert view
                                                 if([self.tileModel hasGameEnded]) {
                                                     UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Congratulations!"
                                                                                                     message:@"The puzzle is solved"
                                                                                                    delegate:nil
                                                                                           cancelButtonTitle:@"Ok"
                                                                                           otherButtonTitles:nil];
                                                     [alert show];
                                                     [alert release];
                                                 }
                                             }];
                        } else {
                            self.tileCanBeDragged = NO;
                            self.finishDragging = NO;
                            [UIView animateWithDuration:0.5
                                             animations:^ {
                                                 int finishedX = self.firstX;
                                                 int finishedY = self.firstY;
                                                 [[viewDragged superview] setCenter:CGPointMake(finishedX, finishedY)];
                                             }
                                             completion:nil];
                        }
                        
                        break;
                    }
                        
                    case THREERIGHT: {
                        if(self.finishDragging) {
#ifdef DEBUG
                            NSLog(@"Board before = %@", self.tileModel.board);
#endif
                            // update the 3 tiles in the model
                            [self.tileModel moveTileWithXPos:tileTwo.currentXPosition yPos:tileTwo.currentYPosition inDirection:RIGHT];
                            [self.tileModel moveTileWithXPos:tileOne.currentXPosition yPos:tileOne.currentYPosition inDirection:RIGHT];
                            [self.tileModel moveTileWithXPos:viewDragged.currentXPosition
                                                        yPos:viewDragged.currentYPosition inDirection:RIGHT];
#ifdef DEBUG
                            NSLog(@"Board after = %@", self.tileModel.board);
#endif
                            
                            // Move the tiles UP
                            int index = [self.tiles indexOfObject:viewDragged];
                            int index2 = [self.tiles indexOfObject:tileOne];
                            int index3 = [self.tiles indexOfObject:tileTwo];
                            
                            // Update the tile (view)
                            viewDragged.currentXPosition += 1;
                            tileOne.currentXPosition += 1;
                            tileTwo.currentXPosition += 1;
                            
                            [self.tiles replaceObjectAtIndex:index3 withObject:tileTwo];
                            [self.tiles replaceObjectAtIndex:index2 withObject:tileOne];
                            [self.tiles replaceObjectAtIndex:index withObject:viewDragged];
                            
                            [UIView animateWithDuration:0.5
                                             animations:^ {
                                                 int finishedX = self.firstX + self.tileWidth;
                                                 int finishedY = self.firstY;
                                                 [[tileTwo superview] setCenter:CGPointMake(self.firstX + self.tileWidth * 3, finishedY)];
                                                 [[tileOne superview] setCenter:CGPointMake(self.firstX + self.tileWidth * 2, finishedY)];
                                                 [[viewDragged superview] setCenter:CGPointMake(finishedX, finishedY)];
                                                 self.tileCanBeDragged = NO;
                                                 self.finishDragging = NO;
                                             }
                                             completion:^(BOOL finished) {
                                                 // Check if the game has ended
                                                 // If it has ended, show an alert view
                                                 if([self.tileModel hasGameEnded]) {
                                                     UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Congratulations!"
                                                                                                     message:@"The puzzle is solved"
                                                                                                    delegate:nil
                                                                                           cancelButtonTitle:@"Ok"
                                                                                           otherButtonTitles:nil];
                                                     [alert show];
                                                     [alert release];
                                                 }
                                             }];
                        } else {
                            self.tileCanBeDragged = NO;
                            self.finishDragging = NO;
                            [UIView animateWithDuration:0.5
                                             animations:^ {
                                                 int finishedX = self.firstX;
                                                 int finishedY = self.firstY;
                                                 [[viewDragged superview] setCenter:CGPointMake(finishedX, finishedY)];
                                                 [[tileOne superview] setCenter:CGPointMake(finishedX + self.tileWidth, finishedY)];
                                                 [[tileTwo superview] setCenter:CGPointMake(finishedX + self.tileWidth * 2, finishedY)];
                                             }
                                             completion:nil];
                        }
                        break;
                    }
                        
                    case TWORIGHT: {
                        if(self.finishDragging) {
#ifdef DEBUG
                            NSLog(@"Board before = %@", self.tileModel.board);
#endif
                            // update the 2 tiles in the model
                            [self.tileModel moveTileWithXPos:tileOne.currentXPosition yPos:tileOne.currentYPosition inDirection:RIGHT];
                            [self.tileModel moveTileWithXPos:viewDragged.currentXPosition
                                                        yPos:viewDragged.currentYPosition inDirection:RIGHT];
#ifdef DEBUG
                            NSLog(@"Board after = %@", self.tileModel.board);
#endif
                            
                            // Move the tiles UP
                            int index = [self.tiles indexOfObject:viewDragged];
                            int index2 = [self.tiles indexOfObject:tileOne];
                            
                            // Update the tile (view)
                            viewDragged.currentXPosition += 1;
                            tileOne.currentXPosition += 1;
                            
                            [self.tiles replaceObjectAtIndex:index2 withObject:tileOne];
                            [self.tiles replaceObjectAtIndex:index withObject:viewDragged];
                            
                            [UIView animateWithDuration:0.5
                                             animations:^ {
                                                 int finishedX = self.firstX + self.tileWidth;
                                                 int finishedY = self.firstY;
                                                 [[tileOne superview] setCenter:CGPointMake(self.firstX + self.tileWidth * 2, finishedY)];
                                                 [[viewDragged superview] setCenter:CGPointMake(finishedX, finishedY)];
                                                 self.tileCanBeDragged = NO;
                                                 self.finishDragging = NO;
                                             }
                                             completion:^(BOOL finished) {
                                                 // Check if the game has ended
                                                 // If it has ended, show an alert view
                                                 if([self.tileModel hasGameEnded]) {
                                                     UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Congratulations!"
                                                                                                     message:@"The puzzle is solved"
                                                                                                    delegate:nil
                                                                                           cancelButtonTitle:@"Ok"
                                                                                           otherButtonTitles:nil];
                                                     [alert show];
                                                     [alert release];
                                                 }
                                             }];
                        } else {
                            self.tileCanBeDragged = NO;
                            self.finishDragging = NO;
                            [UIView animateWithDuration:0.5
                                             animations:^ {
                                                 int finishedX = self.firstX;
                                                 int finishedY = self.firstY;
                                                 [[viewDragged superview] setCenter:CGPointMake(finishedX, finishedY)];
                                                 [[tileOne superview] setCenter:CGPointMake(finishedX + self.tileWidth, finishedY)];
                                             }
                                             completion:nil];
                        }
                        break;
                    }
                        
                    case RIGHT: {
                        if(self.finishDragging) {
#ifdef DEBUG
                            NSLog(@"Board before = %@", self.tileModel.board);
#endif
                            // update the tile in the model
                            [self.tileModel moveTileWithXPos:viewDragged.currentXPosition
                                                        yPos:viewDragged.currentYPosition inDirection:RIGHT];
#ifdef DEBUG
                            NSLog(@"Board after = %@", self.tileModel.board);
#endif
                            
                            // Move the tiles UP
                            int index = [self.tiles indexOfObject:viewDragged];
                            
                            // Update the tile (view)
                            viewDragged.currentXPosition += 1;
                            
                            [self.tiles replaceObjectAtIndex:index withObject:viewDragged];
                            
                            [UIView animateWithDuration:0.5
                                             animations:^ {
                                                 int finishedX = self.firstX + self.tileWidth;
                                                 int finishedY = self.firstY;
                                                 [[viewDragged superview] setCenter:CGPointMake(finishedX, finishedY)];
                                                 self.tileCanBeDragged = NO;
                                                 self.finishDragging = NO;
                                             }
                                             completion:^(BOOL finished) {
                                                 // Check if the game has ended
                                                 // If it has ended, show an alert view
                                                 if([self.tileModel hasGameEnded]) {
                                                     UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Congratulations!"
                                                                                                     message:@"The puzzle is solved"
                                                                                                    delegate:nil
                                                                                           cancelButtonTitle:@"Ok"
                                                                                           otherButtonTitles:nil];
                                                     [alert show];
                                                     [alert release];
                                                 }
                                             }];
                        } else {
                            self.tileCanBeDragged = NO;
                            self.finishDragging = NO;
                            [UIView animateWithDuration:0.5
                                             animations:^ {
                                                 int finishedX = self.firstX;
                                                 int finishedY = self.firstY;
                                                 [[viewDragged superview] setCenter:CGPointMake(finishedX, finishedY)];
                                             }
                                             completion:nil];
                        }
                        break;
                    }
                        
                    case THREEDOWN: {
                        if(self.finishDragging) {
#ifdef DEBUG
                            NSLog(@"Board before = %@", self.tileModel.board);
#endif
                            // update the 3 tiles in the model
                            [self.tileModel moveTileWithXPos:tileTwo.currentXPosition yPos:tileTwo.currentYPosition inDirection:DOWN];
                            [self.tileModel moveTileWithXPos:tileOne.currentXPosition yPos:tileOne.currentYPosition inDirection:DOWN];
                            [self.tileModel moveTileWithXPos:viewDragged.currentXPosition
                                                        yPos:viewDragged.currentYPosition inDirection:DOWN];
#ifdef DEBUG
                            NSLog(@"Board after = %@", self.tileModel.board);
#endif
                            
                            // Move the tiles UP
                            int index = [self.tiles indexOfObject:viewDragged];
                            int index2 = [self.tiles indexOfObject:tileOne];
                            int index3 = [self.tiles indexOfObject:tileTwo];
                            
                            // Update the tile (view)
                            viewDragged.currentYPosition += 1;
                            tileOne.currentYPosition += 1;
                            tileTwo.currentYPosition += 1;
                            
                            [self.tiles replaceObjectAtIndex:index3 withObject:tileTwo];
                            [self.tiles replaceObjectAtIndex:index2 withObject:tileOne];
                            [self.tiles replaceObjectAtIndex:index withObject:viewDragged];
                            
                            [UIView animateWithDuration:0.5
                                             animations:^ {
                                                 int finishedX = self.firstX;
                                                 int finishedY = self.firstY + self.tileHeight;
                                                 [[tileTwo superview] setCenter:CGPointMake(finishedX, self.firstY + self.tileHeight * 3)];
                                                 [[tileOne superview] setCenter:CGPointMake(finishedX, self.firstY + self.tileHeight * 2)];
                                                 [[viewDragged superview] setCenter:CGPointMake(finishedX, finishedY)];
                                                 self.tileCanBeDragged = NO;
                                                 self.finishDragging = NO;
                                             }
                                             completion:^(BOOL finished) {
                                                 // Check if the game has ended
                                                 // If it has ended, show an alert view
                                                 if([self.tileModel hasGameEnded]) {
                                                     UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Congratulations!"
                                                                                                     message:@"The puzzle is solved"
                                                                                                    delegate:nil
                                                                                           cancelButtonTitle:@"Ok"
                                                                                           otherButtonTitles:nil];
                                                     [alert show];
                                                     [alert release];
                                                 }
                                             }];
                        } else {
                            self.tileCanBeDragged = NO;
                            self.finishDragging = NO;
                            [UIView animateWithDuration:0.5
                                             animations:^ {
                                                 int finishedX = self.firstX;
                                                 int finishedY = self.firstY;
                                                 [[viewDragged superview] setCenter:CGPointMake(finishedX, finishedY)];
                                                 [[tileOne superview] setCenter:CGPointMake(finishedX, finishedY + self.tileHeight)];
                                                 [[tileTwo superview] setCenter:CGPointMake(finishedX, finishedY + self.tileHeight * 2)];
                                             }
                                             completion:nil];
                        }
                        break;
                    }
                        
                    case TWODOWN: {
                        if(self.finishDragging) {
#ifdef DEBUG
                            NSLog(@"Board before = %@", self.tileModel.board);
#endif
                            // update the 2 tiles in the model
                            [self.tileModel moveTileWithXPos:tileOne.currentXPosition yPos:tileOne.currentYPosition inDirection:DOWN];
                            [self.tileModel moveTileWithXPos:viewDragged.currentXPosition
                                                        yPos:viewDragged.currentYPosition inDirection:DOWN];
#ifdef DEBUG
                            NSLog(@"Board after = %@", self.tileModel.board);
#endif
                            
                            // Move the tiles UP
                            int index = [self.tiles indexOfObject:viewDragged];
                            int index2 = [self.tiles indexOfObject:tileOne];
                            
                            // Update the tile (view)
                            viewDragged.currentYPosition += 1;
                            tileOne.currentYPosition += 1;
                            
                            [self.tiles replaceObjectAtIndex:index2 withObject:tileOne];
                            [self.tiles replaceObjectAtIndex:index withObject:viewDragged];
                            
                            [UIView animateWithDuration:0.5
                                             animations:^ {
                                                 int finishedX = self.firstX;
                                                 int finishedY = self.firstY + self.tileHeight;
                                                 [[tileOne superview] setCenter:CGPointMake(finishedX, self.firstY + self.tileHeight * 2)];
                                                 [[viewDragged superview] setCenter:CGPointMake(finishedX, finishedY)];
                                                 self.tileCanBeDragged = NO;
                                                 self.finishDragging = NO;
                                             }
                                             completion:^(BOOL finished) {
                                                 // Check if the game has ended
                                                 // If it has ended, show an alert view
                                                 if([self.tileModel hasGameEnded]) {
                                                     UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Congratulations!"
                                                                                                     message:@"The puzzle is solved"
                                                                                                    delegate:nil
                                                                                           cancelButtonTitle:@"Ok"
                                                                                           otherButtonTitles:nil];
                                                     [alert show];
                                                     [alert release];
                                                 }
                                             }];
                        } else {
                            self.tileCanBeDragged = NO;
                            self.finishDragging = NO;
                            [UIView animateWithDuration:0.5
                                             animations:^ {
                                                 int finishedX = self.firstX;
                                                 int finishedY = self.firstY;
                                                 [[viewDragged superview] setCenter:CGPointMake(finishedX, finishedY)];
                                                 [[tileOne superview] setCenter:CGPointMake(finishedX, finishedY + self.tileHeight)];
                                             }
                                             completion:nil];
                        }
                        break;
                    }
                        
                    case DOWN: {
                        if(self.finishDragging) {
#ifdef DEBUG
                            NSLog(@"Board before = %@", self.tileModel.board);
#endif
                            // update the tile in the model
                            [self.tileModel moveTileWithXPos:viewDragged.currentXPosition
                                                        yPos:viewDragged.currentYPosition inDirection:DOWN];
#ifdef DEBUG
                            NSLog(@"Board after = %@", self.tileModel.board);
#endif
                            
                            // Move the tiles UP
                            int index = [self.tiles indexOfObject:viewDragged];
                            
                            // Update the tile (view)
                            viewDragged.currentYPosition += 1;
                            
                            [self.tiles replaceObjectAtIndex:index withObject:viewDragged];
                            
                            [UIView animateWithDuration:0.5
                                             animations:^ {
                                                 int finishedX = self.firstX;
                                                 int finishedY = self.firstY + self.tileHeight;
                                                 [[viewDragged superview] setCenter:CGPointMake(finishedX, finishedY)];
                                                 self.tileCanBeDragged = NO;
                                                 self.finishDragging = NO;
                                             }
                                             completion:^(BOOL finished) {
                                                 // Check if the game has ended
                                                 // If it has ended, show an alert view
                                                 if([self.tileModel hasGameEnded]) {
                                                     UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Congratulations!"
                                                                                                     message:@"The puzzle is solved"
                                                                                                    delegate:nil
                                                                                           cancelButtonTitle:@"Ok"
                                                                                           otherButtonTitles:nil];
                                                     [alert show];
                                                     [alert release];
                                                 }
                                             }];
                        } else {
                            self.tileCanBeDragged = NO;
                            self.finishDragging = NO;
                            [UIView animateWithDuration:0.5
                                             animations:^ {
                                                 int finishedX = self.firstX;
                                                 int finishedY = self.firstY;
                                                 [[viewDragged superview] setCenter:CGPointMake(finishedX, finishedY)];
                                             }
                                             completion:nil];
                        }
                        break;
                    }
                        
                    case THREELEFT: {
                        if(self.finishDragging) {
#ifdef DEBUG
                            NSLog(@"Board before = %@", self.tileModel.board);
#endif
                            // update the 3 tiles in the model
                            [self.tileModel moveTileWithXPos:tileTwo.currentXPosition yPos:tileTwo.currentYPosition inDirection:LEFT];
                            [self.tileModel moveTileWithXPos:tileOne.currentXPosition yPos:tileOne.currentYPosition inDirection:LEFT];
                            [self.tileModel moveTileWithXPos:viewDragged.currentXPosition
                                                        yPos:viewDragged.currentYPosition inDirection:LEFT];
#ifdef DEBUG
                            NSLog(@"Board after = %@", self.tileModel.board);
#endif
                            
                            // Move the tiles UP
                            int index = [self.tiles indexOfObject:viewDragged];
                            int index2 = [self.tiles indexOfObject:tileOne];
                            int index3 = [self.tiles indexOfObject:tileTwo];
                            
                            // Update the tile (view)
                            viewDragged.currentXPosition -= 1;
                            tileOne.currentXPosition -= 1;
                            tileTwo.currentXPosition -= 1;
                            
                            [self.tiles replaceObjectAtIndex:index3 withObject:tileTwo];
                            [self.tiles replaceObjectAtIndex:index2 withObject:tileOne];
                            [self.tiles replaceObjectAtIndex:index withObject:viewDragged];
                            
                            [UIView animateWithDuration:0.5
                                             animations:^ {
                                                 int finishedX = self.firstX - self.tileWidth;
                                                 int finishedY = self.firstY;
                                                 [[tileTwo superview] setCenter:CGPointMake(self.firstX - self.tileWidth * 3, finishedY)];
                                                 [[tileOne superview] setCenter:CGPointMake(self.firstX - self.tileWidth * 2, finishedY)];
                                                 [[viewDragged superview] setCenter:CGPointMake(finishedX, finishedY)];
                                                 self.tileCanBeDragged = NO;
                                                 self.finishDragging = NO;
                                             }
                                             completion:^(BOOL finished) {
                                                 // Check if the game has ended
                                                 // If it has ended, show an alert view
                                                 if([self.tileModel hasGameEnded]) {
                                                     UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Congratulations!"
                                                                                                     message:@"The puzzle is solved"
                                                                                                    delegate:nil
                                                                                           cancelButtonTitle:@"Ok"
                                                                                           otherButtonTitles:nil];
                                                     [alert show];
                                                     [alert release];
                                                 }
                                             }];
                        } else {
                            self.tileCanBeDragged = NO;
                            self.finishDragging = NO;
                            [UIView animateWithDuration:0.5
                                             animations:^ {
                                                 int finishedX = self.firstX;
                                                 int finishedY = self.firstY;
                                                 [[viewDragged superview] setCenter:CGPointMake(finishedX, finishedY)];
                                                 [[tileOne superview] setCenter:CGPointMake(finishedX - self.tileWidth, finishedY)];
                                                 [[tileTwo superview] setCenter:CGPointMake(finishedX - self.tileWidth * 2, finishedY)];
                                             }
                                             completion:nil];
                        }
                        break;
                    }
                        
                    case TWOLEFT: {
                        if(self.finishDragging) {
#ifdef DEBUG
                            NSLog(@"Board before = %@", self.tileModel.board);
#endif
                            // update the 2 tiles in the model
                            [self.tileModel moveTileWithXPos:tileOne.currentXPosition yPos:tileOne.currentYPosition inDirection:LEFT];
                            [self.tileModel moveTileWithXPos:viewDragged.currentXPosition
                                                        yPos:viewDragged.currentYPosition inDirection:LEFT];
#ifdef DEBUG
                            NSLog(@"Board after = %@", self.tileModel.board);
#endif
                            
                            // Move the tiles UP
                            int index = [self.tiles indexOfObject:viewDragged];
                            int index2 = [self.tiles indexOfObject:tileOne];
                            
                            // Update the tile (view)
                            viewDragged.currentXPosition -= 1;
                            tileOne.currentXPosition -= 1;
                            
                            [self.tiles replaceObjectAtIndex:index2 withObject:tileOne];
                            [self.tiles replaceObjectAtIndex:index withObject:viewDragged];
                            
                            [UIView animateWithDuration:0.5
                                             animations:^ {
                                                 int finishedX = self.firstX - self.tileWidth;
                                                 int finishedY = self.firstY;
                                                 [[tileOne superview] setCenter:CGPointMake(self.firstX - self.tileWidth * 2, finishedY)];
                                                 [[viewDragged superview] setCenter:CGPointMake(finishedX, finishedY)];
                                                 self.tileCanBeDragged = NO;
                                                 self.finishDragging = NO;
                                             }
                                             completion:^(BOOL finished) {
                                                 // Check if the game has ended
                                                 // If it has ended, show an alert view
                                                 if([self.tileModel hasGameEnded]) {
                                                     UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Congratulations!"
                                                                                                     message:@"The puzzle is solved"
                                                                                                    delegate:nil
                                                                                           cancelButtonTitle:@"Ok"
                                                                                           otherButtonTitles:nil];
                                                     [alert show];
                                                     [alert release];
                                                 }
                                             }];
                        } else {
                            self.tileCanBeDragged = NO;
                            self.finishDragging = NO;
                            [UIView animateWithDuration:0.5
                                             animations:^ {
                                                 int finishedX = self.firstX;
                                                 int finishedY = self.firstY;
                                                 [[viewDragged superview] setCenter:CGPointMake(finishedX, finishedY)];
                                                 [[tileOne superview] setCenter:CGPointMake(finishedX - self.tileWidth, finishedY)];
                                             }
                                             completion:nil];
                        }
                        break;
                    }
                        
                    case LEFT: {
                        if(self.finishDragging) {
#ifdef DEBUG
                            NSLog(@"Board before = %@", self.tileModel.board);
#endif
                            // update the tile in the model
                            [self.tileModel moveTileWithXPos:viewDragged.currentXPosition
                                                        yPos:viewDragged.currentYPosition inDirection:LEFT];
#ifdef DEBUG
                            NSLog(@"Board after = %@", self.tileModel.board);
#endif
                            
                            // Move the tiles UP
                            int index = [self.tiles indexOfObject:viewDragged];
                            
                            // Update the tile (view)
                            viewDragged.currentXPosition -= 1;
                            
                            [self.tiles replaceObjectAtIndex:index withObject:viewDragged];
                            
                            [UIView animateWithDuration:0.5
                                             animations:^ {
                                                 int finishedX = self.firstX - self.tileWidth;
                                                 int finishedY = self.firstY;
                                                 [[viewDragged superview] setCenter:CGPointMake(finishedX, finishedY)];
                                                 self.tileCanBeDragged = NO;
                                                 self.finishDragging = NO;
                                             }
                                             completion:^(BOOL finished) {
                                                 // Check if the game has ended
                                                 // If it has ended, show an alert view
                                                 if([self.tileModel hasGameEnded]) {
                                                     UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Congratulations!"
                                                                                                     message:@"The puzzle is solved"
                                                                                                    delegate:nil
                                                                                           cancelButtonTitle:@"Ok"
                                                                                           otherButtonTitles:nil];
                                                     [alert show];
                                                     [alert release];
                                                 }
                                             }];
                        } else {
                            self.tileCanBeDragged = NO;
                            self.finishDragging = NO;
                            [UIView animateWithDuration:0.5
                                             animations:^ {
                                                 int finishedX = self.firstX;
                                                 int finishedY = self.firstY;
                                                 [[viewDragged superview] setCenter:CGPointMake(finishedX, finishedY)];
                                             }
                                             completion:nil];
                        }
                        break;
                    }
                        
                    default:
                        break;
                }
            }
        }
            
        default:
            break;
    }
}

#pragma mark  - Can Move Tile
- (BOOL) canMoveTile:(DNTileView *) tile inDirection:(PossibleMoves) direction {
    switch (direction) {
        case UP: {
            if([self.tileModel canMoveTileWithXPos:tile.currentXPosition yPos:tile.currentYPosition andDirection:direction]) {
                // move the tile up
                [self moveSelectedTile:tile andDirection:direction];
                return YES;
            } else {
                int newY = tile.currentYPosition-1;
                if (newY < 0)
                    return NO;
                
                int indexOfTile = [[[self.tileModel.board objectAtIndex:tile.currentXPosition] objectAtIndex:newY] intValue];
                DNTileView* view = [self.tiles objectAtIndex:indexOfTile];
                
                if([self canMoveTile:view inDirection:direction]) {
                    [self moveSelectedTile:tile andDirection:direction];
                    return YES;
                }
            }
            
            return NO;
            break;
        }
            
        case RIGHT: {
            if([self.tileModel canMoveTileWithXPos:tile.currentXPosition yPos:tile.currentYPosition andDirection:direction]) {
                // move the tile up
                [self moveSelectedTile:tile andDirection:direction];
                return YES;
            } else {
                int newX = tile.currentXPosition+1;
                if(newX > 3)
                    return NO;
                
                int indexOfTile = [[[self.tileModel.board objectAtIndex:newX] objectAtIndex:tile.currentYPosition] intValue];
                DNTileView* view = [self.tiles objectAtIndex:indexOfTile];
                
                if([self canMoveTile:view inDirection:direction]) {
                    [self moveSelectedTile:tile andDirection:direction];
                    return YES;
                }
            }
            
            return NO;
            break;
        }
            
        case DOWN: {
            if([self.tileModel canMoveTileWithXPos:tile.currentXPosition yPos:tile.currentYPosition andDirection:direction]) {
                // move the tile up
                [self moveSelectedTile:tile andDirection:direction];
                return YES;
            } else {
                int newY = tile.currentYPosition+1;
                if(newY > 3)
                    return NO;
                
                int indexOfTile = [[[self.tileModel.board objectAtIndex:tile.currentXPosition] objectAtIndex:newY] intValue];
                DNTileView* view = [self.tiles objectAtIndex:indexOfTile];
                
                if([self canMoveTile:view inDirection:direction]) {
                    [self moveSelectedTile:tile andDirection:direction];
                    return YES;
                }
            }
                
            return NO;
            break;
        }
            
        case LEFT: {
            if([self.tileModel canMoveTileWithXPos:tile.currentXPosition yPos:tile.currentYPosition andDirection:direction]) {
                // move the tile up
                [self moveSelectedTile:tile andDirection:direction];
                return YES;
            } else {
                int newX = tile.currentXPosition-1;
                if(newX < 0)
                    return NO;
                
                int indexOfTile = [[[self.tileModel.board objectAtIndex:newX] objectAtIndex:tile.currentYPosition] intValue];
                DNTileView* view = [self.tiles objectAtIndex:indexOfTile];
                
                if([self canMoveTile:view inDirection:direction]) {
                    [self moveSelectedTile:tile andDirection:direction];
                    return YES;
                }
            }
            
            return NO;
            break;
        }
            
        default:
            break;
    }
    
    return NO;
}


#pragma mark - Move Tile
- (BOOL) moveSelectedTile:(DNTileView *) tile andDirection:(PossibleMoves) direction {
    
    // Check if the tile can be moved UP, DOWN, RIGHT, LEFT
    // If it can, then the model is udpated in the call automatically
    // move the tile appropriately
    
    switch (direction) {
        case UP: {
            // Update the model
            [self.tileModel moveTileWithXPos:tile.currentXPosition
                                        yPos:tile.currentYPosition inDirection:UP];
            
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
            
            return YES;
            break;
        }
            
        case RIGHT: {                
            // Update the model
            [self.tileModel moveTileWithXPos:tile.currentXPosition
                                        yPos:tile.currentYPosition inDirection:RIGHT];
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
            
            return YES;
            break;
        }
            
        case DOWN: {
            // Update the model
            [self.tileModel moveTileWithXPos:tile.currentXPosition
                                        yPos:tile.currentYPosition inDirection:DOWN];
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
            
            return YES;
            break;
        }
            
        case LEFT: {
            // Update the model
            [self.tileModel moveTileWithXPos:tile.currentXPosition
                                        yPos:tile.currentYPosition inDirection:LEFT];
            
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
            
            return YES;
            break;
        }
            
        default:
            break;
    }
    
    return NO;
}

#pragma mark - Animates the tile to location
- (void) animateTileToLocation:(DNTileView *) tile andDirection:(PossibleMoves)direction {
    UIView* parent = [tile superview];

    switch (direction) {
        case UP: {
            [UIView animateWithDuration:0.5
                             animations:^ {
                                 CGRect frame = parent.frame;
                                 frame.origin.y -= self.tileHeight;
                                 parent.frame = frame;
                             }
                             completion:^(BOOL finished) {                                 
                                 // Check if the game has ended
                                 // If it has ended, show an alert view
                                 if([self.tileModel hasGameEnded]) {
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
                                 frame.origin.x += self.tileWidth;
                                 parent.frame = frame;
                             }
                             completion:^(BOOL finished) {                                 
                                 // Check if the game has ended
                                 // If it has ended, show an alert view
                                 if([self.tileModel hasGameEnded]) {
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
                                 frame.origin.y += self.tileHeight;
                                 parent.frame = frame;
                             }
                             completion:^(BOOL finished) {                                 
                                 // Check if the game has ended
                                 // If it has ended, show an alert view
                                 if([self.tileModel hasGameEnded]) {
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
                                 frame.origin.x -= self.tileWidth;
                                 parent.frame = frame;
                             }
                             completion:^(BOOL finished) {                                 
                                 // Check if the game has ended
                                 // If it has ended, show an alert view
                                 if([self.tileModel hasGameEnded]) {
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

@end
