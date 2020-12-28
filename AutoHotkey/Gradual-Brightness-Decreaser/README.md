# Gradual Brightness Decreaser

Gradually decrease the screen brightness and blue light, starting from the set hour.

## About

This AutoHotkey script enables you to have your computer's screen brightness automatically and gradually dimmed at night so as to not have eye strain, caused by the prolonged exposure to the screen's light. It also has an option to gradually shift the screen color to a warm tone.   

The script takes around 5 hours to finish, decreasing each value in intervals of 2 minutes. This interval let your eyes adapt in a way that neither you nor your eyes are affected by any abrupt brightnesss or color change. If you want it to finish in less time or you want to change the final color, you can freely tweak the values used in the script.

## How to use

First you need the AutoHotkey interpreter, which can be downloaded from [AutoHotkey's website](https://www.autohotkey.com/), included either in the [setup wizard](https://www.autohotkey.com/download/ahk-install.exe) or the [ZIP archive](https://www.autohotkey.com/download/ahk.zip). 

Before running this script, it requires the [Monitor Class](https://raw.githubusercontent.com/jNizM/Class_Monitor/master/src/Class_Monitor.ahk) created by [jNizM](https://github.com/jNizM). Just download it and put it in the same directory that this script is in.

Now you just have to run this script. If you used the setup, the .ahk extension is automatically associated with the AutoHotkey interpreter, otherwise if you used the ZIP, you have to run the script with the AutoHotkey.exe executable or manually associate it. 

After that, you just need to set the script to be run on startup, either by putting a shortcut to the script in the `C:\ProgramData\Microsoft\Windows\Start Menu\Programs\StartUp` directory or by scheduling it in the Task Scheduler, or whatever other way.

And it's done! If the script is run before the starting hour, it will wait until it's time.

It was tested and works in Windows 10 1909 with AutoHotkey 1.1.33.2, but should also work in other variations.

## License

- You can view the code, download copies and run this software as is.
- You can link to this script's [homepage](https://github.com/hjk789/Creations/tree/master/AutoHotkey/Gradual-Brightness-Decreaser). 
- You can modify your copy as you like.
- You cannot do any other action not allowed in this license.  
