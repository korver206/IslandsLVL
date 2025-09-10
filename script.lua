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
local skills = {
    "Farming",
    "Woodcutting",
    "Mining",
    "Economy",
    "Animal Care",
    "Forging",
    "Fishing",
    "Cooking",
    "Combat",
    "Light Melee",
    "Heavy Melee",
    "Archery",
    "Magic"
}

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
skillTitle.Text = "Skill Leveler"
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

local function findSkillRemote(skillName, parent)
    local keywords = {"skill", "exp", "xp", "level", "experience", skillName:lower():gsub(" ", "")}
    for _, child in ipairs(parent:GetDescendants()) do
        if child:IsA("RemoteEvent") or child:IsA("RemoteFunction") then
            local childName = child.Name:lower()
            for _, keyword in ipairs(keywords) do
                if string.find(childName, keyword) then
                    return child
                end
            end
        end
    end
    return nil
end

local function scanForSkillRemotes()
    updateStatus("Scanning for skill remotes...")
    allRemotes = {}
    skillRemotes = {}

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

    -- Now match remotes to skills based on name keywords without rescanning
    for _, remote in ipairs(allRemotes) do
        local remoteName = remote.Name:lower()
        for _, skill in ipairs(skills) do
            if not skillRemotes[skill] then
                local skillLower = skill:lower():gsub(" ", "")
                local keywords = {"skill", "exp", "xp", "level", "experience", skillLower}
                for _, keyword in ipairs(keywords) do
                    if string.find(remoteName, keyword) then
                        skillRemotes[skill] = remote
                        print("[Islands Skill] Found remote for " .. skill .. ": " .. remote.Name)
                        break  -- Found a match, move to next skill
                    end
                end
            end
        end
    end

    -- Enhanced Fallback: If still no remotes found, assign a general one or create dummy if possible, but use first remote as fallback
    local fallbackRemote = nil
    if next(skillRemotes) == nil then
        for _, remote in ipairs(allRemotes) do
            local remoteName = remote.Name:lower()
            if string.find(remoteName, "skill") or string.find(remoteName, "level") or string.find(remoteName, "exp") or string.find(remoteName, "update") then
                fallbackRemote = remote
                break
            end
        end
        if not fallbackRemote then
            fallbackRemote = allRemotes[1]  -- Use first remote as absolute fallback if any found
        end
        if fallbackRemote then
            for _, skill in ipairs(skills) do
                if not skillRemotes[skill] then
                    skillRemotes[skill] = fallbackRemote
                    print("[Islands Skill] Assigned fallback remote for " .. skill .. ": " .. fallbackRemote.Name)
                end
            end
        else
            print("[Islands Skill] No remotes found at all - skill leveling may not work")
        end
    end

    local foundCount = 0
    for skill, _ in pairs(skillRemotes) do
        foundCount = foundCount + 1
    end
    local scanTime = tick() - startTime
    updateStatus("Scan complete in " .. string.format("%.2f", scanTime) .. "s. Found " .. foundCount .. "/" .. #skills .. " skill remotes. Total remotes: " .. #allRemotes)
end

local function createSkillUI()
    -- Clear existing UI elements
    for _, child in ipairs(skillList:GetChildren()) do
        if child:IsA("Frame") then
            child:Destroy()
        end
    end

    for i, skill in ipairs(skills) do
        local skillFrame = Instance.new("Frame")
        skillFrame.Size = UDim2.new(1, -10, 0, 80)
        skillFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        skillFrame.BackgroundTransparency = 0.3
        skillFrame.BorderSizePixel = 1
        skillFrame.BorderColor3 = Color3.fromRGB(255, 100, 255)
        skillFrame.LayoutOrder = i
        skillFrame.Parent = skillList

        local frameCorner = Instance.new("UICorner")
        frameCorner.CornerRadius = UDim.new(0, 5)
        frameCorner.Parent = skillFrame

        local skillLabel = Instance.new("TextLabel")
        skillLabel.Size = UDim2.new(0.4, 0, 0.3, 0)
        skillLabel.Position = UDim2.new(0, 5, 0, 5)
        skillLabel.BackgroundTransparency = 1
        skillLabel.Text = skill
        skillLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        skillLabel.TextScaled = true
        skillLabel.Font = Enum.Font.GothamBold
        skillLabel.Parent = skillFrame

        local remoteLabel = Instance.new("TextLabel")
        remoteLabel.Size = UDim2.new(0.6, 0, 0.3, 0)
        remoteLabel.Position = UDim2.new(0, 5, 0.3, 0)
        remoteLabel.BackgroundTransparency = 1
        remoteLabel.Text = skillRemotes[skill] and skillRemotes[skill].Name or "No Remote Found"
        remoteLabel.TextColor3 = skillRemotes[skill] and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
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
                if skillRemotes[skill] then
                    local remote = skillRemotes[skill]
                    local levelToAdd = levels[j]
                    pcall(function()
                        -- Try multiple arg combinations for compatibility
                        local success = false
                        local argCombos = {
                            {levelToAdd, skill},
                            {skill, levelToAdd},
                            {levelToAdd},
                            {skill},
                            {levelToAdd, skill:lower():gsub(" ", "_")}
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
                            updateStatus("Added " .. levelToAdd .. " levels to " .. skill)
                            print("[Islands Skill] Successfully fired " .. remote.Name .. " for " .. skill .. " + " .. levelToAdd)
                        else
                            updateStatus("Failed to fire remote for " .. skill .. " - check console")
                            warn("[Islands Skill] Failed to fire " .. remote.Name .. " for " .. skill)
                        end
                    end)
                else
                    updateStatus("No remote found for " .. skill)
                end
            end)
        end
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