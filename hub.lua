-- ==========================================
-- THE SURVIVAL GAME: GOD HUB V22 (SUPREMO FINAL)
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
local farmSeguroAtivado, ignorarAgua = false, true
local savedRespawnCFrame = nil
local velocidadeAtual, puloAtual = 16, 50

-- Filtros de Farm
local farmFiltros = {Madeira=false, Pedra=false, Carvao=false, Cobre=false, Ferro=false, Ouro=false, Bluesteel=false, Obsidian=false, Arbusto=false}
-- Filtros de ESP
local espFiltros = {Arvores=false, Arbustos=false, Animais=false, Bosses=false, Ouro=false, Pedra=false, Carvao=false, Bluesteel=false, Obsidian=false, Ferro=false, Cobre=false}

local recursosCache = {} 
local espCache = {} 
local conexoes = {}

-- ==========================================
-- CRIAÇÃO DA INTERFACE BASE
-- ==========================================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "TSG_God_Hub_V22"
screenGui.ResetOnSpawn = false
pcall(function() screenGui.Parent = CoreGui end)
if not screenGui.Parent then screenGui.Parent = player:WaitForChild("PlayerGui") end

local mainFrame = Instance.new("Frame", screenGui)
mainFrame.Size = UDim2.new(0, 440, 0, 420); mainFrame.Position = UDim2.new(0.5, -220, 0.5, -210)
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20); mainFrame.BorderSizePixel = 0; mainFrame.Active = true; mainFrame.Draggable = true
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 12)
local mainStroke = Instance.new("UIStroke", mainFrame); mainStroke.Thickness = 2; mainStroke.Color = corTema

local titleBar = Instance.new("Frame", mainFrame)
titleBar.Size = UDim2.new(1, 0, 0, 35); titleBar.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Instance.new("UICorner", titleBar).CornerRadius = UDim.new(0, 12)

local titleText = Instance.new("TextLabel", titleBar)
titleText.Size = UDim2.new(0.6, 0, 1, 0); titleText.Position = UDim2.new(0.05, 0, 0, 0)
titleText.BackgroundTransparency = 1; titleText.Text = "TSG GOD HUB V22 (SUPREMO FINAL)"; titleText.TextColor3 = Color3.fromRGB(255, 255, 255)
titleText.Font = Enum.Font.GothamBold; titleText.TextSize = 12; titleText.TextXAlignment = Enum.TextXAlignment.Left

local closeBtn = Instance.new("TextButton", titleBar)
closeBtn.Size = UDim2.new(0, 30, 0, 30); closeBtn.Position = UDim2.new(0.92, 0, 0.1, 0); closeBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
closeBtn.Text = "X"; closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255); Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 8)
closeBtn.MouseButton1Click:Connect(function() screenGui:Destroy() end)

local minBtn = Instance.new("TextButton", titleBar)
minBtn.Size = UDim2.new(0, 30, 0, 30); minBtn.Position = UDim2.new(0.83, 0, 0.1, 0); minBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
minBtn.Text = "-"; minBtn.TextColor3 = Color3.fromRGB(255, 255, 255); Instance.new("UICorner", minBtn).CornerRadius = UDim.new(0, 8)

-- SISTEMA DE ABAS
local tabBar = Instance.new("Frame", mainFrame)
tabBar.Size = UDim2.new(1, 0, 0, 35); tabBar.Position = UDim2.new(0, 0, 0, 35); tabBar.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
local tabLayout = Instance.new("UIListLayout", tabBar); tabLayout.FillDirection = Enum.FillDirection.Horizontal

local pageContainer = Instance.new("Frame", mainFrame)
pageContainer.Size = UDim2.new(1, 0, 1, -70); pageContainer.Position = UDim2.new(0, 0, 0, 70); pageContainer.BackgroundTransparency = 1

