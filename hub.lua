-- ==========================================
-- THE SURVIVAL GAME: GOD HUB V21 (SUPREMO)
-- ==========================================

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local player = Players.LocalPlayer
local mouse = player:GetMouse()

-- ==========================================
-- CONFIGURAÇÕES E ESTADOS
-- ==========================================
local corTema = Color3.fromRGB(40, 200, 100) 

local autoFarmNodes, autoEquiparAtivado = false, true
local autoPlantarAtivado, autoRebirthAtivado = false, false
local inventarioIlimitado, staminaInfinita, semFomeAtivado = false, false, false
local hitBoxPequena = false
local resourceAuraAtivado, killAuraAtivado = false, false
local savedRespawnCFrame = nil
local velocidadeAtual, puloAtual = 16, 50

-- Filtros (Incluindo Carvão e Bluesteel)
local farmFiltros = {Madeira = false, Pedra = false, Carvao = false, Cobre = false, Ferro = false, Ouro = false, Bluesteel = false}
local recursosCache = {} -- OTIMIZAÇÃO: Cache para evitar lag 100%

local conexoes = {}

-- ==========================================
-- CRIAÇÃO DA INTERFACE BASE (COMPACTA)
-- ==========================================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "TSG_God_Hub_V21"
screenGui.ResetOnSpawn = false
pcall(function() screenGui.Parent = CoreGui end)
if not screenGui.Parent then screenGui.Parent = player:WaitForChild("PlayerGui") end

local mainFrame = Instance.new("Frame", screenGui)
mainFrame.Size = UDim2.new(0, 430, 0, 400); mainFrame.Position = UDim2.new(0.5, -215, 0.5, -200)
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20); mainFrame.BorderSizePixel = 0; mainFrame.Active = true; mainFrame.Draggable = true
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 12)
local mainStroke = Instance.new("UIStroke", mainFrame); mainStroke.Thickness = 2; mainStroke.Color = corTema

local titleBar = Instance.new("Frame", mainFrame)
titleBar.Size = UDim2.new(1, 0, 0, 35); titleBar.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Instance.new("UICorner", titleBar).CornerRadius = UDim.new(0, 12)

local titleText = Instance.new("TextLabel", titleBar)
titleText.Size = UDim2.new(0.6, 0, 1, 0); titleText.Position = UDim2.new(0.05, 0, 0, 0)
titleText.BackgroundTransparency = 1; titleText.Text = "TSG GOD HUB V21 (SUPREMO)"; titleText.TextColor3 = Color3.fromRGB(255, 255, 255)
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

local pageFarm, tabFarm = criarAba("Auto-Tudo", 1)
local pagePlayer, tabPlayer = criarAba("Jogador", 2)
local pageInv, tabInv = criarAba("Inventário", 3)

pageFarm.Visible = true; tabFarm.TextColor3 = corTema

local function mudarAba(btnAtivo, pageAtiva)
    for _, btn in pairs(tabBar:GetChildren()) do if btn:IsA("TextButton") then btn.TextColor3 = Color3.fromRGB(200, 200, 200) end end
    for _, pg in pairs(pageContainer:GetChildren()) do if pg:IsA("ScrollingFrame") then pg.Visible = false end end
    btnAtivo.TextColor3 = corTema; pageAtiva.Visible = true
end
tabFarm.MouseButton1Click:Connect(function() mudarAba(tabFarm, pageFarm) end)
tabPlayer.MouseButton1Click:Connect(function() mudarAba(tabPlayer, pagePlayer) end)
tabInv.MouseButton1Click:Connect(function() mudarAba(tabInv, pageInv) end)

local function criarBotao(texto, parent, cor)
    local btn = Instance.new("TextButton", parent)
    btn.Size = UDim2.new(0.9, 0, 0, 35); btn.BackgroundColor3 = cor or Color3.fromRGB(40, 40, 40)
    btn.Text = texto; btn.TextColor3 = Color3.fromRGB(255, 255, 255); btn.Font = Enum.Font.GothamSemibold; btn.TextSize = 12
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
    return btn
