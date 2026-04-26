-- ==========================================
-- HUB ESPECÍFICO: THE SURVIVAL GAME
-- ==========================================

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local player = Players.LocalPlayer
local mouse = player:GetMouse()

-- ==========================================
-- CONFIGURAÇÕES GLOBAIS E ESTADOS
-- ==========================================
local minimizado = false
local aimbotAtivado = false
local aimbotAuto = true 
local autoFarmNodes = false
local autoTeleportDrop = false
local espMineriosAtivado = false
local espPlayersAtivado = false
local noclipAtivado = false
local fullbrightAtivado = false

local aimbotConnection = nil
local noclipConnection = nil
local espMineriosConnection = nil
local espPlayersConnection = nil
local autoFarmConnection = nil

local corTema = Color3.fromRGB(40, 200, 100) -- Verde Natureza para o Survival Game

-- ==========================================
-- 1. CRIAÇÃO DA INTERFACE BASE
-- ==========================================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "TSG_Hub"
screenGui.ResetOnSpawn = false
local success, _ = pcall(function() screenGui.Parent = CoreGui end)
if not success then screenGui.Parent = player:WaitForChild("PlayerGui") end

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 420, 0, 380)
mainFrame.Position = UDim2.new(0.5, -210, 0.5, -190)
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui

Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 12)
local mainStroke = Instance.new("UIStroke", mainFrame)
mainStroke.Thickness = 2; mainStroke.Color = corTema

local titleBar = Instance.new("Frame", mainFrame)
titleBar.Size = UDim2.new(1, 0, 0, 35); titleBar.BackgroundColor3 = Color3.fromRGB(30, 30, 30); titleBar.BorderSizePixel = 0
Instance.new("UICorner", titleBar).CornerRadius = UDim.new(0, 12)

local titleText = Instance.new("TextLabel", titleBar)
titleText.Size = UDim2.new(0.6, 0, 1, 0); titleText.Position = UDim2.new(0.05, 0, 0, 0)
titleText.BackgroundTransparency = 1; titleText.Text = "TSG HUB - SURVIVAL GAME"
titleText.TextColor3 = Color3.fromRGB(255, 255, 255); titleText.Font = Enum.Font.GothamBold
titleText.TextSize = 14; titleText.TextXAlignment = Enum.TextXAlignment.Left

local closeBtn = Instance.new("TextButton", titleBar)
closeBtn.Size = UDim2.new(0, 30, 0, 30); closeBtn.Position = UDim2.new(0.9, 0, 0.1, 0)
closeBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50); closeBtn.Text = "X"; closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 8)

local minBtn = Instance.new("TextButton", titleBar)
minBtn.Size = UDim2.new(0, 30, 0, 30); minBtn.Position = UDim2.new(0.8, 0, 0.1, 0)
minBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60); minBtn.Text = "-"; minBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
Instance.new("UICorner", minBtn).CornerRadius = UDim.new(0, 8)

-- ==========================================
-- SISTEMA DE ABAS (FOCADAS NO JOGO)
-- ==========================================
local tabBar = Instance.new("Frame", mainFrame)
tabBar.Size = UDim2.new(1, 0, 0, 35); tabBar.Position = UDim2.new(0, 0, 0, 35)
tabBar.BackgroundColor3 = Color3.fromRGB(25, 25, 25); tabBar.BorderSizePixel = 0
local tabLayout = Instance.new("UIListLayout", tabBar); tabLayout.FillDirection = Enum.FillDirection.Horizontal

local function criarAba(nome, ordem)
    local btn = Instance.new("TextButton", tabBar)
    btn.Size = UDim2.new(0.25, 0, 1, 0); btn.BackgroundTransparency = 1
    btn.Text = nome; btn.TextColor3 = Color3.fromRGB(200, 200, 200)
    btn.Font = Enum.Font.GothamSemibold; btn.TextSize = 12; btn.LayoutOrder = ordem
    return btn
end

local tabAuto = criarAba("Auto-Farm", 1)
local tabEsp = criarAba("Visuals", 2)
local tabCombat = criarAba("Combate", 3)
local tabConfig = criarAba("Interface", 4)

