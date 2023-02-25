; update_paneldue.g  **** requires RRF firmware version 3.2rc4  or higher to work. ****

if fileexists("0:/firmware/PanelDueFirmware.bin")

	M291 R"PanelDue Upgrade" P"New firmware has been detected. OK to update?" S3
	M997 S4 ; update panel due firmware - file "PanelDueFirmware.bin" must exist in 0:/firmware/
	if result = 0
		G4 S6 ; wait for paneldue reboot
		M291 R"Update complete" P"Update successful, Press OK to delete update file & reboot in 5 seconds" S3
		M30 "0:/firmware/PanelDueFirmware.bin" ; delete update file
		if result = 0
			echo "File deleted"
		else
			echo "File could not be deleted"
		echo "Rebooting in 5 seconds"
		G4 S5 ; wait 5 seconds before reboot
		M999 ; software reboot
	elif result = 1
		M291 R"Update Suspect" P"Update returned a warning code, Press OK to reboot in 5 seconds" S3
		G4 S5 ; wait 5 seconds before reboot
		M999 ; software reboot
	elif result = 2
		M291 R"Update Failed" P"Update failed,  Press OK to reboot in 5 seconds" S3
		G4 S5 ; wait 5 seconds before reboot
		M999 ; software reboot

else
	M291 R"PanelDue Upgrade" P"PanelDueFirmware.bin not found in 0:/firmware/ directory.  Cannot perform update" S2 T6
