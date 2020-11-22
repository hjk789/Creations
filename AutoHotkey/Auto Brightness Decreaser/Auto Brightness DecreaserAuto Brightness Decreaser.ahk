/*
	Auto Brightness Decreaser - v1.0
	Created by BLBC (github.com/hjk789)
	Copyright (c) 2020+ BLBC
*/

#SingleInstance force
#Persistent
ListLines off

;***************
global startHour := 19
;***************

#include %A_ScriptDir%\Monitor Class.ahk				; Using the Monitor Class created by jNizM (https://raw.githubusercontent.com/jNizM/Class_Monitor/master/src/Class_Monitor.ahk).

OnExit("ExitEvent")							; Run the ExitEvent function below when the script exits for any reason, including when the system is shutdown.

global currBrightness := Monitor.GetBrightness().Current
global currGammaRamp  := Monitor.GetGammaRamp()["Red"]
;contrastValue := Monitor.GetContrast().Current				; If you want to make the screen even darker, you can also decrease the contrast, but just the brightness and gamma already make it dark enough.

if (((A_Hour == startHour && A_Min > 2) || A_Hour > startHour || A_Hour >= 0 && A_Hour <= 7) && currGammaRamp >= 128)		; If the script for some reason is started late (like when Windows is started at night), decrease all the missed minutes at once.
{
	if (A_Hour < startHour)						; If the script is started after midnight, count since the previous day.
	{
		day := a_now
		day += -1, days						; Subtract one day from the current date.
		formatTime, day, %day%, dd				; Get only the day from the resulting full date.
	}
	else day := a_dd

	timeDifferenceInMinutes := getDistanceToStartTime("minutes", day)
	decreasingsToBeMade := timeDifferenceInMinutes / 2

	loop % decreasingsToBeMade
		decreaseBrightnessOrGammaByOne()
}
else									; Otherwise, if the script was started before the startHour ...
	sleep, % getDistanceToStartTime("seconds") * 1000 * -1		; ... wait until the startHour.


loop
{
	if (decreaseBrightnessOrGammaByOne())
		sleep 120000  ; 2 minutes
	else 
		break
}




getDistanceToStartTime(timeScale, day := "")
{
	if (day == "")
		day := a_dd

	startTime := a_yyyy . a_mm . day . startHour . 00 . 00
	now := a_now
	now -= startTime , %timeScale%
	timeDifference := now
	
	return timeDifference
}


decreaseBrightnessOrGammaByOne()
{
	if (currBrightness > 5)			; A brightness value lower than 5 or a gamma ramp value lower than 15 causes eye strain.
		Monitor.SetBrightness(--currBrightness)
	else
	{
		if (currGammaRamp > 15)
		{
			currGammaRamp--
			Monitor.SetGammaRamp(currGammaRamp, currGammaRamp, currGammaRamp)
		}
		else return false		; After 5 hours and 16 minutes, or 158 decreasings, exit the loop and wait for the shutdown.
	}
	
	return true
}


ExitEvent(reason, code)
{
	if (reason == "Shutdown")		; The GammaRamp is automatically reset by rebooting, but the brightness is permanent. 
		Monitor.SetBrightness(50)	; This resets the brightness to the original value. It's better to do this on shutdown than on startup.
}
