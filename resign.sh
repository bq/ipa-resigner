#!/bin/bash
IPA=$1
PROVISIONING_PROFILE=$2
ADHOC=$3

if [ "$IPA" == "" ];
then
    echo "Usage: sh resign.sh ipa_path provisioning_path [adhoc_signing:YES|NO]"
    exit 1
fi

if [ "$ADHOC" == "" ];
then
    ADHOC="NO"
fi

if [ ! -f "$IPA" ];
then
    echo "Cannot find IPA, given path: ${IPA}"
    exit 1
fi  

if [ ! -f "$PROVISIONING_PROFILE" ];
then
    echo "Cannot find Provisioning profile, given path: ${PROVISIONING_PROFILE}"
    exit 1
fi  

#UNZIP
if [ -d ipa_content ]
then
	rm -rf ipa_content
fi 
unzip ${IPA} -d ipa_content

#Analysis
echo
echo "Analysing data..."
PROVISIONING_PROFILE_DECRYPTED="${PROVISIONING_PROFILE}.plist"
security cms -D -i "${PROVISIONING_PROFILE}" > "${PROVISIONING_PROFILE_DECRYPTED}"

APP_NAME=$(ls -1 ipa_content/Payload)
echo "APP Name: ${APP_NAME}"
TEAM_IDENTIFIER=$(/usr/libexec/Plistbuddy -c "Print :TeamIdentifier:0" "${PROVISIONING_PROFILE_DECRYPTED}")
echo "Team Identifier: ${TEAM_IDENTIFIER}"
APPLICATION_IDENTIFIER_PREFIX=$(/usr/libexec/Plistbuddy -c "Print :ApplicationIdentifierPrefix:0" "${PROVISIONING_PROFILE_DECRYPTED}")
echo "Application Identifier Prefix: ${APPLICATION_IDENTIFIER_PREFIX}"
SIGNING_IDENTITY=$(security find-identity -p codesigning -v | grep "${TEAM_IDENTIFIER}" | head -n1 | cut -d "\"" -f 2)
echo "Signing Identity: ${SIGNING_IDENTITY}"
BUNDLE_IDENTIFIER=$(/usr/libexec/Plistbuddy -c "Print :CFBundleIdentifier" ipa_content/Payload/${APP_NAME}/Info.plist)
echo "Bundle Identifier: ${BUNDLE_IDENTIFIER}"
echo

/bin/rm "${PROVISIONING_PROFILE_DECRYPTED}"
#End Analysis

#CLEANING
rm -rf ipa_content/Payload/${APP_NAME}/_CodeSignature/
rm -f ipa_content/Payload/${APP_NAME}/embedded.mobileprovision 

#NEW IDENTITY
cp ${PROVISIONING_PROFILE} ipa_content/Payload/${APP_NAME}/embedded.mobileprovision
APP_ENTITLEMENTS="Entitlements.plist"
if [ -f ${APP_ENTITLEMENTS} ]
then
	rm -f ${APP_ENTITLEMENTS}
fi 
/usr/libexec/PlistBuddy -c "Add :application-identifier string ${APPLICATION_IDENTIFIER_PREFIX}.${BUNDLE_IDENTIFIER}" "${APP_ENTITLEMENTS}"
if [ ${ADHOC} == "NO" ]
then
	/usr/libexec/PlistBuddy -c "Add :beta-reports-active bool true" "${APP_ENTITLEMENTS}"
fi
/usr/libexec/PlistBuddy -c "Add :get-task-allow bool false" "${APP_ENTITLEMENTS}"
/usr/libexec/PlistBuddy -c "Add :keychain-access-groups array" "${APP_ENTITLEMENTS}"
/usr/libexec/PlistBuddy -c "Add :keychain-access-groups:0 string ${APPLICATION_IDENTIFIER_PREFIX}.${BUNDLE_IDENTIFIER}" "${APP_ENTITLEMENTS}"
cp "${APP_ENTITLEMENTS}" "ipa_content/Payload/${APP_NAME}/archived-expanded-entitlements.xcent"

#RESINGING
echo "Resigning the app with identity: ${SIGNING_IDENTITY}"
if [ -d "ipa_content/Payload/${APP_NAME}/Frameworks" ];
then        
    for SWIFT_LIB in $(ls -1 ipa_content/Payload/${APP_NAME}/Frameworks); do 
        codesign --force --sign "${SIGNING_IDENTITY}" --verbose "ipa_content/Payload/${APP_NAME}/Frameworks/${SWIFT_LIB}"
    done
fi
codesign --force --entitlements "${APP_ENTITLEMENTS}" --sign "${SIGNING_IDENTITY}" "ipa_content/Payload/${APP_NAME}" --verbose  
codesign --verify --verbose --deep --no-strict "ipa_content/Payload/${APP_NAME}"   

#PACKAGING
IPA_RESIGNED="RESIGNED_${APP_NAME}.ipa"
cd ipa_content
zip --symlinks --verbose --recurse-paths ../${IPA_RESIGNED} .

echo
echo "***************************"
echo
if [ ${ADHOC} == "NO" ]
then
    echo "IPA succesfully signed for AppStore Distribution. This binary is not compatible for AdHoc Deployment."
else
    echo "IPA succesfully signed for AdHoc Distribution. This binary is not compatible for AppStore Deployment."
fi

echo 
echo "Result IPA: ${IPA_RESIGNED}"
echo
echo "***************************"
echo