local function criarAba(nome)
    local btn = Instance.new("TextButton", tabBar)
    btn.Size = UDim2.new(0.2, 0, 1, 0); btn.BackgroundTransparency = 1; btn.Text = nome
    btn.TextColor3 = Color3.fromRGB(200, 200, 200); btn.Font = Enum.Font.GothamSemibold; btn.TextSize = 11
    
    local page = Instance.new("ScrollingFrame", pageContainer)
    page.Size = UDim2.new(1, 0, 1, 0); page.BackgroundTransparency = 1; page.ScrollBarThickness = 4; page.Visible = false
    page.AutomaticCanvasSize = Enum.AutomaticSize.Y; page.CanvasSize = UDim2.new(0, 0, 0, 0)
    local layout = Instance.new("UIListLayout", page); layout.Padding = UDim.new(0, 8); layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    return page, btn
end

local pageFarm, tabFarm = criarAba("Farm")
local pageEsp, tabEsp = criarAba("Visuals")
local pageCombat, tabCombat = criarAba("Combate")
local pagePlayer, tabPlayer = criarAba("Jogador")
local pageTroll, tabTroll = criarAba("Outros")

pageFarm.Visible = true; tabFarm.TextColor3 = corTema

local function mudarAba(btnAtivo, pageAtiva)
    for _, btn in pairs(tabBar:GetChildren()) do if btn:IsA("TextButton") then btn.TextColor3 = Color3.fromRGB(200, 200, 200) end end
    for _, pg in pairs(pageContainer:GetChildren()) do if pg:IsA("ScrollingFrame") then pg.Visible = false end end
    btnAtivo.TextColor3 = corTema; pageAtiva.Visible = true
end
tabFarm.MouseButton1Click:Connect(function() mudarAba(tabFarm, pageFarm) end)
tabEsp.MouseButton1Click:Connect(function() mudarAba(tabEsp, pageEsp) end)
tabCombat.MouseButton1Click:Connect(function() mudarAba(tabCombat, pageCombat) end)
tabPlayer.MouseButton1Click:Connect(function() mudarAba(tabPlayer, pagePlayer) end)
tabTroll.MouseButton1Click:Connect(function() mudarAba(tabTroll, pageTroll) end)

local function criarBotao(texto, parent, cor)
    local btn = Instance.new("TextButton", parent)
    btn.Size = UDim2.new(0.9, 0, 0, 35); btn.BackgroundColor3 = cor or Color3.fromRGB(40, 40, 40)
    btn.Text = texto; btn.TextColor3 = Color3.fromRGB(255, 255, 255); btn.Font = Enum.Font.GothamSemibold; btn.TextSize = 12
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
    return btn
end
local function criarDivisoria(texto, parent)
    local txt = Instance.new("TextLabel", parent); txt.Size = UDim2.new(0.9, 0, 0, 20); txt.BackgroundTransparency = 1; txt.Text = "--- " .. texto .. " ---"
    txt.TextColor3 = corTema; txt.Font = Enum.Font.GothamBold; txt.TextSize = 11
end

-- ==========================================
-- IA DE CACHE (ANTI-LAG) E NOMES EXATOS
-- ==========================================
local valFarm = {
    ["tree"]="Madeira", ["oak tree"]="Madeira", ["pine tree"]="Madeira", ["palm tree"]="Madeira",
    ["rock"]="Pedra", ["boulder"]="Pedra", ["bush"]="Arbusto",
    ["copper ore"]="Cobre", ["iron ore"]="Ferro", ["gold ore"]="Ouro", ["coal ore"]="Carvao", 
    ["bluesteel ore"]="Bluesteel", ["obsidian ore"]="Obsidian"
}

local valEsp = {
    ["wolf"]="Animais", ["boar"]="Animais", ["horse"]="Animais", ["cow"]="Animais", ["bull"]="Animais", ["chicken"]="Animais",
    ["king"]="Bosses", ["boss"]="Bosses", ["tree"]="Arvores", ["bush"]="Arbustos",
    ["gold ore"]="Ouro", ["rock"]="Pedra", ["coal ore"]="Carvao", ["bluesteel ore"]="Bluesteel", ["obsidian ore"]="Obsidian", ["iron ore"]="Ferro", ["copper ore"]="Cobre"
}

