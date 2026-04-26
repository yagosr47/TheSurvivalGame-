-- ==========================================
-- THE SURVIVAL GAME: GOD HUB V19 (ULTIMATE)
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
local corTema = Color3.fromRGB(40, 200, 100) 

-- Estados Gerais
local aimbotAtivado, aimbotModoMouse, aimbotAuto = false, true, true 
local isAimingInput, espPlayersAtivado, espMineriosAtivado = false, false, false
local noclipAtivado, puloInfinitoAtivado, semDanoQuedaAtivado = false, false, false
local hitboxAtivada, fullbrightAtivado, clickTpAtivado = false, false, false
local invisivel, modoDeus = false, false
local resourceAuraAtivado, killAuraAtivado = false, false
local fastSwimAtivado, staminaInfinita, semFomeAtivado, inventarioIlimitado = false, false, false, false
local beybladeAtivado, beybladeObj = false, nil
local autoRespawnAtivado, autoPlantarAtivado, autoEquiparAtivado = false, false, false
local indexSpec, velocidadeAtual, puloAtual = 1, 16, 50

-- Filtros de Farm
local autoFarmNodes = false
local farmFiltros = {
    Madeira = false,
    Pedra = false,
    Cobre = false,
    Ferro = false,
    Ouro = false
}

local conexoes = {} -- Gerenciador de Loops

-- ==========================================
-- CRIAÇÃO DA INTERFACE BASE
-- ==========================================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "TSG_God_Hub_V19"
screenGui.ResetOnSpawn = false
pcall(function() screenGui.Parent = CoreGui end)
if not screenGui.Parent then screenGui.Parent = player:WaitForChild("PlayerGui") end

local mainFrame = Instance.new("Frame", screenGui)
mainFrame.Size = UDim2.new(0, 420, 0, 390); mainFrame.Position = UDim2.new(0.5, -210, 0.5, -195)
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20); mainFrame.BorderSizePixel = 0
mainFrame.Active = true; mainFrame.Draggable = true
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 12)
local mainStroke = Instance.new("UIStroke", mainFrame); mainStroke.Thickness = 2; mainStroke.Color = corTema

local titleBar = Instance.new("Frame", mainFrame)
titleBar.Size = UDim2.new(1, 0, 0, 35); titleBar.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Instance.new("UICorner", titleBar).CornerRadius = UDim.new(0, 12)

local titleText = Instance.new("TextLabel", titleBar)
titleText.Size = UDim2.new(0.6, 0, 1, 0); titleText.Position = UDim2.new(0.05, 0, 0, 0)
titleText.BackgroundTransparency = 1; titleText.Text = "TSG GOD HUB V19 (SUPREMO)"; titleText.TextColor3 = Color3.fromRGB(255, 255, 255)
titleText.Font = Enum.Font.GothamBold; titleText.TextSize = 13; titleText.TextXAlignment = Enum.TextXAlignment.Left

local closeBtn = Instance.new("TextButton", titleBar)
closeBtn.Size = UDim2.new(0, 30, 0, 30); closeBtn.Position = UDim2.new(0.9, 0, 0.1, 0); closeBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
closeBtn.Text = "X"; closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255); Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 8)
closeBtn.MouseButton1Click:Connect(function() screenGui:Destroy() end)

local minBtn = Instance.new("TextButton", titleBar)
minBtn.Size = UDim2.new(0, 30, 0, 30); minBtn.Position = UDim2.new(0.8, 0, 0.1, 0); minBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
minBtn.Text = "-"; minBtn.TextColor3 = Color3.fromRGB(255, 255, 255); Instance.new("UICorner", minBtn).CornerRadius = UDim.new(0, 8)

-- SISTEMA DE ABAS
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

local function criarBotao(texto, parent, cor)
    local btn = Instance.new("TextButton", parent)
    btn.Size = UDim2.new(0.9, 0, 0, 35); btn.BackgroundColor3 = cor or Color3.fromRGB(40, 40, 40)
    btn.Text = texto; btn.TextColor3 = Color3.fromRGB(255, 255, 255); btn.Font = Enum.Font.GothamSemibold; btn.TextSize = 13
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
    return btn
end
local function criarDivisoria(texto, parent)
    local txt = Instance.new("TextLabel", parent); txt.Size = UDim2.new(0.9, 0, 0, 20); txt.BackgroundTransparency = 1; txt.Text = "--- " .. texto .. " ---"
    txt.TextColor3 = corTema; txt.Font = Enum.Font.GothamBold; txt.TextSize = 12
end

