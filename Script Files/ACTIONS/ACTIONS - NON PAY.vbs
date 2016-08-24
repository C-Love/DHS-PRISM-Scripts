'GATHERING STATS---------------------------------------------------------------------
'name_of_script = "ACTIONS - NONPAY LTR.vbs"
'start_time = timer
'
'LOADING FUNCTIONS LIBRARY FROM GITHUB REPOSITORY===========================================================================
IF IsEmpty(FuncLib_URL) = TRUE THEN	'Shouldn't load FuncLib if it already loaded once
	IF run_locally = FALSE or run_locally = "" THEN	   'If the scripts are set to run locally, it skips this and uses an FSO below.
		IF use_master_branch = TRUE THEN			   'If the default_directory is C:\DHS-MAXIS-Scripts\Script Files, you're probably a scriptwriter and should use the master branch.
			FuncLib_URL = "https://raw.githubusercontent.com/MN-Script-Team/BZS-FuncLib/master/MASTER%20FUNCTIONS%20LIBRARY.vbs"
		Else											'Everyone else should use the release branch.
			FuncLib_URL = "https://raw.githubusercontent.com/MN-Script-Team/BZS-FuncLib/RELEASE/MASTER%20FUNCTIONS%20LIBRARY.vbs"
		End if
		SET req = CreateObject("Msxml2.XMLHttp.6.0")				'Creates an object to get a FuncLib_URL
		req.open "GET", FuncLib_URL, FALSE							'Attempts to open the FuncLib_URL
		req.send													'Sends request
		IF req.Status = 200 THEN									'200 means great success
			Set fso = CreateObject("Scripting.FileSystemObject")	'Creates an FSO
			Execute req.responseText								'Executes the script code
		ELSE														'Error message
			critical_error_msgbox = MsgBox ("Something has gone wrong. The Functions Library code stored on GitHub was not able to be reached." & vbNewLine & vbNewLine &_
                                            "FuncLib URL: " & FuncLib_URL & vbNewLine & vbNewLine &_
                                            "The script has stopped. Please check your Internet connection. Consult a scripts administrator with any questions.", _
                                            vbOKonly + vbCritical, "BlueZone Scripts Critical Error")
            StopScript
		END IF
	ELSE
		FuncLib_URL = "C:\BZS-FuncLib\MASTER FUNCTIONS LIBRARY.vbs"
		Set run_another_script_fso = CreateObject("Scripting.FileSystemObject")
		Set fso_command = run_another_script_fso.OpenTextFile(FuncLib_URL)
		text_from_the_other_script = fso_command.ReadAll
		fso_command.Close
		Execute text_from_the_other_script
	END IF
END IF
'END FUNCTIONS LIBRARY BLOCK================================================================================================


'case number dialog-
BeginDialog case_number_dialog, 0, 0, 176, 85, "Case number dialog"
  EditBox 60, 5, 75, 15, PRISM_case_number
  ButtonGroup ButtonPressed
    OkButton 70, 65, 50, 15
    CancelButton 125, 65, 50, 15
  Text 5, 10, 50, 10, "Case number:"
EndDialog
'NONPAY LTR DIAL0G -
BeginDialog NONPAY_LTR_DIALOG, 0, 0, 177, 106, "NONPAY LTR Dialog"
  ButtonGroup ButtonPressed
    PushButton 10, 20, 60, 10, "Non Pay Ltr", NonPay_button
    PushButton 10, 60, 100, 10, "Non Compliance w Pay Plan", PAPD_button
    CancelButton 0, 0, 0, 0
  Text 10, 40, 140, 20, "Send DL Non Compliance Ltr"
  Text 10, 0, 140, 20, "Send Nonpay Letter and E9685 CAAD"
  ButtonGroup ButtonPressed
    PushButton 10, 90, 70, 10, "Cancel", Cancel_button
EndDialog



'************FUNCTIONS **************************
FUNCTION send_non_compliance_dord
	CALL navigate_to_PRISM_screen("DORD")
	EMWriteScreen "A", 3, 29
	EMWriteScreen "        ", 4, 50
	EMWriteScreen "       ", 4, 59
	EMWriteScreen "F0919", 6, 36
	transmit
END FUNCTION


