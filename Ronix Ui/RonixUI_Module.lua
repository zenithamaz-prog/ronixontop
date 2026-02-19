local Module = {}

-- Services
local cloneref = cloneref or function(o) return o end
local HttpService = cloneref(game:GetService("HttpService"))
local TweenService = cloneref(game:GetService("TweenService"))
local TextService = cloneref(game:GetService("TextService"))
local UserInputService = cloneref(game:GetService("UserInputService"))
local Players = cloneref(game:GetService("Players"))
local MarketplaceService = cloneref(game:GetService("MarketplaceService"))

-- Exploit functions
local getgenv = getgenv or function() return {} end
local setclipboard = setclipboard or toclipboard or function() end
local getclipboard = getclipboard or fromclipboard or function() return nil end
local setfpscap = setfpscap
local writefileFunc = writefile
local readfileFunc = readfile
local isfileFunc = isfile
local isfolderFunc = isfolder
local makefolderFunc = makefolder
local listfilesFunc = listfiles
local delfileFunc = delfile

-- File paths
local RONIX_ROOT = "RonixUI"
local DATA_PATH = RONIX_ROOT .. "/data"
local SCRIPTS_PATH = RONIX_ROOT .. "/scripts"

-- Editor settings
local EDITOR_FONT = Enum.Font.Code
local LINE_GAP = 35
local LINE_HEIGHT = 1.15

-- State
Module.currentTheme = "Purple"
Module.currentLang = "English"
Module.currentSize = 18
Module.useSyntax = true
Module.toggleStates = {}
Module.forceUpdate = nil

-- Color themes
Module.Themes = {
    Purple = {
        keyword = "#c792ea", keyword2 = "#f78c6c", builtin = "#82aaff",
        string = "#c3e88d", number = "#f78c6c", comment = "#676e95",
        operator = "#89ddff", bracket = "#89ddff", method = "#82aaff",
        global = "#f07178", ident = "#A6ACCD", symbol = "#89ddff",
        special = "#ff5370"
    },
    Dark = {
        keyword = "#ff79c6", keyword2 = "#bd93f9", builtin = "#8be9fd",
        string = "#f1fa8c", number = "#bd93f9", comment = "#6272a4",
        operator = "#ff79c6", bracket = "#f8f8f2", method = "#50fa7b",
        global = "#ff79c6", ident = "#f8f8f2", symbol = "#ff79c6",
        special = "#ff5555"
    },
    Red = {
        keyword = "#ff6b6b", keyword2 = "#ff8e8e", builtin = "#ff5252",
        string = "#ffb4b4", number = "#ff1744", comment = "#8d6e63",
        operator = "#ffab91", bracket = "#ffccbc", method = "#ff8a80",
        global = "#ff5722", ident = "#ffebee", symbol = "#ff7043",
        special = "#d32f2f"
    },
    Blue = {
        keyword = "#4fc3f7", keyword2 = "#29b6f6", builtin = "#03a9f4",
        string = "#81d4fa", number = "#0288d1", comment = "#546e7a",
        operator = "#039be5", bracket = "#b3e5fc", method = "#00bcd4",
        global = "#0091ea", ident = "#e1f5fe", symbol = "#0277bd",
        special = "#01579b"
    },
    Green = {
        keyword = "#69f0ae", keyword2 = "#00e676", builtin = "#00c853",
        string = "#b9f6ca", number = "#64dd17", comment = "#558b2f",
        operator = "#76ff03", bracket = "#ccff90", method = "#76ff03",
        global = "#33691e", ident = "#f1f8e9", symbol = "#558b2f",
        special = "#1b5e20"
    },
    Orange = {
        keyword = "#ffcc80", keyword2 = "#ffb74d", builtin = "#ffa726",
        string = "#ffe0b2", number = "#fb8c00", comment = "#8d6e63",
        operator = "#ff9800", bracket = "#fff3e0", method = "#f57c00",
        global = "#ef6c00", ident = "#fff8e1", symbol = "#e65100",
        special = "#bf360c"
    },
    Pink = {
        keyword = "#f48fb1", keyword2 = "#f06292", builtin = "#ec407a",
        string = "#f8bbd9", number = "#d81b60", comment = "#880e4f",
        operator = "#ff4081", bracket = "#fce4ec", method = "#c2185b",
        global = "#ad1457", ident = "#fce4ec", symbol = "#880e4f",
        special = "#560027"
    },
    Teal = {
        keyword = "#80cbc4", keyword2 = "#4db6ac", builtin = "#26a69a",
        string = "#b2dfdb", number = "#00897b", comment = "#00695c",
        operator = "#1de9b6", bracket = "#e0f2f1", method = "#00bfa5",
        global = "#004d40", ident = "#e0f2f1", symbol = "#00695c",
        special = "#003d33"
    },
    Yellow = {
        keyword = "#fff59d", keyword2 = "#fff176", builtin = "#ffee58",
        string = "#fff9c4", number = "#fdd835", comment = "#f9a825",
        operator = "#ffeb3b", bracket = "#fffde7", method = "#fbc02d",
        global = "#f57f17", ident = "#fffde7", symbol = "#f9a825",
        special = "#e65100"
    },
    Midnight = {
        keyword = "#7c4dff", keyword2 = "#651fff", builtin = "#6200ea",
        string = "#b388ff", number = "#311b92", comment = "#4527a0",
        operator = "#9575cd", bracket = "#d1c4e9", method = "#7e57c2",
        global = "#512da8", ident = "#ede7f6", symbol = "#673ab7",
        special = "#311b92"
    }
}

