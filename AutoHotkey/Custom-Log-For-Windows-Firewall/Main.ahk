#Persistent
#SingleInstance ignore


/* Map each drive letter to their drive ID. This is only needed to make the application paths in the logs be more readable, and
    only because Windows Firewall doesn't do this automatically, showing something like \device\harddiskvolume4 instead of just C:
*/

drives := {}

DriveGet, driveLetters, List

loop, parse, driveLetters
{
    driveLetter := a_loopfield ":"
    deviceId := QueryDosDevice(driveLetter)     ; Get the device ID of the specified volume.
    drives[deviceId] := driveLetter
}


protocols := {"1": "ICMP", "2": "IGMP", "6": "TCP ", "17": "UDP "}      ; Map the protocol codes to their respective names.


/* Store these values in an active object. The sole purpose of this is the connections attribute. Because the event handler script doesn't stay open
    after it finished running, the value of every variable is lost. One way to store the list of connected IPs would be writting to a file, but this
    would cause a lot of read/write in the  hard drive with many connections. An active object is an alternative to this, persistently storing all
    the values in the memory as long as the main script is running. For more details on active objects, see the comments in the event handler script.
*/

ObjRegisterActive({connections:"", driveMappings: drives, protocolMappings: protocols})





ObjRegisterActive(Object)
{
    ;/* This function was created by Lexikos and adapted by BLBC. Original code: https://www.autohotkey.com/boards/viewtopic.php?f=6&t=6148    */

    VarSetCapacity(_clsid, 16, 0)
    DllCall("ole32\CLSIDFromString", "wstr", "{01234567-89AB-CDEF-0123-456789ABCDEF}", "ptr", &_clsid)
    DllCall("oleaut32\RegisterActiveObject", "ptr", &Object, "ptr", &_clsid, "uint", Flags, "uint*", cookie, "uint")
}


QueryDosDevice(sDevice)
{
   ;/* This function was created by Sean and adapted by BLBC. Original code: https://autohotkey.com/board/topic/15705-lib-mount-map-a-path-to-any-drive-letter-v2/#entry141056    */

   size := 48
   VarSetCapacity(sPath, size)
   DllCall("QueryDosDeviceW", "Str", sDevice, Str, sPath, Uint, size, "Uint")

   Return sPath
}
