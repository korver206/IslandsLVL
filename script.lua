-- Roblox Islands Skill Leveler Script
-- Compatible with Vega X Executor
-- Scans for skill-related remotes and provides UI to add levels to all skills
-- Skills: Farming, Woodcutting, Mining, Economy, Animal Care, Forging, Fishing, Cooking, Combat, Light Melee, Heavy Melee, Archery, Magic

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local player = Players.LocalPlayer

local enabled = true
local skillUIEnabled = false
local allRemotes = {}
local skillRemotes = {}

-- UI Creation
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "IslandsSkillUI"
screenGui.Parent = player:WaitForChild("PlayerGui")

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 300, 0, 400)
mainFrame.Position = UDim2.new(0, 10, 1, -410)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
mainFrame.BackgroundTransparency = 0.2
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui
mainFrame.Visible = enabled

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 10)
corner.Parent = mainFrame

local function shimmerEffect(stroke)
    local tweenInfo = TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true)
    local goal1 = {Color = Color3.fromRGB(255, 100, 255)}
    local goal2 = {Color = Color3.fromRGB(255, 200, 255)}
    local tween1 = TweenService:Create(stroke, tweenInfo, goal1)
    local tween2 = TweenService:Create(stroke, tweenInfo, goal2)
    tween1:Play()
    tween2:Play()
end

local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(0.9, 0, 0, 60)
statusLabel.Position = UDim2.new(0.05, 0, 0, 20)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "Status: Press K to open Skill Leveler"
statusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
statusLabel.TextScaled = true
statusLabel.TextWrapped = true
statusLabel.Font = Enum.Font.Gotham
statusLabel.Parent = mainFrame

local consoleFrame = Instance.new("ScrollingFrame")
consoleFrame.Size = UDim2.new(0.9, 0, 0, 300)
consoleFrame.Position = UDim2.new(0.05, 0, 0, 80)
consoleFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
consoleFrame.BackgroundTransparency = 0.1
consoleFrame.BorderSizePixel = 2
consoleFrame.BorderColor3 = Color3.fromRGB(255, 100, 255)
consoleFrame.ScrollBarThickness = 8
consoleFrame.Parent = mainFrame

local consoleCorner = Instance.new("UICorner")
consoleCorner.CornerRadius = UDim.new(0, 5)
consoleCorner.Parent = consoleFrame

local consoleLayout = Instance.new("UIListLayout")
consoleLayout.SortOrder = Enum.SortOrder.LayoutOrder
consoleLayout.Parent = consoleFrame

local consoleTitle = Instance.new("TextLabel")
consoleTitle.Size = UDim2.new(1, 0, 0, 20)
consoleTitle.BackgroundTransparency = 1
consoleTitle.Text = "Console Logs"
consoleTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
consoleTitle.TextScaled = true
consoleTitle.Font = Enum.Font.GothamBold
consoleTitle.Parent = consoleFrame

-- Skill UI
local skillFrame = Instance.new("Frame")
skillFrame.Size = UDim2.new(0, 500, 0, 550)
skillFrame.Position = UDim2.new(0, 320, 1, -560)
skillFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
skillFrame.BackgroundTransparency = 0.2
skillFrame.BorderSizePixel = 0
skillFrame.Parent = screenGui
skillFrame.Visible = skillUIEnabled

local skillCorner = Instance.new("UICorner")
skillCorner.CornerRadius = UDim.new(0, 10)
skillCorner.Parent = skillFrame

local skillTitle = Instance.new("TextLabel")
skillTitle.Size = UDim2.new(1, 0, 0, 30)
skillTitle.BackgroundTransparency = 1
skillTitle.Text = "Dynamic Skill Leveler - Discovered Functions"
skillTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
skillTitle.TextScaled = true
skillTitle.Font = Enum.Font.GothamBold
skillTitle.Parent = skillFrame

-- Skill List ScrollingFrame
local skillList = Instance.new("ScrollingFrame")
skillList.Size = UDim2.new(0.95, 0, 0, 500)
skillList.Position = UDim2.new(0.025, 0, 0, 35)
skillList.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
skillList.BackgroundTransparency = 0.1
skillList.BorderSizePixel = 2
skillList.BorderColor3 = Color3.fromRGB(255, 100, 255)
skillList.ScrollBarThickness = 8
skillList.Parent = skillFrame