local ActiveColors = Module.Themes.Purple

-- Lua keywords
local Keywords = {
    ["and"] = "keyword", ["break"] = "keyword", ["do"] = "keyword",
    ["else"] = "keyword", ["elseif"] = "keyword", ["end"] = "keyword",
    ["for"] = "keyword", ["function"] = "keyword", ["if"] = "keyword",
    ["in"] = "keyword", ["local"] = "keyword", ["not"] = "keyword",
    ["or"] = "keyword", ["repeat"] = "keyword", ["then"] = "keyword",
    ["until"] = "keyword", ["while"] = "keyword", ["continue"] = "keyword",
    ["export"] = "keyword", ["true"] = "keyword2", ["false"] = "keyword2",
    ["nil"] = "keyword2", ["self"] = "self", ["type"] = "builtin",
    ["typeof"] = "builtin"
}

local Globals = {
    game = true, workspace = true, script = true, Instance = true,
    Vector2 = true, Vector3 = true, CFrame = true, UDim = true,
    UDim2 = true, Color3 = true, BrickColor = true, TweenInfo = true,
    Enum = true, Random = true, task = true, math = true, table = true,
    string = true, coroutine = true
}

local Builtins = {
    print = true, warn = true, error = true, pairs = true, ipairs = true,
    next = true, pcall = true, xpcall = true, require = true, tonumber = true,
    tostring = true, wait = true, spawn = true, delay = true, tick = true,
    time = true, select = true, unpack = true, setmetatable = true,
    getmetatable = true, loadstring = true
}

-- Language translations
Module.LanguageData = {
    English = {
        HOME = "Home", EXECUTOR = "Executor", SCRIPTS = "Scripts",
        Home = "Home", Settings = "Settings", USE = "Use", APPLY = "Apply",
        CANCEL = "Cancel", DELETE = "Delete", EXECUTE = "Execute",
        SAVE = "Save", RUN = "Run", CLEAR = "Clear", SELECTED = "Selected",
        ON = "On", OFF = "Off", STATUS = "Status", LANGUAGE = "Language",
        ["Welcome to Ronix,"] = "Welcome to Ronix,", Script = "Script",
        ["AUTOEXE"] = "Auto-Execute"
    }
}

Module.TextToKey = {}

-- Helper functions
local function createTween(obj, props, duration, style, direction)
    local tweenInfo = TweenInfo.new(
        duration or 0.6,
        style or Enum.EasingStyle.Exponential,
        direction or Enum.EasingDirection.Out
    )
    return TweenService:Create(obj, tweenInfo, props)
end

local function escapeRichText(str)
    return str:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;")
end

