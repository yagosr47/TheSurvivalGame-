-- ==========================================
-- THE SURVIVAL GAME: GOD HUB V18 (FINAL)
-- ==========================================

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local StarterGui = game:GetService("StarterGui")
local player = Players.LocalPlayer
local mouse = player:GetMouse()

-- ==========================================
-- CONFIGURAÇÕES GLOBAIS E ESTADOS
-- ==========================================
local minimizado = false
local corTema = Color3.fromRGB(40, 200, 100) -- Verde TSG

-- Estados de Ativação
local aimbotAtivado, aimbotModoMouse, aimbotAuto = false, true, true 
local isAimingInput = false
local espPlayersAtivado, espMineriosAtivado = false, false
local noclipAtivado, puloInfinitoAtivado, semDanoQuedaAtivado = false, false, false
local hitboxAtivada, fullbrightAtivado, clickTpAtivado = false, false, false
local invisivel, modoDeus = false, false
local autoFarmNodes, resourceAuraAtivado, killAuraAtivado = false, false, false
local fastSwimAtivado, staminaInfinita, semFomeAtivado, inventarioIlimitado = false, false, false, false
local beybladeAtivado, beybladeObj = false, nil
local indexSpec = 1
local velocidadeAtual, puloAtual = 16, 50

-- Conexões de Loop
local aimbotConn, noclipConn, hitboxConn, noFallConn, espConn, espMinConn
local godModeConn, autoFarmConn, auraConn, resConn, swimConn

-- ==========================================
-- 1. CRIAÇÃO DA INTERFACE BASE (COMPACTA)
-- ==========================================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "TSG_God_Hub_V18"
screenGui.ResetOnSpawn = false
local success, _ = pcall(function() screenGui.Parent = CoreGui end)
if not success then screenGui.Parent = player:WaitForChild("PlayerGui") end

local mainFrame = Instance.new("Frame", screenGui)
mainFrame.Size = UDim2.new(0, 420, 0, 380); mainFrame.Position = UDim2.new(0.5, -210, 0.5, -190)
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20); mainFrame.BorderSizePixel = 0
mainFrame.Active = true; mainFrame.Draggable = true
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 12)
local mainStroke = Instance.new("UIStroke", mainFrame); mainStroke.Thickness = 2; mainStroke.Color = corTema

local titleBar = Instance.new("Frame", mainFrame)
titleBar.Size = UDim2.new(1, 0, 0, 35); titleBar.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Instance.new("UICorner", titleBar).CornerRadius = UDim.new(0, 12)

local titleText = Instance.new("TextLabel", titleBar)
titleText.Size = UDim2.new(0.6, 0, 1, 0); titleText.Position = UDim2.new(0.05, 0, 0, 0)
titleText.BackgroundTransparency = 1; titleText.Text = "TSG GOD HUB V18"; titleText.TextColor3 = Color3.fromRGB(255, 255, 255)
titleText.Font = Enum.Font.GothamBold; titleText.TextSize = 14; titleText.TextXAlignment = Enum.TextXAlignment.Left

local closeBtn = Instance.new("TextButton", titleBar)
closeBtn.Size = UDim2.new(0, 30, 0, 30); closeBtn.Position = UDim2.new(0.9, 0, 0.1, 0); closeBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
closeBtn.Text = "X"; closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255); Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 8)

local minBtn = Instance.new("TextButton", titleBar)
minBtn.Size = UDim2.new(0, 30, 0, 30); minBtn.Position = UDim2.new(0.8, 0, 0.1, 0); minBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
minBtn.Text = "-"; minBtn.TextColor3 = Color3.fromRGB(255, 255, 255); Instance.new("UICorner", minBtn).CornerRadius = UDim.new(0, 8)

-- ==========================================
-- 2. SISTEMA DE 5 ABAS E ROLAGEM
-- ==========================================
local tabBar = Instance.new("Frame", mainFrame)
tabBar.Size = UDim2.new(1, 0, 0, 35); tabBar.Position = UDim2.new(0, 0, 0, 35); tabBar.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
local tabLayout = Instance.new("UIListLayout", tabBar); tabLayout.FillDirection = Enum.FillDirection.Horizontal

local pageContainer = Instance.new("Frame", mainFrame)
pageContainer.Size = UDim2.new(1, 0, 1, -70); pageContainer.Position = UDim2.new(0, 0, 0, 70); pageContainer.BackgroundTransparency = 1