local listCorner = Instance.new("UICorner")
listCorner.CornerRadius = UDim.new(0, 5)
listCorner.Parent = skillList

local skillLayout = Instance.new("UIListLayout")
skillLayout.SortOrder = Enum.SortOrder.LayoutOrder
skillLayout.Padding = UDim.new(0, 5)
skillLayout.Parent = skillList

-- Functions
local function updateStatus(text)
    statusLabel.Text = "Status: " .. text
    print("[Islands Skill] " .. text)
end

-- Override print, warn, error for console
local oldPrint = print
print = function(...)
    local args = {...}
    local message = table.concat(args, " ")
    addConsoleMessage("[PRINT] " .. message, Enum.MessageType.MessageOutput)
    return oldPrint(...)
end

local oldWarn = warn
warn = function(...)
    local args = {...}
    local message = table.concat(args, " ")
    addConsoleMessage("[WARN] " .. message, Enum.MessageType.MessageWarning)
    return oldWarn(...)
end

local oldError = error
error = function(message, level)
    addConsoleMessage("[ERROR] " .. tostring(message), Enum.MessageType.MessageError)
    return oldError(message, level)
end

local LogService = game:GetService("LogService")
LogService.MessageOut:Connect(function(message, messageType)
    addConsoleMessage("[LOG] " .. message, messageType)
end)

local function addConsoleMessage(message, messageType)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -10, 0, 20)
    label.BackgroundTransparency = 1
    label.Text = message
    label.TextScaled = true
    label.Font = Enum.Font.Gotham
    label.LayoutOrder = #consoleFrame:GetChildren()

    if messageType == Enum.MessageType.MessageOutput then
        label.TextColor3 = Color3.fromRGB(255, 255, 255)
    elseif messageType == Enum.MessageType.MessageWarning then
        label.TextColor3 = Color3.fromRGB(255, 255, 0)
    elseif messageType == Enum.MessageType.MessageError then
        label.TextColor3 = Color3.fromRGB(255, 0, 0)
    else
        label.TextColor3 = Color3.fromRGB(200, 200, 200)
    end

    label.Parent = consoleFrame
    consoleFrame.CanvasSize = UDim2.new(0, 0, 0, consoleLayout.AbsoluteContentSize.Y)

    -- Limit to last 30 messages
    local children = consoleFrame:GetChildren()
    if #children > 32 then
        children[2]:Destroy()  -- Keep title
    end
end


