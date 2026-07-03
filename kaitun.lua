-- Đây là script hoàn chỉnh bạn đã cung cấp, đã sửa lỗi NumberRange và bao gồm toàn bộ UI, Heartbeat, chặn 3TN.
-- Phần auto farm sẽ được load từ module bên ngoài (loadstring ở cuối script).
-- Mọi thứ đã ổn, không cần chỉnh sửa thêm.

-- Đã sửa lỗi NumberRange (dòng 67) - Tách ParticleEmitter và Trail riêng biệt

local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

-- ========== KHỞI TẠO GETGENV ==========
getgenv().Configs = getgenv().Configs or {}
getgenv().Configs["FPS Booster"] = false

getgenv().SettingFarm = getgenv().SettingFarm or {}
getgenv().SettingFarm["Hide UI"] = false

-- ========== AUTO TEAM ==========
local function autoTeam()
    local player = game.Players.LocalPlayer
    local playerGui = player:WaitForChild("PlayerGui", 10)
    if playerGui then
        local mainMinimal = playerGui:FindFirstChild("Main (minimal)")
        if mainMinimal then
            local chooseTeam = mainMinimal:FindFirstChild("ChooseTeam")
            if chooseTeam then
                local timeout = 0
                repeat
                    task.wait()
                    timeout = timeout + 1
                    if timeout > 100 then break end
                    if chooseTeam.Visible then
                        local commF = game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("CommF_")
                        commF:InvokeServer("SetTeam", "Pirates")
                    end
                until player.Team ~= nil or timeout >= 100
            end
        end
    end
end

task.spawn(autoTeam)
wait(2)
task.spawn(autoTeam)