end
local function criarDivisoria(texto, parent)
    local txt = Instance.new("TextLabel", parent); txt.Size = UDim2.new(0.9, 0, 0, 20); txt.BackgroundTransparency = 1; txt.Text = "--- " .. texto .. " ---"
    txt.TextColor3 = corTema; txt.Font = Enum.Font.GothamBold; txt.TextSize = 12
end

-- ==========================================
-- IA: DETECÇÃO RESTRITA E CACHE (0% LAG)
-- ==========================================

-- Apenas NOMES EXATOS evitam focar em forjas, casas ou móveis de madeira
local nomesValidos = {
    ["tree"] = "Madeira", ["pine tree"] = "Madeira", ["oak tree"] = "Madeira", ["palm tree"] = "Madeira", ["birch tree"] = "Madeira",
    ["rock"] = "Pedra", ["boulder"] = "Pedra",
    ["copper ore"] = "Cobre",
    ["iron ore"] = "Ferro",
    ["gold ore"] = "Ouro",
    ["coal ore"] = "Carvao",
    ["bluesteel ore"] = "Bluesteel"
}

task.spawn(function()
    while task.wait(2) do
        local cacheTemp = {}
        for _, obj in pairs(workspace:GetDescendants()) do
            if obj:IsA("Model") then
                local n = string.lower(obj.Name)
                local tipoMatch = nomesValidos[n]
                if tipoMatch then
                    local pPart = obj.PrimaryPart or obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChild("Trunk") or obj:FindFirstChildWhichIsA("BasePart")
                    if pPart then table.insert(cacheTemp, {part = pPart, tipo = tipoMatch}) end
                end
            end
        end
        recursosCache = cacheTemp
    end
end)

local function equiparMelhorFerramenta(tipoRecurso)
    if not autoEquiparAtivado then return end
    local char = player.Character; local bp = player:FindFirstChild("Backpack")
    if not char or not bp then return end
    
    local pref = "Pickaxe"
    if tipoRecurso == "Madeira" then pref = "Axe" end
    
    local itens = bp:GetChildren()
    for _, v in pairs(char:GetChildren()) do table.insert(itens, v) end
    
    local ferramenta = nil
    local fallbackPedra = nil
    
    for _, item in pairs(itens) do
        if item:IsA("Tool") then
            local n = string.lower(item.Name)
            if n:match(string.lower(pref)) then ferramenta = item; break end
            if n:match("rock") or n:match("stone") then fallbackPedra = item end 
        end
    end
    
    local itemParaEquipar = ferramenta or fallbackPedra
    if itemParaEquipar and itemParaEquipar.Parent ~= char then
        char.Humanoid:EquipTool(itemParaEquipar)
    end
end

local function encontrarRecursoFiltrado()
    local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil, nil end
    local maisProximo = nil; local menorDist = math.huge; local tipoResult = nil
    
    -- Busca APENAS na lista cacheada instantaneamente
    for _, rec in ipairs(recursosCache) do
        if farmFiltros[rec.tipo] and rec.part and rec.part.Parent then
            local dist = (rec.part.Position - hrp.Position).Magnitude
            if dist < menorDist then menorDist = dist; maisProximo = rec.part; tipoResult = rec.tipo end
        end
    end
    return maisProximo, tipoResult
end

-- ==========================================
-- ABA 1: AUTO-TUDO (FARM, PLANT, REBIRTH, AURAS)
-- ==========================================
Instance.new("Frame", pageFarm).Size = UDim2.new(1,0,0,1)

criarDivisoria("O Que Farmar? (Nomes Estritos)", pageFarm)
local frameFiltros = Instance.new("Frame", pageFarm); frameFiltros.Size = UDim2.new(0.9, 0, 0, 100); frameFiltros.BackgroundTransparency = 1
local layoutFiltros = Instance.new("UIGridLayout", frameFiltros); layoutFiltros.CellSize = UDim2.new(0.31, 0, 0, 30); layoutFiltros.CellPadding = UDim2.new(0, 5, 0, 5)

