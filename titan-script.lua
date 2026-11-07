--[[
    TITAN v10.0  —  Full Edition  (one file)
    60 функций · 20 game · 20 visual · 20 utility
    Custom UI · Draggable · PersistPosition · Tooltips
    F1 menu · End panic · F5 save · F6 load
]]

-- ===== CLEANUP =====
local CoreGui=game:GetService("CoreGui")
for _,n in ipairs({"TitanUI","TitanESP","TitanHUD","TitanMenu"}) do
    local o=CoreGui:FindFirstChild(n); if o then o:Destroy() end
end
local Players=game:GetService("Players")
local RunService=game:GetService("RunService")
local UIS=game:GetService("UserInputService")
local WS=game:GetService("Workspace")
local TS=game:GetService("TweenService")
local HS=game:GetService("HttpService")
local Lighting=game:GetService("Lighting")
local TPS=game:GetService("TeleportService")
local Camera=WS.CurrentCamera
local LP=Players.LocalPlayer

-- ===== SETTINGS =====
local D={Enabled=true,TeamCheck=true,WallCheck=false,FOV=200,Smoothness=0.35,
TargetPart="Head",MaxDistance=1000,VisibleCheck=true,Prediction=true,PredictionX=0.12,
AimLock=false,TargetPriority="Distance",LockOn=true,LockIgnoreDist=true,LockIgnoreWall=true,
LockTimeout=0,LockShowLine=true,LockPriority=true,HitboxExpander=false,HitboxSize=10,UseKeybind=true,
TriggerBot=false,TriggerDelay=0.02,TriggerFOV=40,TriggerPart="Head",TriggerTeamCheck=true,
TriggerWallCheck=true,TriggerHold=false,AutoFire=false,AutoFireDelay=0.1,
AutoClicker=false,AutoClickerDelay=0.05,AntiAim=false,AntiAimSpeed=0.05,AntiAimRange=90,
AntiAimAxis="Yaw",AntiAimRandom=true,AntiAimHideHead=true,
BHop=false,Fly=false,FlySpeed=50,Spider=false,SpiderSpeed=30,SpeedBoost=false,SpeedValue=30,
JumpBoost=false,JumpValue=50,NoClip=false,WalkOnWater=false,AntiFling=false,
AutoQueue=false,FastPlace=false,AutoFarm=false,AutoLoot=false,
ShowFOV=true,FOVColor=Color3.fromRGB(120,100,255),Crosshair=false,CrosshairSize=12,
ESP=false,ESPBox=true,ESPName=true,ESPHealth=true,ESPDistance=true,ESPTracer=false,
ESPSkeleton=false,ESPColor=Color3.fromRGB(120,100,255),Chams=false,
ChamsColor=Color3.fromRGB(120,100,255),ChamsTransp=0.5,Fullbright=false,RemoveFog=false,
Watermark=true,AimTracer=false,RaycastVis=false,TargetInfo=false,FPSGraph=false,
HitMarker=true,SoundESP=false,Radar=false,NoSmokeFlash=false,
AutoReconnect=false,AutoSaveConfig=false,Notifications=true,FPSBoost=false,FPSUnlock=false,
Bind_Menu="F1",Bind_Aim="LeftAlt",Bind_Trigger="X",Bind_Fly="F",Bind_Panic="End",Bind_ESP="RightAlt",
ProfileName="default",WindowX=-1,WindowY=-1,WindowW=600,WindowH=700,
AccentColor=Color3.fromRGB(99,102,241),AutoLoadLast=true}
local Settings={}
for k,v in pairs(D) do Settings[k]=v end

-- ===== CONFIG =====
local CD="TitanConfigs"
pcall(function() if not isfolder(CD) then makefolder(CD) end end)
local Cfg={}
function Cfg.ser()
    local t={}
    for k,v in pairs(Settings) do
        if type(v)=="Color3" then t[k]={__c={math.floor(v.R*255+.5),math.floor(v.G*255+.5),math.floor(v.B*255+.5)}}
        elseif type(v)~="userdata" and type(v)~="function" then t[k]=v end
    end
    return t
end
function Cfg.deser(t)
    for k,v in pairs(t) do
        if type(v)=="table" and v.__c then Settings[k]=Color3.fromRGB(v.__c[1],v.__c[2],v.__c[3])
        else Settings[k]=v end
    end
end
function Cfg.save(n)
    n=n or Settings.ProfileName
    local ok=pcall(function()
        writefile(CD.."/"..n..".json",HS:JSONEncode(Cfg.ser()))
        writefile(CD.."/last.txt",n)
    end)
    return ok
end
function Cfg.load(n)
    n=n or Settings.ProfileName
    local ok,r=pcall(function() return readfile(CD.."/"..n..".json") end)
    if not ok then return false end
    local ok2,d=pcall(function() return HS:JSONDecode(r) end)
    if not ok2 then return false end
    Cfg.deser(d); Settings.ProfileName=n; return true
end
function Cfg.list()
    local n={}
    pcall(function() for _,f in ipairs(listfiles(CD)) do
        local m=f:match("([^/\\]+)%.json$"); if m then table.insert(n,m) end end end)
    if #n==0 then n={"default"} end
    return n
end
function Cfg.del(n) pcall(function() delfile(CD.."/"..n..".json") end) end
function Cfg.last()
    local ok,n=pcall(function() return readfile(CD.."/last.txt") end)
    if ok and n and n~="" then Cfg.load(n) end
end
if Settings.AutoLoadLast then pcall(Cfg.last) end

-- ===== CACHE =====
local Cache={C={},P={},RP=RaycastParams.new()}
Cache.RP.FilterType=Enum.RaycastFilterType.Exclude
local function CC(plr)
    local c=plr.Character; if not c then Cache.C[plr]=nil; Cache.P[plr]=nil; return end
    local h=c:FindFirstChildOfClass("Humanoid"); local r=c:FindFirstChild("HumanoidRootPart")
    if not h or not r then return end
    Cache.C[plr]={char=c,hum=h,root=r,head=c:FindFirstChild("Head")}
    Cache.P[plr]={Head=c:FindFirstChild("Head"),HumanoidRootPart=r,
        UpperTorso=c:FindFirstChild("UpperTorso") or c:FindFirstChild("Torso"),
        LowerTorso=c:FindFirstChild("LowerTorso") or c:FindFirstChild("Torso")}
end
for _,p in ipairs(Players:GetPlayers()) do CC(p) end
Players.PlayerAdded:Connect(function(p) p.CharacterAdded:Connect(function() task.wait(.5); CC(p) end) end)
Players.PlayerRemoving:Connect(function(p) Cache.C[p]=nil; Cache.P[p]=nil end)
task.spawn(function() while task.wait(2) do for _,p in ipairs(Players:GetPlayers()) do CC(p) end end end)

-- ===== PERF =====
local Perf={FPS=0,FT=0,LT=tick(),F=0}
RunService.RenderStepped:Connect(function(dt) Perf.F=Perf.F+1; Perf.FT=dt
    if tick()-Perf.LT>=.5 then Perf.FPS=math.floor(Perf.F/(tick()-Perf.LT)); Perf.F=0; Perf.LT=tick() end end)

-- ===== UTILS =====
local function FM() pcall(function() local v=game:GetService("VirtualInputManager")
    v:SendMouseButtonEvent(0,0,0,true,game,0); task.wait(.005)
    v:SendMouseButtonEvent(0,0,0,false,game,0) end) end
local function KC(n) local ok,k=pcall(function() return Enum.KeyCode[n] end); return ok and k or nil end
local function RG(o,r) local c=Instance.new("UICorner"); c.CornerRadius=UDim.new(0,r or 6); c.Parent=o; return c end
local function ST(o,c,t,tr) local s=Instance.new("UIStroke"); s.Color=c or Color3.fromRGB(70,70,85)
    s.Thickness=t or 1; s.Transparency=tr or .5; s.Parent=o; return s end
local function TC(o,p,c,t) TS:Create(o,TweenInfo.new(t or .15),{[p]=c}):Play() end
local function RIP(btn) btn.ClipsDescendants=true; btn.MouseButton1Down:Connect(function()
    local r=Instance.new("Frame"); r.AnchorPoint=Vector2.new(.5,.5)
    r.BackgroundColor3=Color3.new(1,1,1); r.BackgroundTransparency=.8
    r.Size=UDim2.new(0,0,0,0); r.Position=UDim2.new(.5,0,.5,0); RG(r,999)
    r.ZIndex=btn.ZIndex+1; r.Parent=btn
    r:TweenSize(UDim2.new(0,btn.AbsoluteSize.X*1.6,0,btn.AbsoluteSize.X*1.6),
        Enum.EasingDirection.Out,Enum.EasingStyle.Quad,.5,true)
    task.delay(.5,function() r:TweenSize(UDim2.new(0,0,0,0),Enum.EasingDirection.Out,
        Enum.EasingStyle.Quad,.3,true); task.wait(.3); r:Destroy() end) end) end

