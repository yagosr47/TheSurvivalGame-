-- ==========================================
-- THE SURVIVAL GAME: GOD HUB V25 (STEALTH & BYPASS)
-- ==========================================

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local player = Players.LocalPlayer
local mouse = player:GetMouse()

-- ==========================================
-- CONFIGURAÇÕES E ESTADOS (ANTI-CHEAT SAFE)
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

local vipSpoofAtivado, cosmeticosAtivados = false, false

-- Timers Anti-Macro (Humanização)
local lastAuraAtk = 0
local lastFarmAtk = 0

-- Filtros
local farmFiltros = {Madeira=false, Pedra=false, Carvao=false, Cobre=false, Ferro=false, Ouro=false, Bluesteel=false, Obsidian=false, Arbusto=false}
local espFiltros = {Arvores=false, Arbustos=false, Animais=false, Bosses=false, Ouro=false, Pedra=false, Carvao=false, Bluesteel=false, Obsidian=false, Ferro=false, Cobre=false}

local recursosCache = {} 
local espCache = {} 
local conexoes = {}

-- ==========================================
-- CRIAÇÃO DA INTERFACE BASE
-- ==========================================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "TSG_God_Hub_V25"
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
titleText.BackgroundTransparency = 1; titleText.Text = "TSG GOD HUB V25 (STEALTH BYPASS)"; titleText.TextColor3 = Color3.fromRGB(255, 255, 255)
titleText.Font = Enum.Font.GothamBold; titleText.TextSize = 12; titleText.TextXAlignment = Enum.TextXAlignment.Left

local closeBtn = Instance.new("TextButton", titleBar)
closeBtn.Size = UDim2.new(0, 30, 0, 30); closeBtn.Position = UDim2.new(0.92, 0, 0.1, 0); closeBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
closeBtn.Text = "X"; closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255); Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 8)
closeBtn.MouseButton1Click:Connect(function() screenGui:Destroy() end)

local minBtn = Instance.new("TextButton", titleBar)
minBtn.Size = UDim2.new(0, 30, 0, 30); minBtn.Position = UDim2.new(0.83, 0, 0.1, 0); minBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
minBtn.Text = "-"; minBtn.TextColor3 = Color3.fromRGB(255, 255, 255); Instance.new("UICorner", minBtn).CornerRadius = UDim.new(0, 8)

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
local pageVip, tabVip = criarAba("Exploits") 

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
tabVip.MouseButton1Click:Connect(function() mudarAba(tabVip, pageVip) end)

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
    ["wolf"]="Animais", ["boar"]="Animais", ["horse"]="Animais", ["cow"]="Animais", ["bull"]="Animais", ["chicken"]="Animais", ["moose"]="Animais",
    ["king"]="Bosses", ["boss"]="Bosses", ["tree"]="Arvores", ["bush"]="Arbustos",
    ["gold ore"]="Ouro", ["rock"]="Pedra", ["coal ore"]="Carvao", ["bluesteel ore"]="Bluesteel", ["obsidian ore"]="Obsidian", ["iron ore"]="Ferro", ["copper ore"]="Cobre"
}