local pageContainer = Instance.new("Frame", mainFrame)
pageContainer.Size = UDim2.new(1, 0, 1, -70); pageContainer.Position = UDim2.new(0, 0, 0, 70); pageContainer.BackgroundTransparency = 1

local function criarPagina()
    local page = Instance.new("ScrollingFrame", pageContainer)
    page.Size = UDim2.new(1, 0, 1, 0); page.BackgroundTransparency = 1; page.ScrollBarThickness = 4; page.Visible = false
    page.AutomaticCanvasSize = Enum.AutomaticSize.Y; page.CanvasSize = UDim2.new(0, 0, 0, 0)
    local layout = Instance.new("UIListLayout", page)
    layout.Padding = UDim.new(0, 8); layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    return page
end

local pageAuto = criarPagina()
local pageEsp = criarPagina()
local pageCombat = criarPagina()
local pageConfig = criarPagina()
pageAuto.Visible = true

local function mudarAba(ativa, paginaAtiva)
    for _, btn in pairs(tabBar:GetChildren()) do if btn:IsA("TextButton") then btn.TextColor3 = Color3.fromRGB(200, 200, 200) end end
    ativa.TextColor3 = corTema
    pageAuto.Visible = false; pageEsp.Visible = false; pageCombat.Visible = false; pageConfig.Visible = false
    paginaAtiva.Visible = true
end

tabAuto.MouseButton1Click:Connect(function() mudarAba(tabAuto, pageAuto) end)
tabEsp.MouseButton1Click:Connect(function() mudarAba(tabEsp, pageEsp) end)
tabCombat.MouseButton1Click:Connect(function() mudarAba(tabCombat, pageCombat) end)
tabConfig.MouseButton1Click:Connect(function() mudarAba(tabConfig, pageConfig) end)
tabAuto.TextColor3 = corTema

-- ==========================================
-- FUNÇÕES AUXILIARES DE UI
-- ==========================================
local function criarBotaoSimples(texto, parent, cor)
    local btn = Instance.new("TextButton", parent)
    btn.Size = UDim2.new(0.9, 0, 0, 35); btn.BackgroundColor3 = cor or Color3.fromRGB(40, 40, 40)
    btn.Text = texto; btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamSemibold; btn.TextSize = 13
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
    return btn
end

local function criarDivisoria(texto, parent)
    local txt = Instance.new("TextLabel", parent)
    txt.Size = UDim2.new(0.9, 0, 0, 20); txt.BackgroundTransparency = 1
    txt.Text = "--- " .. texto .. " ---"; txt.TextColor3 = corTema; txt.Font = Enum.Font.GothamBold; txt.TextSize = 12
end

local isAimingInput = false
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then isAimingInput = true end
end)
UserInputService.InputEnded:Connect(function(input, gameProcessed)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then isAimingInput = false end
end)

-- ==========================================
-- PÁGINA 1: AUTO-FARM (THE SURVIVAL GAME)
-- ==========================================
Instance.new("Frame", pageAuto).Size = UDim2.new(1,0,0,1)

criarDivisoria("Coleta Automática", pageAuto)
local btnAutoFarmNodes = criarBotaoSimples("Auto-Ir até Recursos (Pedra/Madeira)", pageAuto, Color3.fromRGB(50, 150, 80))
local btnNoclip = criarBotaoSimples("Atravessar Tudo (Para Farmar Melhor)", pageAuto, Color3.fromRGB(120, 60, 180))

local txtAvisoFarm = Instance.new("TextLabel", pageAuto)
txtAvisoFarm.Size = UDim2.new(0.9, 0, 0, 40); txtAvisoFarm.BackgroundTransparency = 1
txtAvisoFarm.Text = "Ative o botão e equipe sua ferramenta. O script te levará até a rocha/árvore mais próxima. Clique para quebrar e ele pulará para a próxima sozinho!"
txtAvisoFarm.TextColor3 = Color3.fromRGB(200, 200, 200); txtAvisoFarm.TextWrapped = true; txtAvisoFarm.Font = Enum.Font.Gotham; txtAvisoFarm.TextSize = 11

