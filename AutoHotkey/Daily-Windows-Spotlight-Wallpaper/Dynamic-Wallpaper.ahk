/*
    Dynamic Wallpaper - v1.0
    Created by BLBC (github.com/hjk789)
    Copyright (c) 2023+ BLBC
*/


;************** SETTINGS **************

whereToSaveTheWallpapers := "<PATH OF THE FOLDER TO WHERE THE WALLPAPERS WILL BE DOWNLOADED>"         ; If you don't want to keep the wallpapers, set the path to "C:\Users\<USERNAME>\AppData\Local\Temp", and eventually it will get deleted.

;**************************************



main()
{
    try
    {
        whr := ComObjCreate("WinHttp.WinHttpRequest.5.1")
        whr.open("GET", "https://www.bing.com")
        whr.send()
        pageResponse := whr.responseText

        if (RegExMatch(pageResponse, "{.Url.:.(.+?).,", match))        ; Parse the page's HTML to get the wallpaper URL.
        {
            imageURL := "https://www.bing.com" match1

            fullpath := getFullPath(imageURL, "=")

            IfNotExist %fullpath%                               ; Download the wallpaper only if it wasn't already.
            {
                downloadAndSetWallpaper(imageURL, fullpath)
                return
            }
        }


        whr.open("GET", "https://windows10spotlight.com")    ; windows10spotlight.com is an automated service that posts every Windows Spotlight wallpaper, two per day.
        whr.send()
        pageResponse := whr.responseText

        i := 1
        while (i := RegExMatch(pageResponse, "src=.(https://windows10spotlight.com/wp-content/uploads/(.+?\.(jpg|webp)))", match, i+StrLen(match)))        ; Parse the page's HTML to get the most recent wallpaper. The last parameter
        {                                                                                                                                                  ; indicates that it should continue searching starting from the last match.
            imageURL := RegExReplace(match1, "-\d+x\d+", "")            ; Remove the resolution suffix to get the highest resolution available.

            fullpath := getFullPath(imageURL, "/")

            IfExist %fullpath%
                continue                                                ; If the most recent wallpaper was already downloaded, try the second to last most recent one, and so on.

            downloadAndSetWallpaper(imageURL, fullpath)

            return
        }

    }
    catch e                                                                   ; In case there's any network error during the process ...
    {
        sleep 5000
        main()                                                                ; ... try again after 5 seconds.
    }
}


getFullPath(imageURL, separator)
{
    global whereToSaveTheWallpapers

    filename := StrSplit(imageURL, separator)
    filename := filename[filename.maxIndex()]                               ; Get the file name, which is the part of the URL after the last separator character.

    fullpath := RTrim(whereToSaveTheWallpapers, "\") "\" filename

    return fullpath
}


downloadAndSetWallpaper(imageURL, fullpath)
{
    UrlDownloadToFile, %imageURL%, %fullpath%                                       ; Download the wallpaper to the designated location.

    DllCall("SystemParametersInfo", UInt, 0x14, UInt, 0, Str, fullpath, UInt, 1)    ; Set the wallpaper.
}



main()