task.spawn(function()
    while task.wait(2) do
        local cF, cE = {}, {}
        for _, obj in pairs(workspace:GetDescendants()) do
            if obj:IsA("Model") then
                local n = string.lower(obj.Name)
                local pPart = obj.PrimaryPart or obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChildWhichIsA("BasePart")
                if pPart then
                    if valFarm[n] then table.insert(cF, {part = pPart, tipo = valFarm[n]}) end
                    if valEsp[n] then table.insert(cE, {obj = obj, pPart = pPart, tipo = valEsp[n], nome = obj.Name}) end
                end
            end
        end
        recursosCache = cF; espCache = cE
    end
end)

local function equiparArmaFarm(tipoRecurso)
    local char = player.Character; local bp = player:FindFirstChild("Backpack"); if not char or not bp then return end
    local pref = "Pickaxe"
    if tipoRecurso == "Madeira" or tipoRecurso == "Arbusto" then pref = "Axe" end
    
    local itens = bp:GetChildren(); for _, v in pairs(char:GetChildren()) do table.insert(itens, v) end
    local ferramenta = nil; local fallback = nil
    for _, item in pairs(itens) do
        if item:IsA("Tool") then
            local n = string.lower(item.Name)
            if n:match(string.lower(pref)) then ferramenta = item; break end
            if n:match("rock") then fallback = item end
        end
    end
    local fFinal = ferramenta or fallback
    if fFinal and fFinal.Parent ~= char then char.Humanoid:EquipTool(fFinal) end
end

local function equiparMelhorArmaCombate()
    local char = player.Character; local bp = player:FindFirstChild("Backpack"); if not char or not bp then return end
    local itens = bp:GetChildren(); for _, v in pairs(char:GetChildren()) do table.insert(itens, v) end
    local espada = nil; local pedraAfiada = nil
    for _, item in pairs(itens) do
        if item:IsA("Tool") then
            local n = string.lower(item.Name)
            if n:match("sword") or n:match("blade") or n:match("dagger") or n:match("katana") then espada = item; break
            elseif n:match("sharp rock") or n:match("pedra afiada") then pedraAfiada = item end
        end
    end
    local fFinal = espada or pedraAfiada
    if fFinal and fFinal.Parent ~= char then char.Humanoid:EquipTool(fFinal) end
end

-- ==========================================
-- ABA 1: FARM 
-- ==========================================
Instance.new("Frame", pageFarm).Size = UDim2.new(1,0,0,1)

criarDivisoria("Filtro de Farm", pageFarm)
local frameFiltrosFarm = Instance.new("Frame", pageFarm); frameFiltrosFarm.Size = UDim2.new(0.9, 0, 0, 110); frameFiltrosFarm.BackgroundTransparency = 1
local layoutFiltrosFarm = Instance.new("UIGridLayout", frameFiltrosFarm); layoutFiltrosFarm.CellSize = UDim2.new(0.31, 0, 0, 25); layoutFiltrosFarm.CellPadding = UDim2.new(0, 5, 0, 5)
for nome, _ in pairs(farmFiltros) do
    local btnF = criarBotao(nome, frameFiltrosFarm, Color3.fromRGB(60, 60, 60))
    btnF.MouseButton1Click:Connect(function() farmFiltros[nome] = not farmFiltros[nome]; btnF.BackgroundColor3 = farmFiltros[nome] and corTema or Color3.fromRGB(60, 60, 60); btnF.TextColor3 = farmFiltros[nome] and Color3.fromRGB(0,0,0) or Color3.fromRGB(255,255,255) end)
end

criarDivisoria("Configurações do Farm", pageFarm)
local btnFarmSeguro = criarBotao("Farm Seguro (Teleporta acima p/ Não tomar dano)", pageFarm, Color3.fromRGB(150, 100, 50))
local btnIgnorarAgua = criarBotao("Ignorar Água (Não farma minérios afundados)", pageFarm, Color3.fromRGB(50, 100, 150))
local btnAutoFarmNodes = criarBotao("Iniciar Auto-Farm (Otimizado)", pageFarm, Color3.fromRGB(50, 150, 80))

btnFarmSeguro.MouseButton1Click:Connect(function() farmSeguroAtivado = not farmSeguroAtivado; btnFarmSeguro.Text = farmSeguroAtivado and "Farm Seguro: LIGADO (Cima)" or "Farm Seguro (Teleporta acima p/ Não tomar dano)" end)
btnIgnorarAgua.MouseButton1Click:Connect(function() ignorarAgua = not ignorarAgua; btnIgnorarAgua.Text = ignorarAgua and "Ignorar Água: LIGADO" or "Ignorar Água (Não farma minérios afundados)" end)