local function criarAba(nome, ordem)
    local btn = Instance.new("TextButton", tabBar)
    btn.Size = UDim2.new(0.2, 0, 1, 0); btn.BackgroundTransparency = 1; btn.Text = nome
    btn.TextColor3 = Color3.fromRGB(200, 200, 200); btn.Font = Enum.Font.GothamSemibold; btn.TextSize = 12; btn.LayoutOrder = ordem
    
    local page = Instance.new("ScrollingFrame", pageContainer)
    page.Size = UDim2.new(1, 0, 1, 0); page.BackgroundTransparency = 1; page.ScrollBarThickness = 4; page.Visible = false
    page.AutomaticCanvasSize = Enum.AutomaticSize.Y; page.CanvasSize = UDim2.new(0, 0, 0, 0)
    local layout = Instance.new("UIListLayout", page); layout.Padding = UDim.new(0, 8); layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    
    return page, btn
end

local pageFarm, tabFarm = criarAba("Farm", 1)
local pageCombat, tabCombat = criarAba("Combate", 2)
local pageMove, tabMove = criarAba("Player", 3)
local pageTroll, tabTroll = criarAba("Trolls", 4)
local pageConfig, tabConfig = criarAba("Interface", 5)

pageFarm.Visible = true; tabFarm.TextColor3 = corTema

local function mudarAba(btnAtivo, pageAtiva)
    for _, btn in pairs(tabBar:GetChildren()) do if btn:IsA("TextButton") then btn.TextColor3 = Color3.fromRGB(200, 200, 200) end end
    for _, pg in pairs(pageContainer:GetChildren()) do if pg:IsA("ScrollingFrame") then pg.Visible = false end end
    btnAtivo.TextColor3 = corTema; pageAtiva.Visible = true
end

tabFarm.MouseButton1Click:Connect(function() mudarAba(tabFarm, pageFarm) end)
tabCombat.MouseButton1Click:Connect(function() mudarAba(tabCombat, pageCombat) end)
tabMove.MouseButton1Click:Connect(function() mudarAba(tabMove, pageMove) end)
tabTroll.MouseButton1Click:Connect(function() mudarAba(tabTroll, pageTroll) end)
tabConfig.MouseButton1Click:Connect(function() mudarAba(tabConfig, pageConfig) end)

-- ==========================================
-- FUNÇÕES DE CRIAÇÃO DE UI
-- ==========================================
local function criarBotao(texto, parent, cor)
    local btn = Instance.new("TextButton", parent)
    btn.Size = UDim2.new(0.9, 0, 0, 35); btn.BackgroundColor3 = cor or Color3.fromRGB(40, 40, 40)
    btn.Text = texto; btn.TextColor3 = Color3.fromRGB(255, 255, 255); btn.Font = Enum.Font.GothamSemibold; btn.TextSize = 13
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
    return btn
end

local function criarDivisoria(texto, parent)
    local txt = Instance.new("TextLabel", parent)
    txt.Size = UDim2.new(0.9, 0, 0, 20); txt.BackgroundTransparency = 1; txt.Text = "--- " .. texto .. " ---"
    txt.TextColor3 = corTema; txt.Font = Enum.Font.GothamBold; txt.TextSize = 12
end

local function criarLinhaEscala(texto, baseValue, parent, isJump)
    local frame = Instance.new("Frame", parent); frame.Size = UDim2.new(0.9, 0, 0, 35); frame.BackgroundTransparency = 1
    local btn = criarBotao(texto, frame); btn.Size = UDim2.new(0.7, 0, 1, 0)
    local input = Instance.new("TextBox", frame); input.Size = UDim2.new(0.25, 0, 1, 0); input.Position = UDim2.new(0.75, 0, 0, 0)
    input.BackgroundColor3 = Color3.fromRGB(30, 30, 30); input.Text = "1"; input.TextColor3 = corTema; input.Font = Enum.Font.GothamBold; input.TextSize = 15
    Instance.new("UICorner", input).CornerRadius = UDim.new(0, 8)
    
    btn.MouseButton1Click:Connect(function()
        local char = player.Character; local valor = tonumber(input.Text) or 1; valor = math.clamp(valor, 1, 10); input.Text = tostring(valor)
        if isJump then puloAtual = baseValue * valor; if char and char:FindFirstChild("Humanoid") then char.Humanoid.UseJumpPower = true; char.Humanoid.JumpPower = puloAtual end
        else velocidadeAtual = baseValue * valor; if char and char:FindFirstChild("Humanoid") then char.Humanoid.WalkSpeed = velocidadeAtual end end
    end)
end

