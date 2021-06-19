;**************** SETTINGS ****************

logFileFullPath := "C:\Users\Public\CLWF-Log.txt"           ; Where the log file should be located.

;******************************************



#NoTrayIcon         ; Prevent the script from flashing in the tray every time it's triggered.
SetBatchLines 0     ; Speedup the script to make it take the least time needed to finish.
ListLines off       ; Disable unnecessary IO of the script to make it speedup a little bit.

;/* Get the event details from each argument. The values of these arguments are provided by the Task Scheduler itself. You can view the same values in the Event Viewer. */

direction     := a_args[1]
application   := a_args[2]
protocol      := a_args[3]
sourceAddress := a_args[4]
sourcePort    := a_args[5]
destAddress   := a_args[6]
destPort      := a_args[7]
eventID       := a_args[8]
processId     := a_args[9]


;/* Wait for the main script to be running before continuing. If the main script is not running, the active object won't be created and the function call below would throw an error. */

loop
{
    try
    {
        obj := ComObjActive("{01234567-89AB-CDEF-0123-456789ABCDEF}")       ; Get the active object identified with this GUID, which is created in the main script. An active object is an object that
        break                                                               ; can be accessed by any process, including the event handler script, provided that the process know the object's GUID.
    }                                                                       ; The object's GUID can be composed of any hexadecimal number, as long as it follows the pattern "{8-4-4-4-12}".
    catch
        sleep 1000                      ; If the object is not yet available or something is wrong, try again after 1 second.
}


/* Replace the volume ID with the volume letter. For some reason, Windows Firewall doesn't use the drive letter mapping
   in the process path of the block/allow events, instead it uses the volume ID (e.g. \device\harddiskvolume4).
*/

RegExMatch(application, "\\device\\harddiskvolume\d+", deviceId)

application := strReplace(application, deviceId, obj.driveMappings[deviceId])


protocol := obj.protocolMappings[protocol]              ; Replace the protocol number with the protocol name.


;/* Replace the connection's direction numeric symbol with the words In or Out. */

if (direction == "%%14593")
    direction := "Out"
else if (direction == "%%14592")
    direction := "In "


;/* Replace the event ID with the event name. */

if (eventID == 5152)
    eventID := "Blocked"
else if (eventID == 5156)
    eventID := "Allowed"


wingettitle, procWinTitle, ahk_pid %processId%          ; Get the process' window title. This only works if the process actually have a window open, otherwise it just returns an empty string.


/* Remember outgoing connections state. In some systems, mostly the ones with an unstable internet connection or a cheap router, it can happen that some outgoing connections are "forgotten",
   and when the response reaches the author, it's treated as an unsolicited incoming connection instead of a response. This can flood the logs with incoming connections that are actually just
   unrecognized responses to normal requests. The code below remembers the outgoing connections and prevents it from logging incoming connections from IPs that were already connected previously.
*/

currentOutgoingConnections := obj.connections

if (direction == "Out")
{
    if (!instr(currentOutgoingConnections, destAddress))
        obj.connections .= destAddress "`n"
}
else
{
    if (instr(currentOutgoingConnections, sourceAddress))
        return
}


;/* Make the columns have a fixed width, not less, not more. This makes the log have a uniform look and makes it easier to quick read. */

application   := padOrTrim(application, 130)
destAddress   := padOrTrim(destAddress, 15)
destPort      := padOrTrim(destPort, 5)
sourceAddress := padOrTrim(sourceAddress, 15)
sourcePort    := padOrTrim(sourcePort, 5)



formatTime, now,, MM/dd HH:mm:ss        ; Get the current date and time in this format.


;/* And finally add the log entry to the log file. */

FileAppend, % now " | " direction " | " application " | " protocol " | " sourceAddress " | " sourcePort " | " destAddress " | " destPort " | " eventID " | " procWinTitle "`n", %logFileFullPath%



padOrTrim(string, length)
{
    s := Format("{:-" length "}|", string)
    s := SubStr(s, 1, length)

    return s
}