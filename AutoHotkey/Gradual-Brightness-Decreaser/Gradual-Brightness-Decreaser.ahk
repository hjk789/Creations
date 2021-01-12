/*
    Gradual Brightness Decreaser - v1.2
    Created by BLBC (github.com/hjk789)
    Copyright (c) 2020+ BLBC
*/


;*********** SETTINGS ***********

startHour :=  19                  ; The hour of day that the script will start to work, in 24-hour format.
blueLightFilterEnabled :=  true   ; Whether the script should also gradually change the screen's gamma colors to a warm tone. To use it, change it to true.
desiredBrightness :=  5           ; The destination brightness to be decreased to. This value should be in the 0-100 range. This doesn't affect colors, only the monitor's light.
desiredGammaIlluminance :=  143   ; The destination gamma illuminance to be decreased to. This value should be in the 0-255 range. This affects images' brightness. If you set this to 0 the screen will turn completely black.
monitorStandbyTimeout :=  10      ; The idle time in minutes needed for the monitor to enter in standby. The number of minutes need to match the one set in your power plan settings. This is needed for cases where the gamma is reset after entering standby.
decreasingsInterval :=  120       ; The time interval in seconds between each decreased brightness or gamma value. A lower value makes the script finish in less time, but the brightness and color shift becomes more noticeable.

;********************************


#SingleInstance force
#Persistent
ListLines off

#include %A_ScriptDir%\Class_Monitor.ahk                            ; Using the Monitor Class created by jNizM (https://raw.githubusercontent.com/jNizM/Class_Monitor/master/src/Class_Monitor.ahk).

OnExit("ExitEvent")                                                 ; Run the ExitEvent function when the script exits for any reason, including when the system is shutdown.

origBrightness := Monitor.GetBrightness().Current
currBrightness := origBrightness
currGammaRed   := Monitor.GetGammaRamp()["Red"]
currGammaGreen := Monitor.GetGammaRamp()["Green"]
currGammaBlue  := Monitor.GetGammaRamp()["Blue"]
;contrastValue := Monitor.GetContrast().Current                     ; If you want to make the screen even darker, you can also decrease the contrast, but just the brightness and gamma already make it dark enough.
idle := false

monitorStandbyTimeout := monitorStandbyTimeout * 60 * 1000
decreasingsInterval   := decreasingsInterval * 1000
destinationGammaGreen := floor(desiredGammaIlluminance / 1.5376)    ; This is the Red:Green and Green:Blue ratios to a warm color, which, with the default settings, will result in the RGB (0-255) Red 143, Green 93 and Blue 53.
destinationGammaBlue  := floor(destinationGammaGreen / 1.7547)      ; If you want a warmer color, you could use the ratios R:G 1.7346 and G:B 2.8823, which will result in the colors Red 143, Green 82 and Blue 28.
gammaRedDecrValue     := (255 - desiredGammaIlluminance) / 100
gammaGreenDecrValue   := (255 - destinationGammaGreen) / 100
gammaBlueDecrValue    := (255 - destinationGammaBlue) / 100
desiredGammaIlluminance -= 128


if (A_Hour == startHour && A_Min > 2 || A_Hour > startHour || A_Hour >= 0 && A_Hour <= 7)       ; If the script for some reason is started late (like when Windows is started at night), decrease all the missed minutes at once.
{
    if (currGammaRed >= 128)
    {
        if (A_Hour < startHour)                                     ; If the script is started after midnight, count since the previous day.
        {
            day := A_Now
            day += -1, days                                         ; Subtract one day from the current date.
            formatTime, day, %day%, dd                              ; Get only the day from the resulting full date.
        }
        else day := A_DD

        timeDifferenceInMinutes := getDistanceFromStartTime("minutes", day)
        decreasingsToBeMade := timeDifferenceInMinutes / 2

        loop % decreasingsToBeMade
            decreaseBrightnessOrGamma()
    }
}
else                                                                ; Otherwise, if the script was started before the startHour ...
    sleep, % getDistanceFromStartTime("seconds") * 1000 * -1        ; ... wait until the startHour.



setTimer, checkIdleTimeAndReapplyGamma, 1000                        ; In some cases, the gamma is reset after the monitor enters standby. This checks if the monitor entered and exited the standby mode, then reapplys the gamma values.

loop
{
    if (decreaseBrightnessOrGamma())
        sleep decreasingsInterval
    else
        break
}

return



decreaseBrightnessOrGamma()
{
    global startHour, blueLightFilterEnabled, desiredBrightness, desiredGammaIlluminance, gammaRedDecrValue, gammaBlueDecrValue, gammaGreenDecrValue, currGammaRed, currGammaGreen, currGammaBlue, currBrightness

    if (currBrightness > desiredBrightness)
        Monitor.SetBrightness(--currBrightness)
    else
    {
        if (ceil(currGammaRed) > desiredGammaIlluminance)
        {
            if (blueLightFilterEnabled)
            {
                currGammaRed   -= gammaRedDecrValue
                currGammaGreen -= gammaGreenDecrValue
                currGammaBlue  -= gammaBlueDecrValue
            }
            else
            {
                currGammaRed--
                currGammaGreen--
                currGammaBlue--
            }

            Monitor.SetGammaRamp(ceil(currGammaRed), ceil(currGammaGreen), ceil(currGammaBlue))

        }
        else return false            ; After finished decreasing all values, exit the loop and wait for the shutdown.
    }

    return true
}


checkIdleTimeAndReapplyGamma()
{
    global monitorStandbyTimeout, idle, currGammaRed, currGammaGreen, currGammaBlue
    critical

    if (A_TimeIdlePhysical > monitorStandbyTimeout)     ; In some cases, when the monitor enters in standby, the gamma changes are reset to the default, eventhough the values are correct and intact.
        idle := true                                    ; This function checks whether enough idle time has passed to trigger the monitor standby, then reapplies the gamma changes when any peripheric wakes the monitor up.
    else if (idle)
    {
        idle := false
        Monitor.SetGammaRamp(ceil(currGammaRed), ceil(currGammaGreen), ceil(currGammaBlue))
    }
}


getDistanceFromStartTime(timeScale, day := "")
{
    global startHour

    if (day == "")
        day := A_DD

    startTime := A_YYYY . A_MM . day . startHour . 00 . 00
    now := A_Now
    now -= startTime , %timeScale%
    timeDifference := now

    return timeDifference
}


ExitEvent(reason, code)
{
    global origBrightness

    if (reason == "Shutdown")                       ; The GammaRamp is automatically reset by rebooting, but the brightness is permanent.
        Monitor.SetBrightness(origBrightness)       ; This resets the brightness to the original value. It's better to do this on shutdown than on startup.
}