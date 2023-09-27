//
//  RootViewController.h
//  Cocos Hello World
//
//  Created by mad4chip on 06/06/12.
//  Copyright __MyCompanyName__ 2012. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface RootViewController : UIViewController
{
	UIInterfaceOrientation	currentOrientation;
}

//ANC Mod
@property (readonly, nonatomic) UIInterfaceOrientation	currentOrientation;

@end