btnAutoFarmNodes.MouseButton1Click:Connect(function()
    autoFarmNodes = not autoFarmNodes; btnAutoFarmNodes.Text = autoFarmNodes and "Auto-Farm: RODANDO" or "Iniciar Auto-Farm (Otimizado)"
    if autoFarmNodes then
        conexoes.farm = RunService.Heartbeat:Connect(function()
            local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
            if not hrp then return end
            
            local maisProx = nil; local mDist = math.huge; local tipoR = nil
            for _, rec in ipairs(recursosCache) do
                if farmFiltros[rec.tipo] and rec.part and rec.part.Parent then
                    -- Ignorar água: O nível do mar no Roblox geralmente é 0 ou próximo a 14 no TSG. Vamos usar < 13
                    if ignorarAgua and rec.part.Position.Y < 13 then continue end
                    local dist = (rec.part.Position - hrp.Position).Magnitude
                    if dist < mDist then mDist = dist; maisProx = rec.part; tipoR = rec.tipo end
                end
            end
            
            if maisProx then
                equiparArmaFarm(tipoR)
                local offset = farmSeguroAtivado and Vector3.new(0, 12, 0) or Vector3.new(0, 3, 4)
                hrp.CFrame = CFrame.new(maisProx.Position + offset, maisProx.Position)
                local tool = player.Character:FindFirstChildOfClass("Tool"); if tool then tool:Activate() end
            end
        end)
    else if conexoes.farm then conexoes.farm:Disconnect() end end
end)

-- ==========================================
-- ABA 2: VISUALS (ESP FILTRADO)
-- ==========================================
Instance.new("Frame", pageEsp).Size = UDim2.new(1,0,0,1)

criarDivisoria("Filtros do ESP", pageEsp)
local frameFiltrosEsp = Instance.new("Frame", pageEsp); frameFiltrosEsp.Size = UDim2.new(0.9, 0, 0, 110); frameFiltrosEsp.BackgroundTransparency = 1
local layoutFiltrosEsp = Instance.new("UIGridLayout", frameFiltrosEsp); layoutFiltrosEsp.CellSize = UDim2.new(0.31, 0, 0, 25); layoutFiltrosEsp.CellPadding = UDim2.new(0, 5, 0, 5)
for nome, _ in pairs(espFiltros) do
    local btnF = criarBotao(nome, frameFiltrosEsp, Color3.fromRGB(60, 60, 60))
    btnF.MouseButton1Click:Connect(function() espFiltros[nome] = not espFiltros[nome]; btnF.BackgroundColor3 = espFiltros[nome] and corTema or Color3.fromRGB(60, 60, 60); btnF.TextColor3 = espFiltros[nome] and Color3.fromRGB(0,0,0) or Color3.fromRGB(255,255,255) end)
end

local btnLigaEsp = criarBotao("Ligar ESPs Selecionados", pageEsp, Color3.fromRGB(200, 150, 0))
local espObjetosConexao = nil

btnLigaEsp.MouseButton1Click:Connect(function()
    espMineriosAtivado = not espMineriosAtivado; btnLigaEsp.Text = espMineriosAtivado and "ESP Ativado" or "Ligar ESPs Selecionados"
    if espMineriosAtivado then
        espObjetosConexao = RunService.RenderStepped:Connect(function()
            -- Limpa antigos não filtrados
            for _, obj in pairs(workspace:GetDescendants()) do if obj:FindFirstChild("TsgESP") then obj.TsgESP:Destroy() end end
            -- Aplica nos novos da cache
            for _, item in ipairs(espCache) do
                if espFiltros[item.tipo] and item.obj.Parent and item.pPart then
                    local bgui = Instance.new("BillboardGui", item.pPart); bgui.Name = "TsgESP"; bgui.Size = UDim2.new(0, 100, 0, 30); bgui.AlwaysOnTop = true
                    local txt = Instance.new("TextLabel", bgui); txt.Size = UDim2.new(1, 0, 1, 0); txt.BackgroundTransparency = 1; txt.Text = item.nome; txt.TextColor3 = Color3.fromRGB(255, 200, 0); txt.TextStrokeTransparency = 0; txt.Font = Enum.Font.GothamBold
                end
            end
        end)
    else
        if espObjetosConexao then espObjetosConexao:Disconnect() end
        for _, obj in pairs(workspace:GetDescendants()) do if obj:FindFirstChild("TsgESP") then obj.TsgESP:Destroy() end end
    end
end)

