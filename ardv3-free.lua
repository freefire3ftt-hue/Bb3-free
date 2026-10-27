-- ============================================================
-- Babis | SURVIVE THE HULK — FREE EDITION
-- ============================================================

local Players           = game:GetService("Players")
local RunService        = game:GetService("RunService")
local TweenService      = game:GetService("TweenService")
local UserInputService  = game:GetService("UserInputService")
local SoundService      = game:GetService("SoundService")
local HttpService       = game:GetService("HttpService")
local Workspace         = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer       = Players.LocalPlayer
local PlayerGui         = LocalPlayer:WaitForChild("PlayerGui")

local LockState = {
    enabled = (getrawmetatable and setreadonly and newcclosure) ~= nil,
    protected = {}, bypass = false,
    props = { Position=true, Size=true, AnchorPoint=true, Parent=true,
        Visible=true, BackgroundTransparency=true, Enabled=true,
        DisplayOrder=true, Active=true, ZIndex=true },
}
if LockState.enabled then
    local ok, err = pcall(function()
        local mt = getrawmetatable(game)
        local oldNewIndex = mt.__newindex
        setreadonly(mt, false)
        mt.__newindex = newcclosure(function(self, key, value)
            if LockState.bypass == false and LockState.props[key]
               and type(self) == "userdata" and LockState.protected[self] then
                return
            end
            return oldNewIndex(self, key, value)
        end)
        setreadonly(mt, true)
    end)
    if not ok then LockState.enabled = false end
end
local function protectInstance(inst)
    if inst and LockState.enabled then LockState.protected[inst] = true end
end
local function safeWrite(inst, prop, value)
    if LockState.enabled then
        LockState.bypass = true; inst[prop] = value; LockState.bypass = false
    else inst[prop] = value end
end

local uiParent = (gethui and gethui()) or PlayerGui
for _, n in ipairs({"BabisUIKit", "BabisUIKitNotif", "BabisIntro",
    "BabisPanicFloat", "BabisFlingFloat", "BabisEventLog", "BabisHulkAlert",
    "BabisKillOverlay", "BabisClimbOverlay"}) do
    local old = uiParent:FindFirstChild(n); if old then old:Destroy() end
    local oldPg = PlayerGui:FindFirstChild(n); if oldPg then oldPg:Destroy() end
end

local CONFIG = {
    appName = "Babis | SURVIVE THE HULK",
    version = "v1.0.0",
    edition = "Free Version",
    discordInvite = "https://discord.gg/gEBbPa5C",
    colors = {
        windowBg=Color3.fromRGB(8,10,14), headerTint=Color3.fromRGB(8,10,14), divider=Color3.fromRGB(65,150,245),
        accent=Color3.fromRGB(90,165,255), accentSoft=Color3.fromRGB(160,210,255), accentDark=Color3.fromRGB(40,90,160),
        gold=Color3.fromRGB(255, 200, 60),
        goldSoft=Color3.fromRGB(255, 225, 140),
        goldDeep=Color3.fromRGB(190, 140, 30),
        navBg=Color3.fromRGB(18,18,19), navBorder=Color3.fromRGB(90,88,92), navIcon=Color3.fromRGB(52,61,69),
        navIconActive=Color3.fromRGB(160,210,255), navActiveBrd=Color3.fromRGB(160,210,255),
        cardBg=Color3.fromRGB(16,16,20), cardBorder=Color3.fromRGB(56,55,62),
        toggleOff=Color3.fromRGB(38,38,44), toggleOn=Color3.fromRGB(90,165,255),
        textPrimary=Color3.fromRGB(240,240,248), textDesc=Color3.fromRGB(150,148,168), textMuted=Color3.fromRGB(130,130,150),
        closeHover=Color3.fromRGB(220,70,90), handIdle=Color3.fromRGB(240,245,255), handHover=Color3.fromRGB(255,255,255),
        cfgIcon=Color3.fromRGB(170,120,255), cfgBtnBg=Color3.fromRGB(24,24,28), cfgBtnBorder=Color3.fromRGB(48,48,56),
        bellBg=Color3.fromRGB(30,38,48),
        lockedCard=Color3.fromRGB(14,14,18), lockedBorder=Color3.fromRGB(40,38,44), lockedText=Color3.fromRGB(120,118,135),
        premium=Color3.fromRGB(255,200,60),
    },
    sizes = {
        windowWidth=460, windowHeight=700, windowRadius=22, headerHeight=82,
        navHeight=88, navBtnSize=70, navBtnRadius=14, navGap=8, navPadX=12,
        contentPadX=14, scrollPadL=6, scrollPadR=8, iconSize=46,
        cardRadius=16, cardPadX=16, cardGap=14,
        toggleCardHeight=150, sliderCardHeight=170,
        toggleW=72, toggleH=38, toggleKnob=30, toggleRight=22,
        controlW=110, controlH=44, controlRight=22, handIconSize=82, handIconY=20,
        cfgHeight=516,
    },
    fonts = { appName=Enum.Font.GothamBold, version=Enum.Font.Gotham, intro=Enum.Font.Code },
    textSizes = {
        appName=22, version=15, intro=20, cardTitle=24, cardDesc=15,
        cfgTitle=22, cfgLabel=17, cfgBtn=17, cfgHint=16, cfgInput=17,
        aboutTitle=30, aboutDesc=16, discordTitle=28, discordSub=18,
    },
    anim = { fast=0.14, normal=0.20, slow=0.32, easing=Enum.EasingStyle.Quint, dir=Enum.EasingDirection.Out },
    tabs = {
        { id="main",     name="Main",     iconId=7733960981,     boost=6 },
        { id="visual",   name="Visuals",  iconId=7733774602,     boost=0 },
        { id="player",   name="Player",   iconId=92187976272467, boost=46 },
        { id="misc",     name="Misc",     iconId=10723387563,    boost=0 },
        { id="settings", name="Settings", iconId=7734053495,     boost=0 },
    },
    defaultTab = "player",
    handIconId="rbxassetid://88060480140568", cfgIconId="rbxassetid://10709791036",
    infoIconId="rbxassetid://7733964719", discordIconId="rbxassetid://100770414662869",
    bellIconId="rbxassetid://7072706001", notifySoundId="rbxassetid://5153734608",
    notifySoundVol=0.5, introImageId="rbxassetid://119251117614023",
    introDuration=5.5, introImgW=156, introImgH=139,
    lockIconId="rbxassetid://113617763566572",
    cfgFolder="Babis/configs", cfgExt=".json", autoloadFile="Babis/autoload.txt",
    positionFile="Babis/position.txt",
}

local function corner(parent, r)
    local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0, r); c.Parent = parent; return c
end
local function stroke(parent, color, thickness, transparency)
    local s = Instance.new("UIStroke")
    s.Color=color; s.Thickness=thickness or 1; s.Transparency=transparency or 0
    s.ApplyStrokeMode=Enum.ApplyStrokeMode.Border; s.Parent=parent; return s
end
local function tween(obj, props, dur, style, dir)
    local info = TweenInfo.new(dur or CONFIG.anim.normal, style or CONFIG.anim.easing, dir or CONFIG.anim.dir)
    local t = TweenService:Create(obj, info, props); t:Play(); return t
