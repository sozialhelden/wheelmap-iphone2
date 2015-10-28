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

// WMConfig

#define WM_CONFIG_FILENAME							[[NSBundle mainBundle] objectForInfoDictionaryKey:@"WMConfigFilename"]
#define WM_CONFIG									[[NSDictionary alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:WM_CONFIG_FILENAME ofType:nil]]

#define K_MBX_TOKEN									WM_CONFIG[@"mbxAccessToken"]
#define K_MBX_MAP_ID								WM_CONFIG[@"mbxMapID"]
#define K_HOCKEY_APP_ID								WM_CONFIG[@"hockeyAppId"]
#define K_API_KEY									WM_CONFIG[@"appAPIKey"]
#define K_API_BASE_URL								WM_CONFIG[@"apiBaseURL"]

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

#define K_WHEELCHAIR_STATE_UNKNOWN					@"unknown"
#define K_WHEELCHAIR_STATE_LIMITED					@"limited"
#define K_WHEELCHAIR_STATE_YES						@"yes"
#define K_WHEELCHAIR_STATE_NO						@"no"