-- Input Mobile/PC
UserInputService.InputBegan:Connect(function(i, gp) if not gp and (i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch) then isAimingInput = true end end)
UserInputService.InputEnded:Connect(function(i, gp) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then isAimingInput = false end end)

-- Auto-Reaplicar Respawn
player.CharacterAdded:Connect(function(char)
    local hum = char:WaitForChild("Humanoid", 3)
    if hum then if velocidadeAtual ~= 16 then hum.WalkSpeed = velocidadeAtual end; if puloAtual ~= 50 then hum.UseJumpPower = true; hum.JumpPower = puloAtual end end
    if invisivel then task.wait(0.5); for _, p in pairs(char:GetDescendants()) do if p:IsA("BasePart") and p.Name ~= "HumanoidRootPart" then p.Transparency = 1 elseif p:IsA("Decal") then p.Transparency = 1 end end end
end)

-- ==========================================
-- ABA 1: FARM E SOBREVIVÊNCIA
-- ==========================================
Instance.new("Frame", pageFarm).Size = UDim2.new(1,0,0,1)

criarDivisoria("Coleta Automática", pageFarm)
local btnAutoFarmNodes = criarBotao("Auto-Ir até Recursos (Pedra/Árvore)", pageFarm, Color3.fromRGB(50, 150, 80))
local btnResAura = criarBotao("Aura de Coleta (Minérios/Madeira)", pageFarm, Color3.fromRGB(50, 100, 150))
local btnEspMinerios = criarBotao("Localizar Minérios (ESP Ouro/Ferro)", pageFarm, Color3.fromRGB(200, 150, 0))

criarDivisoria("Sobrevivência do Jogador", pageFarm)
local btnStamina = criarBotao("Estamina Infinita", pageFarm)
local btnFome = criarBotao("Sem Fome (Travar Barra)", pageFarm)
local btnPeso = criarBotao("Inventário Ilimitado (Sem Peso)", pageFarm, Color3.fromRGB(100, 50, 150))

local function encontrarRecursoProximo()
    local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end; local maisProximo = nil; local menorDist = 150 
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("Model") and (obj.Name:match("Rock") or obj.Name:match("Ore") or obj.Name:match("Tree") or obj.Name:match("Boulder")) then
            local primary = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
            if primary then
                local dist = (primary.Position - hrp.Position).Magnitude
                if dist < menorDist then menorDist = dist; maisProximo = primary end
            end
        end
    end
    return maisProximo
end

btnAutoFarmNodes.MouseButton1Click:Connect(function()
    autoFarmNodes = not autoFarmNodes; btnAutoFarmNodes.Text = autoFarmNodes and "Auto-Ir até Recursos: LIGADO" or "Auto-Ir até Recursos (Pedra/Árvore)"
    if autoFarmNodes then
        autoFarmConn = RunService.RenderStepped:Connect(function()
            task.wait(0.5)
            if autoFarmNodes and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                local recurso = encontrarRecursoProximo()
                if recurso then player.Character.HumanoidRootPart.CFrame = CFrame.new(recurso.Position + Vector3.new(0, 3, 4), recurso.Position) end
            end
        end)
    else if autoFarmConn then autoFarmConn:Disconnect(); autoFarmConn = nil end end
end)

btnResAura.MouseButton1Click:Connect(function()
    resourceAuraAtivado = not resourceAuraAtivado; btnResAura.Text = resourceAuraAtivado and "Aura Coleta: ATIVADA" or "Aura de Coleta (Minérios/Madeira)"
    if resourceAuraAtivado then
        resConn = RunService.RenderStepped:Connect(function()
            local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                for _, obj in pairs(workspace:GetDescendants()) do
                    if obj:IsA("Model") and (obj.Name:match("Ore") or obj.Name:match("Tree") or obj.Name:match("Rock")) then
                        local pPart = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
                        if pPart and (hrp.Position - pPart.Position).Magnitude < 15 then
                            local tool = player.Character:FindFirstChildOfClass("Tool"); if tool then tool:Activate() end
                        end
                    end
                end
            end
        end)
    else if resConn then resConn:Disconnect(); resConn = nil end end
end)