-- ==========================================
-- ABA 3: COMBATE (KILL AURA MÁXIMA)
-- ==========================================
Instance.new("Frame", pageCombat).Size = UDim2.new(1,0,0,1)

criarDivisoria("Sistemas de Mira e Dano", pageCombat)
local btnKillAura = criarBotao("Kill Aura (Players, Mobs e Bosses)", pageCombat, Color3.fromRGB(150, 50, 50))
local txtKillInfo = Instance.new("TextLabel", pageCombat); txtKillInfo.Size = UDim2.new(0.9, 0, 0, 20); txtKillInfo.BackgroundTransparency = 1; txtKillInfo.Text = "Usa Espada ou Pedra Afiada automaticamente."; txtKillInfo.TextColor3 = Color3.fromRGB(150,150,150); txtKillInfo.Font = Enum.Font.Gotham; txtKillInfo.TextSize = 11

btnKillAura.MouseButton1Click:Connect(function()
    killAuraAtivado = not killAuraAtivado; btnKillAura.Text = killAuraAtivado and "Kill Aura: ATIVADA EM TUDO" or "Kill Aura (Players, Mobs e Bosses)"
    if killAuraAtivado then
        conexoes.killAura = RunService.RenderStepped:Connect(function()
            local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                local atacou = false
                for _, p in pairs(Players:GetPlayers()) do
                    if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and p.Character:FindFirstChild("Humanoid") and p.Character.Humanoid.Health > 0 then
                        if player.Team and p.Team and player.Team == p.Team then continue end
                        if (hrp.Position - p.Character.HumanoidRootPart.Position).Magnitude < 18 then atacou = true end
                    end
                end
                if not atacou then
                    for _, obj in pairs(workspace:GetDescendants()) do
                        if obj:IsA("Model") and obj:FindFirstChild("Humanoid") and obj:FindFirstChild("HumanoidRootPart") and obj ~= player.Character then
                            if not Players:GetPlayerFromCharacter(obj) and obj.Humanoid.Health > 0 and (hrp.Position - obj.HumanoidRootPart.Position).Magnitude < 18 then atacou = true; break end
                        end
                    end
                end
                if atacou then
                    equiparMelhorArmaCombate()
                    local tool = player.Character:FindFirstChildOfClass("Tool"); if tool then tool:Activate() end
                end
            end
        end)
    else if conexoes.killAura then conexoes.killAura:Disconnect() end end
end)

-- ==========================================
-- ABA 4: JOGADOR (RESPAWN, HITBOX, PESO)
-- ==========================================
Instance.new("Frame", pagePlayer).Size = UDim2.new(1,0,0,1)

criarDivisoria("Defesa e Forma Física", pagePlayer)
local btnShrink = criarBotao("Reduzir Hitbox ao Máximo (Modo Formiga)", pagePlayer, Color3.fromRGB(150, 100, 150))
local btnPeso = criarBotao("Forçar Velocidade (Ignora Inventário Cheio)", pagePlayer, Color3.fromRGB(100, 50, 200))
local inputVel = Instance.new("Frame", pagePlayer); inputVel.Size = UDim2.new(0.9, 0, 0, 35); inputVel.BackgroundTransparency = 1
local bVel = criarBotao("Velocidade Base (1-10)", inputVel); bVel.Size = UDim2.new(0.7, 0, 1, 0)
local tVel = Instance.new("TextBox", inputVel); tVel.Size = UDim2.new(0.25, 0, 1, 0); tVel.Position = UDim2.new(0.75, 0, 0, 0); tVel.BackgroundColor3 = Color3.fromRGB(30, 30, 30); tVel.Text = "1"; tVel.TextColor3 = corTema; tVel.Font = Enum.Font.GothamBold; Instance.new("UICorner", tVel)
bVel.MouseButton1Click:Connect(function() local v = tonumber(tVel.Text) or 1; v = math.clamp(v, 1, 10); tVel.Text = tostring(v); velocidadeAtual = 16 * v end)