-- Lógica Básica de Auto-Mover para Recursos no TSG
-- NOTA TÉCNICA: Em TSG, os minérios e árvores ficam no Workspace e geralmente têm parts que os representam.
local function encontrarRecursoProximo()
    local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end
    
    local maisProximo = nil
    local menorDist = 150 -- Só procura num raio de 150 studs para não teleportar pro infinito e tomar kick
    
    -- Busca genérica por partes que pareçam coletáveis
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("Model") and (obj.Name:match("Rock") or obj.Name:match("Ore") or obj.Name:match("Tree") or obj.Name:match("Boulder")) then
            local primary = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
            if primary then
                local dist = (primary.Position - hrp.Position).Magnitude
                if dist < menorDist then
                    menorDist = dist
                    maisProximo = primary
                end
            end
        end
    end
    return maisProximo
end

btnAutoFarmNodes.MouseButton1Click:Connect(function()
    autoFarmNodes = not autoFarmNodes
    btnAutoFarmNodes.Text = autoFarmNodes and "Auto-Ir até Recursos: LIGADO" or "Auto-Ir até Recursos (Pedra/Madeira)"
    
    if autoFarmNodes then
        autoFarmConnection = RunService.RenderStepped:Connect(function()
            task.wait(1) -- Checa de 1 em 1 segundo
            if autoFarmNodes and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                local recurso = encontrarRecursoProximo()
                if recurso then
                    -- Fica a 4 studs de distância do recurso
                    player.Character.HumanoidRootPart.CFrame = CFrame.new(recurso.Position + Vector3.new(0, 3, 4), recurso.Position)
                end
            end
        end)
    else
        if autoFarmConnection then autoFarmConnection:Disconnect(); autoFarmConnection = nil end
    end
end)

btnNoclip.MouseButton1Click:Connect(function()
    noclipAtivado = not noclipAtivado; btnNoclip.Text = noclipAtivado and "Atravessar Parede: ATIVADO" or "Atravessar Tudo (Para Farmar Melhor)"
    if noclipAtivado then noclipConnection = RunService.Stepped:Connect(function() if player.Character then for _, part in pairs(player.Character:GetDescendants()) do if part:IsA("BasePart") and part.CanCollide then part.CanCollide = false end end end end)
    else if noclipConnection then noclipConnection:Disconnect(); noclipConnection = nil end end
end)

-- ==========================================
-- PÁGINA 2: VISUALS (ESP)
-- ==========================================
Instance.new("Frame", pageEsp).Size = UDim2.new(1,0,0,1)

criarDivisoria("ESP de Recursos (Raio-X)", pageEsp)
local btnEspMinerios = criarBotaoSimples("Localizar Minérios Valiosos", pageEsp, Color3.fromRGB(200, 150, 0))

criarDivisoria("ESP de Jogadores", pageEsp)
local btnEspPlayers = criarBotaoSimples("ESP Jogadores Inimigos", pageEsp, Color3.fromRGB(0, 150, 200))
local btnFullbright = criarBotaoSimples("Visão Noturna (Fullbright)", pageEsp, Color3.fromRGB(200, 200, 50))

-- ESP Específico para TSG (Minérios)
btnEspMinerios.MouseButton1Click:Connect(function()
    espMineriosAtivado = not espMineriosAtivado
    btnEspMinerios.Text = espMineriosAtivado and "Localizar Minérios: ATIVADO" or "Localizar Minérios Valiosos"
    
    if espMineriosAtivado then
        espMineriosConnection = RunService.RenderStepped:Connect(function()
            task.wait(1)
            for _, obj in pairs(workspace:GetDescendants()) do
                -- Busca por nomes comuns de minérios valiosos em jogos de sobrevivência
                if obj:IsA("Model") and (obj.Name:match("Copper") or obj.Name:match("Iron") or obj.Name:match("Steel") or obj.Name:match("Gold")) then
                    local primary = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
                    if primary and not obj:FindFirstChild("OreESP") then
                        local bgui = Instance.new("BillboardGui", obj)
                        bgui.Name = "OreESP"; bgui.Size = UDim2.new(0, 100, 0, 30); bgui.AlwaysOnTop = true
                        local txt = Instance.new("TextLabel", bgui); txt.Size = UDim2.new(1, 0, 1, 0); txt.BackgroundTransparency = 1
                        txt.Text = obj.Name; txt.TextColor3 = Color3.fromRGB(255, 200, 0); txt.TextStrokeTransparency = 0; txt.Font = Enum.Font.GothamBold
                    end
                end
            end
        end)
    else
        if espMineriosConnection then espMineriosConnection:Disconnect(); espMineriosConnection = nil end
        for _, obj in pairs(workspace:GetDescendants()) do if obj:FindFirstChild("OreESP") then obj.OreESP:Destroy() end end
    end
end)

