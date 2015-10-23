//
//  Constants.h
//  Wheelmap
//
//  Created by Michael Thomas on 14.01.13.
//  Copyright (c) 2013 Sozialhelden e.V. All rights reserved.
//

#define LastRunVersion			@"LastRunVersion"
#define InstallId				@"installId"

#define WheelMapTermsURL		@"http://blog.wheelmap.org/was-ist-wheelmap/terms/"
#define WheelMapDataTermsURL	@"http://blog.wheelmap.org/was-ist-wheelmap/privacy/"

#define FORGOT_PASSWORD_LINK	@"/users/password/new"
#define WEB_LOGIN_LINK			@"/users/auth/osm"
#define WM_REGISTER_LINK		@"/user/new"

#define OSM_URL					@"http://www.openstreetmap.org/"
#define ODBL_URL				@"http://opendatacommons.org/licenses/odbl/"

#define IS_OS_8_OR_LATER		([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
#define ODBL_URL				@"http://opendatacommons.org/licenses/odbl/"

#define K_MAP_ID				@"mbxMapID"
#define K_ACESSS_TOKEN			@"mbxAccessToken"

// ETags aren't working et the moment. If you enable ist, please check if they are sent valid from the backend
#define K_USE_ETAGS				NO

#define K_NAVIGATION_BAR_HEIGHT					44.0f
#define K_NAVIGATION_BAR_SEARCH_OFFSET			5.0f

#define K_TOOLBAR_BAR_HEIGHT					49.0f
#define K_TOOLBAR_BUTTONS_WITH					58.0f
#define K_TOOLBAR_TOOGLE_BUTTON_OFFSET			5.0f

#define K_TOOLBAR_WHEELCHAIR_STATUS_OFFSET		4.0f

#define K_ANIMATION_DURATION_SHORT				0.3f

#define K_DATA_KEY_ETAGS							@"eTags"

#define K_DB_KEY_CATEGORY_LOCALIZED_NAME			@"localized_name"