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

-- Load the module
local script = script -- This references the LocalScript itself
local InternalModule = script:FindFirstChild("RonixUI_Module")
if not InternalModule then
    warn("[Ronix] Module not found! Make sure RonixUI_Module is a child of this script.")
    return
end

local Internal = require(InternalModule)

-- Get UI elements
local ScreenGui = script.Parent
if gethui then
    pcall(function() ScreenGui.Parent = gethui() end)
end

local UI = ScreenGui:WaitForChild("UI")
local Sidebar = UI:WaitForChild("SideBar")
local SidebarFrame = Sidebar:WaitForChild("Frame")
local MainFrame = UI:WaitForChild("SideFrame")

-- Find all pages
local Pages = {
    Home = MainFrame:FindFirstChild("Home"),
    Executor = MainFrame:FindFirstChild("Executor"),
    Gallery = MainFrame:FindFirstChild("Gallery"),
    Scripts = MainFrame:FindFirstChild("Scripts"),
    Profile = MainFrame:FindFirstChild("Profile"),
    Extension = MainFrame:FindFirstChild("Extention")
}

-- Find sidebar buttons
local Buttons = {
    Home = SidebarFrame:FindFirstChild("HomeButton"),
    Executor = SidebarFrame:FindFirstChild("ExecutorButton"),
    Gallery = SidebarFrame:FindFirstChild("GalleryButton") or SidebarFrame:FindFirstChild("PremiumButton"),
    Scripts = SidebarFrame:FindFirstChild("ScriptsButton"),
    Profile = Sidebar:FindFirstChild("ProfileButton")
}

-- Find executor-specific elements that need to be hidden when not on executor page
local ExecutorElements = {}
if Pages.Executor then
    -- Button footer (Execute, Paste, Clear, Save buttons)
    local buttonFooter = Pages.Executor:FindFirstChild("ButtonFooter")
    if buttonFooter then
        table.insert(ExecutorElements, buttonFooter)
    end
    
    -- Tab header (tab switching)
    local tabHeader = Pages.Executor:FindFirstChild("TabHeader")
    if tabHeader then
        table.insert(ExecutorElements, tabHeader)
    end
    
    -- Editor header
    local editorHeader = Pages.Executor:FindFirstChild("EditorHeader")
    if editorHeader then
        table.insert(ExecutorElements, editorHeader)
    end
end

-- Helper function to find elements recursively
local function FindRecursive(parent, name)
    if not parent then return nil end
    local found = parent:FindFirstChild(name)
    if found then return found end
    for _, child in pairs(parent:GetChildren()) do
        found = FindRecursive(child, name)
        if found then return found end
    end
    return nil
end

-- Find page title label
local PageTitleLabel = FindRecursive(Sidebar, "Selected") or FindRecursive(Sidebar, "Title")

-- Helper to connect button clicks
local function ConnectClick(obj, callback)
    if not obj then return end
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
end

-- Find executor components
local ExecutorHandler = Pages.Executor and Pages.Executor:FindFirstChild("EditorHeader") 
    and Pages.Executor.EditorHeader:FindFirstChild("ScrollingFrame")
local ExecutorButtons = Pages.Executor and Pages.Executor:FindFirstChild("ButtonFooter")
local Editor = ExecutorHandler and (ExecutorHandler:FindFirstChild("Editor") 
    or (ExecutorHandler:FindFirstChild("ContentContainer") 
        and ExecutorHandler.ContentContainer:FindFirstChild("Editor")))
local TabHeader = Pages.Executor and Pages.Executor:FindFirstChild("TabHeader")
local TabScrollFrame = TabHeader and TabHeader:FindFirstChild("ScrollingFrame")
local LineNumberLabel = ExecutorHandler and ExecutorHandler:FindFirstChild("Line") 
    and ExecutorHandler.Line:FindFirstChild("Line Number")

-- Find other UI elements
local FilePopup = UI:WaitForChild("FilePopUp")
local GlobalSearchBar = Pages.Scripts and Pages.Scripts:FindFirstChild("SearchBar")

-- Gallery elements
local GalleryScroll = Pages.Gallery and FindRecursive(Pages.Gallery, "ScrollingFrame")
local GalleryAddBtn = Pages.Gallery and FindRecursive(Pages.Gallery, "AddButton")
local GalleryTemplate = Pages.Gallery and FindRecursive(Pages.Gallery, "Script")
local GallerySearchBar = Pages.Gallery and FindRecursive(Pages.Gallery, "SearchBar")
local GallerySearchInput = GallerySearchBar and FindRecursive(GallerySearchBar, "TextBox")

-- Scripts page elements
local ScriptsScroll = Pages.Scripts and FindRecursive(Pages.Scripts, "ScrollingFrame")
local ScriptsSearchBar = Pages.Scripts and Pages.Scripts:FindFirstChild("SearchBar")
local SearchInput = ScriptsSearchBar and FindRecursive(ScriptsSearchBar, "TextBox")
local SearchBtn = ScriptsSearchBar and ScriptsSearchBar:FindFirstChild("Search")
local FilterBtn = ScriptsSearchBar and ScriptsSearchBar:FindFirstChild("Filter")
local FilterBar = Pages.Scripts and Pages.Scripts:FindFirstChild("FilterBar")

