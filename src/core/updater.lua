require("src.core.utils")

Updater = {}

local currentVersion = "2.0.0" -- This version is hardcoded in the script

function Updater.checkForUpdates()
    WebRequest.get(versionCheckURL, function(request)
        if request.is_done and request.is_success then
            local latestVersion = request.text
            -- Trim whitespace or other characters from the response
            latestVersion = latestVersion:match("^%s*(.-)%s*$")

            if latestVersion ~= currentVersion then
                -- UPDATE AVAILABLE! Broadcast an event with the data.
                -- Don't create UI here. Just announce the news.
                print("Update found: " .. latestVersion)
                Global.call("EventDispatcher.broadcast", {
                    eventName = "updateAvailable",
                    versionInfo = {
                        current = currentVersion,
                        latest = latestVersion
                    }
                })
            else
                -- System is up-to-date.
                print("System is up to date.")
                Global.call("EventDispatcher.broadcast", {eventName = "systemUpToDate"})
            end
        else
            -- FAILED TO CHECK! Broadcast a different event.
            Global.call("EventDispatcher.broadcast", {
                eventName = "updateCheckFailed",
                error = request.error
            })
        end
    end)
end

function Updater.getCurrentVersion()
    return currentVersion
end

return Updater