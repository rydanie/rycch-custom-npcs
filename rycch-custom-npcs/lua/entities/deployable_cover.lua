AddCSLuaFile()

util.PrecacheModel( "models/hunter/tubes/tube4x4x1c.mdl" )

if CLIENT then
surface.CreateFont("OvR_Load_HUD_Holo_1" , {
    font = "Kenney Future Square", --name of font
    size = 60,
    weight = 500,
    blursize = 2;
    scanlines = 2,
    antialias = true,
    underline = false,
    italic = false,
    strikeout = false,
    symbol = false,
    rotary = false,
    shadow = true,
    additive = true,
    outline = false
})
end

ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.Author = "Trench"
ENT.Purpose = "deployable force shield for blocking income small arms fire- has hp and then is destroyed"
ENT.PrintName = "Energy Cover Large"
ENT.Category = "Cover System"
ENT.Spawnable = true
ENT.RenderGroup = RENDERGROUP_TRANSLUCENT
ENT.spawnTime = 0
ENT.totalLifeTime = 12000
ENT.hp = 500
ENT.mmRHAe = 10000 --Controls penetration resistance for ArcCW weapons, high number means no bullets from this pack will penetrate
ENT.CoverRequestQueue = {}
ENT.CoverPointGroup1 = {}
ENT.CoverPointGroup2 = {}
ENT.ServeQueueTimer = 0
ENT.EntType = "Cover"
ENT.Group1SafeClass = nil
ENT.Group2SafeClass = nil

local forceShieldImpactSounds = {
    [1] = "weapons/physcannon/superphys_small_zap1.wav",
    [2] = "weapons/physcannon/superphys_small_zap2.wav",
    [3] = "weapons/physcannon/superphys_small_zap3.wav",
    [4] = "weapons/physcannon/superphys_small_zap4.wav"
}

PrecacheParticleSystem( "vortigaunt_hand_glow" )
util.PrecacheSound("ambient/machines/combine_shield_touch_loop1.wav")
util.PrecacheSound("ambient/levels/labs/electric_explosion5.wav")
util.PrecacheSound("weapons/stunstick/alyx_stunner1.wav")

for impactSound in ipairs(forceShieldImpactSounds) do
    util.PrecacheSound(forceShieldImpactSounds[impactSound])
end

-- To get a read off the table above we only look at first two numbers of HP, since we never go over 999
-- we can do this by dividing by 10 and flooring the result with math.floor  
function ENT:Flicker()
    timer.Create( "shield_flicker_timer" .. tostring(self), .02, 24, function() 
        if !IsValid(self) then return end
        local color = self:GetColor()
        
        if(self.colorModulate == false)then
            color.a = math.abs(math.sin(CurTime()) * 100)
            self:SetColor(color)
        else 
            color.a = 255
            self:SetColor(color)
        end
        self.colorModulate = !self.colorModulate
    end)
end

function ENT:bulletImpactEffect(impactPoint, impactNormal)
    local effectdata = EffectData()
    effectdata:SetNormal(impactNormal)
    effectdata:SetOrigin(impactPoint)
    util.Effect( "AR2Impact", effectdata) 
    util.Effect( "selection_ring", effectdata)
end

function ENT:OnTakeDamage( dmginfo )
    local damage = dmginfo:GetDamage() 
    local HPColorValueIndex = math.floor((self.hp/2)/10)
    
    self:EmitSound(forceShieldImpactSounds[math.random(1,4)], 85)
    self:bulletImpactEffect(dmginfo:GetDamagePosition(), self:GetForward())
    self.hp = self.hp - damage 
    
    --self:SetModelScale(.995, .05)
    timer.Simple(.05, function() 
        if (IsValid(self)) then 
            --self:SetModelScale(1,.05) 
            self:SetModelScale(1,1) 
        end 
    end)

    if(self.hp <= 0) then
        self:Flicker()
        self:EmitSound("ambient/levels/labs/electric_explosion5.wav", 100)
        self:StopSound("ambient/machines/combine_shield_touch_loop1.wav")
        timer.Simple(.48,function()
            if(IsValid(self)) then self:Remove() end
        end)
    end
    -- At the point the ENT:Flicker function is called, the shield's HP will be 0. 
    -- So if we don't cancel the coloring code if shield HP is below 0 the shield will be white since 
    -- the shield's color lookup table doesn't index below 0, which is where we retrieve color values 
    -- indexed for HP values(Less memory efficient, more performance efficient)
    timer.Simple(0.1, function() if IsValid(self) then self:RemoveAllDecals() end end)
end

function ENT:SetupDataTables()
    self:NetworkVar( "Float", 0, "spawnTime" )

    if SERVER then
        self:SetspawnTime( CurTime() )
    end
end

function ENT:Draw()
    self:DrawModel()
    local shieldPos = self:GetPos()
    shieldPos.z = shieldPos.z + 96
    local shieldAngle = self:GetAngles()
    shieldAngle = Angle(0, shieldAngle.y, 90)
end

function ENT:RequestCover(requestingEnt)
    for k,i in pairs (self.CoverRequestQueue) do
        if i == requestingEnt then return end
    end
    table.insert( self.CoverRequestQueue, requestingEnt )
end

function ENT:CheckCoverPointStatus()
    for k,i in pairs (self.CoverPointGroup1) do
        if i.Occupied == true then
            break
        end
        self.Group1SafeClass = nil
    end
end