local function ensureFolder(path)
    if type(path) ~= "string" or path == "" then return false end
    if not isfolderFunc then return false end
    if not makefolderFunc then
        local ok, exists = pcall(function() return isfolderFunc(path) end)
        return ok and exists
    end
    
    local normalized = path:gsub("\\", "/")
    local ok, exists = pcall(function() return isfolderFunc(normalized) end)
    if ok and exists then return true end
    
    local parent = normalized:match("^(.*)/[^/]+$")
    if parent and parent ~= "" and parent ~= normalized then
        ensureFolder(parent)
    end
    
    pcall(function() makefolderFunc(normalized) end)
    local okAfter, existsAfter = pcall(function() return isfolderFunc(normalized) end)
    return okAfter and existsAfter
end

local function writeFile(path, content)
    if not writefileFunc then return false end
    if type(path) ~= "string" or path == "" then return false end
    
    local normalized = path:gsub("\\", "/")
    local payload = type(content) == "string" and content or tostring(content or "")
    local parent = normalized:match("^(.*)/[^/]+$")
    if parent and parent ~= "" then ensureFolder(parent) end
    
    local success = pcall(function() writefileFunc(normalized, payload) end)
    return success
end

local function readFile(path)
    if not readfileFunc or not isfileFunc then return nil end
    if type(path) ~= "string" or path == "" then return nil end
    
    local normalized = path:gsub("\\", "/")
    local exists = false
    pcall(function() exists = isfileFunc(normalized) end)
    if not exists then return nil end
    
    local success, result = pcall(function() return readfileFunc(normalized) end)
    if success and result then
        return type(result) == "string" and result or tostring(result)
    end
    return nil
end

local function fileExists(path)
    if not isfileFunc then return false end
    local success, result = pcall(function() return isfileFunc(path) end)
    return success and result
end

-- HTTP cache
local httpCache = {}
local lastApiCall = 0

local function httpGet(url, bypassCache)
    if not bypassCache and httpCache[url] then
        return httpCache[url]
    end
    
    local now = tick()
    if now - lastApiCall < 0.5 then
        task.wait(0.5 - (now - lastApiCall))
    end
    lastApiCall = tick()
    
    local success, result = pcall(function()
        if game.HttpGet then
            return game:HttpGet(url)
        end
        if request then
            local response = request({Url = url, Method = "GET", Timeout = 10})
            return response and response.Body
        end
        return nil
    end)
    
    if success and result then
        if not bypassCache then
            httpCache[url] = result
            task.delay(300, function()
                if httpCache[url] == result then
                    httpCache[url] = nil
                end
            end)
        end
        return result
    end
    return nil
end

-- Initialize filesystem
ensureFolder(RONIX_ROOT)
ensureFolder(DATA_PATH)
ensureFolder(SCRIPTS_PATH)

-- Module functions
function Module.setTheme(themeName)
    local cleanName = themeName:match("^%a+")
    if Module.Themes[cleanName] then
        ActiveColors = Module.Themes[cleanName]
        Module.currentTheme = cleanName
        if Module.forceUpdate then Module.forceUpdate() end
    end
end

function Module.setTextSize(size)
    Module.currentSize = tonumber(size) or 18
    if Module.forceUpdate then Module.forceUpdate() end
end

function Module.resetTextSize()
    Module.currentSize = 18
    if Module.forceUpdate then Module.forceUpdate() end
end

function Module.connect(obj, callback)
    if not obj then return end
    if obj:IsA("GuiButton") then
        local signal = obj.Activated or obj.MouseButton1Click
        signal:Connect(callback)
    else
        obj.InputBegan:Connect(function(input)
            local valid = input.UserInputType == Enum.UserInputType.MouseButton1
                or input.UserInputType == Enum.UserInputType.Touch
            if valid then callback() end
        end)
    end
end

function Module.buildReverseLookup()
    Module.TextToKey = {}
    for _, data in pairs(Module.LanguageData) do
        for key, val in pairs(data) do
            Module.TextToKey[val] = key
            Module.TextToKey[string.lower(val)] = key
        end
    end
end

Module.buildReverseLookup()

function Module.findKey(text)
    if not text or text == "" then return nil end
    if Module.TextToKey[text] then return Module.TextToKey[text] end
    local lower = string.lower(text)
    if Module.TextToKey[lower] then return Module.TextToKey[lower] end
    return nil
end

