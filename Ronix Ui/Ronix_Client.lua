-- Prevent double loading
if getgenv and getgenv().RonixLoaded then return end
if getgenv then getgenv().RonixLoaded = true end

-- Services
local cloneref = cloneref or function(o) return o end
local TweenService = cloneref(game:GetService("TweenService"))
local Players = cloneref(game:GetService("Players"))
local GuiService = cloneref(game:GetService("GuiService"))
local RunService = cloneref(game:GetService("RunService"))
local StarterGui = cloneref(game:GetService("StarterGui"))
local VirtualUser = cloneref(game:GetService("VirtualUser"))
local HttpService = cloneref(game:GetService("HttpService"))
local MarketplaceService = cloneref(game:GetService("MarketplaceService"))

-- Exploit functions
local getgenv = getgenv or function() return {} end
local setclipboard = setclipboard or toclipboard or function() end
local setfpscap = setfpscap

-- GitHub Raw URL for the module
local MODULE_URL = "https://raw.githubusercontent.com/ug32-C9/main/main/RonixUI-Module.lua"

-- Debug function
local function Debug(msg)
    print("[Ronix Debug] " .. tostring(msg))
end

-- Safe WaitForChild with timeout
local function SafeWait(parent, name, timeout)
    timeout = timeout or 5
    if not parent then
        Debug("SafeWait: parent is nil for '" .. tostring(name) .. "'")
        return nil
    end
    local success, result = pcall(function()
        return parent:WaitForChild(name, timeout)
    end)
    if success and result then
        return result
    else
        Debug("SafeWait: Failed to find '" .. tostring(name) .. "' in " .. tostring(parent.Name))
        return nil
    end
end

-- Safe FindFirstChild
local function SafeFind(parent, name)
    if not parent then return nil end
    local success, result = pcall(function()
        return parent:FindFirstChild(name)
    end)
    return success and result or nil
end

