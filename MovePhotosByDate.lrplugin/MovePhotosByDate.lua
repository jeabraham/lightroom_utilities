local LrDialogs = import 'LrDialogs'
local LrApplication = import 'LrApplication'
local LrTasks = import 'LrTasks'
local LrFileUtils = import 'LrFileUtils'
local LrPathUtils = import 'LrPathUtils'

local catalog = LrApplication.activeCatalog()

LrTasks.startAsyncTask(function()
    -- Prompt user to select the base directory for date folders
    local targetDir = LrDialogs.runOpenPanel({
        title = "Select Base Directory for Date-Based Folders",
        canChooseFiles = false,
        canChooseDirectories = true,
        allowsMultipleSelection = false,
    })

    if not (targetDir and #targetDir > 0) then
        LrDialogs.message("No directory selected. Exiting.")
        return
    end

    targetDir = targetDir[1] -- Use the selected directory

    -- Ensure we have write access
    catalog:withWriteAccessDo("Move Photos to Date Folders", function()
        local photos = catalog:getTargetPhotos() -- Get the selected photos

        for _, photo in ipairs(photos) do
            -- Get the capture date of the photo
            local captureDate = photo:getFormattedMetadata("captureTime")
            if not captureDate then
                LrDialogs.message("Skipping a photo with no capture date.")
                goto continue
            end

            -- Format the capture date to create the folder structure
            local year = captureDate:sub(1, 4)
            local dateFolder = year .. "/" .. captureDate:sub(1, 10) -- "YYYY/YYYY-MM-DD"

            -- Create the destination folder if it doesn't exist
            local destinationDir = LrPathUtils.child(targetDir, dateFolder)
            if not LrFileUtils.exists(destinationDir) then
                LrFileUtils.createAllDirectories(destinationDir)
            end

            -- Get the current photo path and construct the destination path
            local photoPath = photo:getRawMetadata("path")
            local destinationPath = LrPathUtils.child(destinationDir, LrPathUtils.leafName(photoPath))

            -- Move the photo file
            local success, errorMessage = LrFileUtils.move(photoPath, destinationPath)
            if success then
                -- Update Lightroom catalog with the new location
                photo:moveToFolder(destinationDir)
            else
                LrDialogs.message("Failed to move " .. photoPath .. ": " .. errorMessage)
            end
            ::continue::
        end
    end)

    LrDialogs.message("Photos moved successfully!")
end)