function Module.getTranslation(key)
    local langData = Module.LanguageData[Module.currentLang]
    if langData and langData[key] then
        return langData[key]
    end
    return key
end

function Module.highlight(text)
    if not text or text == "" or not Module.useSyntax then return "" end
    
    local theme = Module.Themes[Module.currentTheme] or ActiveColors
    local result = {}
    local i = 1
    local n = #text
    
    local function addColored(s, colorKey)
        local color = theme[colorKey] or theme.ident or "#A6ACCD"
        table.insert(result, '<font color="' .. color .. '">' .. escapeRichText(s) .. '</font>')
    end
    
    while i <= n do
        local c = text:sub(i, i)
        local c2 = text:sub(i, i + 1)
        
        if c:match("%s") then
            local j = i + 1
            while j <= n and text:sub(j, j):match("%s") do j = j + 1 end
            table.insert(result, text:sub(i, j - 1))
            i = j
        elseif c2 == "--" then
            local j = text:find("\n", i) or n + 1
            addColored(text:sub(i, j - 1), "comment")
            i = j
        elseif c == '"' or c == "'" then
            local quote = c
            local j = i + 1
            while j <= n do
                local ch = text:sub(j, j)
                if ch == "\\" then j = j + 2
                elseif ch == quote or ch == "\n" then j = j + 1; break
                else j = j + 1 end
            end
            addColored(text:sub(i, j - 1), "string")
            i = j
        elseif c2 == "[[" then
            local j = text:find("]]", i + 2, true)
            if j then j = j + 2 else j = n + 1 end
            addColored(text:sub(i, j - 1), "string")
            i = j
        elseif c:match("%d") then
            local j = i + 1
            while j <= n and text:sub(j, j):match("[%d%.xXaAbBcCdDeEfF]") do j = j + 1 end
            addColored(text:sub(i, j - 1), "number")
            i = j
        elseif c:match("[%a_]") then
            local j = i + 1
            while j <= n and text:sub(j, j):match("[%w_]") do j = j + 1 end
            local word = text:sub(i, j - 1)
            
            if Keywords[word] then addColored(word, Keywords[word])
            elseif Globals[word] then addColored(word, "global")
            elseif Builtins[word] then addColored(word, "builtin")
            elseif text:sub(j, j) == "(" then addColored(word, "method")
            else addColored(word, "ident") end
            i = j
        elseif c:match("[%+%-%*/%^%%#=<>~]") then
            addColored(c, "operator")
            i = i + 1
        elseif c:match("[%[%]%(%)%{%}]") then
            addColored(c, "bracket")
            i = i + 1
        elseif c:match("[%.,;:]") then
            addColored(c, "symbol")
            i = i + 1
        else
            table.insert(result, escapeRichText(c))
            i = i + 1
        end
        
        if i % 1000 == 0 then task.wait() end
    end
    
    return table.concat(result)
end

function Module.tween(obj, props, duration)
    return createTween(obj, props, duration)
end

function Module.fadeIn(frame, duration)
    for _, obj in frame:GetDescendants() do
        if obj:IsA("GuiObject") then
            local props = {}
            if obj.BackgroundTransparency then
                props.BackgroundTransparency = obj.BackgroundTransparency
                obj.BackgroundTransparency = 1
            end
            if obj:IsA("ImageLabel") or obj:IsA("ImageButton") then
                props.ImageTransparency = obj.ImageTransparency
                obj.ImageTransparency = 1
            end
            if obj:IsA("TextLabel") or obj:IsA("TextButton") then
                props.TextTransparency = obj.TextTransparency
                obj.TextTransparency = 1
            end
            task.spawn(function()
                createTween(obj, props, duration):Play()
            end)
        end
    end
end