-- Load the module from GitHub
local function LoadModuleFromGitHub()
    Debug("Loading module from: " .. MODULE_URL)
    
    local success, result = pcall(function()
        local moduleCode
        
        -- Method 1: game:HttpGet
        if game.HttpGet then
            Debug("Trying game:HttpGet...")
            local ok, code = pcall(function()
                return game:HttpGet(MODULE_URL)
            end)
            if ok and code and code ~= "" then
                moduleCode = code
                Debug("Success with game:HttpGet")
            end
        end
        
        -- Method 2: request function
        if not moduleCode and request then
            Debug("Trying request...")
            local ok, response = pcall(function()
                return request({
                    Url = MODULE_URL,
                    Method = "GET",
                    Timeout = 15
                })
            end)
            if ok and response and response.Body then
                moduleCode = response.Body
                Debug("Success with request")
            end
        end
        
        -- Method 3: http_request
        if not moduleCode and http_request then
            Debug("Trying http_request...")
            local ok, response = pcall(function()
                return http_request({
                    Url = MODULE_URL,
                    Method = "GET"
                })
            end)
            if ok and response and response.Body then
                moduleCode = response.Body
                Debug("Success with http_request")
            end
        end
        
        -- Method 4: syn.request
        if not moduleCode and syn and syn.request then
            Debug("Trying syn.request...")
            local ok, response = pcall(function()
                return syn.request({
                    Url = MODULE_URL,
                    Method = "GET"
                })
            end)
            if ok and response and response.Body then
                moduleCode = response.Body
                Debug("Success with syn.request")
            end
        end
        
        if not moduleCode or moduleCode == "" then
            error("Failed to fetch module from GitHub - all methods failed")
        end
        
        Debug("Module code length: " .. tostring(#moduleCode))
        
        local loadFunc = loadstring or (getgenv and getgenv().loadstring)
        if not loadFunc then
            error("loadstring not available")
        end
        
        local moduleFunc, loadErr = loadFunc(moduleCode)
        if not moduleFunc then
            error("Failed to parse module: " .. tostring(loadErr))
        end
        
        return moduleFunc()
    end)
    
    if success then
        Debug("Module loaded successfully!")
        return result
    else
        warn("[Ronix] Failed to load module from GitHub: " .. tostring(result))
        return nil
    end
end

-- Try to load the module
local Internal = LoadModuleFromGitHub()

-- Fallback: Try to load from local if GitHub fails
if not Internal then
    Debug("GitHub load failed, trying local fallback...")
    local localModule = script:FindFirstChild("RonixUI_Module")
    if localModule then
        local success, result = pcall(function()
            return require(localModule)
        end)
        if success then
            Internal = result
            Debug("Loaded from local fallback")
        else
            warn("[Ronix] Local fallback also failed: " .. tostring(result))
        end
    else
        warn("[Ronix] No local module found as fallback")
    end
end

if not Internal then
    warn("[Ronix] CRITICAL: Could not load module! UI will not function.")
    return
end

Debug("Module loaded, initializing UI...")

-- Get UI elements with error checking
local ScreenGui = script.Parent
if not ScreenGui then
    warn("[Ronix] CRITICAL: script.Parent is nil!")
    return
end

Debug("ScreenGui: " .. tostring(ScreenGui.Name))

-- Reparent to gethui if available (for some executors)
if gethui then
    local ok = pcall(function()
        ScreenGui.Parent = gethui()
    end)
    if ok then
        Debug("Reparented to gethui")
    end
end

-- Find UI container - try different possible names
local UI = SafeWait(ScreenGui, "UI", 3)
if not UI then
    UI = SafeFind(ScreenGui, "UI") or SafeFind(ScreenGui, "ui") or SafeFind(ScreenGui, "MainUI")
end

if not UI then
    -- Try to find any Frame/Folder that might be the UI container
    for _, child in pairs(ScreenGui:GetChildren()) do
        if child:IsA("GuiObject") or child:IsA("Folder") then
            if child.Name ~= "UIButton" then -- Skip the toggle button
                UI = child
                Debug("Found UI container by scanning: " .. child.Name)
                break
            end
        end
    end
end

if not UI then
    warn("[Ronix] CRITICAL: Could not find UI container! Make sure your UI has a child named 'UI' or similar.")
    return
end

Debug("UI container: " .. tostring(UI.Name))

-- Find Sidebar
local Sidebar = SafeWait(UI, "SideBar", 3)
if not Sidebar then
    Sidebar = SafeFind(UI, "SideBar") or SafeFind(UI, "Sidebar") or SafeFind(UI, "sidebar")
end

if not Sidebar then
    warn("[Ronix] CRITICAL: Could not find SideBar!")
    return
end

Debug("Sidebar: " .. tostring(Sidebar.Name))

-- Find Sidebar Frame
local SidebarFrame = SafeFind(Sidebar, "Frame")
if not SidebarFrame then
    -- Sidebar might be the frame itself
    SidebarFrame = Sidebar
    Debug("Using Sidebar as SidebarFrame")
end

-- Find MainFrame
local MainFrame = SafeWait(UI, "SideFrame", 3)
if not MainFrame then
    MainFrame = SafeFind(UI, "SideFrame") or SafeFind(UI, "MainFrame") or SafeFind(UI, "Main")
end

if not MainFrame then
    warn("[Ronix] CRITICAL: Could not find MainFrame/SideFrame!")
    return
end

Debug("MainFrame: " .. tostring(MainFrame.Name))

-- Find all pages with error handling
local Pages = {}
local pageNames = {"Home", "Executor", "Gallery", "Scripts", "Profile", "Extention", "Extension"}

for _, name in ipairs(pageNames) do
    local page = SafeFind(MainFrame, name)
    if page then
        Pages[name] = page
        Debug("Found page: " .. name)
    end
end

-- If Executor not found, try alternative names
if not Pages.Executor then
    Pages.Executor = SafeFind(MainFrame, "Editor") or SafeFind(MainFrame, "executor") or SafeFind(MainFrame, "editor")
    if Pages.Executor then
        Debug("Found Executor page with alternative name")
    end
end

if not Pages.Executor then
    warn("[Ronix] WARNING: Executor page not found! Some features may not work.")
end

-- Find sidebar buttons
local Buttons = {}
local buttonNames = {
    Home = {"HomeButton", "HomeBtn", "home"},
    Executor = {"ExecutorButton", "ExecutorBtn", "EditorButton", "editor"},
    Gallery = {"GalleryButton", "GalleryBtn", "PremiumButton", "gallery"},
    Scripts = {"ScriptsButton", "ScriptsBtn", "ScriptButton", "scripts"},
    Profile = {"ProfileButton", "ProfileBtn", "SettingsButton", "profile"}
}

for btnType, names in pairs(buttonNames) do
    for _, name in ipairs(names) do
        local btn = SafeFind(SidebarFrame, name) or SafeFind(Sidebar, name)
        if btn then
            Buttons[btnType] = btn
            Debug("Found button: " .. btnType .. " -> " .. btn.Name)
            break
        end
    end
end

-- Find executor-specific elements
local ExecutorElements = {}
if Pages.Executor then
    local elementNames = {"ButtonFooter", "TabHeader", "EditorHeader", "Buttons", "Footer"}
    for _, name in ipairs(elementNames) do
        local elem = SafeFind(Pages.Executor, name)
        if elem then
            table.insert(ExecutorElements, elem)
            Debug("Found executor element: " .. name)
        end
    end
end

-- Helper function to find elements recursively
local function FindRecursive(parent, name)
    if not parent then return nil end
    local success, result = pcall(function()
        local found = parent:FindFirstChild(name)
        if found then return found end
        for _, child in pairs(parent:GetChildren()) do
            found = FindRecursive(child, name)
            if found then return found end
        end
        return nil
    end)
    return success and result or nil
end

-- Find page title label
local PageTitleLabel = FindRecursive(Sidebar, "Selected") 
    or FindRecursive(Sidebar, "Title") 
    or FindRecursive(Sidebar, "PageTitle")

-- Helper to connect button clicks
local function ConnectClick(obj, callback)
    if not obj then return end
    local success = pcall(function()
        if obj:IsA("GuiButton") then
            local signal = obj.Activated or obj.MouseButton1Click
            signal:Connect(callback)
        else
            obj.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 
                   or input.UserInputType == Enum.UserInputType.Touch then
                    callback()
                end
            end)
        end
    end)
    if not success then
        Debug("Failed to connect click for: " .. tostring(obj.Name))
    end
end

-- Find executor components with better error handling
local ExecutorHandler = nil
local ExecutorButtons = nil
local Editor = nil
local TabHeader = nil
local TabScrollFrame = nil
local LineNumberLabel = nil

if Pages.Executor then
    -- Try to find EditorHeader
    local editorHeader = SafeFind(Pages.Executor, "EditorHeader")
    if editorHeader then
        ExecutorHandler = SafeFind(editorHeader, "ScrollingFrame")
    end
    
    -- Try alternative paths
    if not ExecutorHandler then
        ExecutorHandler = FindRecursive(Pages.Executor, "ScrollingFrame")
    end
    
    ExecutorButtons = SafeFind(Pages.Executor, "ButtonFooter") 
        or SafeFind(Pages.Executor, "Buttons")
        or FindRecursive(Pages.Executor, "ButtonFooter")
    
    if ExecutorHandler then
        Editor = SafeFind(ExecutorHandler, "Editor")
        if not Editor then
            local contentContainer = SafeFind(ExecutorHandler, "ContentContainer")
            if contentContainer then
                Editor = SafeFind(contentContainer, "Editor")
            end
        end
    end
    
    TabHeader = SafeFind(Pages.Executor, "TabHeader")
    if TabHeader then
        TabScrollFrame = SafeFind(TabHeader, "ScrollingFrame")
    end
    
    if ExecutorHandler then
        local lineObj = SafeFind(ExecutorHandler, "Line")
        if lineObj then
            LineNumberLabel = SafeFind(lineObj, "Line Number")
        end
    end
end

-- Find other UI elements
local FilePopup = SafeWait(UI, "FilePopUp", 2) or SafeFind(UI, "FilePopUp") or SafeFind(UI, "FilePopup")
local GlobalSearchBar = Pages.Scripts and SafeFind(Pages.Scripts, "SearchBar")

-- Gallery elements
local GalleryScroll = Pages.Gallery and FindRecursive(Pages.Gallery, "ScrollingFrame")
local GalleryAddBtn = Pages.Gallery and FindRecursive(Pages.Gallery, "AddButton")
local GalleryTemplate = Pages.Gallery and FindRecursive(Pages.Gallery, "Script")
local GallerySearchBar = Pages.Gallery and FindRecursive(Pages.Gallery, "SearchBar")
local GallerySearchInput = GallerySearchBar and FindRecursive(GallerySearchBar, "TextBox")

-- Scripts page elements
local ScriptsScroll = Pages.Scripts and FindRecursive(Pages.Scripts, "ScrollingFrame")
local ScriptsSearchBar = Pages.Scripts and SafeFind(Pages.Scripts, "SearchBar")
local SearchInput = ScriptsSearchBar and FindRecursive(ScriptsSearchBar, "TextBox")
local SearchBtn = ScriptsSearchBar and SafeFind(ScriptsSearchBar, "Search")
local FilterBtn = ScriptsSearchBar and SafeFind(ScriptsSearchBar, "Filter")
local FilterBar = Pages.Scripts and SafeFind(Pages.Scripts, "FilterBar")

-- Profile elements
local ProfileList = Pages.Profile and SafeFind(Pages.Profile, "ScrollingFrame")
local ProfileSearchBar = Pages.Profile and FindRecursive(Pages.Profile, "SearchBar")
local ProfileSearchInput = ProfileSearchBar and FindRecursive(ProfileSearchBar, "TextBox")
local ProfileExtensionBtn = ProfileSearchBar and FindRecursive(ProfileSearchBar, "ExtentionButton")

-- Extension elements
local ExtControlColors = FindRecursive(UI, "ExtentionControlPanel")
local ExtControlStart = FindRecursive(UI, "ExtentionControlPanel1") or ExtControlColors
local ExtControlLang = FindRecursive(UI, "ExtentionControlPanel2")
local TextSizeConfig = FilePopup and FindRecursive(FilePopup, "EditorTExtSIzeConfig") or (FilePopup and FindRecursive(FilePopup, "FileConfig"))

-- Popup elements
local RenamePopup = FilePopup and FindRecursive(FilePopup, "FileConfig")
local RenameBtn = RenamePopup and FindRecursive(RenamePopup, "RenameButton")
local CancelRenameBtn = RenamePopup and FindRecursive(RenamePopup, "CancelButton")
local OldNameLabel = RenamePopup and FindRecursive(RenamePopup, "FileLabel")
local NewNameTextBox = RenamePopup and FindRecursive(RenamePopup, "RenameTextBox")

local DeletePopup = FilePopup and FindRecursive(FilePopup, "FileDelete")
local DeleteBtn = DeletePopup and FindRecursive(DeletePopup, "DeleteButton")
local CancelDeleteBtn = DeletePopup and FindRecursive(DeletePopup, "CancelButton")
local FileNameLabel = DeletePopup and FindRecursive(DeletePopup, "FileLabel")

local Step1 = FilePopup and FindRecursive(FilePopup, "FileCreateStep1")
local Step1NameBox = Step1 and FindRecursive(Step1, "NameTextBox")
local Step1NextBtn = Step1 and FindRecursive(Step1, "NextButton")
local Step1CancelBtn = Step1 and FindRecursive(Step1, "CancelButton")

local Step2 = FilePopup and FindRecursive(FilePopup, "FileCreateStep2")
local Step2ScriptBox = Step2 and FindRecursive(Step2, "ScriptTextBox")
local Step2CreateBtn = Step2 and FindRecursive(Step2, "CreateButton")
local Step2CancelBtn = Step2 and FindRecursive(Step2, "CancelButton")

local CreateScriptPopup = FilePopup and FindRecursive(FilePopup, "CreateScript")
local ScriptConfigPopup = FilePopup and FindRecursive(FilePopup, "ScriptConfig")

-- Executor buttons
local ExecuteBtn = ExecutorButtons and SafeFind(ExecutorButtons, "ExecuteButton")
local PasteBtn = ExecutorButtons and SafeFind(ExecutorButtons, "PasteButton")
local EraseBtn = ExecutorButtons and SafeFind(ExecutorButtons, "EraseButton") or (ExecutorButtons and SafeFind(ExecutorButtons, "ClearButton"))
local EditTabBtn = ExecutorButtons and SafeFind(ExecutorButtons, "EditTabButton")
local DeleteTabBtn = ExecutorButtons and (SafeFind(ExecutorButtons, "DeleteButton") or SafeFind(ExecutorButtons, "TrashButton"))
local AddTabBtn = TabHeader and SafeFind(TabHeader, "AddButton")

-- UI Toggle
local UIToggleBtn = SafeFind(ScreenGui, "UIButton") or SafeFind(ScreenGui, "ToggleButton")
local CloseUIBtn = FindRecursive(UI, "CloseUIButton")

-- Profile buttons
local AutoBtn = ProfileList and SafeFind(ProfileList, "AutoButton")
local AntiAfkBtn = ProfileList and SafeFind(ProfileList, "AntiAfkButton")
local UnlockFpsBtn = ProfileList and SafeFind(ProfileList, "FPSButton")
local ConsoleBtn = ProfileList and SafeFind(ProfileList, "ConsoleButton")
local EnlargeBtn = ProfileList and SafeFind(ProfileList, "EnlargeButton")
local LuauSyntaxBtn = ProfileList and FindRecursive(ProfileList, "LuauSyntaxButton")
local StreamerModeBtn = ProfileList and FindRecursive(ProfileList, "StreamerModeButton")

-- State variables
local CurrentPage = Pages.Executor or Pages.Home
local CurrentTitle = "Editor"
local AllPages = {}
for _, page in pairs(Pages) do
    table.insert(AllPages, page)
end

local AllButtons = {}
for _, btn in pairs(Buttons) do
    table.insert(AllButtons, btn)
end

local Tabs = {{name = "Script 1", content = "", createdOn = os.time()}}
local CurrentTab = 1
local GalleryScripts = {}
local IsUIOpen = false
local IsAnimating = false
local IsStreamerMode = false
local TempAutoExecState = false
local EditingGalleryIndex = nil
local TempNewFileName = ""

-- Initialize UI position
local function InitUIPosition()
    local success = pcall(function()
        Sidebar.Position = UDim2.new(-1.5, 0, 0.075, 0)
        MainFrame.Position = UDim2.new(3, 0, 0.076, 0)
    end)
    if not success then
        Debug("Failed to set initial UI position")
    end
end

InitUIPosition()

-- Hide all pages initially
for _, page in pairs(AllPages) do
    if page then
        local success = pcall(function()
            page.Visible = false
        end)
        if not success then
            Debug("Failed to hide page: " .. tostring(page.Name))
        end
    end
end

-- Load saved settings
pcall(function()
    Internal.loadTheme()
    Internal.loadLang()
    Internal.loadTextSize()
    Internal.loadSyntaxEnabled()
end)

local StartupData = {page = "Executor"}
pcall(function()
    StartupData = Internal.loadStartup() or {page = "Executor"}
end)

-- Page mapping for startup
local StartupPageMap = {
    Executor = Pages.Executor,
    Home = Pages.Home,
    Gallery = Pages.Gallery,
    Scripts = Pages.Scripts,
    Profile = Pages.Profile,
    Extension = Pages.Extension or Pages.Extention
}

-- Setup editor
if ExecutorHandler and Editor then
    pcall(function()
        Internal.setupEditor(ExecutorHandler, Editor, LineNumberLabel)
        Debug("Editor setup complete")
    end)
else
    Debug("Could not setup editor - missing components")
    if not ExecutorHandler then Debug("  - ExecutorHandler missing") end
    if not Editor then Debug("  - Editor missing") end
end

-- Helper: Format date
local function FormatDate(t)
    t = t or os.time()
    local days = {"Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"}
    local months = {"Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"}
    local d = os.date("*t", t)
    return string.format("Created on %s %s, %02d", days[d.wday], months[d.month], d.day)
end

-- Helper: Get unique name
local function GetUniqueName(baseName, existingList)
    local counter = 1
    while true do
        local candidate = baseName .. " " .. counter
        local found = false
        for _, item in pairs(existingList) do
            if item.name == candidate then
                found = true
                break
            end
        end
        if not found then return candidate end
        counter = counter + 1
    end
end

-- Helper: Close all popups
local function CloseAllPopups()
    local popups = {FilePopup, ExtControlColors, ExtControlStart, ExtControlLang, 
                    TextSizeConfig, Step1, Step2, RenamePopup, DeletePopup, 
                    CreateScriptPopup, ScriptConfigPopup}
    for _, popup in ipairs(popups) do
        if popup then
            pcall(function() popup.Visible = false end)
        end
    end
end

-- Helper: Set transparency
local function SetTransparency(obj, transparency)
    if not obj then return end
    pcall(function()
        if obj:IsA("ImageButton") or obj:IsA("ImageLabel") then
            obj.ImageTransparency = transparency
        elseif obj:IsA("TextButton") or obj:IsA("TextLabel") or obj:IsA("Frame") then
            obj.BackgroundTransparency = transparency
        end
    end)
end

-- Save data
local function SaveData()
    pcall(function()
        if Tabs[CurrentTab] and Editor then
            Tabs[CurrentTab].content = Editor.Text
        end
        
        local tabData = {}
        for i, tab in ipairs(Tabs) do
            tabData[i] = {
                name = tab.name or ("Script " .. i),
                content = tab.content or "",
                createdOn = tab.createdOn or os.time()
            }
        end
        
        Internal.saveTabs(tabData)
        Internal.saveGallery(GalleryScripts)
    end)
end

local LastSave = 0
local function DebouncedSave()
    local now = tick()
    if now - LastSave > 2 then
        LastSave = now
        SaveData()
    end
end

-- Refresh tabs
local function RefreshTabs()
    if not TabScrollFrame then return end
    
    pcall(function()
        -- Clear existing tabs
        for _, child in ipairs(TabScrollFrame:GetChildren()) do
            if child.Name:match("^Tab%d+$") then
                child:Destroy()
            end
        end
        
        -- Get template
        local template = TabScrollFrame:FindFirstChild("Tab1") or TabScrollFrame:FindFirstChild("_C")
        if template then template = template:Clone() end
        if not template then return end
        
        -- Create tabs
        for i, data in ipairs(Tabs) do
            local newTab = template:Clone()
            newTab.Name = "Tab" .. i
            newTab.Parent = TabScrollFrame
            newTab.Visible = true
            newTab.LayoutOrder = i
            
            local nameLabel = newTab:FindFirstChild("TextLabel")
            if nameLabel then
                nameLabel.Text = data.name
            elseif newTab:IsA("TextButton") then
                newTab.Text = data.name
            end
            
            local btn = newTab:IsA("GuiButton") and newTab or newTab:FindFirstChildWhichIsA("GuiButton", true)
            if btn then
                ConnectClick(btn, function()
                    SwitchTab(i)
                end)
            end
        end
    end)
end

-- Switch tab
local TabSwitchDebounce = false
function SwitchTab(index)
    if TabSwitchDebounce then return end
    if not Tabs[index] then return end
    if CurrentTab == index then return end
    
    TabSwitchDebounce = true
    task.defer(function() TabSwitchDebounce = false end)
    
    pcall(function()
        -- Save current tab
        if Tabs[CurrentTab] and Editor then
            Tabs[CurrentTab].content = Editor.Text or ""
        end
        
        CurrentTab = index
        
        -- Load new tab content
        if Tabs[CurrentTab] and Editor then
            local newContent = Tabs[CurrentTab].content or ""
            
            if #newContent > 199999 then
                Editor:SetAttribute("IgnoreChange", true)
                Editor.Text = string.sub(newContent, 1, 199900) .. "\n-- [TRUNCATED]"
                Editor:SetAttribute("IgnoreChange", false)
            else
                Editor:SetAttribute("IgnoreChange", true)
                Editor.Text = newContent
                Editor:SetAttribute("IgnoreChange", false)
            end
        end
        
        SaveData()
    end)
end

-- Refresh gallery
local function RefreshGallery()
    if not GalleryScroll or not GalleryTemplate then return end
    
    pcall(function()
        -- Clear existing
        for _, child in pairs(GalleryScroll:GetChildren()) do
            if child ~= GalleryTemplate and child.Name ~= "AddButton" 
               and not child:IsA("UILayout") and not child:IsA("UIPadding") then
                child:Destroy()
            end
        end
        
        -- Create gallery items
        for i, sData in ipairs(GalleryScripts) do
            local newScript = GalleryTemplate:Clone()
            newScript.Name = "GalleryScript_" .. i
            newScript.Parent = GalleryScroll
            newScript.Visible = true
            newScript.LayoutOrder = i
            
            local nameLbl = FindRecursive(newScript, "ScriptName") or FindRecursive(newScript, "TextLabel")
            if nameLbl then nameLbl.Text = sData.name end
            
            local autoStatus = FindRecursive(newScript, "AutoExeON/OFF")
            if autoStatus then
                local status = sData.autoExec and "ON" or "OFF"
                autoStatus.Text = "AUTOEXE : " .. status
            end
            
            local delBtn = FindRecursive(newScript, "DeleteScript")
            if delBtn then
                ConnectClick(delBtn, function()
                    table.remove(GalleryScripts, i)
                    RefreshGallery()
                    SaveData()
                end)
            end
            
            local runBtn = FindRecursive(newScript, "ExecuteButton") or newScript
            ConnectClick(runBtn, function()
                Internal.exec(sData.script)
            end)
            
            local editBtn = FindRecursive(newScript, "EditScriptButton")
            ConnectClick(editBtn, function()
                EditingGalleryIndex = i
                TempAutoExecState = sData.autoExec
                
                local scRenameBox = ScriptConfigPopup and FindRecursive(ScriptConfigPopup, "RenameTextBox")
                local scScriptBox = ScriptConfigPopup and FindRecursive(ScriptConfigPopup, "ScriptTextBox")
                local scStatusInfo = ScriptConfigPopup and FindRecursive(ScriptConfigPopup, "StatusInfo")
                local scFileInfo = ScriptConfigPopup and FindRecursive(ScriptConfigPopup, "FileInfo")
                local scAutoOn = ScriptConfigPopup and FindRecursive(ScriptConfigPopup, "ON")
                local scAutoOff = ScriptConfigPopup and FindRecursive(ScriptConfigPopup, "OFF")
                
                if scRenameBox then scRenameBox.Text = sData.name end
                if scScriptBox then scScriptBox.Text = sData.script end
                if scStatusInfo then scStatusInfo.Text = "Status : " .. (TempAutoExecState and "ON" or "OFF") end
                if scFileInfo then scFileInfo.Text = FormatDate(sData.createdOn or os.time()) end
                
                SetTransparency(scAutoOn, TempAutoExecState and 0 or 0.6)
                SetTransparency(scAutoOff, TempAutoExecState and 0.6 or 0)
                
                FilePopup.Visible = true
                if ScriptConfigPopup then
                    ScriptConfigPopup.Visible = true
                end
            end)
        end
    end)
end

-- Load saved data
local function LoadData()
    pcall(function()
        local tabData = Internal.loadTabs()
        GalleryScripts = Internal.loadGallery() or {}
        Tabs = {}
        
        if #tabData > 0 then
            for _, data in ipairs(tabData) do
                table.insert(Tabs, {
                    name = data.name,
                    content = data.content,
                    createdOn = data.createdOn or os.time()
                })
            end
        else
            table.insert(Tabs, {
                name = "Script 1",
                content = "",
                createdOn = os.time()
            })
        end
        
        RefreshTabs()
        RefreshGallery()
        CurrentTab = 1
        
        if Tabs[CurrentTab] and Editor then
            Editor:SetAttribute("IgnoreChange", true)
            Editor.Text = Tabs[CurrentTab].content or ""
            Editor:SetAttribute("IgnoreChange", false)
        end
    end)
end

-- FIXED: Page switching with proper executor element handling
local function SwitchPage(newPage, btn, title)
    if IsAnimating or newPage == CurrentPage or not IsUIOpen then return end
    IsAnimating = true
    
    local ok, err = pcall(function()
        -- Show/hide global search bar
        if GlobalSearchBar then
            GlobalSearchBar.Visible = (newPage == Pages.Scripts)
        end
        
        -- FIXED: Pass executor elements to switch function
        Internal.switch(CurrentPage, newPage, AllButtons, btn, ExecutorElements)
        CurrentPage = newPage
        
        -- Update title
        local titleMap = {
            [Pages.Home] = "Home",
            [Pages.Executor] = "Editor",
            [Pages.Gallery] = "Gallery",
            [Pages.Scripts] = "Script Hub",
            [Pages.Profile] = "Settings",
            [Pages.Extension] = "Extension"
        }
        
        CurrentTitle = titleMap[newPage] or title
        if PageTitleLabel then
            PageTitleLabel.Text = CurrentTitle
        end
    end)
    
    if not ok then
        warn("[Ronix] SwitchPage error: " .. tostring(err))
    end
    
    task.spawn(function()
        wait(0.4)
        IsAnimating = false
    end)
end

-- Toggle UI visibility
local function ToggleUI()
    if IsAnimating then return end
    IsAnimating = true
    
    local ok, err = pcall(function()
        if IsUIOpen then
            -- Close UI
            Internal.close(Sidebar, MainFrame, AllPages)
            if CloseUIBtn then CloseUIBtn.Visible = false end
        else
            -- Open UI
            local startPage = StartupPageMap[StartupData.page or "Executor"] or Pages.Executor or Pages.Home
            CurrentPage = startPage
            
            -- Show startup page
            for _, page in pairs(AllPages) do
                if page then
                    page.Visible = (page == startPage)
                    
                    -- FIXED: Handle executor elements on open
                    if Pages.Executor and page == Pages.Executor and page == startPage then
                        for _, elem in pairs(ExecutorElements) do
                            if elem then elem.Visible = true end
                        end
                    elseif Pages.Executor and page == Pages.Executor then
                        for _, elem in pairs(ExecutorElements) do
                            if elem then elem.Visible = false end
                        end
                    end
                end
            end
            
            -- Set active button
            local startBtn = nil
            if startPage == Pages.Executor then startBtn = Buttons.Executor
            elseif startPage == Pages.Home then startBtn = Buttons.Home
            elseif startPage == Pages.Gallery then startBtn = Buttons.Gallery
            elseif startPage == Pages.Scripts then startBtn = Buttons.Scripts
            elseif startPage == Pages.Profile then startBtn = Buttons.Profile end
            
            -- Update button visuals
            for _, btn in pairs(AllButtons) do
                if btn and btn.Name ~= "ProfileButton" then
                    btn.ImageTransparency = 1
                    local stroke = btn:FindFirstChild("UIStroke")
                    if stroke then stroke.Transparency = 1 end
                end
            end
            
            if startBtn and startBtn.Name ~= "ProfileButton" then
                startBtn.ImageTransparency = 0.6
                local stroke = startBtn:FindFirstChild("UIStroke")
                if stroke then stroke.Transparency = 0.6 end
            end
            
            Internal.open(Sidebar, MainFrame, startPage)
            
            -- Update title
            local titleMap = {
                [Pages.Executor] = "Editor",
                [Pages.Home] = "Home",
                [Pages.Gallery] = "Gallery",
                [Pages.Scripts] = "Script Hub",
                [Pages.Profile] = "Settings",
                [Pages.Extension] = "Extension"
            }
            
            CurrentTitle = titleMap[startPage] or "Editor"
            if PageTitleLabel then
                PageTitleLabel.Text = CurrentTitle
            end
            
            if CloseUIBtn then CloseUIBtn.Visible = true end
        end
        
        IsUIOpen = not IsUIOpen
    end)
    
    if not ok then
        warn("[Ronix] ToggleUI error: " .. tostring(err))
    end
    
    task.spawn(function()
        wait(1)
        IsAnimating = false
    end)
end

-- Connect sidebar buttons
if Buttons.Home then
    ConnectClick(Buttons.Home, function()
        SwitchPage(Pages.Home, Buttons.Home, "Home")
    end)
end

if Buttons.Executor then
    ConnectClick(Buttons.Executor, function()
        SwitchPage(Pages.Executor, Buttons.Executor, "Executor")
    end)
end

if Buttons.Gallery then
    ConnectClick(Buttons.Gallery, function()
        SwitchPage(Pages.Gallery, Buttons.Gallery, "Gallery")
    end)
end

if Buttons.Scripts then
    ConnectClick(Buttons.Scripts, function()
        SwitchPage(Pages.Scripts, Buttons.Scripts, "Scripts")
    end)
end

if Buttons.Profile then
    ConnectClick(Buttons.Profile, function()
        SwitchPage(Pages.Profile, Buttons.Profile, "Profile")
    end)
end

-- Connect UI toggle
if UIToggleBtn then
    ConnectClick(UIToggleBtn, ToggleUI)
end

if CloseUIBtn then
    ConnectClick(CloseUIBtn, function()
        if IsUIOpen then ToggleUI() end
    end)
    CloseUIBtn.Visible = false
end

-- Connect executor buttons
if ExecuteBtn then
    ConnectClick(ExecuteBtn, function()
        local code = Editor and Editor.Text or ""
        if code and code:gsub("%s", "") ~= "" then
            Internal.exec(code)
        end
        SaveData()
    end)
end

if PasteBtn then
    ConnectClick(PasteBtn, function()
        if Editor then Internal.paste(Editor) end
        SaveData()
    end)
end

if EraseBtn then
    ConnectClick(EraseBtn, function()
        if Editor then Internal.clear(Editor) end
        SaveData()
    end)
end

if AddTabBtn then
    ConnectClick(AddTabBtn, function()
        if Step1 then
            CloseAllPopups()
            FilePopup.Visible = true
            Step1.Visible = true
            if Step1NameBox then Step1NameBox.Text = "" end
        end
    end)
end

if EditTabBtn then
    ConnectClick(EditTabBtn, function()
        if Tabs[CurrentTab] and RenamePopup then
            if OldNameLabel then OldNameLabel.Text = "rename: " .. Tabs[CurrentTab].name end
            if NewNameTextBox then NewNameTextBox.Text = Tabs[CurrentTab].name end
            FilePopup.Visible = true
            RenamePopup.Visible = true
        end
    end)
end

if DeleteTabBtn then
    ConnectClick(DeleteTabBtn, function()
        if #Tabs >= 1 and Tabs[CurrentTab] and DeletePopup then
            if FileNameLabel then FileNameLabel.Text = "delete: " .. Tabs[CurrentTab].name end
            FilePopup.Visible = true
            DeletePopup.Visible = true
        end
    end)
end

if RenameBtn then
    ConnectClick(RenameBtn, function()
        if NewNameTextBox and Tabs[CurrentTab] then
            local newName = NewNameTextBox.Text
            if newName ~= "" then
                Tabs[CurrentTab].name = newName
                RefreshTabs()
                SaveData()
            end
        end
        CloseAllPopups()
    end)
end

if CancelRenameBtn then
    ConnectClick(CancelRenameBtn, CloseAllPopups)
end

if DeleteBtn then
    ConnectClick(DeleteBtn, function()
        if #Tabs >= 1 then
            table.remove(Tabs, CurrentTab)
            
            if #Tabs == 0 then
                table.insert(Tabs, {
                    name = "Script 1",
                    content = "",
                    createdOn = os.time()
                })
                CurrentTab = 1
            elseif CurrentTab > #Tabs then
                CurrentTab = #Tabs
            end
            
            RefreshTabs()
            
            if Tabs[CurrentTab] and Editor then
                Editor:SetAttribute("IgnoreChange", true)
                Editor.Text = Tabs[CurrentTab].content or ""
                Editor:SetAttribute("IgnoreChange", false)
            end
            
            SaveData()
        end
        CloseAllPopups()
    end)
end

if CancelDeleteBtn then
    ConnectClick(CancelDeleteBtn, CloseAllPopups)
end

-- Step 1 (create tab)
if Step1NextBtn then
    ConnectClick(Step1NextBtn, function()
        local userInputName = Step1NameBox and Step1NameBox.Text or ""
        
        if userInputName == "" or userInputName == " " then
            TempNewFileName = GetUniqueName("Script", Tabs)
        else
            TempNewFileName = userInputName
        end
        
        if Step1 then Step1.Visible = false end
        if Step2 then
            Step2.Visible = true
            local scriptBox = FindRecursive(Step2, "ScriptTextBox")
            if scriptBox then scriptBox.Text = "" end
        end
    end)
end

if Step1CancelBtn then
    ConnectClick(Step1CancelBtn, CloseAllPopups)
end

-- Step 2 (confirm create)
if Step2CreateBtn then
    ConnectClick(Step2CreateBtn, function()
        local scriptBox = FindRecursive(Step2, "ScriptTextBox")
        local code = scriptBox and scriptBox.Text or ""
        
        table.insert(Tabs, {
            name = TempNewFileName,
            content = code,
            createdOn = os.time()
        })
        
        CurrentTab = #Tabs
        RefreshTabs()
        
        if Tabs[CurrentTab] and Editor then
            Editor:SetAttribute("IgnoreChange", true)
            Editor.Text = Tabs[CurrentTab].content
            Editor:SetAttribute("IgnoreChange", false)
        end
        
        SaveData()
        CloseAllPopups()
    end)
end

if Step2CancelBtn then
    ConnectClick(Step2CancelBtn, CloseAllPopups)
end

-- Profile toggles
local ProfileToggles = {}
local SavedToggles = {}
pcall(function()
    SavedToggles = Internal.loadToggles() or {}
end)

local function HandleButtonToggle(btn, textPrefix, onClick)
    if not btn then return end
    
    local savedState = SavedToggles[textPrefix] or false
    local toggleData = {btn = btn, prefix = textPrefix, state = savedState}
    table.insert(ProfileToggles, toggleData)
    
    local label = btn:FindFirstChild("Label") or btn:FindFirstChild("TextLabel")
    
    local function Update(newState)
        toggleData.state = newState
        
        pcall(function()
            TweenService:Create(btn, TweenInfo.new(0.3), {
                ImageTransparency = newState and 0 or 0.6
            }):Play()
        end)
        
        if label then
            label.Text = textPrefix .. " : " .. (newState and "ON" or "OFF")
        end
        
        Internal.setToggle(textPrefix, newState)
    end
    
    Update(savedState)
    
    if savedState and onClick then onClick(savedState) end
    
    ConnectClick(btn, function()
        local newState = not toggleData.state
        Update(newState)
        if onClick then onClick(newState) end
        SaveData()
    end)
end

-- Anti-AFK
local AntiAfkConnection
HandleButtonToggle(AntiAfkBtn, "ANTI AFK", function(state)
    if state then
        AntiAfkConnection = Players.LocalPlayer.Idled:Connect(function()
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new())
        end)
    else
        if AntiAfkConnection then
            AntiAfkConnection:Disconnect()
            AntiAfkConnection = nil
        end
    end
end)