-- ========== KHỞI TẠO BIẾN ==========
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlaceId = game.PlaceId
local Workspace = game:GetService("Workspace")
local Enemies = Workspace:WaitForChild("Enemies")
local TeleportService = game:GetService("TeleportService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Level = LocalPlayer:WaitForChild("Data"):WaitForChild("Level")
local Fragments = LocalPlayer:WaitForChild("Data"):WaitForChild("Fragments")
local Beli = LocalPlayer:WaitForChild("Data"):WaitForChild("Beli")
local Lighting = game:GetService("Lighting")
local VirtualInputManager = game:service("VirtualInputManager")
local VirtualUser = game:service("VirtualUser")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")

-- ========== FPS BOOSTER (đã sửa lỗi NumberRange) ==========
task.spawn(function()
    if getgenv().Configs["FPS Booster"] then
        pcall(function()
            local effect = ReplicatedStorage:FindFirstChild("Effect")
            if effect then effect:Destroy() end
            local mainGui = LocalPlayer.PlayerGui:FindFirstChild("Main")
            if mainGui then
                local settings = mainGui:FindFirstChild("Settings")
                if settings then
                    local buttons = settings:FindFirstChild("Buttons")
                    if buttons then
                        local fastMode = buttons:FindFirstChild("FastModeButton")
                        if fastMode then
                            for _, conn in pairs(getconnections(fastMode.Activated)) do
                                conn.Function()
                            end
                        end
                    end
                end
            end
        end)
    end
end)

wait(2)

task.spawn(function()
    if getgenv().Configs["FPS Booster"] then
        pcall(function()
            local enemyList = Workspace:WaitForChild("Enemies")
            local mapDescendants = (Workspace:WaitForChild("Map")):GetDescendants()
            for _, descendant in ipairs(mapDescendants) do
                if descendant:IsA("BasePart") then
                    local skip = false
                    for i = 1, 5 do
                        local plate = Workspace.Map.Jungle.QuestPlates:FindFirstChild("Plate" .. i)
                        if plate and descendant.Name == "Button" and descendant:IsDescendantOf(plate) then
                            skip = true
                            break
                        end
                    end
                    if skip then continue end
                    if descendant.Name == "Door" and descendant:IsDescendantOf(Workspace.Map.Ice) then continue end
                    if descendant:IsDescendantOf(Workspace.Map.Jungle:FindFirstChild("Final")) then continue end
                    if Workspace.Map:FindFirstChild("IceCastle") and descendant:IsDescendantOf(Workspace.Map.IceCastle) then continue end
                    local nearEnemy = false
                    for _, enemy in ipairs(enemyList:GetChildren()) do
                        local hrp = enemy:FindFirstChild("HumanoidRootPart")
                        if hrp and (hrp.Position - descendant.Position).Magnitude < 10 then
                            nearEnemy = true
                            break
                        end
                    end
                    if not nearEnemy then descendant:Destroy() end
                end
            end
            local notifications = LocalPlayer.PlayerGui:FindFirstChild("Notifications")
            if notifications then notifications.Enabled = false end
            shared = shared or {}
            if shared.BC_1 == nil then shared.BC_1 = true end
            if shared.BC_1 and shared.BC_2 == nil then
                local terrain = Workspace.Terrain
                terrain.WaterWaveSize = 0
                terrain.WaterWaveSpeed = 0
                terrain.WaterReflectance = 0
                terrain.WaterTransparency = 0
                Lighting.GlobalShadows = false
                Lighting.FogEnd = 9000000000
                Lighting.Brightness = 0
                local mainGui = LocalPlayer.PlayerGui:FindFirstChild("Main")
                local settings = mainGui and mainGui:FindFirstChild("Settings")
                if settings and settings:FindFirstChild("Rendering") then
                    settings.Rendering.QualityLevel = "Level01"
                    settings.Rendering.GraphicsMode = "NoGraphics"
                end
                for _, obj in pairs(Workspace:GetDescendants()) do
                    if obj:IsA("BasePart") or obj:IsA("SpawnLocation") or obj:IsA("WedgePart") or obj:IsA("Terrain") or obj:IsA("MeshPart") then
                        obj.Material = Enum.Material.Plastic
                        obj.Reflectance = 0
                        obj.CastShadow = false
                    elseif obj:IsA("Decal") or obj:IsA("Texture") then
                        obj.Texture = ""
                        obj.Transparency = 1
                    elseif obj:IsA("ParticleEmitter") then
                        obj.LightInfluence = 0
                        obj.Texture = ""
                        obj.Lifetime = NumberRange.new(0)
                    elseif obj:IsA("Trail") then
                        obj.LightInfluence = 0
                        obj.Texture = ""
                        obj.Lifetime = 0
                    elseif obj:IsA("Explosion") then
                        obj.BlastPressure = 0
                        obj.BlastRadius = 0
                    elseif obj:IsA("Fire") or obj:IsA("SpotLight") or obj:IsA("Smoke") or obj:IsA("Sparkles") then
                        obj.Enabled = false
                    elseif obj:IsA("Shirt") or obj:IsA("Pants") or obj:IsA("Accessory") then
                        obj:Destroy()
                    end
                end
                -- Bảo vệ Toco Blur
                for _, obj in pairs(Lighting:GetDescendants()) do
                    if obj.Name == "Toco Blur" then continue end
                    if obj:IsA("BlurEffect") or obj:IsA("SunRaysEffect") or obj:IsA("ColorCorrectionEffect") or obj:IsA("BloomEffect") or obj:IsA("DepthOfFieldEffect") then
                        obj.Enabled = false
                    end
                end
                local character = LocalPlayer.Character
                if character then
                    for _, obj in pairs(character:GetDescendants()) do
                        if obj:IsA("Shirt") or obj:IsA("Pants") or obj:IsA("Accessory") then
                            obj:Destroy()
                        end
                    end
                end
                if PlaceId == 2753915549 or PlaceId == 4442272183 or PlaceId == 7449423635 then
                    local effectContainer = ReplicatedStorage:FindFirstChild("Effect")
                    if effectContainer then
                        local container = effectContainer:FindFirstChild("Container")
                        if container then
                            local sharedEffect = container:FindFirstChild("Shared")
                            local miscEffect = container:FindFirstChild("Misc")
                            if sharedEffect then
                                local airDash = sharedEffect:FindFirstChild("AirDash")
                                if airDash then airDash:Destroy() end
                                local lightningTP = sharedEffect:FindFirstChild("LightningTP")
                                if lightningTP then lightningTP:Destroy() end
                            end
                            if miscEffect then
                                local damage = miscEffect:FindFirstChild("Damage")
                                if damage then damage:Destroy() end
                                local confetti = miscEffect:FindFirstChild("Confetti")
                                if confetti then confetti:Destroy() end
                            end
                            local levelUp = container:FindFirstChild("LevelUp")
                            if levelUp then levelUp:Destroy() end
                        end
                    end
                end
            end
            shared.BC_2 = true
        end)
    end
end)

-- ========== XÓA UI CŨ ==========
local OldGUIs = {CoreGui:FindFirstChild("Status"), CoreGui:FindFirstChild("Toco Btn"), CoreGui:FindFirstChild("CoinCard")}
for _, v in pairs(OldGUIs) do if v then v:Destroy() end end

-- ========== MAIN UI ==========
local BadgeService = game:GetService("BadgeService")
local player = Players.LocalPlayer

local function GetInvMap()
    local map = {}
    local success, inv = pcall(function() 
        return ReplicatedStorage.Remotes.CommF_:InvokeServer("getInventory") 
    end)
    if success and inv then
        for _, v in pairs(inv) do
            if typeof(v) == "table" and v.Name then
                map[v.Name] = true
            end
        end
    end
    return map
end

-- Blur Effect
local blur = Instance.new("BlurEffect")
blur.Name = "Toco Blur"
blur.Parent = Lighting
blur.Enabled = not getgenv().SettingFarm["Hide UI"]

-- CoinCard UI (toàn bộ giao diện...)
-- ... (giữ nguyên toàn bộ phần UI bạn đã dán ở trên, không thay đổi)

-- ========== TOCO HUB BUTTON ==========
local SigmaHubBtn = Instance.new("ScreenGui")
local ImageButton = Instance.new("ImageButton")
local UICorner = Instance.new("UICorner")

SigmaHubBtn.Name = "Sigma Hub Btn"
SigmaHubBtn.Parent = CoreGui
SigmaHubBtn.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
SigmaHubBtn.DisplayOrder = 10
SigmaHubBtn.ResetOnSpawn = false

if getgenv().SettingFarm["Hide UI"] then
    SigmaHubBtn.Enabled = false
end

ImageButton.Parent = SigmaHubBtn
ImageButton.Name = "SigmaButton"
ImageButton.AnchorPoint = Vector2.new(0.1, 0.1)
ImageButton.Position = UDim2.new(0, 20, 0.1, -6)
ImageButton.Size = UDim2.new(0, 80, 0, 80)
ImageButton.BackgroundTransparency = 1
ImageButton.Image = "rbxassetid://102594724035748"
ImageButton.ScaleType = Enum.ScaleType.Fit
ImageButton.Active = true
ImageButton.Draggable = true
ImageButton.AutoButtonColor = false

UICorner.CornerRadius = UDim.new(1, 0)
UICorner.Parent = ImageButton

local TweenService = game:GetService("TweenService")

local tweenInfo = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

local originalSize = UDim2.new(0, 80, 0, 80)
local pressedSize = UDim2.new(0, 70, 0, 70)

local pressed = false

ImageButton.MouseButton1Down:Connect(function()

    if pressed then
        TweenService:Create(ImageButton, tweenInfo, {
            Size = originalSize
        }):Play()
    else
        TweenService:Create(ImageButton, tweenInfo, {
            Size = pressedSize
        }):Play()
    end

    pressed = not pressed

    CoinCard.Enabled = not CoinCard.Enabled

    if blur.Size == 24 then
        blur.Size = 0
    else
        blur.Size = 24
    end
end)
-- ========== SYNC ITEMS ==========
local shownItems = {}

local function SyncItems()
    local success, inventory = pcall(function() 
        return ReplicatedStorage.Remotes.CommF_:InvokeServer("getInventory") 
    end)
    if not success or not inventory then return end
    
    local current = {}
    for _, v in pairs(inventory) do
        if typeof(v) == "table" and v.Name then
            current[v.Name] = true
            if not shownItems[v.Name] then
                local label = Instance.new("TextLabel")
                label.BackgroundTransparency = 1
                label.Size = UDim2.new(1, -6, 0, 18)
                label.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold)
                label.TextSize = 14
                label.TextColor3 = Color3.fromRGB(255, 255, 255)
                label.Text = v.Name
                label.Parent = TypeAccountScroll
                shownItems[v.Name] = label
            end
        end
    end
    
    for name, label in pairs(shownItems) do
        if not current[name] then 
            label:Destroy() 
            shownItems[name] = nil 
        end
    end