btnEspMinerios.MouseButton1Click:Connect(function()
    espMineriosAtivado = not espMineriosAtivado; btnEspMinerios.Text = espMineriosAtivado and "Localizar Minérios: ATIVADO" or "Localizar Minérios (ESP Ouro/Ferro)"
    if espMineriosAtivado then
        espMinConn = RunService.RenderStepped:Connect(function()
            task.wait(1)
            for _, obj in pairs(workspace:GetDescendants()) do
                if obj:IsA("Model") and (obj.Name:match("Copper") or obj.Name:match("Iron") or obj.Name:match("Steel") or obj.Name:match("Gold")) then
                    local primary = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
                    if primary and not obj:FindFirstChild("OreESP") then
                        local bgui = Instance.new("BillboardGui", obj); bgui.Name = "OreESP"; bgui.Size = UDim2.new(0, 100, 0, 30); bgui.AlwaysOnTop = true
                        local txt = Instance.new("TextLabel", bgui); txt.Size = UDim2.new(1, 0, 1, 0); txt.BackgroundTransparency = 1; txt.Text = obj.Name; txt.TextColor3 = Color3.fromRGB(255, 200, 0); txt.TextStrokeTransparency = 0; txt.Font = Enum.Font.GothamBold
                    end
                end
            end
        end)
    else
        if espMinConn then espMinConn:Disconnect(); espMinConn = nil end
        for _, obj in pairs(workspace:GetDescendants()) do if obj:FindFirstChild("OreESP") then obj.OreESP:Destroy() end end
    end
end)

btnStamina.MouseButton1Click:Connect(function() staminaInfinita = not staminaInfinita; btnStamina.Text = staminaInfinita and "Estamina: INFINITA" or "Estamina Infinita" end)
btnFome.MouseButton1Click:Connect(function() semFomeAtivado = not semFomeAtivado; btnFome.Text = semFomeAtivado and "Sem Fome: ATIVADO" or "Sem Fome (Travar Barra)" end)
btnPeso.MouseButton1Click:Connect(function() inventarioIlimitado = not inventarioIlimitado; btnPeso.Text = inventarioIlimitado and "Inventário: SEM PESO" or "Inventário Ilimitado (Sem Peso)" end)

-- Loop Global de Sobrevivência
RunService.Heartbeat:Connect(function()
    local char = player.Character
    if char and char:FindFirstChild("Humanoid") then
        if staminaInfinita then local s = char:FindFirstChild("Stamina") or player:FindFirstChild("Stamina"); if s and s:IsA("NumberValue") then s.Value = 100 end end
        if semFomeAtivado then local f = player:FindFirstChild("Hunger") or char:FindFirstChild("Hunger"); if f and f:IsA("NumberValue") then f.Value = 100 end end
        if inventarioIlimitado then char.Humanoid.WalkSpeed = velocidadeAtual end -- Ignora peso forçando a velocidade base escolhida
    end
end)

-- ==========================================
-- ABA 2: COMBATE E ESP JOGADORES
-- ==========================================
Instance.new("Frame", pageCombat).Size = UDim2.new(1,0,0,1)

criarDivisoria("Sistemas de Mira e Dano", pageCombat)
local btnAimbot = criarBotao("Ativar Aimbot (Arco/Besta)", pageCombat, Color3.fromRGB(200, 50, 50))
local btnAimbotTrigger = criarBotao("Gatilho Aimbot: Automático", pageCombat, Color3.fromRGB(180, 80, 120))
local btnAimbotMode = criarBotao("Alvo: Mais Próximo da Mira", pageCombat, Color3.fromRGB(150, 50, 100))
local btnKillAura = criarBotao("Kill Aura (Dano em Área)", pageCombat, Color3.fromRGB(150, 50, 50))
local btnHitbox = criarBotao("Expandir Hitbox (Inimigo Gigante)", pageCombat, Color3.fromRGB(200, 100, 50))

criarDivisoria("Rastreamento", pageCombat)
local btnEsp = criarBotao("Ativar ESP (Distância)", pageCombat)

btnAimbotTrigger.MouseButton1Click:Connect(function() aimbotAuto = not aimbotAuto; btnAimbotTrigger.Text = aimbotAuto and "Gatilho Aimbot: Automático" or "Gatilho Aimbot: Segurar Touch/Clique" end)
btnAimbotMode.MouseButton1Click:Connect(function() aimbotModoMouse = not aimbotModoMouse; btnAimbotMode.Text = aimbotModoMouse and "Alvo: Mais Próximo da Mira" or "Alvo: Mais Próximo do Corpo" end)