-- Unlock FPS
HandleButtonToggle(UnlockFpsBtn, "UNLOCK FPS", function(state)
    if state then
        Internal.unlockFPS()
    else
        pcall(function() setfpscap(60) end)
    end
end)

-- Enlarge UI
HandleButtonToggle(EnlargeBtn, "ENLARGE UI", function(state)
    pcall(function()
        TweenService:Create(UI, TweenInfo.new(0.2), {
            Size = state and UDim2.new(1.1, 0, 1.1, 0) or UDim2.new(1, 0, 1, 0)
        }):Play()
    end)
end)

-- Console
if ConsoleBtn then
    HandleButtonToggle(ConsoleBtn, "OPEN CONSOLE", function(state)
        pcall(function()
            StarterGui:SetCore("DevConsoleVisible", state)
        end)
    end)
end

-- Streamer mode
if StreamerModeBtn then
    HandleButtonToggle(StreamerModeBtn, "STREAMER MODE", function(state)
        IsStreamerMode = state
        if UIToggleBtn then UIToggleBtn.Visible = not state end
    end)
end

-- Luau syntax toggle
if LuauSyntaxBtn then
    local label = FindRecursive(LuauSyntaxBtn, "Label") or FindRecursive(LuauSyntaxBtn, "TextLabel")
    if label then label.Text = "LUAU SYNTAX : ON" end
    
    ConnectClick(LuauSyntaxBtn, function()
        Internal.useSyntax = not Internal.useSyntax
        
        pcall(function()
            TweenService:Create(LuauSyntaxBtn, TweenInfo.new(0.3), {
                ImageTransparency = Internal.useSyntax and 0 or 0.6
            }):Play()
        end)
        
        if label then
            label.Text = "LUAU SYNTAX : " .. (Internal.useSyntax and "ON" or "OFF")
        end
        
        if Internal.forceUpdate then Internal.forceUpdate() end
    end)