local function scanForSkillRemotes()
    updateStatus("Scanning for skill remotes...")
    allRemotes = {}
    skillRemotes = {}  -- Now {skillName = remote}, where skillName is derived from remote name

    local startTime = tick()
    local maxScanTime = 3  -- 3 second timeout

    -- Limit to ReplicatedStorage for faster, surefire scanning (remotes are typically there)
    local areas = {ReplicatedStorage}
    if player.PlayerGui then
        table.insert(areas, player.PlayerGui)
    end
    -- Skip workspace and character to avoid large scans that cause hanging

    local scannedCount = 0
    local scanLimit = 1000  -- Further reduced limit

    -- First, collect all remotes efficiently with timeout check
    for _, area in ipairs(areas) do
        if tick() - startTime > maxScanTime then
            print("[Islands Skill] Scan timed out after " .. maxScanTime .. " seconds")
            break
        end
        pcall(function()
            local descendants = area:GetDescendants()
            for i, child in ipairs(descendants) do
                if tick() - startTime > maxScanTime then
                    print("[Islands Skill] Scan loop timed out")
                    break
                end
                scannedCount = scannedCount + 1
                if scannedCount > scanLimit then
                    break
                end
                if i % 100 == 0 then  -- Yield more frequently
                    task.wait(0.01)
                end
                if child:IsA("RemoteEvent") or child:IsA("RemoteFunction") then
                    table.insert(allRemotes, child)
                end
            end
        end)
        if scannedCount > scanLimit then
            break
        end
    end

    -- Now discover skill remotes by looking for remotes with "skill" or related keywords in name
    -- Derive skill name from remote name, e.g., "UpdateFarming" -> "Farming"
    local generalKeywords = {"skill", "exp", "xp", "level", "experience", "update"}
    for _, remote in ipairs(allRemotes) do
        local remoteName = remote.Name:lower()
        local isSkillRemote = false
        for _, keyword in ipairs(generalKeywords) do
            if string.find(remoteName, keyword) then
                isSkillRemote = true
                break
            end
        end
        if isSkillRemote and not skillRemotes[remote.Name] then
            -- Derive skill name: remove common prefixes like "Update", "Add", "Remote"
            local skillName = remote.Name:gsub("^Update", ""):gsub("^Add", ""):gsub("^Remote", ""):gsub("Event$", ""):gsub("Function$", "")
            if skillName == "" then skillName = remote.Name end
            skillRemotes[skillName] = remote
            print("[Islands Skill] Discovered skill remote: " .. skillName .. " -> " .. remote.Name)
        end
    end

    -- Enhanced Fallback: If no skill-specific remotes, use any remote with level/exp keywords
    if next(skillRemotes) == nil then
        local fallbackRemote = nil
        for _, remote in ipairs(allRemotes) do
            local remoteName = remote.Name:lower()
            if string.find(remoteName, "level") or string.find(remoteName, "exp") or string.find(remoteName, "xp") or string.find(remoteName, "update") then
                fallbackRemote = remote
                local skillName = "General Levels"
                skillRemotes[skillName] = fallbackRemote
                print("[Islands Skill] Assigned fallback for general levels: " .. remote.Name)
                break
            end
        end
        if not fallbackRemote then
            if #allRemotes > 0 then
                skillRemotes["Fallback"] = allRemotes[1]
                print("[Islands Skill] Using first remote as ultimate fallback: " .. allRemotes[1].Name)
            else
                print("[Islands Skill] No remotes found at all - skill leveling may not work")
            end
        end
    end

    local foundCount = 0
    for skill, _ in pairs(skillRemotes) do
        foundCount = foundCount + 1
    end
    local scanTime = tick() - startTime
    local discoveredSkills = {}
    for skill, _ in pairs(skillRemotes) do
        table.insert(discoveredSkills, skill)
    end
    updateStatus("Scan complete in " .. string.format("%.2f", scanTime) .. "s. Discovered " .. foundCount .. " skill functions: " .. table.concat(discoveredSkills, ", "))
end

