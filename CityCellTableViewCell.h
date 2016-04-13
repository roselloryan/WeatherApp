//
//  CityCellTableViewCell.h
//  Weather App


#import <UIKit/UIKit.h>


@interface CityCellTableViewCell : UITableViewCell

@property (weak, nonatomic, nullable) IBOutlet UILabel *cityNameLabel;
@property (weak, nonatomic, nullable) IBOutlet UILabel *tempLabel;

-(nonnull instancetype)initWithCoder:(nullable NSCoder *)aDecoder;


@end
