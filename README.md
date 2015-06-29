ipa-resigner
===

This script resign an IPA for AppStore Deployment or Adhoc Deployment. Is compatible with Swift Code.

#Usage
 1. Import the certificate in the Keychain
 2. Generate a provisioning profile por Adhoc o AppStore Desployment
 3. Run the script:
	sh resign.sh /path/to/ipa /path/to/provisioning_profile Adhoc:YES|NO

####Example for Adhoc Resign:
	sh resign.sh MyApp.ipa Adhoc_deployment.mobileprovision YES
####Example for AppStore Resign:
	sh resign.sh MyApp.ipa AppStore_deployment.mobileprovision NO

##Requirements
- OSX Mavericks or Yosemite
- Xcode 6+
- Xcode command line tools

#License
This script is distributed in terms of LGPL license. See http://www.gnu.org/licenses/lgpl.html for more details.