local function pegarInimigoMaisProximo()
    local alvoMaisProximo = nil; local menorDistancia = math.huge; local camera = workspace.CurrentCamera
    local meuHrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= player and p.Character and p.Character:FindFirstChild("Head") and p.Character:FindFirstChild("Humanoid") and p.Character.Humanoid.Health > 0 then
            if player.Team ~= nil and p.Team ~= nil and player.Team == p.Team then continue end
            if aimbotModoMouse then
                local posTela, naTela = camera:WorldToViewportPoint(p.Character.Head.Position)
                if naTela then
                    local centroTela = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
                    local dist = (Vector2.new(posTela.X, posTela.Y) - centroTela).Magnitude
                    if dist < menorDistancia then menorDistancia = dist; alvoMaisProximo = p.Character.Head end
                end
            else
                if meuHrp and p.Character:FindFirstChild("HumanoidRootPart") then
                    local dist = (p.Character.HumanoidRootPart.Position - meuHrp.Position).Magnitude
                    if dist < menorDistancia then menorDistancia = dist; alvoMaisProximo = p.Character.Head end
                end
            end
        end
    end
    return alvoMaisProximo
end

btnAimbot.MouseButton1Click:Connect(function()
    aimbotAtivado = not aimbotAtivado; btnAimbot.Text = aimbotAtivado and "Aimbot: ATIVADO" or "Ativar Aimbot (Arco/Besta)"
    if aimbotAtivado then 
        aimbotConn = RunService.RenderStepped:Connect(function() 
            if aimbotAuto or isAimingInput or UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
                local alvo = pegarInimigoMaisProximo(); if alvo then workspace.CurrentCamera.CFrame = CFrame.new(workspace.CurrentCamera.CFrame.Position, alvo.Position) end 
            end
        end)
    else if aimbotConn then aimbotConn:Disconnect(); aimbotConn = nil end end
end)

btnKillAura.MouseButton1Click:Connect(function()
    killAuraAtivado = not killAuraAtivado; btnKillAura.Text = killAuraAtivado and "Kill Aura: ATIVADA" or "Kill Aura (Dano em Área)"
    if killAuraAtivado then
        auraConn = RunService.RenderStepped:Connect(function()
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and p.Character:FindFirstChild("Humanoid") and p.Character.Humanoid.Health > 0 then
                    local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
                    if hrp and (hrp.Position - p.Character.HumanoidRootPart.Position).Magnitude < 15 then
                        local tool = player.Character:FindFirstChildOfClass("Tool"); if tool then tool:Activate() end
                    end
                end
            end
        end)
    else if auraConn then auraConn:Disconnect(); auraConn = nil end end
end)

btnHitbox.MouseButton1Click:Connect(function()
    hitboxAtivada = not hitboxAtivada; btnHitbox.Text = hitboxAtivada and "Expandir Hitbox: ATIVADA" or "Expandir Hitbox (Inimigo Gigante)"
    if hitboxAtivada then
        hitboxConn = RunService.RenderStepped:Connect(function()
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                    if player.Team ~= nil and p.Team ~= nil and player.Team == p.Team then continue end
                    local hrp = p.Character.HumanoidRootPart; hrp.Size = Vector3.new(15, 15, 15); hrp.Transparency = 0.5
                    hrp.BrickColor = BrickColor.new("Bright blue"); hrp.Material = Enum.Material.Neon; hrp.CanCollide = false
                end
            end
        end)
    else
        if hitboxConn then hitboxConn:Disconnect(); hitboxConn = nil end
        for _, p in pairs(Players:GetPlayers()) do if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then p.Character.HumanoidRootPart.Size = Vector3.new(2, 2, 1); p.Character.HumanoidRootPart.Transparency = 1 end end
    end
end)

btnEsp.MouseButton1Click:Connect(function()
    espPlayersAtivado = not espPlayersAtivado; btnEsp.Text = espPlayersAtivado and "ESP Jogadores: ATIVADO" or "Ativar ESP (Distância)"
    if espPlayersAtivado then
        espConn = RunService.RenderStepped:Connect(function()
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= player and p.Character and p.Character:FindFirstChild("Head") then
                    local head = p.Character.Head; local tag = head:FindFirstChild("ESPTag")
                    if not tag then
                        local bgui = Instance.new("BillboardGui", head); bgui.Name = "ESPTag"; bgui.Size = UDim2.new(0, 200, 0, 50); bgui.AlwaysOnTop = true
                        local txt = Instance.new("TextLabel", bgui); txt.Size = UDim2.new(1, 0, 1, 0); txt.BackgroundTransparency = 1; txt.TextColor3 = Color3.fromRGB(255, 50, 50); txt.TextStrokeTransparency = 0; txt.TextSize = 14; txt.Font = Enum.Font.GothamBold; tag = bgui
                    end
                    local dist = 0; if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then dist = math.floor((player.Character.HumanoidRootPart.Position - head.Position).Magnitude) end
                    tag.TextLabel.Text = p.Name .. " (" .. tostring(dist) .. "m)"
                end
            end
        end)
    else
        if espConn then espConn:Disconnect(); espConn = nil end
        for _, p in pairs(Players:GetPlayers()) do if p.Character and p.Character:FindFirstChild("Head") then local tag = p.Character.Head:FindFirstChild("ESPTag"); if tag then tag:Destroy() end end end
    end
end)