criarDivisoria("Respawn e Spoof", pagePlayer)
local btnSalvarRespawn = criarBotao("1. Marcar Local de Respawn Aqui", pagePlayer, Color3.fromRGB(0, 150, 200))
local btnTpRespawn = criarBotao("2. Teleportar para Local Salvo Agora", pagePlayer, Color3.fromRGB(0, 100, 150))
local btnSpoofRebirth = criarBotao("Spoof Visual: 100 Rebirths / VIP", pagePlayer, Color3.fromRGB(200, 150, 0))

btnShrink.MouseButton1Click:Connect(function()
    hitBoxPequena = not hitBoxPequena; btnShrink.Text = hitBoxPequena and "Hitbox Extremamente Reduzida" or "Reduzir Hitbox ao Máximo (Modo Formiga)"
    local char = player.Character; local hum = char and char:FindFirstChild("Humanoid")
    if char and hum then
        if hitBoxPequena then
            for _, p in pairs({"BodyDepthScale", "BodyHeightScale", "BodyWidthScale", "HeadScale"}) do if hum:FindFirstChild(p) then hum[p].Value = 0.1 end end
            local hrp = char:FindFirstChild("HumanoidRootPart"); if hrp then hrp.Size = Vector3.new(0.5,0.5,0.5) end
        else
            for _, p in pairs({"BodyDepthScale", "BodyHeightScale", "BodyWidthScale", "HeadScale"}) do if hum:FindFirstChild(p) then hum[p].Value = 1 end end
            local hrp = char:FindFirstChild("HumanoidRootPart"); if hrp then hrp.Size = Vector3.new(2,2,1) end
        end
    end
end)

btnSalvarRespawn.MouseButton1Click:Connect(function()
    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        savedRespawnCFrame = player.Character.HumanoidRootPart.CFrame; btnSalvarRespawn.Text = "Local Marcado!"
        task.wait(1); btnSalvarRespawn.Text = "1. Marcar Local de Respawn Aqui"
    end
end)

btnTpRespawn.MouseButton1Click:Connect(function()
    if savedRespawnCFrame and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        player.Character.HumanoidRootPart.CFrame = savedRespawnCFrame
    end
end)

btnPeso.MouseButton1Click:Connect(function() inventarioIlimitado = not inventarioIlimitado; btnPeso.Text = inventarioIlimitado and "Ignorar Peso: ATIVADO" or "Forçar Velocidade (Ignora Inventário Cheio)" end)

btnSpoofRebirth.MouseButton1Click:Connect(function()
    -- ALERTA: Apenas Visual
    local ls = player:FindFirstChild("leaderstats")
    if ls then
        local r = ls:FindFirstChild("Rebirths") or ls:FindFirstChild("Renascimentos")
        if r then r.Value = 100 end
    end
    btnSpoofRebirth.Text = "Spoof Visual Aplicado!"
    task.wait(2); btnSpoofRebirth.Text = "Spoof Visual: 100 Rebirths / VIP"
end)

-- Sistema de RenderStepped para Bypassar a Lentidão
RunService.RenderStepped:Connect(function()
    local char = player.Character
    if char and char:FindFirstChild("Humanoid") then
        if inventarioIlimitado then char.Humanoid.WalkSpeed = velocidadeAtual end
    end
end)

player.CharacterAdded:Connect(function(char)
    local hrp = char:WaitForChild("HumanoidRootPart", 5); local hum = char:WaitForChild("Humanoid", 5)
    if hrp and savedRespawnCFrame then task.wait(0.2); hrp.CFrame = savedRespawnCFrame end
    if hum then
        if inventarioIlimitado then hum.WalkSpeed = velocidadeAtual end
        if puloAtual ~= 50 then hum.UseJumpPower = true; hum.JumpPower = puloAtual end
        if hitBoxPequena then
            for _, p in pairs({"BodyDepthScale", "BodyHeightScale", "BodyWidthScale", "HeadScale"}) do if hum:FindFirstChild(p) then hum[p].Value = 0.1 end end
            if hrp then hrp.Size = Vector3.new(0.5,0.5,0.5) end
        end
    end
end)