-- Profile elements
local ProfileList = Pages.Profile and Pages.Profile:FindFirstChild("ScrollingFrame")
local ProfileSearchBar = Pages.Profile and FindRecursive(Pages.Profile, "SearchBar")
local ProfileSearchInput = ProfileSearchBar and FindRecursive(ProfileSearchBar, "TextBox")
local ProfileExtensionBtn = ProfileSearchBar and FindRecursive(ProfileSearchBar, "ExtentionButton")

-- Extension elements
local ExtControlColors = FindRecursive(UI, "ExtentionControlPanel")
local ExtControlStart = FindRecursive(UI, "ExtentionControlPanel1") or ExtControlColors
local ExtControlLang = FindRecursive(UI, "ExtentionControlPanel2")
local TextSizeConfig = FindRecursive(FilePopup, "EditorTExtSIzeConfig") or FindRecursive(FilePopup, "FileConfig")

-- Popup elements
local RenamePopup = FindRecursive(FilePopup, "FileConfig")
local RenameBtn = RenamePopup and FindRecursive(RenamePopup, "RenameButton")
local CancelRenameBtn = RenamePopup and FindRecursive(RenamePopup, "CancelButton")
local OldNameLabel = RenamePopup and FindRecursive(RenamePopup, "FileLabel")
local NewNameTextBox = RenamePopup and FindRecursive(RenamePopup, "RenameTextBox")

local DeletePopup = FindRecursive(FilePopup, "FileDelete")
local DeleteBtn = DeletePopup and FindRecursive(DeletePopup, "DeleteButton")
local CancelDeleteBtn = DeletePopup and FindRecursive(DeletePopup, "CancelButton")
local FileNameLabel = DeletePopup and FindRecursive(DeletePopup, "FileLabel")

local Step1 = FindRecursive(FilePopup, "FileCreateStep1")
local Step1NameBox = Step1 and FindRecursive(Step1, "NameTextBox")
local Step1NextBtn = Step1 and FindRecursive(Step1, "NextButton")
local Step1CancelBtn = Step1 and FindRecursive(Step1, "CancelButton")

local Step2 = FindRecursive(FilePopup, "FileCreateStep2")
local Step2ScriptBox = Step2 and FindRecursive(Step2, "ScriptTextBox")
local Step2CreateBtn = Step2 and FindRecursive(Step2, "CreateButton")
local Step2CancelBtn = Step2 and FindRecursive(Step2, "CancelButton")

local CreateScriptPopup = FindRecursive(FilePopup, "CreateScript")
local ScriptConfigPopup = FindRecursive(FilePopup, "ScriptConfig")

-- Executor buttons
local ExecuteBtn = ExecutorButtons and ExecutorButtons:FindFirstChild("ExecuteButton")
local PasteBtn = ExecutorButtons and ExecutorButtons:FindFirstChild("PasteButton")
local EraseBtn = ExecutorButtons and ExecutorButtons:FindFirstChild("EraseButton")
local EditTabBtn = ExecutorButtons and ExecutorButtons:FindFirstChild("EditTabButton")
local DeleteTabBtn = ExecutorButtons and (ExecutorButtons:FindFirstChild("DeleteButton") 
    or ExecutorButtons:FindFirstChild("TrashButton"))
local AddTabBtn = TabHeader and TabHeader:FindFirstChild("AddButton")

-- UI Toggle
local UIToggleBtn = script.Parent:FindFirstChild("UIButton")
local CloseUIBtn = FindRecursive(UI, "CloseUIButton")

-- Profile buttons
local AutoBtn = ProfileList and ProfileList:FindFirstChild("AutoButton")
local AntiAfkBtn = ProfileList and ProfileList:FindFirstChild("AntiAfkButton")
local UnlockFpsBtn = ProfileList and ProfileList:FindFirstChild("FPSButton")
local ConsoleBtn = ProfileList and ProfileList:FindFirstChild("ConsoleButton")
local EnlargeBtn = ProfileList and ProfileList:FindFirstChild("EnlargeButton")
local LuauSyntaxBtn = ProfileList and FindRecursive(ProfileList, "LuauSyntaxButton")
local StreamerModeBtn = ProfileList and FindRecursive(ProfileList, "StreamerModeButton")

-- State variables
local CurrentPage = Pages.Executor
local CurrentTitle = "Editor"
local AllPages = {Pages.Home, Pages.Executor, Pages.Gallery, Pages.Scripts, Pages.Profile, Pages.Extension}
local AllButtons = {Buttons.Home, Buttons.Executor, Buttons.Gallery, Buttons.Scripts, Buttons.Profile}
local Tabs = {}
local CurrentTab = 1
local GalleryScripts = {}
local IsUIOpen = false
local IsAnimating = false
local IsStreamerMode = false
local TempAutoExecState = false
local EditingGalleryIndex = nil
local TempNewFileName = ""

