-- Notification Library by YourName
-- GitHub: https://github.com/yourusername/your-repo
-- Usage: 
-- local NotificationLibrary = loadstring(game:HttpGet("https://raw.githubusercontent.com/yourusername/your-repo/main/notificationlib.lua"))()
-- NotificationLibrary.Notifications:New("Hello World!", 3, Color3.fromRGB(0, 255, 0))

local NotificationLibrary = {Notifications = {}}

do
    local Utility = {}
    local ActiveNotifications = {}
    
    -- Create screen GUI
    local NotificationContainer = Instance.new("ScreenGui")
    NotificationContainer.Name = "NotificationContainer"
    NotificationContainer.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    NotificationContainer.Parent = game:GetService("CoreGui") or (gethui and gethui()) or game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")

    -- Utility functions
    function Utility:Tween(instance, tweenInfo, properties)
        local tween = game:GetService("TweenService"):Create(instance, tweenInfo, properties)
        tween:Play()
        return tween
    end

    -- Calculate required width for text
    local function GetTextWidth(text, font, size)
        local textService = game:GetService("TextService")
        local parameters = Font.fromEnum(font or Enum.Font.Ubuntu)
        parameters.Size = size or 12
        local bounds = textService:GetTextSize(text, size, font, Vector2.new(10000, 10000))
        return bounds.X
    end

    -- Notification functions
    function NotificationLibrary.Notifications:UpdatePositions()
        local i = 0
        for _, notification in ipairs(ActiveNotifications) do
            if notification and notification.Holder and notification.Holder.Parent then
                Utility:Tween(notification.Holder, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                    Position = UDim2.new(0, 20, 0, 75 + (i * 25))
                })
                i = i + 1
            end
        end
    end

    function NotificationLibrary.Notifications:FadeOut(notification)
        for _, v in pairs(notification) do
            if typeof(v) == "Instance" then
                if v:IsA("Frame") then
                    Utility:Tween(v, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                        BackgroundTransparency = 1
                    })
                elseif v:IsA("TextLabel") then
                    Utility:Tween(v, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                        TextTransparency = 1
                    })
                end
            end
        end
    end

    function NotificationLibrary.Notifications:New(Text, Time, Color)
        -- Default values
        Time = Time or 3
        Color = Color or Color3.fromRGB(100, 95, 192)
        Text = tostring(Text or "Notification")
        
        -- Calculate required width before creating elements
        local textWidth = GetTextWidth(Text, Enum.Font.Ubuntu, 12)
        local minWidth = math.max(textWidth + 24, 150) -- Minimum width of 150 or text width + padding
        
        -- Create notification table
        local Notification = {}
        
        -- Create holder frame
        local Holder = Instance.new("Frame")
        Holder.Name = "Holder"
        Holder.Position = UDim2.new(0, -minWidth, 0, 75) -- Start offscreen
        Holder.Size = UDim2.new(0, minWidth, 0, 23)
        Holder.BackgroundTransparency = 0
        Holder.BackgroundColor3 = Color3.fromRGB(37, 37, 37)
        Holder.BorderSizePixel = 0
        Holder.ClipsDescendants = true
        Holder.Parent = NotificationContainer
        
        -- Create background frame
        local Background = Instance.new("Frame")
        Background.Name = "Background"
        Background.Size = UDim2.new(1, -4, 1, -4)
        Background.Position = UDim2.new(0, 2, 0, 2)
        Background.BackgroundColor3 = Color3.fromRGB(17, 17, 17)
        Background.BorderSizePixel = 0
        Background.Parent = Holder
        
        -- Create accent bar
        local AccentBar = Instance.new("Frame")
        AccentBar.Name = "AccentBar"
        AccentBar.Size = UDim2.new(0, 2, 1, 0)
        AccentBar.Position = UDim2.new(0, 0, 0, 0)
        AccentBar.BackgroundColor3 = Color
        AccentBar.BorderSizePixel = 0
        AccentBar.Parent = Background
        
        -- Create progress bar
        local ProgressBar = Instance.new("Frame")
        ProgressBar.Name = "ProgressBar"
        ProgressBar.Size = UDim2.new(0, 0, 0, 1)
        ProgressBar.Position = UDim2.new(0, 0, 0, Background.AbsoluteSize.Y - 2)
        ProgressBar.BackgroundColor3 = Color
        ProgressBar.BorderSizePixel = 0
        ProgressBar.Parent = Background
        
        -- Create text label with text constraints
        local TextLabel = Instance.new("TextLabel")
        TextLabel.Name = "TextLabel"
        TextLabel.TextXAlignment = Enum.TextXAlignment.Left
        TextLabel.Position = UDim2.new(0, 8, 0, 0)
        TextLabel.Size = UDim2.new(1, -8, 1, 0)
        TextLabel.Font = Enum.Font.Ubuntu
        TextLabel.Text = Text
        TextLabel.TextColor3 = Color3.new(1, 1, 1)
        TextLabel.TextSize = 12
        TextLabel.BackgroundTransparency = 1
        TextLabel.TextTransparency = 0
        TextLabel.TextWrapped = false
        TextLabel.TextTruncate = Enum.TextTruncate.AtEnd
        TextLabel.Parent = Background
        
        -- Store references
        Notification.Holder = Holder
        Notification.Background = Background
        Notification.AccentBar = AccentBar
        Notification.ProgressBar = ProgressBar
        Notification.TextLabel = TextLabel
        
        -- Add to active notifications
        table.insert(ActiveNotifications, Notification)
        
        -- Define remove function
        function Notification:Remove()
            for i, notif in ipairs(ActiveNotifications) do
                if notif == self then
                    table.remove(ActiveNotifications, i)
                    break
                end
            end
            NotificationLibrary.Notifications:UpdatePositions()
            
            -- Fade out animation
            NotificationLibrary.Notifications:FadeOut(self)
            
            -- Destroy after animation
            task.delay(0.5, function()
                if self.Holder and self.Holder.Parent then
                    self.Holder:Destroy()
                end
            end)
        end
        
        -- Slide in animation
        Utility:Tween(Holder, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Position = UDim2.new(0, 20, 0, Holder.Position.Y.Offset)
        })
        
        -- Update all notification positions
        NotificationLibrary.Notifications:UpdatePositions()
        
        -- Progress bar animation
        Utility:Tween(ProgressBar, TweenInfo.new(Time, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
            Size = UDim2.new(1, 0, 0, 1)
        })
        
        -- Auto-remove after time
        task.delay(Time, function()
            if Notification.Remove then
                Notification:Remove()
            end
        end)
        
        return Notification
    end
end

return NotificationLibrary