if SERVER then
    function ENT:Initialize()
        self:SetModel( "models/hunter/tubes/tube4x4x1c.mdl" )
        self:SetRenderMode(RENDERMODE_TRANSCOLOR)
        self:SetMoveType( MOVETYPE_NONE ) --MOVETYPE_NOCLIP )
        self:SetSolid( SOLID_VPHYSICS )
        self:SetCollisionGroup( COLLISION_GROUP_NPC ) 
        self.spawnTime = CurTime()
        --Effects 
        self:SetMaterial("models/props_combine/com_shield001a")--"models/props_combine/stasisshield_sheet")--"models/props_combine/com_shield001a")
        self:SetColor(Color(0, 80, 254,254))
        self:EmitSound("ambient/machines/combine_shield_touch_loop1.wav", 55)
        self:EmitSound("weapons/stunstick/alyx_stunner1.wav",100)
        --ParticleEffectAttach( "vortigaunt_hand_glow", PATTACH_ABSORIGIN_FOLLOW, self, 1)
        --ParticleEffect("vortigaunt_hand_glow", self:GetPos()+self:GetUp()*-40, self:GetAngles(), self)
        self.colorModulate = false
        self:Flicker()
        -- Put default setModelScale in timer too because even though physics are initialized before SetModelScale is called,
        -- SetModelScale finishes its job first, so this will result in it spawning a tiny model collision. 
        timer.Simple( 0, function() self:SetModelScale( 0, 0 ) end) --default of size 0
        timer.Simple( 0, function() self:SetModelScale( 1, .1 ) end ) --grows to size 1
        --Code that defines behavior when entity's lifetime runs out
        --timer.Simple(self.totalLifeTime,function()
        --    if(!IsValid(self)) then return end
        --    self:EmitSound("ambient/levels/labs/electric_explosion5.wav", 100)
        --    self:StopSound("ambient/machines/combine_shield_touch_loop1.wav")
        --    self:Flicker()
        --    timer.Simple(.48,function()
        --        if(IsValid(self)) then self:Remove() end
        --    end)
        --end)

        self.CoverPoint1 = ents.Create("cover_point")
        self.CoverPoint1:SetPos(self:GetPos() - (self:GetForward()*20+self:GetRight()*45+self:GetUp()*20))
        self.CoverPoint1:SetParent(self)
        self.CoverPoint1:Spawn()
        table.insert( self.CoverPointGroup1, self.CoverPoint1 )

        self.CoverPoint2 = ents.Create("cover_point")
        self.CoverPoint2:SetPos(self:GetPos() - (self:GetForward()*20+self:GetRight()*-45+self:GetUp()*20))
        self.CoverPoint2:SetParent(self)
        self.CoverPoint2:Spawn()
        table.insert( self.CoverPointGroup1, self.CoverPoint2 )

        self.CoverPoint3 = ents.Create("cover_point")
        self.CoverPoint3:SetPos(self:GetPos() - (self:GetForward()*150+self:GetRight()*45+self:GetUp()*20))
        self.CoverPoint3:SetParent(self)
        self.CoverPoint3:Spawn()
        table.insert( self.CoverPointGroup2, self.CoverPoint3 )

        self.CoverPoint4 = ents.Create("cover_point")
        self.CoverPoint4:SetPos(self:GetPos() - (self:GetForward()*150+self:GetRight()*-45+self:GetUp()*20))
        self.CoverPoint4:SetParent(self)
        self.CoverPoint4:Spawn()
        table.insert( self.CoverPointGroup2, self.CoverPoint4 )

        print("Table Group1-1", self.CoverPointGroup1[1])
        print("Table Group1-2", self.CoverPointGroup1[2])
        print("Table Group2-1", self.CoverPointGroup2[1])
        print("Table Group2-2", self.CoverPointGroup2[2])

    end

    function ENT:Think()

        if self.ServeQueueTimer < CurTime() and table.Count(self.CoverRequestQueue) > 0 and IsValid(self.CoverRequestQueue[1]) then
            self.ServeQueueTimer = CurTime() + 1
            local QueueNPC = self.CoverRequestQueue[1] 

            --Check which points are safe for the requesting npc
            if self.Group1SafeClass == nil then
                self.Group1SafeClass = QueueNPC.VJ_NPC_Class[1]
                print("set class for group 1 to", self.Group1SafeClass)
            end 

            print("Safe class group 1", self.Group1SafeClass)

            --Assign available safe cover points
            if(self.Group1SafeClass == QueueNPC.VJ_NPC_Class[1]) and !IsValid(QueueNPC.ClaimedCoverPoint) then
                for k,i in pairs (self.CoverPointGroup1) do
                    if i.Occupied == false and i != QueueNPC.OldClaimedCoverPoint then 
                        i.Occupied = true
                        i.OccupierClass = QueueNPC.VJ_NPC_Class[1]
                        QueueNPC.ClaimedCoverPoint = i 
                        QueueNPC.CoverEnt = self
                        print("Set Cover Point Group 1", QueueNPC.ClaimedCoverPoint, i)
                        --print("Class for group 1 is", QueueNPC.VJ_NPC_Class[1])
                        table.remove(self.CoverRequestQueue, 1 )
                        return
                    end
                end
            elseif !IsValid(QueueNPC.ClaimedCoverPoint) then
                for k,i in pairs (self.CoverPointGroup2) do
                    if i.Occupied == false then 
                        i.Occupied = true
                        i.OccupierClass = QueueNPC.VJ_NPC_Class[1]
                        QueueNPC.ClaimedCoverPoint = i 
                        QueueNPC.CoverEnt = self
                        print("Set Cover Point Group 2", QueueNPC.ClaimedCoverPoint, i)
                        table.remove(self.CoverRequestQueue, 1 )
                        return
                    end               
                end
            end
            table.remove(self.CoverRequestQueue, 1 )
        end
    end
end    