-- ==========================================
-- ABA 3: MOVIMENTO DO JOGADOR
-- ==========================================
Instance.new("Frame", pageMove).Size = UDim2.new(1,0,0,1)

criarDivisoria("Controle de Corpo", pageMove)
criarLinhaEscala("Aplicar Velocidade (1-10)", 16, pageMove, false)
criarLinhaEscala("Aplicar Pulo (1-10)", 50, pageMove, true)
local btnPuloInf = criarBotao("Pulo Infinito no Ar", pageMove, Color3.fromRGB(0, 150, 200))
local btnSwim = criarBotao("Nadar Rápido (Shark Mode)", pageMove, Color3.fromRGB(50, 150, 200))

criarDivisoria("Física do Mapa", pageMove)
local btnNoclip = criarBotao("Atravessar Tudo (Noclip)", pageMove, Color3.fromRGB(120, 60, 180))
local btnClickTp = criarBotao("Teleporte por Clique (CTRL+Click)", pageMove, Color3.fromRGB(0, 150, 100))
local btnNoFall = criarBotao("Ignorar Dano de Queda", pageMove, Color3.fromRGB(100, 150, 50))

btnPuloInf.MouseButton1Click:Connect(function() puloInfinitoAtivado = not puloInfinitoAtivado; btnPuloInf.Text = puloInfinitoAtivado and "Pulo Infinito: ATIVADO" or "Pulo Infinito no Ar" end)
UserInputService.JumpRequest:Connect(function() if puloInfinitoAtivado and player.Character and player.Character:FindFirstChild("Humanoid") then player.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping) end end)

btnSwim.MouseButton1Click:Connect(function()
    fastSwimAtivado = not fastSwimAtivado; btnSwim.Text = fastSwimAtivado and "Nadar Rápido: ATIVADO" or "Nadar Rápido (Shark Mode)"
    if fastSwimAtivado then swimConn = RunService.Heartbeat:Connect(function() local hum = player.Character and player.Character:FindFirstChild("Humanoid"); if hum and hum:GetState() == Enum.HumanoidStateType.Swimming then player.Character.HumanoidRootPart.Velocity = player.Character.HumanoidRootPart.Velocity + (hum.MoveDirection * 1.5) end end)
    else if swimConn then swimConn:Disconnect(); swimConn = nil end end
end)

btnNoclip.MouseButton1Click:Connect(function()
    noclipAtivado = not noclipAtivado; btnNoclip.Text = noclipAtivado and "Noclip: ATIVADO" or "Atravessar Tudo (Noclip)"
    if noclipAtivado then noclipConn = RunService.Stepped:Connect(function() if player.Character then for _, p in pairs(player.Character:GetDescendants()) do if p:IsA("BasePart") and p.CanCollide then p.CanCollide = false end end end end)
    else if noclipConn then noclipConn:Disconnect(); noclipConn = nil end end
end)

btnClickTp.MouseButton1Click:Connect(function() clickTpAtivado = not clickTpAtivado; btnClickTp.Text = clickTpAtivado and "Click TP: ATIVADO" or "Teleporte por Clique (CTRL+Click)" end)
UserInputService.InputBegan:Connect(function(input, processed)
    if not processed and clickTpAtivado and input.UserInputType == Enum.UserInputType.MouseButton1 then
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) or UserInputService:IsKeyDown(Enum.KeyCode.RightControl) then
            if player.Character and player.Character:FindFirstChild("HumanoidRootPart") and mouse.Hit then player.Character.HumanoidRootPart.CFrame = CFrame.new(mouse.Hit.Position + Vector3.new(0, 3, 0)) end
        end
    end
end)

btnNoFall.MouseButton1Click:Connect(function()
    semDanoQuedaAtivado = not semDanoQuedaAtivado; btnNoFall.Text = semDanoQuedaAtivado and "Ignorar Queda: ATIVADO" or "Ignorar Dano de Queda"
    if semDanoQuedaAtivado then noFallConn = RunService.Stepped:Connect(function() local c = player.Character; if c and c:FindFirstChild("HumanoidRootPart") and c.HumanoidRootPart.AssemblyLinearVelocity.Y < -40 then c.HumanoidRootPart.AssemblyLinearVelocity = Vector3.new(c.HumanoidRootPart.AssemblyLinearVelocity.X, -40, c.HumanoidRootPart.AssemblyLinearVelocity.Z) end end)
    else if noFallConn then noFallConn:Disconnect(); noFallConn = nil end end
end)