FUNCTION send_non_pay_memo
	CALL navigate_to_PRISM_screen("DORD")
	EMWriteScreen "A", 3, 29
	'-----Selecting the form
	EMWriteScreen "F0104", 6, 36
	'-----Selecting the recipient
	EMWriteScreen "NCP", 11, 51
	EMWriteScreen "        ", 4, 50
	EMWriteScreen "       ", 4, 59
	transmit

	EMSendKey "<PF14>"
	EMWaitReady 0, 0

	EMWriteScreen "U", 20, 14
	transmit

	dord_row = 7
	DO
		EMWriteScreen "S", dord_row, 5
		dord_row = dord_row + 1
	LOOP UNTIL dord_row = 19
	transmit

	EMWriteScreen "As you are aware, you have a court ordered obligation to     ", 16, 15
	transmit
	EMWriteScreen "pay child support. As of this date, it has been over 30 days", 16, 15
	transmit
	EMWriteScreen "since your last payment. All court ordered obligations must", 16, 15
	transmit
	EMWriteScreen "be paid during the month in which they are due. Failure to", 16, 15
	transmit
	EMWriteScreen "pay your court ordered support obligation can result in", 16, 15
	transmit
	EMWriteScreen "actions such as: suspension of driver's license, seizure", 16, 15
	transmit
	EMWriteScreen "of funds held in a financial institution, denial of", 16, 15
	transmit
	EMWriteScreen "passport, suspension of recreational licenses such as", 16, 15
	transmit
	EMWriteScreen "fishing and hunting, interception of tax refunds from the", 16, 15
	transmit
	EMWriteScreen "MN Department of Revenue and the IRS, suspension of any", 16, 15
	transmit
	EMWriteScreen "professional license you may hold, reporting of your arrears", 16, 15
	transmit
	EMWriteScreen "balance to the major credit reporting agencies and/or", 16, 15
	transmit
	transmit

	dord_row = 7
	DO
		EMWriteScreen "S", dord_row, 5
		dord_row = dord_row + 1
	LOOP UNTIL dord_row = 13
	transmit

	EMWriteScreen "possible court action for non-payment of support. Please", 16, 15
	transmit
	EMWriteScreen "contact me immediately to discuss your employment status", 16, 15
	transmit
	EMWriteScreen "or sources of income. To avoid further delinquency, please", 16, 15
	transmit
	EMWriteScreen "make a payment today. If you have questions or concerns", 16, 15
	transmit
	EMWriteScreen "regarding your support obligation, please contact me at the", 16, 15
	transmit
	EMWriteScreen "number listed below.", 16, 15
	transmit

	PF3

	EMWriteScreen "M", 3, 29
	transmit

	PF9
	PF3
END FUNCTION

FUNCTION add_caad_code(CAAD_code)
	CALL navigate_to_PRISM_screen("CAAD")
	PF5
	EMWriteScreen CAAD_code, 4, 54
END FUNCTION

'***************************

'Connecting to BlueZone
EMConnect ""
CALL check_for_PRISM(True)
call PRISM_case_number_finder(PRISM_case_number)


'Case number display dialog
Do

	Dialog case_number_dialog
	If buttonpressed = 0 then stopscript
	call PRISM_case_number_validation(PRISM_case_number, case_number_valid)
	If case_number_valid = False then MsgBox "Your case number is not valid. Please make sure it uses the following format: ''XXXXXXXXXX-XX''"
Loop until case_number_valid = True

	Do
		EMReadScreen PRISM_check, 5, 1, 36
		If PRISM_check <> "PRISM" then MsgBox "You appear to have timed out, or are out of PRISM. Navigate to PRISM and try again."
	Loop until PRISM_check = "PRISM"
	Dialog NONPAY_LTR_DIALOG


	IF ButtonPressed = Cancel_button THEN stopscript
	If ButtonPressed = NonPay_button then
		CALL send_non_pay_memo
		purge_msg = MsgBox ("Do you want to purge E0002 worklist item?", vbYesNo)
		IF purge_msg = vbYes THEN
			CALL navigate_to_PRISM_screen("CAWT")
			Do
				CALL write_value_and_transmit("E0002", 20, 29)
				EMReadscreen worklist_check, 5, 8, 8
				If worklist_check = "E0002" then
					EMWriteScreen "P", 8, 4
					transmit
					transmit
					PF3
				end if
			Loop until worklist_check <> "E0002"
		END IF
		CALL add_caad_code("E9685")
		script_end_procedure("The script has sent the requested DORD document and is now waiting for you to transmit to confirm the CAAD Note.")
	End If
	If ButtonPressed = PAPD_button then
		CALL send_non_compliance_dord
		purge_msg = MsgBox ("Do you want to purge E4111 worklist item?", vbYesNo)
		IF purge_msg = vbYes THEN
			CALL navigate_to_PRISM_screen("CAWT")
			Do
				CALL write_value_and_transmit("E4111", 20, 29)
				EMReadScreen worklist_check, 5, 8, 8
				If worklist_check = "E4111" then
					EMWriteScreen "P", 8, 4
					transmit
					transmit
					PF3
				End if
			Loop until worklist_check <> "E4111"
		END IF
		script_end_procedure("The script has sent the requested DORD document.")
	END IF
