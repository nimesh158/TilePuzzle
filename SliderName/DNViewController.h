//
//  DNViewController.h
//  SliderName
//
//  Created by Nimesh on 2/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TileModel.h"

@interface DNViewController : UIViewController {
    
    // The button to start the game
    IBOutlet UIButton* startGame;
    
    // The board view
    IBOutlet UIView* boardView;
    
    // Keeps a track of all the tiles
    NSMutableArray* tiles;
    
    // The tile model object
    TileModel* tileModel;
}

@property (nonatomic, retain) UIButton* startGame;
@property (nonatomic, retain) UIView* boardView;
@property (nonatomic, retain) NSMutableArray* tiles;
@property (nonatomic, retain) TileModel* tileModel;

/**
    Starts the game 
*/
- (IBAction) startTheGame:(id)sender;

@end