local function createSkillUI()
    -- Clear existing UI elements
    for _, child in ipairs(skillList:GetChildren()) do
        if child:IsA("Frame") then
            child:Destroy()
        end
    end

    local discoveredSkills = {}
    for skillName, remote in pairs(skillRemotes) do
        table.insert(discoveredSkills, {name = skillName, remote = remote})
    end

    -- Sort by name for consistent order
    table.sort(discoveredSkills, function(a, b) return a.name < b.name end)

    local layoutOrder = 1
    for _, data in ipairs(discoveredSkills) do
        local skillName = data.name
        local remote = data.remote

        local skillFrame = Instance.new("Frame")
        skillFrame.Size = UDim2.new(1, -10, 0, 80)
        skillFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        skillFrame.BackgroundTransparency = 0.3
        skillFrame.BorderSizePixel = 1
        skillFrame.BorderColor3 = Color3.fromRGB(255, 100, 255)
        skillFrame.LayoutOrder = layoutOrder
        skillFrame.Parent = skillList

        local frameCorner = Instance.new("UICorner")
        frameCorner.CornerRadius = UDim.new(0, 5)
        frameCorner.Parent = skillFrame

        local skillLabel = Instance.new("TextLabel")
        skillLabel.Size = UDim2.new(0.4, 0, 0.3, 0)
        skillLabel.Position = UDim2.new(0, 5, 0, 5)
        skillLabel.BackgroundTransparency = 1
        skillLabel.Text = skillName
        skillLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        skillLabel.TextScaled = true
        skillLabel.Font = Enum.Font.GothamBold
        skillLabel.Parent = skillFrame

        local remoteLabel = Instance.new("TextLabel")
        remoteLabel.Size = UDim2.new(0.6, 0, 0.3, 0)
        remoteLabel.Position = UDim2.new(0, 5, 0.3, 0)
        remoteLabel.BackgroundTransparency = 1
        remoteLabel.Text = remote.Name
        remoteLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
        remoteLabel.TextScaled = true
        remoteLabel.Font = Enum.Font.Gotham
        remoteLabel.TextWrapped = true
        remoteLabel.Parent = skillFrame

        -- Buttons for +1, +5, +10, MAX
        local buttons = {"+1", "+5", "+10", "MAX"}
        local buttonPositions = {UDim2.new(0, 5, 0.6, 0), UDim2.new(0.25, 0, 0.6, 0), UDim2.new(0.5, 0, 0.6, 0), UDim2.new(0.75, 0, 0.6, 0)}
        local levels = {1, 5, 10, 999}  -- MAX as high number for max level

        for j, btnText in ipairs(buttons) do
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(0.2, -5, 0.3, 0)
            btn.Position = buttonPositions[j]
            btn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
            btn.Text = btnText
            btn.TextColor3 = Color3.fromRGB(255, 255, 255)
            btn.TextScaled = true
            btn.Font = Enum.Font.GothamBold
            btn.Parent = skillFrame

            local btnCorner = Instance.new("UICorner")
            btnCorner.CornerRadius = UDim.new(0, 3)
            btnCorner.Parent = btn

            local trim = Instance.new("UIStroke")
            trim.Color = Color3.fromRGB(255, 100, 255)
            trim.Thickness = 1
            trim.Parent = btn
            shimmerEffect(trim)

            btn.MouseButton1Click:Connect(function()
                local levelToAdd = levels[j]
                pcall(function()
                    -- Try multiple arg combinations for compatibility (since no predefined skill, use levelToAdd and possibly skillName)
                    local success = false
                    local argCombos = {
                        {levelToAdd, skillName},
                        {skillName, levelToAdd},
                        {levelToAdd},
                        {skillName},
                        {levelToAdd, skillName:lower():gsub(" ", "_")}
                    }
                    for _, args in ipairs(argCombos) do
                        local ok, err = pcall(function()
                            if remote:IsA("RemoteEvent") then
                                remote:FireServer(unpack(args))
                            elseif remote:IsA("RemoteFunction") then
                                remote:InvokeServer(unpack(args))
                            end
                        end)
                        if ok then
                            success = true
                            break
                        end
                    end
                    if success then
                        updateStatus("Added " .. levelToAdd .. " levels to " .. skillName)
                        print("[Islands Skill] Successfully fired " .. remote.Name .. " for " .. skillName .. " + " .. levelToAdd)
                    else
                        updateStatus("Failed to fire remote for " .. skillName .. " - check console")
                        warn("[Islands Skill] Failed to fire " .. remote.Name .. " for " .. skillName)
                    end
                end)
            end)
        end

        layoutOrder = layoutOrder + 1
    end

    skillList.CanvasSize = UDim2.new(0, 0, 0, skillLayout.AbsoluteContentSize.Y)
end

-- Events
UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == Enum.KeyCode.G then
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
            screenGui:Destroy()
            updateStatus("Script stopped.")
        else
            enabled = not enabled
            mainFrame.Visible = enabled
        end
    elseif input.KeyCode == Enum.KeyCode.K then
        skillUIEnabled = not skillUIEnabled
        skillFrame.Visible = skillUIEnabled
        if skillUIEnabled then
            spawn(function()  -- Run scanning in a separate thread to prevent UI blocking
                updateStatus("Scanning for skill remotes...")
                scanForSkillRemotes()
                task.wait(0.2)  -- Further reduced wait for quicker UI response
                createSkillUI()
            end)
        end
        updateStatus(skillUIEnabled and "Skill Leveler enabled" or "Skill Leveler disabled")
    end
end)

updateStatus("Script loaded. G: toggle main UI, Shift+G: stop, K: skill leveler")
print("[Islands Skill] Script loaded successfully")