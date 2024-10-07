local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

getgenv().Settings = {
    AutoType = true,
    AutoJoin = true,
    LongWords = false,
    breakscript = false,
    TypeTime = 2
}

-- Load Words from online source
local Words = {}
local Response = game:HttpGet("https://raw.githubusercontent.com/98x9s9xs9xs9x9sx9asx9s9xgf324432442342r/SmoxAve/main/Smox-Words.txt")
for line in string.gmatch(Response,"[^\r\n]*") do
    if line ~= "" then
        table.insert(Words, line)
    end
end

local LongWords = {}
local ResponseLong = game:HttpGet("https://raw.githubusercontent.com/98x9s9xs9xs9x9sx9asx9s9xgf324432442342r/SmoxAve/main/Smox-Long-Words.txt")
for line in string.gmatch(ResponseLong,"[^\r\n]*") do
    if line ~= "" then
        table.insert(LongWords, line)
    end
end

-- UI Elements
local ScreenGui = Instance.new("ScreenGui", PlayerGui)
local Frame = Instance.new("Frame", ScreenGui)
Frame.Size = UDim2.new(0, 400, 0, 300)
Frame.Position = UDim2.new(0.5, -200, 0.5, -150)
Frame.BackgroundColor3 = Color3.fromRGB(41, 74, 122)

-- Title Label
local TitleLabel = Instance.new("TextLabel", Frame)
TitleLabel.Size = UDim2.new(1, 0, 0, 50)
TitleLabel.Position = UDim2.new(0, 0, 0, 0)
TitleLabel.Text = "Word Bomb Script"
TitleLabel.TextScaled = true
TitleLabel.BackgroundColor3 = Color3.fromRGB(23, 0, 1)
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)

-- Toggle AutoType
local AutoTypeButton = Instance.new("TextButton", Frame)
AutoTypeButton.Size = UDim2.new(0.8, 0, 0, 50)
AutoTypeButton.Position = UDim2.new(0.1, 0, 0.2, 0)
AutoTypeButton.Text = "Auto Type: " .. tostring(Settings.AutoType)
AutoTypeButton.TextScaled = true
AutoTypeButton.BackgroundColor3 = Color3.fromRGB(44, 13, 19)
AutoTypeButton.TextColor3 = Color3.fromRGB(255, 255, 255)

AutoTypeButton.MouseButton1Click:Connect(function()
    Settings.AutoType = not Settings.AutoType
    AutoTypeButton.Text = "Auto Type: " .. tostring(Settings.AutoType)
end)

-- Toggle AutoJoin
local AutoJoinButton = Instance.new("TextButton", Frame)
AutoJoinButton.Size = UDim2.new(0.8, 0, 0, 50)
AutoJoinButton.Position = UDim2.new(0.1, 0, 0.4, 0)
AutoJoinButton.Text = "Auto Join: " .. tostring(Settings.AutoJoin)
AutoJoinButton.TextScaled = true
AutoJoinButton.BackgroundColor3 = Color3.fromRGB(44, 13, 19)
AutoJoinButton.TextColor3 = Color3.fromRGB(255, 255, 255)

AutoJoinButton.MouseButton1Click:Connect(function()
    Settings.AutoJoin = not Settings.AutoJoin
    AutoJoinButton.Text = "Auto Join: " .. tostring(Settings.AutoJoin)
end)

-- Slider for Type Time
local TypeTimeSlider = Instance.new("TextButton", Frame)
TypeTimeSlider.Size = UDim2.new(0.8, 0, 0, 50)
TypeTimeSlider.Position = UDim2.new(0.1, 0, 0.6, 0)
TypeTimeSlider.Text = "Type Time: " .. tostring(Settings.TypeTime)
TypeTimeSlider.TextScaled = true
TypeTimeSlider.BackgroundColor3 = Color3.fromRGB(44, 13, 19)
TypeTimeSlider.TextColor3 = Color3.fromRGB(255, 255, 255)

TypeTimeSlider.MouseButton1Click:Connect(function()
    Settings.TypeTime = (Settings.TypeTime % 6) + 1
    TypeTimeSlider.Text = "Type Time: " .. tostring(Settings.TypeTime)
end)

-- Word Finding and Typing Logic
local Used = {}

function CanType()
    local GameSpace = PlayerGui.GameUI.Container.GameSpace
    if GameSpace:FindFirstChild("DefaultUI") and GameSpace.DefaultUI:FindFirstChild("GameContainer") and GameSpace.DefaultUI.GameContainer:FindFirstChild("DesktopContainer") then
        return GameSpace.DefaultUI.GameContainer.DesktopContainer.Typebar.Typebox.Visible
    end
    return false
end

function FindWord(Pattern)
    local total = {}
    local WordSource = Settings.LongWords and LongWords or Words
    for _, Word in next, WordSource do
        if string.find(Word, Pattern) and not table.find(Used, Word) then
            table.insert(total, Word)
        end
    end
    local theword = total[math.random(1, #total)]
    table.insert(Used, theword)
    return theword
end

function Type(Word)
    local Typebox = PlayerGui.GameUI.Container.GameSpace.DefaultUI.GameContainer.DesktopContainer.Typebar.Typebox
    local WaitTime = (Settings.TypeTime / 3) / 10
    for _, Letter in next, string.split(Word, "") do
        Typebox.Text ..= Letter
        wait(WaitTime)
    end
    firesignal(Typebox.FocusLost, true)
end

function AutoTypeWord()
    if CanType() and Settings.AutoType then
        local Pattern = GetCurrentPattern()
        local Word = FindWord(string.lower(Pattern))
        if Word then
            Type(Word)
        end
    end
end

-- Rejoin Button
local RejoinButton = Instance.new("TextButton", Frame)
RejoinButton.Size = UDim2.new(0.8, 0, 0, 50)
RejoinButton.Position = UDim2.new(0.1, 0, 0.8, 0)
RejoinButton.Text = "Rejoin Server"
RejoinButton.TextScaled = true
RejoinButton.BackgroundColor3 = Color3.fromRGB(44, 13, 19)
RejoinButton.TextColor3 = Color3.fromRGB(255, 255, 255)

RejoinButton.MouseButton1Click:Connect(function()
    TeleportService:Teleport(game.PlaceId, LocalPlayer)
end)

-- Run the auto-type logic continuously
while wait(1) do
    if Settings.AutoType then
        AutoTypeWord()
    end
end