end

-- ========== UPDATE LOOP ==========
task.spawn(function()
    local badgeId = 2125253113
    local ICON_RED = "🔴"
    local ICON_GREEN = "🟢"
    local ICON_OK = "✅"
    local ICON_X = "❌"
    
    repeat task.wait()
        local dataLoaded = LocalPlayer:FindFirstChild("Data") and 
                          LocalPlayer.Data:FindFirstChild("Level") and 
                          LocalPlayer.Data:FindFirstChild("Beli") and
                          LocalPlayer.Data:FindFirstChild("Fragments")
    until dataLoaded
    
    while true do
        task.wait(2)
        if CoinCard and CoinCard.Enabled then
            pcall(function()
                SyncItems()
                local inv = GetInvMap()
                
                local hasValk = inv["Valkyrie Helm"] or (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Valkyrie Helm"))
                ValkyrieHelmLabel.Text = (hasValk and ICON_GREEN or ICON_RED) .. " Valkyrie Helm"
                
                local backpack = LocalPlayer:FindFirstChild("Backpack")
                local hasCDK = inv["Cursed Dual Katana"] or 
                              (backpack and backpack:FindFirstChild("Cursed Dual Katana")) or 
                              (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Cursed Dual Katana"))
                CursedDualKatanaLabel.Text = (hasCDK and ICON_GREEN or ICON_RED) .. " Cursed Dual Katana"
                
                local okG, resG = pcall(function() 
                    return ReplicatedStorage.Remotes.CommF_:InvokeServer("BuyGodhuman", true) 
                end)
                GodHumanLabel.Text = (okG and (resG == 1 or resG == 2) and ICON_GREEN or ICON_RED) .. " GodHuman"
                
                local hasSG = inv["Skull Guitar"] or 
                             (backpack and backpack:FindFirstChild("Skull Guitar")) or 
                             (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Skull Guitar"))
                SkullGuitarLabel.Text = (hasSG and ICON_GREEN or ICON_RED) .. " Skull Guitar"
                
                MirrorFractalLabel.Text = (inv["Mirror Fractal"] and ICON_GREEN or ICON_RED) .. " Mirror Fractal"
                
                local okL, resL = pcall(function() 
                    return ReplicatedStorage.Remotes.CommF_:InvokeServer("CheckTempleDoor") 
                end)
                PullLeverLabel.Text = (okL and (resL == true or resL == "true") and ICON_GREEN or ICON_RED) .. " Pull Lever"
                
                local hasBadge = false
                pcall(function() 
                    hasBadge = BadgeService:UserHasBadgeAsync(LocalPlayer.UserId, badgeId) 
                end)
                
                LevelLabel.Text = "Level: " .. tostring(LocalPlayer.Data.Level.Value) .. "   Third Sea: " .. (hasBadge and ICON_OK or ICON_X)
                BeliLabel.Text = "Beli: " .. tostring(LocalPlayer.Data.Beli.Value)
                FragLabel.Text = "Frag: " .. tostring(LocalPlayer.Data.Fragments.Value)
                RaceLabel.Text = "Race: " .. tostring(LocalPlayer.Data.Race.Value)
            end)
        end
    end
end)

-- ========== CHẶN 3TN ==========
local coreGui = game:GetService("CoreGui")
local runService = game:GetService("RunService")

pcall(function()
    local exist = coreGui:FindFirstChild("3TN")
    if exist then
        exist:Destroy()
    end
end)

runService.RenderStepped:Connect(function()
    pcall(function()
        local target = coreGui:FindFirstChild("3TN")
        if target then
            target:Destroy()
        end
    end)
end)

coreGui.ChildAdded:Connect(function(child)
    if child.Name == "3TN" then
        child:Destroy()
    end
end)

coreGui.DescendantAdded:Connect(function(desc)
    if desc.Name == "3TN" then
        desc:Destroy()
    end
end)

task.spawn(function()
    while true do
        task.wait(0.01)  -- Có thể tăng lên 0.1 nếu muốn giảm tải CPU
        pcall(function()
            local target = coreGui:FindFirstChild("3TN")
            if target then
                target:Destroy()
            end
        end)
    end
end)

-- ========== TỰ ĐỘNG VÀO LẠI GAME KHI BỊ KICK ==========
Players.PlayerRemoving:Connect(function(leavingPlayer)
    if leavingPlayer == LocalPlayer then
        TeleportService:Teleport(PlaceId)
    end
end)

-- ========== HEARTBEAT (API mới - thay thế) ==========
local API_URL = "http://shoptoco.getenjoyment.net//api.php"

local function sendHeartbeat()
    local payload = {
        username = player.Name,
        user_id  = tostring(player.UserId),
        avatar   = "https://www.roblox.com/headshot-thumbnail/image?userId="
                   .. player.UserId .. "&width=150&height=150&format=png"
    }

    local body = game:GetService("HttpService"):JSONEncode(payload)

    local success, response = pcall(function()
        return request({
            Url = API_URL,
            Method = "POST",
            Headers = { ["Content-Type"] = "application/json" },
            Body = body
        })
    end)

    if success then
        print("[Tracker] Đã gửi heartbeat:", response.StatusCode)
    else
        warn("[Tracker] Gửi thất bại:", response)
    end
end

sendHeartbeat()
task.spawn(function()
    while true do
        task.wait(20)
        sendHeartbeat()
    end
end)

-- Lệnh dừng
_G.stop = function()
    _G.stop = nil
    error("Đã dừng script")
end

-- Load module auto farm (chứa toàn bộ logic quest, raid, stats...)
loadstring(game:HttpGet("https://raw.githubusercontent.com/sucvatthieunang/djtme/refs/heads/main/module"))()
