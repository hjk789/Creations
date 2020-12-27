/*
    Gradual Brightness Decreaser - v1.1
    Created by BLBC (github.com/hjk789)
    Copyright (c) 2020+ BLBC
*/


;********* SETTINGS *********

global startHour := 19              ; The hour of day that the script will start to work, in 24-hour format.
global blueLightFilter := true      ; Whether the script should also gradually change the screen's gamma colors to a warm tone. If you don't want this, change it to false.

;****************************


#SingleInstance force
#Persistent
ListLines off

#include %A_ScriptDir%\Class_Monitor.ahk                        ; Using the Monitor Class created by jNizM (https://raw.githubusercontent.com/jNizM/Class_Monitor/master/src/Class_Monitor.ahk).

OnExit("ExitEvent")                                             ; Run the ExitEvent function below when the script exits for any reason, including when the system is shutdown.

global currBrightness := Monitor.GetBrightness().Current
global currGammaRed   := Monitor.GetGammaRamp()["Red"]
global currGammaGreen := Monitor.GetGammaRamp()["Green"]
global currGammaBlue  := Monitor.GetGammaRamp()["Blue"]
;contrastValue := Monitor.GetContrast().Current                 ; If you want to make the screen even darker, you can also decrease the contrast, but just the brightness and gamma already make it dark enough.

if (((A_Hour == startHour && A_Min > 2) || A_Hour > startHour || A_Hour >= 0 && A_Hour <= 7) && currGammaRed >= 128)       ; If the script for some reason is started late (like when Windows is started at night), decrease all the missed minutes at once.
{
    if (A_Hour < startHour)                                     ; If the script is started after midnight, count since the previous day.
    {
        day := A_Now
        day += -1, days                                         ; Subtract one day from the current date.
        formatTime, day, %day%, dd                              ; Get only the day from the resulting full date.
    }
    else day := A_DD

    timeDifferenceInMinutes := getDistanceToStartTime("minutes", day)
    decreasingsToBeMade := timeDifferenceInMinutes / 2

    loop % decreasingsToBeMade
        decreaseBrightnessOrGamma()
}
else                                                            ; Otherwise, if the script was started before the startHour ...
    sleep, % getDistanceToStartTime("seconds") * 1000 * -1      ; ... wait until the startHour.


loop
{
    if (decreaseBrightnessOrGamma())
        sleep 120000  ; 2 minutes
    else
        break
}




getDistanceToStartTime(timeScale, day := "")
{
    if (day == "")
        day := A_DD

    startTime := A_YYYY . A_MM . day . startHour . 00 . 00
    now := A_Now
    now -= startTime , %timeScale%
    timeDifference := now

    return timeDifference
}


decreaseBrightnessOrGamma()
{
    if (currBrightness > 5)                         ; A brightness value lower than 5 or a gamma ramp value lower than 15 causes eye strain.
        Monitor.SetBrightness(--currBrightness)
    else
    {
        if (currGammaRed > 15)
        {
            currGammaRed--
            
            if (blueLightFilter)
            {
                currGammaGreen -= 1.45              ; These values are proportional with the red gamma value, in a way that the screen color gradually shifts from cold to warm color, while at the
                currGammaBlue -= 1.8                ; same time decreasing the luminance. The resulting color values, in RGB from -128 to 128 (256 shades), are Red 15, Green -35 and Blue -75.
            }
            else 
            {
                currGammaGreen--
                currGammaBlue-- 
            }
            
            Monitor.SetGammaRamp(currGammaRed, ceil(currGammaGreen), ceil(currGammaBlue))
            
        }
        else return false                           ; After 5 hours and 16 minutes, or 158 decreasings, exit the loop and wait for the shutdown.
    }

    return true
}


ExitEvent(reason, code)
{
    if (reason == "Shutdown")                   ; The GammaRamp is automatically reset by rebooting, but the brightness is permanent.
        Monitor.SetBrightness(50)               ; This resets the brightness to the original value. It's better to do this on shutdown than on startup.
}
