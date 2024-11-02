local LrDialogs = import 'LrDialogs'
local LrApplication = import 'LrApplication'
local LrTasks = import 'LrTasks'
local LrFileUtils = import 'LrFileUtils'

local catalog = LrApplication.activeCatalog()

LrTasks.startAsyncTask(function()

    -- Ask user for the file containing the list of image paths
    local filePath = LrDialogs.runOpenPanel({
        title = "Select File with Image Paths",
        canChooseFiles = true,
        canChooseDirectories = false,
        allowsMultipleSelection = false,
        fileTypes = "txt",
    })

    if not (filePath and #filePath > 0) then
        LrDialogs.message("No file selected. Exiting.")
        return
    end

    filePath = filePath[1]  -- Get the selected file path

    -- Read the file paths from the text file
    local fileContents = LrFileUtils.readFile(filePath)
    local imagePaths = {}
    for line in fileContents:gmatch("[^\r\n]+") do
        table.insert(imagePaths, line)
    end

    -- Create a new collection
    catalog:withWriteAccessDo("Create Collection", function()
        local collectionSet = catalog:createCollection("Photos from File List", nil, true)
        
        -- Add each image to the collection if it exists in the catalog
        local missingPhotos = {}
        for _, path in ipairs(imagePaths) do
            local photo = catalog:findPhotoByPath(path)
            if not photo then
                -- If photo is not in catalog, import it
                local importSuccess = catalog:addPhoto(path)
                if importSuccess then
                    photo = catalog:findPhotoByPath(path)
                else
                    LrDialogs.message("Failed to import: " .. path)
                end
            end
            if photo then
                collectionSet:addPhotos({ photo })
            else
                table.insert(missingPhotos, path)
            end
        end

        -- Show a message about completion
        if #missingPhotos > 0 then
            LrDialogs.message("Collection created, but some photos were not found or failed to import.", table.concat(missingPhotos, "\n"))
        else
            LrDialogs.message("Collection created successfully!")
        end
    end)
end)