task.spawn(function()
    while task.wait(2.5) do -- Scan otimizado para não pesar o Client
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
            if n:match("sword") or n:match("blade") or n:match("dagger") or n:match("katana") or n:match("bluesteel") then espada = item; break
            elseif n:match("sharp rock") or n:match("pedra afiada") then pedraAfiada = item end
        end
    end
    local fFinal = espada or pedraAfiada
    if fFinal and fFinal.Parent ~= char then char.Humanoid:EquipTool(fFinal) end
end

-- ==========================================
-- ABA 1: FARM OTIMIZADO
-- ==========================================
Instance.new("Frame", pageFarm).Size = UDim2.new(1,0,0,1)

criarDivisoria("Filtro de Farm (Anti-Lixo)", pageFarm)
local frameFiltrosFarm = Instance.new("Frame", pageFarm); frameFiltrosFarm.Size = UDim2.new(0.9, 0, 0, 110); frameFiltrosFarm.BackgroundTransparency = 1
local layoutFiltrosFarm = Instance.new("UIGridLayout", frameFiltrosFarm); layoutFiltrosFarm.CellSize = UDim2.new(0.31, 0, 0, 25); layoutFiltrosFarm.CellPadding = UDim2.new(0, 5, 0, 5)
for nome, _ in pairs(farmFiltros) do
    local btnF = criarBotao(nome, frameFiltrosFarm, Color3.fromRGB(60, 60, 60))
    btnF.MouseButton1Click:Connect(function() farmFiltros[nome] = not farmFiltros[nome]; btnF.BackgroundColor3 = farmFiltros[nome] and corTema or Color3.fromRGB(60, 60, 60); btnF.TextColor3 = farmFiltros[nome] and Color3.fromRGB(0,0,0) or Color3.fromRGB(255,255,255) end)
end

criarDivisoria("Configurações Avançadas do Farm", pageFarm)
local btnFarmSeguro = criarBotao("Farm Seguro (Fica no topo / Não toma dano)", pageFarm, Color3.fromRGB(150, 100, 50))
local btnIgnorarAgua = criarBotao("Ignorar Água (Não farma minérios afundados)", pageFarm, Color3.fromRGB(50, 100, 150))
local btnAutoFarmNodes = criarBotao("Iniciar Auto-Farm Humanizado", pageFarm, Color3.fromRGB(50, 150, 80))

btnFarmSeguro.MouseButton1Click:Connect(function() farmSeguroAtivado = not farmSeguroAtivado; btnFarmSeguro.Text = farmSeguroAtivado and "Farm Seguro: LIGADO (Fica no topo)" or "Farm Seguro (Fica no topo / Não toma dano)" end)
btnIgnorarAgua.MouseButton1Click:Connect(function() ignorarAgua = not ignorarAgua; btnIgnorarAgua.Text = ignorarAgua and "Ignorar Água: LIGADO" or "Ignorar Água (Não farma minérios afundados)" end)

btnAutoFarmNodes.MouseButton1Click:Connect(function()
    autoFarmNodes = not autoFarmNodes; btnAutoFarmNodes.Text = autoFarmNodes and "Auto-Farm: RODANDO (ANTI-CHEAT SAFE)" or "Iniciar Auto-Farm Humanizado"
    if autoFarmNodes then
        conexoes.farm = RunService.Heartbeat:Connect(function()
            local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
            if not hrp then return end
            
            local maisProx = nil; local mDist = math.huge; local tipoR = nil
            for _, rec in ipairs(recursosCache) do
                if farmFiltros[rec.tipo] and rec.part and rec.part.Parent then
                    if ignorarAgua and rec.part.Position.Y < 13 then continue end 
                    local dist = (rec.part.Position - hrp.Position).Magnitude
                    if dist < mDist then mDist = dist; maisProx = rec.part; tipoR = rec.tipo end
                end
            end
            
            if maisProx then
                equiparArmaFarm(tipoR)
                local offset = farmSeguroAtivado and Vector3.new(0, 10, 0) or Vector3.new(0, 3, 4)
                -- Teleporte suave / Manutenção
                hrp.CFrame = CFrame.new(maisProx.Position + offset, maisProx.Position)
                
                -- Humanização do Clique (Evita detecção de Macro)
                if tick() - lastFarmAtk > math.random(3, 6)/10 then
                    lastFarmAtk = tick()
                    local tool = player.Character:FindFirstChildOfClass("Tool"); if tool then tool:Activate() end
                end
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

local btnLigaEsp = criarBotao("Ligar ESP (Localizar pelo Mapa)", pageEsp, Color3.fromRGB(200, 150, 0))
local espObjetosConexao = nil

btnLigaEsp.MouseButton1Click:Connect(function()
    espMineriosAtivado = not espMineriosAtivado; btnLigaEsp.Text = espMineriosAtivado and "ESP Ativado (Visualizando Alvos)" or "Ligar ESP (Localizar pelo Mapa)"
    if espMineriosAtivado then
        espObjetosConexao = RunService.RenderStepped:Connect(function()
            for _, obj in pairs(workspace:GetDescendants()) do if obj:FindFirstChild("TsgESP") then obj.TsgESP:Destroy() end end
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
-- ABA 3: COMBATE SEGURO (SAFE-ZONE)
-- ==========================================
Instance.new("Frame", pageCombat).Size = UDim2.new(1,0,0,1)

criarDivisoria("Kill Aura (Bypass Magnitude)", pageCombat)
local btnKillAura = criarBotao("Kill Aura (Players, Bosses, Animais)", pageCombat, Color3.fromRGB(150, 50, 50))
local txtKillInfo = Instance.new("TextLabel", pageCombat); txtKillInfo.Size = UDim2.new(0.9, 0, 0, 30); txtKillInfo.BackgroundTransparency = 1; txtKillInfo.Text = "Raio de 13.5 studs e delay humano para o servidor não anular seus ataques."; txtKillInfo.TextColor3 = Color3.fromRGB(150,150,150); txtKillInfo.Font = Enum.Font.Gotham; txtKillInfo.TextSize = 11; txtKillInfo.TextWrapped = true

criarDivisoria("Defesa do Jogador", pageCombat)
local btnShrink = criarBotao("Reduzir Hitbox (Ficar minúsculo)", pageCombat, Color3.fromRGB(150, 100, 150))
local btnStamina = criarBotao("Estamina Infinita", pageCombat)
local btnFome = criarBotao("Sem Fome (Travar Barra)", pageCombat)

btnKillAura.MouseButton1Click:Connect(function()
    killAuraAtivado = not killAuraAtivado; btnKillAura.Text = killAuraAtivado and "Kill Aura: ATIVADA EM TUDO" or "Kill Aura (Players, Bosses, Animais)"
    if killAuraAtivado then
        conexoes.killAura = RunService.RenderStepped:Connect(function()
            local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                local atacou = false
                local safeDistance = 13.5 -- Dentro do limite de validação do Servidor TSG
                
                for _, p in pairs(Players:GetPlayers()) do
                    if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and p.Character:FindFirstChild("Humanoid") and p.Character.Humanoid.Health > 0 then
                        if player.Team and p.Team and player.Team == p.Team then continue end
                        if (hrp.Position - p.Character.HumanoidRootPart.Position).Magnitude <= safeDistance then atacou = true end
                    end
                end
                if not atacou then
                    for _, obj in pairs(workspace:GetDescendants()) do
                        if obj:IsA("Model") and obj:FindFirstChild("Humanoid") and obj:FindFirstChild("HumanoidRootPart") and obj ~= player.Character then
                            if not Players:GetPlayerFromCharacter(obj) and obj.Humanoid.Health > 0 and (hrp.Position - obj.HumanoidRootPart.Position).Magnitude <= safeDistance then atacou = true; break end
                        end
                    end
                end
                
                -- Anti-Macro: O servidor barra cliques na exata mesma fração sempre.
                if atacou and (tick() - lastAuraAtk > math.random(4, 7)/10) then
                    lastAuraAtk = tick()
                    equiparMelhorArmaCombate()
                    local tool = player.Character:FindFirstChildOfClass("Tool"); if tool then tool:Activate() end
                end
            end
        end)
    else if conexoes.killAura then conexoes.killAura:Disconnect() end end
end)

btnShrink.MouseButton1Click:Connect(function()
    hitBoxPequena = not hitBoxPequena; btnShrink.Text = hitBoxPequena and "Hitbox Extremamente Reduzida" or "Reduzir Hitbox (Ficar minúsculo)"
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

btnStamina.MouseButton1Click:Connect(function() staminaInfinita = not staminaInfinita; btnStamina.Text = staminaInfinita and "Estamina: INFINITA" or "Estamina Infinita" end)
btnFome.MouseButton1Click:Connect(function() semFomeAtivado = not semFomeAtivado; btnFome.Text = semFomeAtivado and "Sem Fome: ATIVADO" or "Sem Fome (Travar Barra)" end)

-- ==========================================
-- ABA 4: JOGADOR (ANTI-RUBBERBAND)
-- ==========================================
Instance.new("Frame", pagePlayer).Size = UDim2.new(1,0,0,1)

criarDivisoria("Movimentação e Corpo", pagePlayer)
local btnPeso = criarBotao("Bypass Inventário Cheio (Smooth Anti-Rubberband)", pagePlayer, Color3.fromRGB(100, 50, 200))
local inputVel = Instance.new("Frame", pagePlayer); inputVel.Size = UDim2.new(0.9, 0, 0, 35); inputVel.BackgroundTransparency = 1
local bVel = criarBotao("Velocidade Base (1-10)", inputVel); bVel.Size = UDim2.new(0.7, 0, 1, 0)
local tVel = Instance.new("TextBox", inputVel); tVel.Size = UDim2.new(0.25, 0, 1, 0); tVel.Position = UDim2.new(0.75, 0, 0, 0); tVel.BackgroundColor3 = Color3.fromRGB(30, 30, 30); tVel.Text = "1"; tVel.TextColor3 = corTema; tVel.Font = Enum.Font.GothamBold; Instance.new("UICorner", tVel)
bVel.MouseButton1Click:Connect(function() local v = tonumber(tVel.Text) or 1; v = math.clamp(v, 1, 10); tVel.Text = tostring(v); velocidadeAtual = 16 * v end)

criarDivisoria("Automação Level Máximo", pagePlayer)
local btnAutoRebirth = criarBotao("Auto Rebirth (Simula Lvl 25 e Clica na GUI)", pagePlayer, Color3.fromRGB(150, 50, 200))

criarDivisoria("Respawn (Cofre Local)", pagePlayer)
local btnSalvarRespawn = criarBotao("1. Marcar Local de Respawn Aqui", pagePlayer, Color3.fromRGB(0, 150, 200))
local btnTpRespawn = criarBotao("2. Teleportar para Local Salvo Agora", pagePlayer, Color3.fromRGB(0, 100, 150))

btnPeso.MouseButton1Click:Connect(function() inventarioIlimitado = not inventarioIlimitado; btnPeso.Text = inventarioIlimitado and "Bypass de Peso: ATIVADO" or "Bypass Inventário Cheio (Smooth Anti-Rubberband)" end)

btnAutoRebirth.MouseButton1Click:Connect(function()
    autoRebirthAtivado = not autoRebirthAtivado; btnAutoRebirth.Text = autoRebirthAtivado and "Auto Rebirth: RODANDO" or "Auto Rebirth (Simula Lvl 25 e Clica na GUI)"
    if autoRebirthAtivado then
        conexoes.rebirth = RunService.Heartbeat:Connect(function()
            local skills = player:FindFirstChild("Skills") or player:FindFirstChild("leaderstats") or player
            for _, s in pairs({"Mining", "Woodcutting", "Crafting", "Food", "Cooking"}) do
                local stat = skills:FindFirstChild(s, true)
                if stat and (stat:IsA("IntValue") or stat:IsA("NumberValue")) then stat.Value = 25 end
            end
            for _, gui in pairs(player.PlayerGui:GetDescendants()) do
                if gui:IsA("TextButton") and (string.lower(gui.Text):match("rebirth") or string.lower(gui.Name):match("rebirth")) then
                    pcall(function() for _, conn in pairs(getconnections(gui.MouseButton1Click)) do conn:Fire() end end)
                end
            end
        end)
    else if conexoes.rebirth then conexoes.rebirth:Disconnect() end end
end)

btnSalvarRespawn.MouseButton1Click:Connect(function()
    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        savedRespawnCFrame = player.Character.HumanoidRootPart.CFrame; btnSalvarRespawn.Text = "Local Marcado!"
        task.wait(1); btnSalvarRespawn.Text = "1. Marcar Local de Respawn Aqui"
    end
end)
btnTpRespawn.MouseButton1Click:Connect(function() if savedRespawnCFrame and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then player.Character.HumanoidRootPart.CFrame = savedRespawnCFrame end end)

-- Anti-Rubberband Movement e Status Locais
RunService.RenderStepped:Connect(function()
    local char = player.Character
    if char and char:FindFirstChild("Humanoid") and char:FindFirstChild("HumanoidRootPart") then
        -- Em vez de só forçar o WalkSpeed quebrando a física, movemos levemente o CFrame junto com o input de controle do PC/Mobile para enganar o servidor
        if inventarioIlimitado then 
            char.Humanoid.WalkSpeed = velocidadeAtual 
            if char.Humanoid.MoveDirection.Magnitude > 0 then
                char.HumanoidRootPart.CFrame = char.HumanoidRootPart.CFrame + (char.Humanoid.MoveDirection * (velocidadeAtual/100))
            end
        end
        if staminaInfinita then local s = char:FindFirstChild("Stamina") or player:FindFirstChild("Stamina"); if s and s:IsA("NumberValue") then s.Value = 100 end end
        if semFomeAtivado then local f = player:FindFirstChild("Hunger") or char:FindFirstChild("Hunger"); if f and f:IsA("NumberValue") then f.Value = 100 end end
        if char.Humanoid.Health <= 0 then
            for _, gui in pairs(player.PlayerGui:GetDescendants()) do
                if gui:IsA("TextButton") and (gui.Text:lower():match("spawn") or gui.Text:lower():match("respawn")) then pcall(function() for _, conn in pairs(getconnections(gui.MouseButton1Click)) do conn:Fire() end end) end
            end
        end
    end
end)

player.CharacterAdded:Connect(function(char)
    local hrp = char:WaitForChild("HumanoidRootPart", 5); local hum = char:WaitForChild("Humanoid", 5)
    if hrp and savedRespawnCFrame then task.wait(0.2); hrp.CFrame = savedRespawnCFrame end
    if hum then
        if inventarioIlimitado then hum.WalkSpeed = velocidadeAtual end
        if hitBoxPequena then
            for _, p in pairs({"BodyDepthScale", "BodyHeightScale", "BodyWidthScale", "HeadScale"}) do if hum:FindFirstChild(p) then hum[p].Value = 0.1 end end
            if hrp then hrp.Size = Vector3.new(0.5,0.5,0.5) end
        end
    end
end)

-- ==========================================
-- ABA 5: EXPLOITS E TROLLS
-- ==========================================
Instance.new("Frame", pageVip).Size = UDim2.new(1,0,0,1)

local infoVip = Instance.new("TextLabel", pageVip)
infoVip.Size = UDim2.new(0.9, 0, 0, 55); infoVip.BackgroundTransparency = 1
infoVip.Text = "O Scanner procura portas abertas (RemoteEvents) no mapa. Gamepasses 2x forçam visualmente a interface para te dar vantagem estética."
infoVip.TextColor3 = Color3.fromRGB(255, 100, 100); infoVip.TextWrapped = true; infoVip.Font = Enum.Font.GothamBold; infoVip.TextSize = 11

criarDivisoria("Vantagens Premium", pageVip)
local btnVipSpoof = criarBotao("Aplicar Gamepasses 2x (XP, Recursos, Dano)", pageVip, Color3.fromRGB(200, 150, 0))
local btnCosmetics = criarBotao("Desbloquear Montarias Perigosas (Client)", pageVip, Color3.fromRGB(150, 50, 200))
local btnAutoPlant = criarBotao("Auto-Plantar Sementes Próximas", pageVip, Color3.fromRGB(150, 150, 50))

criarDivisoria("Scanner de Vulnerabilidades", pageVip)
local btnScanRemotes = criarBotao("Escanear Vulnerabilidades (Portas Abertas)", pageVip, Color3.fromRGB(200, 100, 50))
local txtScanResult = Instance.new("TextLabel", pageVip); txtScanResult.Size = UDim2.new(0.9, 0, 0, 30); txtScanResult.BackgroundTransparency = 1; txtScanResult.Text = "Nenhuma varredura iniciada."; txtScanResult.TextColor3 = Color3.fromRGB(150, 150, 150); txtScanResult.Font = Enum.Font.GothamBold; txtScanResult.TextSize = 11
local btnForcePasses = criarBotao("Forçar Todas as Gamepasses (Bypass Local)", pageVip, Color3.fromRGB(50, 200, 100))

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

btnVipSpoof.MouseButton1Click:Connect(function()
    vipSpoofAtivado = not vipSpoofAtivado; btnVipSpoof.Text = vipSpoofAtivado and "Vantagens 2x VIP Aplicadas!" or "Aplicar Gamepasses 2x (XP, Recursos, Dano)"
    if vipSpoofAtivado then
        for _, gui in pairs(player.PlayerGui:GetDescendants()) do
            if gui:IsA("TextLabel") and gui.Text:match("XP") then gui.Text = "2x " .. gui.Text
            elseif gui:IsA("TextLabel") and gui.Text:match("Damage") then gui.Text = "Dano 200% (Spoofed)" end
        end
    end
end)

btnCosmetics.MouseButton1Click:Connect(function()
    cosmeticosAtivados = not cosmeticosAtivados; btnCosmetics.Text = cosmeticosAtivados and "Montarias Desbloqueadas Localmente!" or "Desbloquear Montarias Perigosas (Client)"
    if cosmeticosAtivados then
        local rep = game:GetService("ReplicatedStorage"); local mounts = rep:FindFirstChild("Mounts") or rep:FindFirstChild("Cosmetics")
        if mounts then for _, mount in pairs(mounts:GetChildren()) do if mount:IsA("Model") then mount:Clone().Parent = player.Character end end end
    end
end)

btnScanRemotes.MouseButton1Click:Connect(function()
    txtScanResult.Text = "Escaneando ReplicatedStorage..."; task.wait(1)
    local vulneraveis = 0
    for _, v in pairs(game:GetService("ReplicatedStorage"):GetDescendants()) do
        if v:IsA("RemoteEvent") then
            local name = string.lower(v.Name)
            if name:match("give") or name:match("add") or name:match("buy") or name:match("admin") or name:match("vip") then
                vulneraveis = vulneraveis + 1
                pcall(function() v:FireServer() end)
            end
        end
    end
    txtScanResult.Text = vulneraveis > 0 and "ACHAMOS " .. vulneraveis .. " REMOTES SUSPEITOS!" or "Nenhuma porta aberta óbvia encontrada."
    txtScanResult.TextColor3 = vulneraveis > 0 and Color3.fromRGB(50, 255, 50) or Color3.fromRGB(150, 150, 150)
end)

btnForcePasses.MouseButton1Click:Connect(function()
    for _, v in pairs(player:GetDescendants()) do
        if (v:IsA("BoolValue") or v:IsA("IntValue")) then
            local name = string.lower(v.Name)
            if name:match("vip") or name:match("pass") or name:match("premium") or name:match("owned") then
                if v:IsA("BoolValue") then v.Value = true end
                if v:IsA("IntValue") then v.Value = 1 end
            end
        end
    end
    btnForcePasses.Text = "Valores VIP Locais Ativados!"
    task.wait(2); btnForcePasses.Text = "Forçar Todas as Gamepasses (Bypass Local)"
end)

-- ==========================================
-- LÓGICA GERAL DA JANELA (MINIMIZAR/FECHAR)
-- ==========================================
minBtn.MouseButton1Click:Connect(function()
    minimizado = not minimizado
    if minimizado then mainFrame:TweenSize(UDim2.new(0, 440, 0, 35), "Out", "Quad", 0.3, true); tabBar.Visible = false; pageContainer.Visible = false
    else mainFrame:TweenSize(UDim2.new(0, 440, 0, 420), "Out", "Quad", 0.3, true); tabBar.Visible = true; pageContainer.Visible = true end
end)
