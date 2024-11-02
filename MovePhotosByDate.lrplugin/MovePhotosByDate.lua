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

    -- Move photos to date-based folders
    catalog:withWriteAccessDo("Move Photos to Date Folders", function()
        local photos = catalog:getTargetPhotos() -- Get the selected photos

        for _, photo in ipairs(photos) do
            -- Save metadata to .xmp first
            photo:saveMetadata()

            -- Try to get the capture date using commonly available fields
            local captureDate = photo:getFormattedMetadata("dateTimeOriginal") or photo:getFormattedMetadata("dateCreated")
            
            -- Skip processing if there is no capture date
            if captureDate then
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

                -- Determine the .xmp file path for the photo
                local xmpPath = LrPathUtils.replaceExtension(photoPath, "xmp")
                local xmpDestinationPath = LrPathUtils.replaceExtension(destinationPath, "xmp")
                
                -- Move the photo file
                local success = LrFileUtils.move(photoPath, destinationPath)
                if success then
                    -- Check if .xmp file exists, and move it if it does
                    if LrFileUtils.exists(xmpPath) then
                        LrFileUtils.move(xmpPath, xmpDestinationPath)
                    end

                    -- Inform Lightroom about the file move
                    photo:setRawMetadata("path", destinationPath)
                else
                    LrDialogs.message("Failed to move " .. photoPath .. ": Could not complete the move operation.")
                end
            else
                LrDialogs.message("Skipping a photo with no capture date.")
            end
        end
    end)

    LrDialogs.message("Photos moved successfully!")
end)