-- ==========================================
-- ABA 4: TROLLS & UTILIDADES 
-- ==========================================
Instance.new("Frame", pageTroll).Size = UDim2.new(1,0,0,1)

criarDivisoria("Poderes Pessoais", pageTroll)
local btnGodMode = criarBotao("Ativar Modo Deus (Client-Side)", pageTroll, Color3.fromRGB(150, 100, 0))
local btnInvis = criarBotao("Ativar Invisibilidade", pageTroll)
local btnFullbright = criarBotao("Visão Noturna (Claridade Máxima)", pageTroll, Color3.fromRGB(200, 200, 50))

criarDivisoria("Interação Externa", pageTroll)
local btnSpec = criarBotao("Espionar Próximo Jogador", pageTroll)
local btnCloneSkin = criarBotao("Clonar Skin (Do Alvo Espiado)", pageTroll, Color3.fromRGB(180, 50, 150))
local btnBeyblade = criarBotao("Tornado Fling (Bata nos outros)", pageTroll, Color3.fromRGB(200, 100, 0))
local btnFoguete = criarBotao("Arremessar-se pro Céu", pageTroll, Color3.fromRGB(100, 50, 200))
local btnFakeBan = criarBotao("Gerar Fake Ban (Chat)", pageTroll, Color3.fromRGB(200, 0, 0))

btnGodMode.MouseButton1Click:Connect(function()
    modoDeus = not modoDeus; btnGodMode.Text = modoDeus and "Modo Deus: ATIVADO" or "Ativar Modo Deus (Client-Side)"
    if modoDeus then godModeConn = RunService.RenderStepped:Connect(function() if player.Character and player.Character:FindFirstChild("Humanoid") then player.Character.Humanoid.MaxHealth = math.huge; player.Character.Humanoid.Health = math.huge end end)
    else if godModeConn then godModeConn:Disconnect() end end
end)

btnInvis.MouseButton1Click:Connect(function()
    invisivel = not invisivel; btnInvis.Text = invisivel and "Invisibilidade: ATIVADA" or "Ativar Invisibilidade"
    if player.Character then for _, p in pairs(player.Character:GetDescendants()) do if p:IsA("BasePart") and p.Name ~= "HumanoidRootPart" then p.Transparency = invisivel and 1 or 0 elseif p:IsA("Decal") then p.Transparency = invisivel and 1 or 0 end end end
end)

btnFullbright.MouseButton1Click:Connect(function()
    fullbrightAtivado = not fullbrightAtivado; btnFullbright.Text = fullbrightAtivado and "Visão Noturna: ATIVADA" or "Visão Noturna (Claridade Máxima)"
    if fullbrightAtivado then Lighting.Brightness = 2; Lighting.ClockTime = 14; Lighting.FogEnd = 100000; Lighting.GlobalShadows = false; Lighting.Ambient = Color3.fromRGB(255, 255, 255)
    else Lighting.Brightness = 1; Lighting.FogEnd = 10000; Lighting.GlobalShadows = true end
end)

btnSpec.MouseButton1Click:Connect(function()
    local todos = Players:GetPlayers(); indexSpec = indexSpec + 1; if indexSpec > #todos then indexSpec = 1 end
    local alvo = todos[indexSpec]; if alvo.Character and alvo.Character:FindFirstChild("Humanoid") then workspace.CurrentCamera.CameraSubject = alvo.Character.Humanoid; btnSpec.Text = "Espiando: " .. alvo.Name end
end)

btnCloneSkin.MouseButton1Click:Connect(function()
    local alvo = Players:GetPlayers()[indexSpec] 
    if alvo and alvo ~= player and alvo.Character and player.Character then
        local mC = player.Character; local aC = alvo.Character
        for _, v in pairs(mC:GetChildren()) do if v:IsA("Accessory") or v:IsA("Shirt") or v:IsA("Pants") or v:IsA("CharacterMesh") or v:IsA("BodyColors") or v:IsA("ShirtGraphic") then v:Destroy() end end
        for _, v in pairs(aC:GetChildren()) do if v:IsA("Accessory") or v:IsA("Shirt") or v:IsA("Pants") or v:IsA("CharacterMesh") or v:IsA("BodyColors") or v:IsA("ShirtGraphic") then v:Clone().Parent = mC end end
        local mH = mC:FindFirstChild("Head"); local aH = aC:FindFirstChild("Head")
        if mH and aH then local mF = mH:FindFirstChildOfClass("Decal"); local aF = aH:FindFirstChildOfClass("Decal"); if mF and aF then mF.Texture = aF.Texture elseif aF and not mF then aF:Clone().Parent = mH end end
        btnCloneSkin.Text = "Clonado: " .. alvo.Name; task.wait(2); btnCloneSkin.Text = "Clonar Skin (Do Alvo Espiado)"
    end
end)