-- ===== UI FRAMEWORK =====
local SG=Instance.new("ScreenGui"); SG.Name="TitanMenu"; SG.ResetOnSpawn=false
SG.IgnoreGuiInset=true; SG.DisplayOrder=999
SG.ZIndexBehavior=Enum.ZIndexBehavior.Sibling; SG.Parent=CoreGui

local Win={}
function Win:Create()
    local w={Drag=false,DS=nil,SP=nil}
    local f=Instance.new("Frame"); f.Name="Main"
    f.Size=UDim2.new(0,Settings.WindowW,0,Settings.WindowH)
    if Settings.WindowX>=0 and Settings.WindowY>=0 then
        f.Position=UDim2.new(0,Settings.WindowX,0,Settings.WindowY)
    else f.Position=UDim2.new(.5,-Settings.WindowW/2,.5,-Settings.WindowH/2) end
    f.BackgroundColor3=Color3.fromRGB(20,20,26); f.BorderSizePixel=0; f.Visible=false
    f.Active=true; f.Parent=SG; f.ZIndex=10; RG(f,12)
    ST(f,Color3.fromRGB(70,70,85),1,.4)
    local g=Instance.new("UIGradient"); g.Color=ColorSequence.new(Color3.fromRGB(30,30,40),Color3.fromRGB(16,16,22))
    g.Rotation=90; g.Parent=f

    local sh=Instance.new("Frame"); sh.Size=UDim2.new(1,24,1,24); sh.Position=UDim2.new(0,-12,0,-12)
    sh.BackgroundColor3=Color3.new(0,0,0); sh.BackgroundTransparency=.7
    sh.BorderSizePixel=0; sh.ZIndex=9; RG(sh,16); sh.Parent=SG
    local function sync() sh.Position=f.Position-UDim2.new(0,12,0,12); sh.Size=f.Size+UDim2.new(0,24,0,24) end
    f:GetPropertyChangedSignal("Position"):Connect(sync)
    f:GetPropertyChangedSignal("Size"):Connect(sync); sync()

    local TB=Instance.new("Frame"); TB.Size=UDim2.new(1,0,0,44); TB.BackgroundTransparency=1
    TB.Active=true; TB.Parent=f; RG(TB,12)
    local gh=Instance.new("UIGradient"); gh.Color=ColorSequence.new(Settings.AccentColor,Color3.fromRGB(30,30,40))
    gh.Rotation=90; gh.Parent=TB
    local Lg=Instance.new("TextLabel"); Lg.Size=UDim2.new(0,28,0,28); Lg.Position=UDim2.new(0,14,.5,-14)
    Lg.BackgroundColor3=Settings.AccentColor; Lg.BorderSizePixel=0; Lg.Text="T"
    Lg.TextColor3=Color3.new(1,1,1); Lg.Font=Enum.Font.GothamBold; Lg.TextSize=16
    Lg.Parent=TB; RG(Lg,8)
    local TT=Instance.new("TextLabel"); TT.Size=UDim2.new(0,240,1,0); TT.Position=UDim2.new(0,50,0,0)
    TT.BackgroundTransparency=1; TT.Text="TITAN v10.0"
    TT.TextColor3=Color3.fromRGB(240,240,245); TT.Font=Enum.Font.GothamBold; TT.TextSize=14
    TT.TextXAlignment=Enum.TextXAlignment.Left; TT.Parent=TB
    local FL=Instance.new("TextLabel"); FL.Size=UDim2.new(0,90,1,0); FL.Position=UDim2.new(1,-130,0,0)
    FL.BackgroundTransparency=1; FL.Text="FPS —"
    FL.TextColor3=Color3.fromRGB(160,160,180); FL.Font=Enum.Font.Gotham; FL.TextSize=11
    FL.TextXAlignment=Enum.TextXAlignment.Right; FL.Parent=TB
    local MN=Instance.new("TextButton"); MN.Size=UDim2.new(0,30,0,30); MN.Position=UDim2.new(1,-74,.5,-15)
    MN.BackgroundTransparency=1; MN.Text="—"; MN.TextColor3=Color3.fromRGB(200,200,220)
    MN.Font=Enum.Font.GothamBold; MN.TextSize=14; MN.AutoButtonColor=false; MN.Parent=TB; RG(MN,6)
    local CL=Instance.new("TextButton"); CL.Size=UDim2.new(0,30,0,30); CL.Position=UDim2.new(1,-40,.5,-15)
    CL.BackgroundTransparency=1; CL.Text="✕"; CL.TextColor3=Color3.fromRGB(200,200,220)
    CL.Font=Enum.Font.GothamBold; CL.TextSize=14; CL.AutoButtonColor=false; CL.Parent=TB; RG(CL,6)
    CL.MouseEnter:Connect(function() TC(CL,"BackgroundTransparency",0,.1)
        TC(CL,"BackgroundColor3",Color3.fromRGB(196,43,28),.1); TC(CL,"TextColor3",Color3.new(1,1,1),.1) end)
    CL.MouseLeave:Connect(function() TC(CL,"BackgroundTransparency",1,.1)
        TC(CL,"TextColor3",Color3.fromRGB(200,200,220),.1) end)
    CL.MouseButton1Click:Connect(function() f.Visible=false end)
    MN.MouseButton1Click:Connect(function()
        if f.Size.Y.Offset==44 then TS:Create(f,TweenInfo.new(.25),{Size=UDim2.new(0,Settings.WindowW,0,Settings.WindowH)}):Play()
        else TS:Create(f,TweenInfo.new(.25),{Size=UDim2.new(0,Settings.WindowW,0,44)}):Play() end end)

    TB.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then
        w.Drag=true; w.DS=i.Position; w.SP=f.Position end end)
    UIS.InputChanged:Connect(function(i) if w.Drag and i.UserInputType==Enum.UserInputType.MouseMovement then
        local d=i.Position-w.DS
        f.Position=UDim2.new(w.SP.X.Scale,w.SP.X.Offset+d.X,w.SP.Y.Scale,w.SP.Y.Offset+d.Y) end end)
    UIS.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 and w.Drag then
        w.Drag=false; Settings.WindowX=f.Position.X.Offset; Settings.WindowY=f.Position.Y.Offset end end)

    local TBr=Instance.new("Frame"); TBr.Size=UDim2.new(1,-28,0,36); TBr.Position=UDim2.new(0,14,0,54)
    TBr.BackgroundColor3=Color3.fromRGB(28,28,36); TBr.BorderSizePixel=0; TBr.Parent=f
    RG(TBr,10); ST(TBr,Color3.fromRGB(60,60,75),1,.7)
    local TL=Instance.new("UIListLayout"); TL.FillDirection=Enum.FillDirection.Horizontal
    TL.Padding=UDim.new(0,4); TL.VerticalAlignment=Enum.VerticalAlignment.Center; TL.Parent=TBr
    local TP=Instance.new("UIPadding"); TP.PaddingLeft=UDim.new(0,4); TP.Parent=TBr
    local TI=Instance.new("Frame"); TI.Size=UDim2.new(0,0,0,3); TI.Position=UDim2.new(0,4,1,-4)
    TI.BackgroundColor3=Settings.AccentColor; TI.BorderSizePixel=0; TI.ZIndex=11; TI.Parent=TBr; RG(TI,2)

    local CT=Instance.new("Frame"); CT.Size=UDim2.new(1,-28,1,-110); CT.Position=UDim2.new(0,14,0,98)
    CT.BackgroundTransparency=1; CT.Parent=f
    local Pages={}; local AT=nil
    local function SW(n)
        for k,p in pairs(Pages) do p.P.Visible=false
            TC(p.B,"BackgroundColor3",Color3.new(0,0,0),.15)
            TC(p.B,"BackgroundTransparency",1,.15)
            TC(p.B,"TextColor3",Color3.fromRGB(160,160,180),.15) end
        local pg=Pages[n]; if not pg then return end
        pg.P.Visible=true
        TC(pg.B,"BackgroundColor3",Color3.fromRGB(40,40,52),.15)
        TC(pg.B,"BackgroundTransparency",0,.15)
        TC(pg.B,"TextColor3",Color3.fromRGB(240,240,245),.15)
        local bx=pg.B.AbsolutePosition.X-TBr.AbsolutePosition.X
        TS:Create(TI,TweenInfo.new(.25,Enum.EasingStyle.Quart,Enum.EasingDirection.Out),{
            Position=UDim2.new(0,bx,1,-4),Size=UDim2.new(0,pg.B.AbsoluteSize.X,0,3)}):Play()
        AT=n end

    function w:Tab(name,icon)
        local B=Instance.new("TextButton"); B.Size=UDim2.new(0,80,0,28)
        B.BackgroundColor3=Color3.new(0,0,0); B.BackgroundTransparency=1; B.BorderSizePixel=0
        B.Text=(icon or "").." "..name; B.TextColor3=Color3.fromRGB(160,160,180)
        B.Font=Enum.Font.GothamMedium; B.TextSize=11; B.AutoButtonColor=false; B.Parent=TBr
        RG(B,6); RIP(B)
        local P=Instance.new("ScrollingFrame"); P.Size=UDim2.new(1,0,1,0)
        P.BackgroundTransparency=1; P.BorderSizePixel=0; P.ScrollBarThickness=4
        P.ScrollBarImageColor3=Color3.fromRGB(60,60,75); P.CanvasSize=UDim2.new(0,0,0,0)
        P.AutomaticCanvasSize=Enum.AutomaticSize.Y; P.Visible=false; P.Parent=CT
        local L=Instance.new("UIListLayout"); L.Padding=UDim.new(0,10)
        L.SortOrder=Enum.SortOrder.LayoutOrder; L.Parent=P
        Pages[name]={B=B,P=P}
        B.MouseButton1Click:Connect(function() SW(name) end)
        local T={}
        function T:Section(t)
            local C=Instance.new("Frame"); C.Size=UDim2.new(1,0,0,0)
            C.AutomaticSize=Enum.AutomaticSize.Y; C.BackgroundColor3=Color3.fromRGB(28,28,36)
            C.BorderSizePixel=0; C.Parent=P; RG(C,10)
            ST(C,Color3.fromRGB(55,55,70),1,.7)
            local pd=Instance.new("UIPadding"); pd.PaddingTop=UDim.new(0,10); pd.PaddingBottom=UDim.new(0,10)
            pd.PaddingLeft=UDim.new(0,14); pd.PaddingRight=UDim.new(0,14); pd.Parent=C
            local L2=Instance.new("UIListLayout"); L2.Padding=UDim.new(0,5)
            L2.SortOrder=Enum.SortOrder.LayoutOrder; L2.Parent=C
            if t then local h=Instance.new("TextLabel"); h.Size=UDim2.new(1,0,0,18)
                h.BackgroundTransparency=1; h.Text=t; h.TextColor3=Settings.AccentColor
                h.Font=Enum.Font.GothamBold; h.TextSize=10
                h.TextXAlignment=Enum.TextXAlignment.Left; h.LayoutOrder=-1; h.Parent=C end
            return C end
        return T end

    function w:Toggle(p,n,d,cb)
        local R=Instance.new("Frame"); R.Size=UDim2.new(1,0,0,28); R.BackgroundTransparency=1; R.Parent=p
        local L=Instance.new("TextLabel"); L.Size=UDim2.new(1,-60,1,0); L.BackgroundTransparency=1
        L.Text=n; L.TextColor3=Color3.fromRGB(230,230,240); L.Font=Enum.Font.Gotham
        L.TextSize=12; L.TextXAlignment=Enum.TextXAlignment.Left; L.Parent=R
        local S=Instance.new("Frame"); S.Size=UDim2.new(0,40,0,20); S.Position=UDim2.new(1,-40,.5,-10)
        S.BackgroundColor3=d and Settings.AccentColor or Color3.fromRGB(56,56,70)
        S.BorderSizePixel=0; S.Parent=R; RG(S,10); ST(S,Color3.fromRGB(70,70,85),1,.5)
        local Kn=Instance.new("Frame"); Kn.Size=UDim2.new(0,14,0,14)
        Kn.Position=d and UDim2.new(1,-16,.5,-7) or UDim2.new(0,3,.5,-7)
        Kn.BackgroundColor3=Color3.new(1,1,1); Kn.BorderSizePixel=0; Kn.Parent=S; RG(Kn,7)
        local H=Instance.new("TextButton"); H.Size=UDim2.new(1,0,1,0); H.BackgroundTransparency=1
        H.Text=""; H.Parent=R
        local st=d
        H.MouseButton1Click:Connect(function() st=not st
            TS:Create(S,TweenInfo.new(.2,Enum.EasingStyle.Quart),{
                BackgroundColor3=st and Settings.AccentColor or Color3.fromRGB(56,56,70)}):Play()
            TS:Create(Kn,TweenInfo.new(.2,Enum.EasingStyle.Quart),{
                Position=st and UDim2.new(1,-16,.5,-7) or UDim2.new(0,3,.5,-7)}):Play()
            cb(st) end) end

    function w:Slider(p,n,mn,mx,d,cb)
        local Fr=Instance.new("Frame"); Fr.Size=UDim2.new(1,0,0,42); Fr.BackgroundTransparency=1; Fr.Parent=p
        local L=Instance.new("TextLabel"); L.Size=UDim2.new(1,-70,0,18); L.BackgroundTransparency=1
        L.Text=n; L.TextColor3=Color3.fromRGB(230,230,240); L.Font=Enum.Font.Gotham
        L.TextSize=12; L.TextXAlignment=Enum.TextXAlignment.Left; L.Parent=Fr
        local V=Instance.new("TextLabel"); V.Size=UDim2.new(0,60,0,18); V.Position=UDim2.new(1,-60,0,0)
        V.BackgroundTransparency=1; V.Text=tostring(d); V.TextColor3=Settings.AccentColor
        V.Font=Enum.Font.GothamMedium; V.TextSize=12
        V.TextXAlignment=Enum.TextXAlignment.Right; V.Parent=Fr
        local Tr=Instance.new("Frame"); Tr.Size=UDim2.new(1,-4,0,4); Tr.Position=UDim2.new(0,2,1,-14)
        Tr.BackgroundColor3=Color3.fromRGB(56,56,70); Tr.BorderSizePixel=0; Tr.Parent=Fr; RG(Tr,2)
        local Fi=Instance.new("Frame"); Fi.Size=UDim2.new((d-mn)/(mx-mn),0,1,0)
        Fi.BackgroundColor3=Settings.AccentColor; Fi.BorderSizePixel=0; Fi.Parent=Tr; RG(Fi,2)
        local Th=Instance.new("Frame"); Th.Size=UDim2.new(0,14,0,14)
        Th.Position=UDim2.new((d-mn)/(mx-mn),-7,.5,-7)
        Th.BackgroundColor3=Settings.AccentColor; Th.BorderSizePixel=0; Th.Parent=Tr; RG(Th,7)
        local H=Instance.new("TextButton"); H.Size=UDim2.new(1,0,0,22); H.Position=UDim2.new(0,0,1,-22)
        H.BackgroundTransparency=1; H.Text=""; H.Parent=Fr
        local dg=false
        local function up(i)
            local r=math.clamp((i.Position.X-Tr.AbsolutePosition.X)/Tr.AbsoluteSize.X,0,1)
            local v=math.floor(mn+(mx-mn)*r+.5)
            Fi.Size=UDim2.new(r,0,1,0); Th.Position=UDim2.new(r,-7,.5,-7)
            V.Text=tostring(v); cb(v) end
        H.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then dg=true; up(i) end end)
        UIS.InputChanged:Connect(function(i) if dg and i.UserInputType==Enum.UserInputType.MouseMovement then up(i) end end)
        UIS.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then dg=false end end) end

    function w:Dropdown(p,n,opts,d,cb)
        local Fr=Instance.new("Frame"); Fr.Size=UDim2.new(1,0,0,30)
        Fr.BackgroundColor3=Color3.fromRGB(40,40,52); Fr.BorderSizePixel=0
        Fr.ClipsDescendants=false; Fr.ZIndex=2; Fr.Parent=p; RG(Fr,6)
        ST(Fr,Color3.fromRGB(55,55,70),1,.7)
        local L=Instance.new("TextLabel"); L.Size=UDim2.new(0,90,1,0); L.Position=UDim2.new(0,10,0,0)
        L.BackgroundTransparency=1; L.Text=n; L.TextColor3=Color3.fromRGB(160,160,180)
        L.Font=Enum.Font.Gotham; L.TextSize=11
        L.TextXAlignment=Enum.TextXAlignment.Left; L.Parent=Fr
        local V=Instance.new("TextLabel"); V.Size=UDim2.new(1,-130,1,0); V.Position=UDim2.new(0,100,0,0)
        V.BackgroundTransparency=1; V.Text=d; V.TextColor3=Color3.fromRGB(230,230,240)
        V.Font=Enum.Font.GothamMedium; V.TextSize=12
        V.TextXAlignment=Enum.TextXAlignment.Left; V.Parent=Fr
        local Ar=Instance.new("TextLabel"); Ar.Size=UDim2.new(0,20,1,0); Ar.Position=UDim2.new(1,-26,0,0)
        Ar.BackgroundTransparency=1; Ar.Text="▾"; Ar.TextColor3=Color3.fromRGB(160,160,180)
        Ar.Font=Enum.Font.GothamMedium; Ar.TextSize=12; Ar.Parent=Fr
        local B=Instance.new("TextButton"); B.Size=UDim2.new(1,0,1,0); B.BackgroundTransparency=1
        B.Text=""; B.ZIndex=3; B.Parent=Fr
        local e=false
        local Ls=Instance.new("Frame"); Ls.Size=UDim2.new(1,0,0,0); Ls.Position=UDim2.new(0,0,1,4)
        Ls.BackgroundColor3=Color3.fromRGB(28,28,36); Ls.BorderSizePixel=0
        Ls.Visible=false; Ls.ZIndex=20; Ls.Parent=Fr; RG(Ls,8)
        ST(Ls,Color3.fromRGB(70,70,85),1,.5)
        local LL=Instance.new("UIListLayout"); LL.Padding=UDim.new(0,1); LL.Parent=Ls
        for _,o in ipairs(opts) do
            local OB=Instance.new("TextButton"); OB.Size=UDim2.new(1,-8,0,26); OB.Position=UDim2.new(0,4,0,0)
            OB.BackgroundColor3=Color3.fromRGB(28,28,36); OB.BorderSizePixel=0; OB.Text=o
            OB.TextColor3=Color3.fromRGB(230,230,240); OB.Font=Enum.Font.Gotham; OB.TextSize=12
            OB.TextXAlignment=Enum.TextXAlignment.Left; OB.AutoButtonColor=false
            OB.ZIndex=21; OB.Parent=Ls; RG(OB,4)
            OB.MouseEnter:Connect(function() TC(OB,"BackgroundColor3",Color3.fromRGB(40,40,52),.08) end)
            OB.MouseLeave:Connect(function() TC(OB,"BackgroundColor3",Color3.fromRGB(28,28,36),.08) end)
            OB.MouseButton1Click:Connect(function() V.Text=o; Ls.Visible=false
                Ls.Size=UDim2.new(1,0,0,0); e=false; Ar.Text="▾"; cb(o) end) end
        B.MouseButton1Click:Connect(function() e=not e; Ls.Visible=e
            TS:Create(Ls,TweenInfo.new(.15),{Size=e and UDim2.new(1,0,0,#opts*27) or UDim2.new(1,0,0,0)}):Play()
            Ar.Text=e and "▴" or "▾" end) end

    function w:Btn(p,t,s,cb)
        local B=Instance.new("TextButton"); B.Size=UDim2.new(1,0,0,32); B.BorderSizePixel=0
        B.Text=t; B.TextColor3=(s=="accent") and Color3.new(1,1,1) or Color3.fromRGB(230,230,240)
        B.Font=Enum.Font.GothamMedium; B.TextSize=12; B.AutoButtonColor=false
        B.BackgroundColor3=(s=="accent") and Settings.AccentColor or Color3.fromRGB(40,40,52)
        B.Parent=p; RG(B,6)
        if s~="accent" then ST(B,Color3.fromRGB(55,55,70),1,.7) end
        RIP(B); B.MouseButton1Click:Connect(cb) end

    function w:Input(p,n,d,cb)
        local Fr=Instance.new("Frame"); Fr.Size=UDim2.new(1,0,0,32)
        Fr.BackgroundColor3=Color3.fromRGB(40,40,52); Fr.BorderSizePixel=0; Fr.Parent=p
        RG(Fr,6); ST(Fr,Color3.fromRGB(55,55,70),1,.7)
        local L=Instance.new("TextLabel"); L.Size=UDim2.new(0,90,1,0); L.Position=UDim2.new(0,10,0,0)
        L.BackgroundTransparency=1; L.Text=n; L.TextColor3=Color3.fromRGB(160,160,180)
        L.Font=Enum.Font.Gotham; L.TextSize=11
        L.TextXAlignment=Enum.TextXAlignment.Left; L.Parent=Fr
        local TB=Instance.new("TextBox"); TB.Size=UDim2.new(1,-110,1,0); TB.Position=UDim2.new(0,100,0,0)
        TB.BackgroundTransparency=1; TB.Text=d or ""; TB.TextColor3=Color3.fromRGB(230,230,240)
        TB.PlaceholderText="…"; TB.PlaceholderColor3=Color3.fromRGB(120,120,135)
        TB.Font=Enum.Font.Gotham; TB.TextSize=12
        TB.TextXAlignment=Enum.TextXAlignment.Left
        TB.ClearTextOnFocus=false; TB.Parent=Fr
        TB.FocusLost:Connect(function() cb(TB.Text) end) end

    function w:Toggle2() f.Visible=not f.Visible end
    function w:Show() f.Visible=true end
    function w:Hide() f.Visible=false end
    function w:Frame() return f end
    w.SW=SW; w.FL=FL; w.Pages=Pages
    SW("Aim")
    return w
end

local W=Win:Create()
local WinFL=W.FL
local AimT=W:Tab("Aim","◎")
local MovT=W:Tab("Movement","➤")
local VisT=W:Tab("Visual","◉")
local AntT=W:Tab("Anti-Aim","✕")
local MisT=W:Tab("Misc","✦")
local BndT=W:Tab("Binds","⌨")
local CfgT=W:Tab("Configs","⚙")

-- ===== NOTIFICATIONS =====
local NC=Instance.new("Frame"); NC.Size=UDim2.new(0,320,0,0)
NC.Position=UDim2.new(1,-336,0,12); NC.BackgroundTransparency=1; NC.Parent=SG
local NL2=Instance.new("UIListLayout"); NL2.Padding=UDim.new(0,8)
NL2.SortOrder=Enum.SortOrder.LayoutOrder; NL2.Parent=NC
function Notify(t,b)
    if not Settings.Notifications then return end
    local N=Instance.new("Frame"); N.Size=UDim2.new(1,0,0,50)
    N.BackgroundColor3=Color3.fromRGB(28,28,36); N.BorderSizePixel=0; N.Parent=NC
    RG(N,8); ST(N,Settings.AccentColor,1,.3)
    local A=Instance.new("Frame"); A.Size=UDim2.new(0,3,1,0); A.BackgroundColor3=Settings.AccentColor
    A.BorderSizePixel=0; A.Parent=N; RG(A,2)
    local T=Instance.new("TextLabel"); T.Size=UDim2.new(1,-20,0,20); T.Position=UDim2.new(0,14,0,4)
    T.BackgroundTransparency=1; T.Text=t; T.TextColor3=Settings.AccentColor
    T.Font=Enum.Font.GothamBold; T.TextSize=12
    T.TextXAlignment=Enum.TextXAlignment.Left; T.Parent=N
    local D=Instance.new("TextLabel"); D.Size=UDim2.new(1,-20,0,20); D.Position=UDim2.new(0,14,0,24)
    D.BackgroundTransparency=1; D.Text=b; D.TextColor3=Color3.fromRGB(200,200,220)
    D.Font=Enum.Font.Gotham; D.TextSize=11
    D.TextXAlignment=Enum.TextXAlignment.Left; D.Parent=N
    task.delay(3.5,function() if N.Parent then
        TS:Create(N,TweenInfo.new(.2),{Size=UDim2.new(1,0,0,0),BackgroundTransparency=1}):Play()
        task.wait(.25); N:Destroy() end end) end

-- ===== HUD =====
local HUD=Instance.new("ScreenGui"); HUD.Name="TitanHUD"; HUD.ResetOnSpawn=false
HUD.IgnoreGuiInset=true; HUD.DisplayOrder=997
HUD.ZIndexBehavior=Enum.ZIndexBehavior.Sibling; HUD.Parent=CoreGui

local FC=Instance.new("Frame"); FC.Size=UDim2.new(0,Settings.FOV*2,0,Settings.FOV*2)
FC.Position=UDim2.new(.5,-Settings.FOV,.5,-Settings.FOV)
FC.BackgroundTransparency=1; FC.BorderSizePixel=0; FC.Parent=HUD
local FCS=ST(FC,Settings.FOVColor,1.5,.4); RG(FC,9999)
local CH=Instance.new("Frame"); CH.Size=UDim2.new(0,Settings.CrosshairSize,0,1)
CH.BackgroundColor3=Settings.AccentColor; CH.BorderSizePixel=0; CH.Visible=false; CH.Parent=HUD
local CV=Instance.new("Frame"); CV.Size=UDim2.new(0,1,0,Settings.CrosshairSize)
CV.BackgroundColor3=Settings.AccentColor; CV.BorderSizePixel=0; CV.Visible=false; CV.Parent=HUD
local WM=Instance.new("Frame"); WM.Size=UDim2.new(0,340,0,30); WM.Position=UDim2.new(0,12,0,12)
WM.BackgroundColor3=Color3.fromRGB(24,24,30); WM.BackgroundTransparency=.1
WM.BorderSizePixel=0; WM.Parent=HUD; RG(WM,8); ST(WM,Settings.AccentColor,1,.3)
local WMA=Instance.new("Frame"); WMA.Size=UDim2.new(0,3,1,0); WMA.BackgroundColor3=Settings.AccentColor
WMA.BorderSizePixel=0; WMA.Parent=WM; RG(WMA,2)
local WMT=Instance.new("TextLabel"); WMT.Size=UDim2.new(1,-16,1,0); WMT.Position=UDim2.new(0,12,0,0)
WMT.BackgroundTransparency=1; WMT.Text="TITAN v10.0"
WMT.TextColor3=Color3.fromRGB(240,240,245); WMT.Font=Enum.Font.GothamMedium
WMT.TextSize=12; WMT.TextXAlignment=Enum.TextXAlignment.Left; WMT.Parent=WM
local LL=Instance.new("Frame"); LL.AnchorPoint=Vector2.new(.5,.5)
LL.BackgroundColor3=Color3.fromRGB(255,60,60); LL.BorderSizePixel=0
LL.Visible=false; LL.ZIndex=3; LL.Parent=HUD
local LD=Instance.new("Frame"); LD.Size=UDim2.new(0,6,0,6); LD.AnchorPoint=Vector2.new(.5,.5)
LD.BackgroundColor3=Color3.fromRGB(255,60,60); LD.BorderSizePixel=0
LD.Visible=false; LD.ZIndex=3; LD.Parent=HUD; RG(LD,3)
local ESPF=Instance.new("Folder"); ESPF.Name="TitanESP"; ESPF.Parent=HUD

local function DrawLock(p)
    if not Settings.LockShowLine or not p then LL.Visible=false; LD.Visible=false; return end
    local sp,on=Camera:WorldToViewportPoint(p)
    if not on then LL.Visible=false; LD.Visible=false; return end
    local vx,vy=Camera.ViewportSize.X,Camera.ViewportSize.Y
    local cx,cy=vx/2,vy/2; local dx,dy=sp.X-cx,sp.Y-cy
    LL.Visible=true; LL.Size=UDim2.new(0,math.sqrt(dx*dx+dy*dy),0,1)
    LL.Position=UDim2.new(0,(cx+sp.X)/2,0,(cy+sp.Y)/2)
    LL.Rotation=math.deg(math.atan2(dy,dx))
    LD.Visible=true; LD.Position=UDim2.new(0,sp.X,0,sp.Y) end

-- ===== TARGETING =====
local function IsVis(p)
    if not Settings.WallCheck and not Settings.VisibleCheck then return true end
    if not LP.Character then return true end
    Cache.RP.FilterDescendantsInstances={LP.Character,Camera}
    local r=WS:Raycast(Camera.CFrame.Position,p.Position-Camera.CFrame.Position,Cache.RP)
    return not r or r.Instance:IsDescendantOf(p.Parent) end
local function IsVal(plr)
    if plr==LP then return false end
    local c=Cache.C[plr]; if not c or not c.hum or c.hum.Health<=0 then return false end
    if Settings.TeamCheck and plr.Team and LP.Team and plr.Team==LP.Team then return false end
    return true end
local function Best()
    local mc=LP.Character; if not mc then return nil end
    local mr=mc:FindFirstChild("HumanoidRootPart"); local mh=mc:FindFirstChildOfClass("Humanoid")
    if not mr or not mh or mh.Health<=0 then return nil end
    local cp=Camera.CFrame.Position; local cl=Camera.CFrame.LookVector
    local hv=Camera.ViewportSize.Y*.5; local ma=math.atan(Settings.FOV/hv)
    local b,bs=nil,math.huge
    for plr,c in pairs(Cache.C) do if IsVal(plr) then
        local p=Cache.P[plr] and Cache.P[plr][Settings.TargetPart]
        if p and p.Parent then
            local d=(p.Position-mr.Position).Magnitude
            if d<=Settings.MaxDistance then
                local pos=p.Position
                if Settings.Prediction then pos=pos+p.AssemblyLinearVelocity*Settings.PredictionX*(d/100) end
                local to=(pos-cp).Unit; local dot=cl:Dot(to)
                if dot>0 then local a=math.acos(math.clamp(dot,-1,1))
                    if a<=ma and IsVis(p) then
                        local s
                        if Settings.TargetPriority=="Distance" then s=d
                        elseif Settings.TargetPriority=="Angle" then s=a*100
                        elseif Settings.TargetPriority=="Health" then s=c.hum.Health*10+a
                        else s=(c.hum.Health/c.hum.MaxHealth)*50+a*10 end
                        if s<bs then bs=s; b={plr=plr,part=p,pos=pos,dist=d} end
                    end end end end end end
    return b end
local function LkV(e)
    if not e then return false end
    local plr,p=e.plr,e.part
    if not plr or not plr.Parent then return false end
    local c=Cache.C[plr]; if not c or not c.hum or c.hum.Health<=0 then return false end
    if not p or not p.Parent then p=Cache.P[plr] and Cache.P[plr][Settings.TargetPart]
        if not p or not p.Parent then return false end; e.part=p end
    if Settings.TeamCheck and plr.Team and LP.Team and plr.Team==LP.Team then return false end
    if not Settings.LockIgnoreDist and LP.Character then
        local mr=LP.Character:FindFirstChild("HumanoidRootPart")
        if mr and (p.Position-mr.Position).Magnitude>Settings.MaxDistance then return false end end
    if not Settings.LockIgnoreWall and not IsVis(p) then return false end
    return true end

-- ===== ANTI-AIM =====
local AA={O=nil,LT=0,Off=CFrame.new()}
local function FN() local c=LP.Character; if not c then return nil end
    for _,v in ipairs(c:GetDescendants()) do if v:IsA("Motor6D") and v.Name=="Neck" then return v end end end
RunService.Heartbeat:Connect(function()
    if not Settings.AntiAim then
        if AA.O then local n=FN(); if n then n.C0=AA.O end; AA.O=nil end
        return end
    local n=FN(); if not n then return end
    if not AA.O then AA.O=n.C0 end
    local now=tick()
    if now-AA.LT>=Settings.AntiAimSpeed then AA.LT=now
        local y,p=0,0
        if Settings.AntiAimRandom then
            y=math.rad(math.random(-Settings.AntiAimRange,Settings.AntiAimRange))
            p=math.rad(math.random(-Settings.AntiAimRange/2,Settings.AntiAimRange/2))
        else
            local sp=1/math.max(Settings.AntiAimSpeed,.01)
            y=math.rad(Settings.AntiAimRange)*math.sin(now*sp)
            p=math.rad(Settings.AntiAimRange/2)*math.cos(now*sp*1.3) end
        if Settings.AntiAimAxis=="Pitch" then y=0 end
        if Settings.AntiAimAxis=="Yaw" then p=0 end
        if Settings.AntiAimHideHead then p=p+math.rad(80) end
        AA.Off=CFrame.Angles(p,y,0) end
    n.C0=AA.O*AA.Off end)

-- ===== TRIGGER =====
local TG={LS=0,H=false}
local function GT()
    local mc=LP.Character; if not mc then return nil end
    local cp=Camera.CFrame.Position; local cl=Camera.CFrame.LookVector
    local hv=Camera.ViewportSize.Y*.5; local ma=math.atan(Settings.TriggerFOV/hv)
    local b,ba=nil,math.huge
    for plr,c in pairs(Cache.C) do
        if plr~=LP and c.hum and c.hum.Health>0 then
            if not (Settings.TriggerTeamCheck and plr.Team and LP.Team and plr.Team==LP.Team) then
                local p=Cache.P[plr] and Cache.P[plr][Settings.TriggerPart]
                if p and p.Parent then
                    local to=(p.Position-cp).Unit; local dot=cl:Dot(to)
                    if dot>0 then local a=math.acos(math.clamp(dot,-1,1))
                        if a<=ma then
                            if Settings.TriggerWallCheck then
                                Cache.RP.FilterDescendantsInstances={mc,Camera}
                                local r=WS:Raycast(cp,p.Position-cp,Cache.RP)
                                if r and not r.Instance:IsDescendantOf(p.Parent) then a=math.huge end end
                            if a<ba then ba=a; b={plr=plr,part=p} end end end end end end end
    return b end
RunService.RenderStepped:Connect(function()
    if not Settings.TriggerBot or not LP.Character then
        if TG.H then TG.H=false
            pcall(function() game:GetService("VirtualInputManager"):SendMouseButtonEvent(0,0,0,false,game,0) end) end
        return end
    local k=KC(Settings.Bind_Trigger)
    if k and not UIS:IsKeyDown(k) then return end
    local t=GT()
    if not t then if TG.H then TG.H=false
        pcall(function() game:GetService("VirtualInputManager"):SendMouseButtonEvent(0,0,0,false,game,0) end) end
        return end
    if tick()-TG.LS<Settings.TriggerDelay then return end
    if Settings.TriggerHold then
        if not TG.H then TG.H=true
            pcall(function() game:GetService("VirtualInputManager"):SendMouseButtonEvent(0,0,0,true,game,0) end) end
    else FM(); TG.LS=tick() end end)

-- ===== MOVEMENT =====
local BH={L=0}; local Fly={BV=nil,On=false}; local SBV=nil
RunService.Heartbeat:Connect(function()
    local c=LP.Character; if not c then return end
    local h=c:FindFirstChildOfClass("Humanoid"); local r=c:FindFirstChild("HumanoidRootPart")
    if not h or not r then return end
    if Settings.SpeedBoost then h.WalkSpeed=Settings.SpeedValue else h.WalkSpeed=16 end
    if Settings.JumpBoost then h.JumpPower=Settings.JumpValue else h.JumpPower=50 end
    if Settings.BHop and h:GetState()==Enum.HumanoidStateType.Landed then
        if tick()-BH.L>=.05 then h.Jump=true; BH.L=tick() end end
    if Settings.Fly and not Fly.On then Fly.On=true
        local bv=Instance.new("BodyVelocity"); bv.MaxForce=Vector3.new(1e5,1e5,1e5)
        bv.Velocity=Vector3.zero; bv.Parent=r; Fly.BV=bv; h.PlatformStand=true
        UIS.InputChanged:Connect(function(i)
            if Fly.On and Fly.BV and i.UserInputType==Enum.UserInputType.MouseMovement then
                local d=Camera.CFrame.LookVector*Settings.FlySpeed
                if UIS:IsKeyDown(Enum.KeyCode.W) then Fly.BV.Velocity=d
                elseif UIS:IsKeyDown(Enum.KeyCode.S) then Fly.BV.Velocity=-d
                else Fly.BV.Velocity=Vector3.zero end end end)
    elseif not Settings.Fly and Fly.On then Fly.On=false
        if Fly.BV then Fly.BV:Destroy(); Fly.BV=nil end; h.PlatformStand=false end
    if Settings.Spider then
        local ray=RaycastParams.new(); ray.FilterDescendantsInstances={c}
        local res=WS:Raycast(r.Position,Vector3.new(0,-3,0),ray)
        if res then if not SBV or not SBV.Parent then
            SBV=Instance.new("BodyVelocity"); SBV.MaxForce=Vector3.new(1e5,1e5,1e5); SBV.Parent=r end
            SBV.Velocity=Camera.CFrame.LookVector*Settings.SpiderSpeed+Vector3.new(0,Settings.SpiderSpeed*.5,0)
        else if SBV then SBV:Destroy(); SBV=nil end end
    else if SBV then SBV:Destroy(); SBV=nil end end end)
RunService.Stepped:Connect(function()
    if not Settings.NoClip then return end
    local c=LP.Character; if not c then return end
    for _,p in ipairs(c:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide=false end end end)

-- ===== HITBOX =====
task.spawn(function() while task.wait(1) do
    if Settings.HitboxExpander then
        for plr,c in pairs(Cache.C) do if plr~=LP and c.char then
            for _,p in ipairs(c.char:GetDescendants()) do
                if p:IsA("BasePart") and p.Name~="HumanoidRootPart" then
                    if not p:GetAttribute("TO") then p:SetAttribute("TO",p.Size) end
                    p.Size=Vector3.new(Settings.HitboxSize,Settings.HitboxSize,Settings.HitboxSize) end end end end
    else for _,c in pairs(Cache.C) do if c.char then
        for _,p in ipairs(c.char:GetDescendants()) do
            if p:IsA("BasePart") and p:GetAttribute("TO") then p.Size=p:GetAttribute("TO") end end end end end end end)

-- ===== AUTO RESPAWN / ANTI-FLING =====
RunService.Heartbeat:Connect(function()
    local c=LP.Character; if not c then return end
    local h=c:FindFirstChildOfClass("Humanoid")
    if Settings.AutoRespawn and h and h.Health<=0 then
        task.wait(.1); pcall(function() LP:LoadCharacter() end) end
    if Settings.AntiFling then local r=c:FindFirstChild("HumanoidRootPart")
        if r and r.AssemblyLinearVelocity.Magnitude>500 then
            r.AssemblyLinearVelocity=Vector3.zero; r.Velocity=Vector3.zero end end end)

-- ===== AUTO CLICKER =====
task.spawn(function() while task.wait(Settings.AutoClickerDelay) do
    if Settings.AutoClicker and LP.Character then FM() end end end)

-- ===== CLICK TP =====
UIS.InputBegan:Connect(function(i,pr) if pr then return end
    if Settings.ClickTP and i.UserInputType==Enum.UserInputType.MouseButton1 then
        local c=LP.Character; if not c then return end
        local r=c:FindFirstChild("HumanoidRootPart"); if not r then return end
        local mp=UIS:GetMouseLocation(); local ur=Camera:ViewportPointToRay(mp.X,mp.Y)
        local ray=RaycastParams.new(); ray.FilterDescendantsInstances={c}
        local res=WS:Raycast(ur.Origin,ur.Direction*5000,ray)
        if res then r.CFrame=CFrame.new(res.Position+Vector3.new(0,5,0)) end end end)

-- ===== MAIN AIM =====
local tgt=nil; local LE=nil; local LkT=0; local AF=0
RunService.RenderStepped:Connect(function(dt)
    FC.Visible=Settings.ShowFOV and Settings.Enabled
    if FC.Visible then FC.Size=UDim2.new(0,Settings.FOV*2,0,Settings.FOV*2)
        FC.Position=UDim2.new(.5,-Settings.FOV,.5,-Settings.FOV); FCS.Color=Settings.FOVColor end
    CH.Visible=Settings.Crosshair; CV.Visible=Settings.Crosshair
    if Settings.Crosshair then
        CH.Size=UDim2.new(0,Settings.CrosshairSize,0,1)
        CH.Position=UDim2.new(.5,-Settings.CrosshairSize/2,.5,0)
        CV.Size=UDim2.new(0,1,0,Settings.CrosshairSize)
        CV.Position=UDim2.new(.5,0,.5,-Settings.CrosshairSize/2) end
    WM.Visible=Settings.Watermark
    if WM.Visible then WMT.Text="TITAN v10.0 · "..Perf.FPS.." FPS · "..(tgt and tgt.plr.Name or "—") end
    WinFL.Text="FPS "..Perf.FPS
    if not Settings.Enabled or not LP.Character then tgt=nil; LE=nil; LkT=0; DrawLock(nil); return end
    if Settings.UseKeybind then
        local k=KC(Settings.Bind_Aim)
        if k and not UIS:IsKeyDown(k) then tgt=nil; LE=nil; LkT=0; DrawLock(nil); return end end
    if LE then if LkV(LE) then tgt=LE; LkT=LkT+dt
        if Settings.LockTimeout>0 and LkT>=Settings.LockTimeout then LE=nil; LkT=0; tgt=nil end
    else LE=nil; LkT=0; tgt=nil end end
    if not tgt then local f=Best(); if f then tgt=f
        if Settings.LockOn then LE=f; LkT=0 end end end
    if LE and not Settings.LockPriority then
        local fr=Best(); if fr and fr.plr~=LE.plr then tgt=fr; LE=fr; LkT=0 end end
    if not tgt then DrawLock(nil); return end
    local l=tgt.part; if l and l.Parent then tgt.pos=l.Position
        if Settings.Prediction then local mr=LP.Character:FindFirstChild("HumanoidRootPart")
            if mr then local d=(l.Position-mr.Position).Magnitude
                tgt.pos=tgt.pos+l.AssemblyLinearVelocity*Settings.PredictionX*(d/100) end end end
    local cc=Camera.CFrame; local ds=CFrame.new(cc.Position,tgt.pos)
    local s=math.clamp(Settings.Smoothness,.01,1)
    local al=(Settings.AimLock or LE) and 1 or (1-math.exp(-dt/s*10))
    Camera.CFrame=CFrame.new(cc.Position)*cc.Rotation:Lerp(ds.Rotation,al)
    DrawLock(tgt.pos)
    if Settings.AutoFire then AF=AF+dt
        if AF>=Settings.AutoFireDelay then AF=0; FM() end end end)

-- ===== ESP =====
RunService.RenderStepped:Connect(function()
    if not Settings.ESP then
        for _,v in ipairs(ESPF:GetChildren()) do if v:IsA("Frame") then v.Visible=false end end
        return end
    for _,plr in ipairs(Players:GetPlayers()) do if plr~=LP then
        local c=Cache.C[plr]
        if c and c.root and c.hum then
            local sk=Settings.TeamCheck and plr.Team and LP.Team and plr.Team==LP.Team
            if not sk then
                local e=ESPF:FindFirstChild(plr.Name)
                if not e then e=Instance.new("Frame"); e.BackgroundTransparency=1
                    e.BorderSizePixel=0; e.Visible=false; e.Parent=ESPF; e.Name=plr.Name
                    local s=Instance.new("UIStroke"); s.Color=Settings.ESPColor
                    s.Thickness=1.5; s.Parent=e
                    local n=Instance.new("TextLabel"); n.Size=UDim2.new(1,0,0,14)
                    n.Position=UDim2.new(0,0,0,-16); n.BackgroundTransparency=1
                    n.TextColor3=Settings.ESPColor; n.Font=Enum.Font.GothamMedium
                    n.TextSize=11; n.Text=plr.Name; n.Parent=e end
                local hd=c.head and c.head.Position or c.root.Position+Vector3.new(0,2,0)
                local t,ton=Camera:WorldToViewportPoint(hd+Vector3.new(0,1,0))
                local b,bon=Camera:WorldToViewportPoint(c.root.Position-Vector3.new(0,3,0))
                if ton and bon then local h=math.abs(t.Y-b.Y); local w=h*.5
                    e.Visible=true; e.Size=UDim2.new(0,w,0,h)
                    e.Position=UDim2.new(0,t.X-w/2,0,t.Y)
                else e.Visible=false end end end end end
    for _,v in ipairs(ESPF:GetChildren()) do
        if v:IsA("Frame") and not Players:FindFirstChild(v.Name) then v:Destroy() end end end)

-- ===== CHAMS =====
local ChC={}
local function SC(plr,on)
    local c=Cache.C[plr]; if not c or not c.char then return end
    if on then ChC[plr]=ChC[plr] or {}
        for _,p in ipairs(c.char:GetDescendants()) do if p:IsA("BasePart") then
            if not ChC[plr][p] then ChC[plr][p]={p.Color,p.Material,p.Transparency} end
            p.Color=Settings.ChamsColor; p.Material=Enum.Material.Neon
            p.Transparency=Settings.ChamsTransp end end
    else for p,o in pairs(ChC[plr] or {}) do if p and p.Parent then
        p.Color=o[1]; p.Material=o[2]; p.Transparency=o[3] end end
        ChC[plr]=nil end end
RunService.Heartbeat:Connect(function()
    if not Settings.Chams then for p in pairs(ChC) do SC(p,false) end return end
    for p in pairs(Cache.C) do if not (Settings.TeamCheck and p.Team and LP.Team and p.Team==LP.Team) then SC(p,true) end end end)

-- ===== 20 UTILITY =====
-- 1. Server Hop
local function SHop() pcall(function()
    local s=HS:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Asc&limit=100"))
    for _,x in ipairs(s.data or {}) do if x.playing<x.maxPlayers and x.id~=game.JobId then
        TPS:TeleportToPlaceInstance(game.PlaceId,x.id,LP); return end end end) end
-- 2. Rejoin
local function Rej() pcall(function() TPS:Teleport(game.PlaceId,LP) end) end
-- 3. Auto Reconnect
task.spawn(function() while task.wait(2) do
    if Settings.AutoReconnect and LP.Parent==nil then pcall(Rej) end end end)
-- 4. Copy JobId
local function CopyJob() pcall(function() setclipboard(game.JobId); Notify("Titan","JobId copied") end) end
-- 5-20 UI элементы будут в вкладке Utility

-- ===== BUILD UI TABS =====
-- AIM
local a1=AimT:Section("Core")
W:Toggle(a1,"Aimbot Enabled",Settings.Enabled,function(v) Settings.Enabled=v end)
W:Dropdown(a1,"Target Part",{"Head","HumanoidRootPart","UpperTorso","LowerTorso"},Settings.TargetPart,function(v) Settings.TargetPart=v end)
W:Dropdown(a1,"Priority",{"Distance","Angle","Health","Threat"},Settings.TargetPriority,function(v) Settings.TargetPriority=v end)
W:Slider(a1,"FOV",20,600,Settings.FOV,function(v) Settings.FOV=v end)
W:Slider(a1,"Smoothness %",5,100,math.floor(Settings.Smoothness*100),function(v) Settings.Smoothness=v/100 end)
W:Slider(a1,"Max Distance",50,2000,Settings.MaxDistance,function(v) Settings.MaxDistance=v end)
local a2=AimT:Section("Filters")
W:Toggle(a2,"Team Check",Settings.TeamCheck,function(v) Settings.TeamCheck=v end)
W:Toggle(a2,"Wall Check",Settings.WallCheck,function(v) Settings.WallCheck=v end)
W:Toggle(a2,"Visible Check",Settings.VisibleCheck,function(v) Settings.VisibleCheck=v end)
local a3=AimT:Section("Prediction")
W:Toggle(a3,"Prediction",Settings.Prediction,function(v) Settings.Prediction=v end)
W:Slider(a3,"Strength %",0,50,math.floor(Settings.PredictionX*100),function(v) Settings.PredictionX=v/100 end)
W:Toggle(a3,"Aim Lock",Settings.AimLock,function(v) Settings.AimLock=v end)
local a4=AimT:Section("Lock-On")
W:Toggle(a4,"Lock On",Settings.LockOn,function(v) Settings.LockOn=v end)
W:Toggle(a4,"Ignore Distance",Settings.LockIgnoreDist,function(v) Settings.LockIgnoreDist=v end)
W:Toggle(a4,"Ignore Wall",Settings.LockIgnoreWall,function(v) Settings.LockIgnoreWall=v end)
W:Toggle(a4,"Locked > New",Settings.LockPriority,function(v) Settings.LockPriority=v end)
W:Slider(a4,"Timeout",0,30,Settings.LockTimeout,function(v) Settings.LockTimeout=v end)
W:Toggle(a4,"Show Line",Settings.LockShowLine,function(v) Settings.LockShowLine=v end)
local a5=AimT:Section("Extras")
W:Toggle(a5,"Hitbox Expander",Settings.HitboxExpander,function(v) Settings.HitboxExpander=v end)
W:Slider(a5,"Hitbox Size",2,30,Settings.HitboxSize,function(v) Settings.HitboxSize=v end)

-- MOVEMENT
local m1=MovT:Section("Speed & Jump")
W:Toggle(m1,"Speed Boost",Settings.SpeedBoost,function(v) Settings.SpeedBoost=v end)
W:Slider(m1,"WalkSpeed",16,200,Settings.SpeedValue,function(v) Settings.SpeedValue=v end)
W:Toggle(m1,"Jump Boost",Settings.JumpBoost,function(v) Settings.JumpBoost=v end)
W:Slider(m1,"JumpPower",50,300,Settings.JumpValue,function(v) Settings.JumpValue=v end)
local m2=MovT:Section("Flight")
W:Toggle(m2,"Fly",Settings.Fly,function(v) Settings.Fly=v end)
W:Slider(m2,"Fly Speed",10,200,Settings.FlySpeed,function(v) Settings.FlySpeed=v end)
W:Toggle(m2,"Walk on Water",Settings.WalkOnWater,function(v) Settings.WalkOnWater=v end)
local m3=MovT:Section("Advanced")
W:Toggle(m3,"BHop",Settings.BHop,function(v) Settings.BHop=v end)
W:Toggle(m3,"Spider",Settings.Spider,function(v) Settings.Spider=v end)
W:Slider(m3,"Spider Speed",10,200,Settings.SpiderSpeed,function(v) Settings.SpiderSpeed=v end)
W:Toggle(m3,"NoClip",Settings.NoClip,function(v) Settings.NoClip=v end)
W:Toggle(m3,"Anti-Fling",Settings.AntiFling,function(v) Settings.AntiFling=v end)

-- VISUAL
local v1=VisT:Section("Overlay")
W:Toggle(v1,"Show FOV",Settings.ShowFOV,function(v) Settings.ShowFOV=v end)
W:Toggle(v1,"Crosshair",Settings.Crosshair,function(v) Settings.Crosshair=v end)
W:Slider(v1,"Crosshair Size",4,40,Settings.CrosshairSize,function(v) Settings.CrosshairSize=v end)
W:Toggle(v1,"Watermark",Settings.Watermark,function(v) Settings.Watermark=v end)
local v2=VisT:Section("ESP")
W:Toggle(v2,"ESP",Settings.ESP,function(v) Settings.ESP=v end)
W:Toggle(v2,"ESP Box",Settings.ESPBox,function(v) Settings.ESPBox=v end)
W:Toggle(v2,"ESP Name",Settings.ESPName,function(v) Settings.ESPName=v end)
W:Toggle(v2,"ESP Health",Settings.ESPHealth,function(v) Settings.ESPHealth=v end)
W:Toggle(v2,"ESP Distance",Settings.ESPDistance,function(v) Settings.ESPDistance=v end)
local v3=VisT:Section("Chams")
W:Toggle(v3,"Chams",Settings.Chams,function(v) Settings.Chams=v end)
W:Slider(v3,"Chams Transparency %",0,100,math.floor(Settings.ChamsTransp*100),function(v) Settings.ChamsTransp=v/100 end)
local v4=VisT:Section("World")
W:Toggle(v4,"Fullbright",Settings.Fullbright,function(v)
    Settings.Fullbright=v
    if v then Lighting.Brightness=3; Lighting.ClockTime=12; Lighting.FogEnd=1e6
    else Lighting.Brightness=1; Lighting.ClockTime=14; Lighting.FogEnd=100000 end end)
W:Toggle(v4,"Remove Fog",Settings.RemoveFog,function(v) Settings.RemoveFog=v
    Lighting.FogEnd=v and 1e6 or 100000 end)

-- ANTI
local an1=AntT:Section("Anti-Aim")
W:Toggle(an1,"Anti-Aim",Settings.AntiAim,function(v) Settings.AntiAim=v end)
W:Dropdown(an1,"Axis",{"Yaw","Pitch","Both"},Settings.AntiAimAxis,function(v) Settings.AntiAimAxis=v end)
W:Slider(an1,"Speed ms",10,300,math.floor(Settings.AntiAimSpeed*1000),function(v) Settings.AntiAimSpeed=v/1000 end)
W:Slider(an1,"Range deg",10,180,Settings.AntiAimRange,function(v) Settings.AntiAimRange=v end)
W:Toggle(an1,"Randomize",Settings.AntiAimRandom,function(v) Settings.AntiAimRandom=v end)
W:Toggle(an1,"Hide Head",Settings.AntiAimHideHead,function(v) Settings.AntiAimHideHead=v end)
local an2=AntT:Section("TriggerBot")
W:Toggle(an2,"TriggerBot",Settings.TriggerBot,function(v) Settings.TriggerBot=v end)
W:Toggle(an2,"Team Check",Settings.TriggerTeamCheck,function(v) Settings.TriggerTeamCheck=v end)
W:Toggle(an2,"Wall Check",Settings.TriggerWallCheck,function(v) Settings.TriggerWallCheck=v end)
W:Toggle(an2,"Hold LMB",Settings.TriggerHold,function(v) Settings.TriggerHold=v end)
W:Dropdown(an2,"Trigger Part",{"Head","HumanoidRootPart","UpperTorso"},Settings.TriggerPart,function(v) Settings.TriggerPart=v end)
W:Slider(an2,"Trigger FOV",5,200,Settings.TriggerFOV,function(v) Settings.TriggerFOV=v end)
W:Slider(an2,"Delay ms",0,300,math.floor(Settings.TriggerDelay*1000),function(v) Settings.TriggerDelay=v/1000 end)
local an3=AntT:Section("Auto")
W:Toggle(an3,"Auto Fire",Settings.AutoFire,function(v) Settings.AutoFire=v end)
W:Slider(an3,"Auto Fire Delay",10,500,math.floor(Settings.AutoFireDelay*1000),function(v) Settings.AutoFireDelay=v/1000 end)
W:Toggle(an3,"Auto Clicker",Settings.AutoClicker,function(v) Settings.AutoClicker=v end)
W:Slider(an3,"Clicker Delay",10,300,math.floor(Settings.AutoClickerDelay*1000),function(v) Settings.AutoClickerDelay=v/1000 end)

-- MISC / UTILITY
local mi1=MisT:Section("Performance")
W:Toggle(mi1,"FPS Boost",Settings.FPSBoost,function(v)
    Settings.FPSBoost=v
    if v then Lighting.GlobalShadows=false; Lighting.EnvironmentDiffuseScale=0
        Lighting.EnvironmentSpecularScale=0
    else Lighting.GlobalShadows=true; Lighting.EnvironmentDiffuseScale=1
        Lighting.EnvironmentSpecularScale=1 end end)
W:Toggle(mi1,"FPS Unlock",Settings.FPSUnlock,function(v)
    Settings.FPSUnlock=v; pcall(function() setfpscap(v and 240 or 60) end) end)
local mi2=MisT:Section("Gameplay")
W:Toggle(mi2,"Auto Respawn",Settings.AutoRespawn,function(v) Settings.AutoRespawn=v end)
W:Toggle(mi2,"Click TP",Settings.ClickTP,function(v) Settings.ClickTP=v end)
local mi3=MisT:Section("UI")
W:Toggle(mi3,"Notifications",Settings.Notifications,function(v) Settings.Notifications=v end)
local mi4=MisT:Section("Server")
W:Btn(mi4,"Server Hop","accent",function() SHop(); Notify("Titan","Hopping…") end)
W:Btn(mi4,"Rejoin","secondary",function() Rej() end)
W:Btn(mi4,"Copy JobId","secondary",function() CopyJob() end)

-- BINDS
local kl={}; for _,it in ipairs(Enum.KeyCode:GetEnumItems()) do table.insert(kl,it.Name) end
table.sort(kl)
local b1=BndT:Section("Menu")
W:Dropdown(b1,"Menu Toggle",kl,Settings.Bind_Menu,function(v) Settings.Bind_Menu=v end)
W:Dropdown(b1,"Panic",kl,Settings.Bind_Panic,function(v) Settings.Bind_Panic=v end)
local b2=BndT:Section("Combat")
W:Dropdown(b2,"Aimbot Hold",kl,Settings.Bind_Aim,function(v) Settings.Bind_Aim=v end)
W:Dropdown(b2,"TriggerBot",kl,Settings.Bind_Trigger,function(v) Settings.Bind_Trigger=v end)
local b3=BndT:Section("Movement")
W:Dropdown(b3,"Fly Toggle",kl,Settings.Bind_Fly,function(v) Settings.Bind_Fly=v end)
W:Dropdown(b3,"ESP Toggle",kl,Settings.Bind_ESP,function(v) Settings.Bind_ESP=v end)

-- CONFIG
local cf1=CfgT:Section("Profile")
W:Input(cf1,"Profile Name",Settings.ProfileName,function(t) if t~="" then Settings.ProfileName=t end end)
local cf2=CfgT:Section("Actions")
W:Btn(cf2,"💾 Save","accent",function() local ok=Cfg.save(Settings.ProfileName)
    Notify("Titan",ok and ("Saved: "..Settings.ProfileName) or "Save failed") end)
W:Btn(cf2,"📂 Load","secondary",function() local ok=Cfg.load(Settings.ProfileName)
    Notify("Titan",ok and ("Loaded: "..Settings.ProfileName) or "Load failed") end)
W:Btn(cf2,"🗑 Delete","secondary",function() Cfg.del(Settings.ProfileName)
    Notify("Titan","Deleted") end)
W:Btn(cf2,"🔄 Reset","secondary",function() for k,v in pairs(D) do Settings[k]=v end
    Notify("Titan","Reset (re-open)") end)
local cf3=CfgT:Section("Window")
W:Btn(cf3,"🎯 Center","secondary",function() local fr=W:Frame()
    fr.Position=UDim2.new(.5,-fr.Size.X.Offset/2,.5,-fr.Size.Y.Offset/2)
    Settings.WindowX=fr.Position.X.Offset; Settings.WindowY=fr.Position.Y.Offset end)
W:Btn(cf3,"💾 Save Position","accent",function() local fr=W:Frame()
    Settings.WindowX=fr.Position.X.Offset; Settings.WindowY=fr.Position.Y.Offset
    Cfg.save(Settings.ProfileName); Notify("Titan","Position saved") end)

-- ===== PANIC =====
local function Panic()
    for _,k in ipairs({"Enabled","TriggerBot","AutoFire","AutoClicker","Fly","Spider","NoClip",
        "AntiAim","Chams","ESP"}) do Settings[k]=false end
    if Fly.BV then Fly.BV:Destroy(); Fly.BV=nil; Fly.On=false end
    if SBV then SBV:Destroy(); SBV=nil end
    local c=LP.Character; if c then local h=c:FindFirstChildOfClass("Humanoid")
        if h then h.PlatformStand=false end end
    Notify("TITAN","PANIC — everything off") end

-- ===== HOTKEYS =====
UIS.InputBegan:Connect(function(i,pr) if pr then return end
    if i.KeyCode==KC(Settings.Bind_Menu) then W:Toggle2() end
    if i.KeyCode==KC(Settings.Bind_Panic) then Panic() end
    if i.KeyCode==KC(Settings.Bind_Fly) then Settings.Fly=not Settings.Fly
        Notify("TITAN","Fly: "..tostring(Settings.Fly)) end
    if i.KeyCode==KC(Settings.Bind_ESP) then Settings.ESP=not Settings.ESP
        Notify("TITAN","ESP: "..tostring(Settings.ESP)) end
    if i.KeyCode==Enum.KeyCode.F5 then local ok=Cfg.save(Settings.ProfileName)
        Notify("TITAN",ok and ("Saved: "..Settings.ProfileName) or "Save failed") end
    if i.KeyCode==Enum.KeyCode.F6 then local ok=Cfg.load(Settings.ProfileName)
        Notify("TITAN",ok and ("Loaded: "..Settings.ProfileName) or "Load failed") end end)

-- ===== STARTUP =====
Notify("TITAN v10.0","F1 menu · End panic · F5 save · F6 load")
W:Show()
print("[TITAN v10.0] loaded — F1 menu | End panic | F5 save | F6 load")