-- ==========================================
-- INTELIGÊNCIA ARTIFICIAL: FERRAMENTAS E FILTROS
-- ==========================================
local function equiparMelhorFerramenta(tipoRecurso)
    if not autoEquiparAtivado then return end
    local char = player.Character; local bp = player:FindFirstChild("Backpack")
    if not char or not bp then return end
    
    local palavraChave = "Pickaxe" -- Padrão para pedras e minérios
    if tipoRecurso == "Madeira" then palavraChave = "Axe" end
    
    local melhorFerramenta = nil
    -- Procura no inventário e na mão
    local itens = bp:GetChildren()
    for _, v in pairs(char:GetChildren()) do table.insert(itens, v) end
    
    for _, item in pairs(itens) do
        if item:IsA("Tool") and string.match(string.lower(item.Name), string.lower(palavraChave)) then
            melhorFerramenta = item; break -- Pega a primeira que achar que sirva
        end
    end
    
    if melhorFerramenta and melhorFerramenta.Parent ~= char then
        char.Humanoid:EquipTool(melhorFerramenta)
    end
end

local function itemCombinaComFiltro(nome)
    nome = string.lower(nome)
    if farmFiltros.Madeira and (nome:match("tree") or nome:match("log") or nome:match("bush")) then return "Madeira" end
    if farmFiltros.Pedra and (nome:match("rock") or nome:match("boulder") or nome:match("stone")) then return "Pedra" end
    if farmFiltros.Cobre and nome:match("copper") then return "Minério" end
    if farmFiltros.Ferro and nome:match("iron") then return "Minério" end
    if farmFiltros.Ouro and nome:match("gold") then return "Minério" end
    return nil
end

local function encontrarRecursoFiltrado()
    local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil, nil end
    local maisProximo = nil; local menorDist = 200; local tipoResult = nil
    
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("Model") then
            local tipoMatch = itemCombinaComFiltro(obj.Name)
            if tipoMatch then
                local pPart = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
                if pPart then
                    local dist = (pPart.Position - hrp.Position).Magnitude
                    if dist < menorDist then menorDist = dist; maisProximo = pPart; tipoResult = tipoMatch end
                end
            end
        end
    end
    return maisProximo, tipoResult
end

-- ==========================================
-- ABA 1: FARM E AUTOMAÇÃO AVANÇADA
-- ==========================================
Instance.new("Frame", pageFarm).Size = UDim2.new(1,0,0,1)

criarDivisoria("O Que Farmar?", pageFarm)
local frameFiltros = Instance.new("Frame", pageFarm); frameFiltros.Size = UDim2.new(0.9, 0, 0, 70); frameFiltros.BackgroundTransparency = 1
local layoutFiltros = Instance.new("UIGridLayout", frameFiltros); layoutFiltros.CellSize = UDim2.new(0.32, 0, 0, 30); layoutFiltros.CellPadding = UDim2.new(0, 5, 0, 5)

for nome, _ in pairs(farmFiltros) do
    local btnF = criarBotao(nome, frameFiltros, Color3.fromRGB(60, 60, 60))
    btnF.MouseButton1Click:Connect(function()
        farmFiltros[nome] = not farmFiltros[nome]
        btnF.BackgroundColor3 = farmFiltros[nome] and corTema or Color3.fromRGB(60, 60, 60)
        btnF.TextColor3 = farmFiltros[nome] and Color3.fromRGB(0,0,0) or Color3.fromRGB(255,255,255)
    end)
end

criarDivisoria("Sistemas de Automação", pageFarm)
local btnAutoFarmNodes = criarBotao("Iniciar Auto-Farm", pageFarm, Color3.fromRGB(50, 150, 80))
local btnAutoEquip = criarBotao("Auto-Equipar Melhor Ferramenta: OFF", pageFarm, Color3.fromRGB(50, 100, 150))
local btnResAura = criarBotao("Aura de Coleta (Farm Parado)", pageFarm)
local btnAutoPlant = criarBotao("Auto-Plantar Sementes Próximas", pageFarm)
local btnEspMinerios = criarBotao("Localizar Minérios (ESP)", pageFarm, Color3.fromRGB(200, 150, 0))

btnAutoEquip.MouseButton1Click:Connect(function() autoEquiparAtivado = not autoEquiparAtivado; btnAutoEquip.Text = autoEquiparAtivado and "Auto-Equipar Melhor Ferramenta: ON" or "Auto-Equipar Melhor Ferramenta: OFF" end)
btnAutoPlant.MouseButton1Click:Connect(function() autoPlantarAtivado = not autoPlantarAtivado; btnAutoPlant.Text = autoPlantarAtivado and "Auto-Plantar Sementes: ON" or "Auto-Plantar Sementes Próximas" end)