btnBeyblade.MouseButton1Click:Connect(function()
    beybladeAtivado = not beybladeAtivado; btnBeyblade.Text = beybladeAtivado and "Tornado Fling: ATIVADO" or "Tornado Fling (Bata nos outros)"
    local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if beybladeAtivado and hrp then
        if not hrp:FindFirstChild("BFling") then local b = Instance.new("BodyAngularVelocity"); b.Name = "BFling"; b.MaxTorque = Vector3.new(math.huge, math.huge, math.huge); b.AngularVelocity = Vector3.new(0, 1500, 0); b.Parent = hrp; beybladeObj = b end
    else if beybladeObj then beybladeObj:Destroy(); beybladeObj = nil end; if hrp and hrp:FindFirstChild("BFling") then hrp.BFling:Destroy() end end
end)

btnFoguete.MouseButton1Click:Connect(function()
    local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if hrp then local v = Instance.new("BodyVelocity"); v.MaxForce = Vector3.new(0, math.huge, 0); v.Velocity = Vector3.new(0, 500, 0); v.Parent = hrp; task.wait(0.5); v:Destroy() end
end)

btnFakeBan.MouseButton1Click:Connect(function() StarterGui:SetCore("ChatMakeSystemMessage", {Text = "[SISTEMA]: A sua conta foi denunciada multiplas vezes por exploração. A moderação analisará seu cliente.", Color = Color3.fromRGB(255, 0, 0), Font = Enum.Font.SourceSansBold, TextSize = 18}) end)

-- ==========================================
-- ABA 5: CONFIGURAÇÕES DA INTERFACE
-- ==========================================
Instance.new("Frame", pageConfig).Size = UDim2.new(1,0,0,1)

criarDivisoria("Customização Visual", pageConfig)
local cores = {
    {"Verde Natureza (TSG)", Color3.fromRGB(40, 200, 100)}, {"Azul Neon", Color3.fromRGB(0, 170, 255)}, 
    {"Vermelho Sangue", Color3.fromRGB(255, 50, 50)}, {"Rosa Choque", Color3.fromRGB(255, 0, 255)}
}
for _, c in ipairs(cores) do
    local btn = criarBotao(c[1], pageConfig, c[2]); btn.TextColor3 = Color3.fromRGB(0,0,0)
    btn.MouseButton1Click:Connect(function()
        corTema = c[2]; mainStroke.Color = corTema
        for _, o in pairs(screenGui:GetDescendants()) do if o:IsA("TextBox") then o.TextColor3 = corTema elseif o:IsA("TextLabel") and o.Text:match("^%-%-%-") then o.TextColor3 = corTema end end
        for _, b in pairs(tabBar:GetChildren()) do if b:IsA("TextButton") and b.Visible and b.TextColor3 ~= Color3.fromRGB(200,200,200) then b.TextColor3 = corTema end end
    end)
end

criarDivisoria("Aparência da Janela", pageConfig)
local btnSido = criarBotao("Fundo Sólido (Normal)", pageConfig)
local btnTransp = criarBotao("Fundo Transparente (Vidro)", pageConfig)
local btnBorda = criarBotao("Ligar/Desligar Borda", pageConfig)

btnSido.MouseButton1Click:Connect(function() mainFrame.BackgroundTransparency = 0 end)
btnTransp.MouseButton1Click:Connect(function() mainFrame.BackgroundTransparency = 0.4 end)
btnBorda.MouseButton1Click:Connect(function() mainStroke.Enabled = not mainStroke.Enabled end)

-- ==========================================
-- LÓGICA DE JANELA (MINIMIZAR/FECHAR)
-- ==========================================
minBtn.MouseButton1Click:Connect(function()
    minimizado = not minimizado
    if minimizado then mainFrame:TweenSize(UDim2.new(0, 420, 0, 35), "Out", "Quad", 0.3, true); tabBar.Visible = false; pageContainer.Visible = false
    else mainFrame:TweenSize(UDim2.new(0, 420, 0, 380), "Out", "Quad", 0.3, true); tabBar.Visible = true; pageContainer.Visible = true end
end)
