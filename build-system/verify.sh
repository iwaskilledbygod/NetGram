#!/bin/bash

export TELEGRAM_ENV_SET="1"

export DEVELOPMENT_CODE_SIGN_IDENTITY="iPhone Distribution: Digital Fortress LLC (C67CF9S4VU)"
export DISTRIBUTION_CODE_SIGN_IDENTITY="iPhone Distribution: Digital Fortress LLC (C67CF9S4VU)"
export DEVELOPMENT_TEAM="C67CF9S4VU"

export API_ID="8"
export API_HASH="7245de8e747a0d6fbe11f7cc14fcc0bb"

export BUNDLE_ID="ios.NetGram.pvpsoldier"
export IS_INTERNAL_BUILD="false"
export IS_APPSTORE_BUILD="true"
export APPSTORE_ID="686449807"
export APP_SPECIFIC_URL_SCHEME="tgapp"
export PREMIUM_IAP_PRODUCT_ID="org.telegram.telegramPremium.monthly"

if [ -z "$BUILD_NUMBER" ]; then
	echo "BUILD_NUMBER is not defined"
	exit 1
fi

export DEVELOPMENT_PROVISIONING_PROFILE_APP="match Development ios.NetGram.pvpsoldier"
export DISTRIBUTION_PROVISIONING_PROFILE_APP="match AppStore ios.NetGram.pvpsoldier"
export DEVELOPMENT_PROVISIONING_PROFILE_EXTENSION_SHARE="match Development ios.NetGram.pvpsoldier.Share"
export DISTRIBUTION_PROVISIONING_PROFILE_EXTENSION_SHARE="match AppStore ios.NetGram.pvpsoldier.Share"
export DEVELOPMENT_PROVISIONING_PROFILE_EXTENSION_WIDGET="match Development ios.NetGram.pvpsoldier.Widget"
export DISTRIBUTION_PROVISIONING_PROFILE_EXTENSION_WIDGET="match AppStore ios.NetGram.pvpsoldier.Widget"
export DEVELOPMENT_PROVISIONING_PROFILE_EXTENSION_NOTIFICATIONSERVICE="match Development ios.NetGram.pvpsoldier.NotificationService"
export DISTRIBUTION_PROVISIONING_PROFILE_EXTENSION_NOTIFICATIONSERVICE="match AppStore ios.NetGram.pvpsoldier.NotificationService"
export DEVELOPMENT_PROVISIONING_PROFILE_EXTENSION_NOTIFICATIONCONTENT="match Development ios.NetGram.pvpsoldier.NotificationContent"
export DISTRIBUTION_PROVISIONING_PROFILE_EXTENSION_NOTIFICATIONCONTENT="match AppStore ios.NetGram.pvpsoldier.NotificationContent"
export DEVELOPMENT_PROVISIONING_PROFILE_EXTENSION_INTENTS="match Development ios.NetGram.pvpsoldier.SiriIntents"
export DISTRIBUTION_PROVISIONING_PROFILE_EXTENSION_INTENTS="match AppStore ios.NetGram.pvpsoldier.SiriIntents"
export DEVELOPMENT_PROVISIONING_PROFILE_WATCH_APP="match Development ios.NetGram.pvpsoldier.watchkitapp"
export DISTRIBUTION_PROVISIONING_PROFILE_WATCH_APP="match AppStore ios.NetGram.pvpsoldier.watchkitapp"
export DEVELOPMENT_PROVISIONING_PROFILE_WATCH_EXTENSION="match Development ios.NetGram.pvpsoldier.watchkitapp.watchkitextension"
export DISTRIBUTION_PROVISIONING_PROFILE_WATCH_EXTENSION="match AppStore ios.NetGram.pvpsoldier.watchkitapp.watchkitextension"

BUILDBOX_DIR="buildbox"

export CODESIGNING_PROFILES_VARIANT="appstore"

$@