-- FIXED: Proper page switching with executor element handling
function Module.switch(oldPage, newPage, buttons, activeBtn, executorElements)
    -- Hide all buttons first
    for _, btn in pairs(buttons) do
        if btn and btn.Name ~= "ProfileButton" then
            btn.ImageTransparency = 1
            local stroke = btn:FindFirstChild("UIStroke")
            if stroke then stroke.Transparency = 1 end
        end
    end
    
    -- Show active button
    if activeBtn and activeBtn.Name ~= "ProfileButton" then
        activeBtn.ImageTransparency = 0.6
        local stroke = activeBtn:FindFirstChild("UIStroke")
        if stroke then stroke.Transparency = 0.6 end
    end
    
    -- Hide old page
    if oldPage then
        oldPage.Visible = false
        
        -- FIXED: Hide executor-specific elements when leaving executor page
        if executorElements and oldPage.Name == "Executor" then
            for _, elem in pairs(executorElements) do
                if elem then elem.Visible = false end
            end
        end
    end
    
    -- Show new page
    if newPage then
        newPage.Visible = true
        newPage.Position = UDim2.new(0, 0, 0, 0)
        
        -- FIXED: Show executor-specific elements when entering executor page
        if executorElements and newPage.Name == "Executor" then
            for _, elem in pairs(executorElements) do
                if elem then elem.Visible = true end
            end
        end
    end
end

