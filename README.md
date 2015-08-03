ipa-resigner
===

This script resigns an IPA for AppStore or Adhoc Deployment. 
It is compatible with Swift Code.

##Requirements
- Mac with OSX Yosemite (or later)
- Xcode 6 (or later)
- Xcode command line tools
- A valid developer account with the iOS Developer Program

##Usage
 1. Generate one distribution certificate in the member center (http://developer.apple.com -> `Member Center` -> `Certificates, Identifiers & Profiles`) 
 2. Import the new certificate in the Keychain of your Mac: be sure to keep the Keychain clean and remove old certificates.
    1. Open the `Keychain Access` app in your mac and choose `Import item` in the login keychain
 3. Generate the proviosining profile for the previous certificate.
    1. In the `Member Center` create a new provisioning profile for AppStore Distribution. In case you want to install the new IPA through iTunes in your devices, remember that you should use an Adhoc provisioning profile.
    2. Download the new file (i.e. the previously provisioning profile generated) and store it in a known location of your Mac
 4. Run the script with the following parameters:  
	`sh resign.sh /path/to/ipa /path/to/provisioning_profile`

####Example for Adhoc Resign:
	sh resign.sh MyApp.ipa Adhoc_deployment.mobileprovision
####Example for AppStore Resign:
	sh resign.sh MyApp.ipa AppStore_deployment.mobileprovision


#License
This script is distributed in terms of LGPL license. See http://www.gnu.org/licenses/lgpl.html for more details.