end

-- Editor text change
if Editor then
    Editor:GetPropertyChangedSignal("Text"):Connect(function()
        if Editor:GetAttribute("IgnoreChange") then return end
        if Tabs[CurrentTab] then
            Tabs[CurrentTab].content = Editor.Text
            DebouncedSave()
        end
    end)
end

-- Initialize
task.spawn(function()
    wait(0.5)
    LoadData()
    
    -- Set initial page
    local startPage = StartupPageMap[StartupData.page or "Executor"] or Pages.Executor or Pages.Home
    if not startPage then
        Debug("No start page found, using first available")
        for _, page in pairs(AllPages) do
            if page then
                startPage = page
                break
            end
        end
    end
    
    CurrentPage = startPage
    
    for _, page in pairs(AllPages) do
        if page then
            pcall(function()
                page.Visible = (page == startPage)
            end)
            
            -- Handle executor elements on init
            if Pages.Executor then
                if page == Pages.Executor and page == startPage then
                    for _, elem in pairs(ExecutorElements) do
                        if elem then elem.Visible = true end
                    end
                elseif page == Pages.Executor then
                    for _, elem in pairs(ExecutorElements) do
                        if elem then elem.Visible = false end
                    end
                end
            end
        end
    end
    
    -- Set active button
    local startBtn = nil
    if startPage == Pages.Executor then startBtn = Buttons.Executor
    elseif startPage == Pages.Home then startBtn = Buttons.Home
    elseif startPage == Pages.Gallery then startBtn = Buttons.Gallery
    elseif startPage == Pages.Scripts then startBtn = Buttons.Scripts
    elseif startPage == Pages.Profile then startBtn = Buttons.Profile end
    
    if startBtn then
        pcall(function()
            startBtn.ImageTransparency = 0.6
            local stroke = startBtn:FindFirstChild("UIStroke")
            if stroke then stroke.Transparency = 0.6 end
        end)
    end
    
    -- Update title
    local titleMap = {
        [Pages.Executor] = "Editor",
        [Pages.Home] = "Home",
        [Pages.Gallery] = "Gallery",
        [Pages.Scripts] = "Script Hub",
        [Pages.Profile] = "Settings",
        [Pages.Extension] = "Extension"
    }
    
    CurrentTitle = titleMap[startPage] or "Editor"
    if PageTitleLabel then
        PageTitleLabel.Text = CurrentTitle
    end
    
    -- Run auto-exec scripts
    for _, s in pairs(GalleryScripts) do
        if s.autoExec and s.script then
            local shouldExec = false
            pcall(function()
                shouldExec = Internal.getToggle("AUTO EXECUTE")
            end)
            if shouldExec then
                Internal.exec(s.script)
            end
        end
    end
    
    Debug("Initialization complete!")
end)

print("[Ronix] Client loaded successfully from GitHub!")