-- ESP Jogadores Tradicional
btnEspPlayers.MouseButton1Click:Connect(function()
    espPlayersAtivado = not espPlayersAtivado; btnEspPlayers.Text = espPlayersAtivado and "ESP Jogadores: ATIVADO" or "ESP Jogadores Inimigos"
    if espPlayersAtivado then
        espPlayersConnection = RunService.RenderStepped:Connect(function()
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= player and p.Character and p.Character:FindFirstChild("Head") then
                    local head = p.Character.Head; local tag = head:FindFirstChild("PlayerESP")
                    if not tag then
                        local bgui = Instance.new("BillboardGui", head); bgui.Name = "PlayerESP"; bgui.Size = UDim2.new(0, 200, 0, 50); bgui.AlwaysOnTop = true
                        local txt = Instance.new("TextLabel", bgui); txt.Size = UDim2.new(1, 0, 1, 0); txt.BackgroundTransparency = 1
                        txt.TextColor3 = Color3.fromRGB(255, 50, 50); txt.TextStrokeTransparency = 0; txt.TextSize = 14; txt.Font = Enum.Font.GothamBold; tag = bgui
                    end
                    local dist = 0; if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then dist = math.floor((player.Character.HumanoidRootPart.Position - head.Position).Magnitude) end
                    tag.TextLabel.Text = p.Name .. " (" .. tostring(dist) .. "m)"
                end
            end
        end)
    else
        if espPlayersConnection then espPlayersConnection:Disconnect(); espPlayersConnection = nil end
        for _, p in pairs(Players:GetPlayers()) do if p.Character and p.Character:FindFirstChild("Head") then local tag = p.Character.Head:FindFirstChild("PlayerESP"); if tag then tag:Destroy() end end end
    end
end)

btnFullbright.MouseButton1Click:Connect(function()
    fullbrightAtivado = not fullbrightAtivado; btnFullbright.Text = fullbrightAtivado and "Visão Noturna: ATIVADA" or "Visão Noturna (Fullbright)"
    if fullbrightAtivado then Lighting.Brightness = 2; Lighting.ClockTime = 14; Lighting.FogEnd = 100000; Lighting.GlobalShadows = false; Lighting.Ambient = Color3.fromRGB(255, 255, 255)
    else Lighting.Brightness = 1; Lighting.FogEnd = 10000; Lighting.GlobalShadows = true end
end)

-- ==========================================
-- PÁGINA 3: COMBATE
-- ==========================================
Instance.new("Frame", pageCombat).Size = UDim2.new(1,0,0,1)

criarDivisoria("Aimbot de Arco/Besta", pageCombat)
local btnAimbot = criarBotaoSimples("Ativar Aimbot (Atira com Gatilho)", pageCombat, Color3.fromRGB(200, 50, 50))
local btnAimbotTrigger = criarBotaoSimples("Gatilho: Automático (Sem Segurar)", pageCombat, Color3.fromRGB(180, 80, 120))

local function pegarInimigoMaisProximo()
    local alvoMaisProximo = nil; local menorDistancia = math.huge; local camera = workspace.CurrentCamera
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= player and p.Character and p.Character:FindFirstChild("Head") and p.Character:FindFirstChild("Humanoid") and p.Character.Humanoid.Health > 0 then
            local posTela, naTela = camera:WorldToViewportPoint(p.Character.Head.Position)
            if naTela then
                local centroTela = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
                local distancia = (Vector2.new(posTela.X, posTela.Y) - centroTela).Magnitude
                if distancia < menorDistancia then menorDistancia = distancia; alvoMaisProximo = p.Character.Head end
            end
        end
    end
    return alvoMaisProximo
end