-- ==========================================
-- ABA 5: OUTROS E TROLLS
-- ==========================================
Instance.new("Frame", pageTroll).Size = UDim2.new(1,0,0,1)

local btnAutoRebirth = criarBotao("Auto-Rebirth Real (Clica na Estátua)", pageTroll, Color3.fromRGB(150, 50, 200))
local btnAutoPlant = criarBotao("Auto-Plantar Sementes Próximas", pageTroll, Color3.fromRGB(150, 150, 50))
local btnInvis = criarBotao("Ficar Invisível (Auto-Respawn)", pageTroll)

btnAutoPlant.MouseButton1Click:Connect(function()
    autoPlantarAtivado = not autoPlantarAtivado; btnAutoPlant.Text = autoPlantarAtivado and "Auto-Plantar: LIGADO" or "Auto-Plantar Sementes Próximas"
    if autoPlantarAtivado then
        conexoes.plant = RunService.Heartbeat:Connect(function()
            local char = player.Character; local bp = player:FindFirstChild("Backpack"); if not char or not bp then return end
            local soloProximo = false
            for _, obj in pairs(workspace:GetDescendants()) do if obj.Name == "Soil" and obj:IsA("BasePart") and (obj.Position - char.HumanoidRootPart.Position).Magnitude < 10 then soloProximo = true; break end end
            local itens = bp:GetChildren(); for _, v in pairs(char:GetChildren()) do table.insert(itens, v) end
            if not soloProximo then
                for _, item in pairs(itens) do if item:IsA("Tool") and string.lower(item.Name):match("shovel") then if item.Parent ~= char then char.Humanoid:EquipTool(item) end; item:Activate(); break end end
            else
                for _, item in pairs(itens) do if item:IsA("Tool") and (string.lower(item.Name):match("seed") or string.lower(item.Name):match("sapling") or string.lower(item.Name):match("acorn")) then if item.Parent ~= char then char.Humanoid:EquipTool(item) end; item:Activate(); break end end
            end
        end)
    else if conexoes.plant then conexoes.plant:Disconnect() end end
end)

btnAutoRebirth.MouseButton1Click:Connect(function()
    autoRebirthAtivado = not autoRebirthAtivado; btnAutoRebirth.Text = autoRebirthAtivado and "Auto-Rebirth Real: ATIVO" or "Auto-Rebirth Real (Clica na Estátua)"
    if autoRebirthAtivado then
        conexoes.rebirth = RunService.Heartbeat:Connect(function()
            for _, prompt in pairs(workspace:GetDescendants()) do
                if prompt:IsA("ProximityPrompt") and string.lower(prompt.ActionText):match("rebirth") then fireproximityprompt(prompt) end
            end
        end)
    else if conexoes.rebirth then conexoes.rebirth:Disconnect() end end
end)

btnInvis.MouseButton1Click:Connect(function()
    invisivel = not invisivel; btnInvis.Text = invisivel and "Invisibilidade: ATIVADA" or "Ficar Invisível (Auto-Respawn)"
    if player.Character then for _, p in pairs(player.Character:GetDescendants()) do if p:IsA("BasePart") and p.Name ~= "HumanoidRootPart" then p.Transparency = invisivel and 1 or 0 elseif p:IsA("Decal") then p.Transparency = invisivel and 1 or 0 end end end
end)

-- ==========================================
-- LÓGICA DE JANELA
-- ==========================================
minBtn.MouseButton1Click:Connect(function()
    minimizado = not minimizado
    if minimizado then mainFrame:TweenSize(UDim2.new(0, 440, 0, 35), "Out", "Quad", 0.3, true); tabBar.Visible = false; pageContainer.Visible = false
    else mainFrame:TweenSize(UDim2.new(0, 440, 0, 420), "Out", "Quad", 0.3, true); tabBar.Visible = true; pageContainer.Visible = true end
end)
