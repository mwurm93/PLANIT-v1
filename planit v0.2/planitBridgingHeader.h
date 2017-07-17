//
//  planitBridgingHeader.h
//  planit v0.2
//
//  Created by MICHAEL WURM on 7/17/17.
//  Copyright © 2017 MICHAEL WURM. All rights reserved.
//

#import "MaplyComponent.h"
#import "MaplyBaseViewController.h"
#import "WhirlyGlobeViewController.h"
#import "MaplyViewController.h"

#import <AviasalesSDK/AviasalesSDK.h>
#import <HotellookSDK/HotellookSDK.h>

#import "Source/JRDefines.h"
#import "Source/JRHeader.h"
#import "Source/Config.h"
//#import "JRAppDelegate.h"
#import "Source/JRAppLauncher.h"


#import "Source/CommonSource/JRNavigationController/JRNavigationController.h"
#import "Source/CommonSource/StringUtils.h"
#import "Source/CommonSource/ColorManagment/JRColorScheme.h"
#import "Source/CommonSource/About/HLProfileVC.h"
#import "Source/CommonSource/About/Items/HLProfileCurrencyItem.h"
#import "Source/CommonSource/About/Cells/HLProfileCell.h"


#import "Source/Utils/JRDateUtil/DateUtil.h"
#import "Source/Utils/JRPriceUtils.h"
#import "Source/Utils/JRSearchInfoUtils/JRSearchInfoUtils.h"

#import "Source/HotelsSource/SearchVC/HLSearchVC.h"
#import "Source/HotelsSource/SearchVC/HLIpadSearchVC.h"
#import "Source/HotelsSource/HLVariantsManager.h"
#import "Source/HotelsSource/Objects/HLResultVariant.h"
#import "Source/HotelsSource/Filters/HLVariantsSorter.h"
#import "Source/HotelsSource/Filters/HLFilter.h"
#import "Source/HotelsSource/SearchVC/WaitingScreen/Results/Placeholders/HLPlaceholderView.h"
#import "Source/HotelsSource/SearchVC/WaitingScreen/Results/ActionCards/ActionCardsManager/HLActionCardsManager.h"
#import "Source/HotelsSource/SearchVC/WaitingScreen/Results/Iphone/HLVariantScrollablePhotoCell.h"
#import "Source/HotelsSource/HDKDefaultsSaver+Hotellook.h"
#import "Source/HotelsSource/NSObject+Notifications.h"
#import "Source/HotelsSource/UIColor/UIColor+Hex.h"
#import "Source/HotelsSource/NotificationDefines.h"
#import "Source/HotelsSource/AutolayoutViews/HLAutolayoutCollectionViewCell.h"
//#import "HLActionCardsManager.h"
#import "Source/HotelsSource/HLPoiManager.h"
#import "Source/HotelsSource/SearchVC/WaitingScreen/Results/ActionCards/Cells/HLResultCardCell.h"
#import "Source/HotelsSource/Controls/HLRangeSlider.h"
#import "Source/HotelsSource/AutolayoutViews/HLAutolayoutView.h"
#import "Source/HotelsSource/Utils/HLUrlUtils.h"
#import "Source/HotelsSource/Filters/HLDistanceCalculator.h"
#import "Source/HotelsSource/Filters/SliderCalculator/HLSliderCalculator.h"
#import "Source/HotelsSource/HLLocationManager.h"
#import "Source/HotelsSource/SearchVC/WaitingScreen/Results/ActionCards/Cells/ActionCardsCells.h"
#import "Source/HotelsSource/Map/HLIphoneMapVC.h"
#import "Source/HotelsSource/Utils/HLCommonVC.h"
#import "Source/HotelsSource/AutolayoutViews/HLAutolayoutCell.h"
#import "Source/HotelsSource/Filters/PointSelectionVC/PointSelectionDelegate.h"
#import "Source/HotelsSource/Controls/HLPanGestureRecognizer.h"
#import "Source/HotelsSource/Map/HLMapVC.h"
#import "Source/HotelsSource/Map/MapViews/HLMapView.h"
#import "Source/HotelsSource/Map/POI/HLPoiIconSelector.h"
#import "Source/HotelsSource/CityLoaders/HLNearbyCitiesDetector.h"
#import "Source/HotelsSource/HLHotelsManager.h"
#import "Source/HotelsSource/HotelDetails/Cells/HLShowMorePricesCell.h"
#import "Source/HotelsSource/Alerts/HLAlertsFabric.h"
#import "Source/HotelsSource/Browser/HLWebBrowser.h"
#import "Source/HotelsSource/Sharing/HLUrlShortener.h"
#import "Source/HotelsSource/MapGroupDetails/HLMapGroupDetailsVC.h"

#import "Source/HotelsSource/Utils/HLLocaleInspector.h"
#import "Source/HotelsSource/Controls/HLDeceleratingProgressAnimator.h"
#import "Source/HotelsSource/Utils/MailSender/HLEmailSender.h"
#import "Source/HotelsSource/Utils/NSError+HLCustomErrors.h"
#import "Source/HotelsSource/Utils/HLDefaultCitiesFactory.h"
#import "Source/HotelsSource/Filters/FilterCellFactories/FilterCells/ChooseSelectionDelegate.h"
#import "Source/HotelsSource/Filters/FiltersVCDelegate.h"

#import "Source/Categories/NSString+HLSizeCalculation.h"
#import "Source/Categories/UIViewController+JRAddChildViewController/UIViewController+JRAddChildViewController.h"
#import "Source/Categories/ReuseIdentifiers/UIViewCell+ReuseIdentifier.h"
#import "Source/Categories/UIImage+JRUIImage/UIImage+JRUIImage.h"
#import "Source/Categories/ReuseIdentifiers/Collections+HLNibLoading.h"
#import "Source/Categories/NSArray+HLContentComparison/NSArray+HLContentComparison.h"
#import "Source/Categories/UIView+Nib/UIView+Nib.h"
#import "Source/Categories/UIScrollView+ScrollableArea.h"
#import "Source/Categories/NSString+HLCapitalization.h"
#import "Source/Categories/UINavigationController+Additions/UINavigationController+Additions.h"
#import "Source/Categories/MKMapView+ZoomLevel/MKMapView+Zoom.h"
#import "Source/Categories/NSLayoutConstraint+JRConstraintMake/NSLayoutConstraint+JRConstraintMake.h"

#import "Source/AviasalesSource/SearchForm/ASTContainerSearchFormViewController.h"
#import "Source/AviasalesSource/SearchForm/ASTSearchFormSceneViewController.h"
#import "Source/AviasalesSource/SearchResults/JRSearchResultsVC.h"
#import "Source/AviasalesSource/JRFilters/JRFilter/JRFilter.h"
#import "Source/AviasalesSource/JRFilters/JRFilterVC.h"
#import "Source/AviasalesSource/JRTicket/JRTicketVC.h"
#import "Source/AviasalesSource/JRAirportPicker/JRAirportPickerCellWithInfo.h"

#import "Source/Advertisement/JRAdvertisementManager.h"
#import "Source/Advertisement/JRAdvertisementManager.h"

#import <PureLayout/PureLayout.h>
