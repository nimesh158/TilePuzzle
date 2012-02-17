//
//  DNViewController.m
//  SliderName
//
//  Created by Nimesh on 2/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DNViewController.h"
#import "TileView.h"

@interface DNViewController (Private)
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
@end

@implementation DNViewController

@synthesize startGame, boardView, tiles, tileModel;

#pragma mark - Memory Mangement
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

- (void) dealloc {
    [self.tileModel release], tileModel = nil;
    [self.tiles release], tiles = nil;
    [self.boardView release], boardView = nil;
    [self.startGame release], startGame = nil;
    [super dealloc];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
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
    
    
    // Initialize the model of the board
    TileModel* model = [[TileModel alloc] init];
    self.tileModel = model;
    [model release];
    
    [self setupBoardForImage:@"Globe"];
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
#ifdef DEBUG
            NSLog(@"Tag = %d", tag);
#endif
//            if(i == self.tileModel.rowOfTileToBeEmpty &&
//               j == self.tileModel.columnOfTileToBeEmpty) {
//                continue;
//            }
            
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
            
            TileView* tileIV = [[TileView alloc] initWithImage:[self borderedTile:image]];
            tileIV.frame = CGRectMake(0, 0, boardImage.size.width/4.0, boardImage.size.width/4.0);
            
            [self.tiles addObject:tileIV];
            
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
                                                                        y * boardImage.size.width/4.0, boardImage.size.width/4.0, boardImage.size.width/4.0)];
            
            tileIV.winConditionPosition = tag;
            
            // Since there are 4 columns (0 -3) in every previous row, we multiply 3
            // to the current row and add it to the column which is then added to the row
            // to obtain
            // 0 4 8  12
            // 1 5 9  13
            // 2 6 10 14
            // 3 7 11 15
            // as the win condition
            
            tileIV.currentPosition = x + (y + x * 3);
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
    
    [boardImage release];
}

#pragma mark - Tap Gesture Recognizer
- (void) tileTapped:(UITapGestureRecognizer *)tapGesture {
    TileView* viewTapped = (TileView *)[self.tiles objectAtIndex:tapGesture.view.tag];
#ifdef DEBUG
    NSLog(@"Win Condition position of the tile tapped is = %d", viewTapped.winConditionPosition);
    NSLog(@"Current position of the tile tapped is = %d", viewTapped.currentPosition);
#endif
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

@end