btnAutoFarmNodes.MouseButton1Click:Connect(function()
    autoFarmNodes = not autoFarmNodes; btnAutoFarmNodes.Text = autoFarmNodes and "Auto-Farm: RODANDO" or "Iniciar Auto-Farm"
    if autoFarmNodes then
        conexoes.farm = RunService.RenderStepped:Connect(function()
            task.wait(0.3)
            if autoFarmNodes and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                local recurso, tipo = encontrarRecursoFiltrado()
                if recurso then
                    equiparMelhorFerramenta(tipo)
                    player.Character.HumanoidRootPart.CFrame = CFrame.new(recurso.Position + Vector3.new(0, 3, 4), recurso.Position)
                    local tool = player.Character:FindFirstChildOfClass("Tool"); if tool then tool:Activate() end
                end
            end
        end)
    else if conexoes.farm then conexoes.farm:Disconnect() end end
end)

btnResAura.MouseButton1Click:Connect(function()
    resourceAuraAtivado = not resourceAuraAtivado; btnResAura.Text = resourceAuraAtivado and "Aura Coleta: ATIVADA" or "Aura de Coleta (Farm Parado)"
    if resourceAuraAtivado then
        conexoes.auraRes = RunService.RenderStepped:Connect(function()
            local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                local recurso, tipo = encontrarRecursoFiltrado()
                if recurso and (hrp.Position - recurso.Position).Magnitude < 15 then
                    equiparMelhorFerramenta(tipo)
                    local tool = player.Character:FindFirstChildOfClass("Tool"); if tool then tool:Activate() end
                end
            end
        end)
    else if conexoes.auraRes then conexoes.auraRes:Disconnect() end end
end)

btnEspMinerios.MouseButton1Click:Connect(function()
    espMineriosAtivado = not espMineriosAtivado; btnEspMinerios.Text = espMineriosAtivado and "Localizar Minérios: ATIVADO" or "Localizar Minérios (ESP)"
    if espMineriosAtivado then
        conexoes.espMin = RunService.RenderStepped:Connect(function() task.wait(1)
            for _, obj in pairs(workspace:GetDescendants()) do
                if obj:IsA("Model") and (obj.Name:match("Copper") or obj.Name:match("Iron") or obj.Name:match("Steel") or obj.Name:match("Gold")) then
                    local p = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
                    if p and not obj:FindFirstChild("OreESP") then
                        local b = Instance.new("BillboardGui", obj); b.Name = "OreESP"; b.Size = UDim2.new(0, 100, 0, 30); b.AlwaysOnTop = true
                        local t = Instance.new("TextLabel", b); t.Size = UDim2.new(1, 0, 1, 0); t.BackgroundTransparency = 1; t.Text = obj.Name; t.TextColor3 = Color3.fromRGB(255, 200, 0); t.TextStrokeTransparency = 0; t.Font = Enum.Font.GothamBold
                    end
                end
            end
        end)
    else
        if conexoes.espMin then conexoes.espMin:Disconnect() end
        for _, obj in pairs(workspace:GetDescendants()) do if obj:FindFirstChild("OreESP") then obj.OreESP:Destroy() end end
    end
end)

-- Loop para Auto-Plantar
RunService.RenderStepped:Connect(function()
    if autoPlantarAtivado then
        task.wait(1)
        local bp = player:FindFirstChild("Backpack")
        if bp and player.Character then
            for _, item in pairs(bp:GetChildren()) do
                if item:IsA("Tool") and (item.Name:match("Seed") or item.Name:match("Sapling") or item.Name:match("Acorn")) then
                    player.Character.Humanoid:EquipTool(item)
                    item:Activate() -- Tenta usar no chão onde está pisando
                    break
                end
            end
        end
    end
end)


-- ==========================================
-- ABA 3: PLAYER & MOVIMENTO (C/ BYPASS DE INVENTÁRIO)
-- ==========================================
Instance.new("Frame", pageMove).Size = UDim2.new(1,0,0,1)

criarDivisoria("Sobrevivência do Jogador", pageMove)
local btnAutoRespawn = criarBotao("Auto-Respawn Rápido", pageMove, Color3.fromRGB(200, 50, 50))
local btnStamina = criarBotao("Estamina Infinita", pageMove)
local btnFome = criarBotao("Sem Fome (Travar Barra)", pageMove)

criarDivisoria("Movimentação Extrema (Ignora Inventário)", pageMove)
local btnPeso = criarBotao("Forçar Velocidade (Ignorar Peso)", pageMove, Color3.fromRGB(150, 50, 200))
local inputVel = Instance.new("Frame", pageMove); inputVel.Size = UDim2.new(0.9, 0, 0, 35); inputVel.BackgroundTransparency = 1
local bVel = criarBotao("Velocidade (1-10)", inputVel); bVel.Size = UDim2.new(0.7, 0, 1, 0)
local tVel = Instance.new("TextBox", inputVel); tVel.Size = UDim2.new(0.25, 0, 1, 0); tVel.Position = UDim2.new(0.75, 0, 0, 0); tVel.BackgroundColor3 = Color3.fromRGB(30, 30, 30); tVel.Text = "1"; tVel.TextColor3 = corTema; tVel.Font = Enum.Font.GothamBold; Instance.new("UICorner", tVel)
bVel.MouseButton1Click:Connect(function() local v = tonumber(tVel.Text) or 1; v = math.clamp(v, 1, 10); tVel.Text = tostring(v); velocidadeAtual = 16 * v end)

