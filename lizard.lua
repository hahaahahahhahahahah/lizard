local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TeleportService = game:GetService("TeleportService")
local MarketplaceService = game:GetService("MarketplaceService")
local Stats = game:GetService("Stats")
local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local MainEvent = ReplicatedStorage:WaitForChild("MainEvent")

getgenv().Players = Players
getgenv().RunService = RunService
getgenv().UserInputService = UserInputService
getgenv().ReplicatedStorage = ReplicatedStorage
getgenv().TeleportService = TeleportService
getgenv().MarketplaceService = MarketplaceService
getgenv().Stats = Stats
getgenv().Debris = Debris
getgenv().TweenService = TweenService
getgenv().LocalPlayer = LocalPlayer
getgenv().Camera = Camera
getgenv().MainEvent = MainEvent
getgenv().Workspace = workspace
getgenv().GuiService = game:GetService("GuiService")

getgenv().ForceHitTarget = nil
getgenv().ForceHitTarget2 = nil

getgenv().FrameCounter = 0
getgenv().FPS = 0
getgenv().WatermarkConnection = nil
getgenv().TargetHealthConnection = nil

getgenv().IsMobile = getgenv().UserInputService.TouchEnabled and not getgenv().UserInputService.KeyboardEnabled

local LIZARD_LIBRARY_SOURCE =
[==[local InputService = game:GetService('UserInputService');
local TextService = game:GetService('TextService');
local CoreGui = game:GetService('CoreGui');
local Teams = game:GetService('Teams');
local Players = game:GetService('Players');
local RunService = game:GetService('RunService')
local TweenService = game:GetService('TweenService');
local RenderStepped = RunService.RenderStepped;
local LocalPlayer = Players.LocalPlayer;
local Mouse = LocalPlayer:GetMouse();

local IsMobile = InputService.TouchEnabled and not InputService.KeyboardEnabled;
local S = IsMobile and 1 or 1;

local ProtectGui = protectgui or (syn and syn.protect_gui) or (function() end);

local ScreenGui = Instance.new('ScreenGui');
ProtectGui(ScreenGui);

ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global;
ScreenGui.Parent = CoreGui;

local Toggles = {};
local Options = {};

getgenv().Toggles = Toggles;
getgenv().Options = Options;

local Library = {
    Registry = {};
    RegistryMap = {};

    HudRegistry = {};

    FontColor = Color3.fromRGB(255, 255, 255);
    MainColor = Color3.fromRGB(28, 28, 28);
    BackgroundColor = Color3.fromRGB(20, 20, 20);
    AccentColor = Color3.fromRGB(0, 85, 255);
    OutlineColor = Color3.fromRGB(50, 50, 50);
    RiskColor = Color3.fromRGB(255, 50, 50),

    Black = Color3.new(0, 0, 0);
    Font = Enum.Font.Code,

    OpenedFrames = {};
    DependencyBoxes = {};

    Signals = {};
    ScreenGui = ScreenGui;

    MobileToggleTaps = 3;
};

local ActiveTouches = {};
local LastTouchPos = Vector2.new(0, 0);

InputService.TouchStarted:Connect(function(touch)
    ActiveTouches[touch] = true;
    LastTouchPos = touch.Position;
end)

InputService.TouchMoved:Connect(function(touch)
    LastTouchPos = touch.Position;
end)

InputService.TouchEnded:Connect(function(touch)
    ActiveTouches[touch] = nil;
end)

local function GetInputPosition()
    if IsMobile then
        return LastTouchPos.X, LastTouchPos.Y;
    end
    return Mouse.X, Mouse.Y;
end

local function IsInputActive(inputType)
    if IsMobile then
        for _ in next, ActiveTouches do
            return true;
        end
        return false;
    end
    return InputService:IsMouseButtonPressed(inputType or Enum.UserInputType.MouseButton1);
end

local function IsInputButton1(input)
    return input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch;
end

local function IsInputButton2(input)
    return input.UserInputType == Enum.UserInputType.MouseButton2;
end

local RainbowStep = 0
local Hue = 0

table.insert(Library.Signals, RenderStepped:Connect(function(Delta)
    RainbowStep = RainbowStep + Delta

    if RainbowStep >= (1 / 60) then
        RainbowStep = 0

        Hue = Hue + (1 / 400);

        if Hue > 1 then
            Hue = 0;
        end;

        Library.CurrentRainbowHue = Hue;
        Library.CurrentRainbowColor = Color3.fromHSV(Hue, 0.8, 1);
    end
end))

local function GetPlayersString()
    local PlayerList = Players:GetPlayers();

    for i = 1, #PlayerList do
        PlayerList[i] = PlayerList[i].Name;
    end;

    table.sort(PlayerList, function(str1, str2) return str1 < str2 end);

    return PlayerList;
end;

local function GetTeamsString()
    local TeamList = Teams:GetTeams();

    for i = 1, #TeamList do
        TeamList[i] = TeamList[i].Name;
    end;

    table.sort(TeamList, function(str1, str2) return str1 < str2 end);

    return TeamList;
end;

function Library:SafeCallback(f, ...)
    if (not f) then
        return;
    end;

    if not Library.NotifyOnError then
        return f(...);
    end;

    local success, event = pcall(f, ...);

    if not success then
        local _, i = event:find(":%d+: ");

        if not i then
            return Library:Notify(event);
        end;

        return Library:Notify(event:sub(i + 1), 3);
    end;
end;

function Library:AttemptSave()
    if Library.SaveManager then
        Library.SaveManager:Save();
    end;
end;

function Library:Create(Class, Properties)
    local _Instance = Class;

    if type(Class) == 'string' then
        _Instance = Instance.new(Class);
    end;

    for Property, Value in next, Properties do
        _Instance[Property] = Value;
    end;

    return _Instance;
end;

function Library:ApplyTextStroke(Inst)
    Inst.TextStrokeTransparency = 1;

    Library:Create('UIStroke', {
        Color = Color3.new(0, 0, 0);
        Thickness = 1;
        LineJoinMode = Enum.LineJoinMode.Miter;
        Parent = Inst;
    });
end;

function Library:CreateLabel(Properties, IsHud)
    local _Instance = Library:Create('TextLabel', {
        BackgroundTransparency = 1;
        Font = Library.Font;
        TextColor3 = Library.FontColor;
        TextSize = 16 * S;
        TextStrokeTransparency = 0;
    });

    Library:ApplyTextStroke(_Instance);

    Library:AddToRegistry(_Instance, {
        TextColor3 = 'FontColor';
    }, IsHud);

    return Library:Create(_Instance, Properties);
end;

function Library:MakeDraggable(Instance, Cutoff)
    Instance.Active = true;

    local function StartDrag(inputX, inputY)
        local ObjPos = Vector2.new(
            inputX - Instance.AbsolutePosition.X,
            inputY - Instance.AbsolutePosition.Y
        );

        if ObjPos.Y > (Cutoff or 40) then
            return;
        end;

        while IsInputActive() do
            local mX, mY = GetInputPosition();
            Instance.Position = UDim2.new(
                0,
                mX - ObjPos.X + (Instance.Size.X.Offset * Instance.AnchorPoint.X),
                0,
                mY - ObjPos.Y + (Instance.Size.Y.Offset * Instance.AnchorPoint.Y)
            );

            RenderStepped:Wait();
        end;
    end

    Instance.InputBegan:Connect(function(Input)
        if IsInputButton1(Input) then
            local iX, iY;
            if Input.UserInputType == Enum.UserInputType.Touch then
                iX = Input.Position.X;
                iY = Input.Position.Y;
            else
                iX = Mouse.X;
                iY = Mouse.Y;
            end
            StartDrag(iX, iY);
        end;
    end)
end;

function Library:AddToolTip(InfoStr, HoverInstance)
    local X, Y = Library:GetTextBounds(InfoStr, Library.Font, 14);
    local Tooltip = Library:Create('Frame', {
        BackgroundColor3 = Library.MainColor,
        BorderColor3 = Library.OutlineColor,

        Size = UDim2.fromOffset((X + 5) * S, (Y + 4) * S),
        ZIndex = 100,
        Parent = Library.ScreenGui,

        Visible = false,
    })

    local Label = Library:CreateLabel({
        Position = UDim2.fromOffset(3, 1),
        Size = UDim2.fromOffset(X * S, Y * S);
        TextSize = 14;
        Text = InfoStr,
        TextColor3 = Library.FontColor,
        TextXAlignment = Enum.TextXAlignment.Left;
        ZIndex = Tooltip.ZIndex + 1,

        Parent = Tooltip;
    });

    Library:AddToRegistry(Tooltip, {
        BackgroundColor3 = 'MainColor';
        BorderColor3 = 'OutlineColor';
    });

    Library:AddToRegistry(Label, {
        TextColor3 = 'FontColor',
    });

    local IsHovering = false

    HoverInstance.MouseEnter:Connect(function()
        if Library:MouseIsOverOpenedFrame() then
            return
        end

        IsHovering = true

        local mX, mY = GetInputPosition();
        Tooltip.Position = UDim2.fromOffset(mX + 15, mY + 12)
        Tooltip.Visible = true

        while IsHovering do
            RunService.Heartbeat:Wait()
            local tX, tY = GetInputPosition();
            Tooltip.Position = UDim2.fromOffset(tX + 15, tY + 12)
        end
    end)

    HoverInstance.MouseLeave:Connect(function()
        IsHovering = false
        Tooltip.Visible = false
    end)
end

function Library:OnHighlight(HighlightInstance, Instance, Properties, PropertiesDefault)
    HighlightInstance.MouseEnter:Connect(function()
        local Reg = Library.RegistryMap[Instance];

        for Property, ColorIdx in next, Properties do
            Instance[Property] = Library[ColorIdx] or ColorIdx;

            if Reg and Reg.Properties[Property] then
                Reg.Properties[Property] = ColorIdx;
            end;
        end;
    end)

    HighlightInstance.MouseLeave:Connect(function()
        local Reg = Library.RegistryMap[Instance];

        for Property, ColorIdx in next, PropertiesDefault do
            Instance[Property] = Library[ColorIdx] or ColorIdx;

            if Reg and Reg.Properties[Property] then
                Reg.Properties[Property] = ColorIdx;
            end;
        end;
    end)
end;

function Library:MouseIsOverOpenedFrame()
    local mX, mY = GetInputPosition();
    for Frame, _ in next, Library.OpenedFrames do
        local AbsPos, AbsSize = Frame.AbsolutePosition, Frame.AbsoluteSize;

        if mX >= AbsPos.X and mX <= AbsPos.X + AbsSize.X
            and mY >= AbsPos.Y and mY <= AbsPos.Y + AbsSize.Y then

            return true;
        end;
    end;
end;

function Library:IsMouseOverFrame(Frame)
    local mX, mY = GetInputPosition();
    local AbsPos, AbsSize = Frame.AbsolutePosition, Frame.AbsoluteSize;

    if mX >= AbsPos.X and mX <= AbsPos.X + AbsSize.X
        and mY >= AbsPos.Y and mY <= AbsPos.Y + AbsSize.Y then

        return true;
    end;
end;

function Library:UpdateDependencyBoxes()
    for _, Depbox in next, Library.DependencyBoxes do
        Depbox:Update();
    end;
end;

function Library:MapValue(Value, MinA, MaxA, MinB, MaxB)
    return (1 - ((Value - MinA) / (MaxA - MinA))) * MinB + ((Value - MinA) / (MaxA - MinA)) * MaxB;
end;

function Library:GetTextBounds(Text, Font, Size, Resolution)
    local Bounds = TextService:GetTextSize(Text, Size, Font, Resolution or Vector2.new(1920, 1080))
    return Bounds.X, Bounds.Y
end;

function Library:GetDarkerColor(Color)
    local H, S, V = Color3.toHSV(Color);
    return Color3.fromHSV(H, S, V / 1.5);
end;
Library.AccentColorDark = Library:GetDarkerColor(Library.AccentColor);

function Library:AddToRegistry(Instance, Properties, IsHud)
    local Idx = #Library.Registry + 1;
    local Data = {
        Instance = Instance;
        Properties = Properties;
        Idx = Idx;
    };

    table.insert(Library.Registry, Data);
    Library.RegistryMap[Instance] = Data;

    if IsHud then
        table.insert(Library.HudRegistry, Data);
    end;
end;

function Library:RemoveFromRegistry(Instance)
    local Data = Library.RegistryMap[Instance];

    if Data then
        for Idx = #Library.Registry, 1, -1 do
            if Library.Registry[Idx] == Data then
                table.remove(Library.Registry, Idx);
            end;
        end;

        for Idx = #Library.HudRegistry, 1, -1 do
            if Library.HudRegistry[Idx] == Data then
                table.remove(Library.HudRegistry, Idx);
            end;
        end;

        Library.RegistryMap[Instance] = nil;
    end;
end;

function Library:UpdateColorsUsingRegistry()
    for Idx, Object in next, Library.Registry do
        for Property, ColorIdx in next, Object.Properties do
            if type(ColorIdx) == 'string' then
                Object.Instance[Property] = Library[ColorIdx];
            elseif type(ColorIdx) == 'function' then
                Object.Instance[Property] = ColorIdx()
            end
        end;
    end;
end;

function Library:GiveSignal(Signal)
    table.insert(Library.Signals, Signal)
end

function Library:Unload()
    for Idx = #Library.Signals, 1, -1 do
        local Connection = table.remove(Library.Signals, Idx)
        Connection:Disconnect()
    end

    if Library.OnUnload then
        Library.OnUnload()
    end

    ScreenGui:Destroy()
end

function Library:OnUnload(Callback)
    Library.OnUnload = Callback
end

Library:GiveSignal(ScreenGui.DescendantRemoving:Connect(function(Instance)
    if Library.RegistryMap[Instance] then
        Library:RemoveFromRegistry(Instance);
    end;
end))

local BaseAddons = {};

do
    local Funcs = {};

    function Funcs:AddColorPicker(Idx, Info)
        local ToggleLabel = self.TextLabel;

        assert(Info.Default, 'AddColorPicker: Missing default value.');

        local ColorPicker = {
            Value = Info.Default;
            Transparency = Info.Transparency or 0;
            Type = 'ColorPicker';
            Title = type(Info.Title) == 'string' and Info.Title or 'Color picker',
            Callback = Info.Callback or function(Color) end;
        };

        function ColorPicker:SetHSVFromRGB(Color)
            local H, S, V = Color3.toHSV(Color);

            ColorPicker.Hue = H;
            ColorPicker.Sat = S;
            ColorPicker.Vib = V;
        end;

        ColorPicker:SetHSVFromRGB(ColorPicker.Value);

        local DisplayFrame = Library:Create('Frame', {
            BackgroundColor3 = ColorPicker.Value;
            BorderColor3 = Library:GetDarkerColor(ColorPicker.Value);
            BorderMode = Enum.BorderMode.Inset;
            Size = UDim2.new(0, 28 * S, 0, 14 * S);
            ZIndex = 6;
            Parent = ToggleLabel;
        });

        local CheckerFrame = Library:Create('ImageLabel', {
            BorderSizePixel = 0;
            Size = UDim2.new(0, 27 * S, 0, 13 * S);
            ZIndex = 5;
            Image = 'http://www.roblox.com/asset/?id=12977615774';
            Visible = not not Info.Transparency;
            Parent = DisplayFrame;
        });

        local PickerFrameOuter = Library:Create('Frame', {
            Name = 'Color';
            BackgroundColor3 = Color3.new(1, 1, 1);
            BorderColor3 = Color3.new(0, 0, 0);
            Position = UDim2.fromOffset(DisplayFrame.AbsolutePosition.X, DisplayFrame.AbsolutePosition.Y + 18),
            Size = UDim2.fromOffset(230 * S, (Info.Transparency and 271 or 253) * S);
            Visible = false;
            ZIndex = 15;
            Parent = ScreenGui,
        });

        DisplayFrame:GetPropertyChangedSignal('AbsolutePosition'):Connect(function()
            PickerFrameOuter.Position = UDim2.fromOffset(DisplayFrame.AbsolutePosition.X, DisplayFrame.AbsolutePosition.Y + 18 * S);
        end)

        local PickerFrameInner = Library:Create('Frame', {
            BackgroundColor3 = Library.BackgroundColor;
            BorderColor3 = Library.OutlineColor;
            BorderMode = Enum.BorderMode.Inset;
            Size = UDim2.new(1, 0, 1, 0);
            ZIndex = 16;
            Parent = PickerFrameOuter;
        });

        local Highlight = Library:Create('Frame', {
            BackgroundColor3 = Library.AccentColor;
            BorderSizePixel = 0;
            Size = UDim2.new(1, 0, 0, 2);
            ZIndex = 17;
            Parent = PickerFrameInner;
        });

        local SatVibMapOuter = Library:Create('Frame', {
            BorderColor3 = Color3.new(0, 0, 0);
            Position = UDim2.new(0, 4 * S, 0, 25 * S);
            Size = UDim2.new(0, 200 * S, 0, 200 * S);
            ZIndex = 17;
            Parent = PickerFrameInner;
        });

        local SatVibMapInner = Library:Create('Frame', {
            BackgroundColor3 = Library.BackgroundColor;
            BorderColor3 = Library.OutlineColor;
            BorderMode = Enum.BorderMode.Inset;
            Size = UDim2.new(1, 0, 1, 0);
            ZIndex = 18;
            Parent = SatVibMapOuter;
        });

        local SatVibMap = Library:Create('ImageLabel', {
            BorderSizePixel = 0;
            Size = UDim2.new(1, 0, 1, 0);
            ZIndex = 18;
            Image = 'rbxassetid://4155801252';
            Parent = SatVibMapInner;
        });

        local CursorOuter = Library:Create('ImageLabel', {
            AnchorPoint = Vector2.new(0.5, 0.5);
            Size = UDim2.new(0, 6 * S, 0, 6 * S);
            BackgroundTransparency = 1;
            Image = 'http://www.roblox.com/asset/?id=9619665977';
            ImageColor3 = Color3.new(0, 0, 0);
            ZIndex = 19;
            Parent = SatVibMap;
        });

        local CursorInner = Library:Create('ImageLabel', {
            Size = UDim2.new(0, CursorOuter.Size.X.Offset - 2, 0, CursorOuter.Size.Y.Offset - 2);
            Position = UDim2.new(0, 1, 0, 1);
            BackgroundTransparency = 1;
            Image = 'http://www.roblox.com/asset/?id=9619665977';
            ZIndex = 20;
            Parent = CursorOuter;
        })

        local HueSelectorOuter = Library:Create('Frame', {
            BorderColor3 = Color3.new(0, 0, 0);
            Position = UDim2.new(0, 208 * S, 0, 25 * S);
            Size = UDim2.new(0, 15 * S, 0, 200 * S);
            ZIndex = 17;
            Parent = PickerFrameInner;
        });

        local HueSelectorInner = Library:Create('Frame', {
            BackgroundColor3 = Color3.new(1, 1, 1);
            BorderSizePixel = 0;
            Size = UDim2.new(1, 0, 1, 0);
            ZIndex = 18;
            Parent = HueSelectorOuter;
        });

        local HueCursor = Library:Create('Frame', {
            BackgroundColor3 = Color3.new(1, 1, 1);
            AnchorPoint = Vector2.new(0, 0.5);
            BorderColor3 = Color3.new(0, 0, 0);
            Size = UDim2.new(1, 0, 0, 1);
            ZIndex = 18;
            Parent = HueSelectorInner;
        });

        local HueBoxOuter = Library:Create('Frame', {
            BorderColor3 = Color3.new(0, 0, 0);
            Position = UDim2.fromOffset(4 * S, 228 * S),
            Size = UDim2.new(0.5, -6 * S, 0, 20 * S),
            ZIndex = 18,
            Parent = PickerFrameInner;
        });

        local HueBoxInner = Library:Create('Frame', {
            BackgroundColor3 = Library.MainColor;
            BorderColor3 = Library.OutlineColor;
            BorderMode = Enum.BorderMode.Inset;
            Size = UDim2.new(1, 0, 1, 0);
            ZIndex = 18,
            Parent = HueBoxOuter;
        });

        Library:Create('UIGradient', {
            Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.new(1, 1, 1)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(212, 212, 212))
            });
            Rotation = 90;
            Parent = HueBoxInner;
        });

        local HueBox = Library:Create('TextBox', {
            BackgroundTransparency = 1;
            Position = UDim2.new(0, 5, 0, 0);
            Size = UDim2.new(1, -5, 1, 0);
            Font = Library.Font;
            PlaceholderColor3 = Color3.fromRGB(190, 190, 190);
            PlaceholderText = 'Hex color',
            Text = '#FFFFFF',
            TextColor3 = Library.FontColor;
            TextSize = 14 * S;
            TextStrokeTransparency = 0;
            TextXAlignment = Enum.TextXAlignment.Left;
            ZIndex = 20,
            Parent = HueBoxInner;
        });

        Library:ApplyTextStroke(HueBox);

        local RgbBoxBase = Library:Create(HueBoxOuter:Clone(), {
            Position = UDim2.new(0.5, 2 * S, 0, 228 * S),
            Size = UDim2.new(0.5, -6 * S, 0, 20 * S),
            Parent = PickerFrameInner
        });

        local RgbBox = Library:Create(RgbBoxBase.Frame:FindFirstChild('TextBox'), {
            Text = '255, 255, 255',
            PlaceholderText = 'RGB color',
            TextColor3 = Library.FontColor
        });

        local TransparencyBoxOuter, TransparencyBoxInner, TransparencyCursor;

        if Info.Transparency then
            TransparencyBoxOuter = Library:Create('Frame', {
                BorderColor3 = Color3.new(0, 0, 0);
                Position = UDim2.fromOffset(4 * S, 251 * S);
                Size = UDim2.new(1, -8 * S, 0, 15 * S);
                ZIndex = 19;
                Parent = PickerFrameInner;
            });

            TransparencyBoxInner = Library:Create('Frame', {
                BackgroundColor3 = ColorPicker.Value;
                BorderColor3 = Library.OutlineColor;
                BorderMode = Enum.BorderMode.Inset;
                Size = UDim2.new(1, 0, 1, 0);
                ZIndex = 19;
                Parent = TransparencyBoxOuter;
            });

            Library:AddToRegistry(TransparencyBoxInner, { BorderColor3 = 'OutlineColor' });

            Library:Create('ImageLabel', {
                BackgroundTransparency = 1;
                Size = UDim2.new(1, 0, 1, 0);
                Image = 'http://www.roblox.com/asset/?id=12978095818';
                ZIndex = 20;
                Parent = TransparencyBoxInner;
            });

            TransparencyCursor = Library:Create('Frame', {
                BackgroundColor3 = Color3.new(1, 1, 1);
                AnchorPoint = Vector2.new(0.5, 0);
                BorderColor3 = Color3.new(0, 0, 0);
                Size = UDim2.new(0, 1, 1, 0);
                ZIndex = 21;
                Parent = TransparencyBoxInner;
            });
        end;

        local DisplayLabel = Library:CreateLabel({
            Size = UDim2.new(1, 0, 0, 14);
            Position = UDim2.fromOffset(5, 5);
            TextXAlignment = Enum.TextXAlignment.Left;
            TextSize = 14 * S;
            Text = ColorPicker.Title,
            TextWrapped = false;
            ZIndex = 16;
            Parent = PickerFrameInner;
        });

        local ContextMenu = {}
        do
            ContextMenu.Options = {}
            ContextMenu.Container = Library:Create('Frame', {
                BorderColor3 = Color3.new(),
                ZIndex = 14,

                Visible = false,
                Parent = ScreenGui
            })

            ContextMenu.Inner = Library:Create('Frame', {
                BackgroundColor3 = Library.BackgroundColor;
                BorderColor3 = Library.OutlineColor;
                BorderMode = Enum.BorderMode.Inset;
                Size = UDim2.fromScale(1, 1);
                ZIndex = 15;
                Parent = ContextMenu.Container;
            });

            Library:Create('UIListLayout', {
                Name = 'Layout',
                FillDirection = Enum.FillDirection.Vertical;
                SortOrder = Enum.SortOrder.LayoutOrder;
                Parent = ContextMenu.Inner;
            });

            Library:Create('UIPadding', {
                Name = 'Padding',
                PaddingLeft = UDim.new(0, 4),
                Parent = ContextMenu.Inner,
            });

            local function updateMenuPosition()
                ContextMenu.Container.Position = UDim2.fromOffset(
                    (DisplayFrame.AbsolutePosition.X + DisplayFrame.AbsoluteSize.X) + 4,
                    DisplayFrame.AbsolutePosition.Y + 1
                )
            end

            local function updateMenuSize()
                local menuWidth = 60
                for i, label in next, ContextMenu.Inner:GetChildren() do
                    if label:IsA('TextLabel') then
                        menuWidth = math.max(menuWidth, label.TextBounds.X)
                    end
                end

                ContextMenu.Container.Size = UDim2.fromOffset(
                    menuWidth + 8,
                    ContextMenu.Inner.Layout.AbsoluteContentSize.Y + 4
                )
            end

            DisplayFrame:GetPropertyChangedSignal('AbsolutePosition'):Connect(updateMenuPosition)
            ContextMenu.Inner.Layout:GetPropertyChangedSignal('AbsoluteContentSize'):Connect(updateMenuSize)

            task.spawn(updateMenuPosition)
            task.spawn(updateMenuSize)

            Library:AddToRegistry(ContextMenu.Inner, {
                BackgroundColor3 = 'BackgroundColor';
                BorderColor3 = 'OutlineColor';
            });

            function ContextMenu:Show()
                self.Container.Visible = true
            end

            function ContextMenu:Hide()
                self.Container.Visible = false
            end

            function ContextMenu:AddOption(Str, Callback)
                if type(Callback) ~= 'function' then
                    Callback = function() end
                end

                local Button = Library:CreateLabel({
                    Active = false;
                    Size = UDim2.new(1, 0, 0, 15 * S);
                    TextSize = 13 * S;
                    Text = Str;
                    ZIndex = 16;
                    Parent = self.Inner;
                    TextXAlignment = Enum.TextXAlignment.Left,
                });

                Library:OnHighlight(Button, Button,
                    { TextColor3 = 'AccentColor' },
                    { TextColor3 = 'FontColor' }
                );

                Button.InputBegan:Connect(function(Input)
                    if not IsInputButton1(Input) then
                        return
                    end

                    Callback()
                end)
            end

            ContextMenu:AddOption('Copy color', function()
                Library.ColorClipboard = ColorPicker.Value
                Library:Notify('Copied color!', 2)
            end)

            ContextMenu:AddOption('Paste color', function()
                if not Library.ColorClipboard then
                    return Library:Notify('You have not copied a color!', 2)
                end
                ColorPicker:SetValueRGB(Library.ColorClipboard)
            end)

            ContextMenu:AddOption('Copy HEX', function()
                pcall(setclipboard, ColorPicker.Value:ToHex())
                Library:Notify('Copied hex code to clipboard!', 2)
            end)

            ContextMenu:AddOption('Copy RGB', function()
                pcall(setclipboard, table.concat({ math.floor(ColorPicker.Value.R * 255), math.floor(ColorPicker.Value.G * 255), math.floor(ColorPicker.Value.B * 255) }, ', '))
                Library:Notify('Copied RGB values to clipboard!', 2)
            end)

        end

        Library:AddToRegistry(PickerFrameInner, { BackgroundColor3 = 'BackgroundColor'; BorderColor3 = 'OutlineColor'; });
        Library:AddToRegistry(Highlight, { BackgroundColor3 = 'AccentColor'; });
        Library:AddToRegistry(SatVibMapInner, { BackgroundColor3 = 'BackgroundColor'; BorderColor3 = 'OutlineColor'; });

        Library:AddToRegistry(HueBoxInner, { BackgroundColor3 = 'MainColor'; BorderColor3 = 'OutlineColor'; });
        Library:AddToRegistry(RgbBoxBase.Frame, { BackgroundColor3 = 'MainColor'; BorderColor3 = 'OutlineColor'; });
        Library:AddToRegistry(RgbBox, { TextColor3 = 'FontColor', });
        Library:AddToRegistry(HueBox, { TextColor3 = 'FontColor', });

        local SequenceTable = {};

        for Hue = 0, 1, 0.1 do
            table.insert(SequenceTable, ColorSequenceKeypoint.new(Hue, Color3.fromHSV(Hue, 1, 1)));
        end;

        local HueSelectorGradient = Library:Create('UIGradient', {
            Color = ColorSequence.new(SequenceTable);
            Rotation = 90;
            Parent = HueSelectorInner;
        });

        HueBox.FocusLost:Connect(function(enter)
            if enter then
                local success, result = pcall(Color3.fromHex, HueBox.Text)
                if success and typeof(result) == 'Color3' then
                    ColorPicker.Hue, ColorPicker.Sat, ColorPicker.Vib = Color3.toHSV(result)
                end
            end

            ColorPicker:Display()
        end)

        RgbBox.FocusLost:Connect(function(enter)
            if enter then
                local r, g, b = RgbBox.Text:match('(%d+),%s*(%d+),%s*(%d+)')
                if r and g and b then
                    ColorPicker.Hue, ColorPicker.Sat, ColorPicker.Vib = Color3.toHSV(Color3.fromRGB(r, g, b))
                end
            end

            ColorPicker:Display()
        end)

        function ColorPicker:Display()
            ColorPicker.Value = Color3.fromHSV(ColorPicker.Hue, ColorPicker.Sat, ColorPicker.Vib);
            SatVibMap.BackgroundColor3 = Color3.fromHSV(ColorPicker.Hue, 1, 1);

            Library:Create(DisplayFrame, {
                BackgroundColor3 = ColorPicker.Value;
                BackgroundTransparency = ColorPicker.Transparency;
                BorderColor3 = Library:GetDarkerColor(ColorPicker.Value);
            });

            if TransparencyBoxInner then
                TransparencyBoxInner.BackgroundColor3 = ColorPicker.Value;
                TransparencyCursor.Position = UDim2.new(1 - ColorPicker.Transparency, 0, 0, 0);
            end;

            CursorOuter.Position = UDim2.new(ColorPicker.Sat, 0, 1 - ColorPicker.Vib, 0);
            HueCursor.Position = UDim2.new(0, 0, ColorPicker.Hue, 0);

            HueBox.Text = '#' .. ColorPicker.Value:ToHex()
            RgbBox.Text = table.concat({ math.floor(ColorPicker.Value.R * 255), math.floor(ColorPicker.Value.G * 255), math.floor(ColorPicker.Value.B * 255) }, ', ')

            Library:SafeCallback(ColorPicker.Callback, ColorPicker.Value);
            Library:SafeCallback(ColorPicker.Changed, ColorPicker.Value);
        end;

        function ColorPicker:OnChanged(Func)
            ColorPicker.Changed = Func;
            Func(ColorPicker.Value)
        end;

        function ColorPicker:Show()
            for Frame, Val in next, Library.OpenedFrames do
                if Frame.Name == 'Color' then
                    Frame.Visible = false;
                    Library.OpenedFrames[Frame] = nil;
                end;
            end;

            PickerFrameOuter.Visible = true;
            Library.OpenedFrames[PickerFrameOuter] = true;
        end;

        function ColorPicker:Hide()
            PickerFrameOuter.Visible = false;
            Library.OpenedFrames[PickerFrameOuter] = nil;
        end;

        function ColorPicker:SetValue(HSV, Transparency)
            local Color = Color3.fromHSV(HSV[1], HSV[2], HSV[3]);

            ColorPicker.Transparency = Transparency or 0;
            ColorPicker:SetHSVFromRGB(Color);
            ColorPicker:Display();
        end;

        function ColorPicker:SetValueRGB(Color, Transparency)
            ColorPicker.Transparency = Transparency or 0;
            ColorPicker:SetHSVFromRGB(Color);
            ColorPicker:Display();
        end;

        SatVibMap.InputBegan:Connect(function(Input)
            if IsInputButton1(Input) then
                while IsInputActive() do
                    local mX, mY = GetInputPosition();
                    local MinX = SatVibMap.AbsolutePosition.X;
                    local MaxX = MinX + SatVibMap.AbsoluteSize.X;
                    local MouseX = math.clamp(mX, MinX, MaxX);

                    local MinY = SatVibMap.AbsolutePosition.Y;
                    local MaxY = MinY + SatVibMap.AbsoluteSize.Y;
                    local MouseY = math.clamp(mY, MinY, MaxY);

                    ColorPicker.Sat = (MouseX - MinX) / (MaxX - MinX);
                    ColorPicker.Vib = 1 - ((MouseY - MinY) / (MaxY - MinY));
                    ColorPicker:Display();

                    RenderStepped:Wait();
                end;

                Library:AttemptSave();
            end;
        end);

        HueSelectorInner.InputBegan:Connect(function(Input)
            if IsInputButton1(Input) then
                while IsInputActive() do
                    local _, mY = GetInputPosition();
                    local MinY = HueSelectorInner.AbsolutePosition.Y;
                    local MaxY = MinY + HueSelectorInner.AbsoluteSize.Y;
                    local MouseY = math.clamp(mY, MinY, MaxY);

                    ColorPicker.Hue = ((MouseY - MinY) / (MaxY - MinY));
                    ColorPicker:Display();

                    RenderStepped:Wait();
                end;

                Library:AttemptSave();
            end;
        end);

        local LongPressThread;

        DisplayFrame.InputBegan:Connect(function(Input)
            if IsInputButton1(Input) and not Library:MouseIsOverOpenedFrame() then
                if IsMobile then
                    LongPressThread = task.delay(0.4, function()
                        LongPressThread = nil;
                        ContextMenu:Show();
                        ColorPicker:Hide();
                    end)
                end
                if PickerFrameOuter.Visible then
                    ColorPicker:Hide()
                else
                    ContextMenu:Hide()
                    ColorPicker:Show()
                end;
            elseif IsInputButton2(Input) and not Library:MouseIsOverOpenedFrame() then
                ContextMenu:Show()
                ColorPicker:Hide()
            end
        end);

        DisplayFrame.InputEnded:Connect(function(Input)
            if IsInputButton1(Input) and LongPressThread then
                task.cancel(LongPressThread);
                LongPressThread = nil;
            end
        end)

        if TransparencyBoxInner then
            TransparencyBoxInner.InputBegan:Connect(function(Input)
                if IsInputButton1(Input) then
                    while IsInputActive() do
                        local mX, _ = GetInputPosition();
                        local MinX = TransparencyBoxInner.AbsolutePosition.X;
                        local MaxX = MinX + TransparencyBoxInner.AbsoluteSize.X;
                        local MouseX = math.clamp(mX, MinX, MaxX);

                        ColorPicker.Transparency = 1 - ((MouseX - MinX) / (MaxX - MinX));

                        ColorPicker:Display();

                        RenderStepped:Wait();
                    end;

                    Library:AttemptSave();
                end;
            end);
        end;

        Library:GiveSignal(InputService.InputBegan:Connect(function(Input)
            if IsInputButton1(Input) then
                local mX, mY = GetInputPosition();
                local AbsPos, AbsSize = PickerFrameOuter.AbsolutePosition, PickerFrameOuter.AbsoluteSize;

                if mX < AbsPos.X or mX > AbsPos.X + AbsSize.X
                    or mY < (AbsPos.Y - 20 - 1) or mY > AbsPos.Y + AbsSize.Y then

                    ColorPicker:Hide();
                end;

                if not Library:IsMouseOverFrame(ContextMenu.Container) then
                    ContextMenu:Hide()
                end
            end;

            if IsInputButton2(Input) and ContextMenu.Container.Visible then
                if not Library:IsMouseOverFrame(ContextMenu.Container) and not Library:IsMouseOverFrame(DisplayFrame) then
                    ContextMenu:Hide()
                end
            end
        end))

        ColorPicker:Display();
        ColorPicker.DisplayFrame = DisplayFrame

        Options[Idx] = ColorPicker;

        return self;
    end;

    function Funcs:AddKeyPicker(Idx, Info)
        local ParentObj = self;
        local ToggleLabel = self.TextLabel;
        local Container = self.Container;

        assert(Info.Default, 'AddKeyPicker: Missing default value.');

        local KeyPicker = {
            Value = Info.Default;
            Toggled = false;
            Mode = Info.Mode or 'Toggle';
            Type = 'KeyPicker';
            Callback = Info.Callback or function(Value) end;
            ChangedCallback = Info.ChangedCallback or function(New) end;

            SyncToggleState = Info.SyncToggleState or false;
        };

        if KeyPicker.SyncToggleState then
            Info.Modes = { 'Toggle' }
            Info.Mode = 'Toggle'
        end

        local PickOuter = Library:Create('Frame', {
            BackgroundColor3 = Color3.new(0, 0, 0);
            BorderColor3 = Color3.new(0, 0, 0);
            Size = UDim2.new(0, 28 * S, 0, 15 * S);
            ZIndex = 6;
            Parent = ToggleLabel;
        });

        local PickInner = Library:Create('Frame', {
            BackgroundColor3 = Library.BackgroundColor;
            BorderColor3 = Library.OutlineColor;
            BorderMode = Enum.BorderMode.Inset;
            Size = UDim2.new(1, 0, 1, 0);
            ZIndex = 7;
            Parent = PickOuter;
        });

        Library:AddToRegistry(PickInner, {
            BackgroundColor3 = 'BackgroundColor';
            BorderColor3 = 'OutlineColor';
        });

        local DisplayLabel = Library:CreateLabel({
            Size = UDim2.new(1, 0, 1, 0);
            TextSize = 13 * S;
            Text = Info.Default;
            TextWrapped = true;
            ZIndex = 8;
            Parent = PickInner;
        });

        local ModeSelectOuter = Library:Create('Frame', {
            BorderColor3 = Color3.new(0, 0, 0);
            Position = UDim2.fromOffset(ToggleLabel.AbsolutePosition.X + ToggleLabel.AbsoluteSize.X + 4, ToggleLabel.AbsolutePosition.Y + 1);
            Size = UDim2.new(0, 60 * S, 0, (45 + 2) * S);
            Visible = false;
            ZIndex = 14;
            Parent = ScreenGui;
        });

        ToggleLabel:GetPropertyChangedSignal('AbsolutePosition'):Connect(function()
            ModeSelectOuter.Position = UDim2.fromOffset(ToggleLabel.AbsolutePosition.X + ToggleLabel.AbsoluteSize.X + 4, ToggleLabel.AbsolutePosition.Y + 1);
        end);

        local ModeSelectInner = Library:Create('Frame', {
            BackgroundColor3 = Library.BackgroundColor;
            BorderColor3 = Library.OutlineColor;
            BorderMode = Enum.BorderMode.Inset;
            Size = UDim2.new(1, 0, 1, 0);
            ZIndex = 15;
            Parent = ModeSelectOuter;
        });

        Library:AddToRegistry(ModeSelectInner, {
            BackgroundColor3 = 'BackgroundColor';
            BorderColor3 = 'OutlineColor';
        });

        Library:Create('UIListLayout', {
            FillDirection = Enum.FillDirection.Vertical;
            SortOrder = Enum.SortOrder.LayoutOrder;
            Parent = ModeSelectInner;
        });

        local ContainerLabel = Library:CreateLabel({
            TextXAlignment = Enum.TextXAlignment.Left;
            Size = UDim2.new(1, 0, 0, 18 * S);
            TextSize = 13 * S;
            Visible = false;
            ZIndex = 110;
            Parent = Library.KeybindContainer;
        }, true);

        local Modes = Info.Modes or { 'Always', 'Toggle', 'Hold' };
        local ModeButtons = {};

        for Idx, Mode in next, Modes do
            local ModeButton = {};

            local Label = Library:CreateLabel({
                Active = false;
                Size = UDim2.new(1, 0, 0, 15 * S);
                TextSize = 13 * S;
                Text = Mode;
                ZIndex = 16;
                Parent = ModeSelectInner;
            });

            function ModeButton:Select()
                for _, Button in next, ModeButtons do
                    Button:Deselect();
                end;

                KeyPicker.Mode = Mode;

                Label.TextColor3 = Library.AccentColor;
                Library.RegistryMap[Label].Properties.TextColor3 = 'AccentColor';

                ModeSelectOuter.Visible = false;
            end;

            function ModeButton:Deselect()
                KeyPicker.Mode = nil;

                Label.TextColor3 = Library.FontColor;
                Library.RegistryMap[Label].Properties.TextColor3 = 'FontColor';
            end;

            Label.InputBegan:Connect(function(Input)
                if IsInputButton1(Input) then
                    ModeButton:Select();
                    Library:AttemptSave();
                end;
            end);

            if Mode == KeyPicker.Mode then
                ModeButton:Select();
            end;

            ModeButtons[Mode] = ModeButton;
        end;

        function KeyPicker:Update()
            if Info.NoUI then
                return;
            end;

            local State = KeyPicker:GetState();

            ContainerLabel.Text = string.format('[%s] %s (%s)', KeyPicker.Value, Info.Text, KeyPicker.Mode);

            ContainerLabel.Visible = true;
            ContainerLabel.TextColor3 = State and Library.AccentColor or Library.FontColor;

            Library.RegistryMap[ContainerLabel].Properties.TextColor3 = State and 'AccentColor' or 'FontColor';

            local YSize = 0
            local XSize = 0

            for _, Label in next, Library.KeybindContainer:GetChildren() do
                if Label:IsA('TextLabel') and Label.Visible then
                    YSize = YSize + 18;
                    if (Label.TextBounds.X > XSize) then
                        XSize = Label.TextBounds.X
                    end
                end;
            end;

            Library.KeybindFrame.Size = UDim2.new(0, math.max(XSize + 10 * S, 210 * S), 0, YSize + 23 * S)
        end;

        function KeyPicker:GetState()
            if KeyPicker.Mode == 'Always' then
                return true;
            elseif KeyPicker.Mode == 'Hold' then
                if KeyPicker.Value == 'None' then
                    return false;
                end

                local Key = KeyPicker.Value;

                if Key == 'MB1' or Key == 'MB2' then
                    return Key == 'MB1' and InputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1)
                        or Key == 'MB2' and InputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2);
                else
                    return InputService:IsKeyDown(Enum.KeyCode[KeyPicker.Value]);
                end;
            else
                return KeyPicker.Toggled;
            end;
        end;

        function KeyPicker:SetValue(Data)
            local Key, Mode = Data[1], Data[2];
            DisplayLabel.Text = Key;
            KeyPicker.Value = Key;
            ModeButtons[Mode]:Select();
            KeyPicker:Update();
        end;

        function KeyPicker:OnClick(Callback)
            KeyPicker.Clicked = Callback
        end

        function KeyPicker:OnChanged(Callback)
            KeyPicker.Changed = Callback
            Callback(KeyPicker.Value)
        end

        if ParentObj.Addons then
            table.insert(ParentObj.Addons, KeyPicker)
        end

        function KeyPicker:DoClick()
            if ParentObj.Type == 'Toggle' and KeyPicker.SyncToggleState then
                ParentObj:SetValue(not ParentObj.Value)
            end

            Library:SafeCallback(KeyPicker.Callback, KeyPicker.Toggled)
            Library:SafeCallback(KeyPicker.Clicked, KeyPicker.Toggled)
        end

        local Picking = false;
        local LongPressThread;

        PickOuter.InputBegan:Connect(function(Input)
            if IsInputButton1(Input) and not Library:MouseIsOverOpenedFrame() then
                if IsMobile then
                    LongPressThread = task.delay(0.5, function()
                        LongPressThread = nil;
                        ModeSelectOuter.Visible = true;
                    end)
                end

                Picking = true;

                DisplayLabel.Text = '';

                local Break;
                local Text = '';

                task.spawn(function()
                    while (not Break) do
                        if Text == '...' then
                            Text = '';
                        end;

                        Text = Text .. '.';
                        DisplayLabel.Text = Text;

                        wait(0.4);
                    end;
                end);

                wait(0.2);

                local Event;
                Event = InputService.InputBegan:Connect(function(Input)
                    local Key;

                    if Input.UserInputType == Enum.UserInputType.Keyboard then
                        Key = Input.KeyCode.Name;
                    elseif Input.UserInputType == Enum.UserInputType.MouseButton1 then
                        Key = 'MB1';
                    elseif Input.UserInputType == Enum.UserInputType.MouseButton2 then
                        Key = 'MB2';
                    elseif Input.UserInputType == Enum.UserInputType.Touch then
                        Key = 'Touch';
                    end;

                    if not Key then return end;

                    Break = true;
                    Picking = false;

                    DisplayLabel.Text = Key;
                    KeyPicker.Value = Key;

                    Library:SafeCallback(KeyPicker.ChangedCallback, Input.KeyCode or Input.UserInputType)
                    Library:SafeCallback(KeyPicker.Changed, Input.KeyCode or Input.UserInputType)

                    Library:AttemptSave();

                    Event:Disconnect();
                end);
            elseif IsInputButton2(Input) and not Library:MouseIsOverOpenedFrame() then
                ModeSelectOuter.Visible = true;
            end;
        end);

        PickOuter.InputEnded:Connect(function(Input)
            if IsInputButton1(Input) and LongPressThread then
                task.cancel(LongPressThread);
                LongPressThread = nil;
            end
        end)

        Library:GiveSignal(InputService.InputBegan:Connect(function(Input)
            if (not Picking) then
                if KeyPicker.Mode == 'Toggle' then
                    local Key = KeyPicker.Value;

                    if Key == 'MB1' or Key == 'MB2' then
                        if Key == 'MB1' and Input.UserInputType == Enum.UserInputType.MouseButton1
                            or Key == 'MB2' and Input.UserInputType == Enum.UserInputType.MouseButton2 then
                            KeyPicker.Toggled = not KeyPicker.Toggled
                            KeyPicker:DoClick()
                        end;
                    elseif Key == 'Touch' and Input.UserInputType == Enum.UserInputType.Touch then
                        KeyPicker.Toggled = not KeyPicker.Toggled
                        KeyPicker:DoClick()
                    elseif Input.UserInputType == Enum.UserInputType.Keyboard then
                        if Input.KeyCode.Name == Key then
                            KeyPicker.Toggled = not KeyPicker.Toggled;
                            KeyPicker:DoClick()
                        end;
                    end;
                end;

                KeyPicker:Update();
            end;

            if IsInputButton1(Input) then
                local mX, mY = GetInputPosition();
                local AbsPos, AbsSize = ModeSelectOuter.AbsolutePosition, ModeSelectOuter.AbsoluteSize;

                if mX < AbsPos.X or mX > AbsPos.X + AbsSize.X
                    or mY < (AbsPos.Y - 20 - 1) or mY > AbsPos.Y + AbsSize.Y then

                    ModeSelectOuter.Visible = false;
                end;
            end;
        end))

        Library:GiveSignal(InputService.InputEnded:Connect(function(Input)
            if (not Picking) then
                KeyPicker:Update();
            end;
        end))

        KeyPicker:Update();

        Options[Idx] = KeyPicker;

        return self;
    end;

    BaseAddons.__index = Funcs;
    BaseAddons.__namecall = function(Table, Key, ...)
        return Funcs[Key](...);
    end;
end;

local BaseGroupbox = {};

do
    local Funcs = {};

    function Funcs:AddBlank(Size)
        local Groupbox = self;
        local Container = Groupbox.Container;

        Library:Create('Frame', {
            BackgroundTransparency = 1;
            Size = UDim2.new(1, 0, 0, Size);
            ZIndex = 1;
            Parent = Container;
        });
    end;

    function Funcs:AddLabel(Text, DoesWrap)
        local Label = {};

        local Groupbox = self;
        local Container = Groupbox.Container;

        local TextLabel = Library:CreateLabel({
            Size = UDim2.new(1, -4, 0, 15 * S);
            TextSize = 14 * S;
            Text = Text;
            TextWrapped = DoesWrap or false,
            TextXAlignment = Enum.TextXAlignment.Left;
            ZIndex = 5;
            Parent = Container;
        });

        if DoesWrap then
            local Y = select(2, Library:GetTextBounds(Text, Library.Font, 14, Vector2.new(TextLabel.AbsoluteSize.X, math.huge)))
            TextLabel.Size = UDim2.new(1, -4, 0, Y)
        else
            Library:Create('UIListLayout', {
                Padding = UDim.new(0, 4);
                FillDirection = Enum.FillDirection.Horizontal;
                HorizontalAlignment = Enum.HorizontalAlignment.Right;
                SortOrder = Enum.SortOrder.LayoutOrder;
                Parent = TextLabel;
            });
        end

        Label.TextLabel = TextLabel;
        Label.Container = Container;

        function Label:SetText(Text)
            TextLabel.Text = Text

            if DoesWrap then
                local Y = select(2, Library:GetTextBounds(Text, Library.Font, 14, Vector2.new(TextLabel.AbsoluteSize.X, math.huge)))
                TextLabel.Size = UDim2.new(1, -4, 0, Y)
            end

            Groupbox:Resize();
        end

        if (not DoesWrap) then
            setmetatable(Label, BaseAddons);
        end

        Groupbox:AddBlank(5);
        Groupbox:Resize();

        return Label;
    end;

    function Funcs:AddButton(...)
        local Button = {};
        local function ProcessButtonParams(Class, Obj, ...)
            local Props = select(1, ...)
            if type(Props) == 'table' then
                Obj.Text = Props.Text
                Obj.Func = Props.Func
                Obj.DoubleClick = Props.DoubleClick
                Obj.Tooltip = Props.Tooltip
            else
                Obj.Text = select(1, ...)
                Obj.Func = select(2, ...)
            end

            assert(type(Obj.Func) == 'function', 'AddButton: `Func` callback is missing.');
        end

        ProcessButtonParams('Button', Button, ...)

        local Groupbox = self;
        local Container = Groupbox.Container;

        local function CreateBaseButton(Button)
            local Outer = Library:Create('Frame', {
                BackgroundColor3 = Color3.new(0, 0, 0);
                BorderColor3 = Color3.new(0, 0, 0);
                Size = UDim2.new(1, -4, 0, 20 * S);
                ZIndex = 5;
            });

            local Inner = Library:Create('Frame', {
                BackgroundColor3 = Library.MainColor;
                BorderColor3 = Library.OutlineColor;
                BorderMode = Enum.BorderMode.Inset;
                Size = UDim2.new(1, 0, 1, 0);
                ZIndex = 6;
                Parent = Outer;
            });

            local Label = Library:CreateLabel({
                Size = UDim2.new(1, 0, 1, 0);
                TextSize = 14 * S;
                Text = Button.Text;
                ZIndex = 6;
                Parent = Inner;
            });

            Library:Create('UIGradient', {
                Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, Color3.new(1, 1, 1)),
                    ColorSequenceKeypoint.new(1, Color3.fromRGB(212, 212, 212))
                });
                Rotation = 90;
                Parent = Inner;
            });

            Library:AddToRegistry(Outer, {
                BorderColor3 = 'Black';
            });

            Library:AddToRegistry(Inner, {
                BackgroundColor3 = 'MainColor';
                BorderColor3 = 'OutlineColor';
            });

            Library:OnHighlight(Outer, Outer,
                { BorderColor3 = 'AccentColor' },
                { BorderColor3 = 'Black' }
            );

            return Outer, Inner, Label
        end

        local function InitEvents(Button)
            local function WaitForEvent(event, timeout, validator)
                local bindable = Instance.new('BindableEvent')
                local connection = event:Once(function(...)

                    if type(validator) == 'function' and validator(...) then
                        bindable:Fire(true)
                    else
                        bindable:Fire(false)
                    end
                end)
                task.delay(timeout, function()
                    connection:disconnect()
                    bindable:Fire(false)
                end)
                return bindable.Event:Wait()
            end

            local function ValidateClick(Input)
                if Library:MouseIsOverOpenedFrame() then
                    return false
                end

                if not IsInputButton1(Input) then
                    return false
                end

                return true
            end

            Button.Outer.InputBegan:Connect(function(Input)
                if not ValidateClick(Input) then return end
                if Button.Locked then return end

                if Button.DoubleClick then
                    Library:RemoveFromRegistry(Button.Label)
                    Library:AddToRegistry(Button.Label, { TextColor3 = 'AccentColor' })

                    Button.Label.TextColor3 = Library.AccentColor
                    Button.Label.Text = 'Are you sure?'
                    Button.Locked = true

                    local clicked = WaitForEvent(Button.Outer.InputBegan, 0.5, ValidateClick)

                    Library:RemoveFromRegistry(Button.Label)
                    Library:AddToRegistry(Button.Label, { TextColor3 = 'FontColor' })

                    Button.Label.TextColor3 = Library.FontColor
                    Button.Label.Text = Button.Text
                    task.defer(rawset, Button, 'Locked', false)

                    if clicked then
                        Library:SafeCallback(Button.Func)
                    end

                    return
                end

                Library:SafeCallback(Button.Func);
            end)
        end

        Button.Outer, Button.Inner, Button.Label = CreateBaseButton(Button)
        Button.Outer.Parent = Container

        InitEvents(Button)

        function Button:AddTooltip(tooltip)
            if type(tooltip) == 'string' then
                Library:AddToolTip(tooltip, self.Outer)
            end
            return self
        end

        function Button:AddButton(...)
            local SubButton = {}

            ProcessButtonParams('SubButton', SubButton, ...)

            self.Outer.Size = UDim2.new(0.5, -2, 0, 20)

            SubButton.Outer, SubButton.Inner, SubButton.Label = CreateBaseButton(SubButton)

            SubButton.Outer.Position = UDim2.new(1, 3, 0, 0)
            SubButton.Outer.Size = UDim2.fromOffset(self.Outer.AbsoluteSize.X - 2, self.Outer.AbsoluteSize.Y)
            SubButton.Outer.Parent = self.Outer

            function SubButton:AddTooltip(tooltip)
                if type(tooltip) == 'string' then
                    Library:AddToolTip(tooltip, self.Outer)
                end
                return SubButton
            end

            if type(SubButton.Tooltip) == 'string' then
                SubButton:AddTooltip(SubButton.Tooltip)
            end

            InitEvents(SubButton)
            return SubButton
        end

        if type(Button.Tooltip) == 'string' then
            Button:AddTooltip(Button.Tooltip)
        end

        Groupbox:AddBlank(5);
        Groupbox:Resize();

        return Button;
    end;

    function Funcs:AddDivider()
        local Groupbox = self;
        local Container = self.Container

        local Divider = {
            Type = 'Divider',
        }

        Groupbox:AddBlank(2);
        local DividerOuter = Library:Create('Frame', {
            BackgroundColor3 = Color3.new(0, 0, 0);
            BorderColor3 = Color3.new(0, 0, 0);
            Size = UDim2.new(1, -4, 0, 5 * S);
            ZIndex = 5;
            Parent = Container;
        });

        local DividerInner = Library:Create('Frame', {
            BackgroundColor3 = Library.MainColor;
            BorderColor3 = Library.OutlineColor;
            BorderMode = Enum.BorderMode.Inset;
            Size = UDim2.new(1, 0, 1, 0);
            ZIndex = 6;
            Parent = DividerOuter;
        });

        Library:AddToRegistry(DividerOuter, {
            BorderColor3 = 'Black';
        });

        Library:AddToRegistry(DividerInner, {
            BackgroundColor3 = 'MainColor';
            BorderColor3 = 'OutlineColor';
        });

        Groupbox:AddBlank(9);
        Groupbox:Resize();
    end

    function Funcs:AddInput(Idx, Info)
        assert(Info.Text, 'AddInput: Missing `Text` string.')

        local Textbox = {
            Value = Info.Default or '';
            Numeric = Info.Numeric or false;
            Finished = Info.Finished or false;
            Type = 'Input';
            Callback = Info.Callback or function(Value) end;
        };

        local Groupbox = self;
        local Container = Groupbox.Container;

        local InputLabel = Library:CreateLabel({
            Size = UDim2.new(1, 0, 0, 15 * S);
            TextSize = 14 * S;
            Text = Info.Text;
            TextXAlignment = Enum.TextXAlignment.Left;
            ZIndex = 5;
            Parent = Container;
        });

        Groupbox:AddBlank(1);

        local TextBoxOuter = Library:Create('Frame', {
            BackgroundColor3 = Color3.new(0, 0, 0);
            BorderColor3 = Color3.new(0, 0, 0);
            Size = UDim2.new(1, -4, 0, 20 * S);
            ZIndex = 5;
            Parent = Container;
        });

        local TextBoxInner = Library:Create('Frame', {
            BackgroundColor3 = Library.MainColor;
            BorderColor3 = Library.OutlineColor;
            BorderMode = Enum.BorderMode.Inset;
            Size = UDim2.new(1, 0, 1, 0);
            ZIndex = 6;
            Parent = TextBoxOuter;
        });

        Library:AddToRegistry(TextBoxInner, {
            BackgroundColor3 = 'MainColor';
            BorderColor3 = 'OutlineColor';
        });

        Library:OnHighlight(TextBoxOuter, TextBoxOuter,
            { BorderColor3 = 'AccentColor' },
            { BorderColor3 = 'Black' }
        );

        if type(Info.Tooltip) == 'string' then
            Library:AddToolTip(Info.Tooltip, TextBoxOuter)
        end

        Library:Create('UIGradient', {
            Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.new(1, 1, 1)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(212, 212, 212))
            });
            Rotation = 90;
            Parent = TextBoxInner;
        });

        local Container = Library:Create('Frame', {
            BackgroundTransparency = 1;
            ClipsDescendants = true;

            Position = UDim2.new(0, 5, 0, 0);
            Size = UDim2.new(1, -5, 1, 0);

            ZIndex = 7;
            Parent = TextBoxInner;
        })

        local Box = Library:Create('TextBox', {
            BackgroundTransparency = 1;

            Position = UDim2.fromOffset(0, 0),
            Size = UDim2.fromScale(5, 1),

            Font = Library.Font;
            PlaceholderColor3 = Color3.fromRGB(190, 190, 190);
            PlaceholderText = Info.Placeholder or '';

            Text = Info.Default or '';
            TextColor3 = Library.FontColor;
            TextSize = 14 * S;
            TextStrokeTransparency = 0;
            TextXAlignment = Enum.TextXAlignment.Left;

            ZIndex = 7;
            Parent = Container;
        });

        Library:ApplyTextStroke(Box);

        function Textbox:SetValue(Text)
            if Info.MaxLength and #Text > Info.MaxLength then
                Text = Text:sub(1, Info.MaxLength);
            end;

            if Textbox.Numeric then
                if (not tonumber(Text)) and Text:len() > 0 then
                    Text = Textbox.Value
                end
            end

            Textbox.Value = Text;
            Box.Text = Text;

            Library:SafeCallback(Textbox.Callback, Textbox.Value);
            Library:SafeCallback(Textbox.Changed, Textbox.Value);
        end;

        if Textbox.Finished then
            Box.FocusLost:Connect(function(enter)
                if not enter then return end

                Textbox:SetValue(Box.Text);
                Library:AttemptSave();
            end)
        else
            Box:GetPropertyChangedSignal('Text'):Connect(function()
                Textbox:SetValue(Box.Text);
                Library:AttemptSave();
            end);
        end

        local function Update()
            local PADDING = 2
            local reveal = Container.AbsoluteSize.X

            if not Box:IsFocused() or Box.TextBounds.X <= reveal - 2 * PADDING then
                Box.Position = UDim2.new(0, PADDING, 0, 0)
            else
                local cursor = Box.CursorPosition
                if cursor ~= -1 then
                    local subtext = string.sub(Box.Text, 1, cursor-1)
                    local width = TextService:GetTextSize(subtext, Box.TextSize, Box.Font, Vector2.new(math.huge, math.huge)).X

                    local currentCursorPos = Box.Position.X.Offset + width

                    if currentCursorPos < PADDING then
                        Box.Position = UDim2.fromOffset(PADDING-width, 0)
                    elseif currentCursorPos > reveal - PADDING - 1 then
                        Box.Position = UDim2.fromOffset(reveal-width-PADDING-1, 0)
                    end
                end
            end
        end

        task.spawn(Update)

        Box:GetPropertyChangedSignal('Text'):Connect(Update)
        Box:GetPropertyChangedSignal('CursorPosition'):Connect(Update)
        Box.FocusLost:Connect(Update)
        Box.Focused:Connect(Update)

        Library:AddToRegistry(Box, {
            TextColor3 = 'FontColor';
        });

        function Textbox:OnChanged(Func)
            Textbox.Changed = Func;
            Func(Textbox.Value);
        end;

        Groupbox:AddBlank(5);
        Groupbox:Resize();

        Options[Idx] = Textbox;

        return Textbox;
    end;

    function Funcs:AddToggle(Idx, Info)
        assert(Info.Text, 'AddInput: Missing `Text` string.')

        local Toggle = {
            Value = Info.Default or false;
            Type = 'Toggle';

            Callback = Info.Callback or function(Value) end;
            Addons = {},
            Risky = Info.Risky,
        };

        local Groupbox = self;
        local Container = Groupbox.Container;

        local ToggleOuter = Library:Create('Frame', {
            BackgroundColor3 = Color3.new(0, 0, 0);
            BorderColor3 = Color3.new(0, 0, 0);
            Size = UDim2.new(0, 13 * S, 0, 13 * S);
            ZIndex = 5;
            Parent = Container;
        });

        Library:AddToRegistry(ToggleOuter, {
            BorderColor3 = 'Black';
        });

        local ToggleInner = Library:Create('Frame', {
            BackgroundColor3 = Library.MainColor;
            BorderColor3 = Library.OutlineColor;
            BorderMode = Enum.BorderMode.Inset;
            Size = UDim2.new(1, 0, 1, 0);
            ZIndex = 6;
            Parent = ToggleOuter;
        });

        Library:AddToRegistry(ToggleInner, {
            BackgroundColor3 = 'MainColor';
            BorderColor3 = 'OutlineColor';
        });

        local ToggleLabel = Library:CreateLabel({
            Size = UDim2.new(0, 216 * S, 1, 0);
            Position = UDim2.new(1, 6 * S, 0, 0);
            TextSize = 14 * S;
            Text = Info.Text;
            TextXAlignment = Enum.TextXAlignment.Left;
            ZIndex = 6;
            Parent = ToggleInner;
        });

        Library:Create('UIListLayout', {
            Padding = UDim.new(0, 4);
            FillDirection = Enum.FillDirection.Horizontal;
            HorizontalAlignment = Enum.HorizontalAlignment.Right;
            SortOrder = Enum.SortOrder.LayoutOrder;
            Parent = ToggleLabel;
        });

        local ToggleRegion = Library:Create('Frame', {
            BackgroundTransparency = 1;
            Size = UDim2.new(0, 170 * S, 1, 0);
            ZIndex = 8;
            Parent = ToggleOuter;
        });

        Library:OnHighlight(ToggleRegion, ToggleOuter,
            { BorderColor3 = 'AccentColor' },
            { BorderColor3 = 'Black' }
        );

        function Toggle:UpdateColors()
            Toggle:Display();
        end;

        function Toggle:SetText(Text)
            ToggleLabel.Text = Text;
        end;

        if type(Info.Tooltip) == 'string' then
            Library:AddToolTip(Info.Tooltip, ToggleRegion)
        end

        function Toggle:Display()
            ToggleInner.BackgroundColor3 = Toggle.Value and Library.AccentColor or Library.MainColor;
            ToggleInner.BorderColor3 = Toggle.Value and Library.AccentColorDark or Library.OutlineColor;

            Library.RegistryMap[ToggleInner].Properties.BackgroundColor3 = Toggle.Value and 'AccentColor' or 'MainColor';
            Library.RegistryMap[ToggleInner].Properties.BorderColor3 = Toggle.Value and 'AccentColorDark' or 'OutlineColor';
        end;

        function Toggle:OnChanged(Func)
            Toggle.Changed = Func;
            Func(Toggle.Value);
        end;

        function Toggle:SetValue(Bool)
            Bool = (not not Bool);

            Toggle.Value = Bool;
            Toggle:Display();

            for _, Addon in next, Toggle.Addons do
                if Addon.Type == 'KeyPicker' and Addon.SyncToggleState then
                    Addon.Toggled = Bool
                    Addon:Update()
                end
            end

            Library:SafeCallback(Toggle.Callback, Toggle.Value);
            Library:SafeCallback(Toggle.Changed, Toggle.Value);
            Library:UpdateDependencyBoxes();
        end;

        ToggleRegion.InputBegan:Connect(function(Input)
            if IsInputButton1(Input) and not Library:MouseIsOverOpenedFrame() then
                Toggle:SetValue(not Toggle.Value)
                Library:AttemptSave();
            end;
        end);

        if Toggle.Risky then
            Library:RemoveFromRegistry(ToggleLabel)
            ToggleLabel.TextColor3 = Library.RiskColor
            Library:AddToRegistry(ToggleLabel, { TextColor3 = 'RiskColor' })
        end

        Toggle:Display();
        Groupbox:AddBlank(Info.BlankSize or (5 + 2) * S);
        Groupbox:Resize();

        Toggle.TextLabel = ToggleLabel;
        Toggle.Container = Container;
        setmetatable(Toggle, BaseAddons);

        Toggles[Idx] = Toggle;

        Library:UpdateDependencyBoxes();

        return Toggle;
    end;

    function Funcs:AddSlider(Idx, Info)
        assert(Info.Default, 'AddSlider: Missing default value.');
        assert(Info.Text, 'AddSlider: Missing slider text.');
        assert(Info.Min, 'AddSlider: Missing minimum value.');
        assert(Info.Max, 'AddSlider: Missing maximum value.');
        assert(Info.Rounding, 'AddSlider: Missing rounding value.');

        local Slider = {
            Value = Info.Default;
            Min = Info.Min;
            Max = Info.Max;
            Rounding = Info.Rounding;
            MaxSize = 232 * S;
            Type = 'Slider';
            Callback = Info.Callback or function(Value) end;
        };

        local Groupbox = self;
        local Container = Groupbox.Container;

        if not Info.Compact then
            Library:CreateLabel({
                Size = UDim2.new(1, 0, 0, 10 * S);
                TextSize = 14 * S;
                Text = Info.Text;
                TextXAlignment = Enum.TextXAlignment.Left;
                TextYAlignment = Enum.TextYAlignment.Bottom;
                ZIndex = 5;
                Parent = Container;
            });

            Groupbox:AddBlank(3);
        end

        local SliderOuter = Library:Create('Frame', {
            BackgroundColor3 = Color3.new(0, 0, 0);
            BorderColor3 = Color3.new(0, 0, 0);
            Size = UDim2.new(1, -4, 0, 13 * S);
            ZIndex = 5;
            Parent = Container;
        });

        Library:AddToRegistry(SliderOuter, {
            BorderColor3 = 'Black';
        });

        local SliderInner = Library:Create('Frame', {
            BackgroundColor3 = Library.MainColor;
            BorderColor3 = Library.OutlineColor;
            BorderMode = Enum.BorderMode.Inset;
            Size = UDim2.new(1, 0, 1, 0);
            ZIndex = 6;
            Parent = SliderOuter;
        });

        Library:AddToRegistry(SliderInner, {
            BackgroundColor3 = 'MainColor';
            BorderColor3 = 'OutlineColor';
        });

        local Fill = Library:Create('Frame', {
            BackgroundColor3 = Library.AccentColor;
            BorderColor3 = Library.AccentColorDark;
            Size = UDim2.new(0, 0, 1, 0);
            ZIndex = 7;
            Parent = SliderInner;
        });

        Library:AddToRegistry(Fill, {
            BackgroundColor3 = 'AccentColor';
            BorderColor3 = 'AccentColorDark';
        });

        local HideBorderRight = Library:Create('Frame', {
            BackgroundColor3 = Library.AccentColor;
            BorderSizePixel = 0;
            Position = UDim2.new(1, 0, 0, 0);
            Size = UDim2.new(0, 1, 1, 0);
            ZIndex = 8;
            Parent = Fill;
        });

        Library:AddToRegistry(HideBorderRight, {
            BackgroundColor3 = 'AccentColor';
        });

        local DisplayLabel = Library:CreateLabel({
            Size = UDim2.new(1, 0, 1, 0);
            TextSize = 14 * S;
            Text = 'Infinite';
            ZIndex = 9;
            Parent = SliderInner;
        });

        Library:OnHighlight(SliderOuter, SliderOuter,
            { BorderColor3 = 'AccentColor' },
            { BorderColor3 = 'Black' }
        );

        if type(Info.Tooltip) == 'string' then
            Library:AddToolTip(Info.Tooltip, SliderOuter)
        end

        function Slider:UpdateColors()
            Fill.BackgroundColor3 = Library.AccentColor;
            Fill.BorderColor3 = Library.AccentColorDark;
        end;

        function Slider:Display()
            local Suffix = Info.Suffix or '';

            if Info.Compact then
                DisplayLabel.Text = Info.Text .. ': ' .. Slider.Value .. Suffix
            elseif Info.HideMax then
                DisplayLabel.Text = string.format('%s', Slider.Value .. Suffix)
            else
                DisplayLabel.Text = string.format('%s/%s', Slider.Value .. Suffix, Slider.Max .. Suffix);
            end

            local X = math.ceil(Library:MapValue(Slider.Value, Slider.Min, Slider.Max, 0, Slider.MaxSize));
            Fill.Size = UDim2.new(0, X, 1, 0);

            HideBorderRight.Visible = not (X == Slider.MaxSize or X == 0);
        end;

        function Slider:OnChanged(Func)
            Slider.Changed = Func;
            Func(Slider.Value);
        end;

        local function Round(Value)
            if Slider.Rounding == 0 then
                return math.floor(Value);
            end;

            return tonumber(string.format('%.' .. Slider.Rounding .. 'f', Value))
        end;

        function Slider:GetValueFromXOffset(X)
            return Round(Library:MapValue(X, 0, Slider.MaxSize, Slider.Min, Slider.Max));
        end;

        function Slider:SetValue(Str)
            local Num = tonumber(Str);

            if (not Num) then
                return;
            end;

            Num = math.clamp(Num, Slider.Min, Slider.Max);

            Slider.Value = Num;
            Slider:Display();

            Library:SafeCallback(Slider.Callback, Slider.Value);
            Library:SafeCallback(Slider.Changed, Slider.Value);
        end;

        SliderInner.InputBegan:Connect(function(Input)
            if IsInputButton1(Input) and not Library:MouseIsOverOpenedFrame() then
                local startX, _ = GetInputPosition();
                local gPos = Fill.Size.X.Offset;
                local Diff = startX - (Fill.AbsolutePosition.X + gPos);

                while IsInputActive() do
                    local nMX, _ = GetInputPosition();
                    local nX = math.clamp(gPos + (nMX - startX) + Diff, 0, Slider.MaxSize);

                    local nValue = Slider:GetValueFromXOffset(nX);
                    local OldValue = Slider.Value;
                    Slider.Value = nValue;

                    Slider:Display();

                    if nValue ~= OldValue then
                        Library:SafeCallback(Slider.Callback, Slider.Value);
                        Library:SafeCallback(Slider.Changed, Slider.Value);
                    end;

                    RenderStepped:Wait();
                end;

                Library:AttemptSave();
            end;
        end);

        Slider:Display();
        Groupbox:AddBlank(Info.BlankSize or 6);
        Groupbox:Resize();

        Options[Idx] = Slider;

        return Slider;
    end;

    function Funcs:AddDropdown(Idx, Info)
        if Info.SpecialType == 'Player' then
            Info.Values = GetPlayersString();
            Info.AllowNull = true;
        elseif Info.SpecialType == 'Team' then
            Info.Values = GetTeamsString();
            Info.AllowNull = true;
        end;

        assert(Info.Values, 'AddDropdown: Missing dropdown value list.');
        assert(Info.AllowNull or Info.Default, 'AddDropdown: Missing default value. Pass `AllowNull` as true if this was intentional.')

        if (not Info.Text) then
            Info.Compact = true;
        end;

        local Dropdown = {
            Values = Info.Values;
            Value = Info.Multi and {};
            Multi = Info.Multi;
            Type = 'Dropdown';
            SpecialType = Info.SpecialType;
            Callback = Info.Callback or function(Value) end;
        };

        local Groupbox = self;
        local Container = Groupbox.Container;

        local RelativeOffset = 0;

        if not Info.Compact then
            local DropdownLabel = Library:CreateLabel({
                Size = UDim2.new(1, 0, 0, 10);
                TextSize = 14;
                Text = Info.Text;
                TextXAlignment = Enum.TextXAlignment.Left;
                TextYAlignment = Enum.TextYAlignment.Bottom;
                ZIndex = 5;
                Parent = Container;
            });

            Groupbox:AddBlank(3);
        end

        for _, Element in next, Container:GetChildren() do
            if not Element:IsA('UIListLayout') then
                RelativeOffset = RelativeOffset + Element.Size.Y.Offset;
            end;
        end;

        local DropdownOuter = Library:Create('Frame', {
            BackgroundColor3 = Color3.new(0, 0, 0);
            BorderColor3 = Color3.new(0, 0, 0);
            Size = UDim2.new(1, -4, 0, 20 * S);
            ZIndex = 5;
            Parent = Container;
        });

        Library:AddToRegistry(DropdownOuter, {
            BorderColor3 = 'Black';
        });

        local DropdownInner = Library:Create('Frame', {
            BackgroundColor3 = Library.MainColor;
            BorderColor3 = Library.OutlineColor;
            BorderMode = Enum.BorderMode.Inset;
            Size = UDim2.new(1, 0, 1, 0);
            ZIndex = 6;
            Parent = DropdownOuter;
        });

        Library:AddToRegistry(DropdownInner, {
            BackgroundColor3 = 'MainColor';
            BorderColor3 = 'OutlineColor';
        });

        Library:Create('UIGradient', {
            Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.new(1, 1, 1)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(212, 212, 212))
            });
            Rotation = 90;
            Parent = DropdownInner;
        });

        local DropdownArrow = Library:Create('ImageLabel', {
            AnchorPoint = Vector2.new(0, 0.5);
            BackgroundTransparency = 1;
            Position = UDim2.new(1, -16 * S, 0.5, 0);
            Size = UDim2.new(0, 12 * S, 0, 12 * S);
            Image = 'http://www.roblox.com/asset/?id=6282522798';
            ZIndex = 8;
            Parent = DropdownInner;
        });

        local ItemList = Library:CreateLabel({
            Position = UDim2.new(0, 5, 0, 0);
            Size = UDim2.new(1, -5, 1, 0);
            TextSize = 14 * S;
            Text = '--';
            TextXAlignment = Enum.TextXAlignment.Left;
            TextWrapped = true;
            ZIndex = 7;
            Parent = DropdownInner;
        });

        Library:OnHighlight(DropdownOuter, DropdownOuter,
            { BorderColor3 = 'AccentColor' },
            { BorderColor3 = 'Black' }
        );

        if type(Info.Tooltip) == 'string' then
            Library:AddToolTip(Info.Tooltip, DropdownOuter)
        end

        local MAX_DROPDOWN_ITEMS = 8;

        local ListOuter = Library:Create('Frame', {
            BackgroundColor3 = Color3.new(0, 0, 0);
            BorderColor3 = Color3.new(0, 0, 0);
            ZIndex = 20;
            Visible = false;
            Parent = ScreenGui;
        });

        local function RecalculateListPosition()
            ListOuter.Position = UDim2.fromOffset(DropdownOuter.AbsolutePosition.X, DropdownOuter.AbsolutePosition.Y + DropdownOuter.Size.Y.Offset + 1);
        end;

        local function RecalculateListSize(YSize)
            ListOuter.Size = UDim2.fromOffset(DropdownOuter.AbsoluteSize.X, YSize or (MAX_DROPDOWN_ITEMS * 20 + 2))
        end;

        RecalculateListPosition();
        RecalculateListSize();

        DropdownOuter:GetPropertyChangedSignal('AbsolutePosition'):Connect(RecalculateListPosition);

        local ListInner = Library:Create('Frame', {
            BackgroundColor3 = Library.MainColor;
            BorderColor3 = Library.OutlineColor;
            BorderMode = Enum.BorderMode.Inset;
            BorderSizePixel = 0;
            Size = UDim2.new(1, 0, 1, 0);
            ZIndex = 21;
            Parent = ListOuter;
        });

        Library:AddToRegistry(ListInner, {
            BackgroundColor3 = 'MainColor';
            BorderColor3 = 'OutlineColor';
        });

        local Scrolling = Library:Create('ScrollingFrame', {
            BackgroundTransparency = 1;
            BorderSizePixel = 0;
            CanvasSize = UDim2.new(0, 0, 0, 0);
            Size = UDim2.new(1, 0, 1, 0);
            ZIndex = 21;
            Parent = ListInner;

            TopImage = 'rbxasset://textures/ui/Scroll/scroll-middle.png',
            BottomImage = 'rbxasset://textures/ui/Scroll/scroll-middle.png',

            ScrollBarThickness = 3,
            ScrollBarImageColor3 = Library.AccentColor,
        });

        Library:AddToRegistry(Scrolling, {
            ScrollBarImageColor3 = 'AccentColor'
        })

        Library:Create('UIListLayout', {
            Padding = UDim.new(0, 0);
            FillDirection = Enum.FillDirection.Vertical;
            SortOrder = Enum.SortOrder.LayoutOrder;
            Parent = Scrolling;
        });

        function Dropdown:Display()
            local Values = Dropdown.Values;
            local Str = '';

            if Info.Multi then
                for Idx, Value in next, Values do
                    if Dropdown.Value[Value] then
                        Str = Str .. Value .. ', ';
                    end;
                end;

                Str = Str:sub(1, #Str - 2);
            else
                Str = Dropdown.Value or '';
            end;

            ItemList.Text = (Str == '' and '--' or Str);
        end;

        function Dropdown:GetActiveValues()
            if Info.Multi then
                local T = {};

                for Value, Bool in next, Dropdown.Value do
                    table.insert(T, Value);
                end;

                return T;
            else
                return Dropdown.Value and 1 or 0;
            end;
        end;

        function Dropdown:BuildDropdownList()
            local Values = Dropdown.Values;
            local Buttons = {};

            for _, Element in next, Scrolling:GetChildren() do
                if not Element:IsA('UIListLayout') then
                    Element:Destroy();
                end;
            end;

            local Count = 0;

            for Idx, Value in next, Values do
                local Table = {};

                Count = Count + 1;

                local Button = Library:Create('Frame', {
                    BackgroundColor3 = Library.MainColor;
                    BorderColor3 = Library.OutlineColor;
                    BorderMode = Enum.BorderMode.Middle;
                    Size = UDim2.new(1, -1, 0, 20 * S);
                    ZIndex = 23;
                    Active = true,
                    Parent = Scrolling;
                });

                Library:AddToRegistry(Button, {
                    BackgroundColor3 = 'MainColor';
                    BorderColor3 = 'OutlineColor';
                });

                local ButtonLabel = Library:CreateLabel({
                    Active = false;
                    Size = UDim2.new(1, -6, 1, 0);
                    Position = UDim2.new(0, 6 * S, 0, 0);
                    TextSize = 14 * S;
                    Text = Value;
                    TextXAlignment = Enum.TextXAlignment.Left;
                    ZIndex = 25;
                    Parent = Button;
                });

                Library:OnHighlight(Button, Button,
                    { BorderColor3 = 'AccentColor', ZIndex = 24 },
                    { BorderColor3 = 'OutlineColor', ZIndex = 23 }
                );

                local Selected;

                if Info.Multi then
                    Selected = Dropdown.Value[Value];
                else
                    Selected = Dropdown.Value == Value;
                end;

                function Table:UpdateButton()
                    if Info.Multi then
                        Selected = Dropdown.Value[Value];
                    else
                        Selected = Dropdown.Value == Value;
                    end;

                    ButtonLabel.TextColor3 = Selected and Library.AccentColor or Library.FontColor;
                    Library.RegistryMap[ButtonLabel].Properties.TextColor3 = Selected and 'AccentColor' or 'FontColor';
                end;

                ButtonLabel.InputBegan:Connect(function(Input)
                    if IsInputButton1(Input) then
                        local Try = not Selected;

                        if Dropdown:GetActiveValues() == 1 and (not Try) and (not Info.AllowNull) then
                        else
                            if Info.Multi then
                                Selected = Try;

                                if Selected then
                                    Dropdown.Value[Value] = true;
                                else
                                    Dropdown.Value[Value] = nil;
                                end;
                            else
                                Selected = Try;

                                if Selected then
                                    Dropdown.Value = Value;
                                else
                                    Dropdown.Value = nil;
                                end;

                                for _, OtherButton in next, Buttons do
                                    OtherButton:UpdateButton();
                                end;
                            end;

                            Table:UpdateButton();
                            Dropdown:Display();

                            Library:SafeCallback(Dropdown.Callback, Dropdown.Value);
                            Library:SafeCallback(Dropdown.Changed, Dropdown.Value);

                            Library:AttemptSave();
                        end;
                    end;
                end);

                Table:UpdateButton();
                Dropdown:Display();

                Buttons[Button] = Table;
            end;

            Scrolling.CanvasSize = UDim2.fromOffset(0, (Count * 20 * S) + 1);

            local Y = math.clamp(Count * 20 * S, 0, MAX_DROPDOWN_ITEMS * 20 * S) + 1;
            RecalculateListSize(Y);
        end;

        function Dropdown:SetValues(NewValues)
            if NewValues then
                Dropdown.Values = NewValues;
            end;

            Dropdown:BuildDropdownList();
        end;

        function Dropdown:OpenDropdown()
            ListOuter.Visible = true;
            Library.OpenedFrames[ListOuter] = true;
            DropdownArrow.Rotation = 180;
        end;

        function Dropdown:CloseDropdown()
            ListOuter.Visible = false;
            Library.OpenedFrames[ListOuter] = nil;
            DropdownArrow.Rotation = 0;
        end;

        function Dropdown:OnChanged(Func)
            Dropdown.Changed = Func;
            Func(Dropdown.Value);
        end;

        function Dropdown:SetValue(Val)
            if Dropdown.Multi then
                local nTable = {};

                for Value, Bool in next, Val do
                    if table.find(Dropdown.Values, Value) then
                        nTable[Value] = true
                    end;
                end;

                Dropdown.Value = nTable;
            else
                if (not Val) then
                    Dropdown.Value = nil;
                elseif table.find(Dropdown.Values, Val) then
                    Dropdown.Value = Val;
                end;
            end;

            Dropdown:BuildDropdownList();

            Library:SafeCallback(Dropdown.Callback, Dropdown.Value);
            Library:SafeCallback(Dropdown.Changed, Dropdown.Value);
        end;

        DropdownOuter.InputBegan:Connect(function(Input)
            if IsInputButton1(Input) and not Library:MouseIsOverOpenedFrame() then
                if ListOuter.Visible then
                    Dropdown:CloseDropdown();
                else
                    Dropdown:OpenDropdown();
                end;
            end;
        end);

        InputService.InputBegan:Connect(function(Input)
            if IsInputButton1(Input) then
                local mX, mY = GetInputPosition();
                local AbsPos, AbsSize = ListOuter.AbsolutePosition, ListOuter.AbsoluteSize;

                if mX < AbsPos.X or mX > AbsPos.X + AbsSize.X
                    or mY < (AbsPos.Y - 20 - 1) or mY > AbsPos.Y + AbsSize.Y then

                    Dropdown:CloseDropdown();
                end;
            end;
        end);

        Dropdown:BuildDropdownList();
        Dropdown:Display();

        local Defaults = {}

        if type(Info.Default) == 'string' then
            local Idx = table.find(Dropdown.Values, Info.Default)
            if Idx then
                table.insert(Defaults, Idx)
            end
        elseif type(Info.Default) == 'table' then
            for _, Value in next, Info.Default do
                local Idx = table.find(Dropdown.Values, Value)
                if Idx then
                    table.insert(Defaults, Idx)
                end
            end
        elseif type(Info.Default) == 'number' and Dropdown.Values[Info.Default] ~= nil then
            table.insert(Defaults, Info.Default)
        end

        if next(Defaults) then
            for i = 1, #Defaults do
                local Index = Defaults[i]
                if Info.Multi then
                    Dropdown.Value[Dropdown.Values[Index]] = true
                else
                    Dropdown.Value = Dropdown.Values[Index];
                end

                if (not Info.Multi) then break end
            end

            Dropdown:BuildDropdownList();
            Dropdown:Display();
        end

        Groupbox:AddBlank(Info.BlankSize or 5);
        Groupbox:Resize();

        Options[Idx] = Dropdown;

        return Dropdown;
    end;

    function Funcs:AddDependencyBox()
        local Depbox = {
            Dependencies = {};
        };

        local Groupbox = self;
        local Container = Groupbox.Container;

        local Holder = Library:Create('Frame', {
            BackgroundTransparency = 1;
            Size = UDim2.new(1, 0, 0, 0);
            Visible = false;
            Parent = Container;
        });

        local Frame = Library:Create('Frame', {
            BackgroundTransparency = 1;
            Size = UDim2.new(1, 0, 1, 0);
            Visible = true;
            Parent = Holder;
        });

        local Layout = Library:Create('UIListLayout', {
            FillDirection = Enum.FillDirection.Vertical;
            SortOrder = Enum.SortOrder.LayoutOrder;
            Parent = Frame;
        });

        function Depbox:Resize()
            Holder.Size = UDim2.new(1, 0, 0, Layout.AbsoluteContentSize.Y);
            Groupbox:Resize();
        end;

        Layout:GetPropertyChangedSignal('AbsoluteContentSize'):Connect(function()
            Depbox:Resize();
        end);

        Holder:GetPropertyChangedSignal('Visible'):Connect(function()
            Depbox:Resize();
        end);

        function Depbox:Update()
            for _, Dependency in next, Depbox.Dependencies do
                local Elem = Dependency[1];
                local Value = Dependency[2];

                if Elem.Type == 'Toggle' and Elem.Value ~= Value then
                    Holder.Visible = false;
                    Depbox:Resize();
                    return;
                end;
            end;

            Holder.Visible = true;
            Depbox:Resize();
        end;

        function Depbox:SetupDependencies(Dependencies)
            for _, Dependency in next, Dependencies do
                assert(type(Dependency) == 'table', 'SetupDependencies: Dependency is not of type `table`.');
                assert(Dependency[1], 'SetupDependencies: Dependency is missing element argument.');
                assert(Dependency[2] ~= nil, 'SetupDependencies: Dependency is missing value argument.');
            end;

            Depbox.Dependencies = Dependencies;
            Depbox:Update();
        end;

        Depbox.Container = Frame;

        setmetatable(Depbox, BaseGroupbox);

        table.insert(Library.DependencyBoxes, Depbox);

        return Depbox;
    end;

    BaseGroupbox.__index = Funcs;
    BaseGroupbox.__namecall = function(Table, Key, ...)
        return Funcs[Key](...);
    end;
end;

do
    Library.NotificationArea = Library:Create('Frame', {
        BackgroundTransparency = 1;
        Position = UDim2.new(0, 0, 0, 40);
        Size = UDim2.new(0, 300, 0, 200);
        ZIndex = 100;
        Parent = ScreenGui;
    });

    Library:Create('UIListLayout', {
        Padding = UDim.new(0, 4);
        FillDirection = Enum.FillDirection.Vertical;
        SortOrder = Enum.SortOrder.LayoutOrder;
        Parent = Library.NotificationArea;
    });

    local WatermarkOuter = Library:Create('Frame', {
        BorderColor3 = Color3.new(0, 0, 0);
        Position = UDim2.new(0, 100, 0, -25);
        Size = UDim2.new(0, 213, 0, 20);
        ZIndex = 200;
        Visible = false;
        Parent = ScreenGui;
    });

    local WatermarkInner = Library:Create('Frame', {
        BackgroundColor3 = Library.MainColor;
        BorderColor3 = Library.AccentColor;
        BorderMode = Enum.BorderMode.Inset;
        Size = UDim2.new(1, 0, 1, 0);
        ZIndex = 201;
        Parent = WatermarkOuter;
    });

    Library:AddToRegistry(WatermarkInner, {
        BorderColor3 = 'AccentColor';
    });

    local InnerFrame = Library:Create('Frame', {
        BackgroundColor3 = Color3.new(1, 1, 1);
        BorderSizePixel = 0;
        Position = UDim2.new(0, 1, 0, 1);
        Size = UDim2.new(1, -2, 1, -2);
        ZIndex = 202;
        Parent = WatermarkInner;
    });

    local Gradient = Library:Create('UIGradient', {
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Library:GetDarkerColor(Library.MainColor)),
            ColorSequenceKeypoint.new(1, Library.MainColor),
        });
        Rotation = -90;
        Parent = InnerFrame;
    });

    Library:AddToRegistry(Gradient, {
        Color = function()
            return ColorSequence.new({
                ColorSequenceKeypoint.new(0, Library:GetDarkerColor(Library.MainColor)),
                ColorSequenceKeypoint.new(1, Library.MainColor),
            });
        end
    });

    local WatermarkLabel = Library:CreateLabel({
        Position = UDim2.new(0, 5, 0, 0);
        Size = UDim2.new(1, -4, 1, 0);
        TextSize = 14 * S;
        TextXAlignment = Enum.TextXAlignment.Left;
        ZIndex = 203;
        Parent = InnerFrame;
    });

    Library.Watermark = WatermarkOuter;
    Library.WatermarkText = WatermarkLabel;
    Library:MakeDraggable(Library.Watermark);

    local KeybindOuter = Library:Create('Frame', {
        AnchorPoint = Vector2.new(0, 0.5);
        BorderColor3 = Color3.new(0, 0, 0);
        Position = UDim2.new(0, 10, 0.5, 0);
        Size = UDim2.new(0, 210 * S, 0, 20 * S);
        Visible = false;
        ZIndex = 100;
        Parent = ScreenGui;
    });

    local KeybindInner = Library:Create('Frame', {
        BackgroundColor3 = Library.MainColor;
        BorderColor3 = Library.OutlineColor;
        BorderMode = Enum.BorderMode.Inset;
        Size = UDim2.new(1, 0, 1, 0);
        ZIndex = 101;
        Parent = KeybindOuter;
    });

    Library:AddToRegistry(KeybindInner, {
        BackgroundColor3 = 'MainColor';
        BorderColor3 = 'OutlineColor';
    }, true);

    local ColorFrame = Library:Create('Frame', {
        BackgroundColor3 = Library.AccentColor;
        BorderSizePixel = 0;
        Size = UDim2.new(1, 0, 0, 2);
        ZIndex = 102;
        Parent = KeybindInner;
    });

    Library:AddToRegistry(ColorFrame, {
        BackgroundColor3 = 'AccentColor';
    }, true);

    local KeybindLabel = Library:CreateLabel({
        Size = UDim2.new(1, 0, 0, 20 * S);
        Position = UDim2.fromOffset(5 * S, 2 * S),
        TextXAlignment = Enum.TextXAlignment.Left,

        Text = 'Keybinds';
        TextSize = 14 * S;
        ZIndex = 104;
        Parent = KeybindInner;
    });

    local KeybindContainer = Library:Create('Frame', {
        BackgroundTransparency = 1;
        Size = UDim2.new(1, 0, 1, -20 * S);
        Position = UDim2.new(0, 0, 0, 20 * S);
        ZIndex = 1;
        Parent = KeybindInner;
    });

    Library:Create('UIListLayout', {
        FillDirection = Enum.FillDirection.Vertical;
        SortOrder = Enum.SortOrder.LayoutOrder;
        Parent = KeybindContainer;
    });

    Library:Create('UIPadding', {
        PaddingLeft = UDim.new(0, 5),
        Parent = KeybindContainer,
    })

    Library.KeybindFrame = KeybindOuter;
    Library.KeybindContainer = KeybindContainer;
    Library:MakeDraggable(KeybindOuter);
end;

function Library:SetWatermarkVisibility(Bool)
    Library.Watermark.Visible = Bool;
end;

function Library:SetWatermark(Text)
    local X, Y = Library:GetTextBounds(Text, Library.Font, 14);
    Library.Watermark.Size = UDim2.new(0, (X + 15) * S, 0, ((Y * 1.5) + 3) * S);
    Library:SetWatermarkVisibility(true)

    Library.WatermarkText.Text = Text;
end;

function Library:Notify(Text, Time)
    local XSize, YSize = Library:GetTextBounds(Text, Library.Font, 14);

    YSize = YSize + 7

    local NotifyOuter = Library:Create('Frame', {
        BorderColor3 = Color3.new(0, 0, 0);
        Position = UDim2.new(0, 100, 0, 10);
        Size = UDim2.new(0, 0, 0, YSize);
        ClipsDescendants = true;
        ZIndex = 100;
        Parent = Library.NotificationArea;
    });

    local NotifyInner = Library:Create('Frame', {
        BackgroundColor3 = Library.MainColor;
        BorderColor3 = Library.OutlineColor;
        BorderMode = Enum.BorderMode.Inset;
        Size = UDim2.new(1, 0, 1, 0);
        ZIndex = 101;
        Parent = NotifyOuter;
    });

    Library:AddToRegistry(NotifyInner, {
        BackgroundColor3 = 'MainColor';
        BorderColor3 = 'OutlineColor';
    }, true);

    local InnerFrame = Library:Create('Frame', {
        BackgroundColor3 = Color3.new(1, 1, 1);
        BorderSizePixel = 0;
        Position = UDim2.new(0, 1, 0, 1);
        Size = UDim2.new(1, -2, 1, -2);
        ZIndex = 102;
        Parent = NotifyInner;
    });

    local Gradient = Library:Create('UIGradient', {
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Library:GetDarkerColor(Library.MainColor)),
            ColorSequenceKeypoint.new(1, Library.MainColor),
        });
        Rotation = -90;
        Parent = InnerFrame;
    });

    Library:AddToRegistry(Gradient, {
        Color = function()
            return ColorSequence.new({
                ColorSequenceKeypoint.new(0, Library:GetDarkerColor(Library.MainColor)),
                ColorSequenceKeypoint.new(1, Library.MainColor),
            });
        end
    });

    local NotifyLabel = Library:CreateLabel({
        Position = UDim2.new(0, 4, 0, 0);
        Size = UDim2.new(1, -4, 1, 0);
        Text = Text;
        TextXAlignment = Enum.TextXAlignment.Left;
        TextSize = 14 * S;
        ZIndex = 103;
        Parent = InnerFrame;
    });

    local LeftColor = Library:Create('Frame', {
        BackgroundColor3 = Library.AccentColor;
        BorderSizePixel = 0;
        Position = UDim2.new(0, -1, 0, -1);
        Size = UDim2.new(0, 3, 1, 2);
        ZIndex = 104;
        Parent = NotifyOuter;
    });

    Library:AddToRegistry(LeftColor, {
        BackgroundColor3 = 'AccentColor';
    }, true);

    pcall(NotifyOuter.TweenSize, NotifyOuter, UDim2.new(0, (XSize + 8 + 4) * S, 0, YSize), 'Out', 'Quad', 0.4, true);

    task.spawn(function()
        wait(Time or 5);

        pcall(NotifyOuter.TweenSize, NotifyOuter, UDim2.new(0, 0, 0, YSize), 'Out', 'Quad', 0.4, true);

        wait(0.4);

        NotifyOuter:Destroy();
    end);
end;

function Library:CreateWindow(...)
    local Arguments = { ... }
    local Config = { AnchorPoint = Vector2.zero }

    if type(...) == 'table' then
        Config = ...;
    else
        Config.Title = Arguments[1]
        Config.AutoShow = Arguments[2] or false;
    end

    if type(Config.Title) ~= 'string' then Config.Title = 'No title' end
    if type(Config.TabPadding) ~= 'number' then Config.TabPadding = 0 end
    if type(Config.MenuFadeTime) ~= 'number' then Config.MenuFadeTime = 0.2 end

    if typeof(Config.Position) ~= 'UDim2' then Config.Position = UDim2.fromOffset(175 * S, 50 * S) end
    if typeof(Config.Size) ~= 'UDim2' then Config.Size = UDim2.fromOffset(550 * S, 600 * S) end

    if Config.Center then
        Config.AnchorPoint = Vector2.new(0.5, 0.5)
        Config.Position = UDim2.fromScale(0.5, 0.5)
    end

    local Window = {
        Tabs = {};
    };

    local Outer = Library:Create('Frame', {
        AnchorPoint = Config.AnchorPoint,
        BackgroundColor3 = Color3.new(0, 0, 0);
        BorderSizePixel = 0;
        Position = Config.Position,
        Size = Config.Size,
        Visible = false;
        ZIndex = 1;
        Parent = ScreenGui;
    });

    Library:MakeDraggable(Outer, 25 * S);

    local Inner = Library:Create('Frame', {
        BackgroundColor3 = Library.MainColor;
        BorderColor3 = Library.AccentColor;
        BorderMode = Enum.BorderMode.Inset;
        Position = UDim2.new(0, 1, 0, 1);
        Size = UDim2.new(1, -2, 1, -2);
        ZIndex = 1;
        Parent = Outer;
    });

    Library:AddToRegistry(Inner, {
        BackgroundColor3 = 'MainColor';
        BorderColor3 = 'AccentColor';
    });

    local WindowLabel = Library:CreateLabel({
        Position = UDim2.new(0, 7, 0, 0);
        Size = UDim2.new(0, 0, 0, 25 * S);
        Text = Config.Title or '';
        TextXAlignment = Enum.TextXAlignment.Left;
        ZIndex = 1;
        Parent = Inner;
    });

    local MainSectionOuter = Library:Create('Frame', {
        BackgroundColor3 = Library.BackgroundColor;
        BorderColor3 = Library.OutlineColor;
        Position = UDim2.new(0, 8 * S, 0, 25 * S);
        Size = UDim2.new(1, -16 * S, 1, -33 * S);
        ZIndex = 1;
        Parent = Inner;
    });

    Library:AddToRegistry(MainSectionOuter, {
        BackgroundColor3 = 'BackgroundColor';
        BorderColor3 = 'OutlineColor';
    });

    local MainSectionInner = Library:Create('Frame', {
        BackgroundColor3 = Library.BackgroundColor;
        BorderColor3 = Color3.new(0, 0, 0);
        BorderMode = Enum.BorderMode.Inset;
        Position = UDim2.new(0, 0, 0, 0);
        Size = UDim2.new(1, 0, 1, 0);
        ZIndex = 1;
        Parent = MainSectionOuter;
    });

    Library:AddToRegistry(MainSectionInner, {
        BackgroundColor3 = 'BackgroundColor';
    });

    local TabArea = Library:Create('Frame', {
        BackgroundTransparency = 1;
        Position = UDim2.new(0, 8 * S, 0, 8 * S);
        Size = UDim2.new(1, -16 * S, 0, 21 * S);
        ZIndex = 1;
        Parent = MainSectionInner;
    });

    local TabListLayout = Library:Create('UIListLayout', {
        Padding = UDim.new(0, Config.TabPadding);
        FillDirection = Enum.FillDirection.Horizontal;
        SortOrder = Enum.SortOrder.LayoutOrder;
        Parent = TabArea;
    });

    local TabContainer = Library:Create('Frame', {
        BackgroundColor3 = Library.MainColor;
        BorderColor3 = Library.OutlineColor;
        Position = UDim2.new(0, 8 * S, 0, 30 * S);
        Size = UDim2.new(1, -16 * S, 1, -38 * S);
        ZIndex = 2;
        Parent = MainSectionInner;
    });

    Library:AddToRegistry(TabContainer, {
        BackgroundColor3 = 'MainColor';
        BorderColor3 = 'OutlineColor';
    });

    function Window:SetWindowTitle(Title)
        WindowLabel.Text = Title;
    end;

    function Window:AddTab(Name)
        local Tab = {
            Groupboxes = {};
            Tabboxes = {};
        };

        local TabButtonWidth = Library:GetTextBounds(Name, Library.Font, 16 * S);

        local TabButton = Library:Create('Frame', {
            BackgroundColor3 = Library.BackgroundColor;
            BorderColor3 = Library.OutlineColor;
            Size = UDim2.new(0, TabButtonWidth + (8 + 4) * S, 1, 0);
            ZIndex = 1;
            Parent = TabArea;
        });

        Library:AddToRegistry(TabButton, {
            BackgroundColor3 = 'BackgroundColor';
            BorderColor3 = 'OutlineColor';
        });

        local TabButtonLabel = Library:CreateLabel({
            Position = UDim2.new(0, 0, 0, 0);
            Size = UDim2.new(1, 0, 1, -1);
            Text = Name;
            TextSize = 16 * S;
            ZIndex = 1;
            Parent = TabButton;
        });

        local Blocker = Library:Create('Frame', {
            BackgroundColor3 = Library.MainColor;
            BorderSizePixel = 0;
            Position = UDim2.new(0, 0, 1, 0);
            Size = UDim2.new(1, 0, 0, 1);
            BackgroundTransparency = 1;
            ZIndex = 3;
            Parent = TabButton;
        });

        Library:AddToRegistry(Blocker, {
            BackgroundColor3 = 'MainColor';
        });

        local TabFrame = Library:Create('Frame', {
            Name = 'TabFrame',
            BackgroundTransparency = 1;
            Position = UDim2.new(0, 0, 0, 0);
            Size = UDim2.new(1, 0, 1, 0);
            Visible = false;
            ZIndex = 2;
            Parent = TabContainer;
        });

        local LeftSide = Library:Create('ScrollingFrame', {
            BackgroundTransparency = 1;
            BorderSizePixel = 0;
            Position = UDim2.new(0, 8 - 1, 0, 8 - 1);
            Size = UDim2.new(0.5, (-12 + 2) * S, 0, (507 + 2) * S);
            CanvasSize = UDim2.new(0, 0, 0, 0);
            BottomImage = '';
            TopImage = '';
            ScrollBarThickness = 0;
            ZIndex = 2;
            Parent = TabFrame;
        });

        local RightSide = Library:Create('ScrollingFrame', {
            BackgroundTransparency = 1;
            BorderSizePixel = 0;
            Position = UDim2.new(0.5, 4 + 1, 0, 8 - 1);
            Size = UDim2.new(0.5, (-12 + 2) * S, 0, (507 + 2) * S);
            CanvasSize = UDim2.new(0, 0, 0, 0);
            BottomImage = '';
            TopImage = '';
            ScrollBarThickness = 0;
            ZIndex = 2;
            Parent = TabFrame;
        });

        Library:Create('UIListLayout', {
            Padding = UDim.new(0, 8);
            FillDirection = Enum.FillDirection.Vertical;
            SortOrder = Enum.SortOrder.LayoutOrder;
            HorizontalAlignment = Enum.HorizontalAlignment.Center;
            Parent = LeftSide;
        });

        Library:Create('UIListLayout', {
            Padding = UDim.new(0, 8);
            FillDirection = Enum.FillDirection.Vertical;
            SortOrder = Enum.SortOrder.LayoutOrder;
            HorizontalAlignment = Enum.HorizontalAlignment.Center;
            Parent = RightSide;
        });

        for _, Side in next, { LeftSide, RightSide } do
            Side:WaitForChild('UIListLayout'):GetPropertyChangedSignal('AbsoluteContentSize'):Connect(function()
                Side.CanvasSize = UDim2.fromOffset(0, Side.UIListLayout.AbsoluteContentSize.Y);
            end);
        end;

        function Tab:ShowTab()
            for _, Tab in next, Window.Tabs do
                Tab:HideTab();
            end;

            Blocker.BackgroundTransparency = 0;
            TabButton.BackgroundColor3 = Library.MainColor;
            Library.RegistryMap[TabButton].Properties.BackgroundColor3 = 'MainColor';
            TabFrame.Visible = true;
        end;

        function Tab:HideTab()
            Blocker.BackgroundTransparency = 1;
            TabButton.BackgroundColor3 = Library.BackgroundColor;
            Library.RegistryMap[TabButton].Properties.BackgroundColor3 = 'BackgroundColor';
            TabFrame.Visible = false;
        end;

        function Tab:SetLayoutOrder(Position)
            TabButton.LayoutOrder = Position;
            TabListLayout:ApplyLayout();
        end;

        function Tab:AddGroupbox(Info)
            local Groupbox = {};

            local BoxOuter = Library:Create('Frame', {
                BackgroundColor3 = Library.BackgroundColor;
                BorderColor3 = Library.OutlineColor;
                BorderMode = Enum.BorderMode.Inset;
                Size = UDim2.new(1, 0, 0, 507 + 2);
                ZIndex = 2;
                Parent = Info.Side == 1 and LeftSide or RightSide;
            });

            Library:AddToRegistry(BoxOuter, {
                BackgroundColor3 = 'BackgroundColor';
                BorderColor3 = 'OutlineColor';
            });

            local BoxInner = Library:Create('Frame', {
                BackgroundColor3 = Library.BackgroundColor;
                BorderColor3 = Color3.new(0, 0, 0);
                Size = UDim2.new(1, -2, 1, -2);
                Position = UDim2.new(0, 1, 0, 1);
                ZIndex = 4;
                Parent = BoxOuter;
            });

            Library:AddToRegistry(BoxInner, {
                BackgroundColor3 = 'BackgroundColor';
            });

            local Highlight = Library:Create('Frame', {
                BackgroundColor3 = Library.AccentColor;
                BorderSizePixel = 0;
                Size = UDim2.new(1, 0, 0, 2);
                ZIndex = 5;
                Parent = BoxInner;
            });

            Library:AddToRegistry(Highlight, {
                BackgroundColor3 = 'AccentColor';
            });

            local GroupboxLabel = Library:CreateLabel({
                Size = UDim2.new(1, 0, 0, 18 * S);
                Position = UDim2.new(0, 4 * S, 0, 2 * S);
                TextSize = 14 * S;
                Text = Info.Name;
                TextXAlignment = Enum.TextXAlignment.Left;
                ZIndex = 5;
                Parent = BoxInner;
            });

            local Container = Library:Create('Frame', {
                BackgroundTransparency = 1;
                Position = UDim2.new(0, 4 * S, 0, 20 * S);
                Size = UDim2.new(1, -4 * S, 1, -20 * S);
                ZIndex = 1;
                Parent = BoxInner;
            });

            Library:Create('UIListLayout', {
                FillDirection = Enum.FillDirection.Vertical;
                SortOrder = Enum.SortOrder.LayoutOrder;
                Parent = Container;
            });

            function Groupbox:Resize()
                local Size = 0;

                for _, Element in next, Groupbox.Container:GetChildren() do
                    if (not Element:IsA('UIListLayout')) and Element.Visible then
                        Size = Size + Element.Size.Y.Offset;
                    end;
                end;

                BoxOuter.Size = UDim2.new(1, 0, 0, 20 * S + Size + 2 + 2);
            end;

            Groupbox.Container = Container;
            setmetatable(Groupbox, BaseGroupbox);

            Groupbox:AddBlank(3);
            Groupbox:Resize();

            Tab.Groupboxes[Info.Name] = Groupbox;

            return Groupbox;
        end;

        function Tab:AddLeftGroupbox(Name)
            return Tab:AddGroupbox({ Side = 1; Name = Name; });
        end;

        function Tab:AddRightGroupbox(Name)
            return Tab:AddGroupbox({ Side = 2; Name = Name; });
        end;

        function Tab:AddTabbox(Info)
            local Tabbox = {
                Tabs = {};
            };

            local BoxOuter = Library:Create('Frame', {
                BackgroundColor3 = Library.BackgroundColor;
                BorderColor3 = Library.OutlineColor;
                BorderMode = Enum.BorderMode.Inset;
                Size = UDim2.new(1, 0, 0, 0);
                ZIndex = 2;
                Parent = Info.Side == 1 and LeftSide or RightSide;
            });

            Library:AddToRegistry(BoxOuter, {
                BackgroundColor3 = 'BackgroundColor';
                BorderColor3 = 'OutlineColor';
            });

            local BoxInner = Library:Create('Frame', {
                BackgroundColor3 = Library.BackgroundColor;
                BorderColor3 = Color3.new(0, 0, 0);
                Size = UDim2.new(1, -2, 1, -2);
                Position = UDim2.new(0, 1, 0, 1);
                ZIndex = 4;
                Parent = BoxOuter;
            });

            Library:AddToRegistry(BoxInner, {
                BackgroundColor3 = 'BackgroundColor';
            });

            local Highlight = Library:Create('Frame', {
                BackgroundColor3 = Library.AccentColor;
                BorderSizePixel = 0;
                Size = UDim2.new(1, 0, 0, 2);
                ZIndex = 10;
                Parent = BoxInner;
            });

            Library:AddToRegistry(Highlight, {
                BackgroundColor3 = 'AccentColor';
            });

            local TabboxButtons = Library:Create('Frame', {
                BackgroundTransparency = 1;
                Position = UDim2.new(0, 0, 0, 1);
                Size = UDim2.new(1, 0, 0, 18 * S);
                ZIndex = 5;
                Parent = BoxInner;
            });

            Library:Create('UIListLayout', {
                FillDirection = Enum.FillDirection.Horizontal;
                HorizontalAlignment = Enum.HorizontalAlignment.Left;
                SortOrder = Enum.SortOrder.LayoutOrder;
                Parent = TabboxButtons;
            });

            function Tabbox:AddTab(Name)
                local Tab = {};

                local Button = Library:Create('Frame', {
                    BackgroundColor3 = Library.MainColor;
                    BorderColor3 = Color3.new(0, 0, 0);
                    Size = UDim2.new(0.5, 0, 1, 0);
                    ZIndex = 6;
                    Parent = TabboxButtons;
                });

                Library:AddToRegistry(Button, {
                    BackgroundColor3 = 'MainColor';
                });

                local ButtonLabel = Library:CreateLabel({
                    Size = UDim2.new(1, 0, 1, 0);
                    TextSize = 14 * S;
                    Text = Name;
                    TextXAlignment = Enum.TextXAlignment.Center;
                    ZIndex = 7;
                    Parent = Button;
                });

                local Block = Library:Create('Frame', {
                    BackgroundColor3 = Library.BackgroundColor;
                    BorderSizePixel = 0;
                    Position = UDim2.new(0, 0, 1, 0);
                    Size = UDim2.new(1, 0, 0, 1);
                    Visible = false;
                    ZIndex = 9;
                    Parent = Button;
                });

                Library:AddToRegistry(Block, {
                    BackgroundColor3 = 'BackgroundColor';
                });

                local Container = Library:Create('Frame', {
                    BackgroundTransparency = 1;
                    Position = UDim2.new(0, 4 * S, 0, 20 * S);
                    Size = UDim2.new(1, -4 * S, 1, -20 * S);
                    ZIndex = 1;
                    Visible = false;
                    Parent = BoxInner;
                });

                Library:Create('UIListLayout', {
                    FillDirection = Enum.FillDirection.Vertical;
                    SortOrder = Enum.SortOrder.LayoutOrder;
                    Parent = Container;
                });

                function Tab:Show()
                    for _, Tab in next, Tabbox.Tabs do
                        Tab:Hide();
                    end;

                    Container.Visible = true;
                    Block.Visible = true;

                    Button.BackgroundColor3 = Library.BackgroundColor;
                    Library.RegistryMap[Button].Properties.BackgroundColor3 = 'BackgroundColor';

                    Tab:Resize();
                end;

                function Tab:Hide()
                    Container.Visible = false;
                    Block.Visible = false;

                    Button.BackgroundColor3 = Library.MainColor;
                    Library.RegistryMap[Button].Properties.BackgroundColor3 = 'MainColor';
                end;

                function Tab:Resize()
                    local TabCount = 0;

                    for _, Tab in next, Tabbox.Tabs do
                        TabCount = TabCount + 1;
                    end;

                    for _, Button in next, TabboxButtons:GetChildren() do
                        if not Button:IsA('UIListLayout') then
                            Button.Size = UDim2.new(1 / TabCount, 0, 1, 0);
                        end;
                    end;

                    if (not Container.Visible) then
                        return;
                    end;

                    local Size = 0;

                    for _, Element in next, Tab.Container:GetChildren() do
                        if (not Element:IsA('UIListLayout')) and Element.Visible then
                            Size = Size + Element.Size.Y.Offset;
                        end;
                    end;

                    BoxOuter.Size = UDim2.new(1, 0, 0, 20 * S + Size + 2 + 2);
                end;

                Button.InputBegan:Connect(function(Input)
                    if IsInputButton1(Input) and not Library:MouseIsOverOpenedFrame() then
                        Tab:Show();
                        Tab:Resize();
                    end;
                end);

                Tab.Container = Container;
                Tabbox.Tabs[Name] = Tab;

                setmetatable(Tab, BaseGroupbox);

                Tab:AddBlank(3);
                Tab:Resize();

                if #TabboxButtons:GetChildren() == 2 then
                    Tab:Show();
                end;

                return Tab;
            end;

            Tab.Tabboxes[Info.Name or ''] = Tabbox;

            return Tabbox;
        end;

        function Tab:AddLeftTabbox(Name)
            return Tab:AddTabbox({ Name = Name, Side = 1; });
        end;

        function Tab:AddRightTabbox(Name)
            return Tab:AddTabbox({ Name = Name, Side = 2; });
        end;

        TabButton.InputBegan:Connect(function(Input)
            if IsInputButton1(Input) then
                Tab:ShowTab();
            end;
        end);

        if #TabContainer:GetChildren() == 1 then
            Tab:ShowTab();
        end;

        Window.Tabs[Name] = Tab;
        return Tab;
    end;

    local ModalElement = Library:Create('TextButton', {
        BackgroundTransparency = 1;
        Size = UDim2.new(0, 0, 0, 0);
        Visible = true;
        Text = '';
        Modal = false;
        Parent = ScreenGui;
    });

    local TransparencyCache = {};
    local Toggled = false;
    local Fading = false;

    function Library:Toggle()
        if Fading then
            return;
        end;

        local FadeTime = Config.MenuFadeTime;
        Fading = true;
        Toggled = (not Toggled);
        ModalElement.Modal = Toggled;

        if Toggled and not IsMobile then
            task.spawn(function()
                local State = InputService.MouseIconEnabled;

                local Cursor = Drawing.new('Triangle');
                Cursor.Thickness = 1;
                Cursor.Filled = true;
                Cursor.Visible = true;

                local CursorOutline = Drawing.new('Triangle');
                CursorOutline.Thickness = 1;
                CursorOutline.Filled = false;
                CursorOutline.Color = Color3.new(0, 0, 0);
                CursorOutline.Visible = true;

                while Toggled and ScreenGui.Parent do
                    InputService.MouseIconEnabled = false;

                    local mPos = InputService:GetMouseLocation();

                    Cursor.Color = Library.AccentColor;

                    Cursor.PointA = Vector2.new(mPos.X, mPos.Y);
                    Cursor.PointB = Vector2.new(mPos.X + 16, mPos.Y + 6);
                    Cursor.PointC = Vector2.new(mPos.X + 6, mPos.Y + 16);

                    CursorOutline.PointA = Cursor.PointA;
                    CursorOutline.PointB = Cursor.PointB;
                    CursorOutline.PointC = Cursor.PointC;

                    RenderStepped:Wait();
                end;

                InputService.MouseIconEnabled = State;

                Cursor:Remove();
                CursorOutline:Remove();
            end);
        end

        for _, Desc in next, Outer:GetDescendants() do
            local Properties = {};

            if Desc:IsA('ImageLabel') then
                table.insert(Properties, 'ImageTransparency');
                table.insert(Properties, 'BackgroundTransparency');
            elseif Desc:IsA('TextLabel') or Desc:IsA('TextBox') then
                table.insert(Properties, 'TextTransparency');
            elseif Desc:IsA('Frame') or Desc:IsA('ScrollingFrame') then
                table.insert(Properties, 'BackgroundTransparency');
            elseif Desc:IsA('UIStroke') then
                table.insert(Properties, 'Transparency');
            end;

            local Cache = TransparencyCache[Desc];

            if (not Cache) then
                Cache = {};
                TransparencyCache[Desc] = Cache;
            end;

            for _, Prop in next, Properties do
                if not Cache[Prop] then
                    Cache[Prop] = Desc[Prop];
                end;

                if Cache[Prop] == 1 then
                    continue;
                end;

                TweenService:Create(Desc, TweenInfo.new(FadeTime, Enum.EasingStyle.Linear), { [Prop] = Toggled and Cache[Prop] or 1 }):Play();
            end;
        end;

        task.wait(FadeTime);

        Outer.Visible = Toggled;

        Fading = false;
    end

    if IsMobile then
        local tapCount = 0
        local tapTimer = 0

        Library:GiveSignal(InputService.TouchStarted:Connect(function()
            tapCount = tapCount + 1
            tapTimer = tick()

            task.delay(0.5, function()
                if tick() - tapTimer >= 0.5 then
                    tapCount = 0
                end
            end)

            if tapCount >= Library.MobileToggleTaps then
                tapCount = 0
                task.spawn(Library.Toggle)
            end
        end))
    end

    Library:GiveSignal(InputService.InputBegan:Connect(function(Input, Processed)
        if type(Library.ToggleKeybind) == 'table' and Library.ToggleKeybind.Type == 'KeyPicker' then
            if Input.UserInputType == Enum.UserInputType.Keyboard and Input.KeyCode.Name == Library.ToggleKeybind.Value then
                task.spawn(Library.Toggle)
            end
        elseif Input.KeyCode == Enum.KeyCode.RightControl or (Input.KeyCode == Enum.KeyCode.RightShift and (not Processed)) then
            task.spawn(Library.Toggle)
        end
    end))

    if Config.AutoShow then task.spawn(Library.Toggle) end

    Window.Holder = Outer;

    return Window;
end;

local function OnPlayerChange()
    local PlayerList = GetPlayersString();

    for _, Value in next, Options do
        if Value.Type == 'Dropdown' and Value.SpecialType == 'Player' then
            Value:SetValues(PlayerList);
        end;
    end;
end;

Players.PlayerAdded:Connect(OnPlayerChange);
Players.PlayerRemoving:Connect(OnPlayerChange);

getgenv().Library = Library
return Library
]==]getgenv().Library = loadstring(LIZARD_LIBRARY_SOURCE)()

getgenv().SaveManager = {
    Library = nil,
    Folder = 'ghosted/config',
    SetLibrary = function(self, lib) self.Library = lib if lib then lib.SaveManager = self end end,
    SetFolder = function(self, folder) self.Folder = folder end,
    BuildConfigSection = function(self) end,
    IgnoreThemeSettings = function(self) end,
    SetIgnoreIndexes = function(self) end,
    LoadAutoloadConfig = function(self) end,
    Save = function(self) end,
}

getgenv().ThemeManager = {
    Library = nil,
    Folder = 'ghosted',
    SetLibrary = function(self, lib) self.Library = lib end,
    SetFolder = function(self, folder) self.Folder = folder end,
    ApplyToTab = function(self, tab)
        if not (tab and tab.AddLeftGroupbox) then return end
        if getgenv().Options and getgenv().Options.AccentColor then return end
        local ok, gb = pcall(function() return tab:AddLeftGroupbox('Theme') end)
        if not ok or not gb then return end
        pcall(function()
            gb:AddLabel('Accent Color'):AddColorPicker('AccentColor', {
                Default = Color3.fromRGB(0, 85, 255),
                Title = 'Accent Color',
                Callback = function(c)
                    local lib = getgenv().Library
                    if lib then
                        lib.AccentColor = c
                        lib.AccentColorDark = lib:GetDarkerColor(c)
                        lib:UpdateColorsUsingRegistry()
                    end
                end,
            })
        end)
    end,
}

local currentPlaceId = game.PlaceId
local isFFAPlace = currentPlaceId == 138995385694035
local isHoodCustomPlace = currentPlaceId == 9825515356
getgenv().ForceDefaultHudVisible = isFFAPlace
getgenv().gameName = isFFAPlace and 'lizard | Hood Customs Free For All' or 'lizard | Hood Custom'
if isHoodCustomPlace then
    getgenv().gameName = 'lizard | Hood Customs'
end

pcall(function()
    if setfpscap then setfpscap(32555555555555555) end
end)

getgenv().LizardGen = (getgenv().LizardGen or 0) + 1
local lizardGen = getgenv().LizardGen

for _, connName in ipairs({
    'ForceHitConnection', 'MainHeartbeatConnection', 'LizardWeatherConn',
    'WatermarkConnection', 'TargetHealthConnection', 'TargetCleanupConnection',
    'StrafeConnection', 'SpectateConnection', 'ESPConnection',
    'LegitAimConnection', 'KnifeGlueConn', 'AutoReloadConnection',
    'CrosshairConnection', 'HUDConnection', 'DesyncIndicatorConnection',
    'FOVConnection', 'FlyConn', 'TargetRespawnConnection',
}) do
    local c = getgenv()[connName]
    if c and c.Disconnect then pcall(function() c:Disconnect() end) end
    getgenv()[connName] = nil
end
if getgenv().Misc and getgenv().Misc.SpinConnection then
    pcall(function() getgenv().Misc.SpinConnection:Disconnect() end)
    getgenv().Misc.SpinConnection = nil
end
if getgenv().LizardOldNamecall then
    pcall(function() hookmetamethod(game, "__namecall", getgenv().LizardOldNamecall) end)
    getgenv().LizardOldNamecall = nil
end

task.spawn(function()
    local localPlayer = getgenv().LocalPlayer
    while task.wait(1) do
        if getgenv().LizardGen ~= lizardGen then break end
        if not localPlayer or localPlayer.Parent == nil then
            localPlayer = Players.LocalPlayer
            getgenv().LocalPlayer = localPlayer
        end
        local dataFolder = localPlayer and localPlayer:FindFirstChild("DataFolder")
        local subscription = dataFolder and dataFolder:FindFirstChild("Subscription")
        local hasSubscription = subscription and subscription:FindFirstChild("HasSubscription")
        local subscriptionStreak = subscription and subscription:FindFirstChild("SubscriptionStreak")
        local subscriptionData = subscription and subscription:FindFirstChild("SubscriptionData")
        if hasSubscription and hasSubscription:IsA("BoolValue") then
            hasSubscription.Value = true
        end
        if subscriptionStreak and (subscriptionStreak:IsA("IntValue") or subscriptionStreak:IsA("NumberValue")) then
            subscriptionStreak.Value = 67
        end
        if subscriptionData and (subscriptionData:IsA("IntValue") or subscriptionData:IsA("NumberValue")) then
            subscriptionData.Value = 67
        end
    end
end)

getgenv().shootArgs = { {}, {}, Vector3.zero, Vector3.zero, 0 }

for i = 1, 5 do
    getgenv().shootArgs[1][i] = {Normal = Vector3.zero, Instance = nil, Position = Vector3.zero}
    getgenv().shootArgs[2][i] = {thePart = nil, theOffset = Vector3.zero}
end

getgenv().forceFieldTimers = setmetatable({}    , {__mode = "k"})

getgenv().DesyncPart = Instance.new("Part")
getgenv().DesyncPart.Name = "DesyncVisual"
getgenv().DesyncPart.Size = Vector3.new(2, 2, 1)
getgenv().DesyncPart.Transparency = 1
getgenv().DesyncPart.CanCollide = false
getgenv().DesyncPart.Anchored = true
getgenv().DesyncPart.Parent = workspace

getgenv().StrafeConnection = nil
getgenv().StrafeVisConnection = nil
getgenv().StrafeVisParts = nil
getgenv().CurrentStrafeCF = nil

getgenv().Config = {
    Visual = {
        FOV = {
            Enabled = false,
            Shape = 'Circle',
            Size = 300,
            InnerColor = Color3.fromRGB(255, 255, 255),
            OuterColor = Color3.fromRGB(0, 0, 0),
            FollowCursor = true,
            Filled = false,
            FillColor = Color3.fromRGB(255, 255, 255),
            PulseEnabled = false,
            PulseAmount = 20,
            PulseSpeed = 2,
            InnerCircle = nil,
            OuterCircle = nil,
            FillCircle = nil,
            ScreenGui = nil,
            MainFrame = nil,
            UICorner = nil,
            UIStroke = nil,
        }
    },
    ESP = {
        Box = {
            Enable = true,
            Type = 'Full',
            Font = 'SmallestPixel',
            Color = Color3.fromRGB(255, 255, 255),
            Filled = {
                Enable = false,
                Gradient = {
                    Enable = false,
                    Color = {
                        Start = Color3.fromRGB(255, 255, 255),
                        End = Color3.fromRGB(0, 0, 0),
                    },
                    Rotation = {
                        Enable = true,
                        Auto = true,
                    },
                    Transparency = 0.5,
                },
            },
        },
        Text = {
            Enable = true,
            Name = {
                Enable = true,
                Teamcheck = true,
                Color = Color3.fromRGB(255, 255, 255),
            },
            Studs = {
                Enable = true,
                Color = Color3.fromRGB(255, 255, 255),
            },
            Tool = {
                Enable = true,
                Color = Color3.fromRGB(255, 255, 255),
            },
        },
        Bars = {
            Enable = true,
            Health = {
                ShowOutline = false,
                Enable = true,
                Lerp = true,
                Color1 = Color3.fromRGB(0, 255, 0),
                Color2 = Color3.fromRGB(255, 255, 0),
                Color3 = Color3.fromRGB(255, 0, 0),
            },
        },
    }
}

local void = {
    enabled = false,
    client_root = nil,
    saved_cframe = nil,
    spoof_cframe = nil,
    hook = nil,
    timer = 0,
    is_voided = false,
    angle = 0,
    radius = 1000,
    spin_speed = 50,
    source = nil,
    _didExitEquip = false
}

local lastLocalHealthForAutoVoid = nil
local hitAutoVoidActiveUntil = 0
local hitAutoVoidOwnedSync = false

local PARTICLE_AURA_DATA = {
    { "starlight", "rbxassetid://134645216613107" },
    { "heavenly", "rbxassetid://139300897520961" },
    { "ribbon", "rbxassetid://132069507632161" },
    { "sakura", "rbxassetid://81755778619404" },
    { "angel", "rbxassetid://97658130917593" },
    { "wind", "rbxassetid://80694081850877" },
    { "flow", "rbxassetid://119913533725648" },
    { "star", "rbxassetid://73754563740680" },
}

getgenv().LocalPlayer.CharacterAdded:Connect(function(newChar)
    task.defer(function()
        if getgenv().LocalPlayer.Character ~= newChar then return end

    end)
end)

local function own(part)
    if not part or not part:IsA("BasePart") then return end
    pcall(function() part:SetNetworkOwner(getgenv().LocalPlayer) end)
end

local PARTICLE_AURA_NAMES = {}
local particleAuraIdByName = {}

for _, row in ipairs(PARTICLE_AURA_DATA) do
    table.insert(PARTICLE_AURA_NAMES, row[1])
    particleAuraIdByName[row[1]] = row[2]
end

local loadedParticleAuras = {}
local selfAuraParticles = {}

local function mapCharacterParts(character)
    local parts = {}
    for _, child in ipairs(character:GetChildren()) do
        if child:IsA("BasePart") then
            parts[child.Name] = child
        end
    end
    return parts
end

local function getParticleAuraTemplate(name)
    local cached = loadedParticleAuras[name]
    if cached then return cached end
    local id = particleAuraIdByName[name]
    if not id then return nil end
    local ok, result = pcall(function()
        return game:GetObjects(id)[1]
    end)
    if ok and result then
        loadedParticleAuras[name] = result
        return result
    end
    return nil
end

local function clearSelfAura()
    for _, p in ipairs(selfAuraParticles) do
        if p then p:Destroy() end
    end
    table.clear(selfAuraParticles)
end

local function tintParticleSubtree(root, color)
    if not color or not root then return end
    local seq = ColorSequence.new(color)
    local function tintOne(obj)
        if obj:IsA("ParticleEmitter") or obj:IsA("Beam") or obj:IsA("Trail") then
            obj.Color = seq
        elseif obj:IsA("PointLight") then
            obj.Color = color
        end
    end
    tintOne(root)
    for _, d in ipairs(root:GetDescendants()) do
        tintOne(d)
    end
end

local function setParticleEmittersEnabledInSubtree(root, enabled)
    if not root then return end
    if root:IsA("ParticleEmitter") then
        root.Enabled = enabled
    end
    for _, d in ipairs(root:GetDescendants()) do
        if d:IsA("ParticleEmitter") then
            d.Enabled = enabled
        end
    end
end

local function applyParticleAuraToCharacter(character, auraName, color, isPersistent)
    local auraObj = getParticleAuraTemplate(auraName)
    if not auraObj then return {} end

    local localParts = mapCharacterParts(character)
    local cloned = auraObj:Clone()
    local created = {}

    for _, part in ipairs(cloned:GetChildren()) do
        local targetPart = localParts[part.Name]
        if targetPart then
            for _, child in ipairs(part:GetChildren()) do
                local inst = child:Clone()
                inst.Name = "LizardAuraParticle"
                inst.Parent = targetPart
                if color then
                    tintParticleSubtree(inst, color)
                end
                table.insert(created, inst)
            end
        end
    end
    cloned:Destroy()

    for _, p in ipairs(created) do
        setParticleEmittersEnabledInSubtree(p, true)
    end

    if not isPersistent then
        task.delay(1.6, function()
            for _, p in ipairs(created) do
                if p and p.Parent then
                    setParticleEmittersEnabledInSubtree(p, false)
                end
            end
        end)
        task.delay(2.5, function()
            for _, p in ipairs(created) do
                if p then p:Destroy() end
            end
        end)
    end

    return created
end

local function refreshSelfAura()
    clearSelfAura()
    if not (Toggles.SelfAuraEnabled and Toggles.SelfAuraEnabled.Value) then return end
    local char = getgenv().LocalPlayer.Character
    if not char then return end
    local auraName = (Options.SelfAuraType and Options.SelfAuraType.Value) or "None"
    if auraName == "None" or not particleAuraIdByName[auraName] then return end
    local col = Options.SelfAuraColor.Value or Color3.fromRGB(133, 220, 255)
    selfAuraParticles = applyParticleAuraToCharacter(char, auraName, col, true)
end

getgenv().LocalPlayer.CharacterAdded:Connect(function()
    if Toggles.SelfAuraEnabled and Toggles.SelfAuraEnabled.Value then
        task.delay(0.75, refreshSelfAura)
    end
    if Toggles.SkinChangerEnabled and Toggles.SkinChangerEnabled.Value then
        task.delay(1, function()
            getgenv().Lizard_ApplySkins()
            getgenv().Lizard_ApplyBullets()
        end)
    end
end)

local GUN_SKINS = {
    "Default", "Ascension", "Void Dragon", "Hell Hound", "Snow Dragon", "Lovestruck",
    "Adurite", "Hallows", "Candy Cane", "Heartbringer", "Arctic", "Lightbringer",
    "Deathbringer", "Hell Dragon", "Kitty", "Kirumi", "Shiryus Breath", "Poseidon",
    "Amethyst", "Arsenic", "Volcanic Ashes", "Floral", "Binary", "Voxel",
    "Hello Kitty", "Radiation", "Void", "Hexagram", "Strawberry Shortcake",
    "Black Ice", "Crimson Fangs", "Green Tint", "Ember",
}
local KNIFE_SKINS = { "--", "Beta", "Fishbone" }
local BULLET_SKINS = {
    "None", "Beta", "Hallows", "Kitty", "Kirumi", "Rainbow",
    "Red", "Blue", "Green", "Orange",
}
local BULLET_CODES = {
    DoubleBarrel = "109d1326878cc594bc1bb42d126250810999782f",
    Revolver = "539db315b53f77390c0aa74773158e25bedcdd6e",
    Shotgun = "b415a7273aa86cbc2adc445fde5435eb5afababa",
    SMG = "005af87725b42ac4ca8103d11af6bf0c7d55f7b3",
    TacticalShotgun = "109d1326878cc594bc1bb42d126250810999782f",
}

local function SC_WeldParts(p0, p1)
    local w = Instance.new("WeldConstraint")
    w.Part0 = p0; w.Part1 = p1; w.Parent = p0
end

local function SC_StripSkin(weapon)
    local handle = weapon:FindFirstChild("Handle")
    if handle then handle.Transparency = 0 end
    for _, child in ipairs(weapon:GetChildren()) do
        if child:IsA("Model") and child:FindFirstChild("_LizardSkin") then
            child:Destroy()
        end
    end
end

local function SC_ApplySkin(weapon, model)
    SC_StripSkin(weapon)
    local handle = weapon:FindFirstChild("Handle")
    if not handle then return end
    local clone = model:Clone()
    if not clone.PrimaryPart then return end
    local tag = Instance.new("BoolValue")
    tag.Name = "_LizardSkin"
    tag.Parent = clone
    for _, part in ipairs(clone:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CanCollide = false
            part.Anchored = false
            part.Massless = true
            part.Transparency = 0
        end
    end
    clone.Parent = weapon
    SC_WeldParts(handle, clone.PrimaryPart)
    clone:SetPrimaryPartCFrame(handle.CFrame)
    handle.Transparency = 1
end

local function SC_IsNoSkin(name)
    return (not name) or name == "None" or name == "Default" or name == "--"
end

getgenv().Lizard_ApplySkins = function()
    local bp = getgenv().LocalPlayer:FindFirstChild("Backpack")
    if not bp then return end
    local RS = getgenv().ReplicatedStorage
    local gunMap = {
        DoubleBarrel = Options.SkinDoubleBarrel and Options.SkinDoubleBarrel.Value,
        Revolver = Options.SkinRevolver and Options.SkinRevolver.Value,
        Shotgun = Options.SkinShotgun and Options.SkinShotgun.Value,
        SMG = Options.SkinSMG and Options.SkinSMG.Value,
        TacticalShotgun = Options.SkinTacticalShotgun and Options.SkinTacticalShotgun.Value,
    }
    for weaponKey, skinName in pairs(gunMap) do
        local weapon = bp:FindFirstChild("[" .. weaponKey .. "]")
        if weapon then
            if not SC_IsNoSkin(skinName) then
                local skinFolder = RS:FindFirstChild("Wraps") and RS.Wraps:FindFirstChild("[" .. weaponKey .. "]")
                if skinFolder then
                    local skinModel = skinFolder:FindFirstChild(skinName)
                    if skinModel then SC_ApplySkin(weapon, skinModel) end
                end
            else
                SC_StripSkin(weapon)
            end
        end
    end
    local knifeSkin = Options.SkinKnife and Options.SkinKnife.Value
    local knife = bp:FindFirstChild("[Knife]")
    if knife then
        if not SC_IsNoSkin(knifeSkin) then
            local knivesFolder = RS:FindFirstChild("Knives")
            if knivesFolder then
                local skinModel = knivesFolder:FindFirstChild(knifeSkin)
                if skinModel then SC_ApplySkin(knife, skinModel) end
            end
        else
            SC_StripSkin(knife)
        end
    end
end

getgenv().Lizard_ResetSkins = function()
    local bp = getgenv().LocalPlayer:FindFirstChild("Backpack")
    if not bp then return end
    local weapons = bp:GetChildren()
    local char = getgenv().LocalPlayer.Character
    if char then
        for _, c in ipairs(char:GetChildren()) do
            if c:IsA("Tool") then table.insert(weapons, c) end
        end
    end
    for _, weapon in ipairs(weapons) do
        if weapon:IsA("Tool") then SC_StripSkin(weapon) end
    end
    getgenv().Library:Notify("Skins Reset!", 3)
end

getgenv().Lizard_ApplyBullets = function()
    local enabled = Toggles.BulletChangerEnabled and Toggles.BulletChangerEnabled.Value
    local texture = Options.BulletTexture and Options.BulletTexture.Value
    if not (enabled and texture and texture ~= "None") then return end

    local dataFolder = getgenv().LocalPlayer:FindFirstChild("DataFolder")
    if not dataFolder then return end
    local inventoryData = dataFolder:FindFirstChild("InventoryData")
    local equippedBB = dataFolder:FindFirstChild("EquippedBulletBeams")
    local HttpService = game:GetService("HttpService")

    if inventoryData then
        local bulletBeams = inventoryData:FindFirstChild("BulletBeams")
        if bulletBeams and bulletBeams:IsA("StringValue") then
            local beamData = {}
            for _, code in pairs(BULLET_CODES) do
                beamData[code] = { Name = texture }
            end
            bulletBeams.Value = HttpService:JSONEncode(beamData)
        end
    end
    if equippedBB and equippedBB:IsA("StringValue") then
        local equipped = {}
        for weaponKey, code in pairs(BULLET_CODES) do
            equipped["[" .. weaponKey .. "]"] = code
        end
        equippedBB.Value = HttpService:JSONEncode(equipped)
    end
end

local function applyVisualGuns()
    if not Toggles.SkinChangerEnabled or not Toggles.SkinChangerEnabled.Value then return end
    getgenv().Lizard_ApplySkins()
    getgenv().Lizard_ApplyBullets()
end

local function localPlayerIsKO()
    local char = getgenv().LocalPlayer.Character
    local body = char and char:FindFirstChild("BodyEffects")
    local ko = (body and body:FindFirstChild("K.O") and body["K.O"].Value) or (char and char:FindFirstChild("KO") and char.KO.Value)
    return ko
end

local function isValidAutoHealTarget(pChar, myRoot)
    if not pChar or not myRoot or myRoot.Parent == nil then return false end
    local be = pChar:FindFirstChild("BodyEffects")
    local pHum = pChar:FindFirstChildOfClass("Humanoid")
    local pRoot = pChar:FindFirstChild("HumanoidRootPart")
    if not pRoot then return false end

    local isKO = (be and be:FindFirstChild("K.O") and be["K.O"].Value) or (pChar:FindFirstChild("KO") and pChar.KO.Value)
    local isDead = (be and be:FindFirstChild("Dead") and be.Dead.Value) or (pHum and pHum.Health <= 0)

    if not isKO or isDead then return false end
    return pRoot.Position.Y < 5000 and pRoot.Position.Y > -500 and (pRoot.Position - myRoot.Position).Magnitude <= 2500
end

local function getValidAutoHealPlayers()
    local myRoot = getgenv().LocalPlayer.Character and getgenv().LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not myRoot then return {} end
    local targets = {}
    for _, p in ipairs(getgenv().Players:GetPlayers()) do
        if p ~= getgenv().LocalPlayer and isValidAutoHealTarget(p.Character, myRoot) then
            table.insert(targets, p)
        end
    end
    return targets
end

local autoHealActive = false
task.spawn(function()
    while task.wait(0.1) do
        if getgenv().LizardGen ~= lizardGen then break end
        if Toggles.AutoHealEnabled and Toggles.AutoHealEnabled.Value and not autoHealActive then
            local char = getgenv().LocalPlayer.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if not hum or not hrp or localPlayerIsKO() then continue end

            local threshold = Options.AutoHealThreshold and Options.AutoHealThreshold.Value or 50
            local maxHealth = hum.MaxHealth > 0 and hum.MaxHealth or 100
            if (hum.Health / maxHealth) * 100 >= threshold then continue end

            local koPlayers = getValidAutoHealPlayers()
            if #koPlayers == 0 then continue end

            local targetPlayer = koPlayers[math.random(1, #koPlayers)]
            autoHealActive = true
            local oldCFrame = hrp.CFrame
            getgenv().Library:Notify("Auto Healing: Teleporting to " .. (targetPlayer.DisplayName or targetPlayer.Name))

            local healStart = tick()
            local healMaxDuration = 8
            local healAbortKO = false

            while tick() - healStart < healMaxDuration do
                local char = getgenv().LocalPlayer.Character
                local hum = char and char:FindFirstChildOfClass("Humanoid")
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                if not hum or not hrp or not hum.Parent then break end
                if localPlayerIsKO() then healAbortKO = true; break end

                local maxHealth = hum.MaxHealth > 0 and hum.MaxHealth or 100
                if (hum.Health / maxHealth) * 100 >= threshold + 5 or hum.Health >= maxHealth then break end

                if not targetPlayer or targetPlayer.Parent ~= getgenv().Players then
                    koPlayers = getValidAutoHealPlayers()
                    if #koPlayers == 0 then break end
                    targetPlayer = koPlayers[math.random(1, #koPlayers)]
                end

                local targetChar = targetPlayer and targetPlayer.Character
                if not isValidAutoHealTarget(targetChar, hrp) then
                    koPlayers = getValidAutoHealPlayers()
                    if #koPlayers == 0 then break end
                    targetPlayer = koPlayers[math.random(1, #koPlayers)]
                    targetChar = targetPlayer.Character
                end

                local targetRoot = targetChar and targetChar:FindFirstChild("HumanoidRootPart")
                local currentTorso = targetChar and (targetChar:FindFirstChild("UpperTorso") or targetChar:FindFirstChild("Torso") or targetRoot)

                if currentTorso then
                    getgenv().isCurrentlyStomping = true
                    pcall(function() hrp:SetNetworkOwner(getgenv().LocalPlayer) end)
                    local pos = currentTorso.Position + Vector3.new(0, 3, 0)
                    local look = hrp.CFrame.LookVector
                    local flatLook = Vector3.new(look.X, 0, look.Z)
                    if flatLook.Magnitude < 1e-3 then flatLook = Vector3.new(0, 0, -1) end

                    pcall(function()
                        hrp.CFrame = CFrame.lookAt(pos, pos + flatLook.Unit)
                        hrp.Velocity = Vector3.zero
                    end)

                    getgenv().MainEvent:FireServer("Stomp")
                end
                task.wait(0.1)
            end

            getgenv().isCurrentlyStomping = false

            local char = getgenv().LocalPlayer.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if hrp and oldCFrame then
                pcall(function()
                    hrp.CFrame = oldCFrame
                    hrp.Velocity = Vector3.zero
                end)
            end
            autoHealActive = false
            getgenv().Library:Notify(healAbortKO and "Auto Heal stopped (K.O.)" or "Heal Complete")
        end
    end
end)

getgenv().SpectateConnection = nil
getgenv().LastShotTime = 0
getgenv().lastMeleeFire = 0
getgenv().isCurrentlyStomping = false

getgenv().trackCharacter = function(char)
    if not char then return end
    local ff = char:FindFirstChildOfClass("ForceField")
    if ff then getgenv().forceFieldTimers[char] = workspace:GetServerTimeNow() end
    char.ChildAdded:Connect(function(child)
        if child:IsA("ForceField") then getgenv().forceFieldTimers[char] = workspace:GetServerTimeNow() end
    end)
end

getgenv().trackPlayer = function(plr)
    if plr.Character then getgenv().trackCharacter(plr.Character) end
    plr.CharacterAdded:Connect(getgenv().trackCharacter)
end

for _, plr in ipairs(getgenv().Players:GetPlayers()) do getgenv().trackPlayer(plr) end
getgenv().Players.PlayerAdded:Connect(getgenv().trackPlayer)

getgenv().TargetCleanupConnection = getgenv().Players.PlayerRemoving:Connect(function(plr)
    if getgenv().ForceHitTarget == plr then
        getgenv().ForceHitTarget = nil
        getgenv().SetupDamageDetection(nil)
        if getgenv().TracerLine then getgenv().TracerLine.Visible = false end
        if getgenv().TracerOutline then getgenv().TracerOutline.Visible = false end
    end
    if getgenv().ForceHitTarget2 == plr then
        getgenv().ForceHitTarget2 = nil
        getgenv().SetupDamageDetection(nil)
        if getgenv().TracerLine2 then getgenv().TracerLine2.Visible = false end
        if getgenv().TracerOutline2 then getgenv().TracerOutline2.Visible = false end
    end
end)

getgenv().TracerOutline = Drawing.new("Line")
getgenv().TracerOutline.Thickness = 3; getgenv().TracerOutline.Color = Color3.fromRGB(0, 0, 0); getgenv().TracerOutline.Visible = false; getgenv().TracerOutline.ZIndex = 1

getgenv().TracerLine = Drawing.new("Line")
getgenv().TracerLine.Thickness = 1; getgenv().TracerLine.Color = Color3.fromRGB(255, 255, 255); getgenv().TracerLine.Visible = false; getgenv().TracerLine.ZIndex = 2

getgenv().TracerOutline2 = Drawing.new("Line")
getgenv().TracerOutline2.Thickness = 3; getgenv().TracerOutline2.Color = Color3.fromRGB(0, 0, 0); getgenv().TracerOutline2.Visible = false; getgenv().TracerOutline2.ZIndex = 1

getgenv().TracerLine2 = Drawing.new("Line")
getgenv().TracerLine2.Thickness = 1; getgenv().TracerLine2.Color = Color3.fromRGB(255, 255, 255); getgenv().TracerLine2.Visible = false; getgenv().TracerLine2.ZIndex = 2

getgenv().HitNotifGui = Instance.new("ScreenGui")
getgenv().HitNotifGui.Name = "LizardHitNotifs"; getgenv().HitNotifGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
getgenv().coreGui = pcall(function() return game:GetService("CoreGui") end) and game:GetService("CoreGui") or getgenv().LocalPlayer:WaitForChild("PlayerGui")
getgenv().HitNotifGui.Parent = getgenv().coreGui

getgenv().notifContainer = Instance.new("Frame")
getgenv().notifContainer.Name = "Container"; getgenv().notifContainer.BackgroundTransparency = 1; getgenv().notifContainer.Size = UDim2.new(0, 300, 0.8, 0)
getgenv().notifContainer.Parent = getgenv().HitNotifGui

getgenv().listLayout = Instance.new("UIListLayout")
getgenv().listLayout.Padding = UDim.new(0, 8); getgenv().listLayout.SortOrder = Enum.SortOrder.LayoutOrder; getgenv().listLayout.Parent = getgenv().notifContainer

getgenv().UpdateNotifPosition = function(mode)
    local configs = {
        ["Top Left"] = { Anchor = Vector2.new(0, 0), Position = UDim2.new(0.02, 0, 0.05, 0), VAlign = Enum.VerticalAlignment.Top, HAlign = Enum.HorizontalAlignment.Left },
        ["Top Right"] = { Anchor = Vector2.new(1, 0), Position = UDim2.new(0.98, 0, 0.05, 0), VAlign = Enum.VerticalAlignment.Top, HAlign = Enum.HorizontalAlignment.Right },
        ["Bottom Center"] = { Anchor = Vector2.new(0.5, 1), Position = UDim2.new(0.5, 0, 0.95, 0), VAlign = Enum.VerticalAlignment.Bottom, HAlign = Enum.HorizontalAlignment.Center },
        ["Center"] = { Anchor = Vector2.new(0.5, 0.5), Position = UDim2.new(0.5, 0, 0.5, 0), VAlign = Enum.VerticalAlignment.Center, HAlign = Enum.HorizontalAlignment.Center }
    }
    local cfg = configs[mode]
    if cfg then
        getgenv().notifContainer.AnchorPoint = cfg.Anchor; getgenv().notifContainer.Position = cfg.Position
        getgenv().listLayout.VerticalAlignment = cfg.VAlign; getgenv().listLayout.HorizontalAlignment = cfg.HAlign
    end
end

getgenv().CreateDamageIndicator = function(part, damage)
    if not Toggles.DamageIndicators.Value or not part then return end
    local anchor = Instance.new("Part")
    anchor.Anchored = true; anchor.CanCollide = false; anchor.Transparency = 1
    anchor.Size = Vector3.new(0.1, 0.1, 0.1); anchor.Position = part.Position; anchor.Parent = workspace

    local bbg = Instance.new("BillboardGui")
    bbg.AlwaysOnTop = true; bbg.Size = UDim2.new(0, 200, 0, 50)

    local randX = math.random(-15, 15) / 10; local randY = math.random(-5, 5) / 10
    local startOffset = Vector3.new(randX, 1.5 + randY, 0)
    bbg.StudsOffset = startOffset; bbg.Adornee = anchor; bbg.Parent = getgenv().coreGui

    local label = Instance.new("TextLabel")
    label.BackgroundTransparency = 1; label.Size = UDim2.new(1, 0, 1, 0)
    label.Font = Enum.Font.Code; label.Text = tostring(math.floor(damage + 0.5))
    label.TextColor3 = Options.IndicatorColor.Value; label.TextSize = 28; label.TextStrokeTransparency = 1

    local stroke = Instance.new("UIStroke")
    stroke.Thickness = 2; stroke.Color = Options.IndicatorStrokeColor and Options.IndicatorStrokeColor.Value or Color3.fromRGB(15, 15, 15)
    stroke.LineJoinMode = Enum.LineJoinMode.Round; stroke.Parent = label

    label.Rotation = math.random(-35, 35); label.Parent = bbg
    local scale = Instance.new("UIScale")
    scale.Scale = 0; scale.Parent = label

    task.spawn(function()
        getgenv().TweenService:Create(scale, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Scale = 1}):Play()
        getgenv().TweenService:Create(label, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Rotation = math.random(-5, 5)}):Play()
        getgenv().TweenService:Create(bbg, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {StudsOffset = startOffset + Vector3.new(0, 1.5, 0)}):Play()

        task.wait(Options.IndicatorDuration and Options.IndicatorDuration.Value or 1.0)

        getgenv().TweenService:Create(bbg, TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {StudsOffset = startOffset + Vector3.new(0, 0.5, 0)}):Play()
        getgenv().TweenService:Create(label, TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {TextTransparency = 1}):Play()
        getgenv().TweenService:Create(stroke, TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Transparency = 1}):Play()
        local shrinkOut = getgenv().TweenService:Create(scale, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.In), {Scale = 0})

        shrinkOut:Play()
        shrinkOut.Completed:Wait()
        bbg:Destroy(); anchor:Destroy()
    end)
end

getgenv().HitSounds = {["Rust Headshot"]  = "138750331387064",["Neverlose"]      = "110168723447153",["Bubble"]         = "6534947588",
    ["Laser"]          = "7837461331", ["Steve"]          = "4965083997",["Call of Duty"]   = "5952120301",["Bat"]            = "3333907347", ["TF2 Critical"]   = "296102734", ["Saber"]          = "8415678813",
    ["Bameware"]       = "3124331820", ["Money"]          = "13956013041", ["Notif"]          = "6696469190",
    ["Shutter"]        = "10066921516", ["RIFK7"]          = "9102080552",["LazerBeam"]      = "130791043",
    ["WindowsXPError"] = "160715357", ["TF2Hitsound"]    = "3455144981",["TF2Bat"]         = "3333907347",
    ["BowHit"]         = "1053296915",["Bow"]            = "3442683707",["OSU"]            = "7147454322",
    ["OneNN"]          = "7349055654", ["Rust"]           = "6565371338",["TF2Pan"]         = "3431749479",
    ["Mario"]          = "5709456554", ["Bell"]           = "6534947240", ["Pick"]           = "1347140027",["Pop"]            = "198598793",["Sans"]           = "3188795283", ["Fart"]           = "130833677",
    ["Big"]            = "5332005053", ["Vine"]           = "5332680810", ["Bruh"]           = "4578740568",
    ["Skeet"]          = "5633695679", ["Fatality"]       = "6534947869",["Bonk"]           = "5766898159",["Minecraft"]      = "5869422451", ["Gamesense"]      = "4817809188", ["Bamboo"]         = "3769434519",
    ["Crowbar"]        = "546410481",["Weeb"]           = "6442965016", ["Beep"]           = "8177256015",["Bambi"]          = "8437203821",["Stone"]          = "3581383408",["Old Fatality"]   = "6607142036",["Click"]          = "8053704437",["Ding"]           = "7149516994", ["Snow"]           = "6455527632",
    ["Osu"]            = "7149255551",["TF2"]            = "2868331684",["Slime"]          = "6916371803",
    ["Among Us"]       = "5700183626",["One"]            = "7380502345",["BulletDeflect"]  = "1657157666",
}
getgenv().HitSoundList = {}
for name, _ in pairs(getgenv().HitSounds) do table.insert(getgenv().HitSoundList, name) end
table.sort(getgenv().HitSoundList); table.insert(getgenv().HitSoundList, "Custom")

getgenv().PlayHitSound = function()
    if not Toggles.HitSoundEnabled.Value then return end
    local soundId = Options.HitSoundChoice.Value == 'Custom' and Options.CustomHitSound.Value or getgenv().HitSounds[Options.HitSoundChoice.Value]
    if not soundId or soundId == "" then return end
    if string.match(soundId, "^%d+$") then soundId = "rbxassetid://" .. soundId end

    local sound = Instance.new("Sound")
    sound.SoundId = soundId; sound.Volume = 1; sound.Parent = workspace
    sound:Play(); getgenv().Debris:AddItem(sound, 2)
end

getgenv().notifTick = 0
getgenv().CreateHitNotification = function(playerName, damage)
    if not Toggles.HitNotifEnabled.Value then return end
    local c = Options.AccentColor.Value or Color3.fromRGB(162, 193, 255)
    local hex = string.format("#%02X%02X%02X", math.floor(c.R*255), math.floor(c.G*255), math.floor(c.B*255))

    local notif = Instance.new("TextLabel")
    notif.Size = UDim2.new(0, 0, 0, 25); notif.AutomaticSize = Enum.AutomaticSize.X; notif.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    notif.BackgroundTransparency = 1; notif.TextTransparency = 1; notif.TextStrokeTransparency = 1; notif.Font = Enum.Font.Code
    notif.TextSize = 14; notif.TextColor3 = Color3.fromRGB(255, 255, 255); notif.RichText = true
    local fmt = (Options.NotifFormat and Options.NotifFormat.Value) or "Hit (player) for (dmg%)"
    local nameSpan = string.format("<font color='%s'>%s</font>", hex, playerName)
    local dmgSpan = string.format("<font color='%s'>%d</font>", hex, math.floor(damage + 0.5))
    fmt = fmt:gsub("%(player%)", function() return nameSpan end)
    fmt = fmt:gsub("%(dmg%%%)", function() return dmgSpan end)
    fmt = fmt:gsub("%(dmg%)", function() return dmgSpan end)
    notif.Text = fmt

    getgenv().notifTick = getgenv().notifTick + 1; notif.LayoutOrder = getgenv().notifTick

    local corner = Instance.new("UICorner"); corner.CornerRadius = UDim.new(0, 4); corner.Parent = notif
    local stroke = Instance.new("UIStroke"); stroke.Color = Options.OutlineColor and Options.OutlineColor.Value or Color3.fromRGB(40, 40, 40); stroke.Transparency = 1; stroke.Parent = notif
    local pad = Instance.new("UIPadding"); pad.PaddingLeft = UDim.new(0, 8); pad.PaddingRight = UDim.new(0, 8); pad.Parent = notif
    notif.Parent = getgenv().notifContainer

    local tiIn = TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
    getgenv().TweenService:Create(notif, tiIn, {BackgroundTransparency = 0.4, TextTransparency = 0, TextStrokeTransparency = 0.5}):Play()
    getgenv().TweenService:Create(stroke, tiIn, {Transparency = 0}):Play()

    task.spawn(function()
        task.wait(2)
        local tiOut = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        getgenv().TweenService:Create(notif, tiOut, {BackgroundTransparency = 1, TextTransparency = 1, TextStrokeTransparency = 1}):Play()
        getgenv().TweenService:Create(stroke, tiOut, {Transparency = 1}):Play()
        task.wait(0.5); notif:Destroy()
    end)
end

getgenv().CreateBulletTracer = function(startPos, endPos, isDB)
    if not Toggles.BulletTracers.Value then return end
    local color = Options.BulletTracerColorOption.Value
    local duration = Options.TracerDuration.Value
    local steps = math.floor(duration * 50)
    if steps < 1 then steps = 1 end
    local waitTime = duration / steps

    local lineCount = isDB and 3 or 1
    for i = 1, lineCount do
        local targetPos = endPos
        local offset = Vector3.zero
        if isDB then
            local spread = Options.DBSpread.Value
            targetPos = targetPos + Vector3.new((math.random() - 0.5) * spread, (math.random() - 0.5) * spread, (math.random() - 0.5) * spread)
            local angle = math.rad((i - 1) * 120)
            offset = Vector3.new(math.cos(angle) * 0.12, math.sin(angle) * 0.12, 0)
        end

        local distance = (targetPos - startPos).Magnitude
        local tracer = Instance.new("Part")
        tracer.Anchored = true; tracer.CanCollide = false; tracer.Material = Enum.Material.Neon
        local tw = math.max(0.02, (Options.TracerWidth and Options.TracerWidth.Value or 1) * 0.06)
        tracer.Color = color; tracer.Transparency = 0.2; tracer.Size = Vector3.new(tw, tw, distance)
        tracer.CFrame = CFrame.lookAt(startPos, targetPos) * CFrame.new(offset) * CFrame.new(0, 0, -distance / 2)
        tracer.Parent = workspace

        task.spawn(function()
            for t = 1, steps do
                tracer.Transparency = 0.2 + (0.8 * (t / steps)); task.wait(waitTime)
            end
            tracer:Destroy()
        end)
    end
end

getgenv().SetupDamageDetection = function(target)
    if getgenv().TargetHealthConnection then getgenv().TargetHealthConnection:Disconnect(); getgenv().TargetHealthConnection = nil end
    if getgenv().TargetRespawnConnection then getgenv().TargetRespawnConnection:Disconnect(); getgenv().TargetRespawnConnection = nil end
    if not target then return end

    getgenv().TargetRespawnConnection = target.CharacterAdded:Connect(function()
        task.wait(0.3)
        getgenv().SetupDamageDetection(target)
    end)

    local char = target.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end

    local lastHealth = hum.Health
    getgenv().TargetHealthConnection = hum:GetPropertyChangedSignal("Health"):Connect(function()
        local currentHealth = hum.Health
        if currentHealth < lastHealth then
            local damage = lastHealth - currentHealth
            local myChar = getgenv().LocalPlayer.Character
            if myChar then
                local hasTool = myChar:FindFirstChildOfClass("Tool")
                if hasTool then getgenv().PlayHitSound() end
                if Toggles.HitNotifEnabled and Toggles.HitNotifEnabled.Value then getgenv().CreateHitNotification(target.Name, damage) end
                if Toggles.DamageIndicators and Toggles.DamageIndicators.Value then
                    local hitPart = char:FindFirstChild(Options.HitPart.Value) or char:FindFirstChild("HumanoidRootPart")
                    getgenv().CreateDamageIndicator(hitPart, damage)
                end
                if Toggles.BulletTracers.Value then
                    local startPos = getgenv().Camera.CFrame.Position
                    if hasTool and hasTool:FindFirstChild("Handle") then startPos = hasTool.Handle.Position
                    elseif myChar:FindFirstChild("Right Arm") then startPos = myChar["Right Arm"].Position
                    elseif myChar:FindFirstChild("RightHand") then startPos = myChar["RightHand"].Position end

                    local hitPart = char:FindFirstChild(Options.HitPart.Value)
                    if hitPart then
                        local isDB = hasTool and string.lower(hasTool.Name) == "[doublebarrel]"
                        getgenv().CreateBulletTracer(startPos, hitPart.Position, isDB)
                    end
                end
            end
        end
        lastHealth = currentHealth
    end)
end

getgenv().isKO = function(p)
    if not Toggles.KOCheck.Value then return false end
    local c = p.Character
    if not c then return true end
    local h = c:FindFirstChild("Humanoid")
    local b = c:FindFirstChild("BodyEffects")
    return (h and h.Health <= 0) or (b and b:FindFirstChild("K.O") and b["K.O"].Value)
end

getgenv().isFullyDead = function(p)
    local c = p.Character
    if not c then return true end
    local h = c:FindFirstChild("Humanoid")
    local b = c:FindFirstChild("BodyEffects")
    return (h and h.Health <= 0) or (b and b:FindFirstChild("SDeath") and b["SDeath"].Value)
end

getgenv().wallCheck = function(a, b, ignore)
    if not Toggles.WallCheck.Value then return true end
    local rayParams = RaycastParams.new()
    rayParams.FilterDescendantsInstances = ignore
    rayParams.FilterType = Enum.RaycastFilterType.Blacklist
    local result = workspace:Raycast(a, b - a, rayParams)
    return not (result and result.Instance and result.Instance.CanCollide and not result.Instance:IsDescendantOf(getgenv().Players))
end

local function normWeaponName(name)
    return string.gsub(string.lower(name or ""), "[%[%]()%s%-_]", "")
end

local WEAPON_FIRE_COOLDOWNS = {
    doublebarrel = 0.85,
    revolver = 0.4,
    tacticalshotgun = 0.8,
    shotgun = 0.85,
    smg = 0.1,
    silencer = 0.1,
}

local WEAPON_PELLETS = {
    doublebarrel = 2,
    revolver = 1,
    tacticalshotgun = 5,
    shotgun = 4,
    smg = 1,
    silencer = 1,
}

getgenv().Shoot = function(p)
    if not p or not p.Character then return end
    local character = p.Character
    local humanoid = character:FindFirstChildOfClass("Humanoid")

    if Toggles.KOCheck.Value then
        if not humanoid or humanoid.Health <= 0 then return end
        local be = character:FindFirstChild("BodyEffects")
        if be and be:FindFirstChild("K.O") and be["K.O"].Value then return end
    end

    local targetPart = character:FindFirstChild(Options.HitPart.Value)
    if not targetPart then return end

    if Toggles.ForceFieldCheck.Value and not Toggles.EnablePrefire.Value then
        if character:FindFirstChildOfClass("ForceField") then return end
    end

    local char = getgenv().LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return end

    local myTool = char:FindFirstChildOfClass("Tool")
    local norm = normWeaponName(myTool and myTool.Name)
    local fireRate = (Options.FireRate and Options.FireRate.Value) or 1
    local fireCd = (WEAPON_FIRE_COOLDOWNS[norm] or 0.1) / fireRate
    if tick() - (getgenv().LastShotTime or 0) < fireCd then return end

    local spoofCF = getgenv().ForceHit.CurrentStrafeCF or getgenv().CurrentStrafeCF
    local playerPos = (Toggles.StrafeToggle.Value and spoofCF) and spoofCF.Position or root.Position

    if Toggles.WallCheck.Value then
        local rayParams = RaycastParams.new()
        rayParams.FilterDescendantsInstances = {char, character, getgenv().DesyncPart}
        rayParams.FilterType = Enum.RaycastFilterType.Blacklist
        local res = workspace:Raycast(playerPos, targetPart.Position - playerPos, rayParams)
        if res and res.Instance and res.Instance.CanCollide and not res.Instance:IsDescendantOf(getgenv().Players) then return end
    end

    if Options.MaxDistance and (playerPos - targetPart.Position).Magnitude > Options.MaxDistance.Value then return end

    local pellets = WEAPON_PELLETS[norm] or 5
    local hits = {}
    local partData = {}
    for i = 1, pellets do
        hits[i] = { Normal = targetPart.Position, Instance = targetPart, Position = targetPart.Position }
        partData[i] = { thePart = targetPart, theOffset = Vector3.zero }
    end
    local args = { hits, partData, playerPos, playerPos, workspace:GetServerTimeNow() }

    getgenv().MainEvent:FireServer("Shoot", args)
    getgenv().LastShotTime = tick()
    getgenv().ForceHit.LastShotTime = tick()
end

getgenv().GetClosestToMouse = function()
    local mousePos = getgenv().UserInputService:GetMouseLocation()
    local fovCfg = getgenv().Config and getgenv().Config.Visual and getgenv().Config.Visual.FOV
    local shortest = fovCfg and fovCfg.Enabled and fovCfg.Size or 100
    local closest = nil

    for _, plr in ipairs(getgenv().Players:GetPlayers()) do
        if plr ~= getgenv().LocalPlayer and plr.Character then
            local part = plr.Character:FindFirstChild(Options.HitPart.Value)
            if part and not getgenv().isKO(plr) then
                local screenPos, visible = getgenv().Camera:WorldToViewportPoint(part.Position)
                if visible then
                    local dist = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                    if dist < shortest then
                        shortest = dist; closest = plr
                    end
                end
            end
        end
    end
    return closest
end

getgenv().resetStrafeCamera = function()
    local char = getgenv().LocalPlayer.Character
    local hum = char and char:FindFirstChildWhichIsA("Humanoid")
    if hum then getgenv().Camera.CameraSubject = hum end
end

getgenv().destroyStrafeVisualizer = function()
    if getgenv().StrafeVisConnection then getgenv().StrafeVisConnection:Disconnect(); getgenv().StrafeVisConnection = nil end
    if getgenv().StrafeVisParts then
        for _, data in pairs(getgenv().StrafeVisParts) do
            if data.part then data.part:Destroy() end
        end
        getgenv().StrafeVisParts = nil
    end
end

getgenv().createStrafeVisualizer = function()
    getgenv().destroyStrafeVisualizer()
    local char = getgenv().LocalPlayer.Character or getgenv().LocalPlayer.CharacterAdded:Wait()
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return end

    getgenv().StrafeVisParts = {}
    for _, p in ipairs(char:GetChildren()) do
        if p:IsA("BasePart") and p.Name ~= "HumanoidRootPart" then
            local vis = Instance.new("Part")
            vis.Name = p.Name .. "_StrafeGhost"
            vis.Size = p.Size; vis.Anchored = true; vis.CanCollide = false
            vis.CastShadow = false; vis.Material = Enum.Material.Neon
            vis.Color = Color3.fromRGB(255, 255, 255); vis.Transparency = 0; vis.Parent = getgenv().Camera

            local offset = root.CFrame:Inverse() * p.CFrame
            getgenv().StrafeVisParts[p.Name] = {part = vis, offset = offset, currentCF = vis.CFrame}
        end
    end

    local alpha = 0.18
    getgenv().CurrentStrafeCF = root.CFrame
    getgenv().StrafeVisConnection = getgenv().RunService.RenderStepped:Connect(function()
        if not getgenv().CurrentStrafeCF then return end
        for _, data in pairs(getgenv().StrafeVisParts) do
            local targetCF = getgenv().CurrentStrafeCF * data.offset
            data.currentCF = data.currentCF:Lerp(targetCF, alpha)
            data.part.CFrame = data.currentCF
        end
    end)
end

getgenv().startSpectate = function()
    if getgenv().SpectateConnection then getgenv().SpectateConnection:Disconnect() getgenv().SpectateConnection = nil end
    getgenv().SpectateConnection = getgenv().RunService.Heartbeat:Connect(function()
        if not (Toggles.SpectateTarget and Toggles.SpectateTarget.Value) then
            getgenv().resetStrafeCamera()
            if getgenv().SpectateConnection then getgenv().SpectateConnection:Disconnect() end
            getgenv().SpectateConnection = nil
            return
        end
        if not getgenv().ForceHitTarget or not getgenv().ForceHitTarget.Character then return end
        local targetHum = getgenv().ForceHitTarget.Character:FindFirstChildWhichIsA("Humanoid")
        if targetHum and getgenv().Camera.CameraSubject ~= targetHum then
            getgenv().Camera.CameraType = Enum.CameraType.Custom
            getgenv().Camera.CameraSubject = targetHum
        end
    end)
end

getgenv().Window = getgenv().Library:CreateWindow({ Title = getgenv().gameName, Center = true, AutoShow = true, Resizable = true, TabPadding = 10 })

getgenv().Tabs = {
    Main = getgenv().Window:AddTab('HvH'),
    Autofarm = getgenv().Window:AddTab('Autofarm'),
    Visuals = getgenv().Window:AddTab('Visuals'),
    Misc = getgenv().Window:AddTab('Misc'),
    Settings = getgenv().Window:AddTab('Settings'),
}
getgenv().Tabs.Character = getgenv().Tabs.Misc

if not getgenv().AntiStaffSettings then
    getgenv().AntiStaffSettings = {
        Enabled = true,
        Action = "Notify"
    }
end

getgenv().ChecksGb = getgenv().Tabs.Main:AddRightGroupbox('Forcehit Checks')
getgenv().VoidGb = getgenv().Tabs.Main:AddRightGroupbox('Desync')
getgenv().KnifeGb = getgenv().Tabs.Main:AddRightGroupbox('KnifeBot')
getgenv().LegitGb = getgenv().Tabs.Main:AddLeftGroupbox('Legit')
getgenv().MainGb = getgenv().Tabs.Main:AddLeftGroupbox('Force Hit')
getgenv().HitVisualsGb = getgenv().Tabs.Main:AddLeftGroupbox('hit visuals')

getgenv().AutofarmSettingsGb = getgenv().Tabs.Autofarm:AddLeftGroupbox('1v1 Settings')
getgenv().AutofarmCustomizationGb = getgenv().Tabs.Autofarm:AddRightGroupbox('Customization')

getgenv().AutofarmSettingsGb:AddToggle('AutofarmEnabled', {
    Text = 'Enable Autofarm',
    Default = false,
})
getgenv().AutofarmSettingsGb:AddToggle('AutofarmAntiAFK', {
    Text = 'Anti AFK',
    Default = true,
})
getgenv().AutofarmSettingsGb:AddInput('AutofarmWinnerUsername', {
    Default = 'rwnr',
    Numeric = false,
    Finished = false,
    Text = 'Winner Username',
    Placeholder = 'Winner Username',
})
getgenv().AutofarmSettingsGb:AddInput('AutofarmLoserUsername', {
    Default = 'bancrypto',
    Numeric = false,
    Finished = false,
    Text = 'Loser Username',
    Placeholder = 'Loser Username',
})

getgenv().AutofarmCustomizationGb:AddDropdown('AutofarmWeaponMode', {
    Text = 'Weapon Mode',
    Values = { 'DoubleBarrel', 'Revolver', 'Knife', 'SMG' },
    Default = 'DoubleBarrel',
})
getgenv().AutofarmCustomizationGb:AddToggle('AutofarmAimlockLoser', {
    Text = 'aimlock the loser',
    Default = true,
})
getgenv().AutofarmCustomizationGb:AddInput('AutofarmStaffGroupId', {
    Default = '34199407',
    Numeric = true,
    Finished = false,
    Text = 'Staff Group ID',
    Placeholder = 'Staff Group ID',
})
getgenv().AutofarmCustomizationGb:AddSlider('AutofarmSkyBoxHeight', {
    Text = 'Sky Box Height',
    Default = 500,
    Min = 0,
    Max = 5000,
    Rounding = 0,
})
getgenv().AutofarmCustomizationGb:AddSlider('AutofarmForceFieldDelay', {
    Text = 'ForceField Delay',
    Default = 0.5,
    Min = 0,
    Max = 3,
    Rounding = 1,
})

do
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local VirtualUser = game:GetService("VirtualUser")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")

    local LocalPlayer = Players.LocalPlayer
    local MainEvent = ReplicatedStorage:FindFirstChild("MainEvent")

    getgenv().AutofarmState = getgenv().AutofarmState or {
        InBox = false,
        Padded = false,
        EnteredAt = 0,
        BasePlate = nil,
    }

    local function afToggle(name)
        local t = Toggles[name]
        return t and t.Value
    end

    local function afOption(name, fallback)
        local o = Options[name]
        if o and o.Value ~= nil then
            return o.Value
        end
        return fallback
    end

    local function afGetChar()
        local char = LocalPlayer.Character
        if not char then return nil end
        local hum = char:FindFirstChildOfClass("Humanoid")
        local root = char:FindFirstChild("HumanoidRootPart")
        return char, hum, root
    end

    local function afWinnerName()
        return tostring(afOption('AutofarmWinnerUsername', 'rwnr'))
    end

    local function afLoserName()
        return tostring(afOption('AutofarmLoserUsername', 'bancrypto'))
    end

    local function afRole()
        if LocalPlayer.Name == afWinnerName() then
            return "winner"
        end
        if LocalPlayer.Name == afLoserName() then
            return "loser"
        end
        return nil
    end

    local function afTargetPlayer()
        local role = afRole()
        if role == "winner" then
            return Players:FindFirstChild(afLoserName())
        elseif role == "loser" then
            return Players:FindFirstChild(afWinnerName())
        end
        return nil
    end

    local function afWeaponNames(mode)
        if mode == "DoubleBarrel" then
            return { "[Double-Barrel]", "[DoubleBarrel]" }
        elseif mode == "Revolver" then
            return { "[Revolver]" }
        elseif mode == "SMG" then
            return { "[SMG]" }
        end
        return { "[Knife]" }
    end

    local function afEquipWeapon(mode)
        local char, hum = afGetChar()
        if not char or not hum then return nil end

        for _, name in ipairs(afWeaponNames(mode)) do
            local equipped = char:FindFirstChild(name)
            if equipped and equipped:IsA("Tool") then
                return equipped
            end
        end

        local backpack = LocalPlayer:FindFirstChild("Backpack")
        if backpack then
            for _, name in ipairs(afWeaponNames(mode)) do
                local tool = backpack:FindFirstChild(name)
                if tool and tool:IsA("Tool") then
                    hum:EquipTool(tool)
                    task.wait(0.1)
                    return char:FindFirstChild(name) or tool
                end
            end
        end

        return nil
    end

    local function afExpandKnifeHitbox()
        local knife = afEquipWeapon("Knife")
        local handle = knife and knife:FindFirstChild("Handle")
        local hitbox = handle and handle:FindFirstChild("HITBOX_PART")
        if hitbox and hitbox:IsA("BasePart") then
            hitbox.Size = Vector3.new(21, 21, 21)
        end
    end

    local function afInBoxCheck()
        local folder = workspace:FindFirstChild("Players")
        local inbox = folder and folder:FindFirstChild("InBox")
        return inbox and inbox:FindFirstChild(LocalPlayer.Name) ~= nil or false
    end

    local function afBothInCharacters()
        local folder = workspace:FindFirstChild("Players")
        local chars = folder and folder:FindFirstChild("Characters")
        if not chars then return false end
        return chars:FindFirstChild(afWinnerName()) ~= nil and chars:FindFirstChild(afLoserName()) ~= nil
    end

    local function afGetPads(fp)
        local j1 = fp and fp:FindFirstChild("JoinFight1")
        local j2 = fp and fp:FindFirstChild("JoinFight2")
        if not j1 or not j2 then return nil, nil end
        return j1:FindFirstChild("Region"), j2:FindFirstChild("Region")
    end

    local function afFindEmptyFightPlace()
        local ignored = workspace:FindFirstChild("Ignored")
        local boxes = ignored and ignored:FindFirstChild("Boxes")
        if not boxes then return nil end
        for _, fp in ipairs(boxes:GetChildren()) do
            if fp.Name == "FightPlace" then
                local p1 = fp:FindFirstChild("Player1")
                local p2 = fp:FindFirstChild("Player2")
                if p1 and p2 and (p1.Value == "" or p1.Value == nil) and (p2.Value == "" or p2.Value == nil) then
                    return fp
                end
            end
        end
        return nil
    end

    local function afFindWinnerFightPlace()
        local winnerPlayer = Players:FindFirstChild(afWinnerName())
        local winnerRoot = winnerPlayer and winnerPlayer.Character and winnerPlayer.Character:FindFirstChild("HumanoidRootPart")
        local ignored = workspace:FindFirstChild("Ignored")
        local boxes = ignored and ignored:FindFirstChild("Boxes")
        if not winnerRoot or not boxes then return nil, nil end

        for _, fp in ipairs(boxes:GetChildren()) do
            if fp.Name == "FightPlace" then
                local pad1, pad2 = afGetPads(fp)
                if pad1 and (winnerRoot.Position - pad1.Position).Magnitude < 10 then
                    return fp, 1
                elseif pad2 and (winnerRoot.Position - pad2.Position).Magnitude < 10 then
                    return fp, 2
                end
            end
        end
        return nil, nil
    end

    local function afTeleport(cf)
        local _, _, root = afGetChar()
        if root then
            root.CFrame = cf
        end
    end

    local function afCreateBasePlate()
        local state = getgenv().AutofarmState
        local height = tonumber(afOption('AutofarmSkyBoxHeight', 500)) or 500
        if state.BasePlate and state.BasePlate.Parent then
            state.BasePlate.CFrame = CFrame.new(0, height, 0)
            return state.BasePlate
        end

        local part = Instance.new("Part")
        part.Name = "_67"
        part.Size = Vector3.new(60, 1, 60)
        part.Anchored = true
        part.CanCollide = true
        part.Transparency = 1
        part.CFrame = CFrame.new(0, height, 0)
        part.Parent = workspace
        state.BasePlate = part
        return part
    end

    local function afRemoveBasePlate()
        local state = getgenv().AutofarmState
        if state.BasePlate then
            pcall(function() state.BasePlate:Destroy() end)
            state.BasePlate = nil
        end
    end

    local function afIsTargetAlive(target)
        local char = target and target.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        local body = char and char:FindFirstChild("BodyEffects")
        local ko = body and body:FindFirstChild("K.O")
        if not hum or hum.Health <= 0 then return false end
        if ko and ko.Value then return false end
        return true
    end

    local function afHasForceField(target)
        local char = target and target.Character
        return char and char:FindFirstChildOfClass("ForceField") ~= nil or false
    end

    local function afAimlockTarget(target)
        if not afToggle('AutofarmAimlockLoser') then return end
        local _, _, root = afGetChar()
        local head = target and target.Character and target.Character:FindFirstChild("Head")
        if root and head then
            local pos = root.Position
            root.CFrame = CFrame.lookAt(pos, Vector3.new(head.Position.X, pos.Y, head.Position.Z))
        end
    end

    local function afBuildShootArgs(origin, head)
        local shootArgs = { {}, {}, origin, origin, workspace:GetServerTimeNow() }
        local hitPos = head.Position
        for i = 1, 5 do
            shootArgs[1][i] = { Normal = hitPos, Instance = head, Position = hitPos }
            shootArgs[2][i] = { thePart = head, theOffset = Vector3.zero }
        end
        return shootArgs
    end

    local function afAutoFire(target)
        local _, _, root = afGetChar()
        local head = target and target.Character and target.Character:FindFirstChild("Head")
        if MainEvent and root and head then
            MainEvent:FireServer("Shoot", afBuildShootArgs(root.Position, head))
        end
    end

    local function afAutoSwingKnife()
        local knife = afEquipWeapon("Knife")
        if knife then
            afExpandKnifeHitbox()
            knife:Activate()
        end
    end

    LocalPlayer.Idled:Connect(function()
        if not afToggle('AutofarmAntiAFK') then return end
        VirtualUser:Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
        task.wait(0.1)
        VirtualUser:Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
    end)

    task.spawn(function()
        while task.wait(0.1) do
            if getgenv().LizardGen ~= lizardGen then break end
            if not afToggle('AutofarmEnabled') then
                getgenv().AutofarmState.InBox = false
                getgenv().AutofarmState.Padded = false
                getgenv().AutofarmState.EnteredAt = 0
                afRemoveBasePlate()
                continue
            end

            local role = afRole()
            if not role then continue end

            local char, hum, root = afGetChar()
            if not char or not hum or not root or hum.Health <= 0 then continue end

            local mode = afOption('AutofarmWeaponMode', 'DoubleBarrel')
            local state = getgenv().AutofarmState

            if afInBoxCheck() then
                if not state.InBox then
                    state.InBox = true
                    state.Padded = false
                    state.EnteredAt = tick()
                end

                local plate = afCreateBasePlate()
                if plate then
                    if role == "winner" then
                        afTeleport(plate.CFrame + Vector3.new(0, 3, 2))
                    else
                        afTeleport(plate.CFrame + Vector3.new(0, 3, 0))
                    end
                end

                local target = afTargetPlayer()
                local ffDelay = tonumber(afOption('AutofarmForceFieldDelay', 0.5)) or 0.5
                if role == "winner" and target and afIsTargetAlive(target) and not afHasForceField(target) and tick() - state.EnteredAt >= ffDelay then
                    afAimlockTarget(target)
                    if mode == "Knife" then
                        afAutoSwingKnife()
                    else
                        afEquipWeapon(mode)
                        afAutoFire(target)
                    end
                end
            else
                if state.InBox then
                    state.InBox = false
                    state.Padded = false
                    state.EnteredAt = 0
                    afRemoveBasePlate()
                end

                if not state.Padded and afBothInCharacters() then
                    state.Padded = true
                    task.spawn(function()
                        while afToggle('AutofarmEnabled') and not afInBoxCheck() do
                            local currentRole = afRole()
                            if currentRole == "winner" then
                                local fp = afFindEmptyFightPlace()
                                local pad1 = fp and afGetPads(fp)
                                if pad1 then
                                    afTeleport(pad1.CFrame + Vector3.new(0, 3, 0))
                                end
                            elseif currentRole == "loser" then
                                local fp, winnerPadIndex = afFindWinnerFightPlace()
                                local pad1, pad2 = afGetPads(fp)
                                if winnerPadIndex == 1 and pad2 then
                                    afTeleport(pad2.CFrame + Vector3.new(0, 3, 0))
                                elseif winnerPadIndex == 2 and pad1 then
                                    afTeleport(pad1.CFrame + Vector3.new(0, 3, 0))
                                end
                            end
                            task.wait(0.1)
                        end
                        state.Padded = false
                    end)
                end
            end
        end
    end)
end

local desync_setback = Instance.new("Part")
desync_setback.Name = "SND_DesyncSetback"
desync_setback.Size = Vector3.new(2, 2, 1)
desync_setback.Anchored = true
desync_setback.CanCollide = false
desync_setback.Transparency = 1
desync_setback.Parent = getgenv().Workspace

getgenv().desync = {
    enabled = false,
    mode = "Void",
    old_position = nil,
    target_position = nil,
    void_time = 0.4,
    normal_time = 0.133,
    timer = 0,
    custom_offset = Vector3.new(0, 0, 0),
}

local DesyncIndicatorGui = Instance.new("ScreenGui")
DesyncIndicatorGui.Name = "SND_DesyncIndicator"
DesyncIndicatorGui.ResetOnSpawn = false
DesyncIndicatorGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
DesyncIndicatorGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local DesyncIndicatorImage = Instance.new("ImageLabel")
DesyncIndicatorImage.Name = "Indicator"
DesyncIndicatorImage.Size = UDim2.new(0, 55, 0, 55)
DesyncIndicatorImage.BackgroundTransparency = 1
DesyncIndicatorImage.Image = "rbxassetid://17446642923"
DesyncIndicatorImage.Visible = false
DesyncIndicatorImage.ZIndex = 10
DesyncIndicatorImage.Parent = DesyncIndicatorGui

local dToolCheckEnabled = false
local dIndicatorEnabled = false
local dIndicatorSpin = false
local dIndicatorSize = 55
local dIndicatorRotation = 0
local dIndicatorLastPos = nil

local StrafeVis = {
    Enabled = false,
    Transparency = 0.5,
    Color = Color3.fromRGB(0, 140, 255),
    Folder = nil,
    Connection = nil,
    Parts = {},
    LastTool = nil,
}

local function dDestroyVisualizer()
    if StrafeVis.Connection then StrafeVis.Connection:Disconnect() StrafeVis.Connection = nil end
    if StrafeVis.Folder then StrafeVis.Folder:Destroy() StrafeVis.Folder = nil end
    StrafeVis.Parts = {}
end

local function dCreateVisualizer()
    dDestroyVisualizer()
    local char = getgenv().LocalPlayer.Character if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart") if not root then return end
    local folder = Instance.new("Folder")
    folder.Name = "SND_DesyncVisualizer"
    folder.Parent = getgenv().Workspace
    StrafeVis.Folder = folder
    for _, p in ipairs(char:GetChildren()) do
        if p:IsA("BasePart") and p.Name ~= "HumanoidRootPart" then
            local ghost = Instance.new("Part")
            ghost.Size = p.Size ghost.Anchored = true ghost.CanCollide = false ghost.CastShadow = false
            ghost.Material = Enum.Material.Neon ghost.Color = StrafeVis.Color ghost.Transparency = StrafeVis.Transparency
            ghost.TopSurface = Enum.SurfaceType.Smooth ghost.BottomSurface = Enum.SurfaceType.Smooth
            ghost.Parent = folder
            StrafeVis.Parts[p] = { part = ghost, offset = root.CFrame:Inverse() * p.CFrame }
        end
    end
    StrafeVis.Connection = getgenv().RunService.RenderStepped:Connect(function()
        local targetCF = getgenv().desync.target_position
        for realPart, data in pairs(StrafeVis.Parts) do
            if not realPart.Parent or not data.part or not data.part.Parent then
                StrafeVis.Parts[realPart] = nil
            else
                if targetCF then data.part.CFrame = targetCF * data.offset end
                data.part.Color = StrafeVis.Color
                data.part.Transparency = StrafeVis.Enabled and StrafeVis.Transparency or 1
            end
        end
    end)
end

local REFRESH_COOLDOWN = 0.04
local FORCE_REFRESH_EVERY = 0.04
local dLastAttempt = 0
local dLastFullCreate = 0

local function dTryUpdateVisualizer()
    if not StrafeVis.Enabled then return end
    local now = tick()
    if now - dLastAttempt < REFRESH_COOLDOWN then return end
    dLastAttempt = now
    local needsFull = now - dLastFullCreate >= FORCE_REFRESH_EVERY
    if not needsFull then
        local char = getgenv().LocalPlayer.Character
        if char then
            local currentTool = char:FindFirstChildWhichIsA("Tool")
            if currentTool ~= StrafeVis.LastTool then needsFull = true StrafeVis.LastTool = currentTool end
        end
    end
    if needsFull then
        dCreateVisualizer()
        dLastFullCreate = now
    else
        for _, data in pairs(StrafeVis.Parts) do
            if data.part and data.part.Parent then
                data.part.Color = StrafeVis.Color
                data.part.Transparency = StrafeVis.Transparency
            end
        end
    end
end

local function dSetupVisualizerListeners(char)
    if not char then return end
    char.ChildAdded:Connect(function(child) if child:IsA("Tool") or child:IsA("Accessory") then task.delay(0.03, dTryUpdateVisualizer) end end)
    char.ChildRemoved:Connect(function(child) if child:IsA("Tool") or child:IsA("Accessory") then task.delay(0.03, dTryUpdateVisualizer) end end)
end

task.spawn(function()
    while true do
        if getgenv().LizardGen ~= lizardGen then break end
        dTryUpdateVisualizer()
        if StrafeVis.Enabled then
            task.wait(0.033)
        else
            task.wait(0.5)
        end
    end
end)

getgenv().LocalPlayer.CharacterAdded:Connect(function(char)
    task.wait(0.15)
    if StrafeVis.Enabled then
        dCreateVisualizer()
        StrafeVis.LastTool = nil
        dLastFullCreate = tick()
        dSetupVisualizerListeners(char)
    end
end)

local function dResetCamera()
    local char = getgenv().LocalPlayer.Character
    if char and char:FindFirstChild("Humanoid") then
        getgenv().Workspace.CurrentCamera.CameraSubject = char.Humanoid
    end
end

local function setDesync(state)
    getgenv().desync.enabled = state
    if not state then
        dResetCamera()
        getgenv().desync.timer = 0
        getgenv().desync.target_position = nil
        desync_setback.CFrame = CFrame.new(0, -2000, 0)
        DesyncIndicatorImage.Visible = false
        dIndicatorRotation = 0
        dIndicatorLastPos = nil
    end
end

getgenv().RunService.Heartbeat:Connect(function(dt)
    local desync = getgenv().desync
    if not desync.enabled then
        desync.target_position = nil
        return
    end
    local char = getgenv().LocalPlayer.Character
    if not char then return end
    if dToolCheckEnabled and char:FindFirstChildWhichIsA("Tool") then
        desync.target_position = nil
        dResetCamera()
        desync_setback.CFrame = CFrame.new(0, -2000, 0)
        return
    end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end
    desync.old_position = root.CFrame
    local target = desync.old_position
    if desync.mode == "void" then
        target = CFrame.new(root.Position + Vector3.new(math.random(-9e8, 9e8), math.random(1e8, 9e8), math.random(-9e8, 9e8)))
    elseif desync.mode == "spam void" then
        desync.timer += dt
        if desync.timer < desync.void_time then
            target = CFrame.new(root.Position + Vector3.new(math.random(-9e8, 9e8), math.random(1e8, 9e8), math.random(-9e8, 9e8)))
        end
        if desync.timer >= desync.void_time + desync.normal_time then desync.timer = 0 end
    elseif desync.mode == "Chaos" then
        local t = tick() * 999
        target = CFrame.new(root.Position + Vector3.new(math.sin(t) * 9e8, math.abs(math.cos(t * 1.3)) * 9e8, math.sin(t * 0.7) * 9e8))
    elseif desync.mode == "Epilepsy" then
        local flip = math.floor(tick() * 60) % 2 == 0
        target = flip and CFrame.new(root.Position + Vector3.new(9e8, 9e8, 9e8)) or CFrame.new(root.Position + Vector3.new(-9e8, -9e8, -9e8))
    elseif desync.mode == "Custom" then
        target = desync.old_position + desync.custom_offset
    elseif desync.mode == "Underground" then
        target = CFrame.new(root.Position - Vector3.new(0, 6, 0)) * CFrame.Angles(math.pi/2, 0, 0)
    end
    desync.target_position = target
    dIndicatorLastPos = target.Position
    root.CFrame = target
    desync_setback.CFrame = desync.old_position
    getgenv().Workspace.CurrentCamera.CameraSubject = desync_setback
    getgenv().RunService.RenderStepped:Wait()
    root.CFrame = desync.old_position
    desync_setback.CFrame = CFrame.new(0, -2000, 0)
    dResetCamera()
end)

getgenv().DesyncIndicatorConnection = getgenv().RunService.RenderStepped:Connect(function()
    if not getgenv().desync.enabled or not dIndicatorEnabled or not dIndicatorLastPos then
        DesyncIndicatorImage.Visible = false
        return
    end
    local cam = getgenv().Workspace.CurrentCamera
    local screenPos, onScreen = cam:WorldToViewportPoint(dIndicatorLastPos)
    if onScreen then
        local half = dIndicatorSize / 2
        DesyncIndicatorImage.Size = UDim2.new(0, dIndicatorSize, 0, dIndicatorSize)
        DesyncIndicatorImage.Position = UDim2.new(0, screenPos.X - half, 0, screenPos.Y - half)
        if dIndicatorSpin then
            dIndicatorRotation = (dIndicatorRotation + 2) % 360
            DesyncIndicatorImage.Rotation = dIndicatorRotation
        else
            DesyncIndicatorImage.Rotation = 0
        end
        DesyncIndicatorImage.Visible = true
    else
        DesyncIndicatorImage.Visible = false
    end
end)

if getgenv().LocalPlayer.Character then
    task.delay(0.1, function() dSetupVisualizerListeners(getgenv().LocalPlayer.Character) end)
end

local plrs = game:GetService("Players")
local uis = game:GetService("UserInputService")
local lp = plrs.LocalPlayer

local animId = "70883871260184"
local gm_on = false
local gm_root, gm_ghost, gm_hip, gm_track

local function gm_anim()
    local char = lp.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    local animator = hum:FindFirstChildOfClass("Animator") or Instance.new("Animator", hum)
    local a = Instance.new("Animation")
    a.AnimationId = "rbxassetid://" .. animId
    gm_track = animator:LoadAnimation(a)
    gm_track.Priority = Enum.AnimationPriority.Core
    gm_track:Play(0, 1, 0)
    a:Destroy()
    task.delay(0, function()
        if gm_track then
            gm_track.TimePosition = 0.7
            task.delay(0.3, function()
                if gm_track then gm_track:AdjustSpeed(math.huge) end
            end)
        end
    end)
    return true
end

local function gm_fake()
    local char = lp.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health <= 0 then return end
    gm_root = char:FindFirstChild("HumanoidRootPart")
    if not gm_root then return end
    gm_hip = hum.HipHeight
    gm_ghost = gm_root:Clone()
    gm_ghost.Name = "r"
    gm_ghost.Parent = char
    gm_ghost.CFrame = gm_root.CFrame
    gm_ghost.Transparency = 1
    gm_ghost.CanCollide = false
    gm_ghost.Anchored = false
    gm_ghost.CastShadow = false
    gm_ghost.Massless = true
    gm_root.Transparency = 1
    gm_root.CanCollide = false
    gm_root.CastShadow = false
    char.PrimaryPart = gm_ghost
end

local function gm_undo()
    local char = lp.Character
    if not char or not gm_root or not gm_ghost then gm_root = nil return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    gm_ghost:Destroy() gm_ghost = nil
    gm_root.Transparency = 1
    gm_root.CanCollide = true
    gm_root.CastShadow = true
    char.PrimaryPart = gm_root
    if hum then
        hum.HipHeight = gm_hip or 0
        hum:ChangeState(Enum.HumanoidStateType.Running)
    end
    gm_root = nil
end

local function gm_start()
    if gm_on then return end
    gm_on = true
    if not gm_anim() then gm_on = false return end
    task.wait(0.1)
    gm_fake()
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Godmode",
        Text = "Godmode is now enabled",
        Duration = 3,
    })
end

local function gm_stop()
    if not gm_on then return end
    gm_on = false
    if gm_track then pcall(function() gm_track:Stop() end) gm_track = nil end
    gm_undo()
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Godmode",
        Text = "Godmode is now disabled nigga",
        Duration = 3,
    })
end

lp.CharacterRemoving:Connect(function()
    if gm_on then gm_stop() end
end)

VoidGb:AddToggle('GodmodeToggle', {
    Text = 'Godmode',
    Default = false,
    Callback = function(v)
        if v then gm_start() else gm_stop() end
    end
}):AddKeyPicker('GodmodeKeybind', {
    Default = 'B',
    Mode = 'Toggle',
    Text = 'Godmode',
    SyncToggleState = true,
    Callback = function(state)
        if state then gm_start() else gm_stop() end
    end
})
VoidGb:AddToggle("DesyncToggle", {
    Text = "enable desync", Default = false,
    Callback = function(v)
        Toggles.DesyncToggle:SetText(v and "Anti Aim: ON" or "Anti Aim: OFF")
        setDesync(v)
    end
}):AddKeyPicker("DesyncKeybind", {
    Text = "Bind", Default = "V", Mode = "Toggle",
    SyncToggleState = true,
    Callback = function(state)
        setDesync(state)
    end
})

VoidGb:AddDropdown("DesyncMethod", {
    Values = {"void", "spam void", "Chaos", "Epilepsy", "Custom", "Underground"},
    Default = "void", Text = "Mode",
    Callback = function(v) getgenv().desync.mode = v end
})

VoidGb:AddToggle("ToolCheckToggle", {
    Text = "Disable when tool held", Default = false,
    Callback = function(v) dToolCheckEnabled = v end
})

VoidGb:AddToggle("StrafeVisToggle", {
    Text = "Rig", Default = false,
    Callback = function(v)
        StrafeVis.Enabled = v
        if v then
            dCreateVisualizer()
            StrafeVis.LastTool = nil
            dLastFullCreate = tick()
            if getgenv().LocalPlayer.Character then dSetupVisualizerListeners(getgenv().LocalPlayer.Character) end
        else
            dDestroyVisualizer()
        end
    end
}):AddColorPicker("VisColor", {
    Default = Color3.fromRGB(0, 140, 255),
    Callback = function(v)
        StrafeVis.Color = v
        dTryUpdateVisualizer()
    end
})

VoidGb:AddSlider("VisTransparency", {
    Text = "Rig Transparency", Default = 0.5, Min = 0, Max = 1, Rounding = 2,
    Callback = function(v) StrafeVis.Transparency = v dTryUpdateVisualizer() end
})

VoidGb:AddToggle("IndicatorToggle", {
    Text = "Indicator", Default = false,
    Callback = function(v)
        dIndicatorEnabled = v
        if not v then
            DesyncIndicatorImage.Visible = false
            dIndicatorRotation = 0
        end
    end
})

VoidGb:AddToggle("IndicatorSpin", {
    Text = "Spin Indicator", Default = false,
    Callback = function(v)
        dIndicatorSpin = v
        if not v then dIndicatorRotation = 0 DesyncIndicatorImage.Rotation = 0 end
    end
})

VoidGb:AddSlider("IndicatorSize", {
    Text = "Indicator Size", Default = 55, Min = 20, Max = 150, Rounding = 0,
    Callback = function(v) dIndicatorSize = v end
})

VoidGb:AddSlider("VoidTime", {
    Text = "Void Time", Default = 0.4, Min = 0.05, Max = 2, Rounding = 2,
    Callback = function(v) getgenv().desync.void_time = v end
})

VoidGb:AddSlider("GroundTime", {
    Text = "Ground Time", Default = 0.133, Min = 0.05, Max = 2, Rounding = 2,
    Callback = function(v) getgenv().desync.normal_time = v end
})

VoidGb:AddSlider("CustomX", {
    Text = "X Offset", Default = 0, Min = -25, Max = 25, Rounding = 1,
    Callback = function(v) local d = getgenv().desync d.custom_offset = Vector3.new(v, d.custom_offset.Y, d.custom_offset.Z) end
})

VoidGb:AddSlider("CustomY", {
    Text = "Y Offset", Default = 0, Min = -25, Max = 25, Rounding = 1,
    Callback = function(v) local d = getgenv().desync d.custom_offset = Vector3.new(d.custom_offset.X, v, d.custom_offset.Z) end
})

VoidGb:AddSlider("CustomZ", {
    Text = "Z Offset", Default = 0, Min = -25, Max = 25, Rounding = 1,
    Callback = function(v) local d = getgenv().desync d.custom_offset = Vector3.new(d.custom_offset.X, d.custom_offset.Y, v) end
})
VoidGb:AddToggle("AutoVoidOnHit", { Text = "Auto Void on Hit", Default = false })
VoidGb:AddSlider("AutoVoidOnHitDuration", { Text = "Auto Void Duration", Default = 2, Min = 0.5, Max = 10, Rounding = 1 })
VoidGb:AddToggle("CSyncEnabled", { Text = "CSync", Default = false })
VoidGb:AddDropdown("CSyncType", { Text = "CSync Type", Values = { "Void", "None" }, Default = "Void" })

local function createFOV()
    local fov = getgenv().Config.Visual.FOV

    local function makeDrawing(type)
        local d = Drawing.new(type)
        d.Visible = false
        return d
    end

    if not fov.InnerCircle then fov.InnerCircle = makeDrawing("Circle") end
    if not fov.OuterCircle then fov.OuterCircle = makeDrawing("Circle") end
    if not fov.FillCircle then fov.FillCircle = makeDrawing("Circle") end

    if not fov.Lines then
        fov.Lines = {}
        for i = 1, 12 do fov.Lines[i] = makeDrawing("Line") end
    end

    if not fov.Triangles then
        fov.Triangles = {}
        for i = 1, 6 do fov.Triangles[i] = makeDrawing("Triangle") end
    end

    if not fov.ScreenGui then
        local sg = Instance.new("ScreenGui")
        sg.Name = "LizardFOV"
        sg.IgnoreGuiInset = true
        sg.DisplayOrder = 999
        sg.Parent = game.CoreGui
        fov.ScreenGui = sg

        local frame = Instance.new("Frame")
        frame.Name = "Main"
        frame.BackgroundTransparency = 0
        frame.BorderSizePixel = 0
        frame.AnchorPoint = Vector2.new(0.5, 0.5)
        frame.Parent = sg
        fov.MainFrame = frame

        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(1, 0)
        corner.Parent = frame
        fov.UICorner = corner
    end

    getgenv().LizardFOV = {
        Inner = fov.InnerCircle,
        Outer = fov.OuterCircle,
        ScreenGui = fov.ScreenGui,
        MainFrame = fov.MainFrame,
        UICorner = fov.UICorner
    }
end

local MiscTabBox = getgenv().Tabs.Misc:AddLeftTabbox()
local TabCharacter = MiscTabBox:AddTab('Avatar')

local AutoGb = getgenv().Tabs.Misc:AddRightGroupbox('Auto')
AutoGb:AddToggle('AutoHealEnabled', { Text = 'Auto Heal', Default = false })
AutoGb:AddSlider('AutoHealThreshold', { Text = 'Heal Threshold', Default = 50, Min = 10, Max = 100, Rounding = 0 })
local BodyPartsGb = getgenv().Tabs.Misc:AddLeftGroupbox('body parts')
local CrosshairGb = getgenv().Tabs.Misc:AddLeftGroupbox('Crosshair')

do
    CrosshairGb:AddToggle('EnableCrosshair', { Text = 'Enable Crosshair', Default = false })
    CrosshairGb:AddToggle('CrosshairFollowMouse', { Text = 'Follow Mouse', Default = true })
    CrosshairGb:AddSlider('CrosshairGap', { Text = 'Gap', Default = 14, Min = 0, Max = 60, Rounding = 0 })
    CrosshairGb:AddSlider('CrosshairLength', { Text = 'Length', Default = 80, Min = 1, Max = 200, Rounding = 0 })
    CrosshairGb:AddSlider('CrosshairThickness', { Text = 'Thickness', Default = 2, Min = 1, Max = 10, Rounding = 0 })
    CrosshairGb:AddSlider('CrosshairRotation', { Text = 'Rotation Speed', Default = 200, Min = 0, Max = 800, Rounding = 0 })
    CrosshairGb:AddSlider('CrosshairPulseSpeed', { Text = 'Pulse Speed', Default = 3, Min = 0, Max = 15, Rounding = 0 })
    CrosshairGb:AddSlider('CrosshairShadowX', { Text = 'Shadow Offset X', Default = 2, Min = 0, Max = 10, Rounding = 0 })
    CrosshairGb:AddSlider('CrosshairShadowY', { Text = 'Shadow Offset Y', Default = 2, Min = 0, Max = 10, Rounding = 0 })
    CrosshairGb:AddLabel('Line Color'):AddColorPicker('CrosshairColor', { Default = Color3.fromRGB(255, 255, 255), Title = 'Line Color' })
    CrosshairGb:AddLabel('Glow Color'):AddColorPicker('CrosshairGlowColor', { Default = Color3.fromRGB(133, 220, 255), Title = 'Glow Color' })

    local function mkLine(z)
        local l = Drawing.new('Line')
        l.Thickness = 2; l.Color = Color3.fromRGB(255, 255, 255); l.Visible = false; l.ZIndex = z
        return l
    end
    local chLines = { mkLine(5), mkLine(5), mkLine(5), mkLine(5) }
    local glowLines = { mkLine(4), mkLine(4), mkLine(4), mkLine(4) }
    getgenv().CrosshairLines = {
        chLines[1], chLines[2], chLines[3], chLines[4],
        glowLines[1], glowLines[2], glowLines[3], glowLines[4],
    }

    local dirs = { Vector2.new(0, -1), Vector2.new(0, 1), Vector2.new(-1, 0), Vector2.new(1, 0) }

    getgenv().CrosshairConnection = getgenv().RunService.RenderStepped:Connect(function()
        if not (Toggles.EnableCrosshair and Toggles.EnableCrosshair.Value) then
            for _, l in ipairs(chLines) do l.Visible = false end
            for _, l in ipairs(glowLines) do l.Visible = false end
            return
        end
        local vp = getgenv().Camera and getgenv().Camera.ViewportSize or Vector2.new(0, 0)
        local center
        if Toggles.CrosshairFollowMouse and Toggles.CrosshairFollowMouse.Value then
            local m = getgenv().UserInputService:GetMouseLocation()
            center = Vector2.new(m.X, m.Y)
        else
            center = Vector2.new(vp.X / 2, vp.Y / 2)
        end
        local gap = (Options.CrosshairGap and Options.CrosshairGap.Value) or 14
        local len = (Options.CrosshairLength and Options.CrosshairLength.Value) or 80
        local thick = (Options.CrosshairThickness and Options.CrosshairThickness.Value) or 2
        local rotSpeed = (Options.CrosshairRotation and Options.CrosshairRotation.Value) or 0
        local pulseSpeed = (Options.CrosshairPulseSpeed and Options.CrosshairPulseSpeed.Value) or 0
        local shadowX = (Options.CrosshairShadowX and Options.CrosshairShadowX.Value) or 0
        local shadowY = (Options.CrosshairShadowY and Options.CrosshairShadowY.Value) or 0
        local col = (Options.CrosshairColor and Options.CrosshairColor.Value) or Color3.fromRGB(255, 255, 255)
        local glowCol = (Options.CrosshairGlowColor and Options.CrosshairGlowColor.Value) or Color3.fromRGB(133, 220, 255)

        local t = tick()
        if pulseSpeed > 0 then
            gap = math.max(0, gap + math.sin(t * pulseSpeed) * 6)
        end
        local rot = math.rad((t * rotSpeed) % 360)
        local cosR, sinR = math.cos(rot), math.sin(rot)
        local shadow = Vector2.new(shadowX, shadowY)

        for i = 1, 4 do
            local d = dirs[i]
            local rd = Vector2.new(d.X * cosR - d.Y * sinR, d.X * sinR + d.Y * cosR)
            local from = center + rd * gap
            local to = center + rd * (gap + len)

            local gl = glowLines[i]
            gl.From = from + shadow; gl.To = to + shadow
            gl.Color = glowCol; gl.Thickness = thick + 3; gl.Visible = true

            local l = chLines[i]
            l.From = from; l.To = to
            l.Color = col; l.Thickness = thick; l.Visible = true
        end
    end)
end

local function applyAutoBox()
    local AutoBox = AutoGb
    local MoveBox = getgenv().Tabs.Misc:AddRightGroupbox('Movement')

local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")
local LocalPlayer = Players.LocalPlayer
local function PerformReset()
    StarterGui:SetCore("ResetButtonCallback", true)
    local character = LocalPlayer.Character
    if character then
        local humanoid = character:FindFirstChildOfClass("Humanoid")

        if getgenv().replicatesignal then
            getgenv().replicatesignal(LocalPlayer.Kill)
        elseif humanoid then
            humanoid:ChangeState(Enum.HumanoidStateType.Dead)
            humanoid.Health = 0
        end
    end
end

local ForceResetToggle = AutoBox:AddToggle('ForceReset', {
    Text = 'Force Reset',
    Default = false,
    Tooltip = 'Enable this to allow the Keybind to work',
    SyncToggleState = false,
    Callback = function(Value)
        if Value then
            PerformReset()
        end
    end
})

ForceResetToggle:AddKeyPicker('ForceResetKey', {
    Default = 'P',
    Mode = 'Toggle',
    Text = 'Force Reset',
    NoUI = false,
    Callback = function()
        if Toggles.ForceReset.Value then
            PerformReset()
        end
    end
})

getgenv().ForceHit = {}

getgenv().ForceHit.StrafeMode = "Orbit"
getgenv().ForceHit.LookAtTarget = false
getgenv().ForceHit.SpectateTarget = false
local KillAura = Tabs.Main:AddRightGroupbox("Strafe")

KillAura:AddToggle("StompTarget", {Text="Stomp Target", Default=false, Callback=function(v) getgenv().stompTargetEnabled=v end})
KillAura:AddToggle("SpectateTarget", {Text="Spectate Target", Default=false, Callback=function(v) getgenv().ForceHit.SpectateTarget=v end})

local DesyncPart = Instance.new("Part")
DesyncPart.Name="DesyncVisual"
DesyncPart.Size=Vector3.new(2,2,1)
DesyncPart.Transparency=1
DesyncPart.CanCollide=false
DesyncPart.Anchored=true
DesyncPart.Parent=workspace

local strafeToggleEnabled = false
local strafeKeybindEnabled = false
local strafeCamera = workspace.CurrentCamera

local function resetStrafeCamera()
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildWhichIsA("Humanoid")
    if hum then strafeCamera.CameraSubject = hum end
end

local toggle = KillAura:AddToggle("StrafeToggle", {Text="Target Strafe", Default=false, Callback=function(v)
    strafeToggleEnabled = v
    getgenv().ForceHit.StrafeEnabled = v and strafeKeybindEnabled
    if not v then
        resetStrafeCamera()
        getgenv().ForceHit.LookAtTarget = true
    end
end})

toggle:AddKeyPicker("StrafeKeybind", {Default="N", Mode="Toggle", NoSync=true, Text="Target Strafe", Callback=function(s)
    strafeKeybindEnabled = s
    getgenv().ForceHit.StrafeEnabled = strafeToggleEnabled and s
    if not s then
        resetStrafeCamera()
        getgenv().ForceHit.LookAtTarget = true
    end
end})

KillAura:AddToggle("spoofstrafe", {Text="Spoof", Default=false, Callback=function(v)
    getgenv().ForceHit.strafespoof = v
    if not v then resetStrafeCamera() end
end})

KillAura:AddToggle("visualizestrafe", {Text="Visualize Strafe", Default=false, Callback=function(v)
    getgenv().ForceHit.VisualizeStrafe = v
    if not v and getgenv().ForceHit.Visualizer then
        getgenv().ForceHit.Visualizer:Destroy()
        getgenv().ForceHit.Visualizer = nil
        getgenv().ForceHit.VisualizerMotors = nil
    end
end})

KillAura:AddSlider("StrafeSpeedSlider", {Text="Strafe Speed", Min=1, Max=30, Default=5, Rounding=1, Callback=function(v) getgenv().ForceHit.StrafeSpeed=v end})
KillAura:AddSlider("StrafeDistanceSlider", {Text="Strafe Distance", Min=1, Max=20, Default=5, Rounding=1, Callback=function(v) getgenv().ForceHit.StrafeDistance=v end})
KillAura:AddSlider("StrafeHeightSlider", {Text="Strafe Height", Min=-15, Max=15, Default=0, Rounding=1, Callback=function(v) getgenv().ForceHit.StrafeHeight=v end})

KillAura:AddDropdown("StrafeModeDropdown", {Values={"Orbit","Random","Void Shoot"}, Default="Orbit", Text="Strafe Mode", Callback=function(v) getgenv().ForceHit.StrafeMode=v end})

local function destroyStrafeVisualizer()
    if getgenv().ForceHit.StrafeVisConnection then
        getgenv().ForceHit.StrafeVisConnection:Disconnect()
        getgenv().ForceHit.StrafeVisConnection = nil
    end
    if getgenv().ForceHit.StrafeVisParts then
        for _, data in pairs(getgenv().ForceHit.StrafeVisParts) do
            if data.part then data.part:Destroy() end
        end
        getgenv().ForceHit.StrafeVisParts = nil
    end
end

local function createStrafeVisualizer()
    destroyStrafeVisualizer()
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return end
    local parts = {}
    getgenv().ForceHit.StrafeVisParts = parts
    for _, p in ipairs(char:GetChildren()) do
        if p:IsA("BasePart") and p.Name ~= "HumanoidRootPart" then
            local vis = Instance.new("Part")
            vis.Name = p.Name.."_StrafeGhost"
            vis.Size = p.Size
            vis.Anchored = true
            vis.CanCollide = false
            vis.CastShadow = false
            vis.Material = Enum.Material.Neon
            vis.Color = Color3.fromRGB(255,255,255)
            vis.Transparency = 0
            vis.Parent = strafeCamera
            local offset = root.CFrame:Inverse() * p.CFrame
            parts[p.Name] = {part=vis, offset=offset, currentCF=vis.CFrame}
        end
    end
    local alpha = 0.18
    getgenv().ForceHit.CurrentStrafeCF = root.CFrame
    getgenv().ForceHit.StrafeVisConnection = RunService.RenderStepped:Connect(function()
        local baseCF = getgenv().ForceHit.CurrentStrafeCF
        if not baseCF then return end
        for _, data in pairs(parts) do
            local targetCF = baseCF * data.offset
            data.currentCF = data.currentCF:Lerp(targetCF, alpha)
            data.part.CFrame = data.currentCF
        end
    end)
end

local function stopStrafe()
    if getgenv().ForceHit.StrafeConnection then
        getgenv().ForceHit.StrafeConnection:Disconnect()
        getgenv().ForceHit.StrafeConnection = nil
    end
    getgenv().ForceHit.CurrentStrafeCF = nil
    getgenv().CurrentStrafeCF = nil
    destroyStrafeVisualizer()
    resetStrafeCamera()
    getgenv().ForceHit.LookAtTarget = true
end

local function startStrafe()
    if getgenv().ForceHit.StrafeConnection then
        getgenv().ForceHit.StrafeConnection:Disconnect()
        getgenv().ForceHit.StrafeConnection = nil
    end
    if getgenv().ForceHit.VisualizeStrafe then createStrafeVisualizer() end

    getgenv().ForceHit.LookAtTarget = false

    local strafeTime = 0
    local voidPhase = false
    local voidTimer = 0

    getgenv().ForceHit.StrafeConnection = RunService.Heartbeat:Connect(function(dt)
        strafeTime += dt

        if not getgenv().ForceHit.StrafeEnabled or not getgenv().ForceHitTarget then
            stopStrafe()
            return
        end

        local char = LocalPlayer.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        local targetChar = getgenv().ForceHitTarget.Character
        local targetRoot = targetChar and targetChar:FindFirstChild("HumanoidRootPart")
        local targetHum = targetChar and targetChar:FindFirstChildWhichIsA("Humanoid")

        if not (root and targetRoot and targetHum and targetHum.Health > 0) then
            stopStrafe()
            return
        end

        local targetPos = targetRoot.Position
        local desired

        if getgenv().ForceHit.StrafeMode == "Orbit" then
            local angle = strafeTime * (getgenv().ForceHit.StrafeSpeed or 5)
            desired = CFrame.lookAt(
                targetPos + Vector3.new(
                    math.cos(angle) * (getgenv().ForceHit.StrafeDistance or 8),
                    getgenv().ForceHit.StrafeHeight or 0,
                    math.sin(angle) * (getgenv().ForceHit.StrafeDistance or 8)
                ),
                targetPos
            )

        elseif getgenv().ForceHit.StrafeMode == "Random" then
            local t = strafeTime * 40
            local offset = Vector3.new(
                math.noise(t,0,0) * 20,
                math.noise(0,t,0) * 15 + (getgenv().ForceHit.StrafeHeight or 0),
                math.noise(0,0,t) * 20
            )
            desired = CFrame.lookAt(targetPos + offset, targetPos)

        elseif getgenv().ForceHit.StrafeMode == "Void Shoot" then
            voidTimer += dt
            local isShooting = tick() - (getgenv().ForceHit.LastShotTime or 0) < 0.12

            if isShooting then
                voidPhase = false
                voidTimer = 0
                desired = CFrame.lookAt(
                    targetPos + Vector3.new(0, 200, 2),
                    targetPos
                )
            else
                local voidTime = getgenv().ForceHit.VoidTime or 0.4
                local groundTime = getgenv().ForceHit.GroundTime or 0.133

                if not voidPhase then
                    if voidTimer >= groundTime then
                        voidPhase = true
                        voidTimer = 0
                    end
                    desired = CFrame.lookAt(
                        targetPos + Vector3.new(0, 3, 2),
                        targetPos
                    )
                else
                    if voidTimer >= voidTime then
                        voidPhase = false
                        voidTimer = 0
                    end
                    desired = CFrame.new(
                        targetPos + Vector3.new(0, 10000, 0)
                    )
                end
            end
        end

        if not desired then return end

        if getgenv().ForceHit.VisualizeStrafe then
            getgenv().ForceHit.CurrentStrafeCF = desired
        end

        if getgenv().ForceHit.strafespoof then
            local real = root.CFrame
            DesyncPart.CFrame = real + Vector3.new(0, 5, 0)
            strafeCamera.CameraSubject = DesyncPart
            root.CFrame = desired
            RunService.RenderStepped:Wait()
            root.CFrame = real
            resetStrafeCamera()
        else
            root.CFrame = desired
            local targetSubject = targetChar:FindFirstChild("Head") or targetHum
            local selfSubject = char:FindFirstChildWhichIsA("Humanoid")
            strafeCamera.CameraSubject = getgenv().ForceHit.SpectateStrafe and targetSubject or selfSubject
        end
    end)
end

task.spawn(function()
    while task.wait(0.1) do
        if getgenv().LizardGen ~= lizardGen then break end
        if getgenv().ForceHit.StrafeEnabled and getgenv().ForceHitTarget then
            if not getgenv().ForceHit.StrafeConnection then
                startStrafe()
            end
        else
            if getgenv().ForceHit.StrafeConnection then
                stopStrafe()
            end
        end
    end
end)

getgenv().autoGrabEnabled = false
getgenv().autoGrabCooldown = 1

KillAura:AddToggle("AutoGrabToggle", {Text="Auto Grab", Default=false, Callback=function(v)
    getgenv().autoGrabEnabled = v
end})

KillAura:AddSlider("AutoGrabCooldownSlider", {Text="Grab Cooldown", Min=0.1, Max=5, Default=1, Rounding=1, Callback=function(v)
    getgenv().autoGrabCooldown = v
end})

task.spawn(function()
    while task.wait(getgenv().autoGrabCooldown) do
        if getgenv().LizardGen ~= lizardGen then break end
        if not (getgenv().autoGrabEnabled and getgenv().ForceHitTarget and getgenv().ForceHitTarget ~= LocalPlayer) then continue end
        local targetChar = getgenv().ForceHitTarget.Character
        local body = targetChar and targetChar:FindFirstChild("BodyEffects")
        local ko = body and body:FindFirstChild("K.O") and body["K.O"].Value
        if not ko then continue end
        local targetHrp = targetChar:FindFirstChild("HumanoidRootPart")
        local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if not targetHrp or not hrp then continue end

        local real = hrp.CFrame
        local wasStrafing = getgenv().ForceHit.strafespoof
        local wasStrafeEnabled = getgenv().ForceHit.StrafeEnabled

        getgenv().ForceHit.strafespoof = false
        getgenv().ForceHit.StrafeEnabled = false
        stopStrafe()

        if wasStrafing then
            DesyncPart.CFrame = real + Vector3.new(0,5,0)
            strafeCamera.CameraSubject = DesyncPart
        end

        hrp.CFrame = CFrame.new(targetHrp.Position + Vector3.new(0,3,0))
        ReplicatedStorage.MainEvent:FireServer("Grabbing")
        RunService.RenderStepped:Wait()
        hrp.CFrame = real

        getgenv().ForceHit.strafespoof = wasStrafing
        getgenv().ForceHit.StrafeEnabled = wasStrafeEnabled
        resetStrafeCamera()

        local grabbed = body:FindFirstChild("Grabbed")
        if grabbed then
            local timeout = tick()
            while tick() - timeout < 2 do
                if grabbed.Value == LocalPlayer.Name then
                    targetHrp.CFrame = real
                    break
                end
                task.wait()
            end
        end
    end
end)

    local TextChatService = game:GetService("TextChatService")
    local chatConfig = TextChatService.ChatWindowConfiguration
    local originalBG = chatConfig.BackgroundColor3
    local originalTransparency = chatConfig.BackgroundTransparency
    local originalTextColor = chatConfig.TextColor3
    local originalTextSize = chatConfig.TextSize
    local originalAlignment = chatConfig.VerticalAlignment

    AutoBox:AddToggle('ChatSpyEnabled', {
        Text = 'chatspy',
        Default = false,
        Callback = function(v)
            if v then
                chatConfig.Enabled = true
                chatConfig.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
                chatConfig.BackgroundTransparency = 0.8
                chatConfig.TextColor3 = Color3.fromRGB(255, 255, 255)
                chatConfig.TextSize = 13
                chatConfig.VerticalAlignment = Enum.VerticalAlignment.Top
            else
                chatConfig.BackgroundColor3 = originalBG
                chatConfig.BackgroundTransparency = originalTransparency
                chatConfig.TextColor3 = originalTextColor
                chatConfig.TextSize = originalTextSize
                chatConfig.VerticalAlignment = originalAlignment
            end
        end
    })

    AutoBox:AddToggle('AntiVoidEnabled', {
        Text = 'Anti Void',
        Default = false,
        Callback = function(v)
            if v then
                workspace.FallenPartsDestroyHeight = -math.huge
            else
                workspace.FallenPartsDestroyHeight = -50
            end
        end
    })

    AutoBox:AddToggle('Flashback', {
        Text = 'respawn where you died',
        Default = false,
        Callback = function(value)
            if getgenv().flashback and getgenv().flashback.settings then
                getgenv().flashback.settings.enabled = value
            end
        end,
    })

    AutoBox:AddToggle('StompToggle', {
        Text = 'auto stomp',
        Default = false,
        Callback = function(v)
            if v then
                getgenv().StompLoop = task.spawn(function()
                    while task.wait(0.1) do
                        if getgenv().LizardGen ~= lizardGen then break end
                        if not Toggles.StompToggle.Value then break end
                        getgenv().MainEvent:FireServer("Stomp")
                    end
                end)
            else
                if getgenv().StompLoop then
                    task.cancel(getgenv().StompLoop)
                    getgenv().StompLoop = nil
                end
            end
        end
    })

    AutoBox:AddToggle('AutoRejoinToggle', {
        Text = 'auto rejoin when kicked',
        Default = false,
        Callback = function(v)
            if v then
                getgenv().AutoRejoinConnection = getgenv().GuiService.ErrorMessageChanged:Connect(function()
                    getgenv().TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, getgenv().LocalPlayer)
                end)
            else
                if getgenv().AutoRejoinConnection then
                    getgenv().AutoRejoinConnection:Disconnect()
                    getgenv().AutoRejoinConnection = nil
                end
            end
        end
    })

    local FOOD_TOOL_NAMES = {
        "[Pizza]", "[Chicken]", "[Taco]", "[Popcorn]",
        "[Hamburger]", "[HotDog]", "[Lettuce]",
    }

    local function isFoodTool(tool)
        if not tool or not tool:IsA("Tool") then return false end
        for _, foodName in ipairs(FOOD_TOOL_NAMES) do
            if tool.Name == foodName then
                return true
            end
        end
        local lowered = string.lower(tool.Name)
        return lowered:find("pizza", 1, true)
            or lowered:find("chicken", 1, true)
            or lowered:find("taco", 1, true)
            or lowered:find("burger", 1, true)
            or lowered:find("hotdog", 1, true)
            or lowered:find("lettuce", 1, true)
            or lowered:find("popcorn", 1, true)
    end

    local function findFoodTool()
        local character = getgenv().LocalPlayer.Character
        if character then
            for _, child in ipairs(character:GetChildren()) do
                if isFoodTool(child) then
                    return child
                end
            end
        end
        local backpack = getgenv().LocalPlayer:FindFirstChildOfClass("Backpack")
        if backpack then
            for _, child in ipairs(backpack:GetChildren()) do
                if isFoodTool(child) then
                    return child
                end
            end
        end
        return nil
    end

    AutoBox:AddToggle('AutoFoodToggle', {
        Text = 'Auto Food',
        Default = false,
        Callback = function(v)
            if v then
                getgenv().AutoFoodLoop = task.spawn(function()
                    while task.wait(0.25) do
                        if getgenv().LizardGen ~= lizardGen then break end
                        if not (Toggles.AutoFoodToggle and Toggles.AutoFoodToggle.Value) then break end

                        local character = getgenv().LocalPlayer.Character
                        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
                        if not humanoid or humanoid.Health <= 0 then
                            continue
                        end

                        local threshold = math.max((humanoid.MaxHealth > 0 and humanoid.MaxHealth or 100) * 0.65, 45)
                        if humanoid.Health > threshold then
                            continue
                        end

                        local foodTool = findFoodTool()
                        if not foodTool then
                            continue
                        end

                        if foodTool.Parent ~= character then
                            humanoid:EquipTool(foodTool)
                            task.wait(0.12)
                        end

                        pcall(function() foodTool:Activate() end)
                    end
                end)
            else
                if getgenv().AutoFoodLoop then
                    task.cancel(getgenv().AutoFoodLoop)
                    getgenv().AutoFoodLoop = nil
                end
            end
        end
    })

    AutoBox:AddToggle('AntiStaffEnabled', {
        Text = 'Anti Staff',
        Default = getgenv().AntiStaffSettings.Enabled,
        Callback = function(value)
            getgenv().AntiStaffSettings.Enabled = value
        end,
    })

    AutoBox:AddDropdown('AntiStaffAction', {
        Text = 'Action',
        Default = getgenv().AntiStaffSettings.Action,
        Values = { 'Notify', 'Kick', 'Both' },
        Callback = function(value)
            getgenv().AntiStaffSettings.Action = value
        end,
    })

    MoveBox:AddToggle('FlightToggle', {
        Text = 'Flight', Default = false,
        Callback = function(v)
            getgenv().FlightEnabled = v
            if v then getgenv().StartFly() else getgenv().StopFly() end
        end
    }):AddKeyPicker('FlightKeybind', {
        Default = 'X', Mode = 'Toggle', Text = 'Flight',
        SyncToggleState = true,
        Callback = function(state)
            if state then getgenv().StartFly() else getgenv().StopFly() end
        end
    })
    MoveBox:AddSlider('FlySpeed', {Text='Fly Speed', Default=50, Min=10, Max=500, Rounding=0, Callback=function(v) getgenv().Misc.FlySpeed=v end})

    MoveBox:AddToggle('CFrameSpeedToggle', {
        Text = 'CFrame Speed', Default = false,
        Callback = function(state)
            getgenv().cframeSpeedEnabled = state
        end,
    }):AddKeyPicker('CFrameSpeedKeybind', {
        Default = 'T', Text = 'CFrame Speed', Mode = 'Toggle',
        SyncToggleState = true,
        Callback = function(state)
            getgenv().cframeSpeedEnabled = state
        end,
    })
    MoveBox:AddToggle('WalkSpeedToggle', {
        Text = 'WalkSpeed', Default = false,
        Callback = function(state) getgenv().walkSpeedEnabled = state end,
    }):AddKeyPicker('WalkSpeedKeybind', {
        Default = 'T', Text = 'WalkSpeed', Mode = 'Toggle',
        SyncToggleState = true,
        Callback = function(state)
            getgenv().walkSpeedEnabled = state
        end,
    })
    MoveBox:AddToggle('JumpPowerToggle', {
        Text = 'JumpPower', Default = false,
        Callback = function(state) getgenv().jumpPowerEnabled = state end,
    }):AddKeyPicker('JumpPowerKeybind', {
        Default = 'None', Text = 'JumpPower', Mode = 'Toggle',
        SyncToggleState = true,
        Callback = function(state)
            getgenv().jumpPowerEnabled = state
        end,
    })

    MoveBox:AddSlider('WalkSpeedSlider', {
        Text = 'WalkSpeed Value', Default = 16, Min = 16, Max = 500, Rounding = 0,
        Callback = function(v) getgenv().walkSpeed = v end,
    })
    MoveBox:AddSlider('JumpPowerSlider', {
        Text = 'JumpPower Value', Default = 50, Min = 50, Max = 500, Rounding = 0,
        Callback = function(v) getgenv().jumpPower = v end,
    })
    MoveBox:AddSlider('CFrameSpeedSlider', {
        Text = 'CFrame Speed Value', Default = 10, Min = 0, Max = 200, Rounding = 1,
        Callback = function(v) getgenv().cframeSpeed = v end,
    })

    MoveBox:AddToggle('SpinbotToggle', {
        Text = 'Spinbot', Default = false,
        Callback = function(v) getgenv().Misc.SpinEnabled = v if v then getgenv().StartSpin() end end
    })
    MoveBox:AddSlider('SpinSpeed', {Text='Spin Speed', Default=20, Min=1, Max=100, Rounding=1, Callback=function(v) getgenv().Misc.SpinSpeed=v end})

    MoveBox:AddSlider('GravitySlider', {
        Text = 'Gravity', Default = 196.2, Min = 0, Max = 500, Rounding = 1,
        Callback = function(v)
            getgenv().customGravity = v
        end
    })

    MoveBox:AddToggle('NoClipToggle', {
        Text = 'NoClip', Default = false,
        Callback = function(v) getgenv().NoClipEnabled = v end
    }):AddKeyPicker('NoClipKey', {
        Default = 'None', Mode = 'Toggle', Text = 'NoClip Key',
        SyncToggleState = true,
        Callback = function(state)
            getgenv().NoClipEnabled = state
        end
    })
end

applyAutoBox()

local SkinChangerGb = getgenv().Tabs.Misc:AddRightGroupbox('Skin Changer')

local MiscLeft = TabCharacter

getgenv().MainGb:AddToggle('ForceHitEnabled', {
    Text = 'Forcehit',
    Default = false
}):AddKeyPicker('ForceHitKey', {
    Default = 'C',
    Mode = 'Toggle',
    Text = 'Forcehit',
    SyncToggleState = true,
    NoUI = false
})
getgenv().MainGb:AddToggle('FireOnClick', {
    Text = 'Shoot only while clicking',
    Default = true,
    Tooltip = 'Force hit only fires while holding left click'
})
getgenv().MainGb:AddSlider('FireRate', { Text = 'Force hit fire rate', Default = 1, Min = 0.5, Max = 5, Rounding = 1, Tooltip = '1 = normal (per weapon), higher = faster' })

getgenv().MainGb:AddDropdown('TargetPlayer', { SpecialType = 'Player', Text = 'Target Players', Tooltip = 'Lock a specific player' })
getgenv().MainGb:AddDropdown('HitPart', { Text = 'body part', Default = 1, Values = { 'Head', 'UpperTorso', 'HumanoidRootPart', 'LowerTorso' } })
getgenv().MainGb:AddToggle('AutoClosest', { Text = 'Auto Closest Target', Default = false })
getgenv().MainGb:AddToggle('LookAtTarget', { Text = 'Look at Target', Default = false })
getgenv().MainGb:AddToggle('ShowTracer', {
    Text = 'Tracer',
    Default = false
}):AddColorPicker('TracerColor', {
    Default = Color3.fromRGB(255, 255, 255),
    Title = 'Line Color'
})

do
    local VirtualInputManager = game:GetService("VirtualInputManager")
    local RELOAD_TOOLS = {
        "[Revolver]", "[DoubleBarrel]", "[TacticalShotgun]",
        "[SMG]", "[Shotgun]", "[Silencer]",
    }
    local lastReload = {}

    getgenv().AutoReloadConnection = getgenv().RunService.RenderStepped:Connect(function()
        if not (Toggles.AutoReloadEnabled and Toggles.AutoReloadEnabled.Value) then return end
        local char = getgenv().LocalPlayer.Character
        if not char then return end
        local cd = (Options.AutoReloadCooldown and Options.AutoReloadCooldown.Value) or 1
        for _, name in ipairs(RELOAD_TOOLS) do
            local t = char:FindFirstChild(name)
            if t and (not lastReload[name] or tick() - lastReload[name] >= cd) then
                local s = t:FindFirstChild("Script")
                local a = s and s:FindFirstChild("Ammo")
                if a and a:IsA("IntValue") and a.Value == 0 then
                    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.R, false, nil)
                    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.R, false, nil)
                    lastReload[name] = tick()
                end
            end
        end
    end)
end

getgenv().ChecksGb:AddToggle('WallCheck', { Text = 'Wall Check', Default = true })
getgenv().ChecksGb:AddToggle('ForceFieldCheck', { Text = 'ForceField Check', Default = true })
getgenv().ChecksGb:AddToggle('KOCheck', { Text = 'Death / KO Check', Default = true })
getgenv().ChecksGb:AddToggle('EnablePrefire', { Text = 'Prefire ForceField', Default = false })
getgenv().ChecksGb:AddToggle('AutoCalcPrefire', { Text = 'Auto Calculate Prefire', Default = false })
getgenv().ChecksGb:AddSlider('PrefireTime', { Text = 'Prefire Time (s)', Default = 0.1, Min = 0.0, Max = 1.0, Rounding = 2 })
getgenv().ChecksGb:AddSlider('MaxDistance', { Text = 'Max Distance', Default = 250, Min = 10, Max = 1000, Rounding = 0 })

getgenv().MenuBox = getgenv().Tabs.Settings:AddLeftGroupbox('Utilities')
getgenv().MenuBox:AddButton('Unload UI', function() getgenv().Library:Unload() end)
getgenv().MenuBox:AddButton('join new server', function() getgenv().TeleportService:Teleport(game.PlaceId, getgenv().LocalPlayer) end)
getgenv().MenuBox:AddButton('Rejoin Server', function() getgenv().TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, getgenv().LocalPlayer) end)
getgenv().MenuBox:AddLabel('Menu bind'):AddKeyPicker('MenuKeybind', {Default='End', NoUI=true, Text='Menu keybind'})

Options.ForceHitKey:OnClick(function()
    if not Toggles.ForceHitEnabled.Value then
        if getgenv().ForceHitTarget then
            getgenv().ForceHitTarget = nil
            getgenv().ForceHitTarget2 = nil
            getgenv().SetupDamageDetection(nil)
            getgenv().TracerLine.Visible = false; getgenv().TracerOutline.Visible = false
            getgenv().TracerLine2.Visible = false; getgenv().TracerOutline2.Visible = false
        end
        return
    end

    if getgenv().ForceHitTarget then
        getgenv().ForceHitTarget = nil
        getgenv().ForceHitTarget2 = nil
        getgenv().SetupDamageDetection(nil)
        getgenv().TracerLine.Visible = false; getgenv().TracerOutline.Visible = false
        getgenv().TracerLine2.Visible = false; getgenv().TracerOutline2.Visible = false
        if getgenv().Library.Notify then getgenv().Library:Notify("Target Unlocked", 1.5) end
    else
        getgenv().ForceHitTarget = getgenv().GetClosestToMouse()
        if getgenv().ForceHitTarget then
            getgenv().SetupDamageDetection(getgenv().ForceHitTarget)
            if getgenv().Library.Notify then getgenv().Library:Notify("Target Locked: " .. tostring(getgenv().ForceHitTarget.Name), 1.5) end
        end
    end
end)

if Options.TargetPlayer then
    Options.TargetPlayer:OnChanged(function()
        local name = Options.TargetPlayer.Value
        local plr = name and name ~= '' and getgenv().Players:FindFirstChild(name)
        if plr and plr ~= getgenv().LocalPlayer then
            getgenv().ForceHitTarget = plr
            getgenv().SetupDamageDetection(plr)
            if getgenv().Library.Notify then getgenv().Library:Notify("Target Locked: " .. plr.Name, 1.5) end
        end
    end)
end

getgenv().LocalPlayer.CharacterAdded:Connect(function()
    if (Toggles.SpectateTarget and Toggles.SpectateTarget.Value) then task.wait(0.5); getgenv().startSpectate() end
end)

local lastClosestScan = 0
getgenv().ForceHitConnection = getgenv().RunService.RenderStepped:Connect(function()
    if not Toggles.ForceHitEnabled.Value then
        getgenv().TracerLine.Visible = false; getgenv().TracerOutline.Visible = false
        getgenv().TracerLine2.Visible = false; getgenv().TracerOutline2.Visible = false
        return
    end

    local clicking = getgenv().UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1)
    local clickGate = (Toggles.FireOnClick and Toggles.FireOnClick.Value) and not clicking

    if Toggles.AutoClosest and Toggles.AutoClosest.Value then
        local now = tick()
        if now - lastClosestScan >= 0.15 then
            lastClosestScan = now
            local closest = getgenv().GetClosestToMouse()
            if closest ~= getgenv().ForceHitTarget then
                getgenv().ForceHitTarget = closest
                getgenv().SetupDamageDetection(closest)
            end
        end
    end

    local targets = {getgenv().ForceHitTarget, getgenv().ForceHitTarget2}

    for i, target in ipairs(targets) do
        local line = i == 1 and getgenv().TracerLine or getgenv().TracerLine2
        local outline = i == 1 and getgenv().TracerOutline or getgenv().TracerOutline2

        if target then
            local isTargetFullyDead = getgenv().isFullyDead(target)
            local isTargetKO = getgenv().isKO(target)

            local canShoot = not (Toggles.KOCheck.Value and (isTargetFullyDead or (isTargetKO and not Toggles.StompTarget.Value)))

            if canShoot then
                if not clickGate then getgenv().Shoot(target) end

                if Toggles.ShowTracer.Value then
                    local targetPart = target.Character and target.Character:FindFirstChild(Options.HitPart.Value)
                    if targetPart then
                        local screenPos, onScreen = getgenv().Camera:WorldToViewportPoint(targetPart.Position)
                        if onScreen then
                            local viewport = getgenv().Camera.ViewportSize
                            local originMode = Options.TracerOrigin and Options.TracerOrigin.Value or 'Mouse'
                            local startPos
                            if originMode == 'Mouse' then startPos = getgenv().UserInputService:GetMouseLocation()
                            elseif originMode == 'Center' then startPos = Vector2.new(viewport.X / 2, viewport.Y / 2)
                            elseif originMode == 'Bottom' then startPos = Vector2.new(viewport.X / 2, viewport.Y) end

                            local endPos = Vector2.new(screenPos.X, screenPos.Y)
                            outline.From = startPos; outline.To = endPos; outline.Visible = true
                            line.From = startPos; line.To = endPos; line.Color = Options.TracerColor.Value; line.Visible = true
                        else
                            line.Visible = false; outline.Visible = false
                        end
                    else line.Visible = false; outline.Visible = false end
                else line.Visible = false; outline.Visible = false end
            else
                line.Visible = false; outline.Visible = false
            end
        else
            line.Visible = false; outline.Visible = false
        end
    end
end)

task.spawn(function()
    while task.wait(0.1) do
        if getgenv().LizardGen ~= lizardGen then break end
        if not (Toggles.StompTarget.Value and getgenv().ForceHitTarget and getgenv().ForceHitTarget ~= getgenv().LocalPlayer) then continue end
        local targetChar = getgenv().ForceHitTarget.Character
        if not targetChar then continue end

        local body = targetChar:FindFirstChild("BodyEffects")
        local ko = body and body:FindFirstChild("K.O") and body["K.O"].Value
        local sdeath = body and body:FindFirstChild("SDeath") and body["SDeath"].Value

        if ko and not sdeath then
            getgenv().isCurrentlyStomping = true

            local torso = targetChar:FindFirstChild("UpperTorso") or targetChar:FindFirstChild("Torso")
            local hrp = getgenv().LocalPlayer.Character and getgenv().LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if torso and hrp then
                local real = hrp.CFrame
                local wasStrafing = Toggles.spoofstrafe.Value

                if getgenv().StrafeConnection then stopStrafe() end

                if wasStrafing then
                    getgenv().DesyncPart.CFrame = real + Vector3.new(0, 5, 0)
                    if not (Toggles.SpectateTarget and Toggles.SpectateTarget.Value) then getgenv().Camera.CameraSubject = getgenv().DesyncPart end
                end

                while getgenv().ForceHitTarget and getgenv().ForceHitTarget.Character == targetChar and targetChar.Parent do
                    local curBody = targetChar:FindFirstChild("BodyEffects")
                    if not curBody then break end
                    local curKO = curBody:FindFirstChild("K.O") and curBody["K.O"].Value
                    local curSDeath = curBody:FindFirstChild("SDeath") and curBody["SDeath"].Value

                    if not curKO or curSDeath then break end

                    local curTorso = targetChar:FindFirstChild("UpperTorso") or targetChar:FindFirstChild("Torso")
                    if curTorso then hrp.CFrame = CFrame.new(curTorso.Position + Vector3.new(0, 3, 0)) end

                    getgenv().MainEvent:FireServer("Stomp")
                    task.wait(0.1)
                end

                hrp.CFrame = real
                if not (Toggles.SpectateTarget and Toggles.SpectateTarget.Value) then getgenv().resetStrafeCamera() end
            end
            getgenv().isCurrentlyStomping = false
        end
    end
end)

getgenv().MainHeartbeatConnection = getgenv().RunService.Heartbeat:Connect(function()
    if getgenv().customGravity ~= nil then workspace.Gravity = getgenv().customGravity end

    local char = getgenv().LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hum or not hrp then return end

    if getgenv().jumpPowerEnabled then
        hum.UseJumpPower = true
        hum.JumpPower = getgenv().jumpPower or 50
    end

    if getgenv().walkSpeedEnabled then
        hum.WalkSpeed = getgenv().walkSpeed or 16
    end

    if getgenv().cframeSpeedEnabled then
        local moveDir = hum.MoveDirection
        if moveDir.Magnitude > 0 then
            local speed = getgenv().cframeSpeed or 0
            hrp.CFrame = hrp.CFrame + (moveDir * (speed / 10))
        end
    end

    if getgenv().NoClipEnabled then
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") and part.CanCollide then
                part.CanCollide = false
            end
        end
    end

    if Toggles.LookAtTarget and Toggles.LookAtTarget.Value and not getgenv().isCurrentlyStomping then
        if getgenv().ForceHitTarget and getgenv().ForceHitTarget.Character then
            local targetPart = getgenv().ForceHitTarget.Character:FindFirstChild(Options.HitPart.Value) or getgenv().ForceHitTarget.Character:FindFirstChild("HumanoidRootPart")
            if targetPart then
                local lookDir = (targetPart.Position - hrp.Position)
                local flatDir = Vector3.new(lookDir.X, 0, lookDir.Z).Unit
                if flatDir.Magnitude > 0 and flatDir == flatDir then
                    hrp.CFrame = CFrame.new(hrp.Position, hrp.Position + flatDir)
                end

                local head = char:FindFirstChild("Head")
                local neck = (char:FindFirstChild("UpperTorso") and char.UpperTorso:FindFirstChild("Neck")) or (char:FindFirstChild("Torso") and char.Torso:FindFirstChild("Neck"))
                if head and neck then
                    local dir = (targetPart.Position - head.Position).Unit
                    if dir == dir then
                        neck.C0 = CFrame.new(neck.C0.Position) * CFrame.Angles(math.asin(math.clamp(dir.Y, -1, 1)) * -1, math.atan2(-dir.X, -dir.Z), 0)
                    end
                end
            end
        end
    end
end)

getgenv().Misc = getgenv().Misc or {
    AutoReload = true,
    AutoReloadCooldown = 1,
    SpinEnabled = false,
    SpinSpeed = 20,
    SpinConnection = nil,
    FlightEnabled = false,
    Flying = false,
    FlySpeed = 50,
}
getgenv().StartSpin = function()
    if getgenv().Misc.SpinConnection then
        getgenv().Misc.SpinConnection:Disconnect()
        getgenv().Misc.SpinConnection = nil
    end
    getgenv().Misc.SpinConnection = getgenv().RunService.RenderStepped:Connect(function()
        if not getgenv().Misc.SpinEnabled then
            getgenv().Misc.SpinConnection:Disconnect()
            getgenv().Misc.SpinConnection = nil
            return
        end
        local char = getgenv().LocalPlayer.Character
        if not char then return end
        local root = char:FindFirstChild("HumanoidRootPart")
        if not root then return end
        root.CFrame = root.CFrame * CFrame.Angles(0, math.rad(getgenv().Misc.SpinSpeed), 0)
    end)
end

getgenv().MorphSettings = getgenv().MorphSettings or {
    CopyAppearance = true,
    HasHeadless = false,
    HasKorblox = false,
    HasChams = false,
    ChamsColor = Color3.new(1, 1, 1),
    SelectedUserName = "None",
    SelectedUserId = nil,
    DanceEnabled = false,
    CurrentDanceName = "None",
    CurrentDanceId = "",
    LagAnimations = false,
    LagIntensity = 1,
}

local settings = getgenv().MorphSettings

local users = {
    {UserId = 4912090997, UserName = "amir"},
    {UserId = 444115704, UserName = "DingleDorf"},
    {UserId = 7535880104, UserName = "fed"},
}

local danceAnimations = {
    ["None"] = "",
    ["headless"] = "rbxassetid://4",
    ["Floss"] = "rbxassetid://10714340543",
    ["Yungblud Happier Jump"] = "rbxassetid://15609995579",
    ["Monkey"] = "rbxassetid://3333499508",
    ["Fancy Feet"] = "rbxassetid://3333432454",
    ["Sleep"] = "rbxassetid://4686925579",
    ["Cower"] = "rbxassetid://4940563117",
    ["Bored"] = "rbxassetid://5230599789"
}

local danceNames = {}
for name in pairs(danceAnimations) do table.insert(danceNames, name) end

local skinColorParts = {
    Head = true,
    LeftFoot = true,
    LeftHand = true,
    LeftLowerArm = true,
    LeftUpperArm = true,
    RightFoot = true,
    RightHand = true,
    RightLowerArm = true,
    RightUpperArm = true,
}

local function validCharacter(c)
    local h = c and c:FindFirstChildOfClass("Humanoid")
    return h and h.Health > 0 and c:FindFirstChild("HumanoidRootPart")
end

local function ApplyHeadless(char)
    local head = char:FindFirstChild("Head")
    if head then
        head.Transparency = 1
        local face = head:FindFirstChild("face")
        if face then face.Transparency = 1 end
    end
end

local function RemoveHeadless(char)
    local head = char:FindFirstChild("Head")
    if head then
        head.Transparency = 0
        local face = head:FindFirstChild("face")
        if face then face.Transparency = 0 end
    end
end

local function ApplyKorblox(char)
    local rLowerLeg = char:FindFirstChild("RightLowerLeg")
    local rUpperLeg = char:FindFirstChild("RightUpperLeg")
    local rFoot = char:FindFirstChild("RightFoot")
    if rLowerLeg then rLowerLeg.MeshId = "902942093" rLowerLeg.Transparency = 1 end
    if rUpperLeg then rUpperLeg.MeshId = "http://www.roblox.com/asset/?id=902942096" rUpperLeg.TextureID = "http://roblox.com/asset/?id=902843398" end
    if rFoot then rFoot.MeshId = "902942089" rFoot.Transparency = 1 end
end

local function RemoveKorblox(char)
    local rLowerLeg = char:FindFirstChild("RightLowerLeg")
    local rUpperLeg = char:FindFirstChild("RightUpperLeg")
    local rFoot = char:FindFirstChild("RightFoot")
    if rLowerLeg then rLowerLeg.Transparency = 0 rLowerLeg.MeshId = "" end
    if rFoot then rFoot.Transparency = 0 rFoot.MeshId = "" end
    if rUpperLeg then rUpperLeg.TextureID = "" rUpperLeg.MeshId = "" end
    local success, appearance = pcall(function()
        return Players:GetCharacterAppearanceAsync(LocalPlayer.UserId)
    end)
    if not success or not appearance then return end
    for _, v in pairs(char:GetChildren()) do
        if v:IsA("Shirt") or v:IsA("Pants") or v:IsA("BodyColors") then v:Destroy() end
    end
    for _, v in pairs(appearance:GetChildren()) do
        if v:IsA("Shirt") or v:IsA("Pants") or v:IsA("BodyColors") then
            v.Parent = char
        end
    end
end

local savedBodyColors = {}

local function ApplyChams(char)
    local color = settings.ChamsColor or Color3.new(1, 1, 1)
    local partNames = {
        "Head", "LeftFoot", "LeftHand", "LeftLowerArm", "LeftLowerLeg",
        "LeftUpperArm", "LeftUpperLeg", "LowerTorso", "RightFoot",
        "RightHand", "RightLowerArm", "RightLowerLeg",
        "RightUpperArm", "RightUpperLeg", "UpperTorso"
    }
    savedBodyColors = {}
    for _, name in ipairs(partNames) do
        local part = char:FindFirstChild(name)
        if part and part:IsA("BasePart") then
            savedBodyColors[name] = part.Color
            part.Material = Enum.Material.ForceField
            part.Color = color
        end
    end
end

local function RemoveChams(char)
    local partNames = {
        "Head", "LeftFoot", "LeftHand", "LeftLowerArm", "LeftLowerLeg",
        "LeftUpperArm", "LeftUpperLeg", "LowerTorso", "RightFoot",
        "RightHand", "RightLowerArm", "RightLowerLeg",
        "RightUpperArm", "RightUpperLeg", "UpperTorso"
    }
    for _, name in ipairs(partNames) do
        local part = char:FindFirstChild(name)
        if part and part:IsA("BasePart") then
            part.Material = Enum.Material.Plastic
            if savedBodyColors[name] then
                part.Color = savedBodyColors[name]
            end
        end
    end
    savedBodyColors = {}
end

local function Morph(UserId, PlayerName)
    local player = Players:FindFirstChild(PlayerName)
    if not player or not player.Character then return end
    local success, appearance = pcall(function() return Players:GetCharacterAppearanceAsync(UserId) end)
    if not success then return end
    local char = player.Character
    for _, v in pairs(char:GetChildren()) do
        if v:IsA("Accessory") or v:IsA("Shirt") or v:IsA("Pants") or v:IsA("CharacterMesh") or v:IsA("BodyColors") then v:Destroy() end
    end
    if char:FindFirstChild("Head") and char.Head:FindFirstChild("face") then char.Head.face:Destroy() end
    for _, v in pairs(appearance:GetChildren()) do
        if v:IsA("Shirt") or v:IsA("Pants") or v:IsA("BodyColors") then v.Parent = char
        elseif v:IsA("Accessory") then char.Humanoid:AddAccessory(v)
        elseif v.Name == "R15" and char.Humanoid.RigType == Enum.HumanoidRigType.R15 then
            local mesh = v:FindFirstChildOfClass("CharacterMesh")
            if mesh then mesh.Parent = char end
        end
    end
    if appearance:FindFirstChild("face") then
        appearance.face.Parent = char.Head
    else
        local face = Instance.new("Decal")
        face.Face = Enum.NormalId.Front
        face.Name = "face"
        face.Texture = "rbxasset://textures/face.png"
        face.Parent = char.Head
    end
    local parent = char.Parent
    char.Parent = nil
    char.Parent = parent
    if settings.HasHeadless then ApplyHeadless(char) end
    if settings.HasKorblox then ApplyKorblox(char) end
    if settings.HasChams then ApplyChams(char) end
end

LocalPlayer.CharacterAdded:Connect(function(char)
    task.wait(1)
    if settings.SelectedUserId then
        Morph(settings.SelectedUserId, LocalPlayer.Name)
    elseif settings.SelectedUserName and settings.SelectedUserName ~= "None" then
        for _, user in pairs(users) do
            if user.UserName == settings.SelectedUserName then Morph(user.UserId, LocalPlayer.Name) break end
        end
    else
        if settings.HasHeadless then ApplyHeadless(char) end
        if settings.HasKorblox then ApplyKorblox(char) end
        if settings.HasChams then ApplyChams(char) end
    end
end)

do
    local Avatar = TabCharacter
    local DickESP = getgenv().DickESPState or {}
    getgenv().DickESPState = DickESP

    local AttachedModels = getgenv().DickESPAttachedModels or {}
    getgenv().DickESPAttachedModels = AttachedModels

    local DickESPConnections = getgenv().DickESPConnections or {}
    getgenv().DickESPConnections = DickESPConnections

    local function attachPartsWithHighlight(character, player)
        if not character then return end
        local pelvis = character:FindFirstChild("LowerTorso") or character:FindFirstChild("Torso")
        if not pelvis then return end

        if getgenv().CleanupAttachedDickESPModel then
            getgenv().CleanupAttachedDickESPModel(player)
        end

        local attachedModel = Instance.new("Model")
        attachedModel.Name = "AttachedParts_" .. player.Name
        attachedModel.Parent = workspace
        attachedModel.PrimaryPart = pelvis
        AttachedModels[player] = attachedModel

        local parts = {}

        local ball1 = Instance.new("Part")
        ball1.Shape = Enum.PartType.Ball
        ball1.Size = Vector3.new(0.5, 0.5, 0.5)
        ball1.Color = Color3.fromRGB(255, 255, 255)
        ball1.Material = Enum.Material.Neon
        ball1.CanCollide = false
        ball1.Anchored = false
        ball1.CFrame = pelvis.CFrame * CFrame.new(0.2, -0.6, -0.7)
        ball1.Parent = attachedModel
        table.insert(parts, ball1)

        local stick = Instance.new("Part")
        stick.Size = Vector3.new(0.3, 0.3, 6.8)
        stick.Color = Color3.fromRGB(255, 255, 255)
        stick.Material = Enum.Material.Neon
        stick.CanCollide = false
        stick.Anchored = false
        stick.CFrame = pelvis.CFrame * CFrame.new(0.07, -0.6, -3.9)
        stick.Parent = attachedModel
        table.insert(parts, stick)

        local ball2 = Instance.new("Part")
        ball2.Shape = Enum.PartType.Ball
        ball2.Size = Vector3.new(0.5, 4.5, 0.5)
        ball2.Color = Color3.fromRGB(255, 255, 255)
        ball2.Material = Enum.Material.Neon
        ball2.CanCollide = false
        ball2.Anchored = false
        ball2.CFrame = pelvis.CFrame * CFrame.new(-0.1, -0.6, -0.7)
        ball2.Parent = attachedModel
        table.insert(parts, ball2)

        for _, part in pairs(parts) do
            local weld = Instance.new("WeldConstraint")
            weld.Part0 = pelvis
            weld.Part1 = part
            weld.Parent = part
        end

        local highlight = Instance.new("Highlight")
        highlight.Parent = attachedModel
        highlight.Adornee = attachedModel
        highlight.FillColor = Color3.fromRGB(0, 0, 0)
        highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
        highlight.FillTransparency = 1
        highlight.OutlineTransparency = 0
    end

    getgenv().CleanupAttachedDickESPModel = function(player)
        local model = AttachedModels[player]
        if model then
            model:Destroy()
            AttachedModels[player] = nil
        end
    end

    getgenv().DisconnectDickESPConnection = function(key)
        local conn = DickESPConnections[key]
        if conn then
            conn:Disconnect()
            DickESPConnections[key] = nil
        end
    end

    getgenv().ShouldAttachDickESP = function(player)
        return (player == LocalPlayer and DickESP.SelfEnabled) or (player ~= LocalPlayer and DickESP.OthersEnabled)
    end

    getgenv().WatchDickESPPlayer = function(player)
        getgenv().DisconnectDickESPConnection(player)
        DickESPConnections[player] = player.CharacterAdded:Connect(function(character)
            getgenv().CleanupAttachedDickESPModel(player)
            if getgenv().ShouldAttachDickESP(player) then
                attachPartsWithHighlight(character, player)
            end
        end)

        if player.Character and getgenv().ShouldAttachDickESP(player) then
            attachPartsWithHighlight(player.Character, player)
        end
    end

    getgenv().DickESPCleanup = function()
        for player in pairs(AttachedModels) do
            getgenv().CleanupAttachedDickESPModel(player)
        end
        for key, conn in pairs(DickESPConnections) do
            if typeof(conn) == "RBXScriptConnection" then
                conn:Disconnect()
            end
            DickESPConnections[key] = nil
        end
    end

    for _, player in ipairs(game:GetService("Players"):GetPlayers()) do
        getgenv().WatchDickESPPlayer(player)
    end

    DickESPConnections.__playerAdded = game:GetService("Players").PlayerAdded:Connect(function(player)
        getgenv().WatchDickESPPlayer(player)
    end)

    DickESPConnections.__playerRemoving = game:GetService("Players").PlayerRemoving:Connect(function(player)
        getgenv().CleanupAttachedDickESPModel(player)
        getgenv().DisconnectDickESPConnection(player)
    end)

        getgenv().ESPGb = getgenv().Tabs.Visuals:AddLeftGroupbox('ESP')
        getgenv().ParticleAuraGb = getgenv().Tabs.Visuals:AddLeftGroupbox('Particle Aura')
        getgenv().GunMaterialGb = getgenv().Tabs.Visuals:AddLeftGroupbox('Gun Material')
        getgenv().WorldGb = getgenv().Tabs.Visuals:AddRightGroupbox('World')

        local RightTabVisual = getgenv().ParticleAuraGb

        local HitEffectsGb = getgenv().HitVisualsGb
        HitEffectsGb:AddToggle('TargetHUDEnabled', {
            Text = 'Target HUD', Default = false
        }):AddColorPicker('TargetHUDColor', { Default = Color3.fromRGB(97, 121, 191), Title = 'Target HUD Color' })
        HitEffectsGb:AddToggle('AmmoHUDEnabled', { Text = 'Ammo HUD', Default = false })
        HitEffectsGb:AddDropdown('AmmoHUDPosition', { Text = 'Ammo HUD Position', Default = 'Normal', Values = { 'Normal', 'Top', 'Left', 'Right' } })

        HitEffectsGb:AddToggle('AutoReloadEnabled', { Text = 'Auto Reload', Default = false })
        HitEffectsGb:AddSlider('AutoReloadCooldown', { Text = 'Reload Cooldown', Default = 1, Min = 0.1, Max = 5, Rounding = 1 })

        HitEffectsGb:AddToggle('BulletTracers', {
            Text = 'Bullets',
            Default = false
        }):AddColorPicker('BulletTracerColorOption', {
            Default = Color3.fromRGB(0, 255, 0),
            Title = 'Tracer Color'
        })
        HitEffectsGb:AddSlider('TracerDuration', { Text = 'Tracer lifetime', Default = 5.5, Min = 0.1, Max = 5.5, Rounding = 1 })
        HitEffectsGb:AddSlider('TracerWidth', { Text = 'Tracer Width', Default = 1, Min = 1, Max = 10, Rounding = 0 })
        HitEffectsGb:AddSlider('DBSpread', { Text = 'Double Barrel Spread', Default = 3.0, Min = 0.0, Max = 15.0, Rounding = 1 })

        HitEffectsGb:AddToggle('HitSoundEnabled', { Text = 'Hit Sound', Default = false })
        HitEffectsGb:AddDropdown('HitSoundChoice', { Text = 'Hit Sound', Default = 1, Values = getgenv().HitSoundList })
        HitEffectsGb:AddInput('CustomHitSound', { Default = '1347140027', Numeric = false, Finished = false, Text = 'Custom ID', Placeholder = 'Sound ID here' })

        HitEffectsGb:AddToggle('HitNotifEnabled', { Text = 'notify on hit', Default = false })
        HitEffectsGb:AddInput('NotifFormat', { Default = 'Hit (player) for (dmg%)', Finished = false, Text = 'Notification Format', Placeholder = 'Hit (player) for (dmg%)' })
        HitEffectsGb:AddLabel('(player) = target name')
        HitEffectsGb:AddLabel('(dmg%) = damage dealt')
        HitEffectsGb:AddDropdown('NotifPos', { Text = 'Notif Position', Default = 'Bottom Center', Values = { 'Top Left', 'Top Right', 'Center', 'Bottom Center' } })

        HitEffectsGb:AddToggle('DamageIndicators', {
            Text = 'Damage Indicators',
            Default = false
        }):AddColorPicker('IndicatorColor', {
            Default = Color3.fromRGB(0, 210, 255),
            Title = 'Text Color'
        }):AddColorPicker('IndicatorStrokeColor', {
            Default = Color3.fromRGB(0, 0, 0),
            Title = 'Outline Color'
        })

        do
            local playerGui = getgenv().LocalPlayer:WaitForChild("PlayerGui")
            local targetHudGui = Instance.new("ScreenGui")
            targetHudGui.Name = "target hud"
            targetHudGui.ResetOnSpawn = false
            targetHudGui.IgnoreGuiInset = true
            targetHudGui.Parent = playerGui
            getgenv().TargetHUDGui = targetHudGui

            local ammoHudGui = Instance.new("ScreenGui")
            ammoHudGui.Name = "AmmoHUD"
            ammoHudGui.ResetOnSpawn = false
            ammoHudGui.IgnoreGuiInset = true
            ammoHudGui.Parent = playerGui
            getgenv().AmmoHUDGui = ammoHudGui

            local tFrame = Instance.new("Frame")
            tFrame.Parent = targetHudGui
            tFrame.Name = "TargetHudFrame"
            tFrame.AnchorPoint = Vector2.new(0.5, 0.75)
            tFrame.Position = UDim2.new(0.5, 0, 0.75, 0)
            tFrame.Size = UDim2.new(0, 322, 0, 147)
            tFrame.BackgroundColor3 = Color3.fromRGB(11, 11, 11)
            tFrame.BorderSizePixel = 0
            tFrame.Visible = false

            local tFrame2 = Instance.new("Frame")
            tFrame2.Parent = tFrame
            tFrame2.Name = "Frame"
            tFrame2.Position = UDim2.new(0, 1, 0, 1)
            tFrame2.Size = UDim2.new(1, -2, 1, -2)
            tFrame2.BackgroundColor3 = Color3.fromRGB(97, 121, 191)
            tFrame2.BorderSizePixel = 0

            local tFrame3 = Instance.new("Frame")
            tFrame3.Parent = tFrame2
            tFrame3.Name = "Frame"
            tFrame3.Position = UDim2.new(0, 1, 0, 1)
            tFrame3.Size = UDim2.new(1, -2, 1, -2)
            tFrame3.BackgroundColor3 = Color3.fromRGB(31, 31, 31)
            tFrame3.BorderSizePixel = 0

            local tFrame4 = Instance.new("Frame")
            tFrame4.Parent = tFrame3
            tFrame4.Name = "Frame"
            tFrame4.Position = UDim2.new(0, 1, 0, 2)
            tFrame4.Size = UDim2.new(1, -2, 1, -4)
            tFrame4.BackgroundTransparency = 1
            tFrame4.BorderSizePixel = 0

            local tPad = Instance.new("UIPadding")
            tPad.Parent = tFrame4
            tPad.PaddingLeft = UDim.new(0, 6)

            local tHolder = Instance.new("Frame")
            tHolder.Parent = tFrame4
            tHolder.Name = "holder"
            tHolder.Position = UDim2.new(0, -3, 0, 16)
            tHolder.Size = UDim2.new(1, 0, 1, -18)
            tHolder.BackgroundColor3 = Color3.fromRGB(46, 46, 46)
            tHolder.BorderSizePixel = 0

            local tTop = Instance.new("Frame")
            tTop.Parent = tFrame4
            tTop.Name = "top"
            tTop.Size = UDim2.new(1, -4, 0, 20)
            tTop.BackgroundTransparency = 1
            tTop.BorderSizePixel = 0

            local indicatorLabel = Instance.new("TextLabel")
            indicatorLabel.Parent = tTop
            indicatorLabel.Name = "TextLabel"
            indicatorLabel.Size = UDim2.new(0.5, 0, 1, 0)
            indicatorLabel.BackgroundTransparency = 1
            indicatorLabel.BorderSizePixel = 0
            indicatorLabel.Text = "Indicator"
            indicatorLabel.TextColor3 = Color3.fromRGB(181, 181, 181)
            indicatorLabel.TextSize = 12
            indicatorLabel.TextXAlignment = Enum.TextXAlignment.Left
            indicatorLabel.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal)

            local indicatorPadding = Instance.new("UIPadding")
            indicatorPadding.Parent = indicatorLabel
            indicatorPadding.PaddingLeft = UDim.new(0, -2)
            indicatorPadding.PaddingTop = UDim.new(0, -4)
            indicatorPadding.PaddingBottom = UDim.new(0, 4)

            local indicatorStroke = Instance.new("UIStroke")
            indicatorStroke.Parent = indicatorLabel
            indicatorStroke.Color = Color3.fromRGB(0, 0, 0)
            indicatorStroke.Thickness = 1

            local holderFrame = Instance.new("Frame")
            holderFrame.Parent = tHolder
            holderFrame.Name = "Frame"
            holderFrame.Position = UDim2.new(0, 1, 0, 1)
            holderFrame.Size = UDim2.new(1, -2, 1, -2)
            holderFrame.BackgroundColor3 = Color3.fromRGB(11, 11, 11)
            holderFrame.BorderSizePixel = 0

            local holderFrame2 = Instance.new("Frame")
            holderFrame2.Parent = holderFrame
            holderFrame2.Name = "Frame"
            holderFrame2.Position = UDim2.new(0, 1, 0, 1)
            holderFrame2.Size = UDim2.new(1, -2, 1, -2)
            holderFrame2.BackgroundColor3 = Color3.fromRGB(21, 21, 21)
            holderFrame2.BorderSizePixel = 0

            local holderPadding = Instance.new("UIPadding")
            holderPadding.Parent = holderFrame2
            holderPadding.PaddingLeft = UDim.new(0, 4)
            holderPadding.PaddingTop = UDim.new(0, 4)

            local infoOuter = Instance.new("Frame")
            infoOuter.Parent = holderFrame2
            infoOuter.Name = "Frame"
            infoOuter.Size = UDim2.new(1, -4, 1, -4)
            infoOuter.BackgroundColor3 = Color3.fromRGB(11, 11, 11)
            infoOuter.BorderSizePixel = 0

            local infoOuter2 = Instance.new("Frame")
            infoOuter2.Parent = infoOuter
            infoOuter2.Name = "Frame"
            infoOuter2.Position = UDim2.new(0, 1, 0, 1)
            infoOuter2.Size = UDim2.new(1, -2, 1, -2)
            infoOuter2.BackgroundColor3 = Color3.fromRGB(46, 46, 46)
            infoOuter2.BorderSizePixel = 0

            local infoPanel = Instance.new("Frame")
            infoPanel.Parent = infoOuter2
            infoPanel.Name = "Frame"
            infoPanel.Position = UDim2.new(0, 1, 0, 1)
            infoPanel.Size = UDim2.new(1, -2, 1, -2)
            infoPanel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            infoPanel.BorderSizePixel = 0

            local infoPanelGradient = Instance.new("UIGradient")
            infoPanelGradient.Parent = infoPanel
            infoPanelGradient.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromRGB(30, 30, 30)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(21, 21, 21)),
            })

            local infoPanelPadding = Instance.new("UIPadding")
            infoPanelPadding.Parent = infoPanel
            infoPanelPadding.PaddingLeft = UDim.new(0, 4)
            infoPanelPadding.PaddingTop = UDim.new(0, 4)
            infoPanelPadding.PaddingRight = UDim.new(0, 3)
            infoPanelPadding.PaddingBottom = UDim.new(0, 3)

            local content = Instance.new("Frame")
            content.Parent = infoPanel
            content.Name = "Frame"
            content.Size = UDim2.new(1, 0, 1, 3)
            content.BackgroundTransparency = 1
            content.BorderSizePixel = 0

            local contentList = Instance.new("UIListLayout")
            contentList.Parent = content
            contentList.FillDirection = Enum.FillDirection.Vertical
            contentList.SortOrder = Enum.SortOrder.LayoutOrder
            contentList.Padding = UDim.new(0, 4)
            contentList.HorizontalAlignment = Enum.HorizontalAlignment.Left
            contentList.VerticalAlignment = Enum.VerticalAlignment.Top

            local contentPadding = Instance.new("UIPadding")
            contentPadding.Parent = content
            contentPadding.PaddingBottom = UDim.new(0, 4)

            local cardOuter = Instance.new("Frame")
            cardOuter.Parent = content
            cardOuter.Name = "Frame"
            cardOuter.Size = UDim2.new(1, -1, 1, 0)
            cardOuter.BackgroundColor3 = Color3.fromRGB(46, 46, 46)
            cardOuter.BorderSizePixel = 0

            local cardMid = Instance.new("Frame")
            cardMid.Parent = cardOuter
            cardMid.Name = "Frame"
            cardMid.Position = UDim2.new(0, 1, 0, 1)
            cardMid.Size = UDim2.new(1, -2, 1, -2)
            cardMid.BackgroundColor3 = Color3.fromRGB(11, 11, 11)
            cardMid.BorderSizePixel = 0

            local card = Instance.new("Frame")
            card.Parent = cardMid
            card.Name = "Frame"
            card.Position = UDim2.new(0, 1, 0, 1)
            card.Size = UDim2.new(1, -2, 1, -2)
            card.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            card.BorderSizePixel = 0

            local cardGradient = Instance.new("UIGradient")
            cardGradient.Parent = card
            cardGradient.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromRGB(30, 30, 30)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(21, 21, 21)),
            })

            local cardBar = Instance.new("Frame")
            cardBar.Parent = card
            cardBar.Name = "bar"
            cardBar.Size = UDim2.new(1, 0, 0, 2)
            cardBar.BackgroundColor3 = Color3.fromRGB(97, 121, 191)
            cardBar.BorderSizePixel = 0

            local cardBarGradient = Instance.new("UIGradient")
            cardBarGradient.Parent = cardBar
            cardBarGradient.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromRGB(97, 121, 191)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(76, 94, 149)),
            })

            local cardHolder = Instance.new("Frame")
            cardHolder.Parent = card
            cardHolder.Name = "holder"
            cardHolder.Position = UDim2.new(0, 1, 0, 22)
            cardHolder.Size = UDim2.new(1, -2, 1, -24)
            cardHolder.BackgroundTransparency = 1
            cardHolder.BorderSizePixel = 0

            local cardHolderPadding = Instance.new("UIPadding")
            cardHolderPadding.Parent = cardHolder
            cardHolderPadding.PaddingLeft = UDim.new(0, 3)
            cardHolderPadding.PaddingTop = UDim.new(0, -1)
            cardHolderPadding.PaddingRight = UDim.new(0, 3)
            cardHolderPadding.PaddingBottom = UDim.new(0, 2)

            local playerInfo = Instance.new("Frame")
            playerInfo.Parent = cardHolder
            playerInfo.Name = "playerinfo"
            playerInfo.Size = UDim2.new(1, 0, 1, 0)
            playerInfo.BackgroundTransparency = 1
            playerInfo.BorderSizePixel = 0

            local icon = Instance.new("Frame")
            icon.Parent = playerInfo
            icon.Name = "icon"
            icon.Size = UDim2.new(0, 68, 1, 0)
            icon.BackgroundColor3 = Color3.fromRGB(11, 11, 11)
            icon.BorderSizePixel = 0

            local iconFrame = Instance.new("Frame")
            iconFrame.Parent = icon
            iconFrame.Name = "Frame"
            iconFrame.Position = UDim2.new(0, 1, 0, 1)
            iconFrame.Size = UDim2.new(1, -2, 1, -2)
            iconFrame.BackgroundColor3 = Color3.fromRGB(46, 46, 46)
            iconFrame.BorderSizePixel = 0

            local iconFrame2 = Instance.new("Frame")
            iconFrame2.Parent = iconFrame
            iconFrame2.Name = "Frame"
            iconFrame2.Position = UDim2.new(0, 1, 0, 1)
            iconFrame2.Size = UDim2.new(1, -2, 1, -2)
            iconFrame2.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            iconFrame2.BorderSizePixel = 0

            local iconGradient = Instance.new("UIGradient")
            iconGradient.Parent = iconFrame2
            iconGradient.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromRGB(30, 30, 30)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(21, 21, 21)),
            })

            local iconImage = Instance.new("ImageLabel")
            iconImage.Parent = iconFrame2
            iconImage.Name = "ImageLabel"
            iconImage.Size = UDim2.new(1, 0, 1, 0)
            iconImage.BackgroundTransparency = 1
            iconImage.BorderSizePixel = 0
            iconImage.Image = "rbxassetid://119472238324544"
            iconImage.ImageColor3 = Color3.fromRGB(255, 255, 255)

            local health = Instance.new("Frame")
            health.Parent = playerInfo
            health.Name = "health"
            health.Position = UDim2.new(0, 72, 1, 0)
            health.AnchorPoint = Vector2.new(0, 1)
            health.Size = UDim2.new(1, -72, 0, 14)
            health.BackgroundColor3 = Color3.fromRGB(11, 11, 11)
            health.BorderSizePixel = 0

            local healthFrame = Instance.new("Frame")
            healthFrame.Parent = health
            healthFrame.Name = "Frame"
            healthFrame.Position = UDim2.new(0, 1, 0, 1)
            healthFrame.Size = UDim2.new(1, -2, 1, -2)
            healthFrame.BackgroundColor3 = Color3.fromRGB(46, 46, 46)
            healthFrame.BorderSizePixel = 0

            local healthFrame2 = Instance.new("Frame")
            healthFrame2.Parent = healthFrame
            healthFrame2.Name = "Frame"
            healthFrame2.Position = UDim2.new(0, 1, 0, 1)
            healthFrame2.Size = UDim2.new(1, -2, 1, -2)
            healthFrame2.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            healthFrame2.BorderSizePixel = 0

            local healthFrameGradient = Instance.new("UIGradient")
            healthFrameGradient.Parent = healthFrame2
            healthFrameGradient.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromRGB(30, 30, 30)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(21, 21, 21)),
            })

            local healthBarValue = Instance.new("Frame")
            healthBarValue.Parent = healthFrame2
            healthBarValue.Name = "healthbarvalue"
            healthBarValue.Size = UDim2.new(1, 0, 1, 0)
            healthBarValue.BackgroundColor3 = Color3.fromRGB(46, 196, 46)
            healthBarValue.BorderSizePixel = 0

            local healthBarGradient = Instance.new("UIGradient")
            healthBarGradient.Parent = healthBarValue
            healthBarGradient.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(125, 125, 125)),
            })

            local healthValue = Instance.new("TextLabel")
            healthValue.Parent = healthFrame2
            healthValue.Name = "healthvalue"
            healthValue.AnchorPoint = Vector2.new(0.5, 0.5)
            healthValue.Position = UDim2.new(0.5, 0, 0.5, 0)
            healthValue.Size = UDim2.new(1, 0, 1, 0)
            healthValue.BackgroundTransparency = 1
            healthValue.BorderSizePixel = 0
            healthValue.Text = "100/100"
            healthValue.TextColor3 = Color3.fromRGB(181, 181, 181)
            healthValue.TextSize = 12
            healthValue.TextXAlignment = Enum.TextXAlignment.Center
            healthValue.TextYAlignment = Enum.TextYAlignment.Center
            healthValue.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal)

            local healthStroke = Instance.new("UIStroke")
            healthStroke.Parent = healthValue
            healthStroke.Color = Color3.fromRGB(0, 0, 0)
            healthStroke.Thickness = 1

            local infoTextFrame = Instance.new("Frame")
            infoTextFrame.Parent = playerInfo
            infoTextFrame.Name = "Frame"
            infoTextFrame.Position = UDim2.new(0.27, 0, 0.029, 0)
            infoTextFrame.Size = UDim2.new(0, 198, 0, 31)
            infoTextFrame.BackgroundTransparency = 1
            infoTextFrame.BorderSizePixel = 0

            local infoList = Instance.new("UIListLayout")
            infoList.Parent = infoTextFrame
            infoList.FillDirection = Enum.FillDirection.Vertical
            infoList.SortOrder = Enum.SortOrder.LayoutOrder
            infoList.Padding = UDim.new(0, 2)
            infoList.HorizontalAlignment = Enum.HorizontalAlignment.Left
            infoList.VerticalAlignment = Enum.VerticalAlignment.Top

            local targetName = Instance.new("TextLabel")
            targetName.Parent = infoTextFrame
            targetName.Name = "name"
            targetName.Size = UDim2.new(0.391519994, 0, 0.419349998, 0)
            targetName.BackgroundTransparency = 1
            targetName.BorderSizePixel = 0
            targetName.Text = "exp (@example)"
            targetName.TextColor3 = Color3.fromRGB(181, 181, 181)
            targetName.TextSize = 12
            targetName.TextXAlignment = Enum.TextXAlignment.Left
            targetName.TextYAlignment = Enum.TextYAlignment.Top
            targetName.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal)

            local targetNameStroke = Instance.new("UIStroke")
            targetNameStroke.Parent = targetName
            targetNameStroke.Color = Color3.fromRGB(0, 0, 0)
            targetNameStroke.Thickness = 1

            local targetStuds = Instance.new("TextLabel")
            targetStuds.Parent = infoTextFrame
            targetStuds.Name = "studs"
            targetStuds.Size = UDim2.new(0.391519994, 0, 0.419349998, 0)
            targetStuds.BackgroundTransparency = 1
            targetStuds.BorderSizePixel = 0
            targetStuds.Text = "123 studs"
            targetStuds.TextColor3 = Color3.fromRGB(181, 181, 181)
            targetStuds.TextSize = 12
            targetStuds.TextXAlignment = Enum.TextXAlignment.Left
            targetStuds.TextYAlignment = Enum.TextYAlignment.Top
            targetStuds.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal)

            local targetStudsStroke = Instance.new("UIStroke")
            targetStudsStroke.Parent = targetStuds
            targetStudsStroke.Color = Color3.fromRGB(0, 0, 0)
            targetStudsStroke.Thickness = 1

            local infoTop = Instance.new("Frame")
            infoTop.Parent = card
            infoTop.Name = "top"
            infoTop.Position = UDim2.new(0, 0, 0, 2)
            infoTop.Size = UDim2.new(1, 0, 0, 20)
            infoTop.BackgroundTransparency = 1
            infoTop.BorderSizePixel = 0

            local infoLabel = Instance.new("TextLabel")
            infoLabel.Parent = infoTop
            infoLabel.Name = "TextLabel"
            infoLabel.Size = UDim2.new(1, 0, 1, 0)
            infoLabel.BackgroundTransparency = 1
            infoLabel.BorderSizePixel = 0
            infoLabel.Text = "Info"
            infoLabel.TextColor3 = Color3.fromRGB(137, 137, 137)
            infoLabel.TextSize = 12
            infoLabel.TextXAlignment = Enum.TextXAlignment.Left
            infoLabel.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal)

            local infoLabelPadding = Instance.new("UIPadding")
            infoLabelPadding.Parent = infoLabel
            infoLabelPadding.PaddingLeft = UDim.new(0, 5)

            local infoLabelStroke = Instance.new("UIStroke")
            infoLabelStroke.Parent = infoLabel
            infoLabelStroke.Color = Color3.fromRGB(0, 0, 0)
            infoLabelStroke.Thickness = 1

            local draggingTargetHud = false
            local targetHudDragStart
            local targetHudStartPos

            tFrame.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    draggingTargetHud = true
                    targetHudDragStart = input.Position
                    targetHudStartPos = tFrame.Position
                    input.Changed:Connect(function()
                        if input.UserInputState == Enum.UserInputState.End then
                            draggingTargetHud = false
                        end
                    end)
                end
            end)

            getgenv().UserInputService.InputChanged:Connect(function(input)
                if not draggingTargetHud then return end
                if input.UserInputType ~= Enum.UserInputType.MouseMovement and input.UserInputType ~= Enum.UserInputType.Touch then return end

                local delta = input.Position - targetHudDragStart
                tFrame.Position = UDim2.new(
                    targetHudStartPos.X.Scale,
                    targetHudStartPos.X.Offset + delta.X,
                    targetHudStartPos.Y.Scale,
                    targetHudStartPos.Y.Offset + delta.Y
                )
            end)

            local ammoFrame = Instance.new("Frame")
            ammoFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 34)
            ammoFrame.BackgroundTransparency = 0.05
            ammoFrame.BorderSizePixel = 0
            ammoFrame.Size = UDim2.new(0, 196, 0, 64)
            ammoFrame.Visible = false
            ammoFrame.Parent = ammoHudGui
            Instance.new("UICorner", ammoFrame).CornerRadius = UDim.new(0, 8)

            local ammoPad = Instance.new("UIPadding")
            ammoPad.PaddingLeft = UDim.new(0, 12)
            ammoPad.PaddingRight = UDim.new(0, 12)
            ammoPad.PaddingTop = UDim.new(0, 11)
            ammoPad.PaddingBottom = UDim.new(0, 12)
            ammoPad.Parent = ammoFrame

            local ammoStroke = Instance.new("UIStroke")
            ammoStroke.Color = Color3.fromRGB(70, 72, 82)
            ammoStroke.Thickness = 1
            ammoStroke.Transparency = 0.55
            ammoStroke.Parent = ammoFrame

            local ammoName = Instance.new("TextLabel")
            ammoName.BackgroundTransparency = 1
            ammoName.Size = UDim2.new(1, 0, 0, 14)
            ammoName.Position = UDim2.new(0, 0, 0, 0)
            ammoName.Font = Enum.Font.Gotham
            ammoName.TextSize = 13
            ammoName.TextXAlignment = Enum.TextXAlignment.Left
            ammoName.TextColor3 = Color3.fromRGB(150, 153, 165)
            ammoName.Text = ""
            ammoName.Parent = ammoFrame

            local ammoBarBg = Instance.new("Frame")
            ammoBarBg.BackgroundColor3 = Color3.fromRGB(38, 40, 48)
            ammoBarBg.BorderSizePixel = 0
            ammoBarBg.Size = UDim2.new(1, 0, 0, 20)
            ammoBarBg.Position = UDim2.new(0, 0, 1, -20)
            ammoBarBg.AnchorPoint = Vector2.new(0, 0)
            ammoBarBg.Parent = ammoFrame
            Instance.new("UICorner", ammoBarBg).CornerRadius = UDim.new(0, 5)

            local ammoBar = Instance.new("Frame")
            ammoBar.BackgroundColor3 = Color3.fromRGB(91, 124, 250)
            ammoBar.BorderSizePixel = 0
            ammoBar.Size = UDim2.new(1, 0, 1, 0)
            ammoBar.Parent = ammoBarBg
            Instance.new("UICorner", ammoBar).CornerRadius = UDim.new(0, 5)

            local ammoValue = Instance.new("TextLabel")
            ammoValue.BackgroundTransparency = 1
            ammoValue.Size = UDim2.new(1, 0, 1, 0)
            ammoValue.Position = UDim2.new(0, 0, 0, 0)
            ammoValue.Font = Enum.Font.GothamBold
            ammoValue.TextSize = 13
            ammoValue.TextXAlignment = Enum.TextXAlignment.Center
            ammoValue.TextYAlignment = Enum.TextYAlignment.Center
            ammoValue.TextColor3 = Color3.fromRGB(255, 255, 255)
            ammoValue.TextStrokeTransparency = 0.5
            ammoValue.Text = ""
            ammoValue.Parent = ammoBarBg

            local ammoLastValue = nil
            local ammoHideAt = 0
            local ammoDisplayFrac = 1
            local ammoPulseUntil = 0

            local function ammoPos(mode)
                if mode == "Top" then return UDim2.new(0.5, -95, 0, 80) end
                if mode == "Left" then return UDim2.new(0, 20, 0.5, -27) end
                if mode == "Right" then return UDim2.new(1, -210, 0.5, -27) end
                return UDim2.new(1, -20, 1, -140)
            end

            local function tvh(n) local t = Toggles[n] return t and t.Value end
            local function ovh(n) local o = Options[n] return o and o.Value end

            local hudThumbCache = {}
            local function hudThumb(userId)
                local now = tick()
                local entry = hudThumbCache[userId]
                if entry and entry.t > now - 2 then return entry.v end
                if not entry or not entry.loading then
                    local prev = entry and entry.v
                    hudThumbCache[userId] = { v = prev, t = now, loading = true }
                    task.spawn(function()
                        local ok, value = pcall(function()
                            return Players:GetUserThumbnailAsync(userId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
                        end)
                        hudThumbCache[userId] = { v = ok and value or prev, t = tick() }
                    end)
                end
                return entry and entry.v
            end

            local lastHudUpdate = 0
            getgenv().HUDConnection = getgenv().RunService.RenderStepped:Connect(function()
                local hudNow = tick()
                if hudNow - lastHudUpdate < 0.05 then return end
                lastHudUpdate = hudNow
                local target = getgenv().ForceHitTarget
                if tvh('TargetHUDEnabled') and target and target.Parent and target.Character then
                    local hum = target.Character:FindFirstChildOfClass("Humanoid")
                    local hrp = target.Character:FindFirstChild("HumanoidRootPart")
                    if hum and hrp then
                        local col = ovh('TargetHUDColor') or Color3.fromRGB(97, 121, 191)
                        local healthFrac = math.clamp(hum.Health / (hum.MaxHealth > 0 and hum.MaxHealth or 100), 0, 1)
                        local dist = math.floor((getgenv().Camera.CFrame.Position - hrp.Position).Magnitude + 0.5)
                        local thumb = hudThumb(target.UserId)
                        tFrame.Visible = true
                        targetName.Text = string.format("%s (@%s)", target.DisplayName or target.Name, target.Name)
                        targetStuds.Text = string.format("%d studs", dist)
                        iconImage.Image = thumb
                        tFrame2.BackgroundColor3 = col
                        cardBar.BackgroundColor3 = col
                        cardBarGradient.Color = ColorSequence.new({
                            ColorSequenceKeypoint.new(0, col),
                            ColorSequenceKeypoint.new(1, col:Lerp(Color3.fromRGB(20, 20, 20), 0.22)),
                        })
                        healthBarValue.Size = UDim2.new(healthFrac, 0, 1, 0)
                        healthBarValue.BackgroundColor3 = Color3.fromRGB(46, 196, 46)
                        healthValue.Text = string.format("%d/%d", math.floor(hum.Health + 0.5), math.floor((hum.MaxHealth > 0 and hum.MaxHealth or 100) + 0.5))
                    else
                        tFrame.Visible = false
                    end
                else
                    tFrame.Visible = false
                end

                if tvh('AmmoHUDEnabled') then
                    local char = getgenv().LocalPlayer.Character
                    local tool = char and char:FindFirstChildOfClass("Tool")
                    local s = tool and tool:FindFirstChild("Script")
                    local a = s and s:FindFirstChild("Ammo")
                    if a and a:IsA("IntValue") then
                        local maxAmmo = tool:FindFirstChild("MaxAmmo") or s:FindFirstChild("MaxAmmo")
                        local maxValue = (maxAmmo and maxAmmo:IsA("IntValue") and maxAmmo.Value > 0) and maxAmmo.Value or math.max(a.Value, 1)
                        local frac = math.clamp(a.Value / maxValue, 0, 1)

                        if ammoLastValue ~= nil and a.Value < ammoLastValue then
                            ammoPulseUntil = tick() + 0.18
                        end
                        ammoLastValue = a.Value
                        ammoHideAt = tick() + 2

                        local targetPos = ammoPos(ovh('AmmoHUDPosition') or 'Normal')
                        local hiddenPos = targetPos + UDim2.new(0, 18, 0, 0)
                        local timeLeft = ammoHideAt - tick()
                        local visible = timeLeft > 0
                        ammoFrame.Visible = visible

                        local fadeAlpha = 1
                        if timeLeft < 0.25 then
                            fadeAlpha = math.clamp(timeLeft / 0.25, 0, 1)
                        end
                        local posAlpha = 1 - (1 - fadeAlpha)
                        ammoFrame.Position = hiddenPos:Lerp(targetPos, posAlpha)

                        ammoDisplayFrac = ammoDisplayFrac + (frac - ammoDisplayFrac) * 0.25
                        ammoName.Text = tostring(tool.Name):gsub("^%[", ""):gsub("%]$", "")
                        ammoBar.Size = UDim2.new(ammoDisplayFrac, 0, 1, 0)
                        ammoValue.Text = string.format("%d/%d", a.Value, maxValue)

                        local pulseActive = tick() < ammoPulseUntil
                        ammoBar.BackgroundColor3 = pulseActive and Color3.fromRGB(124, 152, 255) or Color3.fromRGB(91, 124, 250)
                        ammoFrame.BackgroundTransparency = (pulseActive and 0.0 or 0.05) + ((1 - fadeAlpha) * 0.75)
                        ammoStroke.Transparency = (pulseActive and 0.4 or 0.55) + ((1 - fadeAlpha) * 0.45)
                        ammoName.TextTransparency = 1 - fadeAlpha
                        ammoValue.TextTransparency = 1 - fadeAlpha
                        ammoValue.TextStrokeTransparency = 0.5 + ((1 - fadeAlpha) * 0.5)
                        ammoBar.BackgroundTransparency = 1 - fadeAlpha
                        ammoBarBg.BackgroundTransparency = 0.15 + ((1 - fadeAlpha) * 0.7)
                        ammoValue.TextSize = pulseActive and 14 or 13
                    else
                        ammoLastValue = nil
                        ammoFrame.Visible = false
                    end
                else
                    ammoLastValue = nil
                    ammoFrame.Visible = false
                end
            end)
        end

        SkinChangerGb:AddToggle('SkinChangerEnabled', {
            Text = 'Weapon Skins',
            Default = false,
            Callback = function(val)
                if val then
                    getgenv().Lizard_ApplySkins()
                end
            end,
        })
        SkinChangerGb:AddDropdown('SkinDoubleBarrel', { Text = 'DoubleBarrel Skin', Values = GUN_SKINS, Default = 1, Callback = function() applyVisualGuns() end })
        SkinChangerGb:AddDropdown('SkinRevolver', { Text = 'Revolver Skin', Values = GUN_SKINS, Default = 1, Callback = function() applyVisualGuns() end })
        SkinChangerGb:AddDropdown('SkinTacticalShotgun', { Text = 'TacticalShotgun Skin', Values = GUN_SKINS, Default = 1, Callback = function() applyVisualGuns() end })
        SkinChangerGb:AddDropdown('SkinSMG', { Text = 'SMG Skin', Values = GUN_SKINS, Default = 1, Callback = function() applyVisualGuns() end })
        SkinChangerGb:AddDropdown('SkinShotgun', { Text = 'Shotgun Skin', Values = GUN_SKINS, Default = 1, Callback = function() applyVisualGuns() end })
        SkinChangerGb:AddDropdown('SkinKnife', { Text = 'Knife Skin', Values = KNIFE_SKINS, Default = 1, Callback = function() applyVisualGuns() end })
        SkinChangerGb:AddDivider()
        SkinChangerGb:AddToggle('BulletChangerEnabled', {
            Text = 'Bullet Changer',
            Default = false,
            Callback = function(val)
                if val then getgenv().Lizard_ApplyBullets() end
            end,
        })
        SkinChangerGb:AddDropdown('BulletTexture', {
            Text = 'Bullet Texture',
            Values = BULLET_SKINS,
            Default = 'Beta',
            Callback = function()
                if Toggles.BulletChangerEnabled and Toggles.BulletChangerEnabled.Value then
                    getgenv().Lizard_ApplyBullets()
                end
            end,
        })

        BodyPartsGb:AddToggle('Dickesp', {
            Text = 'Dick visuals  (Local Player)',
            Default = false,
            Callback = function(enabled)
                DickESP.SelfEnabled = enabled

                if not enabled then
                    getgenv().CleanupAttachedDickESPModel(LocalPlayer)
                    return
                end

                if LocalPlayer.Character then
                    attachPartsWithHighlight(LocalPlayer.Character, LocalPlayer)
                end
            end
        })

        BodyPartsGb:AddToggle('DickespOthers', {
            Text = 'Dick visuals (Other Players)',
            Default = false,
            Callback = function(enabled)
                DickESP.OthersEnabled = enabled

                if not enabled then
                    for player, model in pairs(AttachedModels) do
                        if player ~= LocalPlayer and model then
                            getgenv().CleanupAttachedDickESPModel(player)
                        end
                    end
                    return
                end

                for _, player in pairs(game:GetService("Players"):GetPlayers()) do
                    if player ~= LocalPlayer and player.Character then
                        attachPartsWithHighlight(player.Character, player)
                    end
                end
            end
        })

        RightTabVisual:AddToggle('SelfAuraEnabled', {
            Text = 'Particle Aura',
            Default = false,
            Callback = function(val)
                if val then
                    refreshSelfAura()
                else
                    clearSelfAura()
                end
            end,
        }):AddColorPicker('SelfAuraColor', {
            Default = Color3.fromRGB(133, 220, 255),
            Title = 'Aura Color',
            Callback = function()
                if Toggles.SelfAuraEnabled and Toggles.SelfAuraEnabled.Value then
                    refreshSelfAura()
                end
            end,
        })

        local selfAuraTypeValues = { 'None' }
        for _, n in ipairs(PARTICLE_AURA_NAMES) do
            table.insert(selfAuraTypeValues, n)
        end

        RightTabVisual:AddDropdown('SelfAuraType', {
            Values = selfAuraTypeValues,
            Default = 1,
            Text = 'Aura Type',
            Callback = function()
                if Toggles.SelfAuraEnabled and Toggles.SelfAuraEnabled.Value then
                    refreshSelfAura()
                end
            end,
        })

        do
            local GunMaterialGb = getgenv().GunMaterialGb
            local MATERIALS = {
                'Neon', 'ForceField', 'Glass', 'Plastic', 'SmoothPlastic',
                'Metal', 'DiamondPlate', 'Foil', 'Wood', 'WoodPlanks',
                'Marble', 'Slate', 'Concrete', 'Ice', 'Glacier', 'Granite',
            }

            GunMaterialGb:AddToggle('GunMaterialEnabled', {
                Text = 'Gun Material',
                Default = false,
            }):AddColorPicker('GunMaterialColor', {
                Default = Color3.fromRGB(255, 0, 0),
                Title = 'Gun Color',
            })

            GunMaterialGb:AddDropdown('GunMaterialType', {
                Text = 'Material Type',
                Values = MATERIALS,
                Default = 'Neon',
            })

            local function gunMatParts()
                local out = {}
                local char = getgenv().LocalPlayer.Character
                if char then
                    for _, t in ipairs(char:GetChildren()) do
                        if t:IsA('Tool') then table.insert(out, t) end
                    end
                end
                local bp = getgenv().LocalPlayer:FindFirstChild('Backpack')
                if bp then
                    for _, t in ipairs(bp:GetChildren()) do
                        if t:IsA('Tool') then table.insert(out, t) end
                    end
                end
                return out
            end

            task.spawn(function()
                while task.wait(0.3) do
                    if getgenv().LizardGen ~= lizardGen then break end
                    if not (Toggles.GunMaterialEnabled and Toggles.GunMaterialEnabled.Value) then continue end
                    local matName = (Options.GunMaterialType and Options.GunMaterialType.Value) or 'Neon'
                    local mat = Enum.Material[matName] or Enum.Material.Neon
                    local col = (Options.GunMaterialColor and Options.GunMaterialColor.Value) or Color3.fromRGB(255, 0, 0)
                    for _, tool in ipairs(gunMatParts()) do
                        for _, p in ipairs(tool:GetDescendants()) do
                            if p:IsA('BasePart') and p.Transparency < 1 then
                                pcall(function()
                                    p.Material = mat
                                    p.Color = col
                                end)
                            end
                        end
                    end
                end
            end)
        end

        do
            local WorldGb = getgenv().WorldGb
            local Lighting = game:GetService('Lighting')
            local Terrain = workspace:FindFirstChildOfClass('Terrain')

            local function tvw(n) local t = Toggles[n] return t and t.Value end
            local function ovw(n) local o = Options[n] return o and o.Value end

            WorldGb:AddToggle('WorldLightingMode', { Text = 'Lighting Mode', Default = false })
            WorldGb:AddDropdown('WorldLightingTech', {
                Text = 'Mode',
                Values = { 'Compatibility', 'Voxel', 'ShadowMap', 'Future', 'Legacy' },
                Default = 'ShadowMap',
                Callback = function(v)
                    if not (Toggles.WorldLightingMode and Toggles.WorldLightingMode.Value) then return end
                    pcall(function() Lighting.Technology = Enum.Technology[v] end)
                    if sethiddenproperty then pcall(function() sethiddenproperty(Lighting, 'Technology', Enum.Technology[v]) end) end
                end,
            })
            if Toggles.WorldLightingMode then
                Toggles.WorldLightingMode:OnChanged(function()
                    if Toggles.WorldLightingMode.Value then
                        local v = ovw('WorldLightingTech') or 'ShadowMap'
                        pcall(function() Lighting.Technology = Enum.Technology[v] end)
                        if sethiddenproperty then pcall(function() sethiddenproperty(Lighting, 'Technology', Enum.Technology[v]) end) end
                    end
                end)
            end

            WorldGb:AddToggle('WorldTimeEnabled', { Text = 'World Time', Default = false })
            WorldGb:AddSlider('WorldTimeHour', {
                Text = 'Hour', Default = 4.5, Min = 0, Max = 24, Rounding = 1,
                Callback = function(v)
                    if Toggles.WorldTimeEnabled and Toggles.WorldTimeEnabled.Value then
                        pcall(function() Lighting.ClockTime = v end)
                    end
                end,
            })
            task.spawn(function()
                while task.wait(0.1) do
                    if getgenv().LizardGen ~= lizardGen then break end
                    if tvw('WorldTimeEnabled') then
                        pcall(function() Lighting.ClockTime = ovw('WorldTimeHour') or 4.5 end)
                    end
                end
            end)

            getgenv().LizardAtmosphere = nil
            local function applyAtmosphere()
                local atm = getgenv().LizardAtmosphere
                if not (atm and atm.Parent) then
                    atm = Instance.new('Atmosphere')
                    atm.Name = 'LizardAtmosphere'
                    atm.Parent = Lighting
                    getgenv().LizardAtmosphere = atm
                end
                pcall(function()
                    atm.Density = ovw('WorldAtmDensity') or 0.35
                    atm.Offset = ovw('WorldAtmOffset') or 0
                    atm.Haze = ovw('WorldAtmHaze') or 1
                    atm.Glare = ovw('WorldAtmGlare') or 10
                    atm.Color = (Options.WorldAtmColor and Options.WorldAtmColor.Value) or Color3.fromRGB(199, 212, 255)
                    atm.Decay = (Options.WorldAtmDecay and Options.WorldAtmDecay.Value) or Color3.fromRGB(106, 112, 125)
                end)
            end
            local function clearAtmosphere()
                local atm = getgenv().LizardAtmosphere
                if atm then pcall(function() atm:Destroy() end) end
                getgenv().LizardAtmosphere = nil
            end

            local WorldAtmToggle = WorldGb:AddToggle('WorldAtmEnabled', {
                Text = 'Atmosphere', Default = false,
                Callback = function(v) if v then applyAtmosphere() else clearAtmosphere() end end,
            })
            WorldAtmToggle:AddColorPicker('WorldAtmColor', {
                Default = Color3.fromRGB(199, 212, 255),
                Title = 'Atmosphere Color',
                Callback = function() if tvw('WorldAtmEnabled') then applyAtmosphere() end end,
            })
            WorldAtmToggle:AddColorPicker('WorldAtmDecay', {
                Default = Color3.fromRGB(106, 112, 125),
                Title = 'Atmosphere Decay',
                Callback = function() if tvw('WorldAtmEnabled') then applyAtmosphere() end end,
            })
            WorldGb:AddSlider('WorldAtmHaze', { Text = 'Haze', Default = 1, Min = 0, Max = 10, Rounding = 1, Callback = function() if tvw('WorldAtmEnabled') then applyAtmosphere() end end })
            WorldGb:AddSlider('WorldAtmGlare', { Text = 'Glare', Default = 10, Min = 0, Max = 10, Rounding = 1, Callback = function() if tvw('WorldAtmEnabled') then applyAtmosphere() end end })
            WorldGb:AddSlider('WorldAtmOffset', { Text = 'Offset', Default = 0, Min = 0, Max = 1, Rounding = 2, Callback = function() if tvw('WorldAtmEnabled') then applyAtmosphere() end end })
            WorldGb:AddSlider('WorldAtmDensity', { Text = 'Density', Default = 0.35, Min = 0, Max = 1, Rounding = 2, Callback = function() if tvw('WorldAtmEnabled') then applyAtmosphere() end end })

            local MaterialService = game:GetService('MaterialService')
            local MINECRAFT_VARIANTS = {
                Brick = { BaseMaterial = Enum.Material.Brick, Texture = 'rbxassetid://10777285622' },
                Concrete = { BaseMaterial = Enum.Material.Concrete, Texture = 'rbxassetid://15622710576' },
                CorrodedMetal = { BaseMaterial = Enum.Material.CorrodedMetal, Texture = 'rbxassetid://78612695839404' },
                Grass = { BaseMaterial = Enum.Material.Grass, Texture = 'rbxassetid://9267183930' },
                Metal = { BaseMaterial = Enum.Material.Metal, Texture = 'rbxassetid://121650613091353' },
                Sand = { BaseMaterial = Enum.Material.Sand, Texture = 'rbxassetid://12624140843' },
                Slate = { BaseMaterial = Enum.Material.Slate, Texture = 'rbxassetid://8676746437' },
                Wood = { BaseMaterial = Enum.Material.Wood, Texture = 'rbxassetid://3258599312' },
                WoodPlanks = { BaseMaterial = Enum.Material.WoodPlanks, Texture = 'rbxassetid://8676581022' },
            }
            local MATERIAL_VARIANT_BY_MATERIAL = {
                [Enum.Material.Brick] = 'Brick',
                [Enum.Material.Concrete] = 'Concrete',
                [Enum.Material.CorrodedMetal] = 'CorrodedMetal',
                [Enum.Material.Grass] = 'Grass',
                [Enum.Material.Metal] = 'Metal',
                [Enum.Material.Sand] = 'Sand',
                [Enum.Material.Slate] = 'Slate',
                [Enum.Material.Wood] = 'Wood',
                [Enum.Material.WoodPlanks] = 'WoodPlanks',
            }
            local MINECRAFT_TERRAIN_COLORS = {
                [Enum.Material.Grass] = Color3.fromRGB(106, 170, 64),
                [Enum.Material.Ground] = Color3.fromRGB(134, 96, 67),
                [Enum.Material.Mud] = Color3.fromRGB(102, 76, 51),
                [Enum.Material.Sand] = Color3.fromRGB(219, 211, 160),
                [Enum.Material.Rock] = Color3.fromRGB(122, 122, 122),
                [Enum.Material.Slate] = Color3.fromRGB(90, 90, 90),
                [Enum.Material.Snow] = Color3.fromRGB(245, 245, 245),
                [Enum.Material.Water] = Color3.fromRGB(63, 118, 228),
            }
            getgenv().LizardTextureState = getgenv().LizardTextureState or setmetatable({}, { __mode = 'k' })
            getgenv().LizardMaterialVariantsBuilt = getgenv().LizardMaterialVariantsBuilt or false

            local function ensureMinecraftVariants()
                if getgenv().LizardMaterialVariantsBuilt then return end

                for name, data in pairs(MINECRAFT_VARIANTS) do
                    local variant = MaterialService:FindFirstChild(name)
                    if not variant then
                        variant = Instance.new('MaterialVariant')
                        variant.Name = name
                        variant.Parent = MaterialService
                    end

                    pcall(function()
                        variant.BaseMaterial = data.BaseMaterial
                        variant.ColorMap = data.Texture
                        variant.MetalnessMap = data.Texture
                        variant.NormalMap = data.Texture
                        variant.RoughnessMap = data.Texture
                        variant.MaterialPattern = Enum.MaterialPattern.Regular
                        variant.StudsPerTile = 5
                    end)
                end

                getgenv().LizardMaterialVariantsBuilt = true
            end

            local function rememberPartState(part)
                local state = getgenv().LizardTextureState
                if not state[part] then
                    state[part] = {
                        Color = part.Color,
                        Material = part.Material,
                        MaterialVariant = part.MaterialVariant,
                    }
                end
                return state[part]
            end

            local function shouldSkipTexturePart(part)
                if not part:IsDescendantOf(workspace) then return true end
                if part.Name == 'LizardWeather' or part.Name == 'Part' then return true end
                local parent = part.Parent
                if parent and (parent:IsA('Tool') or parent:IsA('Accessory')) then return true end
                local model = part:FindFirstAncestorOfClass('Model')
                if model and Players:GetPlayerFromCharacter(model) then return true end
                return false
            end

            local function applyPartTexturePack()
                ensureMinecraftVariants()

                for _, obj in ipairs(workspace:GetDescendants()) do
                    if obj:IsA('BasePart') and not shouldSkipTexturePart(obj) then
                        rememberPartState(obj)

                        local variantName = MATERIAL_VARIANT_BY_MATERIAL[obj.Material]
                        if variantName then
                            pcall(function()
                                obj.MaterialVariant = variantName
                            end)
                        end
                    end
                end
            end

            local function clearPartTexturePack()
                for part, state in pairs(getgenv().LizardTextureState) do
                    if part and part.Parent and state then
                        pcall(function()
                            part.Color = state.Color
                            part.Material = state.Material
                            part.MaterialVariant = state.MaterialVariant or ''
                        end)
                    end
                end
            end

            local function clearMinecraftVariants()
                for name, _ in pairs(MINECRAFT_VARIANTS) do
                    local variant = MaterialService:FindFirstChild(name)
                    if variant and variant:IsA('MaterialVariant') then
                        pcall(function()
                            variant:Destroy()
                        end)
                    end
                end
                getgenv().LizardMaterialVariantsBuilt = false
            end

            local function applyTexturePack()
                Terrain = Terrain or workspace:FindFirstChildOfClass('Terrain')

                if Terrain then
                    for mat, col in pairs(MINECRAFT_TERRAIN_COLORS) do
                        pcall(function() Terrain:SetMaterialColor(mat, col) end)
                    end
                end

                applyPartTexturePack()
            end

            local function clearTexturePack()
                clearPartTexturePack()
                clearMinecraftVariants()
            end

            WorldGb:AddToggle('WorldTexturesEnabled', {
                Text = 'Textures', Default = false,
                Callback = function(v)
                    if v then
                        applyTexturePack()
                    else
                        clearTexturePack()
                    end
                end,
            })
            WorldGb:AddDropdown('WorldTexturePack', {
                Text = 'Pack',
                Values = { 'minecraft' },
                Default = 'minecraft',
                Callback = function()
                    if tvw('WorldTexturesEnabled') then
                        applyTexturePack()
                    end
                end,
            })
            local WorldAmbientToggle = WorldGb:AddToggle('WorldAmbient', {
                Text = 'Ambient', Default = false,
                Callback = function(v)
                    if v then
                        pcall(function()
                            Lighting.Ambient = (Options.WorldAmbientColor and Options.WorldAmbientColor.Value) or Color3.fromRGB(178, 178, 178)
                            Lighting.OutdoorAmbient = (Options.WorldOutdoorAmbientColor and Options.WorldOutdoorAmbientColor.Value) or Color3.fromRGB(178, 178, 178)
                            Lighting.Brightness = 3
                        end)
                    else
                        pcall(function()
                            Lighting.Ambient = Color3.fromRGB(0, 0, 0)
                            Lighting.OutdoorAmbient = Color3.fromRGB(70, 70, 70)
                        end)
                    end
                end,
            })
            WorldAmbientToggle:AddColorPicker('WorldAmbientColor', {
                Default = Color3.fromRGB(178, 178, 178),
                Title = 'Ambient Color',
                Callback = function()
                    if tvw('WorldAmbient') then
                        pcall(function()
                            Lighting.Ambient = Options.WorldAmbientColor.Value
                        end)
                    end
                end,
            })
            WorldAmbientToggle:AddColorPicker('WorldOutdoorAmbientColor', {
                Default = Color3.fromRGB(178, 178, 178),
                Title = 'Outdoor Ambient Color',
                Callback = function()
                    if tvw('WorldAmbient') then
                        pcall(function()
                            Lighting.OutdoorAmbient = Options.WorldOutdoorAmbientColor.Value
                        end)
                    end
                end,
            })

            getgenv().LizardWeatherPart = nil
            getgenv().LizardWeatherConn = nil
            getgenv().LizardWeatherEmitters = nil
            getgenv().LizardRainCharacterConn = nil

            local function clearCharacterRain()
                if getgenv().LizardWeatherPart then
                    pcall(function() getgenv().LizardWeatherPart:Destroy() end)
                    getgenv().LizardWeatherPart = nil
                end
            end

            local function createCharacterRain(character)
                local head = character and character:FindFirstChild("Head")
                local root = character and character:FindFirstChild("HumanoidRootPart")
                if not head and not root then return end
                local weatherType = ovw('WorldWeatherType') or 'rain'
                local isLightRain = weatherType == 'light rain'
                local rate = ovw('WorldWeatherRate') or 100

                clearCharacterRain()

                local part = Instance.new("Part")
                part.Name = "Part"
                part.Size = Vector3.new(40, 40, 85)
                part.Transparency = 1
                part.Anchored = true
                part.CanCollide = false
                part.CanQuery = false
                part.CanTouch = false
                part.Parent = workspace

                local rainColor = (Options.WorldWeatherColor and Options.WorldWeatherColor.Value) or Color3.fromRGB(215, 228, 255)

                local rain = Instance.new("ParticleEmitter")
                rain.Name = "ParticleEmitter"
                rain.Texture = "rbxassetid://1822883048"
                rain.Brightness = 1
                rain.Color = ColorSequence.new(Color3.fromRGB(255, 255, 255))
                rain.LightEmission = 0.05
                rain.LightInfluence = 0.9
                rain.Orientation = Enum.ParticleOrientation.FacingCamera
                rain.Size = NumberSequence.new(10)
                rain.Squash = NumberSequence.new(2)
                rain.Transparency = NumberSequence.new(0.5)
                rain.ZOffset = 0
                rain.EmissionDirection = Enum.NormalId.Bottom
                rain.Enabled = true
                rain.Lifetime = NumberRange.new(0.8, 0.8)
                rain.Rate = isLightRain and 0 or math.max(rate * 6, 600)
                rain.Rotation = NumberRange.new(0, 0)
                rain.RotSpeed = NumberRange.new(0, 0)
                rain.Speed = NumberRange.new(60, 60)
                rain.SpreadAngle = Vector2.new(0, 0)
                rain.VelocityInheritance = 0
                rain.Drag = 0
                rain.LockedToPart = true
                rain.Parent = part

                if isLightRain then
                    local lightRain = Instance.new("ParticleEmitter")
                    lightRain.Name = "LightRainEffect"
                    lightRain.Texture = "rbxasset://textures/particles/sparkles_main.dds"
                    lightRain.Brightness = 1
                    lightRain.Color = ColorSequence.new(Color3.fromRGB(255, 255, 255))
                    lightRain.LightEmission = 0.05
                    lightRain.LightInfluence = 0.9
                    lightRain.Orientation = Enum.ParticleOrientation.FacingCamera
                    lightRain.Size = NumberSequence.new(1)
                    lightRain.Squash = NumberSequence.new(4)
                    lightRain.Transparency = NumberSequence.new(0.5)
                    lightRain.ZOffset = 0
                    lightRain.EmissionDirection = Enum.NormalId.Bottom
                    lightRain.Enabled = true
                    lightRain.Lifetime = NumberRange.new(0.8, 0.8)
                    lightRain.Rate = math.max(rate * 6, 600)
                    lightRain.Rotation = NumberRange.new(0, 0)
                    lightRain.RotSpeed = NumberRange.new(0, 0)
                    lightRain.Speed = NumberRange.new(60, 60)
                    lightRain.SpreadAngle = Vector2.new(0, 0)
                    lightRain.VelocityInheritance = 0
                    lightRain.Drag = 0
                    lightRain.LockedToPart = true
                    lightRain.Parent = part
                end

                getgenv().LizardWeatherPart = part
            end

            local function clearWeather()
                if getgenv().LizardWeatherConn then getgenv().LizardWeatherConn:Disconnect() getgenv().LizardWeatherConn = nil end
                if getgenv().LizardRainCharacterConn then getgenv().LizardRainCharacterConn:Disconnect() getgenv().LizardRainCharacterConn = nil end
                getgenv().LizardWeatherEmitters = nil
                clearCharacterRain()
                if getgenv().LizardWeatherPart then pcall(function() getgenv().LizardWeatherPart:Destroy() end) getgenv().LizardWeatherPart = nil end
            end
            local function buildWeather()
                clearWeather()
                local kind = ovw('WorldWeatherType') or 'rain'

                if kind == 'rain' or kind == 'light rain' then
                    local localPlayer = getgenv().LocalPlayer
                    if localPlayer.Character then
                        createCharacterRain(localPlayer.Character)
                    end

                    getgenv().LizardRainCharacterConn = localPlayer.CharacterAdded:Connect(function(character)
                        task.defer(function()
                            createCharacterRain(character)
                        end)
                    end)
                    getgenv().LizardWeatherConn = getgenv().RunService.RenderStepped:Connect(function()
                        local character = localPlayer.Character
                        local head = character and character:FindFirstChild("Head")
                        local root = character and character:FindFirstChild("HumanoidRootPart")
                        local followPart = getgenv().LizardWeatherPart
                        local target = head or root
                        if followPart and followPart.Parent and target then
                            followPart.CFrame = CFrame.new(target.Position + Vector3.new(0, 10, 0))
                        end
                    end)
                    return
                end

                local part = Instance.new('Part')
                part.Name = 'Part'
                part.Size = Vector3.new(260, 1, 260)
                part.Transparency = 1
                part.Anchored = true
                part.CanCollide = false
                part.CanQuery = false
                part.CanTouch = false
                part.Parent = workspace

                local primary = Instance.new('ParticleEmitter')
                primary.Name = 'WeatherEmitterPrimary'
                primary.Parent = part

                local secondary = Instance.new('ParticleEmitter')
                secondary.Name = 'WeatherEmitterSecondary'
                secondary.Parent = part

                local tertiary = Instance.new('ParticleEmitter')
                tertiary.Name = 'WeatherEmitterTertiary'
                tertiary.Parent = part

                getgenv().LizardWeatherPart = part
                getgenv().LizardWeatherEmitters = { primary, secondary, tertiary }

                local function configure()
                    local rate = ovw('WorldWeatherRate') or 100
                    local primaryRate = math.max(rate, 0)
                    local secondaryRate = math.max(math.floor(rate * 0.35), 0)

                    if kind == 'snow' then
                        tertiary.Texture = 'rbxassetid://99851851'
                        tertiary.Brightness = 1
                        tertiary.LightEmission = 0.5
                        tertiary.LightInfluence = 0
                        tertiary.Orientation = Enum.ParticleOrientation.FacingCamera
                        tertiary.Lifetime = NumberRange.new(5, 10)
                        tertiary.Speed = NumberRange.new(30, 30)
                        tertiary.Rotation = NumberRange.new(0, 0)
                        tertiary.RotSpeed = NumberRange.new(0, 0)
                        tertiary.Size = NumberSequence.new({
                            NumberSequenceKeypoint.new(0, 0.33),
                            NumberSequenceKeypoint.new(0.5, 0.551),
                            NumberSequenceKeypoint.new(1, 0.401),
                        })
                        tertiary.Squash = NumberSequence.new({
                            NumberSequenceKeypoint.new(0, 0),
                            NumberSequenceKeypoint.new(0.75, 0),
                            NumberSequenceKeypoint.new(1, 0),
                        })
                        tertiary.Color = ColorSequence.new((Options.WorldWeatherColor and Options.WorldWeatherColor.Value) or Color3.fromRGB(230, 236, 255))
                        tertiary.Transparency = NumberSequence.new({
                            NumberSequenceKeypoint.new(0, 0.74),
                            NumberSequenceKeypoint.new(0.35, 0.973),
                            NumberSequenceKeypoint.new(0.7, 0.77),
                            NumberSequenceKeypoint.new(1, 1),
                        })
                        tertiary.ZOffset = 0
                        tertiary.Acceleration = Vector3.new(0, 0, 0)
                        tertiary.Drag = 0
                        tertiary.SpreadAngle = Vector2.new(50, 50)
                        tertiary.Rate = math.max(primaryRate * 10, 1000)
                        tertiary.EmissionDirection = Enum.NormalId.Bottom
                        tertiary.Enabled = true

                        primary.Enabled = false
                        secondary.Enabled = false
                    end
                end
                configure()
                getgenv().LizardConfigureWeather = configure

                getgenv().LizardWeatherConn = getgenv().RunService.RenderStepped:Connect(function()
                    if part and part.Parent then
                        local camPos = getgenv().Camera.CFrame.Position
                        part.CFrame = CFrame.new(camPos + Vector3.new(0, 85, 0))

                        if kind == 'snow' then
                            local sway = math.sin(os.clock() * 0.9) * 6
                            primary.Acceleration = Vector3.new(sway, -20, sway * 0.35)
                            secondary.Acceleration = Vector3.new(-sway * 0.55, -14, sway * 0.55)
                        end
                    end
                end)
            end

            local WorldWeatherToggle = WorldGb:AddToggle('WorldWeatherEnabled', {
                Text = 'Weather', Default = false,
                Callback = function(v) if v then buildWeather() else clearWeather() end end,
            })
            WorldWeatherToggle:AddColorPicker('WorldWeatherColor', {
                Default = Color3.fromRGB(255, 255, 255),
                Title = 'Weather Color',
                Callback = function()
                    if tvw('WorldWeatherEnabled') then
                        buildWeather()
                    end
                end,
            })
            WorldGb:AddDropdown('WorldWeatherType', {
                Text = 'Type', Values = { 'light rain', 'rain', 'snow' }, Default = 'rain',
                Callback = function()
                    if tvw('WorldWeatherEnabled') then
                        buildWeather()
                    end
                end,
            })
            WorldGb:AddSlider('WorldWeatherRate', {
                Text = 'Rate', Default = 100, Min = 0, Max = 100, Rounding = 0,
                Callback = function() if tvw('WorldWeatherEnabled') and getgenv().LizardConfigureWeather then getgenv().LizardConfigureWeather() end end,
            })

            getgenv().LizardSky = nil
            local function applySkyboxPreset(sky, preset)
                if not sky then return end
                preset = preset or (ovw('WorldSkyboxType') or 'realistic')

                if preset == 'realistic' then
                    sky.MoonTextureId = 'rbxasset://sky/moon.jpg'
                    sky.SkyboxBk = 'rbxassetid://15502511288'
                    sky.SkyboxDn = 'rbxassetid://15502508460'
                    sky.SkyboxFt = 'rbxassetid://15502510289'
                    sky.SkyboxLf = 'rbxassetid://15502507918'
                    sky.SkyboxRt = 'rbxassetid://15502509398'
                    sky.SkyboxUp = 'rbxassetid://15502511911'
                    sky.StarCount = 3000
                    sky.CelestialBodiesShown = true
                end
            end
            WorldGb:AddToggle('WorldSkybox', {
                Text = 'Skybox', Default = false,
                Callback = function(v)
                    if v then
                        local existing = Lighting:FindFirstChildOfClass('Sky')
                        if existing and existing ~= getgenv().LizardSky then pcall(function() existing.Parent = nil end) end
                        local sky = getgenv().LizardSky
                        if not (sky and sky.Parent) then
                            sky = Instance.new('Sky')
                            sky.Name = 'LizardSky'
                            applySkyboxPreset(sky)
                            sky.Parent = Lighting
                            getgenv().LizardSky = sky
                        else
                            applySkyboxPreset(sky)
                            sky.Parent = Lighting
                        end
                    else
                        if getgenv().LizardSky then pcall(function() getgenv().LizardSky.Parent = nil end) end
                    end
                end,
            })
            WorldGb:AddDropdown('WorldSkyboxType', {
                Text = 'Sky',
                Values = { 'realistic' },
                Default = 'realistic',
                Callback = function(v)
                    if tvw('WorldSkybox') and getgenv().LizardSky then
                        applySkyboxPreset(getgenv().LizardSky, v)
                    end
                end,
            })
        end

local danceTrack
local lagConnection

local function validCharacter(c)
    local h = c and c:FindFirstChildOfClass("Humanoid")
    return h and h.Health > 0 and c:FindFirstChild("HumanoidRootPart")
end

local function loadDance()
    local c = LocalPlayer.Character
    if not validCharacter(c) or settings.CurrentDanceId == "" then return end
    local h = c:FindFirstChildOfClass("Humanoid")
    local animator = h:FindFirstChildOfClass("Animator") or Instance.new("Animator", h)
    if danceTrack then danceTrack:Stop() danceTrack:Destroy() end
    local a = Instance.new("Animation")
    a.AnimationId = settings.CurrentDanceId
    danceTrack = animator:LoadAnimation(a)
    danceTrack.Priority = Enum.AnimationPriority.Action
end

local function playDance()
    if settings.DanceEnabled and danceTrack then
        pcall(function()
            if not danceTrack.IsPlaying then
                danceTrack:Play()
            end
            if not settings.LagAnimations then
                danceTrack:AdjustSpeed(settings.EmoteSpeed or 1)
            end
        end)
    end
end

local function stopLag()
    if lagConnection then lagConnection:Disconnect() lagConnection = nil end
    if danceTrack then pcall(function() danceTrack:AdjustSpeed(settings.EmoteSpeed or 1) end) end
end

local function startUltraLag()
    stopLag()
    local accumulator = 0
    local updateRate = math.clamp(20 - settings.LagIntensity * 6, 4, 20)
    lagConnection = RunService.RenderStepped:Connect(function(dt)
        if not settings.LagAnimations or not danceTrack or not danceTrack.IsPlaying then
            stopLag()
            return
        end
        accumulator += dt
        if accumulator < (1 / updateRate) then return end
        accumulator = 0
        if math.random() < (0.35 * settings.LagIntensity) then return end
        local r = math.random()
        if r < 0.35 * settings.LagIntensity then
            danceTrack:AdjustSpeed(0)
        elseif r < 0.5 * settings.LagIntensity then
            danceTrack:AdjustSpeed(-math.random(2,6))
        else
            danceTrack:AdjustSpeed(math.random(1,8))
        end
    end)
end

LocalPlayer.CharacterAdded:Connect(function()
    task.wait(1)
    if settings.DanceEnabled then
        task.spawn(function()
            task.wait(0.1)
            loadDance()
            playDance()
            if settings.LagAnimations and danceTrack then startUltraLag() end
        end)
    end
end)

if LocalPlayer.Character and validCharacter(LocalPlayer.Character) then
    task.spawn(function()
        task.wait(1)
        loadDance()
        playDance()
        if settings.LagAnimations and danceTrack then startUltraLag() end
    end)
end

local nameList = {"None"}
for _, user in ipairs(users) do table.insert(nameList, user.UserName) end

Avatar:AddDropdown('Char', {
    Default = 'None',
    Values = nameList,
    Callback = function(selected)
        settings.SelectedUserName = selected
        settings.SelectedUserId = nil
        if selected ~= "None" then
            for _, user in pairs(users) do
                if user.UserName == selected then Morph(user.UserId, LocalPlayer.Name) break end
            end
        else
            Morph(LocalPlayer.UserId, LocalPlayer.Name)
        end
    end
})

Avatar:AddToggle('HeadlessToggle', {
    Text = 'Toggle Headless',
    Default = settings.HasHeadless,
    Callback = function(state)
        settings.HasHeadless = state
        if LocalPlayer.Character then
            if state then ApplyHeadless(LocalPlayer.Character) else RemoveHeadless(LocalPlayer.Character) end
        end
    end
})

Avatar:AddToggle('KorbloxToggle', {
    Text = 'Toggle Korblox',
    Default = settings.HasKorblox,
    Callback = function(state)
        settings.HasKorblox = state
        if LocalPlayer.Character then
            if state then ApplyKorblox(LocalPlayer.Character) else RemoveKorblox(LocalPlayer.Character) end
        end
    end
})

Avatar:AddToggle('ChamsToggle', {
    Text = 'Toggle Chams',
    Default = settings.HasChams,
    Callback = function(state)
        settings.HasChams = state
        if LocalPlayer.Character then
            if state then ApplyChams(LocalPlayer.Character) else RemoveChams(LocalPlayer.Character) end
        end
    end
}):AddColorPicker('ChamsColor', {
    Default = Color3.new(1, 1, 1),
    Callback = function(color)
        settings.ChamsColor = color
        if settings.HasChams and LocalPlayer.Character then
            ApplyChams(LocalPlayer.Character)
        end
    end
})

Avatar:AddToggle('RemoveAccessories', {
    Text = 'Remove Accessories',
    Default = false,
    Callback = function()
        local char = LocalPlayer.Character
        if not char then return end
        for _, v in pairs(char:GetChildren()) do
            if v:IsA("Accessory") then v:Destroy() end
        end
    end
})

Avatar:AddInput('CustomAccessory', {
    Text = 'Add Accessory by ID',
    Default = '',
    Numeric = false,
    Finished = false,
    Callback = function(idText)
        local char = LocalPlayer.Character
        if not char then return end
        local id = idText:match("%d+")
        if not id then return end

        local function findAttachment(rootPart, name)
            for _, descendant in pairs(rootPart:GetDescendants()) do
                if descendant:IsA("Attachment") and descendant.Name == name then
                    return descendant
                end
            end
        end

        local function weldParts(part0, part1, c0, c1)
            local weld = Instance.new("Weld")
            weld.Part0 = part0
            weld.Part1 = part1
            weld.C0 = c0
            weld.C1 = c1 or CFrame.new()
            weld.Parent = part0
            return weld
        end

        local success, objects = pcall(function()
            return game:GetObjects("rbxassetid://" .. id)
        end)
        if not success or not objects or not objects[1] then
            print("Failed to load asset: " .. tostring(id))
            return
        end

        local accessory = objects[1]
        accessory.Parent = workspace

        local handle = accessory:FindFirstChild("Handle")
        if not handle then
            accessory:Destroy()
            print("No Handle found in asset: " .. tostring(id))
            return
        end

        local attachment = handle:FindFirstChildOfClass("Attachment")
        local parentPart = char:FindFirstChild("Head")
            or char:FindFirstChild("UpperTorso")
            or char:FindFirstChild("Torso")

        if attachment and parentPart then
            local parentAttachment = findAttachment(parentPart, attachment.Name)
            if parentAttachment then
                weldParts(parentPart, handle, parentAttachment.CFrame, attachment.CFrame)
            else
                weldParts(parentPart, handle, CFrame.new(0, 0.5, 0), CFrame.new())
            end
        elseif parentPart then
            weldParts(parentPart, handle, CFrame.new(0, 0.5, 0), CFrame.new())
        end

        accessory.Parent = char
    end
})

Avatar:AddToggle("EnableDance", {
    Text = "Enable Emote",
    Default = false,
    Callback = function(v)
        settings.DanceEnabled = v
        if v then
            loadDance()
            playDance()
            if settings.LagAnimations and danceTrack then startUltraLag() end
        else
            if danceTrack then danceTrack:Stop() end
            stopLag()
        end
    end
})

local danceNames = {}
for name in pairs(danceAnimations) do
    table.insert(danceNames, name)
end

Avatar:AddDropdown("SelectDance", {
    Text = "Select Emote",
    Values = danceNames,
    Default = "None",
    Callback = function(v)
        settings.CurrentDanceName = v
        settings.CurrentDanceId = danceAnimations[v]
        if settings.DanceEnabled then
            loadDance()
            playDance()
            if settings.LagAnimations and danceTrack then startUltraLag() end
        end
    end
})

Avatar:AddSlider("EmoteSpeed", {
    Text = "Emote Speed",
    Default = 1,
    Min = 0,
    Max = 10,
    Rounding = 1,
    Callback = function(v)
        settings.EmoteSpeed = v
        if settings.DanceEnabled and danceTrack and not settings.LagAnimations then
            pcall(function() danceTrack:AdjustSpeed(v) end)
        end
    end
})

Avatar:AddToggle("LagAnimations", {
    Text = "Lag Animations",
    Default = false,
    Callback = function(v)
        settings.LagAnimations = v
        if v and danceTrack then
            startUltraLag()
        else
            stopLag()
            if settings.DanceEnabled then playDance() end
        end
    end
})

Avatar:AddSlider("LagIntensity", {
    Text = "Lag Intensity",
    Default = 1,
    Min = 0,
    Max = 3,
    Rounding = 1,
    Callback = function(v)
        settings.LagIntensity = v
    end
})

local StarterGui = game:GetService("StarterGui")
StarterGui:SetCore("ResetButtonCallback", true)

local TextChatService = game:GetService("TextChatService")
local chatConfig = TextChatService.ChatWindowConfiguration

local players = game:GetService("Players")
local runservice = game:GetService("RunService")
local lp = players.LocalPlayer

local g = getgenv()
g.flashback = g.flashback or {}

if g.flashback.conn then
    pcall(function() g.flashback.conn:Disconnect() end)
    g.flashback.conn = nil
end

g.flashback.settings = {
    enabled = false
}

local lastcf

local function gethrp()
    local char = lp.Character
    return char and char:FindFirstChild("HumanoidRootPart")
end

g.flashback.conn = runservice.Heartbeat:Connect(function()
    if not g.flashback.settings.enabled then return end
    local char = lp.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hum or not hrp then return end

    if hum.Health <= 10 and not lastcf then
        lastcf = hrp.CFrame
    elseif hum.Health > 10 and lastcf then
        hrp.CFrame = lastcf + Vector3.new(math.sin(tick()) * 0.001, 0, math.cos(tick()) * 0.001)
        lastcf = nil
    end
end)

local groupId = 339846382

local function isStaff(player)
    if not player or not player:IsInGroup(groupId) then return false end
    local role = player:GetRoleInGroup(groupId)
    return role and role ~= "" and role ~= "Guest"
end

local function sendNotification(message)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = "Staff Alert",
            Text = message,
            Duration = 6,
            Icon = "rbxassetid://6031075938"
        })
    end)
end

local function handleStaffJoin(staffPlayer)
    if not getgenv().AntiStaffSettings.Enabled then return end
    local action = getgenv().AntiStaffSettings.Action
    if action == "Notify" or action == "Both" then
        sendNotification("Staff detected: " .. staffPlayer.DisplayName .. " (@" .. staffPlayer.Name .. ")")
    end
    if action == "Kick" or action == "Both" then
        task.wait(3)
        LocalPlayer:Kick("\nStaff member joined the game:\n" .. staffPlayer.DisplayName .. " (@" .. staffPlayer.Name .. ")\n\nYou were automatically disconnected for safety.")
    end
end

task.spawn(function()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and isStaff(player) then handleStaffJoin(player) end
    end
end)

Players.PlayerAdded:Connect(function(player)
    if player ~= LocalPlayer and isStaff(player) then handleStaffJoin(player) end
end)
getgenv().FlyCore = nil
getgenv().FlyBV = nil
getgenv().FlyBG = nil
getgenv().FlyConn = nil

getgenv().StartFly = function()
    if getgenv().Misc.Flying then return end
    local char = getgenv().LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    getgenv().Misc.Flying = true
    if workspace:FindFirstChild("FlyCore") then workspace.FlyCore:Destroy() end
    getgenv().FlyCore = Instance.new("Part")
    getgenv().FlyCore.Name = "FlyCore"; getgenv().FlyCore.Size = Vector3.new(0.05,0.05,0.05)
    getgenv().FlyCore.Transparency = 1; getgenv().FlyCore.CanCollide = false; getgenv().FlyCore.Parent = workspace
    local weld = Instance.new("WeldConstraint")
    weld.Part0 = getgenv().FlyCore; weld.Part1 = char.HumanoidRootPart; weld.Parent = getgenv().FlyCore
    getgenv().FlyBV = Instance.new("BodyVelocity")
    getgenv().FlyBV.MaxForce = Vector3.new(400000,400000,400000); getgenv().FlyBV.P = 9000
    getgenv().FlyBV.Velocity = Vector3.zero; getgenv().FlyBV.Parent = getgenv().FlyCore
    getgenv().FlyBG = Instance.new("BodyGyro")
    getgenv().FlyBG.MaxTorque = Vector3.new(400000,400000,400000); getgenv().FlyBG.P = 15000
    getgenv().FlyBG.D = 1000; getgenv().FlyBG.CFrame = getgenv().FlyCore.CFrame; getgenv().FlyBG.Parent = getgenv().FlyCore
    if getgenv().FlyConn then getgenv().FlyConn:Disconnect() end
    getgenv().FlyConn = getgenv().RunService.RenderStepped:Connect(function()
        if not getgenv().Misc.Flying or not getgenv().FlyBV or not getgenv().FlyBG then return end
        local cam = workspace.CurrentCamera
        local move = Vector3.zero
        if getgenv().UserInputService:IsKeyDown(Enum.KeyCode.W) then move += cam.CFrame.LookVector end
        if getgenv().UserInputService:IsKeyDown(Enum.KeyCode.S) then move -= cam.CFrame.LookVector end
        if getgenv().UserInputService:IsKeyDown(Enum.KeyCode.A) then move -= cam.CFrame.RightVector end
        if getgenv().UserInputService:IsKeyDown(Enum.KeyCode.D) then move += cam.CFrame.RightVector end
        if getgenv().UserInputService:IsKeyDown(Enum.KeyCode.Space) then move += Vector3.new(0,1,0) end
        if getgenv().UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then move -= Vector3.new(0,1,0) end
        if move.Magnitude > 0 then move = move.Unit end
        getgenv().FlyBV.Velocity = move * getgenv().Misc.FlySpeed
        getgenv().FlyBG.CFrame = cam.CFrame
    end)
end

getgenv().StopFly = function()
    if not getgenv().Misc.Flying then return end
    getgenv().Misc.Flying = false
    if getgenv().FlyConn then getgenv().FlyConn:Disconnect(); getgenv().FlyConn = nil end
    if getgenv().FlyBV then getgenv().FlyBV:Destroy(); getgenv().FlyBV = nil end
    if getgenv().FlyBG then getgenv().FlyBG:Destroy(); getgenv().FlyBG = nil end
    if getgenv().FlyCore and getgenv().FlyCore.Parent then getgenv().FlyCore:Destroy(); getgenv().FlyCore = nil end
end

getgenv().UpdateNotifPosition(Options.NotifPos.Value)

task.spawn(function()
    while task.wait(0.1) do
        if getgenv().LizardGen ~= lizardGen then break end
        local now = tick()

        local char = getgenv().LocalPlayer.Character
        local hum = char and char:FindFirstChildWhichIsA("Humanoid")

        if hum then
            if lastLocalHealthForAutoVoid == nil then
                lastLocalHealthForAutoVoid = hum.Health
            else
                local autoVoidEnabled = false
                if Toggles and Toggles.AutoVoidOnHit then
                    autoVoidEnabled = Toggles.AutoVoidOnHit.Value
                end

                if hum.Health < lastLocalHealthForAutoVoid and autoVoidEnabled then
                    if Toggles and Toggles.CSyncEnabled and not Toggles.CSyncEnabled.Value then
                        hitAutoVoidOwnedSync = true
                        Toggles.CSyncEnabled:SetValue(true)
                    end

                    if Options and Options.CSyncType then
                        Options.CSyncType:SetValue("Void")
                    end

                    local duration = 2
                    if Options and Options.AutoVoidOnHitDuration then
                        duration = Options.AutoVoidOnHitDuration.Value
                    end

                    hitAutoVoidActiveUntil = now + duration

                    task.delay(duration, function()
                        if tick() >= hitAutoVoidActiveUntil then
                            if hitAutoVoidOwnedSync then
                                if Toggles and Toggles.CSyncEnabled then
                                    Toggles.CSyncEnabled:SetValue(false)
                                end
                                hitAutoVoidOwnedSync = false
                            end
                        end
                    end)
                end
                lastLocalHealthForAutoVoid = hum.Health
            end
        end
    end
end)

getgenv().FOVConnection = getgenv().RunService.RenderStepped:Connect(function()
    if not getgenv().Config or not getgenv().Config.Visual then return end

    local cfg = getgenv().Config.Visual
    local fov = cfg.FOV
    local mousePos = getgenv().UserInputService:GetMouseLocation()
    local centerPos = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize/2 or Vector2.new(0, 0)
    local targetPos = (fov and fov.FollowCursor == false) and centerPos or Vector2.new(mousePos.X, mousePos.Y)
    local tNow = tick()

    if fov and fov.Enabled then
        if not fov.InnerCircle or not fov.ScreenGui then createFOV() end

        local radius = fov.Size or 300
        if fov.PulseEnabled then
            radius = radius + (math.sin(tNow * (fov.PulseSpeed or 2)) * (fov.PulseAmount or 20))
        end
        radius = math.max(1, radius)
        local shape = fov.Shape or 'Circle'

        if fov.ScreenGui then
            fov.ScreenGui.Enabled = false
        end

        local isCircle = (shape == 'Circle')
        local isSquare = (shape == 'Square')
        local isHexagon = (shape == 'Hexagon')
        local isTriangle = (shape == 'Triangle')

        local drawVisible = true
        local fillVisible = fov.Filled == true

        if fov.InnerCircle then
            fov.InnerCircle.Visible = drawVisible and isCircle
            if fov.InnerCircle.Visible then
                fov.InnerCircle.Position = targetPos
                fov.InnerCircle.Radius = radius
                fov.InnerCircle.Color = fov.InnerColor or Color3.new(1,1,1)
                fov.InnerCircle.Transparency = 1
                fov.InnerCircle.Thickness = 1
                fov.InnerCircle.Filled = false
            end

            if fov.OuterCircle then
                fov.OuterCircle.Visible = drawVisible and isCircle
                if fov.OuterCircle.Visible then
                    fov.OuterCircle.Position = targetPos
                    fov.OuterCircle.Radius = radius + 1
                    fov.OuterCircle.Color = fov.OuterColor or Color3.new(0,0,0)
                    fov.OuterCircle.Transparency = 1
                    fov.OuterCircle.Thickness = 1
                    fov.OuterCircle.Filled = false
                end
            end
            if fov.FillCircle then
                fov.FillCircle.Visible = fillVisible and isCircle
                if fov.FillCircle.Visible then
                    fov.FillCircle.Position = targetPos
                    fov.FillCircle.Radius = radius
                    fov.FillCircle.Color = fov.FillColor or fov.InnerColor or Color3.new(1, 1, 1)
                    fov.FillCircle.Transparency = 0.1
                    fov.FillCircle.Thickness = 1
                    fov.FillCircle.Filled = true
                end
            end

            local points, outerPoints
            local function getPolygonPointsCached(sides, offset)
                local p = {}
                local angleStep = (math.pi * 2) / sides
                local baseRotation = (shape == 'Triangle' and -math.pi/2 or (shape == 'Square' and math.pi/4 or 0))
                local currentRotation = math.rad(fov.Rotation or 0)
                local totalRotation = baseRotation + currentRotation

                for i = 1, sides do
                    local angle = (i * angleStep) + totalRotation
                    p[i] = targetPos + Vector2.new(math.cos(angle) * (radius + offset), math.sin(angle) * (radius + offset))
                end
                return p
            end

            if fov.Lines then
                local visible = drawVisible and (not isCircle)
                local sides = (isSquare and 4 or (isHexagon and 6 or (isTriangle and 3 or 0)))

                if visible then
                    points = getPolygonPointsCached(sides, 0)
                    outerPoints = getPolygonPointsCached(sides, 1)
                end

                for i = 1, 12 do
                    local line = fov.Lines[i]
                    if not line then continue end
                    if i <= sides and visible then
                        local nextIdx = (i % sides) + 1
                        line.Visible = true
                        line.From = points[i]
                        line.To = points[nextIdx]
                        line.Color = fov.InnerColor or Color3.new(1,1,1)
                        line.Thickness = 1
                        line.Transparency = 1
                    elseif i > sides and i <= sides * 2 and visible then
                        local realIdx = i - sides
                        local nextIdx = (realIdx % sides) + 1
                        line.Visible = true
                        line.From = outerPoints[realIdx]
                        line.To = outerPoints[nextIdx]
                        line.Color = fov.OuterColor or Color3.new(0,0,0)
                        line.Thickness = 1
                        line.Transparency = 1
                    else
                        line.Visible = false
                    end
                end
            end

            if fov.Triangles then
                local visible = fillVisible and (not isCircle)
                local sides = (isSquare and 4 or (isHexagon and 6 or (isTriangle and 3 or 0)))

                if visible and not points then
                    points = getPolygonPointsCached(sides, 0)
                end

                for i = 1, 6 do
                    local tri = fov.Triangles[i]
                    if not tri then continue end
                    if i <= sides and visible then
                        local nextIdx = (i % sides) + 1
                        tri.Visible = true
                        tri.PointA = targetPos
                        tri.PointB = points[i]
                        tri.PointC = points[nextIdx]
                        tri.Color = fov.FillColor or fov.InnerColor or Color3.new(1,1,1)
                        tri.Transparency = 0.1
                        tri.Filled = true
                    else
                        tri.Visible = false
                    end
                end
            end
        end
    else
        if fov then
            if fov.InnerCircle then fov.InnerCircle.Visible = false end
            if fov.OuterCircle then fov.OuterCircle.Visible = false end
            if fov.FillCircle then fov.FillCircle.Visible = false end
            if fov.Lines then for _, l in ipairs(fov.Lines) do l.Visible = false end end
            if fov.Triangles then for _, t in ipairs(fov.Triangles) do t.Visible = false end end
        end
    end
end)

getgenv().WatermarkConnection = getgenv().RunService.Heartbeat:Connect(function() getgenv().FrameCounter = getgenv().FrameCounter + 1 end)
task.spawn(function()
    while task.wait(1) do
        if getgenv().LizardGen ~= lizardGen then break end
        getgenv().FPS = getgenv().FrameCounter
        getgenv().FrameCounter = 0
        local ping = "0"
        pcall(function() ping = getgenv().Stats.Network.ServerStatsItem["Data Ping"]:GetValueString() end)
        local executorName = (identifyexecutor and identifyexecutor()) or (getexecutorname and getexecutorname()) or "Unknown"
getgenv().Library:SetWatermark(string.format('Lizard | %s | %d fps | %s ms | players: %d/%d', executorName, getgenv().FPS, ping, #getgenv().Players:GetPlayers(), getgenv().Players.MaxPlayers))    end
end)

pcall(function()
    getgenv().Library:SetWatermarkVisibility(true)
    if getgenv().Library.KeybindFrame then
        getgenv().Library.KeybindFrame.Visible = getgenv().ForceDefaultHudVisible == true
    end
end)

 getgenv().Library:OnUnload(function()
    if getgenv().ForceHitConnection then getgenv().ForceHitConnection:Disconnect() end
    if getgenv().MainHeartbeatConnection then getgenv().MainHeartbeatConnection:Disconnect() end
    if getgenv().DesyncIndicatorConnection then getgenv().DesyncIndicatorConnection:Disconnect() end
    if getgenv().FOVConnection then getgenv().FOVConnection:Disconnect() end
    if getgenv().LizardWeatherConn then getgenv().LizardWeatherConn:Disconnect() end
    if getgenv().FlyConn then getgenv().FlyConn:Disconnect() end
    if getgenv().Misc and getgenv().Misc.SpinConnection then getgenv().Misc.SpinConnection:Disconnect() end
    if getgenv().WatermarkConnection then getgenv().WatermarkConnection:Disconnect() end
    if getgenv().TargetHealthConnection then getgenv().TargetHealthConnection:Disconnect() end
    if getgenv().TargetRespawnConnection then getgenv().TargetRespawnConnection:Disconnect() end
    if getgenv().TargetCleanupConnection then getgenv().TargetCleanupConnection:Disconnect() end
    if getgenv().LizardFOV then
        if getgenv().LizardFOV.Inner then getgenv().LizardFOV.Inner:Remove() end
        if getgenv().LizardFOV.Outer then getgenv().LizardFOV.Outer:Remove() end
        if getgenv().LizardFOV.ScreenGui then getgenv().LizardFOV.ScreenGui:Destroy() end
    end
    if getgenv().TracerLine then getgenv().TracerLine:Remove() end
    if getgenv().TracerOutline then getgenv().TracerOutline:Remove() end
    if getgenv().TracerLine2 then getgenv().TracerLine2:Remove() end
    if getgenv().TracerOutline2 then getgenv().TracerOutline2:Remove() end
    if getgenv().HitNotifGui then getgenv().HitNotifGui:Destroy() end
    if getgenv().StrafeConnection then getgenv().StrafeConnection:Disconnect() end
    if getgenv().SpectateConnection then getgenv().SpectateConnection:Disconnect() end
    if getgenv().ESPConnection then getgenv().ESPConnection:Disconnect() end
    if getgenv().ESPCleanup then getgenv().ESPCleanup() end
    if getgenv().DickESPCleanup then getgenv().DickESPCleanup() end
    if getgenv().LegitAimConnection then getgenv().LegitAimConnection:Disconnect() end
    if getgenv().LegitFovCircle then pcall(function() getgenv().LegitFovCircle:Remove() end) end
    if getgenv().KnifeGlueConn then getgenv().KnifeGlueConn:Disconnect() end
    if getgenv().AutoReloadConnection then getgenv().AutoReloadConnection:Disconnect() end
    if getgenv().CrosshairConnection then getgenv().CrosshairConnection:Disconnect() end
    if getgenv().CrosshairLines then
        for _, l in ipairs(getgenv().CrosshairLines) do pcall(function() l:Remove() end) end
    end
    if getgenv().HUDConnection then getgenv().HUDConnection:Disconnect() end
    if getgenv().TargetHUDGui then pcall(function() getgenv().TargetHUDGui:Destroy() end) end
    if getgenv().AmmoHUDGui then pcall(function() getgenv().AmmoHUDGui:Destroy() end) end
    pcall(function()
        local hum = getgenv().LocalPlayer.Character and getgenv().LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum and hum.RootPart and sethiddenproperty then sethiddenproperty(hum.RootPart, "PhysicsRepRootPart", nil) end
    end)
    if getgenv().LizardOldNamecall then
        pcall(function() hookmetamethod(game, "__namecall", getgenv().LizardOldNamecall) end)
        getgenv().LizardOldNamecall = nil
    end
    getgenv().destroyStrafeVisualizer()
    getgenv().resetStrafeCamera()
    getgenv().LizardGen = (getgenv().LizardGen or 0) + 1
    getgenv().Library.Unloaded = true
end)

do
    local Camera = getgenv().Camera
    local Players = getgenv().Players
    local LocalPlayer = getgenv().LocalPlayer
    local UIS = getgenv().UserInputService
    local RunService = getgenv().RunService

    local LegitGb = getgenv().LegitGb
    LegitGb:AddToggle('LegitAimbot', { Text = 'Aimbot', Default = false })
        :AddKeyPicker('LegitAimbotKey', { Default = 'E', Mode = 'Toggle', Text = 'Aimbot', SyncToggleState = true, NoUI = false })
    LegitGb:AddToggle('LegitSilent', { Text = 'Silent', Default = false })
    LegitGb:AddToggle('LegitFov', { Text = 'fov', Default = false })
        :AddColorPicker('LegitFovColor', { Default = Color3.fromRGB(255, 255, 255), Title = 'FOV Color' })
    LegitGb:AddDropdown('LegitPart', { Text = 'Part', Default = 'Head', Values = { 'Head', 'UpperTorso', 'HumanoidRootPart', 'LowerTorso' } })
    LegitGb:AddSlider('LegitSmooth', { Text = 'Smooth', Default = 0.05, Min = 0, Max = 1, Rounding = 3 })
    LegitGb:AddSlider('LegitPred', { Text = 'Pred', Default = 0.155, Min = 0, Max = 1, Rounding = 3 })
    LegitGb:AddSlider('LegitRadius', { Text = 'Radius', Default = 100, Min = 10, Max = 800, Rounding = 0 })
    LegitGb:AddToggle('LegitWallCheck', { Text = 'Wall Check', Default = true })
    LegitGb:AddToggle('LegitSticky', { Text = 'Sticky (aimbot + silent)', Default = true })

    local function ov(n) local o = Options[n] return o and o.Value end
    local function tv(n) local t = Toggles[n] return t and t.Value end

    local function legitWallOk(part)
        if not tv('LegitWallCheck') then return true end
        if not part or not part.Parent then return false end
        local origin = Camera.CFrame.Position
        local rp = RaycastParams.new()
        rp.FilterType = Enum.RaycastFilterType.Blacklist
        local filter = { Camera }
        if LocalPlayer.Character then table.insert(filter, LocalPlayer.Character) end
        rp.FilterDescendantsInstances = filter
        local res = workspace:Raycast(origin, part.Position - origin, rp)
        if not res or not res.Instance then return true end
        return res.Instance:IsDescendantOf(part.Parent)
    end

    local stickyTarget = nil
    local function legitClosest()
        local partName = ov('LegitPart') or 'Head'

        if tv('LegitSticky') and stickyTarget and stickyTarget.Parent and stickyTarget.Character and not getgenv().isKO(stickyTarget) then
            local part = stickyTarget.Character:FindFirstChild(partName)
            if part then
                local sp, vis = Camera:WorldToViewportPoint(part.Position)
                if vis and legitWallOk(part) then
                    return stickyTarget, part
                end
            end
        end

        local mouse = UIS:GetMouseLocation()
        local radius = ov('LegitRadius') or 100
        local shortest, closest, closestPart = radius, nil, nil
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Character then
                local part = plr.Character:FindFirstChild(partName)
                if part and not getgenv().isKO(plr) then
                    local sp, vis = Camera:WorldToViewportPoint(part.Position)
                    if vis then
                        local d = (Vector2.new(sp.X, sp.Y) - mouse).Magnitude
                        if d < shortest and legitWallOk(part) then
                            shortest, closest, closestPart = d, plr, part
                        end
                    end
                end
            end
        end
        stickyTarget = closest
        return closest, closestPart
    end
    getgenv().LegitClosest = legitClosest

    local fovCircle = Drawing.new("Circle")
    fovCircle.Thickness = 1; fovCircle.Filled = false; fovCircle.Transparency = 1
    fovCircle.Color = Color3.fromRGB(255, 255, 255); fovCircle.Visible = false
    pcall(function() fovCircle.NumSides = 64 end)
    getgenv().LegitFovCircle = fovCircle

    getgenv().LegitAimConnection = RunService.RenderStepped:Connect(function()
        if tv('LegitFov') then
            local m = UIS:GetMouseLocation()
            fovCircle.Visible = true
            fovCircle.Position = Vector2.new(m.X, m.Y)
            fovCircle.Radius = ov('LegitRadius') or 100
            fovCircle.Color = ov('LegitFovColor') or Color3.fromRGB(255, 255, 255)
        else
            fovCircle.Visible = false
        end

        if not tv('LegitAimbot') then return end
        local key = Options.LegitAimbotKey
        if not (key and key:GetState()) then return end

        local _, part = legitClosest()
        if not part then return end
        local pred = ov('LegitPred') or 0
        local aimPos = part.Position + part.AssemblyLinearVelocity * pred
        local desired = CFrame.lookAt(Camera.CFrame.Position, aimPos)
        local smooth = math.clamp(ov('LegitSmooth') or 0.05, 0, 1)
        local alpha = math.clamp(1 - smooth, 0.01, 1)
        Camera.CFrame = Camera.CFrame:Lerp(desired, alpha)
    end)

    local function silentAimPart()
        local ft = getgenv().ForceHitTarget
        if ft and ft.Character and not getgenv().isKO(ft) then
            local fp = ft.Character:FindFirstChild(ov('LegitPart') or 'Head')
            if fp then return fp end
        end
        local _, part = legitClosest()
        return part
    end
    getgenv().LegitSilentPart = silentAimPart

    local hooked = pcall(function()
        local mainEvent = getgenv().MainEvent
        local oldNamecall
        oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
            if tv('LegitSilent') then
                local method = getnamecallmethod and getnamecallmethod() or ""
                if self == mainEvent and method == "FireServer" and select(1, ...) == "Shoot" then
                    local shootArgs = select(2, ...)
                    local part = silentAimPart()
                    if part and part.Parent and typeof(shootArgs) == "table" then
                        pcall(function()
                            local pos = part.Position
                            if typeof(shootArgs[1]) == "table" then
                                for i = 1, #shootArgs[1] do
                                    local h = shootArgs[1][i]
                                    if type(h) == "table" then
                                        h.Instance = part
                                        h.Position = pos
                                        h.Normal = pos
                                    end
                                end
                            end
                            if typeof(shootArgs[2]) == "table" then
                                for i = 1, #shootArgs[2] do
                                    local pd = shootArgs[2][i]
                                    if type(pd) == "table" then
                                        pd.thePart = part
                                    end
                                end
                            end
                        end)
                    end
                end
            end
            return oldNamecall(self, ...)
        end)
        getgenv().LizardOldNamecall = oldNamecall
    end)
    if not hooked then
        warn("[Lizard] Silent aim hook unavailable on this executor")
    end
end

do
    local ESP_FONT = 2
    local ESP_UPDATE_INTERVAL = 1 / 30

    local Camera = getgenv().Camera
    local Players = getgenv().Players
    local LocalPlayer = getgenv().LocalPlayer
    local RunService = getgenv().RunService
    local GuiService = game:GetService("GuiService")
    local guiInset = GuiService:GetGuiInset()

    local function mk(class, props)
        local ok, d = pcall(Drawing.new, class)
        if not ok or not d then return nil end
        for k, v in pairs(props) do d[k] = v end
        return d
    end

    local function mkGui(name)
        local gui = Instance.new("ScreenGui")
        gui.Name = name
        gui.ResetOnSpawn = false
        gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        gui.Parent = game.CoreGui
        return gui
    end

    local function mkText(gui)
        local label = Instance.new("TextLabel")
        label.Name = "Text"
        label.Parent = gui
        label.BackgroundTransparency = 1
        label.BorderSizePixel = 0
        label.Size = UDim2.new(0, 4, 0, 4)
        label.AutomaticSize = Enum.AutomaticSize.XY
        label.TextColor3 = Color3.fromRGB(255, 255, 255)
        label.TextStrokeTransparency = 0
        label.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        label.TextSize = 10
        label.Font = Enum.Font.Code
        label.RichText = false
        label.Visible = false
        label.ZIndex = 50
        return label
    end

    local function mkBar(guiName)
        local gui = mkGui(guiName)
        local outline = Instance.new("Frame")
        outline.Name = "Outline"
        outline.Parent = gui
        outline.BackgroundColor3 = Color3.new(0, 0, 0)
        outline.BorderSizePixel = 0
        outline.Visible = false
        outline.ZIndex = 20

        local fill = Instance.new("Frame")
        fill.Name = "Fill"
        fill.Parent = outline
        fill.BackgroundTransparency = 0
        fill.BorderSizePixel = 0
        fill.Visible = false
        fill.ZIndex = 21

        local gradient = Instance.new("UIGradient")
        gradient.Rotation = 90
        gradient.Parent = fill

        return {
            Gui = gui,
            Outline = outline,
            Frame = fill,
            Gradient = gradient,
            LastValue = nil,
        }
    end

    local cache = {}
    local espAccumulator = 0
    local espWasEnabled = false

    local function buildObj()
        local o = {}
        o.boxOutline = mk("Square", { Thickness = 1, Filled = false, Transparency = 1, Color = Color3.new(0, 0, 0), Visible = false, ZIndex = 8 })
        o.box        = mk("Square", { Thickness = 2, Filled = false, Transparency = 1, Color = Color3.new(1, 1, 1), Visible = false, ZIndex = 9 })
        o.boxInline  = mk("Square", { Thickness = 1, Filled = false, Transparency = 1, Color = Color3.new(0, 0, 0), Visible = false, ZIndex = 8 })
        o.corners = {}
        for i = 1, 8 do
            o.corners[i] = mk("Line", { Thickness = 1, Transparency = 1, Color = Color3.new(1, 1, 1), Visible = false, ZIndex = 9 })
        end

        o.fillGui = mkGui("LizardESPFill")
        o.fill = Instance.new("Frame")
        o.fill.Name = "Fill"
        o.fill.Parent = o.fillGui
        o.fill.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        o.fill.BorderSizePixel = 0
        o.fill.Visible = false
        o.fill.ZIndex = 1

        o.fillGradient = Instance.new("UIGradient")
        o.fillGradient.Name = "Gradient"
        o.fillGradient.Rotation = 90
        o.fillGradient.Parent = o.fill

        o.nameGui = mkGui("LizardESPName")
        o.name = mkText(o.nameGui)
        o.studsGui = mkGui("LizardESPStuds")
        o.studs = mkText(o.studsGui)
        o.toolGui = mkGui("LizardESPTool")
        o.tool = mkText(o.toolGui)

        o.hpBar = mkBar("LizardESPHealth")
        return o
    end

    local function eachDrawing(o, fn)
        fn(o.boxOutline)
        fn(o.box)
        fn(o.boxInline)
        for _, d in ipairs(o.corners or {}) do fn(d) end
    end

    local function hide(o)
        eachDrawing(o, function(d) if d then d.Visible = false end end)
        if o.fill then o.fill.Visible = false end
        if o.name then o.name.Visible = false end
        if o.studs then o.studs.Visible = false end
        if o.tool then o.tool.Visible = false end
        if o.hpBar then
            o.hpBar.Outline.Visible = false
            o.hpBar.Frame.Visible = false
        end
    end

    local function destroyObj(o)
        eachDrawing(o, function(d) if d then pcall(function() d:Remove() end) end end)
        local guis = {
            o.fillGui, o.nameGui, o.studsGui, o.toolGui,
            o.hpBar and o.hpBar.Gui,
        }
        for _, gui in ipairs(guis) do
            if gui then
                pcall(function() gui:Destroy() end)
            end
        end
    end

    local function getObj(plr)
        local o = cache[plr]
        if not o then o = buildObj() cache[plr] = o end
        return o
    end

    local function tv(name) local t = Toggles[name] return t and t.Value end
    local function ov(name) local o = Options[name] return o and o.Value end

    local function getEspConfig()
        return getgenv().Config and getgenv().Config.ESP
    end

    local function getArmor(char, hum)
        local names = { "Armor", "Shield", "Stamina" }
        for _, n in ipairs(names) do
            local v = char:FindFirstChild(n)
            if v and v:IsA("ValueBase") then return v.Value, 100 end
            if hum then
                local a = hum:GetAttribute(n)
                if a then return a, 100 end
            end
        end
        local be = char:FindFirstChild("BodyEffects")
        if be then
            for _, n in ipairs(names) do
                local v = be:FindFirstChild(n)
                if v and v:IsA("ValueBase") then return v.Value, 100 end
            end
        end
        return nil
    end

    local ESPGb = getgenv().ESPGb
    local espDefaults = getEspConfig() or {}
    local boxDefaults = espDefaults.Box or {}
    local boxFillDefaults = boxDefaults.Filled or {}
    local boxGradientDefaults = boxFillDefaults.Gradient or {}
    local boxGradientColors = boxGradientDefaults.Color or {}
    local textDefaults = espDefaults.Text or {}
    local nameDefaults = textDefaults.Name or {}
    local studsDefaults = textDefaults.Studs or {}
    local toolDefaults = textDefaults.Tool or {}
    local barsDefaults = espDefaults.Bars or {}
    local healthDefaults = barsDefaults.Health or {}

    ESPGb:AddToggle('ESPBox', { Text = 'Box ESP', Default = boxDefaults.Enable == true })
        :AddColorPicker('ESPBoxColor', { Default = boxDefaults.Color or Color3.fromRGB(255, 255, 255), Title = 'Box Color' })
    ESPGb:AddToggle('ESPShowOnSelf', { Text = 'Show On Self', Default = false })
    ESPGb:AddToggle('ESPBoxFilled', { Text = 'Filled Box', Default = boxFillDefaults.Enable == true })
        :AddColorPicker('ESPGradStart', { Default = boxGradientColors.Start or Color3.fromRGB(255, 255, 255), Title = 'Gradient Start' })
        :AddColorPicker('ESPGradEnd', { Default = boxGradientColors.End or Color3.fromRGB(0, 0, 0), Title = 'Gradient End' })
    ESPGb:AddSlider('ESPFillTransparency', { Text = 'Fill Transparency', Default = boxGradientDefaults.Transparency or 0.5, Min = 0, Max = 1, Rounding = 2 })
    ESPGb:AddToggle('ESPText', { Text = 'Text', Default = textDefaults.Enable ~= false })
    ESPGb:AddToggle('ESPName', { Text = 'Names', Default = nameDefaults.Enable ~= false })
        :AddColorPicker('ESPNameColor', { Default = nameDefaults.Color or Color3.fromRGB(255, 255, 255), Title = 'Name Color' })
    ESPGb:AddToggle('ESPStuds', { Text = 'Distance', Default = studsDefaults.Enable ~= false })
        :AddColorPicker('ESPStudsColor', { Default = studsDefaults.Color or Color3.fromRGB(255, 255, 255), Title = 'Distance Color' })
    ESPGb:AddToggle('ESPTool', { Text = 'Tool', Default = toolDefaults.Enable ~= false })
        :AddColorPicker('ESPToolColor', { Default = toolDefaults.Color or Color3.fromRGB(255, 255, 255), Title = 'Tool Color' })
    ESPGb:AddToggle('ESPHealthBar', { Text = 'Health Bar', Default = barsDefaults.Enable ~= false and healthDefaults.Enable ~= false })
        :AddColorPicker('ESPHealthColor1', { Default = healthDefaults.Color1 or Color3.fromRGB(0, 255, 0), Title = 'Health High' })

    getgenv().ESPConnection = RunService.RenderStepped:Connect(function(dt)
        local function espVisible()
            return tv("ESPBox") or tv("ESPText") or tv("ESPHealthBar")
        end

        if not espVisible() then
            if espWasEnabled then
                if getgenv().ESPCleanup then
                    getgenv().ESPCleanup()
                else
                    for _, o in pairs(cache) do hide(o) end
                end
                espWasEnabled = false
            end
            espAccumulator = 0
            return
        end
        espWasEnabled = true

        espAccumulator = espAccumulator + (dt or 0)
        if espAccumulator < ESP_UPDATE_INTERVAL then
            return
        end
        espAccumulator = 0

        local espCfg = getEspConfig() or {}
        local cfgBox = espCfg.Box or {}
        local cfgFill = cfgBox.Filled or {}
        local cfgGradient = cfgFill.Gradient or {}
        local cfgGradientColors = cfgGradient.Color or {}
        local cfgText = espCfg.Text or {}
        local cfgName = cfgText.Name or {}
        local cfgStuds = cfgText.Studs or {}
        local cfgTool = cfgText.Tool or {}
        local cfgBars = espCfg.Bars or {}
        local cfgHealth = cfgBars.Health or {}

        local teamCheck   = cfgName.Teamcheck ~= false
        local showOnSelf  = tv("ESPShowOnSelf")
        local textMaster  = tv("ESPText")
        local boxOn       = tv("ESPBox")
        local boxType     = cfgBox.Type or "Full"
        local filledOn    = tv("ESPBoxFilled")
        local gradOn      = boxOn
        local nameOn      = tv("ESPName") and textMaster
        local studsOn     = tv("ESPStuds") and textMaster
        local toolOn      = tv("ESPTool") and textMaster
        local hpOn        = tv("ESPHealthBar")
        local hpOutOn     = cfgHealth.ShowOutline == true

        local boxColor    = ov("ESPBoxColor") or cfgBox.Color or Color3.new(1, 1, 1)
        local gradStart   = ov("ESPGradStart") or cfgGradientColors.Start or Color3.new(1, 1, 1)
        local gradEnd     = ov("ESPGradEnd") or cfgGradientColors.End or Color3.new(0, 0, 0)
        local fillColor   = gradStart
        local fillTrans   = ov("ESPFillTransparency") or cfgGradient.Transparency or 0.5
        local nameColor   = ov("ESPNameColor") or cfgName.Color or Color3.new(1, 1, 1)
        local studsColor  = ov("ESPStudsColor") or cfgStuds.Color or Color3.new(1, 1, 1)
        local toolColor   = ov("ESPToolColor") or cfgTool.Color or Color3.new(1, 1, 1)
        local healthColor1 = ov("ESPHealthColor1") or cfgHealth.Color1 or Color3.fromRGB(0, 255, 0)
        local healthColor2 = cfgHealth.Color2 or Color3.fromRGB(255, 255, 0)
        local healthColor3 = cfgHealth.Color3 or Color3.fromRGB(255, 0, 0)

        local camPos = Camera.CFrame.Position
        local seen = {}

        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer or showOnSelf then
                local char = plr.Character
                local hum = char and char:FindFirstChildOfClass("Humanoid")
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                local skip = (plr ~= LocalPlayer) and teamCheck and plr.Team and LocalPlayer.Team and plr.Team == LocalPlayer.Team

                if char and hum and hrp and hum.Health > 0 and not skip then
                    local rootPoint, rootVisible = Camera:WorldToViewportPoint(hrp.Position)
                    if rootPoint.Z <= 0 or not rootVisible then
                        hide(getObj(plr))
                        continue
                    end

                    seen[plr] = true
                    local o = getObj(plr)

                    local cf, size = char:GetBoundingBox()
                    local hx, hy, hz = size.X / 2, size.Y / 2, size.Z / 2
                    local minX, minY = math.huge, math.huge
                    local maxX, maxY = -math.huge, -math.huge
                    local onScreen = false
                    for sx = -1, 1, 2 do for sy = -1, 1, 2 do for sz = -1, 1, 2 do
                        local wp = (cf * CFrame.new(hx * sx, hy * sy, hz * sz)).Position
                        local sp = Camera:WorldToViewportPoint(wp)
                        if sp.Z > 0 then
                            onScreen = true
                            if sp.X < minX then minX = sp.X end
                            if sp.Y < minY then minY = sp.Y end
                            if sp.X > maxX then maxX = sp.X end
                            if sp.Y > maxY then maxY = sp.Y end
                        end
                    end end end

                    if not onScreen then
                        hide(o)
                    else
                        local charSize = (Camera:WorldToViewportPoint(hrp.Position - Vector3.new(0, 1, 0)).Y - Camera:WorldToViewportPoint(hrp.Position + Vector3.new(0, 3, 0)).Y) / 2
                        local boxWidth = math.floor(charSize * 1.5)
                        local boxHeight = math.floor(charSize * 3.2)
                        local bx = math.floor(rootPoint.X - boxWidth / 2)
                        local by = math.floor(rootPoint.Y - boxHeight / 2)
                        local bw = boxWidth
                        local bh = boxHeight
                        local cx = bx + bw / 2

                        if filledOn then
                            o.fill.Visible = true
                            o.fill.Position = UDim2.new(0, bx, 0, by - guiInset.Y)
                            o.fill.Size = UDim2.new(0, bw, 0, bh)
                            o.fill.BackgroundTransparency = math.clamp(fillTrans, 0, 1)
                            o.fill.BackgroundColor3 = fillColor
                            o.fillGradient.Enabled = true
                            o.fillGradient.Color = ColorSequence.new({
                                ColorSequenceKeypoint.new(0, gradStart),
                                ColorSequenceKeypoint.new(1, gradEnd),
                            })
                            o.fillGradient.Rotation = math.sin(tick() * 2) * 180
                        else
                            o.fill.Visible = false
                        end

                        if boxOn and boxType == "Full" then
                            o.boxOutline.Visible = true
                            o.boxOutline.Position = Vector2.new(bx - 1, by - 1)
                            o.boxOutline.Size = Vector2.new(bw + 2, bh + 2)
                            o.boxOutline.Color = Color3.new(0, 0, 0)
                            o.box.Visible = true
                            o.box.Position = Vector2.new(bx, by)
                            o.box.Size = Vector2.new(bw, bh)
                            o.box.Color = boxColor
                            o.boxInline.Visible = true
                            o.boxInline.Position = Vector2.new(bx + 1, by + 1)
                            o.boxInline.Size = Vector2.new(math.max(bw - 2, 0), math.max(bh - 2, 0))
                            o.boxInline.Color = Color3.new(0, 0, 0)
                            for i = 1, 8 do o.corners[i].Visible = false end
                        elseif boxOn and boxType == "Corner" then
                            o.boxOutline.Visible = false
                            o.box.Visible = false
                            o.boxInline.Visible = false
                            local cl = math.clamp(math.min(bw, bh) * 0.25, 6, 20)
                            local idx = 0
                            local function seg(x1, y1, x2, y2)
                                idx = idx + 1
                                local ln = o.corners[idx]
                                ln.Visible = true
                                ln.From = Vector2.new(x1, y1)
                                ln.To = Vector2.new(x2, y2)
                                ln.Color = boxColor
                            end
                            seg(bx, by, bx + cl, by);                   seg(bx, by, bx, by + cl)
                            seg(bx + bw, by, bx + bw - cl, by);         seg(bx + bw, by, bx + bw, by + cl)
                            seg(bx, by + bh, bx + cl, by + bh);         seg(bx, by + bh, bx, by + bh - cl)
                            seg(bx + bw, by + bh, bx + bw - cl, by + bh); seg(bx + bw, by + bh, bx + bw, by + bh - cl)
                        else
                            o.boxOutline.Visible = false
                            o.box.Visible = false
                            o.boxInline.Visible = false
                            for i = 1, 8 do o.corners[i].Visible = false end
                        end

                        if nameOn then
                            o.name.Visible = true
                            o.name.Text = plr.Name
                            o.name.TextColor3 = nameColor
                            o.name.Position = UDim2.new(0, math.floor(cx - (o.name.TextBounds.X / 2)), 0, math.floor(by - guiInset.Y - 9))
                        else
                            o.name.Visible = false
                        end

                        if studsOn then
                            local dist = (camPos - hrp.Position).Magnitude
                            local meters = dist * 0.28
                            o.studs.Visible = true
                            o.studs.Text = string.format("[%.0fm]", meters)
                            o.studs.TextColor3 = studsColor
                            o.studs.Position = UDim2.new(0, math.floor(cx - (o.studs.TextBounds.X / 2)), 0, math.floor(by - guiInset.Y + bh + 2))
                        else
                            o.studs.Visible = false
                        end

                        if toolOn then
                            local tool = char:FindFirstChildOfClass("Tool")
                            o.tool.Visible = true
                            o.tool.Text = tool and tool.Name or "NONE"
                            o.tool.TextColor3 = toolColor
                            o.tool.Position = UDim2.new(0, math.floor(cx - (o.tool.TextBounds.X / 2)), 0, math.floor(by - guiInset.Y + bh + (studsOn and 14 or 2)))
                        else
                            o.tool.Visible = false
                        end

                        if hpOn then
                            local targetFrac = math.clamp(hum.Health / (hum.MaxHealth > 0 and hum.MaxHealth or 100), 0, 1)
                            local lastFrac = o.hpBar.LastValue or targetFrac
                            local frac = lastFrac + (targetFrac - lastFrac) * 0.05
                            o.hpBar.LastValue = frac
                            local barX = bx - 7
                            o.hpBar.Outline.Visible = true
                            o.hpBar.Outline.Position = UDim2.new(0, barX - 1, 0, by - guiInset.Y - 1)
                            o.hpBar.Outline.Size = UDim2.new(0, 5, 0, bh + 2)
                            o.hpBar.Outline.BackgroundTransparency = hpOutOn and 0.2 or 1
                            o.hpBar.Frame.Visible = true
                            o.hpBar.Frame.Position = UDim2.new(0, 1, 0, (1 - frac) * bh + 1)
                            o.hpBar.Frame.Size = UDim2.new(0, 3, 0, frac * bh)
                            o.hpBar.Gradient.Color = ColorSequence.new({
                                ColorSequenceKeypoint.new(0, healthColor1),
                                ColorSequenceKeypoint.new(0.5, healthColor2),
                                ColorSequenceKeypoint.new(1, healthColor3),
                            })
                        else
                            o.hpBar.Outline.Visible = false
                            o.hpBar.Frame.Visible = false
                        end

                    end
                end
            end
        end

        for plr, o in pairs(cache) do
            if not seen[plr] then hide(o) end
        end
    end)

    Players.PlayerRemoving:Connect(function(plr)
        local o = cache[plr]
        if o then destroyObj(o) cache[plr] = nil end
    end)

    getgenv().ESPCleanup = function()
        for plr, o in pairs(cache) do destroyObj(o) cache[plr] = nil end
        espWasEnabled = false
    end
end

do
    local Players = getgenv().Players
    local LocalPlayer = getgenv().LocalPlayer
    local RunService = getgenv().RunService

    local KnifeGb = getgenv().KnifeGb
    KnifeGb:AddToggle('KnifeHitbox', { Text = 'hitbox expander for knife', Default = false })
    KnifeGb:AddToggle('KnifeHitboxVis', { Text = 'hitbox visualizer', Default = false })
    KnifeGb:AddToggle('KnifeAutoSwing', { Text = 'auto swing knife', Default = false })
    KnifeGb:AddToggle('KnifeGlue', { Text = 'glue connection', Default = false })
        :AddKeyPicker('KnifeGlueKey', { Default = 'G', Mode = 'Toggle', Text = 'Glue', SyncToggleState = true, NoUI = false })
    KnifeGb:AddDropdown('KnifeAttachPos', { Text = 'Attach Position', Default = 'HumanoidRootPart', Values = { 'HumanoidRootPart', 'UpperTorso', 'LowerTorso', 'Head', 'Torso' } })
    KnifeGb:AddSlider('KnifeDistance', { Text = 'Distance', Default = 3, Min = 0, Max = 20, Rounding = 0 })
    KnifeGb:AddSlider('KnifeMaxConn', { Text = 'Max Connection Distance', Default = 100, Min = 0, Max = 500, Rounding = 0 })
    KnifeGb:AddSlider('KnifeMinHealth', { Text = 'Minimum Target Health', Default = 0, Min = 0, Max = 100, Rounding = 0 })
    KnifeGb:AddToggle('KnifeTargetStatus', { Text = 'target status', Default = false })
    KnifeGb:AddDropdown('KnifeSelectPlayer', { SpecialType = 'Player', Text = 'Select Player' })
    KnifeGb:AddToggle('KnifeStomp', { Text = 'auto stomp target', Default = false })

    local function tv(n) local t = Toggles[n] return t and t.Value end
    local function ov(n) local o = Options[n] return o and o.Value end

    local HITBOX_SIZE = Vector3.new(50, 50, 50)

    local function findKnife(parent)
        if not parent then return nil end
        for _, t in ipairs(parent:GetChildren()) do
            if t:IsA('Tool') and string.lower(t.Name) == '[knife]' then return t end
        end
    end

    local function getKnifeHitbox()
        local knife = findKnife(LocalPlayer.Character) or findKnife(LocalPlayer:FindFirstChild('Backpack'))
        if not knife then return nil end
        local handle = knife:FindFirstChild('Handle')
        local hb = handle and handle:FindFirstChild('HITBOX_PART')
        if hb and hb:IsA('BasePart') then return hb end
        return nil
    end

    task.spawn(function()
        while task.wait(0.1) do
            if getgenv().LizardGen ~= lizardGen then break end
            local hb = getKnifeHitbox()
            if hb then
                if tv('KnifeHitbox') then
                    if hb:GetAttribute('LizardOrigSize') == nil then
                        hb:SetAttribute('LizardOrigSize', hb.Size)
                        hb:SetAttribute('LizardOrigCanCollide', hb.CanCollide)
                    end
                    hb.Size = HITBOX_SIZE
                    hb.CanCollide = false
                else
                    local orig = hb:GetAttribute('LizardOrigSize')
                    if typeof(orig) == 'Vector3' then hb.Size = orig end
                    local occ = hb:GetAttribute('LizardOrigCanCollide')
                    if typeof(occ) == 'boolean' then hb.CanCollide = occ end
                end
                if tv('KnifeHitboxVis') and tv('KnifeHitbox') then
                    hb.Transparency = 0.6
                    hb.Material = Enum.Material.ForceField
                    hb.Color = Color3.fromRGB(0, 170, 255)
                else
                    hb.Transparency = 1
                end
            end
        end
    end)

    local function getTargetPart()
        local name = ov('KnifeSelectPlayer')
        local plr = (name and name ~= '' and Players:FindFirstChild(name)) or getgenv().ForceHitTarget
        if not plr or plr == LocalPlayer then return nil end
        local char = plr.Character
        if not char then return nil end
        local hum = char:FindFirstChildOfClass('Humanoid')
        if hum and hum.Health <= 0 then return nil end
        local minHp = ov('KnifeMinHealth') or 0
        if hum and minHp > 0 and hum.Health < minHp then return nil end
        return char:FindFirstChild(ov('KnifeAttachPos') or 'HumanoidRootPart') or char:FindFirstChild('HumanoidRootPart')
    end

    local function getTargetPlayer()
        local name = ov('KnifeSelectPlayer')
        local plr = (name and name ~= '' and Players:FindFirstChild(name)) or getgenv().ForceHitTarget
        if not plr or plr == LocalPlayer then return nil end
        local char = plr.Character
        if not char then return nil end
        local hum = char:FindFirstChildOfClass('Humanoid')
        if hum and hum.Health <= 0 then return nil end
        return plr
    end

    local function targetIsDown()
        local plr = getTargetPlayer()
        if not plr or not plr.Character then return false end
        local body = plr.Character:FindFirstChild('BodyEffects')
        local ko = body and body:FindFirstChild('K.O') and body['K.O'].Value
        local sdeath = body and body:FindFirstChild('SDeath') and body['SDeath'].Value
        return (ko and not sdeath) == true
    end

    local function equipKnife()
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass('Humanoid')
        if not hum then return nil end
        local knife = findKnife(char)
        if knife then return knife end
        local bpKnife = findKnife(LocalPlayer:FindFirstChild('Backpack'))
        if bpKnife then
            pcall(function() hum:EquipTool(bpKnife) end)
            return char:FindFirstChild(bpKnife.Name) or bpKnife
        end
        return nil
    end

    task.spawn(function()
        while task.wait(0.05) do
            if getgenv().LizardGen ~= lizardGen then break end
            if tv('KnifeAutoSwing') and not (tv('KnifeStomp') and targetIsDown()) then
                local knife = equipKnife()
                local target = getTargetPart()
                local char = LocalPlayer.Character
                local root = char and char:FindFirstChild('HumanoidRootPart')
                if target and root then
                    pcall(function()
                        local owner = getnetworkowner and getnetworkowner(root)
                        if not owner or owner ~= LocalPlayer then
                            root:SetNetworkOwner(LocalPlayer)
                        end
                    end)
                    local dist = ov('KnifeDistance') or 3
                    local targetPos = target.Position
                    local dir = (root.Position - targetPos)
                    dir = (dir.Magnitude > 0.1) and dir.Unit or Vector3.new(0, 0, 1)
                    pcall(function()
                        root.CFrame = CFrame.lookAt(targetPos + dir * dist, targetPos)
                        root.AssemblyLinearVelocity = Vector3.zero
                    end)
                end
                if knife then pcall(function() knife:Activate() end) end
            else
                task.wait(0.1)
            end
        end
    end)

    task.spawn(function()
        while task.wait(0.1) do
            if getgenv().LizardGen ~= lizardGen then break end
            if not (tv('KnifeStomp') and targetIsDown()) then continue end
            local plr = getTargetPlayer()
            if not plr or not plr.Character then continue end

            getgenv().isCurrentlyStomping = true
            local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild('HumanoidRootPart')
            local torso = plr.Character:FindFirstChild('UpperTorso') or plr.Character:FindFirstChild('Torso')
            if myRoot and torso then
                pcall(function() myRoot.CFrame = CFrame.new(torso.Position + Vector3.new(0, 3, 0)) end)
            end
            getgenv().MainEvent:FireServer('Stomp')
            getgenv().isCurrentlyStomping = false
        end
    end)

    local function glueTarget()
        local part = getTargetPart()
        if not part then return nil end
        local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild('HumanoidRootPart')
        local maxConn = ov('KnifeMaxConn') or 0
        if myRoot and maxConn > 0 and (part.Position - myRoot.Position).Magnitude > maxConn then return nil end
        return part
    end

    getgenv().KnifeGlueConn = RunService.Heartbeat:Connect(function()
        if not tv('KnifeGlue') then return end
        if not sethiddenproperty then return end
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass('Humanoid')
        local root = hum and hum.RootPart
        if not root then return end
        local target = glueTarget()
        pcall(function() sethiddenproperty(root, "PhysicsRepRootPart", target) end)
    end)

    if Toggles.KnifeGlue then
        Toggles.KnifeGlue:OnChanged(function()
            if not Toggles.KnifeGlue.Value then
                if sethiddenproperty then
                    local char = LocalPlayer.Character
                    local hum = char and char:FindFirstChildOfClass('Humanoid')
                    local root = hum and hum.RootPart
                    if root then pcall(function() sethiddenproperty(root, "PhysicsRepRootPart", nil) end) end
                end
                local hb = getKnifeHitbox()
                if hb then
                    local orig = hb:GetAttribute('LizardOrigSize')
                    if typeof(orig) == 'Vector3' then hb.Size = orig end
                    hb.Transparency = 1
                end
            end
        end)
    end
end

getgenv().SaveManager:SetLibrary(getgenv().Library)
getgenv().ThemeManager:SetLibrary(getgenv().Library)
getgenv().ThemeManager:SetFolder('ghosted')
getgenv().SaveManager:BuildConfigSection(getgenv().Tabs.Settings)
getgenv().ThemeManager:ApplyToTab(getgenv().Tabs.Settings)
getgenv().SaveManager:SetFolder('ghosted/config')

if Options.AccentColor then
    pcall(function()
        Options.AccentColor:SetValueRGB(Color3.fromRGB(162, 193, 255))
    end)
end

getgenv().Library.ToggleKeybind = Options.MenuKeybind

if Options.NotifPos then
    Options.NotifPos:OnChanged(function() getgenv().UpdateNotifPosition(Options.NotifPos.Value) end)
end

if Toggles.visualizestrafe then
    Toggles.visualizestrafe:OnChanged(function()
        if Toggles.visualizestrafe.Value and getgenv().StrafeConnection then getgenv().createStrafeVisualizer() else getgenv().destroyStrafeVisualizer() end
    end)
end

if Toggles.SpectateTarget then
    Toggles.SpectateTarget:OnChanged(function()
        if (Toggles.SpectateTarget and Toggles.SpectateTarget.Value) then getgenv().startSpectate() else
            if getgenv().SpectateConnection then getgenv().SpectateConnection:Disconnect() getgenv().SpectateConnection = nil end
            getgenv().resetStrafeCamera()
        end
    end)
end

getgenv().SaveManager:IgnoreThemeSettings()
getgenv().SaveManager:SetIgnoreIndexes({})
getgenv().SaveManager:LoadAutoloadConfig()
end