for nome, _ in pairs(farmFiltros) do
    local btnF = criarBotao(nome, frameFiltros, Color3.fromRGB(60, 60, 60))
    btnF.MouseButton1Click:Connect(function()
        farmFiltros[nome] = not farmFiltros[nome]
        btnF.BackgroundColor3 = farmFiltros[nome] and corTema or Color3.fromRGB(60, 60, 60)
        btnF.TextColor3 = farmFiltros[nome] and Color3.fromRGB(0,0,0) or Color3.fromRGB(255,255,255)
    end)
end

criarDivisoria("Auras e Automação", pageFarm)
local btnAutoFarmNodes = criarBotao("Iniciar Auto-Farm (Teleporta e Quebra)", pageFarm, Color3.fromRGB(50, 150, 80))
local btnResAura = criarBotao("Aura Minérios/Madeira (Coleta em Área)", pageFarm, Color3.fromRGB(50, 100, 150))
local btnKillAura = criarBotao("Kill Aura (Players, Bosses, Animais)", pageFarm, Color3.fromRGB(150, 50, 50))
local btnAutoPlant = criarBotao("Auto-Plantar e Fazer Solo Próximo", pageFarm, Color3.fromRGB(150, 150, 50))
local btnAutoRebirth = criarBotao("Auto-Rebirth (Level 25) - Background", pageFarm, Color3.fromRGB(150, 50, 200))