btnAimbotTrigger.MouseButton1Click:Connect(function()
    aimbotAuto = not aimbotAuto
    btnAimbotTrigger.Text = aimbotAuto and "Gatilho: Automático (Sem Segurar)" or "Gatilho: Ao Segurar Tela/Clique"
end)

btnAimbot.MouseButton1Click:Connect(function()
    aimbotAtivado = not aimbotAtivado; btnAimbot.Text = aimbotAtivado and "Aimbot: ATIVADO" or "Ativar Aimbot (Atira com Gatilho)"
    if aimbotAtivado then 
        aimbotConnection = RunService.RenderStepped:Connect(function() 
            if aimbotAuto or isAimingInput then
                local alvo = pegarInimigoMaisProximo(); if alvo then workspace.CurrentCamera.CFrame = CFrame.new(workspace.CurrentCamera.CFrame.Position, alvo.Position) end 
            end
        end)
    else if aimbotConnection then aimbotConnection:Disconnect(); aimbotConnection = nil end end
end)

-- ==========================================
-- PÁGINA 4: CONFIGURAÇÕES DA INTERFACE
-- ==========================================
Instance.new("Frame", pageConfig).Size = UDim2.new(1,0,0,1)

local function criarTituloSecaoConfig(texto, parent)
    local txt = Instance.new("TextLabel", parent); txt.Size = UDim2.new(0.9, 0, 0, 25); txt.BackgroundTransparency = 1; txt.Text = texto; txt.TextColor3 = Color3.fromRGB(255, 255, 255); txt.Font = Enum.Font.GothamBold; txt.TextSize = 13; txt.TextXAlignment = Enum.TextXAlignment.Left
end

criarTituloSecaoConfig("Cor Principal do Hub:", pageConfig)
local cores = {
    {"Verde Natureza (TSG)", Color3.fromRGB(40, 200, 100)}, {"Azul Neon", Color3.fromRGB(0, 170, 255)}, 
    {"Vermelho Sangue", Color3.fromRGB(255, 50, 50)}, {"Rosa Choque", Color3.fromRGB(255, 0, 255)}
}
for _, dados in ipairs(cores) do
    local btnCor = criarBotaoSimples(dados[1], pageConfig, dados[2]); btnCor.Size = UDim2.new(0.9, 0, 0, 30); btnCor.TextColor3 = Color3.fromRGB(0,0,0)
    btnCor.MouseButton1Click:Connect(function()
        corTema = dados[2]; mainStroke.Color = corTema
        for _, obj in pairs(pageScripts:GetDescendants()) do if obj:IsA("TextBox") then obj.TextColor3 = corTema end end
        for _, obj in pairs(pageScripts:GetDescendants()) do if obj:IsA("TextLabel") and obj.Text:match("^%-%-%-") then obj.TextColor3 = corTema end end
        for _, btn in pairs(tabBar:GetChildren()) do if btn:IsA("TextButton") and btn.Visible then if btn.TextColor3 ~= Color3.fromRGB(200,200,200) then btn.TextColor3 = corTema end end end
    end)
end

criarTituloSecaoConfig("Transparência do Fundo:", pageConfig)
local btnSido = criarBotaoSimples("Fundo Sólido (Normal)", pageConfig)
local btnTransp = criarBotaoSimples("Fundo Transparente (Vidro)", pageConfig)
btnSido.MouseButton1Click:Connect(function() mainFrame.BackgroundTransparency = 0 end)
btnTransp.MouseButton1Click:Connect(function() mainFrame.BackgroundTransparency = 0.4 end)

-- ==========================================
-- LÓGICA GERAL DA JANELA (MINIMIZAR/FECHAR)
-- ==========================================
closeBtn.MouseButton1Click:Connect(function() screenGui:Destroy() end)
minBtn.MouseButton1Click:Connect(function() minimizado = not minimizado; if minimizado then mainFrame:TweenSize(UDim2.new(0, 420, 0, 35), "Out", "Quad", 0.3, true); tabBar.Visible = false; pageContainer.Visible = false else mainFrame:TweenSize(UDim2.new(0, 420, 0, 380), "Out", "Quad", 0.3, true); tabBar.Visible = true; pageContainer.Visible = true end end)