function Module.setupEditor(scrollContainer, codeBox, lineLabel)
    if not scrollContainer or not codeBox then return end
    
    -- Clean existing
    local existingContainer = scrollContainer:FindFirstChild("ContentContainer")
    if existingContainer then
        if codeBox.Parent == existingContainer then
            codeBox.Parent = scrollContainer
        end
        existingContainer:Destroy()
    end
    
    -- Create container
    local container = Instance.new("Frame")
    container.Name = "ContentContainer"
    container.BackgroundTransparency = 1
    container.Size = UDim2.new(1, -LINE_GAP, 1, 0)
    container.Position = UDim2.new(0, LINE_GAP, 0, 0)
    container.Parent = scrollContainer
    
    -- Create highlight label
    local highlightLabel = Instance.new("TextLabel")
    highlightLabel.Name = "SyntaxHighlighting"
    highlightLabel.BackgroundTransparency = 1
    highlightLabel.Size = UDim2.new(1, 0, 1, 0)
    highlightLabel.RichText = true
    highlightLabel.Font = EDITOR_FONT
    highlightLabel.TextSize = Module.currentSize
    highlightLabel.TextColor3 = Color3.fromRGB(166, 172, 205)
    highlightLabel.TextXAlignment = Enum.TextXAlignment.Left
    highlightLabel.TextYAlignment = Enum.TextYAlignment.Top
    highlightLabel.ZIndex = 5
    highlightLabel.Active = false
    highlightLabel.LineHeight = LINE_HEIGHT
    highlightLabel.TextWrapped = false
    highlightLabel.Parent = container
    
    -- Setup code box
    codeBox.Parent = container
    codeBox.Size = UDim2.new(1, 0, 1, 0)
    codeBox.Position = UDim2.new(0, 0, 0, 0)
    codeBox.BackgroundTransparency = 1
    codeBox.Font = EDITOR_FONT
    codeBox.TextSize = Module.currentSize
    codeBox.TextColor3 = Color3.fromRGB(166, 172, 205)
    codeBox.TextXAlignment = Enum.TextXAlignment.Left
    codeBox.TextYAlignment = Enum.TextYAlignment.Top
    codeBox.ZIndex = 10
    codeBox.ClearTextOnFocus = false
    codeBox.MultiLine = true
    codeBox.TextWrapped = false
    codeBox.RichText = false
    codeBox.TextTransparency = 0
    codeBox.Active = true
    codeBox.TextEditable = true
    codeBox.LineHeight = LINE_HEIGHT
    
    -- Setup scroll container
    scrollContainer.ScrollingEnabled = true
    scrollContainer.ScrollingDirection = Enum.ScrollingDirection.XY
    scrollContainer.ScrollBarImageColor3 = Color3.fromHex("#251f42")
    scrollContainer.ScrollBarThickness = 12
    scrollContainer.CanvasSize = UDim2.new(2, 0, 2, 0)
    scrollContainer.ClipsDescendants = true
    
    -- Create cursor
    local cursor = Instance.new("Frame")
    cursor.Name = "Cursor"
    cursor.BackgroundColor3 = Color3.fromRGB(220, 220, 255)
    cursor.BorderSizePixel = 0
    cursor.Size = UDim2.new(0, 2, 0, Module.currentSize)
    cursor.ZIndex = 15
    cursor.Visible = false
    cursor.Parent = container
    
    -- Setup line label
    if lineLabel then
        lineLabel.Name = "Line Number"
        lineLabel:SetAttribute("IgnoreTranslation", true)
        lineLabel.Font = EDITOR_FONT
        lineLabel.TextSize = Module.currentSize
        lineLabel.TextColor3 = Color3.fromRGB(100, 100, 120)
        lineLabel.TextXAlignment = Enum.TextXAlignment.Right
        lineLabel.TextYAlignment = Enum.TextYAlignment.Top
        lineLabel.Position = UDim2.new(0, 0, 0, 0)
        lineLabel.Size = UDim2.new(0, LINE_GAP - 5, 1, 0)
        lineLabel.BackgroundTransparency = 1
        lineLabel.ZIndex = 20
        lineLabel.LineHeight = LINE_HEIGHT
    end
    
    -- Update cursor position
    local function updateCursor()
        if not codeBox:IsFocused() then
            cursor.Visible = false
            return
        end
        
        local cursorPos = codeBox.CursorPosition
        local text = codeBox.Text
        cursorPos = math.max(1, math.min(cursorPos, #text + 1))
        
        local textBefore = text:sub(1, cursorPos - 1)
        local _, lineCount = textBefore:gsub("\n", "")
        
        local lastNewline = 0
        local reversed = textBefore:reverse()
        local newlinePos = reversed:find("\n")
        if newlinePos then
            lastNewline = #textBefore - newlinePos + 1
        end
        
        local lineText = textBefore:sub(lastNewline + 1)
        local fontSize = Module.currentSize
        local textWidth = TextService:GetTextSize(lineText, fontSize, EDITOR_FONT, Vector2.new(999999, 999999)).X
        local yPos = lineCount * fontSize * LINE_HEIGHT
        
        cursor.Position = UDim2.new(0, textWidth, 0, yPos)
        cursor.Size = UDim2.new(0, 2, 0, fontSize)
        cursor.Visible = highlightLabel.Visible
    end
    
    -- Update editor content
    local function updateEditor()
        local text = codeBox.Text
        local _, lineCount = text:gsub("\n", "")
        
        local lineNumbers = {}
        for j = 1, lineCount + 1 do
            lineNumbers[j] = tostring(j)
        end
        
        local fontSize = Module.currentSize
        local textBounds = TextService:GetTextSize(text, fontSize, EDITOR_FONT, Vector2.new(999999, 999999))
        local contentHeight = math.max((lineCount + 1) * fontSize * LINE_HEIGHT, textBounds.Y) + 50
        local minWidth = scrollContainer.AbsoluteSize.X - LINE_GAP
        local contentWidth = math.max(textBounds.X, minWidth) + 50
        
        container.Size = UDim2.new(0, contentWidth, 0, contentHeight)
        scrollContainer.CanvasSize = UDim2.new(0, contentWidth, 0, contentHeight)
        
        if lineLabel then
            lineLabel.TextSize = fontSize
            lineLabel.Text = table.concat(lineNumbers, "\n")
            lineLabel.Size = UDim2.new(0, LINE_GAP - 5, 0, contentHeight)
        end
        
        codeBox.TextSize = fontSize
        highlightLabel.TextSize = fontSize
        updateCursor()
        
        -- Syntax highlighting
        if Module.useSyntax then
            task.spawn(function()
                local success, highlighted = pcall(Module.highlight, text)
                local assignSuccess = false
                
                if success and highlighted then
                    assignSuccess = pcall(function()
                        highlightLabel.RichText = true
                        highlightLabel.Text = highlighted
                    end)
                end
                
                if assignSuccess then
                    highlightLabel.Visible = true
                    codeBox.TextTransparency = 1
                    updateCursor()
                else
                    codeBox.TextTransparency = 0
                    highlightLabel.Visible = false
                    cursor.Visible = false
                end
            end)
        else
            codeBox.TextTransparency = 0
            highlightLabel.Visible = false
            cursor.Visible = false
        end
    end
    
    -- Connect events
    codeBox:GetPropertyChangedSignal("Text"):Connect(updateEditor)
    codeBox:GetPropertyChangedSignal("CursorPosition"):Connect(updateCursor)
    codeBox.Focused:Connect(updateCursor)
    codeBox.FocusLost:Connect(function() cursor.Visible = false end)
    
    UserInputService.InputBegan:Connect(function(input)
        if not codeBox:IsFocused() then return end
        local ctrlHeld = UserInputService:IsKeyDown(Enum.KeyCode.LeftControl)
            or UserInputService:IsKeyDown(Enum.KeyCode.RightControl)
        if input.KeyCode == Enum.KeyCode.V and ctrlHeld then
            task.wait(0.05)
            updateEditor()
        end
    end)
    
    -- Initial update
    updateEditor()
    Module.forceUpdate = updateEditor
end

function Module.exec(code)
    if not code then return end
    task.spawn(function()
        local ls = loadstring or (getgenv and getgenv().loadstring)
        if not ls then
            warn("[Ronix] loadstring not supported")
            return
        end
        local func, err = ls(code)
        if func then
            func()
        else
            warn("[Ronix] Execution error: " .. tostring(err))
        end
    end)
end

function Module.paste(box)
    local success, content = pcall(getclipboard)
    if success and content and content ~= "" then
        local cursorPos = box.CursorPosition
        local text = box.Text
        if cursorPos <= 0 then cursorPos = 1 end
        local before = text:sub(1, cursorPos - 1)
        local after = text:sub(cursorPos)
        box.Text = before .. content .. after
        box.CursorPosition = cursorPos + #content
    end
end

function Module.clear(box)
    box.Text = ""
end

-- File operations
function Module.save(filename, data)
    if not data then return false end
    local path = DATA_PATH .. "/" .. filename
    local success = pcall(function()
        local jsonData = HttpService:JSONEncode(data)
        writeFile(path, jsonData)
    end)
    return success
end

function Module.load(filename)
    local path = DATA_PATH .. "/" .. filename
    local success, result = pcall(function()
        local content = readFile(path)
        if content and content ~= "" then
            return HttpService:JSONDecode(content)
        end
        return nil
    end)
    return success and result or nil
end

function Module.saveTabs(tabData)
    if type(tabData) ~= "table" then return false end
    local cleanData = {}
    for i, tab in ipairs(tabData) do
        cleanData[i] = {
            name = tab.name or ("Script " .. i),
            content = tab.content or "",
            createdOn = tab.createdOn or os.time()
        }
    end
    return Module.save("tabs.json", cleanData)
end

function Module.loadTabs()
    local data = Module.load("tabs.json")
    if type(data) == "table" and #data > 0 then
        return data
    end
    return {{name = "Script 1", content = "", createdOn = os.time()}}
end

function Module.saveGallery(galleryData)
    if type(galleryData) ~= "table" then return false end
    return Module.save("gallery.json", galleryData)
end

function Module.loadGallery()
    local data = Module.load("gallery.json")
    return type(data) == "table" and data or {}
end

function Module.saveStartup(page)
    page = (page and page ~= "") and page or "Executor"
    return Module.save("startup.json", {page = page, timestamp = os.time()})
end

function Module.loadStartup()
    local data = Module.load("startup.json")
    if type(data) == "table" and data.page then
        return data
    end
    return {page = "Executor"}
end

function Module.saveLang(lang)
    lang = (lang and lang ~= "") and lang or "English"
    Module.currentLang = lang
    Module.buildReverseLookup()
    return Module.save("language.json", {lang = lang, timestamp = os.time()})
end

function Module.loadLang()
    local data = Module.load("language.json")
    if type(data) == "table" and data.lang then
        Module.currentLang = data.lang
        Module.buildReverseLookup()
        return data
    end
    Module.currentLang = "English"
    return {lang = "English"}
end

function Module.saveTheme(themeName)
    themeName = themeName or "Purple"
    Module.setTheme(themeName)
    return Module.save("theme.json", {theme = themeName})
end

function Module.loadTheme()
    local data = Module.load("theme.json")
    if type(data) == "table" and data.theme and Module.Themes[data.theme] then
        Module.currentTheme = data.theme
        ActiveColors = Module.Themes[data.theme]
        return data
    end
    Module.currentTheme = "Purple"
    ActiveColors = Module.Themes.Purple
    return {theme = "Purple"}
end

function Module.saveTextSize(size)
    local sz = math.clamp(tonumber(size) or 18, 8, 40)
    Module.currentSize = sz
    return Module.save("textsize.json", {size = sz})
end

function Module.loadTextSize()
    local data = Module.load("textsize.json")
    if type(data) == "table" and data.size then
        Module.currentSize = tonumber(data.size) or 18
        return data
    end
    Module.currentSize = 18
    return {size = 18}
end

function Module.saveSyntaxEnabled(enabled)
    Module.useSyntax = enabled
    return Module.save("syntax.json", {enabled = enabled})
end

function Module.loadSyntaxEnabled()
    local data = Module.load("syntax.json")
    if type(data) == "table" and data.enabled ~= nil then
        Module.useSyntax = data.enabled
        return data.enabled
    end
    Module.useSyntax = true
    return true
end

function Module.saveToggles(toggleData)
    if type(toggleData) ~= "table" then return false end
    Module.toggleStates = toggleData
    return Module.save("toggles.json", toggleData)
end

function Module.loadToggles()
    local data = Module.load("toggles.json")
    if type(data) == "table" then
        Module.toggleStates = data
        return data
    end
    Module.toggleStates = {}
    return {}
end

function Module.setToggle(name, state)
    Module.toggleStates[name] = state
    Module.saveToggles(Module.toggleStates)
end

function Module.getToggle(name)
    return Module.toggleStates[name] or false
end

function Module.saveToFile(name, content)
    if not writefileFunc then return false end
    local safeName = tostring(name):gsub("[<>:\"/\\|%?%*%c]", "_")
    if safeName == "" then safeName = "Script" end
    if not safeName:lower():match("%.lua$") then
        safeName = safeName .. ".lua"
    end
    local path = SCRIPTS_PATH .. "/" .. safeName
    return writeFile(path, tostring(content or ""))
end

function Module.readFromFile(name)
    local safeName = tostring(name):gsub("[<>:\"/\\|%?%*%c]", "_")
    local path = SCRIPTS_PATH .. "/" .. safeName
    if not safeName:lower():find("%.lua$") then
        path = path .. ".lua"
    end
    return readFile(path)
end

function Module.listLocalFiles()
    if not listfilesFunc then return {} end
    local success, files = pcall(function()
        return listfilesFunc(SCRIPTS_PATH)
    end)
    if not success then return {} end
    local result = {}
    for _, f in pairs(files) do
        local name = f:match("([^/\\]+)$")
        if name then table.insert(result, name) end
    end
    return result
end

function Module.deleteLocalFile(name)
    if not delfileFunc then return false end
    local safeName = tostring(name):gsub("[<>:\"/\\|%?%*%c]", "_")
    local path = SCRIPTS_PATH .. "/" .. (safeName:lower():find("%.lua$") and safeName or safeName .. ".lua")
    return pcall(function()
        if fileExists(path) then delfileFunc(path) end
    end)
end

-- UI animations
function Module.open(sidebar, main, currentPage)
    if not currentPage then return end
    currentPage.Visible = true
    local tweenInfo = TweenInfo.new(0.6, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out)
    TweenService:Create(sidebar, tweenInfo, {Position = UDim2.new(0.048, 0, 0.075, 0)}):Play()
    TweenService:Create(main, tweenInfo, {Position = UDim2.new(0.323, 0, 0.076, 0)}):Play()
end

function Module.close(sidebar, main, pages)
    local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.In)
    TweenService:Create(sidebar, tweenInfo, {Position = UDim2.new(-1.5, 0, 0.075, 0)}):Play()
    TweenService:Create(main, tweenInfo, {Position = UDim2.new(3, 0, 0.076, 0)}):Play()
    task.delay(0.5, function()
        for _, p in pairs(pages) do
            if p then p.Visible = false end
        end
    end)
end

function Module.unlockFPS()
    if setfpscap then setfpscap(0) end
end

function Module.getGameInfo()
    return MarketplaceService:GetProductInfo(game.PlaceId)
end

function Module.notify(title, msg)
    -- Placeholder - can be customized
end

function Module.showPopup(popup, frame)
    if popup then popup.Visible = true end
    if frame then frame.Visible = true end
end

function Module.hidePopup(popup, frame)
    if frame then frame.Visible = false end
    if popup then popup.Visible = false end
end

return Module
