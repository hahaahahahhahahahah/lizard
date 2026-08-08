-- ============================================================
-- lizard | key-gated loader
-- Paste your Supabase config below, then obfuscate THIS file
-- and upload it as lizard.lua on GitHub.
-- Users only see this small loader; the real script is stored
-- server-side and only returned to valid licenses.
-- ============================================================

local SUPABASE_URL = "https://xpjwgqgnamfumisfejjq.supabase.co"  -- ex: https://abcdefgh.supabase.co
local ANON_KEY     = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InhwandncWduYW1mdW1pc2ZlampxIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODYxNDIwODgsImV4cCI6MjEwMTcxODA4OH0.vZyLaeu7NDhxC1r9e1XFr-oAgr_AO_fkY7q0VlEd0Wg"     -- ex: eyJhbGciOi...

-- ============================================================

local Players       = game:GetService("Players")
local HttpService   = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer   = Players.LocalPlayer
local UserId        = LocalPlayer.UserId

-- ---------- HTTP helper (compatible with all executors) ----------
local RequestFunc = nil
if syn and syn.request then
    RequestFunc = syn.request
elseif request then
    RequestFunc = request
elseif http_request then
    RequestFunc = http_request
elseif http and http.request then
    RequestFunc = http.request
end

local function doRequest(url, body)
    if RequestFunc then
        local ok, res = pcall(RequestFunc, {
            Url = url,
            Method = "POST",
            Headers = {
                ["Content-Type"] = "application/json",
                ["apikey"] = ANON_KEY,
                ["Authorization"] = "Bearer " .. ANON_KEY,
            },
            Body = body,
        })
        if ok and res then return res end
        return nil, tostring(res)
    end
    -- Fallback: HttpService:RequestAsync (works on executors that allow it)
    local ok, res = pcall(HttpService.RequestAsync, HttpService, {
        Url = url,
        Method = "POST",
        Headers = {
            ["Content-Type"] = "application/json",
            ["apikey"] = ANON_KEY,
            ["Authorization"] = "Bearer " .. ANON_KEY,
        },
        Body = body,
    })
    if ok and res then return res end
    return nil, tostring(res)
end

-- ---------- Supabase RPC call ----------
local function requestScript(key)
    local body = HttpService:JSONEncode({ p_key = key, p_userid = UserId })
    local res, err = doRequest(SUPABASE_URL .. "/rest/v1/rpc/get_script", body)
    if not res then
        return nil, "HTTP unavailable: " .. tostring(err)
    end
    if res.StatusCode ~= 200 then
        return nil, "Clé invalide ou expirée"
    end
    local decoded = HttpService:JSONDecode(res.Body)
    if type(decoded) ~= "string" then
        return nil, "Réponse serveur invalide"
    end
    return decoded
end

-- ---------- UI ----------
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local gui = Instance.new("ScreenGui")
gui.Name = "LizardKey"
gui.ResetOnSpawn = false
gui.Parent = PlayerGui

local S = 1
local card = Instance.new("Frame")
card.Name = "Card"
card.Size = UDim2.fromOffset(380, 210)
card.Position = UDim2.new(0.5, -190, 0.5, -105)
card.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
card.BackgroundTransparency = 0.05
card.BorderSizePixel = 0
card.Parent = gui

local shadow = Instance.new("UICorner")
shadow.CornerRadius = UDim.new(0, 10)
shadow.Parent = card

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(45, 45, 60)
stroke.Thickness = 1
stroke.Parent = card

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 40)
title.BackgroundTransparency = 1
title.Text = "lizard"
title.TextColor3 = Color3.fromRGB(0, 170, 255)
title.TextSize = 26
title.TextTransparency = 0.12
title.Font = Enum.Font.GothamBold
title.Parent = card

local subtitle = Instance.new("TextLabel")
subtitle.Size = UDim2.new(1, 0, 0, 18)
subtitle.Position = UDim2.new(0, 0, 0, 36)
subtitle.BackgroundTransparency = 1
subtitle.Text = "Entrez votre licence  (" .. LocalPlayer.Name .. ")"
subtitle.TextColor3 = Color3.fromRGB(170, 170, 185)
subtitle.TextSize = 13
subtitle.Font = Enum.Font.Gotham
subtitle.Parent = card

local keyBox = Instance.new("TextBox")
keyBox.Size = UDim2.new(1, -32, 0, 34)
keyBox.Position = UDim2.new(0, 16, 0, 62)
keyBox.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
keyBox.BorderSizePixel = 0
keyBox.Text = ""
keyBox.PlaceholderText = "CLÉ-DE-LICENCE"
keyBox.PlaceholderColor3 = Color3.fromRGB(95, 95, 110)
keyBox.TextColor3 = Color3.fromRGB(230, 230, 240)
keyBox.TextSize = 15
keyBox.Font = Enum.Font.Code
keyBox.ClearTextOnFocus = false
keyBox.Parent = card

local keyCorner = Instance.new("UICorner")
keyCorner.CornerRadius = UDim.new(0, 6)
keyCorner.Parent = keyBox

local status = Instance.new("TextLabel")
status.Size = UDim2.new(1, -32, 0, 18)
status.Position = UDim2.new(0, 16, 0, 102)
status.BackgroundTransparency = 1
status.Text = ""
status.TextColor3 = Color3.fromRGB(255, 90, 90)
status.TextSize = 12
status.Font = Enum.Font.Gotham
status.TextWrapped = true
status.Parent = card

local submit = Instance.new("TextButton")
submit.Size = UDim2.new(1, -32, 0, 36)
submit.Position = UDim2.new(0, 16, 0, 160)
submit.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
submit.BackgroundTransparency = 0.15
submit.BorderSizePixel = 0
submit.Text = "VALIDER"
submit.TextColor3 = Color3.fromRGB(255, 255, 255)
submit.TextSize = 15
submit.Font = Enum.Font.GothamBold
submit.AutoButtonColor = true
submit.Parent = card

local submitCorner = Instance.new("UICorner")
submitCorner.CornerRadius = UDim.new(0, 6)
submitCorner.Parent = submit

local busy = false

local function setStatus(msg, isErr)
    status.Text = msg
    status.TextColor3 = isErr and Color3.fromRGB(255, 90, 90) or Color3.fromRGB(120, 230, 150)
end

local function submitKey()
    if busy then return end
    local key = string.gsub(string.upper(keyBox.Text or ""), "%s+", "")
    if key == "" then
        setStatus("Entrez une clé", true)
        return
    end
    busy = true
    submit.Text = "VÉRIFICATION..."
    submit.BackgroundColor3 = Color3.fromRGB(120, 130, 150)
    setStatus("Vérification...", false)

    local ok, code, err = pcall(requestScript, key)
    if not ok then
        setStatus("Erreur: " .. tostring(code), true)
    elseif not code then
        setStatus(err or "Clé invalide", true)
    else
        setStatus("Licence valide, chargement...", false)
        local fn = loadstring(code)
        if fn then
            gui:Destroy()
            return fn()
        else
            setStatus("Script corrompu", true)
        end
    end
    busy = false
    submit.Text = "VALIDER"
    submit.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
end

submit.MouseButton1Click:Connect(submitKey)
keyBox.FocusLost:Connect(function(enter)
    if enter then submitKey() end
end)