-- Initialize UI position
Sidebar.Position = UDim2.new(-1.5, 0, 0.075, 0)
MainFrame.Position = UDim2.new(3, 0, 0.076, 0)

-- Hide all pages initially
for _, page in pairs(AllPages) do
    if page then page.Visible = false end
end

-- Load saved settings
Internal.loadTheme()
Internal.loadLang()
Internal.loadTextSize()
Internal.loadSyntaxEnabled()

local StartupData = Internal.loadStartup()

-- Page mapping for startup
local StartupPageMap = {
    Executor = Pages.Executor,
    Home = Pages.Home,
    Gallery = Pages.Gallery,
    Scripts = Pages.Scripts,
    Profile = Pages.Profile,
    Extension = Pages.Extension
}

-- Setup editor
if ExecutorHandler and Editor then
    Internal.setupEditor(ExecutorHandler, Editor, LineNumberLabel)
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
    if FilePopup then FilePopup.Visible = false end
    if ExtControlColors then ExtControlColors.Visible = false end
    if ExtControlStart then ExtControlStart.Visible = false end
    if ExtControlLang then ExtControlLang.Visible = false end
    if TextSizeConfig then TextSizeConfig.Visible = false end
    if Step1 then Step1.Visible = false end
    if Step2 then Step2.Visible = false end
    if RenamePopup then RenamePopup.Visible = false end
    if DeletePopup then DeletePopup.Visible = false end
    if CreateScriptPopup then CreateScriptPopup.Visible = false end
    if ScriptConfigPopup then ScriptConfigPopup.Visible = false end
end

-- Helper: Set transparency
local function SetTransparency(obj, transparency)
    if not obj then return end
    if obj:IsA("ImageButton") or obj:IsA("ImageLabel") then
        obj.ImageTransparency = transparency
    elseif obj:IsA("TextButton") or obj:IsA("TextLabel") or obj:IsA("Frame") then
        obj.BackgroundTransparency = transparency
    end
end

-- Save data
local function SaveData()
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
end

-- Switch tab
local TabSwitchDebounce = false
function SwitchTab(index)
    if TabSwitchDebounce then return end
    if not Tabs[index] then return end
    if CurrentTab == index then return end
    
    TabSwitchDebounce = true
    task.defer(function() TabSwitchDebounce = false end)
    
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
end

-- Refresh gallery
local function RefreshGallery()
    if not GalleryScroll or not GalleryTemplate then return end
    
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
end

-- Load saved data
local function LoadData()
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
            local startPage = StartupPageMap[StartupData.page or "Executor"] or Pages.Executor
            CurrentPage = startPage
            
            -- Show startup page
            for _, page in pairs(AllPages) do
                if page then
                    page.Visible = (page == startPage)
                    
                    -- FIXED: Handle executor elements on open
                    if page.Name == "Executor" and page == startPage then
                        for _, elem in pairs(ExecutorElements) do
                            if elem then elem.Visible = true end
                        end
                    elseif page.Name == "Executor" then
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
local SavedToggles = Internal.loadToggles()

local function HandleButtonToggle(btn, textPrefix, onClick)
    if not btn then return end
    
    local savedState = SavedToggles[textPrefix] or false
    local toggleData = {btn = btn, prefix = textPrefix, state = savedState}
    table.insert(ProfileToggles, toggleData)
    
    local label = btn:FindFirstChild("Label") or btn:FindFirstChild("TextLabel")
    
    local function Update(newState)
        toggleData.state = newState
        
        TweenService:Create(btn, TweenInfo.new(0.3), {
            ImageTransparency = newState and 0 or 0.6
        }):Play()
        
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
    TweenService:Create(UI, TweenInfo.new(0.2), {
        Size = state and UDim2.new(1.1, 0, 1.1, 0) or UDim2.new(1, 0, 1, 0)
    }):Play()
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
        
        TweenService:Create(LuauSyntaxBtn, TweenInfo.new(0.3), {
            ImageTransparency = Internal.useSyntax and 0 or 0.6
        }):Play()
        
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
    local startPage = StartupPageMap[StartupData.page or "Executor"] or Pages.Executor
    CurrentPage = startPage
    
    for _, page in pairs(AllPages) do
        if page then
            page.Visible = (page == startPage)
            
            -- FIXED: Handle executor elements on init
            if page.Name == "Executor" and page == startPage then
                for _, elem in pairs(ExecutorElements) do
                    if elem then elem.Visible = true end
                end
            elseif page.Name == "Executor" then
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
    
    if startBtn then
        startBtn.ImageTransparency = 0.6
        local stroke = startBtn:FindFirstChild("UIStroke")
        if stroke then stroke.Transparency = 0.6 end
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
        if s.autoExec and s.script and Internal.getToggle("AUTO EXECUTE") then
            Internal.exec(s.script)
        end
    end
end)

print("[Ronix] Client loaded successfully!")