end
local function popTween(obj, props, dur)
    local info = TweenInfo.new(dur or 0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
    local t = TweenService:Create(obj, info, props); t:Play(); return t
end
local function safeCall(fn, ...)
    if type(fn) ~= "function" then return false end
    local ok, res = pcall(fn, ...); if ok then return res end; return nil
end

local function ensureBabisFolder()
    if not safeCall(isfolder, "Babis") then safeCall(makefolder, "Babis") end
end

local function savePosition(pos)
    if not pos then return end
    ensureBabisFolder()
    local data = { x = pos.X.Scale, y = pos.Y.Scale, xo = pos.X.Offset, yo = pos.Y.Offset }
    local ok, encoded = pcall(function() return HttpService:JSONEncode(data) end)
    if not ok or type(encoded) ~= "string" then return end
    safeCall(writefile, CONFIG.positionFile, encoded)
end

local function loadPosition()
    local content = safeCall(readfile, CONFIG.positionFile)
    if type(content) ~= "string" or content == "" then return nil end
    local ok, data = pcall(function() return HttpService:JSONDecode(content) end)
    if not ok or type(data) ~= "table" then return nil end
    return UDim2.new(
        tonumber(data.x) or 0.5, tonumber(data.xo) or 0,
        tonumber(data.y) or 0.5, tonumber(data.yo) or 0
    )
end

local Overlay = { activeKill = nil, activeClimb = nil }

local function showKillOverlay(duration)
    duration = duration or 2.0
    if Overlay.activeKill and Overlay.activeKill.Parent then Overlay.activeKill:Destroy() end
    local sg = Instance.new("ScreenGui")
    sg.Name = "BabisKillOverlay"; sg.ResetOnSpawn = false; sg.IgnoreGuiInset = true
    sg.DisplayOrder = 999999; sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    sg.Parent = uiParent
    protectInstance(sg)
    Overlay.activeKill = sg
    local bg = Instance.new("Frame")
    bg.Size = UDim2.new(1,0,1,0); bg.BackgroundColor3 = Color3.fromRGB(0,0,0)
    bg.BackgroundTransparency = 1; bg.BorderSizePixel = 0; bg.Parent = sg
    protectInstance(bg)
    local lbl = Instance.new("TextLabel")
    lbl.BackgroundTransparency = 1; lbl.Text = "TRYING TO KILL HULK"
    lbl.TextColor3 = Color3.fromRGB(255, 40, 40); lbl.Font = Enum.Font.GothamBlack
    lbl.TextSize = 52; lbl.TextStrokeTransparency = 0; lbl.TextStrokeColor3 = Color3.fromRGB(120, 0, 0)
    lbl.TextTransparency = 1; lbl.Size = UDim2.new(0, 0, 0, 90)
    lbl.Position = UDim2.new(0.5, 0, 0.5, -45); lbl.AnchorPoint = Vector2.new(0.5, 0.5)
    lbl.Parent = bg
    TweenService:Create(bg, TweenInfo.new(0.35, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
        { BackgroundTransparency = 0 }):Play()
    TweenService:Create(lbl, TweenInfo.new(0.55, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
        { Size = UDim2.new(1, 0, 0, 90), TextTransparency = 0 }):Play()
    task.spawn(function()
        local t0 = tick()
        while tick() - t0 < duration - 0.7 do
            task.wait(0.4)
            TweenService:Create(lbl, TweenInfo.new(0.25, Enum.EasingStyle.Quint),
                { TextColor3 = Color3.fromRGB(255, 120, 120) }):Play()
            task.wait(0.25)
            TweenService:Create(lbl, TweenInfo.new(0.25, Enum.EasingStyle.Quint),
                { TextColor3 = Color3.fromRGB(255, 40, 40) }):Play()
        end
    end)
    task.delay(math.max(duration - 0.6, 0.1), function()
        TweenService:Create(bg, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.In),
            { BackgroundTransparency = 1 }):Play()
        TweenService:Create(lbl, TweenInfo.new(0.45, Enum.EasingStyle.Quint, Enum.EasingDirection.In),
            { TextTransparency = 1, Size = UDim2.new(0, 0, 0, 90) }):Play()
    end)
    task.delay(duration, function()
        if sg and sg.Parent then sg:Destroy() end
        if Overlay.activeKill == sg then Overlay.activeKill = nil end
    end)
end

local function showClimbOverlay(duration)
    duration = duration or 1.2
    if Overlay.activeClimb and Overlay.activeClimb.Parent then Overlay.activeClimb:Destroy() end
    local sg = Instance.new("ScreenGui")
    sg.Name = "BabisClimbOverlay"; sg.ResetOnSpawn = false; sg.IgnoreGuiInset = true
    sg.DisplayOrder = 999997; sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    sg.Parent = uiParent
    protectInstance(sg)
    Overlay.activeClimb = sg
    local bg = Instance.new("Frame")
    bg.Size = UDim2.new(1,0,1,0); bg.BackgroundColor3 = Color3.fromRGB(0,0,0)
    bg.BackgroundTransparency = 1; bg.BorderSizePixel = 0; bg.Parent = sg
    protectInstance(bg)
    local lbl = Instance.new("TextLabel")
    lbl.BackgroundTransparency = 1; lbl.Text = "CLIMBING"
    lbl.TextColor3 = Color3.fromRGB(90, 165, 255); lbl.Font = Enum.Font.GothamBlack
    lbl.TextSize = 44; lbl.TextStrokeTransparency = 0; lbl.TextStrokeColor3 = Color3.fromRGB(20, 50, 120)
    lbl.TextTransparency = 1; lbl.Size = UDim2.new(1, 0, 0, 80)
    lbl.Position = UDim2.new(0.5, 0, 0.5, -40); lbl.AnchorPoint = Vector2.new(0.5, 0.5)
    lbl.Parent = bg
    TweenService:Create(bg, TweenInfo.new(0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
        { BackgroundTransparency = 0 }):Play()
    TweenService:Create(lbl, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
        { TextTransparency = 0, Size = UDim2.new(1, 0, 0, 80) }):Play()
    task.spawn(function()
        local t0 = tick()
        local n = 0
        while tick() - t0 < duration - 0.3 do
            n = (n + 1) % 4
            lbl.Text = "CLIMBING" .. string.rep(".", n)
            task.wait(0.16)
        end
    end)
    task.delay(math.max(duration - 0.35, 0.1), function()
        TweenService:Create(bg, TweenInfo.new(0.35, Enum.EasingStyle.Quint, Enum.EasingDirection.In),
            { BackgroundTransparency = 1 }):Play()
        TweenService:Create(lbl, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.In),
            { TextTransparency = 1 }):Play()
    end)
    task.delay(duration, function()
        if sg and sg.Parent then sg:Destroy() end
        if Overlay.activeClimb == sg then Overlay.activeClimb = nil end
    end)
end

-- ============================================================
-- INFINITE STAMINA
-- ============================================================
local InfiniteStamina = {
    enabled = false, runTrack = nil, crawlTouchUntil = 0, crawlBtnRef = nil,
    connBegin = nil, connEnd = nil,
    sprintBtnRef = nil, sprintWasVisible = true, sprintConn = nil,
    hulkSprintBtnRef = nil, hulkSprintWasVisible = true, hulkSprintConn = nil,
    RUN_ID = "rbxassetid://93208526042306", TARGET_SPEED = 32, CRAWL_SPEED = 12,
    CRAWL_GUI = "SurvivorMobileControls", CRAWL_BTN = "CrawlButton", SPRINT_BTN = "SprintButton",
    HULK_GUI = "HulkUI_TouchAbilityActivation", HULK_CLUSTER = "ActionCluster", HULK_SPRINT = "Sprint",
}
do
    local function getChar() return LocalPlayer.Character end
    local function getHum() local ch = getChar() return ch and ch:FindFirstChildOfClass("Humanoid") end
    local function getAnimator() local hum = getHum() return hum and (hum:FindFirstChildOfClass("Animator") or hum) end

    local function applySprintVisibility()
        local gui = PlayerGui:FindFirstChild(InfiniteStamina.CRAWL_GUI); if not gui then return end
        local btn = gui:FindFirstChild(InfiniteStamina.SPRINT_BTN); if not btn then return end
        if InfiniteStamina.sprintBtnRef ~= btn then
            InfiniteStamina.sprintBtnRef = btn; InfiniteStamina.sprintWasVisible = btn.Visible
            if InfiniteStamina.sprintConn then pcall(function() InfiniteStamina.sprintConn:Disconnect() end) end
            InfiniteStamina.sprintConn = btn:GetPropertyChangedSignal("Visible"):Connect(function()
                if InfiniteStamina.enabled and btn.Visible then btn.Visible = false end
            end)
        end
        if InfiniteStamina.enabled then btn.Visible = false
        else btn.Visible = InfiniteStamina.sprintWasVisible end
    end

    local function applyHulkSprintVisibility()
        local gui = PlayerGui:FindFirstChild(InfiniteStamina.HULK_GUI); if not gui then return end
        local cluster = gui:FindFirstChild(InfiniteStamina.HULK_CLUSTER); if not cluster then return end
        local btn = cluster:FindFirstChild(InfiniteStamina.HULK_SPRINT); if not btn then return end
        if InfiniteStamina.hulkSprintBtnRef ~= btn then
            InfiniteStamina.hulkSprintBtnRef = btn; InfiniteStamina.hulkSprintWasVisible = btn.Visible
            if InfiniteStamina.hulkSprintConn then pcall(function() InfiniteStamina.hulkSprintConn:Disconnect() end) end
            InfiniteStamina.hulkSprintConn = btn:GetPropertyChangedSignal("Visible"):Connect(function()
                if InfiniteStamina.enabled and btn.Visible then btn.Visible = false end
            end)
        end
        if InfiniteStamina.enabled then btn.Visible = false
        else btn.Visible = InfiniteStamina.hulkSprintWasVisible end
    end

    task.spawn(function() while true do task.wait(0.5)
        if InfiniteStamina.enabled or InfiniteStamina.sprintBtnRef then applySprintVisibility() end
        if InfiniteStamina.enabled or InfiniteStamina.hulkSprintBtnRef then applyHulkSprintVisibility() end
    end end)

    local function tryBindCrawlButton()
        local gui = PlayerGui:FindFirstChild(InfiniteStamina.CRAWL_GUI); if not gui then return false end
        local btn = gui:FindFirstChild(InfiniteStamina.CRAWL_BTN); if not btn then return false end
        if InfiniteStamina.crawlBtnRef == btn then return true end
        if InfiniteStamina.connBegin then InfiniteStamina.connBegin:Disconnect() end
        if InfiniteStamina.connEnd then InfiniteStamina.connEnd:Disconnect() end
        InfiniteStamina.crawlBtnRef = btn
        InfiniteStamina.connBegin = btn.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Touch
            or input.UserInputType == Enum.UserInputType.MouseButton1 then
                InfiniteStamina.crawlTouchUntil = tick() + 0.5
            end
        end)
        InfiniteStamina.connEnd = btn.InputEnded:Connect(function(input) end)
        return true
    end
    task.spawn(function() while not tryBindCrawlButton() do task.wait(1) end end)

    PlayerGui.ChildAdded:Connect(function(child)
        if child.Name == InfiniteStamina.CRAWL_GUI then
            task.wait(0.5); tryBindCrawlButton(); applySprintVisibility()
        elseif child.Name == InfiniteStamina.HULK_GUI then
            task.wait(0.5); applyHulkSprintVisibility()
        end
    end)

    task.spawn(function()
        while true do
            task.wait(0.5)
            applyHulkSprintVisibility()
        end
    end)

    local function ensureRunTrack()
        if InfiniteStamina.runTrack then return end
        local animator = getAnimator(); if not animator then return end
        local anim = Instance.new("Animation"); anim.AnimationId = InfiniteStamina.RUN_ID
        local ok, track = pcall(function() return animator:LoadAnimation(anim) end)
        if not ok or not track then return end
        track.Priority = Enum.AnimationPriority.Action4; track.Looped = true
        InfiniteStamina.runTrack = track
    end
    local function stopRun(fade)
        if InfiniteStamina.runTrack and InfiniteStamina.runTrack.IsPlaying then
            pcall(function() InfiniteStamina.runTrack:Stop(fade or 0.05) end)
        end
    end
    local function playRun(fade)
        if InfiniteStamina.runTrack and not InfiniteStamina.runTrack.IsPlaying then
            pcall(function() InfiniteStamina.runTrack:Play(fade or 0.1) end)
        end
    end
    RunService.RenderStepped:Connect(function(dt)
        if not InfiniteStamina.enabled then stopRun(0.05) return end
        local ch = getChar(); local hum = getHum()
        if not ch or not hum then stopRun(0.05) return end
        ensureRunTrack()
        if hum.MoveDirection.Magnitude <= 0.1 then stopRun(0.05) return end
        local extra = math.max(0, InfiniteStamina.TARGET_SPEED - hum.WalkSpeed)
        if extra > 0 then pcall(function() ch:TranslateBy(hum.MoveDirection * (extra * dt)) end) end
        if hum.WalkSpeed > InfiniteStamina.CRAWL_SPEED and tick() < InfiniteStamina.crawlTouchUntil then
            InfiniteStamina.crawlTouchUntil = 0
        end
        local byTouch = tick() < InfiniteStamina.crawlTouchUntil
        local bySpeed = hum.WalkSpeed > 0 and hum.WalkSpeed <= InfiniteStamina.CRAWL_SPEED
        if byTouch or bySpeed then stopRun(0.05) return end
        playRun(0.1)
    end)
    LocalPlayer.CharacterAdded:Connect(function()
        InfiniteStamina.runTrack = nil; InfiniteStamina.crawlTouchUntil = 0
        task.wait(0.5); tryBindCrawlButton(); applySprintVisibility(); applyHulkSprintVisibility()
    end)
    function InfiniteStamina.enable()
        InfiniteStamina.enabled = true
        applySprintVisibility()
        applyHulkSprintVisibility()
    end
    function InfiniteStamina.disable()
        InfiniteStamina.enabled = false
        stopRun(0.05)
        InfiniteStamina.crawlTouchUntil = 0
        applySprintVisibility()
        applyHulkSprintVisibility()
    end
end

-- ============================================================
-- PLAYER STATE
-- ============================================================
local PlayerState = { jumpEnabled=false, speedPower=false, jumpPower=50, tpSpeed=3 }
local function getHumanoid() local ch = LocalPlayer.Character return ch and ch:FindFirstChildOfClass("Humanoid") end
local function applyPlayerState()
    local hum = getHumanoid(); if not hum then return end
    if PlayerState.jumpEnabled then
        pcall(function() hum.JumpPower = PlayerState.jumpPower end)
        pcall(function() hum.UseJumpPower = true end)
    end
end
RunService.Heartbeat:Connect(function()
    if not PlayerState.speedPower then return end
    local ch = LocalPlayer.Character; if not ch then return end
    local hum = ch:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health <= 0 then return end
    if hum.MoveDirection.Magnitude > 0 then
        pcall(function() ch:TranslateBy(hum.MoveDirection * PlayerState.tpSpeed) end)
    end
end)
LocalPlayer.CharacterAdded:Connect(function() task.wait(0.5); applyPlayerState() end)

-- ============================================================
-- ANTI-RAGDOLL
-- ============================================================
local AntiRagdoll = { enabled=false, forceWalkSpeed=16, forceState=true }
local AR_MOTOR_NAMES = { RootJoint=true, Neck=true,
    ["Left Shoulder"]=true, ["Right Shoulder"]=true,
    ["Left Hip"]=true, ["Right Hip"]=true, Waist=true }
local function arFix()
    if not AntiRagdoll.enabled then return end
    local ch = LocalPlayer.Character; if not ch then return end
    local hum = ch:FindFirstChildOfClass("Humanoid"); if not hum then return end
    if ch:GetAttribute("Ragdolled") == true then pcall(function() ch:SetAttribute("Ragdolled", false) end) end
    if hum.PlatformStand then pcall(function() hum.PlatformStand = false end) end
    if hum.WalkSpeed < 1 then pcall(function() hum.WalkSpeed = AntiRagdoll.forceWalkSpeed end) end
    for _, d in ipairs(ch:GetDescendants()) do
        if d:IsA("Motor6D") and d.Enabled == false and AR_MOTOR_NAMES[d.Name] then
            pcall(function() d.Enabled = true end)
        end
        if d:IsA("BallSocketConstraint") and d.Name == "__HulkRagdollSocket" and d.Enabled then
            pcall(function() d.Enabled = false end)
        end
    end
    if AntiRagdoll.forceState then
        local st = hum:GetState()
        if st == Enum.HumanoidStateType.PlatformStanding or st == Enum.HumanoidStateType.Physics
           or st == Enum.HumanoidStateType.Ragdoll or st == Enum.HumanoidStateType.FallingDown then
            pcall(function() hum:ChangeState(Enum.HumanoidStateType.Running) end)
        end
    end
end
pcall(function() RunService:BindToRenderStep("BabisAntiRagdoll", Enum.RenderPriority.Character.Value + 1, arFix) end)
RunService.Heartbeat:Connect(arFix)
function AntiRagdoll.enable() AntiRagdoll.enabled = true end
function AntiRagdoll.disable() AntiRagdoll.enabled = false end

-- ============================================================
-- PLAYER ESP
-- ============================================================
local PlayerESP = {
    flags = { hulk=false, hulkbuster=false, survivor=false, weapon=false, abilityHighlight=false },
    colors = { Hulk=Color3.fromRGB(60,220,100), Hulkbuster=Color3.fromRGB(255,200,40),
        Survivor=Color3.fromRGB(60,130,255), SurvivorAbility=Color3.fromRGB(255,200,40),
        Weapon=Color3.fromRGB(255,60,180), Ragdoll=Color3.fromRGB(255,150,50) },
    espByPlayer = {}, loop = nil,
}
local function peGetRole(ch)
    if not ch then return nil end
    if ch:GetAttribute("IsHulk") then return "Hulk" end
    if ch:GetAttribute("HulkbusterActive") then return "Hulkbuster" end
    return "Survivor"
end
local function peIsRagdolled(ch)
    local hum = ch:FindFirstChildOfClass("Humanoid"); if not hum then return false end
    if hum.PlatformStand then return true end
    local st = hum:GetState()
    if st == Enum.HumanoidStateType.Physics or st == Enum.HumanoidStateType.Ragdoll then return true end
    for _, a in ipairs({"IsRagdolled","Ragdolled","Ragdoll","IsDowned","Downed"}) do
        if ch:GetAttribute(a) == true then return true end
    end
    return false
end
local function peHasAbility(p) return p:GetAttribute("OwnsHulkbuster") == true end
local function peClear(p)
    local e = PlayerESP.espByPlayer[p]; if not e then return end
    if e.highlight then pcall(function() e.highlight:Destroy() end) end
    if e.billboard then pcall(function() e.billboard:Destroy() end) end
    if e.weaponHL then pcall(function() e.weaponHL:Destroy() end) end
    PlayerESP.espByPlayer[p] = nil
end
local function peClearAll() for p in pairs(PlayerESP.espByPlayer) do peClear(p) end end
local function peApply(p)
    if p == LocalPlayer then return end
    local ch = p.Character
    if not ch then peClear(p) return end
    local hum = ch:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health <= 0 then peClear(p) return end
    local role = peGetRole(ch); local roleFlag = false
    if role == "Hulk" and PlayerESP.flags.hulk then roleFlag = true end
    if role == "Hulkbuster" and PlayerESP.flags.hulkbuster then roleFlag = true end
    if role == "Survivor" and PlayerESP.flags.survivor then roleFlag = true end
    local weaponFlag = PlayerESP.flags.weapon
    if not roleFlag and not weaponFlag then peClear(p) return end
    local ragdolled = peIsRagdolled(ch)
    local color = PlayerESP.colors[role] or PlayerESP.colors.Survivor
    if role == "Survivor" and PlayerESP.flags.abilityHighlight and peHasAbility(p) then
        color = PlayerESP.colors.SurvivorAbility
    end
    if ragdolled then color = PlayerESP.colors.Ragdoll end
    local hrp = ch:FindFirstChild("HumanoidRootPart") or ch:FindFirstChild("Torso") or ch:FindFirstChild("Head")
    if not hrp then return end
    local e = PlayerESP.espByPlayer[p]
    if roleFlag then
        if not e or not e.highlight or e.highlight.Parent ~= ch then
            if e then peClear(p) end
            e = {}
            local h = Instance.new("Highlight")
            h.FillColor=color; h.FillTransparency=0.55; h.OutlineColor=color; h.OutlineTransparency=0
            h.DepthMode=Enum.HighlightDepthMode.AlwaysOnTop; h.Parent=ch
            e.highlight = h
            local bb = Instance.new("BillboardGui")
            bb.Size=UDim2.new(0,200,0,44); bb.StudsOffset=Vector3.new(0,3.2,0); bb.AlwaysOnTop=true; bb.Parent=hrp
            local lbl = Instance.new("TextLabel")
            lbl.Name="Lbl"; lbl.Size=UDim2.new(1,0,1,0); lbl.BackgroundTransparency=1
            lbl.Font=Enum.Font.GothamBold; lbl.TextSize=14; lbl.TextStrokeTransparency=0
            lbl.TextStrokeColor3=Color3.new(0,0,0); lbl.Parent=bb
            e.billboard = bb; PlayerESP.espByPlayer[p] = e
        end
        if e.highlight and e.highlight.FillColor ~= color then
            e.highlight.FillColor=color; e.highlight.OutlineColor=color
        end
        local lbl = e.billboard and e.billboard:FindFirstChild("Lbl")
        if lbl then
            local myHrp = LocalPlayer.Character and (LocalPlayer.Character:FindFirstChild("HumanoidRootPart") or LocalPlayer.Character:FindFirstChild("Head"))
            local dTxt = myHrp and string.format(" [%d]", math.floor((hrp.Position - myHrp.Position).Magnitude)) or ""
            local tag = ""
            if role == "Hulk" then tag=" HULK"
            elseif role == "Hulkbuster" then tag=" HULKBUSTER"
            elseif role == "Survivor" and PlayerESP.flags.abilityHighlight and peHasAbility(p) then tag=" HB-ABILITY"
            elseif ragdolled then tag=" (DOWN)" end
            lbl.Text = p.Name .. tag .. dTxt; lbl.TextColor3 = color
        end
    else
        if e then
            if e.highlight then e.highlight:Destroy() e.highlight=nil end
            if e.billboard then e.billboard:Destroy() e.billboard=nil end
            if not e.weaponHL then PlayerESP.espByPlayer[p]=nil end
        end
    end
    if weaponFlag then
        if not e then e = {} PlayerESP.espByPlayer[p]=e end
        local tool = ch:FindFirstChildOfClass("Tool")
        if tool then
            local handle = tool:FindFirstChild("Handle")
            if handle and handle:IsA("BasePart") then
                if not e.weaponHL or e.weaponHL.Parent ~= handle then
                    if e.weaponHL then e.weaponHL:Destroy() end
                    local whl = Instance.new("Highlight")
                    whl.FillColor=PlayerESP.colors.Weapon; whl.FillTransparency=0.3
                    whl.OutlineColor=PlayerESP.colors.Weapon; whl.OutlineTransparency=0
                    whl.DepthMode=Enum.HighlightDepthMode.AlwaysOnTop; whl.Parent=handle
                    e.weaponHL = whl
                end
            end
        else
            if e.weaponHL then e.weaponHL:Destroy() e.weaponHL=nil end
        end
    else
        if e and e.weaponHL then e.weaponHL:Destroy() e.weaponHL=nil end
    end
end
local function peRefresh()
    if not PlayerESP.loop then
        PlayerESP.loop = task.spawn(function()
            while true do
                task.wait(0.15)
                local any = PlayerESP.flags.hulk or PlayerESP.flags.hulkbuster or PlayerESP.flags.survivor or PlayerESP.flags.weapon
                if not any then peClearAll() else
                    local alive = {}
                    for _, p in ipairs(Players:GetPlayers()) do
                        if p ~= LocalPlayer then peApply(p) alive[p]=true end
                    end
                    for p in pairs(PlayerESP.espByPlayer) do
                        if not alive[p] then peClear(p) end
                    end
                end
            end
        end)
    end
end
function PlayerESP.setFlag(k, v) PlayerESP.flags[k] = v; peRefresh() end

-- ============================================================
-- CHANCE ESP + PITY
-- ============================================================
local ChanceESP = {
    enabled = false, esp = {}, loop = nil,
    colors = { low=Color3.fromRGB(60,220,100), mid=Color3.fromRGB(255,220,60),
        high=Color3.fromRGB(255,140,40), top=Color3.fromRGB(255,60,60),
        hulk=Color3.fromRGB(80,255,130), blocked=Color3.fromRGB(120,120,130) },
    offsetY = 6.8, sizeX = 150, sizeY = 40,
}
local function chanceGetColor(chance, state, isHulk)
    if isHulk then return ChanceESP.colors.hulk end
    if state and tostring(state):find("BLOCKED") then return ChanceESP.colors.blocked end
    if chance >= 15 then return ChanceESP.colors.top end
    if chance >= 12 then return ChanceESP.colors.high end
    if chance >= 8 then return ChanceESP.colors.mid end
    return ChanceESP.colors.low
end
local function chanceIsHulkNow(ch)
    if not ch then return false end
    return ch:GetAttribute("IsHulk") == true or ch:GetAttribute("Transforming") == true
end
local function chanceClear(p)
    local e = ChanceESP.esp[p]; if not e then return end
    if e.bb then pcall(function() e.bb:Destroy() end) end
    ChanceESP.esp[p] = nil
end
local function chanceClearAll() for p in pairs(ChanceESP.esp) do chanceClear(p) end end
local function chanceApply(p)
    if p == LocalPlayer then return end
    local ch = p.Character; if not ch then chanceClear(p); return end
    local hum = ch:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health <= 0 then chanceClear(p); return end
    local chance = p:GetAttribute("HulkChancePercent") or 0
    local pity = p:GetAttribute("HulkPityRounds") or 0
    local hardPity = p:GetAttribute("HulkHardPityRounds") or 8
    local state = p:GetAttribute("HulkChanceState") or "NORMAL"
    local isH = chanceIsHulkNow(ch)
    local color = chanceGetColor(chance, state, isH)
    local hrp = ch:FindFirstChild("HumanoidRootPart") or ch:FindFirstChild("Head") or ch:FindFirstChild("Torso")
    if not hrp then chanceClear(p); return end
    local e = ChanceESP.esp[p]
    if not e or not e.bb or e.bb.Parent ~= hrp then
        if e then chanceClear(p) end
        e = {}
        local bb = Instance.new("BillboardGui")
        bb.Size = UDim2.new(0, ChanceESP.sizeX, 0, ChanceESP.sizeY)
        bb.StudsOffset = Vector3.new(0, ChanceESP.offsetY, 0)
        bb.AlwaysOnTop = true; bb.Parent = hrp
        e.bb = bb
        local chanceLbl = Instance.new("TextLabel")
        chanceLbl.Size = UDim2.new(1, 0, 0, 22); chanceLbl.BackgroundTransparency = 1
        chanceLbl.Text = "0.00%"; chanceLbl.TextColor3 = color; chanceLbl.Font = Enum.Font.GothamBlack
        chanceLbl.TextSize = 17; chanceLbl.TextStrokeTransparency = 0; chanceLbl.TextStrokeColor3 = Color3.new(0,0,0)
        chanceLbl.TextXAlignment = Enum.TextXAlignment.Center; chanceLbl.Parent = bb
        e.chanceLbl = chanceLbl
        local pityLbl = Instance.new("TextLabel")
        pityLbl.Size = UDim2.new(1, 0, 0, 16); pityLbl.Position = UDim2.new(0, 0, 0, 22)
        pityLbl.BackgroundTransparency = 1; pityLbl.Text = "pity 0/8"
        pityLbl.TextColor3 = color; pityLbl.Font = Enum.Font.GothamBold
        pityLbl.TextSize = 13; pityLbl.TextStrokeTransparency = 0; pityLbl.TextStrokeColor3 = Color3.new(0,0,0)
        pityLbl.TextXAlignment = Enum.TextXAlignment.Center; pityLbl.Parent = bb
        e.pityLbl = pityLbl; ChanceESP.esp[p] = e
    end
    if e.chanceLbl.TextColor3 ~= color then
        e.chanceLbl.TextColor3 = color; e.pityLbl.TextColor3 = color
    end
    if isH then e.chanceLbl.Text = "HULK NOW"
    elseif tostring(state):find("BLOCKED") then e.chanceLbl.Text = "BLOCKED"
    else e.chanceLbl.Text = string.format("%.2f%%", chance) end
    if state == "HARD_PITY" then e.pityLbl.Text = "GUARANTEED next!"
    else e.pityLbl.Text = string.format("pity %d/%d", pity, hardPity) end
end
local function chanceTick()
    local alive = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then chanceApply(p); alive[p] = true end
    end
    for p in pairs(ChanceESP.esp) do if not alive[p] then chanceClear(p) end end
end
function ChanceESP.enable()
    if ChanceESP.enabled then return end
    ChanceESP.enabled = true; chanceTick()
    ChanceESP.loop = task.spawn(function()
        while ChanceESP.enabled do task.wait(0.4); if ChanceESP.enabled then pcall(chanceTick) end end
    end)
end
function ChanceESP.disable() ChanceESP.enabled = false; chanceClearAll() end

-- ============================================================
-- ESP VENTS
-- ============================================================
local EspVents = { enabled=false, color=Color3.fromRGB(180,80,255),
    fillTrans=0.4, outlineTrans=0, scanInterval=3,
    patterns={"vent","nightlight"}, esp={}, parent=nil, loop=nil }
local function ventNameMatches(name)
    local n = name:lower()
    for _, p in ipairs(EspVents.patterns) do if n:match(p) then return true end end
    return false
end
local function ventFindParent()
    local fac = Workspace:FindFirstChild("HulkFacility440x340")
    if not fac then
        for _, c in ipairs(Workspace:GetChildren()) do
            if c:IsA("Model") and c.Name:lower():match("hulkfacility") then fac = c break end
        end
    end
    if not fac then return nil end
    local trim = fac:FindFirstChild("Trim"); if not trim then return nil end
    return trim:FindFirstChild("VentFrames")
end
local function ventGetMainPart(inst)
    if inst:IsA("BasePart") then return inst end
    if inst:IsA("Model") then return inst.PrimaryPart or inst:FindFirstChildWhichIsA("BasePart", true) end
    return nil
end
local function ventClearESP(inst)
    local e = EspVents.esp[inst]; if not e then return end
    if e.hl then pcall(function() e.hl:Destroy() end) end
    EspVents.esp[inst] = nil
end
local function ventApply(inst)
    if not inst or not inst.Parent then return end
    if not ventNameMatches(inst.Name) then return end
    local main = ventGetMainPart(inst); if not main then return end
    local parentForHL = inst:IsA("Model") and inst or main
    local e = EspVents.esp[inst]
    if not e or (e.hl and e.hl.Parent ~= parentForHL) then
        if e then ventClearESP(inst) end
        e = {}
        local hl = Instance.new("Highlight")
        hl.Name="BabisVentHL"; hl.FillColor=EspVents.color; hl.FillTransparency=EspVents.fillTrans
        hl.OutlineColor=EspVents.color; hl.OutlineTransparency=EspVents.outlineTrans
        hl.DepthMode=Enum.HighlightDepthMode.AlwaysOnTop; hl.Parent=parentForHL
        e.hl = hl; EspVents.esp[inst] = e
    end
end
local function ventRescan()
    if not EspVents.parent or not EspVents.parent.Parent then EspVents.parent = ventFindParent() end
    if not EspVents.parent then return end
    for inst in pairs(EspVents.esp) do if not inst.Parent then ventClearESP(inst) end end
    for _, child in ipairs(EspVents.parent:GetDescendants()) do
        if child:IsA("BasePart") or child:IsA("Model") then ventApply(child) end
    end
end
local function ventClearAll() for inst in pairs(EspVents.esp) do ventClearESP(inst) end end
function EspVents.enable()
    EspVents.enabled = true
    task.spawn(function() task.wait(0.1); ventRescan() end)
    if not EspVents.loop then
        EspVents.loop = task.spawn(function()
            while true do task.wait(EspVents.scanInterval); if EspVents.enabled then pcall(ventRescan) end end
        end)
    end
end
function EspVents.disable() EspVents.enabled = false; ventClearAll() end

-- ============================================================
-- ESP CABINET
-- ============================================================
local EspCabinet = { enabled=false, color=Color3.fromRGB(210,170,120),
    fillTrans=0.35, outlineTrans=0, scanInterval=3, esp={}, loop=nil }
local function cabinetFindAll()
    local found, seen = {}, {}
    local furn = Workspace:FindFirstChild("Furniture")
    if furn then
        for _, d in ipairs(furn:GetDescendants()) do
            if d:IsA("Model") and d.Name == "Closet" and not seen[d] then
                seen[d]=true; table.insert(found, d)
            end
        end
    end
    for _, d in ipairs(Workspace:GetDescendants()) do
        if d:IsA("Model") and d.Name == "Closet" and not seen[d] then
            seen[d]=true; table.insert(found, d)
        end
    end
    return found
end
local function cabinetClearESP(inst)
    local hl = EspCabinet.esp[inst]; if hl then pcall(function() hl:Destroy() end) end
    EspCabinet.esp[inst] = nil
end
local function cabinetApply(inst)
    if not inst or not inst.Parent then return end
    if EspCabinet.esp[inst] then return end
    local hl = Instance.new("Highlight")
    hl.Name="BabisCabinetHL"; hl.FillColor=EspCabinet.color; hl.FillTransparency=EspCabinet.fillTrans
    hl.OutlineColor=EspCabinet.color; hl.OutlineTransparency=EspCabinet.outlineTrans
    hl.DepthMode=Enum.HighlightDepthMode.AlwaysOnTop; hl.Adornee = inst; hl.Parent = inst
    EspCabinet.esp[inst] = hl
end
local function cabinetClearAll()
    for inst in pairs(EspCabinet.esp) do cabinetClearESP(inst) end
    for _, d in ipairs(Workspace:GetDescendants()) do
        if d:IsA("Highlight") and d.Name == "BabisCabinetHL" then d:Destroy() end
    end
end
local function cabinetRescan()
    local closets = cabinetFindAll(); local alive = {}
    for _, c in ipairs(closets) do alive[c]=true; cabinetApply(c) end
    for inst, hl in pairs(EspCabinet.esp) do
        if not inst.Parent or not alive[inst] then
            if hl then hl:Destroy() end; EspCabinet.esp[inst] = nil
        end
    end
end
function EspCabinet.enable()
    EspCabinet.enabled = true
    task.spawn(function() task.wait(0.1); cabinetRescan() end)
    if not EspCabinet.loop then
        EspCabinet.loop = task.spawn(function()
            while true do task.wait(EspCabinet.scanInterval); if EspCabinet.enabled then pcall(cabinetRescan) end end
        end)
    end
end
function EspCabinet.disable() EspCabinet.enabled = false; cabinetClearAll() end

-- ============================================================
-- ANTI-DEBRIS
-- ============================================================
local AntiDebris = { enabled = false, folderName = "HulkDebris",
    prefixes = {"HulkDebrisChunk", "Debris", "Fragment", "Chunk", "HulkDebris"} }
local function adMatches(name)
    for _, p in ipairs(AntiDebris.prefixes) do
        if name:find(p, 1, true) then return true end
    end
    return false
end
local function adNuke(inst)
    if not inst then return end
    pcall(function() inst:Destroy() end)
end
local adFolderConn, adWatched
function AntiDebris.enable()
    if AntiDebris.enabled then return end
    AntiDebris.enabled = true
    task.spawn(function()
        while AntiDebris.enabled do
            task.wait()
            local folder = Workspace:FindFirstChild(AntiDebris.folderName)
            if folder then for _, c in ipairs(folder:GetChildren()) do adNuke(c) end end
            for _, c in ipairs(Workspace:GetChildren()) do
                if (c:IsA("BasePart") or c:IsA("Model")) and adMatches(c.Name) then adNuke(c) end
            end
        end
    end)
    task.spawn(function()
        while AntiDebris.enabled do
            local f = Workspace:FindFirstChild(AntiDebris.folderName)
            if f ~= adWatched then
                if adFolderConn then pcall(function() adFolderConn:Disconnect() end) end
                adWatched = f
                if f then
                    adFolderConn = f.ChildAdded:Connect(function(child)
                        if AntiDebris.enabled then adNuke(child) end
                    end)
                end
            end
            task.wait(1)
        end
    end)
end
function AntiDebris.disable()
    AntiDebris.enabled = false
    if adFolderConn then pcall(function() adFolderConn:Disconnect() end) end
    adFolderConn = nil; adWatched = nil
end

-- ============================================================
-- EVENT LOG
-- ============================================================
local EventLog = { enabled = false, gui = nil, container = nil,
    entries = {}, hitCooldown = {}, reportedDeath = {}, prevActive = {}, conn = nil,
    cfg = { fadeInTime=0.15, holdTime=2.6, fadeOutTime=0.4, maxLines=6, hitCooldown=1.0 },
    colors = { hulk=Color3.fromRGB(60,220,100), hulkbuster=Color3.fromRGB(255,200,40),
        survivor=Color3.fromRGB(255,90,90), death=Color3.fromRGB(200,40,40),
        hbActivate=Color3.fromRGB(255,200,40), hbEnded=Color3.fromRGB(180,140,40) } }
local function elGetRole(plr)
    local ch = plr.Character
    if not ch then return "survivor" end
    if ch:GetAttribute("IsHulk") == true or ch:GetAttribute("Transforming") == true then return "hulk" end
    if plr:GetAttribute("HulkbusterActive") == true or ch:GetAttribute("HulkbusterActive") == true then return "hulkbuster" end
    return "survivor"
end
local function elPush(text, color)
    if not EventLog.container then return end
    local label = Instance.new("TextLabel")
    label.BackgroundTransparency=1; label.Size=UDim2.new(1,0,0,32); label.Text=text
    label.TextColor3=color; label.Font=Enum.Font.GothamBlack; label.TextSize=22
    label.TextStrokeTransparency=0; label.TextStrokeColor3=Color3.new(0,0,0)
    label.TextXAlignment=Enum.TextXAlignment.Center; label.TextYAlignment=Enum.TextYAlignment.Center
    label.TextTransparency=1; label.LayoutOrder = math.floor(tick()*1000) % 100000
    label.Parent = EventLog.container
    TweenService:Create(label, TweenInfo.new(EventLog.cfg.fadeInTime), {TextTransparency=0}):Play()
    table.insert(EventLog.entries, { text=text, label=label, expires=tick()+EventLog.cfg.holdTime })
    while #EventLog.entries > EventLog.cfg.maxLines do
        local oldest = table.remove(EventLog.entries, 1)
        if oldest and oldest.label.Parent then oldest.label:Destroy() end
    end
end
local function elBind(plr)
    if plr == LocalPlayer then return end
    task.spawn(function()
        while EventLog.enabled and plr.Parent do
            local ch = plr.Character
            if ch then
                local hum = ch:FindFirstChildOfClass("Humanoid")
                if hum then
                    local lastHP = hum.Health
                    EventLog.reportedDeath[plr] = false
                    local conn = hum:GetPropertyChangedSignal("Health"):Connect(function()
                        local hp = hum.Health
                        if hp < lastHP - 0.5 then
                            local now = tick()
                            if not EventLog.hitCooldown[plr] or now - EventLog.hitCooldown[plr] > EventLog.cfg.hitCooldown then
                                EventLog.hitCooldown[plr] = now
                                local role = elGetRole(plr)
                                local curHP = math.max(0, math.floor(hp))
                                local txt, col
                                if role == "hulk" then txt="HULK "..plr.Name.." was hit ("..curHP.." HP)"; col=EventLog.colors.hulk
                                elseif role == "hulkbuster" then txt="HULKBUSTER "..plr.Name.." was hit ("..curHP.." HP)"; col=EventLog.colors.hulkbuster
                                else txt=plr.Name.." was hit ("..curHP.." HP)"; col=EventLog.colors.survivor end
                                elPush(txt, col)
                            end
                        end
                        lastHP = hp
                    end)
                    plr.CharacterAdded:Wait(); conn:Disconnect()
                else task.wait(0.3) end
            else task.wait(0.3) end
        end
    end)
end
function EventLog.enable()
    if EventLog.enabled then return end
    EventLog.enabled = true
    local sg = Instance.new("ScreenGui")
    sg.Name="BabisEventLog"; sg.ResetOnSpawn=false; sg.IgnoreGuiInset=true
    sg.DisplayOrder=999996; sg.Parent=uiParent
    EventLog.gui = sg
    local c = Instance.new("Frame")
    c.Size=UDim2.new(0,520,0,240); c.Position=UDim2.new(0.5,-260,1,-270)
    c.BackgroundTransparency=1; c.BorderSizePixel=0; c.Parent=sg
    EventLog.container = c
    local lay = Instance.new("UIListLayout")
    lay.FillDirection=Enum.FillDirection.Vertical; lay.HorizontalAlignment=Enum.HorizontalAlignment.Center
    lay.VerticalAlignment=Enum.VerticalAlignment.Bottom; lay.Padding=UDim.new(0,6)
    lay.SortOrder=Enum.SortOrder.LayoutOrder; lay.Parent=c
    EventLog.entries = {}; EventLog.hitCooldown = {}
    EventLog.reportedDeath = {}; EventLog.prevActive = {}
    for _, plr in ipairs(Players:GetPlayers()) do elBind(plr) end
    EventLog.conn = Players.PlayerAdded:Connect(elBind)
    task.spawn(function()
        while EventLog.enabled do
            task.wait(0.1)
            local now = tick()
            for i = #EventLog.entries, 1, -1 do
                local e = EventLog.entries[i]
                if not e.label.Parent then table.remove(EventLog.entries, i)
                elseif now > e.expires then
                    if e.label.Parent then e.label:Destroy() end
                    table.remove(EventLog.entries, i)
                end
            end
        end
    end)
end
function EventLog.disable()
    EventLog.enabled = false
    if EventLog.conn then EventLog.conn:Disconnect(); EventLog.conn = nil end
    for _, e in ipairs(EventLog.entries) do if e.label.Parent then e.label:Destroy() end end
    EventLog.entries = {}
    if EventLog.gui then EventLog.gui:Destroy(); EventLog.gui = nil end
    EventLog.container = nil
end

-- ============================================================
-- HULK ALERT
-- ============================================================
local HulkAlert = { enabled = false, gui = nil, container = nil,
    titleLbl = nil, infoLbl = nil, barFill = nil, lastStage = nil, pulseT = 0, conn = nil,
    cfg = { safeRange=200, nearbyRange=130, closeRange=60 },
    colors = { safe=Color3.fromRGB(60,220,100), nearby=Color3.fromRGB(255,220,60),
        close=Color3.fromRGB(255,140,40), danger=Color3.fromRGB(255,50,50) },
    labels = { safe="HULK FAR — SAFE", nearby="HULK NEARBY",
        close="HULK CLOSE", danger="DANGER — HULK ON YOU" } }
local function haIsHulk(plr)
    local ch = plr.Character; if not ch then return false end
    return ch:GetAttribute("IsHulk") == true or ch:GetAttribute("Transforming") == true
end
local function haFindHulk()
    local myHrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not myHrp then return nil, nil end
    local best, bestD
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and haIsHulk(plr) then
            local hrp = plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                local d = (hrp.Position - myHrp.Position).Magnitude
                if not bestD or d < bestD then best, bestD = plr, d end
            end
        end
    end
    return best, bestD
end
function HulkAlert.enable()
    if HulkAlert.enabled then return end
    HulkAlert.enabled = true
    local sg = Instance.new("ScreenGui")
    sg.Name="BabisHulkAlert"; sg.ResetOnSpawn=false; sg.IgnoreGuiInset=true
    sg.DisplayOrder=999998; sg.Parent=uiParent
    HulkAlert.gui = sg
    local c = Instance.new("Frame")
    c.Size=UDim2.new(0,460,0,90); c.Position=UDim2.new(0.5,-230,0,80)
    c.BackgroundTransparency=1; c.BorderSizePixel=0; c.Visible=false; c.Parent=sg
    HulkAlert.container = c
    local t = Instance.new("TextLabel")
    t.Size=UDim2.new(1,0,0,44); t.BackgroundTransparency=1; t.Text=HulkAlert.labels.safe
    t.TextColor3=HulkAlert.colors.safe; t.Font=Enum.Font.GothamBlack
    t.TextSize=32; t.TextStrokeTransparency=0; t.TextStrokeColor3=Color3.new(0,0,0)
    t.TextXAlignment=Enum.TextXAlignment.Center; t.Parent=c
    HulkAlert.titleLbl = t
    local i = Instance.new("TextLabel")
    i.Size=UDim2.new(1,0,0,24); i.Position=UDim2.new(0,0,0,48)
    i.BackgroundTransparency=1; i.Text="[--- studs]  ·  Name"
    i.TextColor3=HulkAlert.colors.safe; i.Font=Enum.Font.GothamBold
    i.TextSize=18; i.TextStrokeTransparency=0; i.TextStrokeColor3=Color3.new(0,0,0)
    i.TextXAlignment=Enum.TextXAlignment.Center; i.Parent=c
    HulkAlert.infoLbl = i
    local bg = Instance.new("Frame")
    bg.Size=UDim2.new(1,-40,0,3); bg.Position=UDim2.new(0,20,0,78)
    bg.BackgroundColor3=Color3.fromRGB(0,0,0); bg.BackgroundTransparency=0.7
    bg.BorderSizePixel=0; bg.Parent=c; corner(bg, 1)
    local fill = Instance.new("Frame")
    fill.Size=UDim2.new(0,0,1,0); fill.BackgroundColor3=HulkAlert.colors.safe
    fill.BorderSizePixel=0; fill.Parent=bg; corner(fill, 1)
    HulkAlert.barFill = fill
    HulkAlert.conn = RunService.RenderStepped:Connect(function(dt)
        if not HulkAlert.enabled then return end
        local plr, dist = haFindHulk()
        if not plr or not dist then
            if c.Visible then c.Visible = false end
            HulkAlert.lastStage = nil; return
        end
        if not c.Visible then c.Visible = true end
        local stage
        if dist > HulkAlert.cfg.safeRange then stage = "safe"
        elseif dist > HulkAlert.cfg.nearbyRange then stage = "nearby"
        elseif dist > HulkAlert.cfg.closeRange then stage = "close"
        else stage = "danger" end
        local color = HulkAlert.colors[stage]
        if HulkAlert.lastStage ~= stage then
            HulkAlert.lastStage = stage
            TweenService:Create(t, TweenInfo.new(0.2), {TextColor3=color}):Play()
            TweenService:Create(i, TweenInfo.new(0.2), {TextColor3=color}):Play()
            TweenService:Create(fill, TweenInfo.new(0.2), {BackgroundColor3=color}):Play()
        end
        local pct = math.clamp(1 - (dist / 200), 0, 1)
        fill.Size = UDim2.new(pct, 0, 1, 0)
        t.Text = HulkAlert.labels[stage]
        i.Text = string.format("[%d studs]  ·  %s", math.floor(dist), plr.Name)
        if stage == "danger" then
            HulkAlert.pulseT = HulkAlert.pulseT + dt * 10
            local pulse = 0.5 + 0.5 * math.sin(HulkAlert.pulseT)
            t.TextColor3 = Color3.fromRGB(255, math.floor(50 + pulse*90), math.floor(50 + pulse*90))
            t.TextSize = math.floor(32 * (1 + pulse*0.08))
            i.TextSize = math.floor(18 * (1 + pulse*0.08))
        elseif stage == "close" then
            HulkAlert.pulseT = HulkAlert.pulseT + dt * 6
            local pulse = 0.5 + 0.5 * math.sin(HulkAlert.pulseT)
            t.TextColor3 = Color3.fromRGB(math.floor(240+pulse*15), math.floor(120+pulse*40), math.floor(20+pulse*20))
            t.TextSize = 32; i.TextSize = 18
        else
            t.TextSize = 32; i.TextSize = 18
            t.TextColor3 = color; i.TextColor3 = color
        end
    end)
end
function HulkAlert.disable()
    HulkAlert.enabled = false
    if HulkAlert.conn then HulkAlert.conn:Disconnect(); HulkAlert.conn = nil end
    if HulkAlert.gui then HulkAlert.gui:Destroy(); HulkAlert.gui = nil end
    HulkAlert.container = nil; HulkAlert.titleLbl = nil; HulkAlert.infoLbl = nil; HulkAlert.barFill = nil
end

-- ============================================================
-- ESCAPE (Panic)
-- ============================================================
local Panic = { autoTrigger=false, triggerRadius=45, cooldown=5,
    topN=8, sampleStep=20, minHulkDist=50,
    offsetY=3, maxYDelta=6,
    points={}, hulkPos=nil, best=nil, lastTP=0, yRange=nil }
local function panicGetChar() return LocalPlayer.Character end
local function panicGetHrp() local ch = panicGetChar() return ch and ch:FindFirstChild("HumanoidRootPart") end
local function panicFindFacility()
    local f = Workspace:FindFirstChild("HulkFacility440x340")
    if f then return f end
    for _, d in ipairs(Workspace:GetChildren()) do
        if d:IsA("Model") and d.Name:lower():match("hulkfacility") then return d end
    end
    return nil
end
local function panicFindFloors()
    local fac = panicFindFacility(); if not fac then return nil end
    local fl = fac:FindFirstChild("Floors"); if not fl then return nil end
    return {room=fl:FindFirstChild("RoomFloors"), corridor=fl:FindFirstChild("CorridorFloors"), facility=fac}
end
local function panicComputeYRange(fac)
    local mn, mx = math.huge, -math.huge
    for _, d in ipairs(fac:GetDescendants()) do
        if d:IsA("BasePart") then mn=math.min(mn, d.Position.Y); mx=math.max(mx, d.Position.Y) end
    end
    if mn == math.huge then return nil end
    return {min=mn, max=mx}
end
local function panicSampleFolder(folder, tag)
    if not folder then return end
    local ch = panicGetChar(); local step = Panic.sampleStep
    for _, part in ipairs(folder:GetChildren()) do
        if part:IsA("BasePart") and not part.Name:lower():match("water") then
            local topY = part.Position.Y + part.Size.Y * 0.5
            local hX = math.max(part.Size.X * 0.5 - 4, 0)
            local hZ = math.max(part.Size.Z * 0.5 - 4, 0)
            for xO = -hX, hX, step do
                for zO = -hZ, hZ, step do
                    local ray = Ray.new(Vector3.new(part.Position.X + xO, topY + 1, part.Position.Z + zO), Vector3.new(0,-20,0))
                    local hit, hp = Workspace:FindPartOnRay(ray, ch)
                    if hit and hp and math.abs(hp.Y - topY) <= Panic.maxYDelta then
                        Panic.points[#Panic.points+1] = {pos=Vector3.new(hp.X, hp.Y + Panic.offsetY, hp.Z), tag=tag}
                    end
                end
            end
        end
    end
end
local function panicRescan()
    Panic.points = {}
    local f = panicFindFloors(); if not f then return end
    Panic.yRange = panicComputeYRange(f.facility)
    panicSampleFolder(f.room, "room"); panicSampleFolder(f.corridor, "corridor")
end
local function panicFindHulk()
    local hrp = panicGetHrp(); if not hrp then return nil end
    local best, bestD
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:GetAttribute("IsHulk") then
            local h = p.Character:FindFirstChild("HumanoidRootPart")
            if h then
                local d = (h.Position - hrp.Position).Magnitude
                if not bestD or d < bestD then best, bestD = h, d end
            end
        end
    end
    return best, bestD
end
local function panicPickSafe()
    if #Panic.points == 0 then return nil end
    local hrp = panicGetHrp(); if not hrp then return nil end
    local myPos = hrp.Position; local scored = {}
    for _, pt in ipairs(Panic.points) do
        if not Panic.yRange or (pt.pos.Y >= Panic.yRange.min - 5 and pt.pos.Y <= Panic.yRange.max + 5) then
            local hD = Panic.hulkPos and (pt.pos - Panic.hulkPos).Magnitude or 999
            if hD >= Panic.minHulkDist then
                scored[#scored+1] = {pt=pt, score=hD + math.min((pt.pos - myPos).Magnitude, 200)*0.1}
            end
        end
    end
    if #scored == 0 then
        for _, pt in ipairs(Panic.points) do
            local hD = Panic.hulkPos and (pt.pos - Panic.hulkPos).Magnitude or 999
            scored[#scored+1] = {pt=pt, score=hD}
        end
    end
    table.sort(scored, function(a, b) return a.score > b.score end)
    local topN = math.min(Panic.topN, #scored); if topN == 0 then return nil end
    return scored[math.random(1, topN)].pt
end
local function panicDo()
    if tick() - Panic.lastTP < Panic.cooldown then return false end
    local pt = panicPickSafe(); if not pt then return false end
    local ch = panicGetChar(); if not ch then return false end
    local ok = pcall(function() ch:PivotTo(CFrame.new(pt.pos)) end)
    if ok then
        Panic.lastTP = tick(); Panic.best = pt.pos
        showClimbOverlay(1.2)
        return true
    end
    return false
end
task.spawn(function() task.wait(2); panicRescan() end)
task.spawn(function() while true do task.wait(10); if #Panic.points == 0 then pcall(panicRescan) end end end)
task.spawn(function() while true do task.wait(0.25); local h = panicFindHulk(); Panic.hulkPos = h and h.Position or nil end end)
RunService.Heartbeat:Connect(function()
    if not Panic.autoTrigger then return end
    local _, d = panicFindHulk()
    if d and d <= Panic.triggerRadius then panicDo() end
end)
function Panic.setAuto(v) Panic.autoTrigger = v end
function Panic.fireManual() return panicDo() end

-- ============================================================
-- KILL HULK (Fling)
-- ============================================================
local Fling = { running = false, startedAt = 0, tpAt = 0, savedCFrame = nil,
    phase = "idle", returnsDone = 0, aborted = false, hulkName = "—",
    duration = 1.5, linearForce = 80, maxDrift = 12,
    returnTPs = 4, returnDelay = 0.15, settleDelay = 0.20,
    spinForce = 1500, predictOffset = 5 }
local function flingGetChar() return LocalPlayer.Character end
local function flingGetHum() local ch = flingGetChar() return ch and ch:FindFirstChildOfClass("Humanoid") end
local function flingGetHrp() local ch = flingGetChar() return ch and ch:FindFirstChild("HumanoidRootPart") end
local function flingFindHulk()
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:GetAttribute("IsHulk") then
            local hrp = p.Character:FindFirstChild("HumanoidRootPart")
            if hrp then return hrp, p end
        end
    end
    return nil
end
local function flingPredictTarget(hulkHrp)
    local pos = hulkHrp.Position
    local offset = Fling.predictOffset or 0
    if offset == 0 then return pos end
    local vel = hulkHrp.AssemblyLinearVelocity
    local speed = vel.Magnitude
    if speed < 0.5 then
        local look = hulkHrp.CFrame.LookVector
        return pos + look * offset
    end
    return pos + vel.Unit * offset
end
local function flingResetSelf()
    local hrp = flingGetHrp(); if not hrp then return end
    pcall(function()
        hrp.AssemblyLinearVelocity = Vector3.zero
        hrp.AssemblyAngularVelocity = Vector3.zero
    end)
end
local function flingReturnHome()
    if not Fling.savedCFrame then return end
    local ch = flingGetChar(); if not ch then return end
    Fling.phase = "returning"; Fling.returnsDone = 0
    task.spawn(function()
        for i = 1, Fling.returnTPs do
            if not ch.Parent then break end
            pcall(function() ch:PivotTo(Fling.savedCFrame) end)
            flingResetSelf(); Fling.returnsDone = i; task.wait(Fling.returnDelay)
        end
        Fling.phase = "idle"; Fling.savedCFrame = nil
    end)
end
local function flingStop(aborted)
    if aborted then Fling.aborted = true end
    Fling.running = false; flingResetSelf(); flingReturnHome()
end
RunService.Heartbeat:Connect(function()
    if not Fling.running then return end
    local hum = flingGetHum()
    if not hum or hum.Health <= 0 then flingStop(true) return end
    if tick() - Fling.startedAt >= Fling.duration then flingStop() return end
    local myHrp = flingGetHrp(); if not myHrp then return end
    local hulkHrp, hulkPlayer = flingFindHulk()
    if not hulkHrp then Fling.hulkName = "no hulk" return end
    Fling.hulkName = hulkPlayer.Name
    local ch = flingGetChar(); if not ch then return end
    local targetPos = flingPredictTarget(hulkHrp)
    local hulkPos = hulkHrp.Position; local myPos = myHrp.Position
    local distToReal = (myPos - hulkPos).Magnitude
    local distToPred = (myPos - targetPos).Magnitude
    if Fling.phase == "tp" then
        pcall(function() ch:PivotTo(CFrame.new(targetPos)) end)
        flingResetSelf(); Fling.tpAt = tick(); Fling.phase = "settle"; return
    end
    if Fling.phase == "settle" then
        if tick() - Fling.tpAt < Fling.settleDelay then return end
        Fling.phase = "force"
    end
    if Fling.phase == "force" then
        if distToPred > Fling.maxDrift then
            pcall(function() ch:PivotTo(CFrame.new(targetPos)) end); flingResetSelf()
        end
        if distToReal > Fling.maxDrift * 2 then
            pcall(function() ch:PivotTo(CFrame.new(targetPos)) end); flingResetSelf()
        end
        pcall(function()
            myHrp.AssemblyLinearVelocity = Vector3.zero
            myHrp.AssemblyAngularVelocity = Vector3.zero
        end)
        local f = Fling.linearForce; local s = Fling.spinForce
        pcall(function()
            myHrp.AssemblyLinearVelocity = Vector3.new(f, f * 0.05, f)
            myHrp.AssemblyAngularVelocity = Vector3.new(s, s, s)
        end)
    end
end)
function Fling.fire()
    if Fling.running then return false end
    local hrp = flingGetHrp(); if not hrp then return false end
    local hulkHrp = flingFindHulk(); if not hulkHrp then return false end
    Fling.savedCFrame = hrp.CFrame
    Fling.running = true; Fling.startedAt = tick(); Fling.tpAt = 0
    Fling.phase = "tp"; Fling.returnsDone = 0; Fling.aborted = false
    showKillOverlay(2.0)
    return true
end

-- ============================================================
-- REMOVE DOORS
-- ============================================================
local Doors = { enabled=false, invisible=true, noCollide=true, scanInterval=4,
    keywords={"door","gate","exit","porta","entrance","hinge","doorway","portal"},
    originals={}, loop=nil, addConn=nil }
local function doorNameMatches(name)
    local n = name:lower()
    for _, kw in ipairs(Doors.keywords) do if n:match(kw) then return true end end
    return false
end
local function doorIsPlayerPart(part)
    local p = part.Parent
    while p and p ~= Workspace do
        if p:IsA("Model") and p:FindFirstChildOfClass("Humanoid") then return true end
        p = p.Parent
    end
    return false
end
local function doorCapture(part)
    if Doors.originals[part] then return end
    Doors.originals[part] = {transp=part.Transparency, cc=part.CanCollide, cq=part.CanQuery, ct=part.CanTouch}
end
local function doorApply(part)
    if not part or not part.Parent or not part:IsA("BasePart") then return end
    if doorIsPlayerPart(part) then return end
    doorCapture(part)
    if Doors.invisible then part.Transparency = 1 end
    if Doors.noCollide then part.CanCollide=false; part.CanQuery=false; part.CanTouch=false end
end
local function doorRestore()
    for part, o in pairs(Doors.originals) do
        if part and part.Parent then
            pcall(function()
                part.Transparency=o.transp; part.CanCollide=o.cc
                part.CanQuery=o.cq; part.CanTouch=o.ct
            end)
        end
    end
    Doors.originals = {}
end
local function doorScan()
    for _, d in ipairs(Workspace:GetDescendants()) do
        if d:IsA("BasePart") and doorNameMatches(d.Name) then doorApply(d) end
        if d:IsA("Model") and doorNameMatches(d.Name) then
            for _, ch in ipairs(d:GetDescendants()) do
                if ch:IsA("BasePart") then doorApply(ch) end
            end
        end
    end
end
function Doors.enable()
    Doors.enabled = true
    task.spawn(function() task.wait(0.1); doorScan() end)
    if not Doors.loop then
        Doors.loop = task.spawn(function()
            while true do task.wait(Doors.scanInterval); if Doors.enabled then pcall(doorScan) end end
        end)
    end
    if not Doors.addConn then
        Doors.addConn = Workspace.DescendantAdded:Connect(function(d)
            if not Doors.enabled then return end
            if d:IsA("BasePart") and doorNameMatches(d.Name) then task.wait(0.1); doorApply(d) end
        end)
    end
end
function Doors.disable() Doors.enabled = false; doorRestore() end

-- ============================================================
-- INTRO
-- ============================================================
local function showIntro(onComplete)
    local introGui = Instance.new("ScreenGui")
    introGui.Name="BabisIntro"; introGui.ResetOnSpawn=false; introGui.IgnoreGuiInset=true
    introGui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling; introGui.DisplayOrder=200
    introGui.Parent=uiParent
    protectInstance(introGui)
    local overlay = Instance.new("Frame")
    overlay.Size=UDim2.new(1,0,1,0); overlay.BackgroundColor3=Color3.fromRGB(0,0,0)
    overlay.BackgroundTransparency=1; overlay.BorderSizePixel=0; overlay.Parent=introGui
    local center = Instance.new("Frame")
    center.Size=UDim2.new(0,260,0,260); center.Position=UDim2.new(0.5,0,0.5,-30)
    center.AnchorPoint=Vector2.new(0.5,0.5); center.BackgroundTransparency=1; center.Parent=overlay
    local glow = Instance.new("Frame")
    glow.Size=UDim2.new(0,220,0,220); glow.Position=UDim2.new(0.5,0,0.5,0)
    glow.AnchorPoint=Vector2.new(0.5,0.5); glow.BackgroundColor3=CONFIG.colors.accent
    glow.BackgroundTransparency=1; glow.BorderSizePixel=0; glow.Parent=center; corner(glow,110)
    local glowRing = Instance.new("Frame")
    glowRing.Size=UDim2.new(0,260,0,260); glowRing.Position=UDim2.new(0.5,0,0.5,0)
    glowRing.AnchorPoint=Vector2.new(0.5,0.5); glowRing.BackgroundTransparency=1
    glowRing.Parent=center; corner(glowRing,130)
    local ringStroke = stroke(glowRing, CONFIG.colors.accent, 1, 1)
    local image = Instance.new("ImageLabel")
    image.Size=UDim2.new(0,CONFIG.introImgW,0,CONFIG.introImgH)
    image.Position=UDim2.new(0.5,0,0.5,0); image.AnchorPoint=Vector2.new(0.5,0.5)
    image.BackgroundTransparency=1; image.Image=CONFIG.introImageId
    image.ImageTransparency=1; image.ScaleType=Enum.ScaleType.Fit; image.Parent=center
    local subtitle = Instance.new("TextLabel")
    subtitle.Size=UDim2.new(1,0,0,30); subtitle.Position=UDim2.new(0.5,0,0.5,120)
    subtitle.AnchorPoint=Vector2.new(0.5,0); subtitle.BackgroundTransparency=1
    subtitle.Text="CONNECTING TO SERVER"; subtitle.TextColor3=Color3.fromRGB(225,230,245)
    subtitle.TextTransparency=1; subtitle.Font=CONFIG.fonts.intro
    subtitle.TextSize=CONFIG.textSizes.intro; subtitle.TextXAlignment=Enum.TextXAlignment.Center
    subtitle.Parent=overlay
    local line = Instance.new("Frame")
    line.Size=UDim2.new(0,0,0,1); line.Position=UDim2.new(0.5,0,0.5,158)
    line.AnchorPoint=Vector2.new(0.5,0); line.BackgroundColor3=CONFIG.colors.accent
    line.BackgroundTransparency=1; line.BorderSizePixel=0; line.Parent=overlay
    tween(overlay, {BackgroundTransparency=0.55}, 0.5)
    tween(image, {ImageTransparency=0}, 0.5)
    tween(glow, {BackgroundTransparency=0.88}, 0.6)
    tween(ringStroke, {Transparency=0.6}, 0.6)
    tween(subtitle, {TextTransparency=0}, 0.5)
    tween(line, {BackgroundTransparency=0.2}, 0.5)
    tween(line, {Size=UDim2.new(0,190,0,1)}, 0.7)
    local spinning = true
    task.spawn(function()
        while spinning do
            local s = TweenService:Create(image, TweenInfo.new(1.6, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Rotation=image.Rotation+360})
            s:Play(); s.Completed:Wait()
            if not spinning then break end
            task.wait(0.45)
        end
    end)
    task.spawn(function()
        local base="CONNECTING TO SERVER"; local n=0
        while spinning do
            n=(n+1)%4; subtitle.Text=base..string.rep(".",n); task.wait(0.35)
        end
    end)
    task.spawn(function()
        while spinning do
            tween(glow, {BackgroundTransparency=0.95}, 0.9)
            tween(ringStroke, {Transparency=0.9}, 0.9)
            task.wait(0.9)
            if not spinning then break end
            tween(glow, {BackgroundTransparency=0.82}, 0.9)
            tween(ringStroke, {Transparency=0.4}, 0.9)
            task.wait(0.9)
        end
    end)
    task.delay(CONFIG.introDuration, function()
        spinning = false
        tween(overlay, {BackgroundTransparency=1}, 0.55)
        tween(image, {ImageTransparency=1}, 0.5)
        tween(glow, {BackgroundTransparency=1}, 0.5)
        tween(ringStroke, {Transparency=1}, 0.5)
        tween(subtitle, {TextTransparency=1}, 0.4)
        tween(line, {BackgroundTransparency=1}, 0.4)
        tween(line, {Size=UDim2.new(0,0,0,1)}, 0.5)
        task.wait(0.6)
        introGui:Destroy()
        if onComplete then onComplete() end
    end)
end

-- ============================================================
-- CONFIG SYSTEM
-- ============================================================
local ConfigSys = {}
do
    function ConfigSys.ensure()
        if not safeCall(isfolder, "Babis") then safeCall(makefolder, "Babis") end
        if not safeCall(isfolder, CONFIG.cfgFolder) then safeCall(makefolder, CONFIG.cfgFolder) end
    end
    function ConfigSys.list()
        ConfigSys.ensure(); local out = {}
        local files = safeCall(listfiles, CONFIG.cfgFolder)
        if type(files) ~= "table" then return out end
        for _, path in ipairs(files) do
            local name = path:match("([^/\\]+)$") or path
            name = name:gsub(CONFIG.cfgExt:gsub("%.", "%%."), "")
            table.insert(out, name)
        end
        return out
    end
    function ConfigSys.save(name, data)
        ConfigSys.ensure()
        if type(name) ~= "string" or name == "" then return false, "invalid name" end
        local path = CONFIG.cfgFolder .. "/" .. name .. CONFIG.cfgExt
        local okEnc, resEnc = pcall(function() return HttpService:JSONEncode(data) end)
        if not okEnc then return false, "encode failed" end
        local ok = safeCall(writefile, path, resEnc)
        if ok == nil then return false, "writefile failed" end
        return true
    end
    function ConfigSys.load(name)
        ConfigSys.ensure()
        local path = CONFIG.cfgFolder .. "/" .. name .. CONFIG.cfgExt
        local content = safeCall(readfile, path)
        if type(content) ~= "string" then return nil end
        local ok, data = pcall(function() return HttpService:JSONDecode(content) end)
        if not ok then return nil end
        return data
    end
    function ConfigSys.delete(name)
        local path = CONFIG.cfgFolder .. "/" .. name .. CONFIG.cfgExt
        return safeCall(delfile, path) ~= nil
    end
    function ConfigSys.getAutoload()
        local content = safeCall(readfile, CONFIG.autoloadFile)
        if type(content) == "string" and content ~= "" then return content end
        return nil
    end
    function ConfigSys.setAutoload(name)
        ConfigSys.ensure()
        if name == nil or name == "" then safeCall(delfile, CONFIG.autoloadFile)
        else safeCall(writefile, CONFIG.autoloadFile, name) end
    end
end

-- ============================================================
-- NOTIFICATIONS
-- ============================================================
local function createNotifier()
    local notifGui = Instance.new("ScreenGui")
    notifGui.Name="BabisUIKitNotif"; notifGui.ResetOnSpawn=false; notifGui.IgnoreGuiInset=true
    notifGui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling; notifGui.DisplayOrder=300
    notifGui.Parent=uiParent
    protectInstance(notifGui)
    local sound = Instance.new("Sound")
    sound.SoundId=CONFIG.notifySoundId; sound.Volume=CONFIG.notifySoundVol
    sound.Parent=SoundService
    local container = Instance.new("Frame")
    container.BackgroundTransparency=1; container.Size=UDim2.new(0,320,0,0)
    container.AutomaticSize=Enum.AutomaticSize.Y; container.AnchorPoint=Vector2.new(1,0)
    container.Position=UDim2.new(1,-20,0,20); container.Parent=notifGui
    local layout = Instance.new("UIListLayout")
    layout.FillDirection=Enum.FillDirection.Vertical; layout.Padding=UDim.new(0,10)
    layout.SortOrder=Enum.SortOrder.LayoutOrder; layout.VerticalAlignment=Enum.VerticalAlignment.Top
    layout.HorizontalAlignment=Enum.HorizontalAlignment.Right; layout.Parent=container

    local BLUE = CONFIG.colors.accent
    local GOLD = CONFIG.colors.gold
    local kindColors = {
        info    = BLUE,
        success = BLUE,
        warn    = BLUE,
        error   = BLUE,
        premium = GOLD,
    }

    local order = 0
    local function dismiss(row)
        if not row or not row.Parent then return end
        if row:GetAttribute("Dismissing") then return end
        row:SetAttribute("Dismissing", true)
        local card = row:FindFirstChild("Card")
        if card then
            tween(card, {Position=UDim2.new(1,420,0,0), BackgroundTransparency=0.7}, 0.34, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
            for _, d in ipairs(card:GetDescendants()) do
                if d:IsA("TextLabel") then tween(d, {TextTransparency=1}, 0.28)
                elseif d:IsA("ImageLabel") then tween(d, {ImageTransparency=1}, 0.28)
                elseif d:IsA("Frame") then tween(d, {BackgroundTransparency=1}, 0.28)
                elseif d:IsA("UIStroke") then tween(d, {Transparency=1}, 0.28) end
            end
        end
        tween(row, {Size=UDim2.new(1, 0, 0, 0)}, 0.34, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
        task.delay(0.38, function() if row and row.Parent then row:Destroy() end end)
    end
    local function notify(title, message, kind, duration)
        title    = title    or "Notification"
        message  = message  or ""
        kind     = kind     or "info"
        duration = duration or 2.0
        if type(kind) == "number" then duration = kind; kind = "info" end

        if sound.IsPlaying then sound:Stop() end
        sound.TimePosition=0; sound:Play()
        order = order + 1

        local accentColor = kindColors[kind] or BLUE
        local row = Instance.new("Frame")
        row.Size=UDim2.new(1,0,0,76); row.BackgroundTransparency=1
        row.ClipsDescendants=false; row.LayoutOrder=order; row.Parent=container
        local card = Instance.new("Frame")
        card.Name="Card"; card.Size=UDim2.new(1,0,1,0); card.Position=UDim2.new(1,380,0,0)
        card.BackgroundColor3=Color3.fromRGB(18,20,26); card.BorderSizePixel=0; card.Parent=row
        corner(card,12); stroke(card, Color3.fromRGB(56,55,62), 1.5, 0)
        local bar = Instance.new("Frame")
        bar.Size=UDim2.new(0,5,1,-22); bar.Position=UDim2.new(0,9,0,11)
        bar.BackgroundColor3=accentColor; bar.BorderSizePixel=0; bar.Parent=card; corner(bar,3)
        local bellBg = Instance.new("Frame")
        bellBg.Size=UDim2.new(0,42,0,42); bellBg.Position=UDim2.new(0,20,0.5,-21)
        bellBg.BackgroundColor3=CONFIG.colors.bellBg; bellBg.BorderSizePixel=0; bellBg.Parent=card
        corner(bellBg,21); stroke(bellBg, accentColor, 1.2, 0.4)
        local bell = Instance.new("ImageLabel")
        bell.Size=UDim2.new(0,28,0,28); bell.Position=UDim2.new(0.5,-14,0.5,-14)
        bell.BackgroundTransparency=1; bell.Image=CONFIG.bellIconId
        bell.ImageColor3=accentColor; bell.ScaleType=Enum.ScaleType.Fit; bell.Parent=bellBg
        local titleLbl = Instance.new("TextLabel")
        titleLbl.BackgroundTransparency=1; titleLbl.Text=title
        titleLbl.TextColor3=Color3.fromRGB(245,248,255); titleLbl.Font=Enum.Font.GothamBold
        titleLbl.TextSize=16; titleLbl.TextXAlignment=Enum.TextXAlignment.Left
        titleLbl.TextYAlignment=Enum.TextYAlignment.Top
        titleLbl.Size=UDim2.new(1,-90,0,22); titleLbl.Position=UDim2.new(0,72,0,16)
        titleLbl.Parent=card
        local msgLbl = Instance.new("TextLabel")
        msgLbl.BackgroundTransparency=1; msgLbl.Text=message
        msgLbl.TextColor3=Color3.fromRGB(160,165,185); msgLbl.Font=Enum.Font.Gotham
        msgLbl.TextSize=14; msgLbl.TextXAlignment=Enum.TextXAlignment.Left
        msgLbl.TextYAlignment=Enum.TextYAlignment.Top; msgLbl.TextWrapped=true
        msgLbl.Size=UDim2.new(1,-90,0,34); msgLbl.Position=UDim2.new(0,72,0,38)
        msgLbl.Parent=card
        tween(card, {Position=UDim2.new(0,0,0,0)}, 0.35)
        task.spawn(function()
            task.wait(0.4)
            if not bell.Parent then return end
            bell.Rotation=-12
            tween(bell,{Rotation=12},0.10); task.wait(0.11)
            if not bell.Parent then return end
            tween(bell,{Rotation=-8},0.10); task.wait(0.11)
            if not bell.Parent then return end
            tween(bell,{Rotation=6},0.10); task.wait(0.11)
            if not bell.Parent then return end
            tween(bell,{Rotation=0},0.12)
        end)
        task.spawn(function() task.wait(duration); dismiss(row) end)
        return row
    end
    return notify
end

local notify = createNotifier()

-- ============================================================
-- GAME TOOLS — closure
-- Auto Punch + Auto Mission + Auto Spin
-- ============================================================
local GameTools = (function()
    local HulkAttack = ReplicatedStorage:FindFirstChild("HulkAttack")
    local HulkSkinSystem = ReplicatedStorage:FindFirstChild("HulkSkinSystem")
    if not HulkSkinSystem then
        task.spawn(function() HulkSkinSystem = ReplicatedStorage:WaitForChild("HulkSkinSystem", 30) end)
    end
    local function skinRemote(name)
        if HulkSkinSystem then return HulkSkinSystem:FindFirstChild(name) end
    end

    local AutoPunch = { running = false, count = 0, rateClock = 0, rateCount = 0 }
    local function getLocalRoot()
        local c = LocalPlayer.Character
        if not c then return nil end
        return c:FindFirstChild("HumanoidRootPart")
    end
    RunService.RenderStepped:Connect(function(dt)
        if not AutoPunch.running then
            if AutoPunch.rateClock > 0 then AutoPunch.rateClock = 0; AutoPunch.rateCount = 0 end
            return
        end
        if HulkAttack then
            local root = getLocalRoot()
            if root then
                pcall(function() HulkAttack:FireServer(root.CFrame, Vector3.new(0, 0, 0)) end)
                AutoPunch.count = AutoPunch.count + 1
                AutoPunch.rateCount = AutoPunch.rateCount + 1
            end
        end
        AutoPunch.rateClock = AutoPunch.rateClock + dt
        if AutoPunch.rateClock >= 0.5 then AutoPunch.rateClock = 0; AutoPunch.rateCount = 0 end
    end)
    function AutoPunch.setEnabled(v) AutoPunch.running = v and true or false end

    local SharedState = { data = nil }
    local function readState()
        local EmoteSpin = skinRemote("EmoteSpin")
        if EmoteSpin then
            local ok, res = pcall(function() return EmoteSpin:InvokeServer() end)
            if ok and type(res) == "table" and res.Data then
                SharedState.data = res.Data
                return res.Data
            end
        end
        return nil
    end

    local AutoMission = { enabled = false, interval = 2, last = 0 }
    local function claimAllMissions()
        local ClaimMission = skinRemote("ClaimMission")
        local ClaimDaily = skinRemote("ClaimDaily")
        if not SharedState.data then readState() end
        local d = SharedState.data
        if not d then return end
        if ClaimMission then
            local missions = d.Missions or {}
            local idxs = {}
            for i, m in pairs(missions) do
                if m.Completed and not m.Claimed then idxs[#idxs+1] = i end
            end
            table.sort(idxs)
            for _, i in ipairs(idxs) do
                if not AutoMission.enabled then break end
                local ok, res = pcall(function() return ClaimMission:InvokeServer(i) end)
                if ok and type(res) == "table" and res.Data then SharedState.data = res.Data end
                task.wait(0.1)
            end
        end
        if ClaimDaily and SharedState.data and SharedState.data.Daily and SharedState.data.Daily.CanClaim then
            pcall(function() ClaimDaily:InvokeServer() end)
        end
    end
    RunService.Heartbeat:Connect(function()
        if not AutoMission.enabled then return end
        local now = tick()
        if now - AutoMission.last < AutoMission.interval then return end
        AutoMission.last = now
        task.spawn(function() pcall(claimAllMissions) end)
    end)
    function AutoMission.enable() AutoMission.enabled = true; AutoMission.last = 0; task.spawn(function() pcall(claimAllMissions) end) end
    function AutoMission.disable() AutoMission.enabled = false end

    local SpinSystem = { running = false, target = nil, attempts = 0, spent = 0, renderUI = nil }
    function SpinSystem.getState() return SharedState.data end
    local function canAffordSpin()
        local d = SharedState.data
        if not d then return true end
        if (d.AbilitySpins or 0) > 0 then return true end
        return (d.Money or 0) >= (d.AbilitySpinCost or 1000)
    end
    local function stopSpin(reason)
        if not SpinSystem.running then return end
        SpinSystem.running = false
        if SpinSystem.renderUI then pcall(SpinSystem.renderUI) end
    end
    local function startSpin()
        if not SpinSystem.target then notify("Spin", "Select a MISSING ability first", "info"); return end
        if not SharedState.data then readState() end
        local d = SharedState.data
        if d and d.OwnedAbilities and d.OwnedAbilities[SpinSystem.target] then
            notify("Spin", SpinSystem.target .. " already owned", "info"); return
        end
        if not canAffordSpin() then notify("Spin", "No spins and no money", "info"); return end
        SpinSystem.running = true; SpinSystem.attempts = 0; SpinSystem.spent = 0
        if SpinSystem.renderUI then pcall(SpinSystem.renderUI) end
        task.spawn(function()
            while SpinSystem.running do
                if not SpinSystem.target then stopSpin("target removed"); break end
                if not canAffordSpin() then stopSpin("out of money"); break end
                local d2 = SharedState.data
                if d2 and d2.OwnedAbilities and d2.OwnedAbilities[SpinSystem.target] then
                    stopSpin("ACQUIRED · " .. SpinSystem.target); break
                end
                local AbilitySpin = skinRemote("AbilitySpin")
                if not AbilitySpin then task.wait(1) else
                    local prev = SharedState.data and SharedState.data.Money or 0
                    local ok, res = pcall(function() return AbilitySpin:InvokeServer() end)
                    if not ok or type(res) ~= "table" then task.wait(1) else
                        if res.Data then SharedState.data = res.Data end
                        if res.Success == true then
                            SpinSystem.attempts = SpinSystem.attempts + 1
                            local delta = prev - (SharedState.data.Money or prev)
                            if delta > 0 then SpinSystem.spent = SpinSystem.spent + delta end
                            if SpinSystem.renderUI then pcall(SpinSystem.renderUI) end
                            local nowData = SharedState.data
                            if nowData and nowData.OwnedAbilities and nowData.OwnedAbilities[SpinSystem.target] then
                                notify("Spin", "★ GOT " .. SpinSystem.target .. " in " .. SpinSystem.attempts .. " spins!", "info")
                                stopSpin("ACQUIRED · " .. SpinSystem.target); break
                            end
                            task.wait(0.08)
                        else
                            local msg = tostring(res.Message or "?"):lower()
                            if msg:find("lobby") then task.wait(2)
                            elseif msg:find("money") or msg:find("fund") or msg:find("insufficient") then stopSpin("out of money"); break
                            else task.wait(1) end
                        end
                    end
                end
            end
            if SpinSystem.renderUI then pcall(SpinSystem.renderUI) end
        end)
    end
    function SpinSystem.setEnabled(v) if v then startSpin() else stopSpin("manual") end end
    function SpinSystem.setTarget(name) SpinSystem.target = name end
    function SpinSystem.refresh()
        readState()
        if SpinSystem.renderUI then pcall(SpinSystem.renderUI) end
    end
    task.spawn(function()
        while true do
            task.wait(6)
            if not SpinSystem.running then
                readState()
                if SpinSystem.renderUI then pcall(SpinSystem.renderUI) end
            end
        end
    end)
    task.delay(1.2, function() pcall(readState) end)

    return {
        AutoPunch = AutoPunch,
        AutoMission = AutoMission,
        SpinSystem = SpinSystem,
        readState = readState,
    }
end)()

-- ============================================================
-- FLOATING BALLS
-- ============================================================
local Balls = { panic = nil, fling = nil }
local function destroyBall(key)
    local b = Balls[key]; if not b then return end
    if b.connUpd then b.connUpd:Disconnect() end
    if b.connChanged then b.connChanged:Disconnect() end
    if b.connEnded then b.connEnded:Disconnect() end
    if b.connCloseXUpd then b.connCloseXUpd:Disconnect() end
    if b.gui then b.gui:Destroy() end
    Balls[key] = nil
end
local function buildBall(key, opts)
    if Balls[key] then return end
    local sg = Instance.new("ScreenGui")
    sg.Name = key == "panic" and "BabisPanicFloat" or "BabisFlingFloat"
    sg.ResetOnSpawn = false; sg.IgnoreGuiInset = true
    sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling; sg.DisplayOrder = 999
    sg.Parent = uiParent
    protectInstance(sg)
    local size = 90
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, size, 0, size)
    btn.Position = opts.pos or UDim2.new(1, -110, 1, -220)
    btn.BackgroundColor3 = opts.bg; btn.BackgroundTransparency = 0.15
    btn.Text = opts.text; btn.TextColor3 = Color3.new(1,1,1)
    btn.Font = Enum.Font.GothamBlack; btn.TextSize = 14
    btn.BorderSizePixel = 0; btn.AutoButtonColor = false; btn.Parent = sg
    corner(btn, size / 2)
    local st = Instance.new("UIStroke", btn)
    st.Thickness = 3; st.Color = opts.strokeColor; st.Transparency = 0.2
    local state = { gui = sg, btn = btn, stroke = st,
        dragging = false, moved = false, dragStart = nil, startPos = nil,
        connChanged = nil, connEnded = nil, connCloseXUpd = nil,
        closeX = nil, hoveringX = false, pressedOnButton = false }
    Balls[key] = state
    local closeSize = 22
    local closeX = Instance.new("TextButton")
    closeX.Size = UDim2.new(0, closeSize, 0, closeSize)
    closeX.AnchorPoint = Vector2.new(0.5, 0.5)
    closeX.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    closeX.BackgroundTransparency = 0.05; closeX.Text = "×"
    closeX.TextColor3 = Color3.new(1,1,1); closeX.Font = Enum.Font.GothamBold
    closeX.TextSize = 16; closeX.BorderSizePixel = 0
    closeX.AutoButtonColor = false; closeX.ZIndex = 10; closeX.Parent = sg
    corner(closeX, closeSize / 2)
    local cs = stroke(closeX, Color3.fromRGB(80, 80, 90), 1.5, 0.2)
    state.closeX = closeX
    state.connCloseXUpd = RunService.RenderStepped:Connect(function()
        if not closeX.Parent or not btn.Parent then return end
        closeX.Position = UDim2.new(
            btn.Position.X.Scale,
            btn.Position.X.Offset + btn.AbsoluteSize.X / 2,
            btn.Position.Y.Scale,
            btn.Position.Y.Offset - closeSize / 2)
    end)
    closeX.MouseEnter:Connect(function()
        state.hoveringX = true
        tween(closeX, {BackgroundColor3 = Color3.fromRGB(220, 70, 90)}, CONFIG.anim.fast)
        tween(cs, {Transparency = 0}, CONFIG.anim.fast)
    end)
    closeX.MouseLeave:Connect(function()
        state.hoveringX = false
        tween(closeX, {BackgroundColor3 = Color3.fromRGB(30, 30, 35)}, CONFIG.anim.fast)
        tween(cs, {Transparency = 0.2}, CONFIG.anim.fast)
    end)
    closeX.Activated:Connect(function() destroyBall(key) end)
    btn.MouseEnter:Connect(function()
        tween(btn, {BackgroundColor3 = opts.bgHover}, CONFIG.anim.fast)
        tween(st, {Transparency=0}, CONFIG.anim.fast)
    end)
    btn.MouseLeave:Connect(function()
        tween(btn, {BackgroundColor3 = opts.bg}, CONFIG.anim.fast)
        tween(st, {Transparency=0.2}, CONFIG.anim.fast)
    end)
    btn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            state.dragging = true; state.moved = false; state.pressedOnButton = true
            state.dragStart = input.Position; state.startPos = btn.Position
        end
    end)
    state.connChanged = UserInputService.InputChanged:Connect(function(input)
        if not state.dragging then return end
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            local delta = input.Position - state.dragStart
            if delta.Magnitude > 8 then state.moved = true end
            if state.moved then
                btn.Position = UDim2.new(
                    state.startPos.X.Scale, state.startPos.X.Offset + delta.X,
                    state.startPos.Y.Scale, state.startPos.Y.Offset + delta.Y)
            end
        end
    end)
    state.connEnded = UserInputService.InputEnded:Connect(function(input)
        if not state.pressedOnButton then return end
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            local wasMoved = state.moved
            state.dragging = false; state.moved = false; state.pressedOnButton = false
            if not wasMoved and not state.hoveringX then pcall(opts.onFire) end
        end
    end)
end

-- ============================================================
-- MAIN UI
-- ============================================================
local function buildMainUI()
    local savedPos = loadPosition() or UDim2.new(0.5, 0, 0.5, 0)

    local UI = {
        activeTab = CONFIG.defaultTab, connections = {}, isMinimized = false,
        isOpen = false, destroyed = false, options = {}, infoOpen = false,
        cfgSelected = nil, cfgList = {}, savedPos = savedPos, everOpened = false,
        refreshCfgList = nil, updateAutoloadText = nil,
    }
    local function track(conn) table.insert(UI.connections, conn); return conn end
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name="BabisUIKit"; screenGui.ResetOnSpawn=false; screenGui.IgnoreGuiInset=true
    screenGui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling; screenGui.DisplayOrder=10000
    screenGui.Parent=uiParent
    protectInstance(screenGui)
    local scaleWrapper = Instance.new("Frame")
    scaleWrapper.Name = "Root"
    scaleWrapper.BackgroundTransparency=1
    scaleWrapper.Size=UDim2.new(0, CONFIG.sizes.windowWidth, 0, 0)
    scaleWrapper.Position=savedPos
    scaleWrapper.AnchorPoint=Vector2.new(0.5, 0.5)
    scaleWrapper.ClipsDescendants=true
    scaleWrapper.Parent=screenGui
    protectInstance(scaleWrapper)
    local uiScale = Instance.new("UIScale"); uiScale.Parent=scaleWrapper
    local mainWindow = Instance.new("Frame")
    mainWindow.Size=UDim2.new(1,0,1,0); mainWindow.BackgroundColor3=CONFIG.colors.windowBg
    mainWindow.BorderSizePixel=0; mainWindow.ClipsDescendants=true
    mainWindow.BackgroundTransparency=1; mainWindow.Parent=scaleWrapper
    protectInstance(mainWindow)
    corner(mainWindow, CONFIG.sizes.windowRadius)

    local function getViewport()
        local cam = workspace.CurrentCamera
        local vp = cam and cam.ViewportSize
        if not vp or vp.X <= 0 or vp.Y <= 0 then return Vector2.new(1920, 1080) end
        return vp
    end
    local function currentLogicalHeight()
        return UI.isMinimized and (CONFIG.sizes.headerHeight + 2) or CONFIG.sizes.windowHeight
    end
    local function currentPixelSize()
        local s = uiScale.Scale or 1
        return CONFIG.sizes.windowWidth * s, currentLogicalHeight() * s
    end
    local function clampCenter(cx, cy, w, h)
        local vp = getViewport()
        local halfW, halfH = w / 2, h / 2
        local minCX, maxCX = halfW, vp.X - halfW
        local minCY, maxCY = halfH, vp.Y - halfH
        if maxCX < minCX then cx = vp.X / 2 else cx = math.clamp(cx, minCX, maxCX) end
        if maxCY < minCY then cy = vp.Y / 2 else cy = math.clamp(cy, minCY, maxCY) end
        return cx, cy
    end
    local function currentCenterPixels()
        local vp = getViewport()
        local cur = scaleWrapper.Position
        return cur.X.Scale * vp.X + cur.X.Offset, cur.Y.Scale * vp.Y + cur.Y.Offset
    end

    local header = Instance.new("Frame")
    header.Name = "Header"
    header.Size=UDim2.new(1,0,0,CONFIG.sizes.headerHeight)
    header.BackgroundColor3=CONFIG.colors.headerTint; header.BackgroundTransparency=1
    header.BorderSizePixel=0; header.Parent=mainWindow
    protectInstance(header)
    corner(header, CONFIG.sizes.windowRadius)
    local headerFlat = Instance.new("Frame")
    headerFlat.Size=UDim2.new(1,0,0,16); headerFlat.Position=UDim2.new(0,0,1,-16)
    headerFlat.BackgroundColor3=CONFIG.colors.headerTint; headerFlat.BackgroundTransparency=1
    headerFlat.BorderSizePixel=0; headerFlat.Parent=header
    protectInstance(headerFlat)
    local appLabel = Instance.new("TextLabel")
    appLabel.BackgroundTransparency=1; appLabel.Text=CONFIG.appName
    appLabel.TextColor3=CONFIG.colors.accent; appLabel.Font=CONFIG.fonts.appName
    appLabel.TextSize=CONFIG.textSizes.appName; appLabel.TextXAlignment=Enum.TextXAlignment.Left
    appLabel.TextYAlignment=Enum.TextYAlignment.Center
    appLabel.Size=UDim2.new(0,400,0,34); appLabel.Position=UDim2.new(0,22,0,8)
    appLabel.Parent=header
    local subtitleLabel = Instance.new("TextLabel")
    subtitleLabel.BackgroundTransparency=1; subtitleLabel.Text=CONFIG.edition
    subtitleLabel.TextColor3=Color3.fromRGB(255,255,255); subtitleLabel.Font=Enum.Font.GothamBold
    subtitleLabel.TextSize=14; subtitleLabel.TextXAlignment=Enum.TextXAlignment.Left
    subtitleLabel.TextYAlignment=Enum.TextYAlignment.Center
    subtitleLabel.Size=UDim2.new(0,220,0,18); subtitleLabel.Position=UDim2.new(0,24,0,42)
    subtitleLabel.Parent=header
    local versionLabel = Instance.new("TextLabel")
    versionLabel.BackgroundTransparency=1; versionLabel.Text=CONFIG.version
    versionLabel.TextColor3=CONFIG.colors.textMuted; versionLabel.Font=CONFIG.fonts.version
    versionLabel.TextSize=13; versionLabel.TextXAlignment=Enum.TextXAlignment.Left
    versionLabel.TextYAlignment=Enum.TextYAlignment.Center
    versionLabel.Size=UDim2.new(0,200,0,16); versionLabel.Position=UDim2.new(0,24,0,60)
    versionLabel.Parent=header
    local infoBtn = Instance.new("TextButton")
    infoBtn.Size=UDim2.new(0,60,0,60); infoBtn.Position=UDim2.new(1,-182,0,12)
    infoBtn.BackgroundTransparency=1; infoBtn.Text=""; infoBtn.AutoButtonColor=false
    infoBtn.Parent=header
    local infoIcon = Instance.new("ImageLabel")
    infoIcon.Size=UDim2.new(0,30,0,30); infoIcon.Position=UDim2.new(0.5,-15,0.5,-15)
    infoIcon.BackgroundTransparency=1; infoIcon.Image=CONFIG.infoIconId
    infoIcon.ImageColor3=CONFIG.colors.navIcon; infoIcon.ScaleType=Enum.ScaleType.Fit
    infoIcon.Parent=infoBtn
    local minBtn = Instance.new("TextButton")
    minBtn.Size=UDim2.new(0,60,0,60); minBtn.Position=UDim2.new(1,-122,0,12)
    minBtn.BackgroundTransparency=1; minBtn.Text=""; minBtn.AutoButtonColor=false
    minBtn.Parent=header
    local minGlyph = Instance.new("Frame")
    minGlyph.Size=UDim2.new(0,22,0,3); minGlyph.Position=UDim2.new(0.5,-11,0.5,-1)
    minGlyph.BackgroundColor3=CONFIG.colors.textPrimary; minGlyph.BorderSizePixel=0
    minGlyph.Parent=minBtn; corner(minGlyph, 2)
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size=UDim2.new(0,60,0,60); closeBtn.Position=UDim2.new(1,-62,0,12)
    closeBtn.BackgroundTransparency=1; closeBtn.Text=""; closeBtn.AutoButtonColor=false
    closeBtn.Parent=header
    local xLen, xThk = 26, 3
    local xBar1 = Instance.new("Frame")
    xBar1.Size=UDim2.new(0,xLen,0,xThk); xBar1.Position=UDim2.new(0.5,-xLen/2,0.5,-xThk/2)
    xBar1.BackgroundColor3=CONFIG.colors.textPrimary; xBar1.BorderSizePixel=0
    xBar1.Rotation=45; xBar1.Parent=closeBtn; corner(xBar1, 2)
    local xBar2 = Instance.new("Frame")
    xBar2.Size=UDim2.new(0,xLen,0,xThk); xBar2.Position=UDim2.new(0.5,-xLen/2,0.5,-xThk/2)
    xBar2.BackgroundColor3=CONFIG.colors.textPrimary; xBar2.BorderSizePixel=0
    xBar2.Rotation=-45; xBar2.Parent=closeBtn; corner(xBar2, 2)
    local divider = Instance.new("Frame")
    divider.Size=UDim2.new(1,0,0,2); divider.Position=UDim2.new(0,0,0,CONFIG.sizes.headerHeight)
    divider.BackgroundColor3=CONFIG.colors.divider; divider.BorderSizePixel=0
    divider.ZIndex=2; divider.Parent=mainWindow
    protectInstance(divider)
    local divGrad = Instance.new("UIGradient")
    divGrad.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.85), NumberSequenceKeypoint.new(0.5, 0), NumberSequenceKeypoint.new(1, 0.85) })
    divGrad.Parent = divider
    local bodyLayer = Instance.new("Frame")
    bodyLayer.Size=UDim2.new(1,0,1,0); bodyLayer.BackgroundTransparency=1
    bodyLayer.BorderSizePixel=0; bodyLayer.ClipsDescendants=false
    bodyLayer.Visible=false; bodyLayer.Parent=mainWindow
    protectInstance(bodyLayer)
    local navBar = Instance.new("Frame")
    navBar.Size=UDim2.new(1,-CONFIG.sizes.navPadX*2,0,CONFIG.sizes.navHeight)
    navBar.Position=UDim2.new(0,CONFIG.sizes.navPadX,0,CONFIG.sizes.headerHeight+12)
    navBar.BackgroundTransparency=1; navBar.Parent=bodyLayer
    protectInstance(navBar)
    local navLayout = Instance.new("UIListLayout")
    navLayout.FillDirection=Enum.FillDirection.Horizontal
    navLayout.HorizontalAlignment=Enum.HorizontalAlignment.Center
    navLayout.VerticalAlignment=Enum.VerticalAlignment.Center
    navLayout.Padding=UDim.new(0,CONFIG.sizes.navGap)
    navLayout.SortOrder=Enum.SortOrder.LayoutOrder
    navLayout.Parent=navBar
    local contentContainer = Instance.new("Frame")
    contentContainer.Size=UDim2.new(1,-CONFIG.sizes.contentPadX*2,1,-(CONFIG.sizes.headerHeight+CONFIG.sizes.navHeight+30))
    contentContainer.Position=UDim2.new(0,CONFIG.sizes.contentPadX,0,CONFIG.sizes.headerHeight+CONFIG.sizes.navHeight+20)
    contentContainer.BackgroundTransparency=1; contentContainer.Parent=bodyLayer
    protectInstance(contentContainer)
    local scroll = Instance.new("ScrollingFrame")
    scroll.Size=UDim2.new(1,0,1,0); scroll.BackgroundTransparency=1
    scroll.BorderSizePixel=0; scroll.ScrollBarThickness=4
    scroll.ScrollBarImageColor3=CONFIG.colors.accent; scroll.ScrollBarImageTransparency=0.3
    scroll.CanvasSize=UDim2.new(0,0,0,0); scroll.AutomaticCanvasSize=Enum.AutomaticSize.Y
    scroll.ClipsDescendants=true; scroll.Parent=contentContainer
    local contentLayout = Instance.new("UIListLayout")
    contentLayout.FillDirection=Enum.FillDirection.Vertical; contentLayout.Padding=UDim.new(0,CONFIG.sizes.cardGap)
    contentLayout.SortOrder=Enum.SortOrder.LayoutOrder; contentLayout.HorizontalAlignment=Enum.HorizontalAlignment.Center
    contentLayout.Parent=scroll
    local contentPad = Instance.new("UIPadding")
    contentPad.PaddingTop=UDim.new(0,6); contentPad.PaddingBottom=UDim.new(0,16)
    contentPad.PaddingLeft=UDim.new(0,CONFIG.sizes.scrollPadL); contentPad.PaddingRight=UDim.new(0,CONFIG.sizes.scrollPadR)
    contentPad.Parent=scroll

    local infoFrame = Instance.new("Frame")
    infoFrame.Name = "InfoFrame"
    infoFrame.Size=UDim2.new(1,-CONFIG.sizes.contentPadX*2,1,-(CONFIG.sizes.headerHeight+20))
    infoFrame.Position=UDim2.new(0,CONFIG.sizes.contentPadX,0,CONFIG.sizes.headerHeight+10)
    infoFrame.BackgroundColor3=CONFIG.colors.cardBg; infoFrame.BorderSizePixel=0
    infoFrame.Visible=false; infoFrame.BackgroundTransparency=1; infoFrame.Parent=bodyLayer
    corner(infoFrame, CONFIG.sizes.cardRadius)
    local infoStroke = stroke(infoFrame, CONFIG.colors.cardBorder, 1.5, 1)

    local aboutTitle = Instance.new("TextLabel")
    aboutTitle.BackgroundTransparency=1; aboutTitle.Text="About"
    aboutTitle.TextColor3=CONFIG.colors.accent; aboutTitle.Font=Enum.Font.GothamBold
    aboutTitle.TextSize=CONFIG.textSizes.aboutTitle; aboutTitle.TextXAlignment=Enum.TextXAlignment.Left
    aboutTitle.TextYAlignment=Enum.TextYAlignment.Center
    aboutTitle.Size=UDim2.new(1,-32,0,40); aboutTitle.Position=UDim2.new(0,18,0,20)
    aboutTitle.TextTransparency=1; aboutTitle.Parent=infoFrame

    local aboutDesc = Instance.new("TextLabel")
    aboutDesc.BackgroundTransparency=1
    aboutDesc.Text = "Babis | SURVIVE THE HULK — Free\n\nOne hub. Every core tool unlocked. Built for the ones who move first.\n\n• Auto Mission · Auto Punch · Auto Spin Ability (with selector)\n• Infinite Stamina · ESP suite complete · Anti-Ragdoll · Anti-Debris · Remove Doors\n• Live Event · Hulk Alert · Configs — save · load · overwrite · autoload\n\nPremium tools — Escape Button · Auto Escape · Kill Hulk · Kill Predict — are locked in this free edition.\nJoin the Discord to unlock the full toolkit. No key required."
    aboutDesc.TextColor3=CONFIG.colors.textPrimary; aboutDesc.Font=Enum.Font.Gotham
    aboutDesc.TextSize=CONFIG.textSizes.aboutDesc; aboutDesc.TextXAlignment=Enum.TextXAlignment.Left
    aboutDesc.TextYAlignment=Enum.TextYAlignment.Top; aboutDesc.TextWrapped=true
    aboutDesc.LineHeight=1.2; aboutDesc.Size=UDim2.new(1,-36,1,-160)
    aboutDesc.Position=UDim2.new(0,18,0,70); aboutDesc.TextTransparency=1
    aboutDesc.Parent=infoFrame

    local discordBtn = Instance.new("TextButton")
    discordBtn.Size=UDim2.new(1,-36,0,108); discordBtn.Position=UDim2.new(0,18,1,-128)
    discordBtn.BackgroundColor3=Color3.fromRGB(255,255,255); discordBtn.Text=""
    discordBtn.AutoButtonColor=false; discordBtn.BackgroundTransparency=1
    discordBtn.ClipsDescendants=true
    discordBtn.Parent=infoFrame; corner(discordBtn, 14)
    local dBtnGrad = Instance.new("Frame")
    dBtnGrad.Size=UDim2.new(1,0,1,0); dBtnGrad.BackgroundColor3=Color3.fromRGB(255,255,255)
    dBtnGrad.BorderSizePixel=0; dBtnGrad.ZIndex=1; dBtnGrad.Parent=discordBtn
    corner(dBtnGrad, 14)
    local dBtnGradFill = Instance.new("UIGradient")
    dBtnGradFill.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(88,101,242)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(22,24,45)) })
    dBtnGradFill.Parent = dBtnGrad
    local dBtnStroke = stroke(discordBtn, Color3.fromRGB(88,101,242), 1.5, 0.2)
    local dIcon = Instance.new("ImageLabel")
    dIcon.Size=UDim2.new(0,76,0,76); dIcon.Position=UDim2.new(0,16,0.5,-38)
    dIcon.BackgroundTransparency=1; dIcon.Image=CONFIG.discordIconId
    dIcon.ImageColor3=Color3.fromRGB(255,255,255); dIcon.ScaleType=Enum.ScaleType.Fit
    dIcon.ZIndex=2; dIcon.Parent=discordBtn
    local dTitle = Instance.new("TextLabel")
    dTitle.BackgroundTransparency=1; dTitle.Text="Discord"
    dTitle.TextColor3=Color3.fromRGB(255,255,255); dTitle.Font=Enum.Font.GothamBold
    dTitle.TextSize=CONFIG.textSizes.discordTitle; dTitle.TextXAlignment=Enum.TextXAlignment.Left
    dTitle.TextYAlignment=Enum.TextYAlignment.Center
    dTitle.Size=UDim2.new(1,-130,0,32); dTitle.Position=UDim2.new(0,108,0,22)
    dTitle.ZIndex=2; dTitle.Parent=discordBtn
    local dSub = Instance.new("TextLabel")
    dSub.BackgroundTransparency=1; dSub.Text="Tap to copy the invite"
    dSub.TextColor3=Color3.fromRGB(220,225,245); dSub.Font=Enum.Font.Gotham
    dSub.TextSize=CONFIG.textSizes.discordSub; dSub.TextXAlignment=Enum.TextXAlignment.Left
    dSub.TextYAlignment=Enum.TextYAlignment.Center
    dSub.Size=UDim2.new(1,-130,0,26); dSub.Position=UDim2.new(0,108,0,58)
    dSub.ZIndex=2; dSub.Parent=discordBtn

    local shine = Instance.new("Frame")
    shine.Name = "Shine"
    shine.Size = UDim2.new(0, 60, 1.6, 0)
    shine.Position = UDim2.new(0, -80, -0.3, 0)
    shine.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    shine.BackgroundTransparency = 0.55
    shine.BorderSizePixel = 0
    shine.Rotation = 18
    shine.ZIndex = 3
    shine.Visible = false
    shine.Parent = discordBtn
    local shineGrad = Instance.new("UIGradient")
    shineGrad.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 1),
        NumberSequenceKeypoint.new(0.5, 0),
        NumberSequenceKeypoint.new(1, 1),
    })
    shineGrad.Parent = shine

    discordBtn.MouseEnter:Connect(function()
        tween(dBtnGradFill, {Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(105,118,255)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(30,34,60)) })}, CONFIG.anim.fast)
    end)
    discordBtn.MouseLeave:Connect(function()
        tween(dBtnGradFill, {Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(88,101,242)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(22,24,45)) })}, CONFIG.anim.fast)
    end)

    local discordBusy = false
    discordBtn.Activated:Connect(function()
        if discordBusy then return end
        discordBusy = true
        local ok = pcall(function() setclipboard(CONFIG.discordInvite) end)
        tween(dBtnGradFill, {Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, CONFIG.colors.gold),
            ColorSequenceKeypoint.new(1, CONFIG.colors.goldDeep) })}, 0.15)
        tween(dBtnStroke, {Color = CONFIG.colors.gold}, 0.15)
        popTween(discordBtn, {Size = UDim2.new(1, -28, 0, 114)}, 0.18)
        task.delay(0.18, function()
            tween(discordBtn, {Size = UDim2.new(1, -36, 0, 108)}, 0.16)
        end)
        shine.Visible = true
        shine.Position = UDim2.new(0, -80, -0.3, 0)
        shine.BackgroundTransparency = 0.55
        tween(shine, {Position = UDim2.new(1, 80, -0.3, 0)}, 0.75, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        task.delay(0.75, function()
            shine.Visible = false
            shine.Position = UDim2.new(0, -80, -0.3, 0)
        end)
        local origIconSize = dIcon.Size
        popTween(dIcon, {Size = UDim2.new(0, 88, 0, 88), Position = UDim2.new(0, 10, 0.5, -44)}, 0.20)
        task.delay(0.20, function()
            tween(dIcon, {Size = origIconSize, Position = UDim2.new(0, 16, 0.5, -38)}, 0.18)
        end)
        local origTitle = dTitle.Text
        local origSub = dSub.Text
        if ok then
            dTitle.Text = "Copied!"
            dTitle.TextColor3 = CONFIG.colors.gold
            dSub.Text = CONFIG.discordInvite
            dSub.TextColor3 = CONFIG.colors.goldSoft
        else
            dTitle.Text = "Copy failed"
            dTitle.TextColor3 = CONFIG.colors.closeHover
            dSub.Text = "Manual: " .. CONFIG.discordInvite
            dSub.TextColor3 = CONFIG.colors.closeHover
        end
        task.delay(1.6, function()
            dTitle.Text = origTitle
            dTitle.TextColor3 = Color3.fromRGB(255,255,255)
            dSub.Text = origSub
            dSub.TextColor3 = Color3.fromRGB(220,225,245)
            tween(dBtnGradFill, {Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromRGB(88,101,242)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(22,24,45)) })}, 0.25)
            tween(dBtnStroke, {Color = Color3.fromRGB(88,101,242), Transparency = 0.2}, 0.25)
            discordBusy = false
        end)
        notify("Discord", ok and ("Invite copied: " .. CONFIG.discordInvite) or "Copy failed — copy manually from chat", "info")
    end)

    local function closeInfo()
        if not UI.infoOpen then return end
        UI.infoOpen = false
        tween(aboutTitle, {TextTransparency=1}, 0.18)
        tween(aboutDesc, {TextTransparency=1}, 0.18)
        tween(dTitle, {TextTransparency=1}, 0.18)
        tween(dSub, {TextTransparency=1}, 0.18)
        tween(dIcon, {ImageTransparency=1}, 0.18)
        tween(dBtnGrad, {BackgroundTransparency=1}, 0.18)
        tween(discordBtn, {BackgroundTransparency=1}, 0.18)
        tween(dBtnStroke, {Transparency=1}, 0.18)
        tween(infoFrame, {BackgroundTransparency=1}, 0.22)
        tween(infoStroke, {Transparency=1}, 0.22)
        task.delay(0.24, function()
            infoFrame.Visible = false
            if UI.isMinimized then
                safeWrite(navBar, "Visible", false)
                safeWrite(contentContainer, "Visible", false)
            else
                safeWrite(navBar, "Visible", true)
                safeWrite(contentContainer, "Visible", true)
            end
            tween(infoIcon, {ImageColor3=CONFIG.colors.navIcon}, CONFIG.anim.fast)
        end)
    end

    local function openInfo()
        if UI.infoOpen then closeInfo() return end
        if UI.isMinimized then
            UI.isMinimized = false
            safeWrite(bodyLayer, "Visible", true)
            local s = uiScale.Scale or 1
            local w, h = CONFIG.sizes.windowWidth * s, CONFIG.sizes.windowHeight * s
            local cx, cy = currentCenterPixels()
            local tcx, tcy = clampCenter(cx, cy, w, h)
            local target = UDim2.new(0, tcx, 0, tcy)
            UI.savedPos = target
            TweenService:Create(scaleWrapper, TweenInfo.new(CONFIG.anim.slow, CONFIG.anim.easing, CONFIG.anim.dir), {
                Size = UDim2.new(0, CONFIG.sizes.windowWidth, 0, CONFIG.sizes.windowHeight),
                Position = target,
            }):Play()
        end
        UI.infoOpen = true
        infoFrame.Visible = true
        infoFrame.BackgroundTransparency = 1
        infoStroke.Transparency = 1
        aboutTitle.TextTransparency = 1
        aboutDesc.TextTransparency = 1
        dTitle.TextTransparency = 1
        dSub.TextTransparency = 1
        dIcon.ImageTransparency = 1
        dBtnGrad.BackgroundTransparency = 1
        discordBtn.BackgroundTransparency = 1
        dBtnStroke.Transparency = 1
        safeWrite(navBar, "Visible", false)
        safeWrite(contentContainer, "Visible", false)
        tween(infoFrame, {BackgroundTransparency=0}, 0.28)
        tween(infoStroke, {Transparency=0}, 0.28)
        tween(aboutTitle, {TextTransparency=0}, 0.30)
        tween(aboutDesc, {TextTransparency=0}, 0.36)
        task.delay(0.10, function()
            tween(dBtnGrad, {BackgroundTransparency=0}, 0.28)
            tween(discordBtn, {BackgroundTransparency=0}, 0.28)
            tween(dBtnStroke, {Transparency=0.2}, 0.28)
            tween(dIcon, {ImageTransparency=0}, 0.30)
            tween(dTitle, {TextTransparency=0}, 0.30)
            tween(dSub, {TextTransparency=0}, 0.32)
        end)
        tween(infoIcon, {ImageColor3=CONFIG.colors.navIconActive}, CONFIG.anim.fast)
    end
    infoBtn.Activated:Connect(openInfo)
    infoBtn.MouseEnter:Connect(function()
        if not UI.infoOpen then tween(infoIcon, {ImageColor3=CONFIG.colors.accentSoft}, CONFIG.anim.fast) end
    end)
    infoBtn.MouseLeave:Connect(function()
        if not UI.infoOpen then tween(infoIcon, {ImageColor3=CONFIG.colors.navIcon}, CONFIG.anim.fast) end
    end)

    local tabButtons = {}
    local function createTabButton(tabData, order)
        local btn = Instance.new("TextButton")
        btn.Size=UDim2.new(0,CONFIG.sizes.navBtnSize,0,CONFIG.sizes.navBtnSize)
        btn.BackgroundColor3=CONFIG.colors.navBg; btn.Text=""; btn.AutoButtonColor=false
        btn.ClipsDescendants=false; btn.LayoutOrder=order; btn.Parent=navBar
        corner(btn, CONFIG.sizes.navBtnRadius)
        local btnStroke = stroke(btn, CONFIG.colors.navBorder, 2, 0)
        local baseSize = CONFIG.sizes.iconSize + (tabData.boost or 0)
        local iconGlow = Instance.new("ImageLabel")
        iconGlow.Size=UDim2.new(0,baseSize+8,0,baseSize+8)
        iconGlow.Position=UDim2.new(0.5,-(baseSize+8)/2,0.5,-(baseSize+8)/2)
        iconGlow.BackgroundTransparency=1; iconGlow.Image="rbxassetid://"..tabData.iconId
        iconGlow.ImageColor3=CONFIG.colors.navIcon; iconGlow.ImageTransparency=0.85
        iconGlow.ScaleType=Enum.ScaleType.Fit; iconGlow.ZIndex=2; iconGlow.Parent=btn
        local icon = Instance.new("ImageLabel")
        icon.Size=UDim2.new(0,baseSize,0,baseSize)
        icon.Position=UDim2.new(0.5,-baseSize/2,0.5,-baseSize/2)
        icon.BackgroundTransparency=1; icon.Image="rbxassetid://"..tabData.iconId
        icon.ImageColor3=CONFIG.colors.navIcon; icon.ScaleType=Enum.ScaleType.Fit
        icon.ZIndex=2; icon.Parent=btn
        local hit = Instance.new("TextButton")
        hit.Size=UDim2.new(1,0,1,1); hit.BackgroundTransparency=1; hit.Text=""
        hit.AutoButtonColor=false; hit.ZIndex=3; hit.Parent=btn
        return { button=btn, stroke=btnStroke, icon=icon, iconGlow=iconGlow, hit=hit, id=tabData.id, baseSize=baseSize }
    end
    for i, tab in ipairs(CONFIG.tabs) do tabButtons[tab.id] = createTabButton(tab, i) end

    local function createCard(order, height, locked)
        local card = Instance.new("Frame")
        card.Size=UDim2.new(1,0,0,height or 128)
        card.BackgroundColor3 = locked and CONFIG.colors.lockedCard or CONFIG.colors.cardBg
        card.BorderSizePixel=0; card.LayoutOrder=order; card.Parent=scroll
        corner(card, CONFIG.sizes.cardRadius)
        local cardStroke = stroke(card, locked and CONFIG.colors.lockedBorder or CONFIG.colors.cardBorder, 1.5, 0)
        local title = Instance.new("TextLabel")
        title.BackgroundTransparency=1
        title.TextColor3 = locked and CONFIG.colors.lockedText or CONFIG.colors.textPrimary
        title.Font=Enum.Font.GothamBold; title.TextSize=CONFIG.textSizes.cardTitle
        title.TextXAlignment=Enum.TextXAlignment.Left; title.TextYAlignment=Enum.TextYAlignment.Top
        title.TextWrapped = true
        title.Size=UDim2.new(1,-170,0,34); title.Position=UDim2.new(0,CONFIG.sizes.cardPadX,0,22)
        title.Parent=card
        local desc = Instance.new("TextLabel")
        desc.BackgroundTransparency=1
        desc.TextColor3 = locked and CONFIG.colors.lockedText or CONFIG.colors.textDesc
        desc.Font=Enum.Font.Gotham; desc.TextSize=CONFIG.textSizes.cardDesc
        desc.TextXAlignment=Enum.TextXAlignment.Left; desc.TextYAlignment=Enum.TextYAlignment.Top
        desc.TextWrapped = true; desc.LineHeight = 1.15
        desc.Size=UDim2.new(1,-170,0,60); desc.Position=UDim2.new(0,CONFIG.sizes.cardPadX,0,62)
        desc.Parent=card
        if locked then
            local tag = Instance.new("TextLabel")
            tag.BackgroundTransparency=1; tag.Text="PREMIUM"
            tag.TextColor3=CONFIG.colors.premium; tag.Font=Enum.Font.GothamBold
            tag.TextSize=11; tag.TextXAlignment=Enum.TextXAlignment.Right
            tag.TextYAlignment=Enum.TextYAlignment.Top
            tag.Size=UDim2.new(0,90,0,20); tag.Position=UDim2.new(1,-100,0,26)
            tag.Parent=card
        end
        return card, title, desc, cardStroke
    end

    local function createToggleCard(order, titleText, descText, key, default, onChange, locked)
        local card, title, desc = createCard(order, CONFIG.sizes.toggleCardHeight, locked)
        title.Text=titleText; desc.Text=descText
        if UI.options[key] == nil then UI.options[key] = default and true or false end
        local tW = CONFIG.sizes.toggleW; local tH = CONFIG.sizes.toggleH
        local knob = CONFIG.sizes.toggleKnob; local pad = (tH - knob)/2
        local right = CONFIG.sizes.toggleRight
        local track2 = Instance.new("Frame")
        track2.Size=UDim2.new(0,tW,0,tH); track2.Position=UDim2.new(1,-(tW+right),0,26)
        track2.BackgroundColor3 = locked and Color3.fromRGB(28,28,32) or CONFIG.colors.toggleOff
        track2.BorderSizePixel=0
        track2.Parent=card; corner(track2, tH/2)
        local trackStroke = stroke(track2, locked and CONFIG.colors.lockedBorder or CONFIG.colors.cardBorder, 1.5, 0)
        local knobFrame = Instance.new("Frame")
        knobFrame.Size=UDim2.new(0,knob,0,knob); knobFrame.Position=UDim2.new(0,pad,0.5,-knob/2)
        knobFrame.BackgroundColor3 = locked and Color3.fromRGB(70,70,78) or CONFIG.colors.textPrimary
        knobFrame.BorderSizePixel=0
        knobFrame.Parent=track2; corner(knobFrame, knob/2)
        if locked then
            local lock = Instance.new("ImageLabel")
            lock.Size = UDim2.new(0, 20, 0, 20)
            lock.Position = UDim2.new(0.5, -10, 0.5, -10)
            lock.BackgroundTransparency = 1
            lock.Image = CONFIG.lockIconId
            lock.ImageColor3 = CONFIG.colors.premium
            lock.ScaleType = Enum.ScaleType.Fit
            lock.ZIndex = 5
            lock.Parent = track2
        end
        local hit = Instance.new("TextButton")
        hit.Size=UDim2.new(1,0,1,0); hit.BackgroundTransparency=1; hit.Text=""
        hit.AutoButtonColor=false; hit.ZIndex=10; hit.Parent=card
        local offX, onX = pad, tW - knob - pad
        local function render(animate)
            if locked then return end
            local dur = animate and CONFIG.anim.normal or 0
            if UI.options[key] then
                tween(track2, {BackgroundColor3=CONFIG.colors.toggleOn}, dur)
                tween(trackStroke, {Color=CONFIG.colors.toggleOn}, dur)
                tween(knobFrame, {Position=UDim2.new(0,onX,0.5,-knob/2)}, dur)
            else
                tween(track2, {BackgroundColor3=CONFIG.colors.toggleOff}, dur)
                tween(trackStroke, {Color=CONFIG.colors.cardBorder}, dur)
                tween(knobFrame, {Position=UDim2.new(0,offX,0.5,-knob/2)}, dur)
            end
        end
        render(false)
        track(hit.Activated:Connect(function()
            if locked then
                notify(titleText, "Premium only! Join Discord to unlock.", "premium", 3)
                return
            end
            UI.options[key] = not UI.options[key]
            render(true)
            if onChange then onChange(UI.options[key], titleText) end
            notify(titleText, UI.options[key] and "Enabled" or "Disabled", "info")
        end))
        return card
    end

    local function createButtonCard(order, titleText, descText, onClick, locked)
        local card, title, desc, cardStroke = createCard(order, nil, locked)
        title.Text=titleText; desc.Text=descText
        local iconSize = CONFIG.sizes.handIconSize
        local iconY    = CONFIG.sizes.handIconY
        local right    = CONFIG.sizes.controlRight
        local hand = Instance.new("ImageLabel")
        hand.Size=UDim2.new(0,iconSize,0,iconSize); hand.Position=UDim2.new(1,-(iconSize+right),0,iconY)
        hand.BackgroundTransparency=1
        hand.Image = locked and CONFIG.lockIconId or CONFIG.handIconId
        hand.ImageColor3 = locked and CONFIG.colors.premium or CONFIG.colors.handIdle
        hand.ScaleType=Enum.ScaleType.Fit
        hand.Parent=card
        local flash = Instance.new("Frame")
        flash.Size=UDim2.new(1,0,1,0); flash.BackgroundColor3=CONFIG.colors.accent
        flash.BackgroundTransparency=1; flash.BorderSizePixel=0; flash.ZIndex=3
        flash.Parent=card; corner(flash, CONFIG.sizes.cardRadius)
        local hit = Instance.new("TextButton")
        hit.Size=UDim2.new(1,0,1,0); hit.BackgroundTransparency=1; hit.Text=""
        hit.AutoButtonColor=false; hit.ZIndex=5; hit.Parent=card
        if locked then
            track(hit.MouseEnter:Connect(function()
                tween(card, {BackgroundColor3=Color3.fromRGB(20,18,14)}, CONFIG.anim.fast)
                tween(cardStroke, {Color=CONFIG.colors.premium, Transparency=0.4}, CONFIG.anim.fast)
                tween(hand, {ImageColor3=CONFIG.colors.goldSoft}, CONFIG.anim.fast)
            end))
            track(hit.MouseLeave:Connect(function()
                tween(card, {BackgroundColor3=CONFIG.colors.lockedCard}, CONFIG.anim.fast)
                tween(cardStroke, {Color=CONFIG.colors.lockedBorder}, CONFIG.anim.fast)
                tween(hand, {ImageColor3=CONFIG.colors.premium}, CONFIG.anim.fast)
            end))
            track(hit.Activated:Connect(function()
                notify(titleText, "Premium only! Join Discord to unlock.", "premium", 3)
                popTween(hand, {Size = UDim2.new(0, iconSize+6, 0, iconSize+6),
                    Position = UDim2.new(1, -(iconSize+6+right), 0, iconY-3)}, 0.20)
                task.delay(0.20, function()
                    tween(hand, {Size = UDim2.new(0, iconSize, 0, iconSize),
                        Position = UDim2.new(1, -(iconSize+right), 0, iconY)}, 0.18)
                end)
            end))
            return card
        end
        track(hit.MouseEnter:Connect(function()
            tween(card, {BackgroundColor3=CONFIG.colors.navBg}, CONFIG.anim.fast)
            tween(cardStroke, {Color=CONFIG.colors.accent}, CONFIG.anim.fast)
            tween(hand, {ImageColor3=CONFIG.colors.handHover}, CONFIG.anim.fast)
        end))
        track(hit.MouseLeave:Connect(function()
            tween(card, {BackgroundColor3=CONFIG.colors.cardBg}, CONFIG.anim.fast)
            tween(cardStroke, {Color=CONFIG.colors.cardBorder}, CONFIG.anim.fast)
            tween(hand, {ImageColor3=CONFIG.colors.handIdle}, CONFIG.anim.fast)
        end))
        local playing = false
        track(hit.Activated:Connect(function()
            if playing then return end
            playing = true
            local baseSize = card.Size
            tween(card, {Size=UDim2.new(baseSize.X.Scale, baseSize.X.Offset-6, baseSize.Y.Scale, baseSize.Y.Offset-6)}, 0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
            flash.BackgroundTransparency = 0.85
            tween(flash, {BackgroundTransparency=1}, 0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
            local origSize, origPos = hand.Size, hand.Position
            local pop = iconSize - 8
            tween(hand, {Size=UDim2.new(0,pop,0,pop), Position=UDim2.new(1,-(pop+right)-3,0,iconY+3), Rotation=12}, 0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
            task.delay(0.08, function()
                popTween(hand, {Size=UDim2.new(0,iconSize+6,0,iconSize+6), Position=UDim2.new(1,-(iconSize+6+right)+3,0,iconY-3), Rotation=-6}, 0.18)
                task.delay(0.18, function() tween(hand, {Size=origSize, Position=origPos, Rotation=0}, 0.14) end)
            end)
            task.delay(0.08, function()
                popTween(card, {Size=UDim2.new(baseSize.X.Scale, baseSize.X.Offset+4, baseSize.Y.Scale, baseSize.Y.Offset+4)}, 0.16)
                task.delay(0.16, function() tween(card, {Size=baseSize}, 0.14) end)
            end)
            notify(titleText, "Triggered", "info")
            if onClick then onClick() end
            task.delay(0.4, function() playing = false end)
        end))
        return card
    end

    local function createSliderCard(order, titleText, descText, key, minVal, maxVal, default, onChange, isDecimal, locked)
        local card, title, desc = createCard(order, CONFIG.sizes.sliderCardHeight, locked)
        title.Text = titleText; desc.Text = descText
        if UI.options[key] == nil then UI.options[key] = default or minVal end
        local isDec = isDecimal == true
        local currentVal = UI.options[key]

        if locked then
            local boxW, boxH, right = CONFIG.sizes.controlW, CONFIG.sizes.controlH, CONFIG.sizes.controlRight
            local box = Instance.new("Frame")
            box.Size = UDim2.new(0, boxW, 0, boxH)
            box.Position = UDim2.new(1, -(boxW + right), 0, 22)
            box.BackgroundColor3 = Color3.fromRGB(28,28,32)
            box.BorderSizePixel = 0; box.Parent = card
            corner(box, 10); stroke(box, CONFIG.colors.lockedBorder, 1.5, 0)
            local boxLbl = Instance.new("TextLabel")
            boxLbl.Size = UDim2.new(1,0,1,0); boxLbl.BackgroundTransparency = 1
            boxLbl.Text = "—"; boxLbl.TextColor3 = CONFIG.colors.lockedText
            boxLbl.Font = Enum.Font.GothamBold; boxLbl.TextSize = 20
            boxLbl.Parent = box
            local barBg = Instance.new("Frame")
            barBg.Size = UDim2.new(0, 300, 0, 10)
            barBg.Position = UDim2.new(0, 24, 1, -46)
            barBg.BackgroundColor3 = Color3.fromRGB(28,28,32)
            barBg.BorderSizePixel = 0; barBg.Parent = card
            corner(barBg, 5)
            local lock = Instance.new("ImageLabel")
            lock.Size = UDim2.new(0, 82, 0, 82)
            lock.Position = UDim2.new(1, -(82 + right), 0, 20)
            lock.BackgroundTransparency = 1
            lock.Image = CONFIG.lockIconId
            lock.ImageColor3 = CONFIG.colors.premium
            lock.ScaleType = Enum.ScaleType.Fit
            lock.Parent = card
            local hit = Instance.new("TextButton")
            hit.Size = UDim2.new(1,0,1,0); hit.BackgroundTransparency = 1
            hit.Text = ""; hit.AutoButtonColor = false; hit.ZIndex = 20
            hit.Parent = card
            track(hit.MouseEnter:Connect(function()
                tween(card, {BackgroundColor3=Color3.fromRGB(20,18,14)}, CONFIG.anim.fast)
            end))
            track(hit.MouseLeave:Connect(function()
                tween(card, {BackgroundColor3=CONFIG.colors.lockedCard}, CONFIG.anim.fast)
            end))
            track(hit.Activated:Connect(function()
                notify(titleText, "Premium only! Join Discord to unlock.", "premium", 3)
                popTween(lock, {Size = UDim2.new(0, 90, 0, 90),
                    Position = UDim2.new(1, -(90 + right), 0, 16)}, 0.20)
                task.delay(0.20, function()
                    tween(lock, {Size = UDim2.new(0, 82, 0, 82),
                        Position = UDim2.new(1, -(82 + right), 0, 20)}, 0.18)
                end)
            end))
            return card, nil
        end

        local boxW, boxH, right = CONFIG.sizes.controlW, CONFIG.sizes.controlH, CONFIG.sizes.controlRight
        local textBox = Instance.new("TextBox")
        textBox.Size = UDim2.new(0, boxW, 0, boxH)
        textBox.Position = UDim2.new(1, -(boxW + right), 0, 22)
        textBox.BackgroundColor3 = CONFIG.colors.navBg
        textBox.Text = tostring(currentVal)
        textBox.PlaceholderText = "0"; textBox.PlaceholderColor3 = CONFIG.colors.textMuted
        textBox.TextColor3 = CONFIG.colors.textPrimary; textBox.Font = Enum.Font.GothamBold
        textBox.TextSize = 20; textBox.TextXAlignment = Enum.TextXAlignment.Center
        textBox.ClearTextOnFocus = false; textBox.ZIndex = 20; textBox.Parent = card
        corner(textBox, 10)
        local boxStroke = stroke(textBox, CONFIG.colors.cardBorder, 1.5, 0)
        local barW, barH = 300, 10
        local barBg = Instance.new("Frame")
        barBg.Size = UDim2.new(0, barW, 0, barH)
        barBg.Position = UDim2.new(0, 24, 1, -46)
        barBg.BackgroundColor3 = CONFIG.colors.toggleOff; barBg.BorderSizePixel = 0
        barBg.Parent = card; corner(barBg, barH/2)
        local fill = Instance.new("Frame")
        fill.Size = UDim2.new(0, 0, 1, 0); fill.BackgroundColor3 = CONFIG.colors.accent
        fill.BorderSizePixel = 0; fill.Parent = barBg; corner(fill, barH/2)
        local knob = Instance.new("Frame")
        knob.Size = UDim2.new(0, 26, 0, 26); knob.Position = UDim2.new(0, -13, 0.5, -13)
        knob.BackgroundColor3 = CONFIG.colors.textPrimary; knob.BorderSizePixel = 0
        knob.ZIndex = 5; knob.Parent = barBg; corner(knob, 13)
        stroke(knob, CONFIG.colors.accent, 2, 0)
        local valueLbl = Instance.new("TextLabel")
        valueLbl.BackgroundTransparency = 1; valueLbl.Text = tostring(currentVal)
        valueLbl.TextColor3 = CONFIG.colors.accent; valueLbl.Font = Enum.Font.GothamBold
        valueLbl.TextSize = 18; valueLbl.TextXAlignment = Enum.TextXAlignment.Right
        valueLbl.TextYAlignment = Enum.TextYAlignment.Center
        valueLbl.Size = UDim2.new(0, 80, 0, 26); valueLbl.Position = UDim2.new(1, -104, 1, -50)
        valueLbl.Parent = card
        local function roundVal(v)
            if isDec then return math.floor(v * 10 + 0.5) / 10 end
            return math.floor(v + 0.5)
        end
        local function setFromX(absX)
            local barAbs = barBg.AbsolutePosition.X
            local barSize = barBg.AbsoluteSize.X
            local rel = math.clamp((absX - barAbs) / barSize, 0, 1)
            local raw = minVal + (maxVal - minVal) * rel
            local val = roundVal(raw)
            UI.options[key] = val; currentVal = val
            textBox.Text = tostring(val); valueLbl.Text = tostring(val)
            tween(fill, {Size = UDim2.new(rel, 0, 1, 0)}, 0.05, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
            tween(knob, {Position = UDim2.new(rel, -13, 0.5, -13)}, 0.05, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
        end
        local initialRel = (currentVal - minVal) / (maxVal - minVal)
        fill.Size = UDim2.new(initialRel, 0, 1, 0)
        knob.Position = UDim2.new(initialRel, -13, 0.5, -13)
        local dragging = false
        local hit = Instance.new("TextButton")
        hit.Size = UDim2.new(1, 0, 0, 56)
        hit.Position = UDim2.new(0, 0, 1, -56)
        hit.BackgroundTransparency = 1; hit.Text = ""; hit.AutoButtonColor = false
        hit.ZIndex = 5; hit.Parent = card
        track(hit.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true; setFromX(input.Position.X)
            end
        end))
        track(UserInputService.InputChanged:Connect(function(input)
            if not dragging then return end
            if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
                setFromX(input.Position.X)
            end
        end))
        track(UserInputService.InputEnded:Connect(function(input)
            if not dragging then return end
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = false
                if onChange then onChange(UI.options[key], titleText) end
                notify(titleText, "Set to " .. tostring(UI.options[key]), "info")
            end
        end))
        track(textBox:GetPropertyChangedSignal("Text"):Connect(function()
            local filtered
            if isDec then
                filtered = textBox.Text:gsub("[^%d%.%-]", "")
                local minus = filtered:find("%-"); if minus and minus > 1 then filtered = filtered:gsub("%-", "") end
                local firstDot = filtered:find("%.", 2)
                if firstDot then
                    local head = filtered:sub(1, firstDot)
                    local tail = filtered:sub(firstDot + 1):gsub("%.", "")
                    filtered = head .. tail
                end
            else
                filtered = textBox.Text:gsub("[^%d%-]", "")
                local minus = filtered:find("%-"); if minus and minus > 1 then filtered = filtered:gsub("%-", "") end
            end
            if filtered ~= textBox.Text then textBox.Text = filtered end
            local n = tonumber(filtered); if n == nil then return end
            n = math.clamp(n, minVal, maxVal)
            UI.options[key] = n; currentVal = n
            valueLbl.Text = tostring(n)
            local rel = (n - minVal) / (maxVal - minVal)
            tween(fill, {Size = UDim2.new(rel, 0, 1, 0)}, 0.05, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
            tween(knob, {Position = UDim2.new(rel, -13, 0.5, -13)}, 0.05, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
        end))
        track(textBox.Focused:Connect(function() tween(boxStroke, {Color = CONFIG.colors.accent}, CONFIG.anim.fast) end))
        track(textBox.FocusLost:Connect(function()
            tween(boxStroke, {Color = CONFIG.colors.cardBorder}, CONFIG.anim.fast)
            if onChange then onChange(UI.options[key], titleText) end
            notify(titleText, "Set to " .. tostring(UI.options[key]), "info")
        end))
        return card, textBox
    end

    local function smallButton(parent, y, text, onClick)
        local btn = Instance.new("TextButton")
        btn.Size=UDim2.new(1,-28,0,34); btn.Position=UDim2.new(0,14,0,y)
        btn.BackgroundColor3=CONFIG.colors.cfgBtnBg; btn.Text=text
        btn.TextColor3=CONFIG.colors.textPrimary; btn.Font=Enum.Font.GothamBold
        btn.TextSize=CONFIG.textSizes.cfgBtn; btn.AutoButtonColor=false
        btn.Parent=parent; corner(btn, 8)
        local s = stroke(btn, CONFIG.colors.cfgBtnBorder, 1.2, 0)
        btn.MouseEnter:Connect(function()
            tween(btn, {BackgroundColor3=CONFIG.colors.navBg}, CONFIG.anim.fast)
            tween(s, {Color=CONFIG.colors.accent}, CONFIG.anim.fast)
        end)
        btn.MouseLeave:Connect(function()
            tween(btn, {BackgroundColor3=CONFIG.colors.cfgBtnBg}, CONFIG.anim.fast)
            tween(s, {Color=CONFIG.colors.cfgBtnBorder}, CONFIG.anim.fast)
        end)
        btn.Activated:Connect(function() if onClick then onClick() end end)
        return btn
    end
    local function smallLabel(parent, y, text)
        local lbl = Instance.new("TextLabel")
        lbl.Size=UDim2.new(1,-28,0,22); lbl.Position=UDim2.new(0,14,0,y)
        lbl.BackgroundTransparency=1; lbl.Text=text
        lbl.TextColor3=CONFIG.colors.textPrimary; lbl.Font=Enum.Font.GothamBold
        lbl.TextSize=CONFIG.textSizes.cfgLabel; lbl.TextXAlignment=Enum.TextXAlignment.Left
        lbl.Parent=parent
        return lbl
    end

    local function buildKeybindCard()
        local card = Instance.new("Frame")
        card.Size=UDim2.new(1,0,0,110); card.BackgroundColor3=CONFIG.colors.cardBg
        card.BorderSizePixel=0; card.LayoutOrder=0; card.Parent=scroll
        corner(card, CONFIG.sizes.cardRadius); stroke(card, CONFIG.colors.cardBorder, 1.5, 0)
        local title = Instance.new("TextLabel")
        title.BackgroundTransparency=1; title.Text="Toggle Keybind"
        title.TextColor3=CONFIG.colors.textPrimary; title.Font=Enum.Font.GothamBold
        title.TextSize=24; title.TextXAlignment=Enum.TextXAlignment.Left
        title.TextYAlignment=Enum.TextYAlignment.Top
        title.Size=UDim2.new(1,-160,0,28); title.Position=UDim2.new(0,16,0,24)
        title.Parent=card
        local desc = Instance.new("TextLabel")
        desc.BackgroundTransparency=1; desc.Text="Key to open/close the interface"
        desc.TextColor3=CONFIG.colors.textDesc; desc.Font=Enum.Font.Gotham
        desc.TextSize=15; desc.TextXAlignment=Enum.TextXAlignment.Left
        desc.TextYAlignment=Enum.TextYAlignment.Top
        desc.Size=UDim2.new(1,-160,0,22); desc.Position=UDim2.new(0,16,0,60)
        desc.Parent=card
        local keyBtn = Instance.new("TextButton")
        keyBtn.Size=UDim2.new(0,130,0,46); keyBtn.Position=UDim2.new(1,-146,0.5,-23)
        keyBtn.BackgroundColor3=CONFIG.colors.navBg; keyBtn.Text=UI.options["toggle_key"] or "None"
        keyBtn.TextColor3=CONFIG.colors.textPrimary; keyBtn.Font=Enum.Font.GothamBold
        keyBtn.TextSize=18; keyBtn.AutoButtonColor=false; keyBtn.Parent=card
        corner(keyBtn, 10); local keyStroke = stroke(keyBtn, CONFIG.colors.cardBorder, 1.5, 0)
        local listenConn = nil
        local listening = false
        local function stopListening()
            listening = false
            if listenConn then pcall(function() listenConn:Disconnect() end) end
            listenConn = nil
            keyBtn.Text = UI.options["toggle_key"] or "None"
            tween(keyStroke, {Color=CONFIG.colors.cardBorder}, CONFIG.anim.fast)
        end
        keyBtn.Activated:Connect(function()
            if listening then return end
            listening = true
            keyBtn.Text = "Press a key..."
            tween(keyStroke, {Color=CONFIG.colors.accent}, CONFIG.anim.fast)
            listenConn = UserInputService.InputBegan:Connect(function(input, gpe)
                if gpe then return end
                if input.UserInputType ~= Enum.UserInputType.Keyboard then return end
                UI.options["toggle_key"] = input.KeyCode.Name
                stopListening()
                notify("Keybind", "Set to " .. input.KeyCode.Name, "info")
            end)
        end)
    end

    local function buildConfigCard()
        local card = Instance.new("Frame")
        card.Size=UDim2.new(1,0,0,CONFIG.sizes.cfgHeight); card.BackgroundColor3=CONFIG.colors.cardBg
        card.BorderSizePixel=0; card.LayoutOrder=1; card.Parent=scroll
        corner(card, CONFIG.sizes.cardRadius); stroke(card, CONFIG.colors.cardBorder, 1.5, 0)
        local icon = Instance.new("ImageLabel")
        icon.Size=UDim2.new(0,26,0,26); icon.Position=UDim2.new(0,14,0,14)
        icon.BackgroundTransparency=1; icon.Image=CONFIG.cfgIconId
        icon.ImageColor3=CONFIG.colors.cfgIcon; icon.ScaleType=Enum.ScaleType.Fit
        icon.Parent=card
        local headerLbl = Instance.new("TextLabel")
        headerLbl.Size=UDim2.new(1,-60,0,26); headerLbl.Position=UDim2.new(0,48,0,16)
        headerLbl.BackgroundTransparency=1; headerLbl.Text="Configuration"
        headerLbl.TextColor3=CONFIG.colors.textPrimary; headerLbl.Font=Enum.Font.GothamBold
        headerLbl.TextSize=CONFIG.textSizes.cfgTitle; headerLbl.TextXAlignment=Enum.TextXAlignment.Left
        headerLbl.Parent=card
        smallLabel(card, 54, "Config name")
        local nameBox = Instance.new("TextBox")
        nameBox.Size=UDim2.new(1,-28,0,38); nameBox.Position=UDim2.new(0,14,0,78)
        nameBox.BackgroundColor3=CONFIG.colors.cfgBtnBg; nameBox.Text=""
        nameBox.PlaceholderText="type a name..."; nameBox.PlaceholderColor3=CONFIG.colors.textMuted
        nameBox.TextColor3=CONFIG.colors.textPrimary; nameBox.Font=Enum.Font.GothamBold
        nameBox.TextSize=CONFIG.textSizes.cfgInput; nameBox.TextXAlignment=Enum.TextXAlignment.Left
        nameBox.ClearTextOnFocus=false; nameBox.Parent=card
        corner(nameBox, 8); local nameStroke = stroke(nameBox, CONFIG.colors.cfgBtnBorder, 1.2, 0)
        local padLeft = Instance.new("UIPadding"); padLeft.PaddingLeft=UDim.new(0,12); padLeft.Parent=nameBox
        nameBox.Focused:Connect(function() tween(nameStroke, {Color=CONFIG.colors.accent}, CONFIG.anim.fast) end)
        nameBox.FocusLost:Connect(function() tween(nameStroke, {Color=CONFIG.colors.cfgBtnBorder}, CONFIG.anim.fast) end)
        smallButton(card, 126, "Create config", function()
            local name = nameBox.Text
            if name == "" then notify("Config", "Enter a name first", "info") return end
            local ok, err = ConfigSys.save(name, UI.options)
            if ok then
                notify("Config", "\"" .. name .. "\" created", "info")
                nameBox.Text = ""
                if UI.refreshCfgList then UI.refreshCfgList() end
            else
                notify("Config", "Failed: " .. tostring(err), "info")
            end
        end)
        smallLabel(card, 176, "Config list")
        local ddBtn = Instance.new("TextButton")
        ddBtn.Size=UDim2.new(1,-28,0,38); ddBtn.Position=UDim2.new(0,14,0,200)
        ddBtn.BackgroundColor3=CONFIG.colors.cfgBtnBg
        ddBtn.Text = UI.cfgSelected or "---"
        ddBtn.TextColor3=CONFIG.colors.textPrimary; ddBtn.Font=Enum.Font.GothamBold
        ddBtn.TextSize=CONFIG.textSizes.cfgInput; ddBtn.TextXAlignment=Enum.TextXAlignment.Left
        ddBtn.AutoButtonColor=false; ddBtn.Parent=card
        corner(ddBtn, 8); local ddStroke = stroke(ddBtn, CONFIG.colors.cfgBtnBorder, 1.2, 0)
        local ddPad = Instance.new("UIPadding"); ddPad.PaddingLeft=UDim.new(0,12); ddPad.Parent=ddBtn
        local arrow = Instance.new("TextLabel")
        arrow.Size=UDim2.new(0,24,0,38); arrow.Position=UDim2.new(1,-30,0,0)
        arrow.BackgroundTransparency=1; arrow.Text="^"
        arrow.TextColor3=CONFIG.colors.textDesc; arrow.Font=Enum.Font.GothamBold
        arrow.TextSize=16; arrow.Rotation=180; arrow.Parent=ddBtn
        local ddListOpen = false
        local ddBackdrop, ddList = nil, nil
        local function closeDd()
            if not ddListOpen then return end
            ddListOpen = false
            if ddBackdrop and ddBackdrop.Parent then ddBackdrop:Destroy() end
            if ddList and ddList.Parent then ddList:Destroy() end
            ddBackdrop, ddList = nil, nil
            tween(ddStroke, {Color=CONFIG.colors.cfgBtnBorder}, CONFIG.anim.fast)
            tween(arrow, {Rotation=180}, CONFIG.anim.fast)
        end
        local function openDd()
            if ddListOpen then closeDd() return end
            ddListOpen = true
            ddBackdrop = Instance.new("TextButton")
            ddBackdrop.Size=UDim2.new(1,0,1,0); ddBackdrop.BackgroundTransparency=1
            ddBackdrop.Text=""; ddBackdrop.AutoButtonColor=false; ddBackdrop.ZIndex=60
            ddBackdrop.Parent=scaleWrapper
            ddBackdrop.Activated:Connect(closeDd)
            local list = ConfigSys.list()
            UI.cfgList = list
            if #list == 0 then
                notify("Config", "No configs found", "info")
                closeDd()
                return
            end
            local btnAbs = ddBtn.AbsolutePosition
            local wrapAbs = scaleWrapper.AbsolutePosition
            local s = uiScale.Scale
            local relX = (btnAbs.X - wrapAbs.X) / s
            local relW = ddBtn.AbsoluteSize.X / s
            local btnTopY = (btnAbs.Y - wrapAbs.Y) / s
            local itemH = 34
            local listH = #list * itemH + 8
            local relY = btnTopY - listH - 6
            ddList = Instance.new("Frame")
            ddList.Size=UDim2.new(0, relW, 0, listH)
            ddList.Position=UDim2.new(0, relX, 0, relY)
            ddList.BackgroundColor3=CONFIG.colors.cardBg; ddList.BorderSizePixel=0
            ddList.ZIndex=61; ddList.Parent=scaleWrapper
            corner(ddList, 10); stroke(ddList, CONFIG.colors.accent, 1.5, 0)
            local pad = Instance.new("UIPadding")
            pad.PaddingTop=UDim.new(0,4); pad.PaddingBottom=UDim.new(0,4); pad.Parent=ddList
            local lay = Instance.new("UIListLayout"); lay.FillDirection=Enum.FillDirection.Vertical; lay.Parent=ddList
            for i, name in ipairs(list) do
                local item = Instance.new("TextButton")
                item.Size=UDim2.new(1,-8,0,itemH); item.Position=UDim2.new(0,4,0,0)
                item.BackgroundTransparency=1; item.Text=name
                item.TextColor3 = (name == UI.cfgSelected) and CONFIG.colors.accent or CONFIG.colors.textPrimary
                item.Font=Enum.Font.GothamBold; item.TextSize=16
                item.TextXAlignment=Enum.TextXAlignment.Left; item.AutoButtonColor=false
                item.LayoutOrder=i; item.ZIndex=62; item.Parent=ddList; corner(item, 6)
                local ipad = Instance.new("UIPadding"); ipad.PaddingLeft=UDim.new(0,10); ipad.Parent=item
                item.MouseEnter:Connect(function()
                    tween(item, {BackgroundTransparency=0, BackgroundColor3=CONFIG.colors.navBg}, CONFIG.anim.fast)
                end)
                item.MouseLeave:Connect(function()
                    tween(item, {BackgroundTransparency=1}, CONFIG.anim.fast)
                end)
                item.Activated:Connect(function()
                    UI.cfgSelected = name
                    ddBtn.Text = name
                    closeDd()
                end)
            end
            tween(ddStroke, {Color=CONFIG.colors.accent}, CONFIG.anim.fast)
            tween(arrow, {Rotation=0}, CONFIG.anim.fast)
        end
        ddBtn.Activated:Connect(openDd)
        ddBtn.MouseEnter:Connect(function()
            if not ddListOpen then
                tween(ddBtn, {BackgroundColor3=CONFIG.colors.navBg}, CONFIG.anim.fast)
            end
        end)
        ddBtn.MouseLeave:Connect(function()
            tween(ddBtn, {BackgroundColor3=CONFIG.colors.cfgBtnBg}, CONFIG.anim.fast)
        end)
        smallButton(card, 250, "Load config", function()
            local name = UI.cfgSelected
            if not name then notify("Config", "Select a config first", "info") return end
            local data = ConfigSys.load(name)
            if not data then notify("Config", "Failed to load", "info") return end
            for k, v in pairs(data) do UI.options[k] = v end
            if UI.rebuildTab then UI.rebuildTab() end
            notify("Config", "\"" .. name .. "\" loaded", "info")
        end)
        smallButton(card, 288, "Overwrite config", function()
            local name = UI.cfgSelected
            if not name then notify("Config", "Select a config first", "info") return end
            local ok = ConfigSys.save(name, UI.options)
            if ok then notify("Config", "\"" .. name .. "\" overwritten", "info")
            else notify("Config", "Failed", "info") end
        end)
        smallButton(card, 326, "Delete config", function()
            local name = UI.cfgSelected
            if not name then notify("Config", "Select a config first", "info") return end
            ConfigSys.delete(name)
            UI.cfgSelected = nil
            ddBtn.Text = "---"
            if UI.refreshCfgList then UI.refreshCfgList() end
            notify("Config", "\"" .. name .. "\" deleted", "info")
        end)
        smallButton(card, 364, "Refresh list", function()
            if UI.refreshCfgList then UI.refreshCfgList() end
            notify("Config", "List refreshed", "info")
        end)
        smallButton(card, 402, "Set as autoload", function()
            local name = UI.cfgSelected
            if not name then notify("Config", "Select a config first", "info") return end
            ConfigSys.setAutoload(name)
            if UI.updateAutoloadText then UI.updateAutoloadText() end
            notify("Config", "\"" .. name .. "\" set as autoload", "info")
        end)
        smallButton(card, 440, "Reset autoload", function()
            ConfigSys.setAutoload(nil)
            if UI.updateAutoloadText then UI.updateAutoloadText() end
            notify("Config", "Autoload cleared", "info")
        end)
        local autoloadText = Instance.new("TextLabel")
        autoloadText.Size=UDim2.new(1,-28,0,22); autoloadText.Position=UDim2.new(0,14,0,482)
        autoloadText.BackgroundTransparency=1
        autoloadText.Text="Current autoload config: " .. (ConfigSys.getAutoload() or "none")
        autoloadText.TextColor3=CONFIG.colors.textDesc; autoloadText.Font=Enum.Font.GothamBold
        autoloadText.TextSize=CONFIG.textSizes.cfgHint
        autoloadText.TextXAlignment=Enum.TextXAlignment.Left
        autoloadText.Parent=card
        UI.refreshCfgList = function()
            UI.cfgList = ConfigSys.list()
            if UI.cfgSelected then
                local found = false
                for _, n in ipairs(UI.cfgList) do
                    if n == UI.cfgSelected then found = true break end
                end
                if not found then UI.cfgSelected = nil end
            end
            ddBtn.Text = UI.cfgSelected or "---"
        end
        UI.updateAutoloadText = function()
            autoloadText.Text = "Current autoload config: " .. (ConfigSys.getAutoload() or "none")
        end
    end

    local function buildAbilitySelectorCard(order)
        local card = Instance.new("Frame")
        card.Name = "AbilitySelector"
        card.Size = UDim2.new(1, 0, 0, 260)
        card.BackgroundColor3 = CONFIG.colors.cardBg
        card.BorderSizePixel = 0
        card.LayoutOrder = order
        card.Parent = scroll
        corner(card, CONFIG.sizes.cardRadius)
        stroke(card, CONFIG.colors.cardBorder, 1.5, 0)

        local titleLbl = Instance.new("TextLabel")
        titleLbl.BackgroundTransparency = 1
        titleLbl.Text = "Ability Target"
        titleLbl.TextColor3 = CONFIG.colors.textPrimary
        titleLbl.Font = Enum.Font.GothamBold
        titleLbl.TextSize = CONFIG.textSizes.cardTitle
        titleLbl.TextXAlignment = Enum.TextXAlignment.Left
        titleLbl.Size = UDim2.new(1, -32, 0, 28)
        titleLbl.Position = UDim2.new(0, 16, 0, 14)
        titleLbl.Parent = card

        local targetLbl = Instance.new("TextLabel")
        targetLbl.BackgroundTransparency = 1
        targetLbl.Text = "target: NONE — click a MISSING ability"
        targetLbl.TextColor3 = CONFIG.colors.closeHover
        targetLbl.Font = Enum.Font.Code
        targetLbl.TextSize = 13
        targetLbl.TextXAlignment = Enum.TextXAlignment.Left
        targetLbl.Size = UDim2.new(1, -32, 0, 16)
        targetLbl.Position = UDim2.new(0, 16, 0, 44)
        targetLbl.Parent = card

        local list = Instance.new("ScrollingFrame")
        list.Size = UDim2.new(1, -32, 0, 185)
        list.Position = UDim2.new(0, 16, 0, 66)
        list.BackgroundTransparency = 1
        list.BorderSizePixel = 0
        list.ScrollBarThickness = 2
        list.ScrollBarImageColor3 = CONFIG.colors.accent
        list.ScrollBarImageTransparency = 0.4
        list.CanvasSize = UDim2.new(0, 0, 0, 0)
        list.AutomaticCanvasSize = Enum.AutomaticSize.Y
        list.Parent = card

        local listLayout = Instance.new("UIListLayout")
        listLayout.Padding = UDim.new(0, 4)
        listLayout.SortOrder = Enum.SortOrder.LayoutOrder
        listLayout.Parent = list

        local function render()
            for _, c in ipairs(list:GetChildren()) do
                if c:IsA("TextButton") or c:IsA("TextLabel") then c:Destroy() end
            end
            local data = GameTools.SpinSystem.getState()
            local target = GameTools.SpinSystem.target
            if target then
                targetLbl.Text = "target: " .. target
                targetLbl.TextColor3 = CONFIG.colors.accent
            else
                targetLbl.Text = "target: NONE — click a MISSING ability"
                targetLbl.TextColor3 = CONFIG.colors.closeHover
            end
            if not data or not data.OwnedAbilities then
                local lbl = Instance.new("TextLabel")
                lbl.Size = UDim2.new(1, 0, 0, 32)
                lbl.BackgroundTransparency = 1
                lbl.Text = "Loading ability data..."
                lbl.TextColor3 = CONFIG.colors.textMuted
                lbl.Font = Enum.Font.Gotham
                lbl.TextSize = 12
                lbl.Parent = list
                return
            end
            local names = {}
            for n in pairs(data.OwnedAbilities) do names[#names+1] = n end
            table.sort(names)
            if #names == 0 then
                local lbl = Instance.new("TextLabel")
                lbl.Size = UDim2.new(1, 0, 0, 32)
                lbl.BackgroundTransparency = 1
                lbl.Text = "No abilities loaded"
                lbl.TextColor3 = CONFIG.colors.textMuted
                lbl.Font = Enum.Font.Gotham
                lbl.TextSize = 12
                lbl.Parent = list
                return
            end
            for i, name in ipairs(names) do
                local owned = data.OwnedAbilities[name] == true
                local equipped = (data.EquippedAbility == name)
                local isTarget = (target == name)
                local row = Instance.new("TextButton")
                row.Size = UDim2.new(1, -4, 0, 30)
                row.BackgroundColor3 = isTarget and CONFIG.colors.navBg or CONFIG.colors.cfgBtnBg
                row.BackgroundTransparency = isTarget and 0 or 0.35
                row.Text = ""
                row.AutoButtonColor = false
                row.LayoutOrder = i
                row.Parent = list
                corner(row, 6)
                stroke(row, isTarget and CONFIG.colors.accent or (owned and CONFIG.colors.accent or CONFIG.colors.cfgBtnBorder), isTarget and 1.5 or 1, 0.3)
                local dot = Instance.new("Frame")
                dot.Size = UDim2.fromOffset(8, 8)
                dot.Position = UDim2.new(0, 10, 0.5, -4)
                dot.BackgroundColor3 = owned and CONFIG.colors.accent or CONFIG.colors.lockedText
                dot.BorderSizePixel = 0
                dot.Parent = row
                corner(dot, 4)
                local nameLbl = Instance.new("TextLabel")
                nameLbl.Size = UDim2.new(1, -100, 1, 0)
                nameLbl.Position = UDim2.new(0, 24, 0, 0)
                nameLbl.BackgroundTransparency = 1
                nameLbl.Text = name
                nameLbl.TextColor3 = owned and CONFIG.colors.textPrimary or CONFIG.colors.lockedText
                nameLbl.Font = Enum.Font.GothamBold
                nameLbl.TextSize = 12
                nameLbl.TextXAlignment = Enum.TextXAlignment.Left
                nameLbl.Parent = row
                local badge = Instance.new("TextLabel")
                badge.Size = UDim2.fromOffset(78, 18)
                badge.Position = UDim2.new(1, -86, 0.5, -9)
                badge.BackgroundColor3 = owned and Color3.fromRGB(20,40,25) or Color3.fromRGB(30,20,20)
                badge.Text = equipped and "EQUIPPED" or (owned and "OWNED" or "MISSING")
                badge.TextColor3 = equipped and CONFIG.colors.accent or (owned and CONFIG.colors.accent or CONFIG.colors.closeHover)
                badge.Font = Enum.Font.GothamBold
                badge.TextSize = 9
                badge.BorderSizePixel = 0
                badge.Parent = row
                corner(badge, 4)
                row.MouseEnter:Connect(function()
                    if not isTarget then tween(row, {BackgroundTransparency=0, BackgroundColor3=CONFIG.colors.navBg}, 0.1) end
                end)
                row.MouseLeave:Connect(function()
                    if not isTarget then tween(row, {BackgroundTransparency=0.35, BackgroundColor3=CONFIG.colors.cfgBtnBg}, 0.12) end
                end)
                row.MouseButton1Click:Connect(function()
                    if GameTools.SpinSystem.running then
                        notify("Spin", "Stop the spin before changing target", "info"); return
                    end
                    GameTools.SpinSystem.setTarget(name)
                    notify("Spin", "Target: " .. name, "info")
                    render()
                end)
            end
        end
        GameTools.SpinSystem.renderUI = render
        task.delay(0.5, function() pcall(render) end)
        task.spawn(function()
            while true do
                task.wait(6)
                if list.Parent then pcall(render) end
            end
        end)
    end

    local function clearContent()
        for _, c in ipairs(scroll:GetChildren()) do
            if not c:IsA("UIListLayout") and not c:IsA("UIPadding") then c:Destroy() end
        end
    end

    local function buildMainTab()
        clearContent()
        createToggleCard(1, "Auto Mission",
            "The world owes you, and you no longer wait for it to pay. Every mission, every daily, gathered without a word — silently, ceaselessly, for as long as you breathe.",
            "auto_mission", false,
            function(v) if v then GameTools.AutoMission.enable() else GameTools.AutoMission.disable() end end)
        createToggleCard(2, "Auto Punch",
            "The Hulk's fists were never his alone. Every beat of his attack — fired for you, silently, forever.",
            "auto_punch", false,
            function(v) GameTools.AutoPunch.setEnabled(v) end)
        createToggleCard(3, "Auto Spin Ability",
            "Hunt the missing ability. Every spin counts down to acquisition — the machine spins until it lands or the purse runs dry.",
            "spin_ability", false,
            function(v) GameTools.SpinSystem.setEnabled(v) end)
        buildAbilitySelectorCard(4)
        createButtonCard(5, "Escape Button",
            "A silent escape. Tap to awaken the shadow — it will find the safe path when others fall.",
            function()
                buildBall("panic", {
                    text = "ESCAPE", bg = Color3.fromRGB(200, 60, 60),
                    bgHover = Color3.fromRGB(230, 70, 70),
                    strokeColor = Color3.fromRGB(255, 150, 150),
                    pos = UDim2.new(1, -110, 1, -220),
                    onFire = function() Panic.fireManual() end,
                })
                notify("Escape Button", "Ball created", "info")
            end, true)
        createToggleCard(6, "Auto Escape",
            "The watching sentinel. While active, your shadow moves for you before danger touches your body.",
            "auto_panic", false,
            function(v) Panic.setAuto(v) end, true)
        createButtonCard(7, "Kill Hulk Button",
            "Rips the beast from the world. Tap to unleash the chaos that hurls it away — tap again to repeat.",
            function()
                buildBall("fling", {
                    text = "KILL", bg = Color3.fromRGB(80, 20, 20),
                    bgHover = Color3.fromRGB(120, 30, 30),
                    strokeColor = Color3.fromRGB(255, 80, 80),
                    pos = UDim2.new(1, -210, 1, -220),
                    onFire = function()
                        if Fling.running then return end
                        Fling.fire()
                    end,
                })
                notify("Kill Hulk", "Ball created", "info")
            end, true)
        createSliderCard(8, "Kill Predict",
            "Shift the kill target along the Hulk's path. Negative = behind him. Positive = ahead of him. Zero = at him.",
            "fling_predict", -100, 100, 5,
            function(v) Fling.predictOffset = v end, false, true)
    end

    local function buildVisualTab()
        clearContent()
        createToggleCard(1, "ESP Hulk", "See the beast through walls and shadows — every step it takes revealed to your gaze.", "esp_hulk", false,
            function(v) PlayerESP.setFlag("hulk", v) end)
        createToggleCard(2, "ESP Hulkbuster", "The golden armor cannot hide from you. Feel it before it feels you.", "esp_hulkbuster", false,
            function(v) PlayerESP.setFlag("hulkbuster", v) end)
        createToggleCard(3, "ESP Survivor", "Know every soul around you before darkness takes them. No survivor escapes your perception.", "esp_survivor", false,
            function(v) PlayerESP.setFlag("survivor", v) end)
        createToggleCard(4, "ESP Weapons", "Discover what they carry before it turns against you. No weapon stays hidden.", "esp_weapons", false,
            function(v) PlayerESP.setFlag("weapon", v) end)
        createToggleCard(5, "ESP Vents", "The ducts whisper their secrets. Hear every hidden breath between walls.", "esp_vents", false,
            function(v) if v then EspVents.enable() else EspVents.disable() end end)
        createToggleCard(6, "ESP Cabinet", "Every hiding place revealed. Nothing stays closed to you.", "esp_cabinet", false,
            function(v) if v then EspCabinet.enable() else EspCabinet.disable() end end)
        createToggleCard(7, "ESP Ability Owners",
            "See who carries the golden key before they even use it. Allies or threats — the choice is yours.",
            "esp_ability", false,
            function(v) PlayerESP.setFlag("abilityHighlight", v) end)
        createToggleCard(8, "ESP Hulk Probability + Pity",
            "Read the destiny written for every player. See who the beast will choose next before the game decides.",
            "esp_hulk_chance", false,
            function(v) if v then ChanceESP.enable() else ChanceESP.disable() end end)
    end

    local function buildPlayerTab()
        clearContent()
        createToggleCard(1, "Infinite Stamina (Survivor)",
            "The world has a limit for how far you can run. It doesn't apply to you. Every stride faster than it should be, every breath endless, every sprint that never fades — as if the game forgot to tell your legs when to stop.",
            "inf_stamina", false,
            function(v) if v then InfiniteStamina.enable() else InfiniteStamina.disable() end end)
        createToggleCard(2, "JumpPower",
            "Touch the sky with your feet. Free your jump from the chains of the world.",
            "jump_enabled", false,
            function(v) PlayerState.jumpEnabled = v; applyPlayerState() end)
        createSliderCard(3, "JumpPower Value",
            "The height your body can reach when the sky calls.",
            "jump_value", 50, 500, 50,
            function(v) PlayerState.jumpPower = v; if PlayerState.jumpEnabled then applyPlayerState() end end)
        createToggleCard(4, "Speed Power",
            "Move faster than sight can follow. Slip between the spaces.",
            "tpwalk_enabled", false,
            function(v) PlayerState.speedPower = v end)
        createSliderCard(5, "Speed Power Value",
            "The exact force that carries your body between two points. Accepts decimal values.",
            "tp_speed", 0.1, 50, 3,
            function(v) PlayerState.tpSpeed = v end, true)
    end

    local function buildMiscTab()
        clearContent()
        createToggleCard(1, "Anti Ragdoll",
            "You refuse to fall. The world will try to break your legs, drop your body, pin you to the floor — but your spine remembers what standing means, and it does not forget.",
            "anti_ragdoll", false,
            function(v) if v then AntiRagdoll.enable() else AntiRagdoll.disable() end end)
        createToggleCard(2, "Anti Debris",
            "The world breaks, but fragments vanish before touching the ground. Silence for your eyes.",
            "anti_debris", false,
            function(v) if v then AntiDebris.enable() else AntiDebris.disable() end end)
        createToggleCard(3, "Remove Doors",
            "Walls bend, doors open — nothing keeps you from your path.",
            "re_scan_doors", false,
            function(v) if v then Doors.enable() else Doors.disable() end end)
        createToggleCard(4, "Live Event",
            "Hear every scream, every fall, every moment. The world speaks — you simply listen.",
            "live_event", false,
            function(v) if v then EventLog.enable() else EventLog.disable() end end)
        createToggleCard(5, "Hulk Alert",
            "The beast approaches. You will know before it sees you — the distance between you, measured in every beat of your heart.",
            "hulk_alert", false,
            function(v) if v then HulkAlert.enable() else HulkAlert.disable() end end)
    end

    local function buildSettingsTab()
        clearContent()
        buildKeybindCard()
        buildConfigCard()
    end

    local function buildTab(tabId)
        if tabId == "main" then buildMainTab()
        elseif tabId == "visual" then buildVisualTab()
        elseif tabId == "player" then buildPlayerTab()
        elseif tabId == "misc" then buildMiscTab()
        elseif tabId == "settings" then buildSettingsTab()
        else buildMainTab() end
        scroll.CanvasPosition = Vector2.zero
    end
    UI.rebuildTab = function() buildTab(UI.activeTab) end

    local function animateTabActivate(entry, doPop)
        local baseSize = entry.baseSize
        local activeIconSize = UDim2.new(0, baseSize, 0, baseSize)
        local popSize = UDim2.new(0, baseSize * 1.18, 0, baseSize * 1.18)
        entry.icon.Size = activeIconSize
        tween(entry.button, {BackgroundColor3=CONFIG.colors.navBg}, CONFIG.anim.fast)
        tween(entry.icon, {ImageColor3=CONFIG.colors.navIconActive}, CONFIG.anim.fast)
        tween(entry.stroke, {Color=CONFIG.colors.navActiveBrd, Transparency=0, Thickness=3.6}, 0.18)
        task.delay(0.18, function() tween(entry.stroke, {Thickness=2.4}, 0.22) end)
        tween(entry.iconGlow, {ImageColor3=CONFIG.colors.navIconActive, ImageTransparency=0.35}, CONFIG.anim.fast)
        if doPop then
            entry.icon.Size = UDim2.new(0, baseSize * 0.75, 0, baseSize * 0.75)
            entry.icon.Position = UDim2.new(0.5, -(baseSize * 0.75)/2, 0.5, -(baseSize * 0.75)/2)
            popTween(entry.icon, {
                Size = popSize, Position = UDim2.new(0.5, -(baseSize * 1.18)/2, 0.5, -(baseSize * 1.18)/2) }, 0.22)
            task.delay(0.22, function()
                tween(entry.icon, {Size = activeIconSize, Position = UDim2.new(0.5, -baseSize/2, 0.5, -baseSize/2)}, 0.16)
            end)
        end
    end
    local function animateTabDeactivate(entry)
        local baseSize = entry.baseSize
        tween(entry.button, {BackgroundColor3=CONFIG.colors.navBg}, CONFIG.anim.fast)
        tween(entry.stroke, {Color=CONFIG.colors.navBorder, Transparency=0, Thickness=2}, CONFIG.anim.fast)
        tween(entry.icon, {ImageColor3=CONFIG.colors.navIcon}, CONFIG.anim.fast)
        tween(entry.iconGlow, {ImageColor3=CONFIG.colors.navIcon, ImageTransparency=0.85}, CONFIG.anim.fast)
        entry.icon.Size = UDim2.new(0, baseSize, 0, baseSize)
        entry.icon.Position = UDim2.new(0.5, -baseSize/2, 0.5, -baseSize/2)
    end
    local function selectTab(tabId, doPop)
        UI.activeTab = tabId
        for id, entry in pairs(tabButtons) do
            if id == tabId then animateTabActivate(entry, doPop)
            else animateTabDeactivate(entry) end
        end
        buildTab(tabId)
    end
    for id, entry in pairs(tabButtons) do
        track(entry.hit.Activated:Connect(function()
            if UI.activeTab == id then return end
            selectTab(id, true)
        end))
    end

    local function minimizePanel()
        if not UI.isOpen or UI.isMinimized then return end
        UI.isMinimized = true
        local cxA, cyA = currentCenterPixels()
        local s = uiScale.Scale or 1
        local fullW, fullH = CONFIG.sizes.windowWidth * s, CONFIG.sizes.windowHeight * s
        local px, py = clampCenter(cxA, cyA, fullW, fullH)
        savePosition(UDim2.new(0, px, 0, py))
        UI.savedPos = UDim2.new(0, px, 0, py)
        safeWrite(bodyLayer, "Visible", false)
        safeWrite(navBar, "Visible", false)
        safeWrite(contentContainer, "Visible", false)
        if UI.infoOpen then infoFrame.Visible = false end
        local minH = CONFIG.sizes.headerHeight + 2
        local w, h = CONFIG.sizes.windowWidth * s, minH * s
        local cx, cy = clampCenter(cxA, cyA, w, h)
        TweenService:Create(scaleWrapper, TweenInfo.new(CONFIG.anim.slow, CONFIG.anim.easing, CONFIG.anim.dir), {
            Size = UDim2.new(0, CONFIG.sizes.windowWidth, 0, minH),
            Position = UDim2.new(0, cx, 0, cy),
        }):Play()
    end
    local function restorePanel()
        if not UI.isMinimized then return end
        UI.isMinimized = false
        safeWrite(bodyLayer, "Visible", true)
        if UI.infoOpen then
            infoFrame.Visible = true
            safeWrite(navBar, "Visible", false)
            safeWrite(contentContainer, "Visible", false)
        else
            safeWrite(navBar, "Visible", true)
            safeWrite(contentContainer, "Visible", true)
        end
        local s = uiScale.Scale or 1
        local w, h = CONFIG.sizes.windowWidth * s, CONFIG.sizes.windowHeight * s
        local cx, cy = currentCenterPixels()
        local tcx, tcy = clampCenter(cx, cy, w, h)
        local target = UDim2.new(0, tcx, 0, tcy)
        UI.savedPos = target
        savePosition(target)
        TweenService:Create(scaleWrapper, TweenInfo.new(CONFIG.anim.slow, CONFIG.anim.easing, CONFIG.anim.dir), {
            Size = UDim2.new(0, CONFIG.sizes.windowWidth, 0, CONFIG.sizes.windowHeight),
            Position = target,
        }):Play()
    end
    local function closePanel()
        if not UI.isOpen then return end
        UI.isOpen = false
        local cx, cy = currentCenterPixels()
        local s = uiScale.Scale or 1
        local w, h = CONFIG.sizes.windowWidth * s, CONFIG.sizes.windowHeight * s
        local px, py = clampCenter(cx, cy, w, h)
        savePosition(UDim2.new(0, px, 0, py))
        safeWrite(bodyLayer, "Visible", false)
        safeWrite(navBar, "Visible", false)
        safeWrite(contentContainer, "Visible", false)
        if UI.infoOpen then infoFrame.Visible = false end
        tween(scaleWrapper, { Size = UDim2.new(0, CONFIG.sizes.windowWidth, 0, 0) }, CONFIG.anim.normal)
    end
    local function openPanel(playEntrance)
        if UI.destroyed or UI.isOpen then return end
        UI.isOpen = true
        local vp = getViewport()
        local s = uiScale.Scale or 1
        local w, h = CONFIG.sizes.windowWidth * s, CONFIG.sizes.windowHeight * s
        local usePos = UI.savedPos or UDim2.new(0.5, 0, 0.5, 0)
        local cx = usePos.X.Scale * vp.X + usePos.X.Offset
        local cy = usePos.Y.Scale * vp.Y + usePos.Y.Offset
        local tcx, tcy = clampCenter(cx, cy, w, h)
        local targetPos = UDim2.new(0, tcx, 0, tcy)
        UI.savedPos = targetPos
        safeWrite(scaleWrapper, "Position", targetPos)
        UI.everOpened = true
        if playEntrance ~= false then
            safeWrite(scaleWrapper, "Size", UDim2.new(0, CONFIG.sizes.windowWidth, 0, 0))
            safeWrite(mainWindow, "BackgroundTransparency", 1)
            safeWrite(header, "BackgroundTransparency", 1)
            safeWrite(headerFlat, "BackgroundTransparency", 1)
            safeWrite(bodyLayer, "Visible", false)
            local finalSize = UDim2.new(0, CONFIG.sizes.windowWidth, 0, CONFIG.sizes.windowHeight)
            local tw = TweenService:Create(scaleWrapper, TweenInfo.new(0.55, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size=finalSize})
            tw:Play()
            tween(mainWindow, {BackgroundTransparency=0}, 0.40)
            tween(header, {BackgroundTransparency=0}, 0.40)
            tween(headerFlat, {BackgroundTransparency=0}, 0.40)
            task.delay(0.34, function()
                safeWrite(bodyLayer, "Visible", true)
                if UI.infoOpen then
                    infoFrame.Visible = true
                    safeWrite(navBar, "Visible", false)
                    safeWrite(contentContainer, "Visible", false)
                else
                    safeWrite(navBar, "Visible", true)
                    safeWrite(contentContainer, "Visible", true)
                end
            end)
        else
            safeWrite(scaleWrapper, "Size", UDim2.new(0, CONFIG.sizes.windowWidth, 0, CONFIG.sizes.windowHeight))
            safeWrite(mainWindow, "BackgroundTransparency", 0)
            safeWrite(header, "BackgroundTransparency", 0)
            safeWrite(headerFlat, "BackgroundTransparency", 0)
            safeWrite(bodyLayer, "Visible", true)
            safeWrite(navBar, "Visible", true)
            safeWrite(contentContainer, "Visible", true)
        end
    end

    minBtn.Activated:Connect(function()
        if UI.isMinimized then restorePanel() else minimizePanel() end
    end)
    closeBtn.Activated:Connect(function()
        closePanel()
        task.delay(CONFIG.anim.normal + 0.05, function()
            InfiniteStamina.disable(); EspVents.disable(); EspCabinet.disable()
            Doors.disable(); EventLog.disable(); HulkAlert.disable()
            ChanceESP.disable(); AntiDebris.disable(); AntiRagdoll.disable()
            GameTools.AutoMission.disable()
            GameTools.AutoPunch.setEnabled(false)
            GameTools.SpinSystem.setEnabled(false)
            peClearAll(); Panic.setAuto(false)
            destroyBall("panic"); destroyBall("fling")
            screenGui:Destroy()
            local ng = uiParent:FindFirstChild("BabisUIKitNotif"); if ng then ng:Destroy() end
            local ngPg = PlayerGui:FindFirstChild("BabisUIKitNotif"); if ngPg then ngPg:Destroy() end
        end)
    end)
    minBtn.MouseEnter:Connect(function() tween(minGlyph, {BackgroundColor3=CONFIG.colors.accent}, CONFIG.anim.fast) end)
    minBtn.MouseLeave:Connect(function() tween(minGlyph, {BackgroundColor3=CONFIG.colors.textPrimary}, CONFIG.anim.fast) end)
    closeBtn.MouseEnter:Connect(function()
        tween(xBar1, {BackgroundColor3=CONFIG.colors.closeHover}, CONFIG.anim.fast)
        tween(xBar2, {BackgroundColor3=CONFIG.colors.closeHover}, CONFIG.anim.fast)
    end)
    closeBtn.MouseLeave:Connect(function()
        tween(xBar1, {BackgroundColor3=CONFIG.colors.textPrimary}, CONFIG.anim.fast)
        tween(xBar2, {BackgroundColor3=CONFIG.colors.textPrimary}, CONFIG.anim.fast)
    end)

    local dragging = false
    local dragStartAbs = nil
    local dragStartCenter = nil
    local dragMoved = false
    local DRAG_THRESHOLD = 5
    local DRAG_SPURIOUS = 400

    header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragMoved = false
            dragStartAbs = input.Position
            local cx, cy = currentCenterPixels()
            dragStartCenter = Vector2.new(cx, cy)
        end
    end)
    track(UserInputService.InputChanged:Connect(function(input)
        if not dragging then return end
        if input.UserInputType ~= Enum.UserInputType.MouseMovement
           and input.UserInputType ~= Enum.UserInputType.Touch then return end
        local delta = input.Position - dragStartAbs
        if delta.Magnitude > DRAG_SPURIOUS then
            dragStartAbs = input.Position
            local cx, cy = currentCenterPixels()
            dragStartCenter = Vector2.new(cx, cy)
            return
        end
        if not dragMoved then
            if delta.Magnitude < DRAG_THRESHOLD then return end
            dragMoved = true
        end
        local w, h = currentPixelSize()
        local tcx, tcy = clampCenter(
            dragStartCenter.X + delta.X,
            dragStartCenter.Y + delta.Y,
            w, h
        )
        local newPos = UDim2.new(0, tcx, 0, tcy)
        safeWrite(scaleWrapper, "Position", newPos)
        UI.savedPos = newPos
    end))
    track(UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType ~= Enum.UserInputType.MouseButton1
           and input.UserInputType ~= Enum.UserInputType.Touch then return end
        if dragging then
            dragging = false
            if dragMoved then savePosition(UI.savedPos) end
        end
    end))

    track(UserInputService.InputBegan:Connect(function(input, gpe)
        if UI.destroyed then return end
        if gpe then return end
        if input.UserInputType ~= Enum.UserInputType.Keyboard then return end
        local savedKey = UI.options["toggle_key"]
        if not savedKey or savedKey == "None" or savedKey == "" then return end
        if input.KeyCode == Enum.KeyCode[savedKey] then
            if UI.isOpen then closePanel() else openPanel() end
        end
    end))

    local function updateScale()
        local vp = getViewport()
        local sx = (vp.X - 16) / CONFIG.sizes.windowWidth
        local sy = (vp.Y - 32) / CONFIG.sizes.windowHeight
        local s = math.min(1.25, math.min(sx, sy))
        s = math.max(s, 0.55)
        uiScale.Scale = s
        local w, h = currentPixelSize()
        local cx, cy = currentCenterPixels()
        local tcx, tcy = clampCenter(cx, cy, w, h)
        local newPos = UDim2.new(0, tcx, 0, tcy)
        safeWrite(scaleWrapper, "Position", newPos)
        UI.savedPos = newPos
    end
    updateScale()
    local cam = workspace.CurrentCamera
    if cam then track(cam:GetPropertyChangedSignal("ViewportSize"):Connect(updateScale)) end

    selectTab(CONFIG.defaultTab, false)
    openPanel(true)
end

showIntro(buildMainUI)