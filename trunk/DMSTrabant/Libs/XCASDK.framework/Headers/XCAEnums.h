//
//  XCAEnums.h
//  XCA
//
//  Created by Bernhard Ehringer on 09.01.14.
//  Copyright (c) 2014 xyzmo Software GmbH. All rights reserved.
//

/*!
 @abstract The GUI element types.
 */
typedef enum {
	kUIButton,
	kUISwitch,
	kUIView,
	kUIImageView,
	kUIToolbar,
	kUIToolbarButton,
	kUILabel,
	kUISlider,
	kUINavigationBar,
	kUIBarButtonItem
} XCAControlType;

/*!
 @abstract The GUI element's places.
 */
typedef enum {
	kXCAMainToolbar,
	kXCAMainView,
	kXCASignatureView,
	kXCAHelpScreen,
	kXCAOfflineWsPicker,
	kXCADocumentList,
	kXCATaskList,
	kXCAEntireApp,
	kXCALicenseScreen,
	kXCASettingsList,
	kXCASyncStateList,
	kXCAMenuBar,
	kXCADocumentView,
	kXCAFreeHandToolbar,
	kXCAPictureAnnotationToolbar
} XCAControlPlace;

/*!
 @abstract The font styles.
 */
typedef enum {
	kXCAFontRegular,
	kXCAFontBold,
	kXCAFontItalic
} XCAFontStyle;

/*!
 @abstract The color types.
 */
typedef enum {
	kXCAMainTintColor,
	kXCAViewBackgroundColor,
	kXCANavBarTintColor,
	kXCANavBarTitleTextColor,
	kXCANavBarBackgroundColor,
	kXCATabBarTintColor,
	kXCATabBarBackgroundColor,
	kXCAToolbarTintColor,
	kXCAToolbarTitleTextColor,
	kXCAToolbarBackgroundColor,
	kXCATableViewBackgroundColor,
	kXCATableViewCellBackgroundColor,
	kXCATableViewCellSelectedBackgroundColor,
	kXCATableViewCellTitleColor,
	kXCAFormFieldDisabledBackgroundColor,
	kXCAFormFieldFocusedBackgroundColor,
	kXCAFormFieldEmptyBackgroundColor,
	kXCAFormFieldDefaultBackgroundColor,
	kXCAFormFieldDisabledBorderColor,
	kXCAFormFieldRequiredBorderColor,
	kXCAFormFieldDefaultBorderColor
} XCAColorType;

/*!
 @abstract The hint element types.
 */
typedef enum {
	kXCAImportHelp
} XCAHintType;