btnAutoFarmNodes.MouseButton1Click:Connect(function()
    autoFarmNodes = not autoFarmNodes; btnAutoFarmNodes.Text = autoFarmNodes and "Auto-Farm: RODANDO" or "Iniciar Auto-Farm (Teleporta e Quebra)"
    if autoFarmNodes then
        conexoes.farm = RunService.Heartbeat:Connect(function()
            if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
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
    resourceAuraAtivado = not resourceAuraAtivado; btnResAura.Text = resourceAuraAtivado and "Aura Recursos: LIGADA" or "Aura Minérios/Madeira (Coleta em Área)"
    if resourceAuraAtivado then
        conexoes.resAura = RunService.RenderStepped:Connect(function()
            local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                local recurso, tipo = encontrarRecursoFiltrado()
                if recurso and (hrp.Position - recurso.Position).Magnitude < 18 then
                    equiparMelhorFerramenta(tipo)
                    local tool = player.Character:FindFirstChildOfClass("Tool"); if tool then tool:Activate() end
                end
            end
        end)
    else if conexoes.resAura then conexoes.resAura:Disconnect() end end
end)

btnKillAura.MouseButton1Click:Connect(function()
    killAuraAtivado = not killAuraAtivado; btnKillAura.Text = killAuraAtivado and "Kill Aura: ATIVADA EM TUDO" or "Kill Aura (Players, Bosses, Animais)"
    if killAuraAtivado then
        conexoes.killAura = RunService.RenderStepped:Connect(function()
            local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
            local tool = player.Character and player.Character:FindFirstChildOfClass("Tool")
            if hrp and tool then
                -- Ataca Players
                for _, p in pairs(Players:GetPlayers()) do
                    if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and p.Character:FindFirstChild("Humanoid") and p.Character.Humanoid.Health > 0 then
                        if player.Team and p.Team and player.Team == p.Team then continue end
                        if (hrp.Position - p.Character.HumanoidRootPart.Position).Magnitude < 18 then tool:Activate() end
                    end
                end
                -- Ataca Bosses e Animais (NPCs com Humanoid no Workspace)
                for _, obj in pairs(workspace:GetDescendants()) do
                    if obj:IsA("Model") and obj:FindFirstChild("Humanoid") and obj:FindFirstChild("HumanoidRootPart") and obj ~= player.Character then
                        if not Players:GetPlayerFromCharacter(obj) and obj.Humanoid.Health > 0 then
                            if (hrp.Position - obj.HumanoidRootPart.Position).Magnitude < 18 then tool:Activate() end
                        end
                    end
                end
            end
        end)
    else if conexoes.killAura then conexoes.killAura:Disconnect() end end
end)

btnAutoPlant.MouseButton1Click:Connect(function()
    autoPlantarAtivado = not autoPlantarAtivado; btnAutoPlant.Text = autoPlantarAtivado and "Auto-Plantar: LIGADO" or "Auto-Plantar e Fazer Solo Próximo"
    if autoPlantarAtivado then
        conexoes.plant = RunService.Heartbeat:Connect(function()
            local char = player.Character; local bp = player:FindFirstChild("Backpack")
            if not char or not bp then return end
            
            local soloProximo = false
            for _, obj in pairs(workspace:GetDescendants()) do
                if obj.Name == "Soil" and obj:IsA("BasePart") and (obj.Position - char.HumanoidRootPart.Position).Magnitude < 10 then soloProximo = true; break end
            end
            
            local itens = bp:GetChildren(); for _, v in pairs(char:GetChildren()) do table.insert(itens, v) end
            if not soloProximo then
                for _, item in pairs(itens) do
                    if item:IsA("Tool") and string.lower(item.Name):match("shovel") then
                        if item.Parent ~= char then char.Humanoid:EquipTool(item) end
                        item:Activate(); break
                    end
                end
            else
                for _, item in pairs(itens) do
                    if item:IsA("Tool") and (string.lower(item.Name):match("seed") or string.lower(item.Name):match("sapling") or string.lower(item.Name):match("acorn")) then
                        if item.Parent ~= char then char.Humanoid:EquipTool(item) end
                        item:Activate(); break
                    end
                end
            end
        end)
    else if conexoes.plant then conexoes.plant:Disconnect() end end
end)

btnAutoRebirth.MouseButton1Click:Connect(function()
    autoRebirthAtivado = not autoRebirthAtivado; btnAutoRebirth.Text = autoRebirthAtivado and "Auto-Rebirth: ATIVO" or "Auto-Rebirth (Level 25) - Background"
    if autoRebirthAtivado then
        conexoes.rebirth = RunService.Heartbeat:Connect(function()
            for _, prompt in pairs(workspace:GetDescendants()) do
                if prompt:IsA("ProximityPrompt") and string.lower(prompt.ActionText):match("rebirth") then fireproximityprompt(prompt) end
            end
        end)
    else if conexoes.rebirth then conexoes.rebirth:Disconnect() end end
end)

-- ==========================================
-- ABA 2: JOGADOR (RESPAWN, INVENTÁRIO, HITBOX)
-- ==========================================
Instance.new("Frame", pagePlayer).Size = UDim2.new(1,0,0,1)

criarDivisoria("Defesa e Forma Física", pagePlayer)
local btnShrink = criarBotao("Reduzir Hitbox (Ficar Pequeno p/ Inimigos)", pagePlayer, Color3.fromRGB(150, 100, 150))
local btnPeso = criarBotao("Forçar Velocidade (Ignora Inventário Cheio)", pagePlayer, Color3.fromRGB(100, 50, 200))
local btnStamina = criarBotao("Estamina Infinita", pagePlayer)
local btnFome = criarBotao("Sem Fome", pagePlayer)

criarDivisoria("Custom Respawn", pagePlayer)
local btnSalvarRespawn = criarBotao("Marcar Local de Respawn Aqui", pagePlayer, Color3.fromRGB(0, 150, 200))
local txtRespawnInfo = Instance.new("TextLabel", pagePlayer); txtRespawnInfo.Size = UDim2.new(0.9, 0, 0, 20); txtRespawnInfo.BackgroundTransparency = 1; txtRespawnInfo.Text = "Nenhum local salvo."; txtRespawnInfo.TextColor3 = Color3.fromRGB(150,150,150); txtRespawnInfo.Font = Enum.Font.Gotham; txtRespawnInfo.TextSize = 11

btnShrink.MouseButton1Click:Connect(function()
    hitBoxPequena = not hitBoxPequena; btnShrink.Text = hitBoxPequena and "Hitbox Reduzida: ATIVADA" or "Reduzir Hitbox (Ficar Pequeno p/ Inimigos)"
    local char = player.Character
    if char then
        local hum = char:FindFirstChild("Humanoid")
        if hitBoxPequena then
            if hum then for _, p in pairs({"BodyDepthScale", "BodyHeightScale", "BodyWidthScale", "HeadScale"}) do if hum:FindFirstChild(p) then hum[p].Value = 0.3 end end end
            local hrp = char:FindFirstChild("HumanoidRootPart"); if hrp then hrp.Size = Vector3.new(1,1,1) end
        else
            if hum then for _, p in pairs({"BodyDepthScale", "BodyHeightScale", "BodyWidthScale", "HeadScale"}) do if hum:FindFirstChild(p) then hum[p].Value = 1 end end end
            local hrp = char:FindFirstChild("HumanoidRootPart"); if hrp then hrp.Size = Vector3.new(2,2,1) end
        end
    end
end)

btnSalvarRespawn.MouseButton1Click:Connect(function()
    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        savedRespawnCFrame = player.Character.HumanoidRootPart.CFrame; txtRespawnInfo.Text = "Local salvo com sucesso! Você renascerá aqui."; txtRespawnInfo.TextColor3 = Color3.fromRGB(50, 255, 50)
    end
end)

btnStamina.MouseButton1Click:Connect(function() staminaInfinita = not staminaInfinita; btnStamina.Text = staminaInfinita and "Estamina: INFINITA" or "Estamina Infinita" end)
btnFome.MouseButton1Click:Connect(function() semFomeAtivado = not semFomeAtivado; btnFome.Text = semFomeAtivado and "Sem Fome: ATIVADO" or "Sem Fome" end)
btnPeso.MouseButton1Click:Connect(function() inventarioIlimitado = not inventarioIlimitado; btnPeso.Text = inventarioIlimitado and "Ignorar Peso: ATIVADO" or "Forçar Velocidade (Ignora Inventário Cheio)" end)

RunService.RenderStepped:Connect(function()
    local char = player.Character
    if char and char:FindFirstChild("Humanoid") then
        if inventarioIlimitado then char.Humanoid.WalkSpeed = velocidadeAtual end
        if staminaInfinita then local s = char:FindFirstChild("Stamina") or player:FindFirstChild("Stamina"); if s and s:IsA("NumberValue") then s.Value = 100 end end
        if semFomeAtivado then local f = player:FindFirstChild("Hunger") or char:FindFirstChild("Hunger"); if f and f:IsA("NumberValue") then f.Value = 100 end end
        
        -- Auto Respawn Rapidíssimo (Clica no GUI sozinho)
        if char.Humanoid.Health <= 0 then
            for _, gui in pairs(player.PlayerGui:GetDescendants()) do
                if gui:IsA("TextButton") and (gui.Text:lower():match("spawn") or gui.Text:lower():match("respawn")) then
                    pcall(function() for _, conn in pairs(getconnections(gui.MouseButton1Click)) do conn:Fire() end end)
                end
            end
        end
    end
end)

player.CharacterAdded:Connect(function(char)
    local hrp = char:WaitForChild("HumanoidRootPart", 5); local hum = char:WaitForChild("Humanoid", 5)
    if hrp and savedRespawnCFrame then task.wait(0.2); hrp.CFrame = savedRespawnCFrame end
    if hum then
        if inventarioIlimitado then hum.WalkSpeed = velocidadeAtual end
        if puloAtual ~= 50 then hum.UseJumpPower = true; hum.JumpPower = puloAtual end
        if hitBoxPequena then
            for _, p in pairs({"BodyDepthScale", "BodyHeightScale", "BodyWidthScale", "HeadScale"}) do if hum:FindFirstChild(p) then hum[p].Value = 0.3 end end
            if hrp then hrp.Size = Vector3.new(1,1,1) end
        end
    end
end)

-- ==========================================
-- ABA 3: INVENTÁRIO VISUAL
-- ==========================================
Instance.new("Frame", pageInv).Size = UDim2.new(1,0,0,1)

local infoInv = Instance.new("TextLabel", pageInv)
infoInv.Size = UDim2.new(0.9, 0, 0, 45); infoInv.BackgroundTransparency = 1
infoInv.Text = "Aviso de Segurança: Clonar itens do lado do cliente é apenas VISUAL. O servidor não aceitará os itens falsos."
infoInv.TextColor3 = Color3.fromRGB(255, 100, 100); infoInv.TextWrapped = true; infoInv.Font = Enum.Font.GothamBold; infoInv.TextSize = 11

local btnAtualizarInv = criarBotao("Atualizar Meus Itens", pageInv, Color3.fromRGB(50, 100, 50))
local listaItensFrame = Instance.new("Frame", pageInv); listaItensFrame.Size = UDim2.new(0.9, 0, 0, 0); listaItensFrame.AutomaticSize = Enum.AutomaticSize.Y; listaItensFrame.BackgroundTransparency = 1
local listaItensLayout = Instance.new("UIListLayout", listaItensFrame); listaItensLayout.Padding = UDim.new(0, 5)

btnAtualizarInv.MouseButton1Click:Connect(function()
    for _, child in pairs(listaItensFrame:GetChildren()) do if child:IsA("Frame") then child:Destroy() end end
    local itensEncontrados = {}
    if player:FindFirstChild("Backpack") then for _, item in pairs(player.Backpack:GetChildren()) do if item:IsA("Tool") then table.insert(itensEncontrados, item) end end end
    
    if #itensEncontrados == 0 then
        local txt = Instance.new("TextLabel", listaItensFrame); txt.Size = UDim2.new(1, 0, 0, 30); txt.BackgroundTransparency = 1; txt.Text = "Inventário vazio."; txt.TextColor3 = Color3.fromRGB(150, 150, 150); txt.Font = Enum.Font.Gotham; txt.TextSize = 13; return
    end
    
    for _, item in ipairs(itensEncontrados) do
        local frameItem = Instance.new("Frame", listaItensFrame); frameItem.Size = UDim2.new(1, 0, 0, 40); frameItem.BackgroundColor3 = Color3.fromRGB(35, 35, 35); Instance.new("UICorner", frameItem).CornerRadius = UDim.new(0, 8)
        local nomeItem = Instance.new("TextLabel", frameItem); nomeItem.Size = UDim2.new(0.6, 0, 1, 0); nomeItem.Position = UDim2.new(0.05, 0, 0, 0); nomeItem.BackgroundTransparency = 1; nomeItem.Text = item.Name; nomeItem.TextColor3 = Color3.fromRGB(255, 255, 255); nomeItem.TextXAlignment = Enum.TextXAlignment.Left; nomeItem.Font = Enum.Font.GothamSemibold; nomeItem.TextSize = 13
        local btnCloneItem = Instance.new("TextButton", frameItem); btnCloneItem.Size = UDim2.new(0.3, 0, 0.8, 0); btnCloneItem.Position = UDim2.new(0.65, 0, 0.1, 0); btnCloneItem.BackgroundColor3 = corTema; btnCloneItem.Text = "Clonar"; btnCloneItem.TextColor3 = Color3.fromRGB(0, 0, 0); btnCloneItem.Font = Enum.Font.GothamBold; btnCloneItem.TextSize = 11; Instance.new("UICorner", btnCloneItem).CornerRadius = UDim.new(0, 6)
        
        btnCloneItem.MouseButton1Click:Connect(function()
            if player:FindFirstChild("Backpack") then
                item:Clone().Parent = player.Backpack
                btnCloneItem.Text = "Clonado!"; btnCloneItem.BackgroundColor3 = Color3.fromRGB(50, 200, 50); task.wait(1); btnCloneItem.Text = "Clonar"; btnCloneItem.BackgroundColor3 = corTema
            end
        end)
    end
end)

-- ==========================================
-- LÓGICA GERAL DA JANELA
-- ==========================================
minBtn.MouseButton1Click:Connect(function()
    minimizado = not minimizado
    if minimizado then mainFrame:TweenSize(UDim2.new(0, 420, 0, 35), "Out", "Quad", 0.3, true); tabBar.Visible = false; pageContainer.Visible = false
    else mainFrame:TweenSize(UDim2.new(0, 420, 0, 390), "Out", "Quad", 0.3, true); tabBar.Visible = true; pageContainer.Visible = true end
end)