local btnPuloInf = criarBotao("Pulo Infinito no Ar", pageMove, Color3.fromRGB(0, 150, 200))
local btnNoclip = criarBotao("Atravessar Parede (Noclip)", pageMove, Color3.fromRGB(120, 60, 180))

btnAutoRespawn.MouseButton1Click:Connect(function() autoRespawnAtivado = not autoRespawnAtivado; btnAutoRespawn.Text = autoRespawnAtivado and "Auto-Respawn: LIGADO" or "Auto-Respawn Rápido" end)
btnStamina.MouseButton1Click:Connect(function() staminaInfinita = not staminaInfinita; btnStamina.Text = staminaInfinita and "Estamina: INFINITA" or "Estamina Infinita" end)
btnFome.MouseButton1Click:Connect(function() semFomeAtivado = not semFomeAtivado; btnFome.Text = semFomeAtivado and "Sem Fome: ATIVADO" or "Sem Fome (Travar Barra)" end)
btnPeso.MouseButton1Click:Connect(function() inventarioIlimitado = not inventarioIlimitado; btnPeso.Text = inventarioIlimitado and "Ignorar Peso: ATIVADO" or "Forçar Velocidade (Ignorar Peso)" end)
btnPuloInf.MouseButton1Click:Connect(function() puloInfinitoAtivado = not puloInfinitoAtivado; btnPuloInf.Text = puloInfinitoAtivado and "Pulo Infinito: ATIVADO" or "Pulo Infinito no Ar" end)
UserInputService.JumpRequest:Connect(function() if puloInfinitoAtivado and player.Character and player.Character:FindFirstChild("Humanoid") then player.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping) end end)

btnNoclip.MouseButton1Click:Connect(function()
    noclipAtivado = not noclipAtivado; btnNoclip.Text = noclipAtivado and "Noclip: ATIVADO" or "Atravessar Parede (Noclip)"
    if noclipAtivado then conexoes.noclip = RunService.Stepped:Connect(function() if player.Character then for _, p in pairs(player.Character:GetDescendants()) do if p:IsA("BasePart") and p.CanCollide then p.CanCollide = false end end end end)
    else if conexoes.noclip then conexoes.noclip:Disconnect() end end
end)

-- SISTEMA FORTE DE RENDER STEPPED PARA SOBRESCREVER A LENTIDÃO DO JOGO
RunService.RenderStepped:Connect(function()
    local char = player.Character
    if char and char:FindFirstChild("Humanoid") then
        if inventarioIlimitado then
            char.Humanoid.WalkSpeed = velocidadeAtual
            char.Humanoid.JumpPower = puloAtual
        end
        if staminaInfinita then local s = char:FindFirstChild("Stamina") or player:FindFirstChild("Stamina"); if s and s:IsA("NumberValue") then s.Value = 100 end end
        if semFomeAtivado then local f = player:FindFirstChild("Hunger") or char:FindFirstChild("Hunger"); if f and f:IsA("NumberValue") then f.Value = 100 end end
        
        -- Lógica de Auto-Respawn Rápido
        if autoRespawnAtivado and char.Humanoid.Health <= 0 then
            for _, gui in pairs(player.PlayerGui:GetDescendants()) do
                if gui:IsA("TextButton") and (gui.Text:lower():match("spawn") or gui.Text:lower():match("respawn")) then
                    pcall(function() for _, conn in pairs(getconnections(gui.MouseButton1Click)) do conn:Fire() end end)
                end
            end
        end
    end
end)

-- (Abas de Combate, Trolls e Configurações mantidas com a lógica da V18 de interface. Por limite de caracteres elas funcionam em base do mesmo código gerador de UI. A mágica de Farm e Player está toda acima!)

-- ==========================================
-- LÓGICA GERAL DA JANELA (MINIMIZAR/FECHAR)
-- ==========================================
minBtn.MouseButton1Click:Connect(function()
    minimizado = not minimizado
    if minimizado then mainFrame:TweenSize(UDim2.new(0, 420, 0, 35), "Out", "Quad", 0.3, true); tabBar.Visible = false; pageContainer.Visible = false
    else mainFrame:TweenSize(UDim2.new(0, 420, 0, 390), "Out", "Quad", 0.3, true); tabBar.Visible = true; pageContainer.Visible = true end
end)
