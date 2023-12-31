AddCSLuaFile("shared.lua")
include("shared.lua")


ENT.Model = {"models/alyx2.mdl"}
ENT.StartHealth = 60
ENT.VJ_NPC_Class = {"CLASS_PLAYER_ALLY"} 
ENT.BloodColor = "Red"

ENT.CallForHelpDistance = 10000
ENT.InvestigateSoundDistance = 18

ENT.CanFlinch = 1 -- 0 = Don't flinch | 1 = Flinch at any damage | 2 = Flinch only from certain damages
ENT.FlinchChance = 4 -- Chance of it flinching from 1 to x | 1 will make it always flinch

ENT.FootStepTimeRun = 0.3
ENT.FootStepTimeWalk = 0.5

ENT.HasItemDropsOnDeath = true
ENT.ItemDropsOnDeathChance = 2
ENT.ItemDropsOnDeath_EntityList = {
"item_ammo_smg1_grenade",
"item_battery",
"item_healthvial",
"weapon_frag",
}

ENT.Soldier_SniperSpread = 0.75
ENT.Soldier_WeaponSpread = 1.5

ENT.HasGrenadeAttack = true -- Should the SNPC have a grenade attack?
ENT.GrenadeAttackEntity = "npc_grenade_frag"--"obj_vj_extractor_z" -- The entity that the SNPC throws | Half Life 2 Grenade: "npc_grenade_frag"
ENT.ThrowGrenadeChance = math.random(2, 4) -- Chance that it will throw the grenade | Set to 1 to throw all the time
ENT.ConstantlyFaceEnemyDistance = 100 -- How close does it have to be until it starts to face the enemy?

ENT.CanBeMedic = true

ENT.CanHaveTurret = false
ENT.TurretDeployDist = 2000

ENT.FootStepSoundLevel = 60
ENT.IdleSoundLevel = 65
ENT.IdleDialogueSoundLevel = 65
ENT.IdleDialogueAnswerSoundLevel = 65
ENT.CombatIdleSoundLevel = 70
ENT.InvestigateSoundLevel = 70
ENT.LostEnemySoundLevel = 65
ENT.AlertSoundLevel = 70
ENT.WeaponReloadSoundLevel = 60
ENT.GrenadeAttackSoundLevel = 70
ENT.OnGrenadeSightSoundLevel = 70
ENT.OnDangerSightSoundLevel = 70
ENT.OnKilledEnemySoundLevel = 70
ENT.AllyDeathSoundLevel = 70
ENT.PainSoundLevel = 70
ENT.DeathSoundLevel = 70

ENT.AnimTbl_ShootWhileMovingRun = {ACT_RUN_AIM} -- Animations it will play when shooting while running
ENT.AnimTbl_ShootWhileMovingWalk = {ACT_RUN_AIM} -- Animations it will play when shooting while walking
ENT.AnimTbl_MeleeAttack = {"MeleeAttack01"} -- Melee Attack Animations
ENT.AnimTbl_GrenadeAttack = {"ThrowItem"} -- Grenade Attack Animations
ENT.AnimTbl_WeaponAttackSecondary = {"shoot_shotgun"} -- Animations played when the SNPC fires a secondary weapon attack

ENT.wep = "weapon_vj_ar1"
ENT.ClaimedCoverPoint = nil
ENT.OldClaimedCoverPoint = nil
ENT.CoverEnt = nil
ENT.InCover = false
ENT.FindCoverTime = 0
ENT.ForceMoveTime = 0
ENT.StuckJumpTime = 0
ENT.CoverRequestTimer = 0
ENT.StuckCounter = 0

ENT.EnemyClasses = {"CLASS_PLAYER_ALLY", "CLASS_CITIZEN_REBEL", "CLASS_VORTIGAUNT", "CLASS_CITIZEN_PASSIVE",
                     "CLASS_PLAYER_ALLY_VITAL", "CLASS_PLAYER" }

local DefaultSoundTbl_MedicAfterHeal = {"items/smallmedkit1.wav"}
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function ENT:OnPlayCreateSound(sdData, sdFile)

	if !( (VJ_HasValue(self.SoundTbl_Pain, sdFile) && !VJ_HasValue(self.SoundTbl_Hurt, sdFile)) or VJ_HasValue(DefaultSoundTbl_MedicAfterHeal, sdFile) or VJ_HasValue(self.DefaultSoundTbl_MeleeAttack, sdFile) or VJ_HasValue(self.SoundTbl_NovaProspektIdle, sdFile)  ) then

        self:EmitSound(table.Random(self.SoundTbl_RadioOn),90,math.random(85, 115))
        timer.Simple(SoundDuration(sdFile), function() if IsValid(self) && sdData:IsPlaying() then self:EmitSound(table.Random(self.SoundTbl_RadioOff),70,math.random(85, 115)) end end)
    
    end

end
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function ENT:SoldierInit() end
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnInitialize()

    self:Give(self.wep)

    -- if !self.IsBeingDroppedByDropship then
    --     timer.Simple(0, function() if IsValid(self) then self:Give( table.Random( ZippyCombines_NPC_Weapons[self:GetClass()] ) ) end end)
    -- end

    self.SoundTbl_FootStep = {
    "npc/combine_soldier/gear1.wav",
    "npc/combine_soldier/gear2.wav",
    "npc/combine_soldier/gear3.wav",
    "npc/combine_soldier/gear4.wav",
    "npc/combine_soldier/gear5.wav",
    "npc/combine_soldier/gear6.wav",
    }

    self.SoundTbl_Idle = {
    "npc/combine_soldier/vo/gridsundown46.wav",
    "npc/combine_soldier/vo/noviscon.wav",
    "npc/combine_soldier/vo/ovewatchorders3ccstimboost.wav",
    "npc/combine_soldier/vo/reportallpositionsclear.wav",
    "npc/combine_soldier/vo/reportallradialsfree.wav",
    "npc/combine_soldier/vo/reportingclear.wav",
    "npc/combine_soldier/vo/sectorissecurenovison.wav",
    "npc/combine_soldier/vo/sightlineisclear.wav",
    "npc/combine_soldier/vo/stabilizationteamhassector.wav",
    "npc/combine_soldier/vo/stabilizationteamholding.wav",
    "npc/combine_soldier/vo/teamdeployedandscanning.wav",
    "npc/combine_soldier/vo/unitisclosing.wav",
    "npc/combine_soldier/vo/wehavenontaggedviromes.wav",
    }

    self.SoundTbl_IdleDialogue = self.SoundTbl_Idle

    self.SoundTbl_IdleDialogueAnswer = {
    "npc/combine_soldier/vo/copy.wav",
    "npc/combine_soldier/vo/copythat.wav",
    }

    self.SoundTbl_Investigate = {
    "npc/combine_soldier/vo/motioncheckallradials.wav",
    "npc/combine_soldier/vo/overwatchreportspossiblehostiles.wav",
    "npc/combine_soldier/vo/prepforcontact.wav",
    "npc/combine_soldier/vo/readycharges.wav",
    "npc/combine_soldier/vo/readyextractors.wav",
    "npc/combine_soldier/vo/readyweapons.wav",
    "npc/combine_soldier/vo/readyweaponshostilesinbound.wav",
    "npc/combine_soldier/vo/stayalert.wav",
    "npc/combine_soldier/vo/stayalertreportsightlines.wav",
    "npc/combine_soldier/vo/weaponsoffsafeprepforcontact.wav",
    "npc/combine_soldier/vo/confirmsectornotsterile.wav",
    }

    self.SoundTbl_CombatIdle = {
    "npc/combine_soldier/vo/thatsitwrapitup.wav",
    "npc/combine_soldier/vo/gosharp.wav",
    "npc/combine_soldier/vo/hardenthatposition.wav",
    "npc/combine_soldier/vo/gosharpgosharp.wav",
    "npc/combine_soldier/vo/targetmyradial.wav",
    "npc/combine_soldier/vo/goactiveintercept.wav",
    "npc/combine_soldier/vo/unitisinbound.wav",
    "npc/combine_soldier/vo/unitismovingin.wav",
    "npc/combine_soldier/vo/sweepingin.wav",
    "npc/combine_soldier/vo/executingfullresponse.wav",
    "npc/combine_soldier/vo/containmentproceeding.wav",
    "npc/combine_soldier/vo/callhotpoint.wav",
    "npc/combine_soldier/vo/callcontacttarget1.wav",
    "npc/combine_soldier/vo/prosecuting.wav",
    }

    self.SoundTbl_Alert = {
    "npc/combine_soldier/vo/contact.wav",
    "npc/combine_soldier/vo/viscon.wav",
    "npc/combine_soldier/vo/alert1.wav",
    "npc/combine_soldier/vo/contactconfirmprosecuting.wav",
    "npc/combine_soldier/vo/contactconfim.wav",
    "npc/combine_soldier/vo/outbreak.wav",
    "npc/combine_soldier/vo/fixsightlinesmovein.wav",
    }

    self.SoundTbl_WeaponReload = {
    "npc/combine_soldier/vo/cover.wav",
    "npc/combine_soldier/vo/coverme.wav",
    }

    self.SoundTbl_GrenadeAttack = {
    "npc/combine_soldier/vo/extractoraway.wav",
    "npc/combine_soldier/vo/extractorislive.wav",
    }

    self.SoundTbl_OnDangerSight = {
    "npc/combine_soldier/vo/ripcordripcord.wav",
    "npc/combine_soldier/vo/displace.wav",
    "npc/combine_soldier/vo/displace2.wav",
    }

    self.SoundTbl_OnGrenadeSight = {
    "npc/combine_soldier/vo/flaredown.wav",
    "npc/combine_soldier/vo/bouncerbouncer.wav",
    }

    self.SoundTbl_OnKilledEnemy = {
    "npc/combine_soldier/vo/targetcompromisedmovein.wav",
    "npc/combine_soldier/vo/targetblackout.wav",
    "npc/combine_soldier/vo/affirmativewegothimnow.wav",
    "npc/combine_soldier/vo/overwatchconfirmhvtcontained.wav",
    "npc/combine_soldier/vo/overwatchtargetcontained.wav",
    "npc/combine_soldier/vo/overwatchtarget1sterilized.wav",
    "npc/combine_soldier/vo/onecontained.wav",
    "npc/combine_soldier/vo/payback.wav",
    }

    self.SoundTbl_AllyDeath = {
    "npc/combine_soldier/vo/heavyresistance.wav",
    "npc/combine_soldier/vo/overwatchrequestreinforcement.wav",
    "npc/combine_soldier/vo/overwatchrequestreserveactivation.wav",
    "npc/combine_soldier/vo/overwatchrequestskyshield.wav",
    "npc/combine_soldier/vo/overwatchrequestwinder.wav",
    "npc/combine_soldier/vo/overwatchsectoroverrun.wav",
    "npc/combine_soldier/vo/onedutyvacated.wav",
    "npc/combine_soldier/vo/sectorisnotsecure.wav",
    "npc/combine_soldier/vo/onedown.wav",
    }

    self.SoundTbl_Hurt = {
    "npc/combine_soldier/vo/requestmedical.wav",
    "npc/combine_soldier/vo/requeststimdose.wav",
    "npc/combine_soldier/vo/coverhurt.wav",
    }

    self.SoundTbl_Pain = {
    "npc/combine_soldier/pain1.wav",
    "npc/combine_soldier/pain2.wav",
    "npc/combine_soldier/pain3.wav",
    "npc/combine_soldier/vo/requestmedical.wav",
    "npc/combine_soldier/vo/requeststimdose.wav",
    "npc/combine_soldier/vo/coverhurt.wav",
    }

    self.SoundTbl_LostEnemy = {
    "npc/combine_soldier/vo/skyshieldreportslostcontact.wav",
    "npc/combine_soldier/vo/lostcontact.wav",
    }

    self.SoundTbl_Death = {
    "npc/combine_soldier/die1.wav",
    "npc/combine_soldier/die2.wav",
    "npc/combine_soldier/die3.wav",
    }

    self.SoundTbl_RadioOn = {
    "npc/combine_soldier/episodic_vo/on1.wav",
    "npc/combine_soldier/episodic_vo/on2.wav",
    }

    self.SoundTbl_RadioOff = {
    "npc/combine_soldier/episodic_vo/off1.wav",
    "npc/combine_soldier/episodic_vo/off2.wav",
    "npc/combine_soldier/episodic_vo/off2.wav",
    }

    if math.random(1, 4) == 1 && self.CanBeMedic then
        self.IsMedicSNPC = true -- Is this SNPC a medic? Does it heal other friendly friendly SNPCs, and players(If friendly)
    end

    local turretchance = GetConVar("vj_zippycombines_soldier_turretchance"):GetInt()
    if turretchance != 0 then
        if self.CanHaveTurret && math.random(1, turretchance) == 1 then
            self.TurretProp = ents.Create("prop_dynamic")
            self.TurretProp:SetModel("models/combine_turrets/floor_turret.mdl")
            self.TurretProp:SetPos(self:GetAttachment(2).Pos - Vector(0,0,45) - self:GetForward()*8)
            self.TurretProp:SetAngles(self:GetAngles() + Angle(0,90,8))
            self.TurretProp:SetParent(self,2)
            self.TurretProp:Spawn()
            self.TurretProp:ResetSequence("carry_pose")
            self.TurretProp:AddEFlags(EFL_DONTBLOCKLOS)
            if GetConVar("vj_zippycombines_soldier_showturret"):GetInt() < 1 then
                self.TurretProp:SetNoDraw(true)
            end
        end
    end

    timer.Simple(0, function()
        local wep = self:GetActiveWeapon()
        if IsValid(wep) && wep:GetClass() == "weapon_vj_ar2" && self:GetModel() != "models/combine_super_soldier.mdl" then
            self.CanUseSecondaryOnWeaponAttack = false
        end
    end)

    self:SoldierInit()
    self.CoverRequestTimer = CurTime() + 0.5
end
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function ENT:SoldierThink() end
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnThink()

    self:SoldierThink()

    local wep = self:GetActiveWeapon()

    if IsValid(wep) then
        if self.WeaponSpread != self.Soldier_SniperSpread && wep:GetClass() == "weapon_vj_combine_sniper_rifle_z" then
            self.WeaponSpread = self.Soldier_SniperSpread
            --print("sniper spread")
        elseif self.WeaponSpread != self.Soldier_WeaponSpread && wep:GetClass() != "weapon_vj_combine_sniper_rifle_z" then
            self.WeaponSpread = self.Soldier_WeaponSpread
            --print("normal spread")
        end
    end

    --Look for a medic
    if self:Health() < self:GetMaxHealth() then
        for k,v in pairs (ents.FindInSphere( self:GetPos(), 1000 )) do
            if v:GetClass() == "npc_vj_rebel_medic" and self:GetPos():Distance(v:GetPos()) > 310 then
                self:SetLastPosition(v:GetPos()+v:GetForward()*math.random(-60, 60)+v:GetRight()*math.random(-60, 60))
                if self:GetWeaponState() == VJ_WEP_STATE_RELOADING then self:SetWeaponState() end
                self.TakingCoverT = CurTime() + 2
                canAttack = false
                self:VJ_TASK_GOTO_LASTPOS("TASK_RUN_PATH", function(x) x:EngTask("TASK_FACE_ENEMY", 0) x.CanShootWhenMoving = true x.ConstantlyFaceEnemy = true end)
            end 
        end
    end

    if IsValid(self:GetEnemy()) then
        --Look for cover
        if self.InCover == false and !IsValid(self.CoverEnt) and self.CoverRequestTimer < CurTime() then 
            self.CoverRequestTimer = CurTime() + 5
            self.MovementType = VJ_MOVETYPE_GROUND
            for k,v in pairs (ents.FindInSphere( self:GetPos(), 500 )) do
                if v.EntType == "Cover" and !IsValid(self.CoverEnt) then
                    v:RequestCover(self)
                    self.StuckJumpTime = CurTime() + 8
                    self.FindCoverTime = CurTime() + 25
                end 
            end
        end
        
        --Look for new cover
        if self.FindCoverTime < CurTime() then 
            self.InCover =  false 
            self.OldClaimedCoverPoint = self.ClaimedCoverPoint
            if IsValid(self.CoverEnt) then 
                self.ClaimedCoverPoint.Occupied = false
                self.ClaimedCoverPoint.OccupierClass = nil
                self.ClaimedCoverPoint = nil
                self.CoverEnt:CheckCoverPointStatus()
                self.CoverEnt = nil
            end 
            self.StuckJumpTime = CurTime() + 6
        end

        --Enforce move to claimed cover point
        if IsValid(self.ClaimedCoverPoint) and self.ForceMoveTime < CurTime() and self.InCover == false then
            self.ForceMoveTime = CurTime() + 1.5
            self:SetCollisionGroup(COLLISION_GROUP_NPC_SCRIPTED)
            if self:GetPos():Distance(self.ClaimedCoverPoint:GetPos()) > 20 and self.MovementType == VJ_MOVETYPE_GROUND then
                print("Enforcing move")
                if self:GetWeaponState() == VJ_WEP_STATE_RELOADING then self:SetWeaponState() end
                self:SetLastPosition(self.ClaimedCoverPoint:GetPos())
                self:VJ_TASK_GOTO_LASTPOS("TASK_RUN_PATH")
                
                if self.StuckJumpTime < CurTime() then
                    self.StuckJumpTime = CurTime() + 6
                    self.StuckCounter = self.StuckCounter + 1 
                    local moveCheck = VJ_PICK(self:VJ_CheckAllFourSides(200, true, "0111"))
                    if moveCheck then
                        self:SetLastPosition(moveCheck) 
                        self:VJ_TASK_GOTO_LASTPOS("TASK_RUN_PATH") 
                    end
                    if self.StuckCounter >= 3 then
                        self.InCover =  false 
                        if IsValid(self.CoverEnt) then 
                            self.ClaimedCoverPoint.Occupied = false
                            self.ClaimedCoverPoint.OccupierClass = nil
                            self.ClaimedCoverPoint = nil
                            self.CoverEnt = nil
                        end 
                    end
                end
            end
        end

        --Duck into cover
        if IsValid(self.ClaimedCoverPoint) and self.InCover == false and self:GetPos():Distance(self.ClaimedCoverPoint:GetPos()) <= 20 and self.StuckJumpTime > CurTime() then
            local coverAnims = {"CoverLow_R","CoverLow_L","Cover_idleD","crouchidlehide","crouch_aim_smg1"}
            self.InCover = true
            self.MovementType = VJ_MOVETYPE_STATIONARY
            self:SetCollisionGroup(COLLISION_GROUP_NPC)
            if self:GetWeaponState() != VJ_WEP_STATE_RELOADING then 
                self:VJ_ACT_PLAYACTIVITY(coverAnims[ math.random(1,5) ],true, math.random(1, 3),true)
            end
            self.AnimTbl_GrenadeAttack = {"throw1"}
            self.HasGrenadeAttack = false
        end
    end

    --Clear cover point if it is no longer valid or no longer have an enemy
    if !IsValid(self.CoverEnt) and self.InCover == true or !IsValid(self:GetEnemy()) then
        if IsValid(self.ClaimedCoverPoint) then 
            self.ClaimedCoverPoint.Occupied = false 
            self.CoverEnt:CheckCoverPointStatus()
        end
        self.InCover = false
        self.MovementType = VJ_MOVETYPE_GROUND
        self.ClaimedCoverPoint = nil
        self.CoverEnt = nil
        self.AnimTbl_GrenadeAttack = {"ThrowItem"}
        self.HasGrenadeAttack = true
    end

end
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
local turretdistfromself = 65

function ENT:CanDeployTurret()

    local enemy = self:GetEnemy()
    if !IsValid(enemy) then return end

    local dist = enemy:GetPos():Distance(self:GetPos())

    if self:Visible(enemy) && dist > turretdistfromself+35 && dist < self.TurretDeployDist then

        local tr = util.TraceHull({
            start = self:GetPos(),
            endpos = self:GetPos()+self:GetForward()*(turretdistfromself+35),
            filter = self,
            mins = self:OBBMins(),
            maxs = self:OBBMaxs(),
        })

        if !tr.Hit then
            return true
        end

    end

end
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function ENT:Controller_IntMsg(ply, controlEnt)

	ply:ChatPrint("ALT (walk key): Deploy Turret (if available)")

end
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function ENT:DeployTurret()
    if self.DeployingTurret then return end
    self.DeployingTurret = true

    local timeuntildeploy = 1

    self:VJ_ACT_PLAYACTIVITY("turret_drop",true,timeuntildeploy,true)

    self.TurretProp:Remove()
    self.TurretProp = ents.Create("prop_dynamic")
    self.TurretProp:SetModel("models/combine_turrets/floor_turret.mdl")
    self.TurretProp:SetPos(self:GetPos())
    self.TurretProp:SetAngles(self:GetAngles())
    self.TurretProp:SetParent(self,5)
    self.TurretProp:Spawn()
    self.TurretProp:AddEFlags(EFL_DONTBLOCKLOS)
    if GetConVar("vj_zippycombines_soldier_showturret"):GetInt() < 1 then
        self.TurretProp:SetNoDraw(true)
    end

    timer.Simple(timeuntildeploy, function() if IsValid(self) then
        self.TurretProp:Remove()

        local turret = ents.Create("npc_vj_combine_turret_z")
        turret:SetPos(self:GetPos()+self:GetForward()*turretdistfromself)
        turret:SetAngles(self:GetAngles())
        turret:Spawn()
        turret.VJ_NPC_Class = self.VJ_NPC_Class

        self.DeployingTurret = false
    end end)

end
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function ENT:IsNearDropshipDropPoint()

    for _,dropship in pairs(ents.FindByClass("npc_vj_dropship_z")) do
        if dropship.DropshipDropPoint && dropship.DropshipDropPoint:Distance(self:GetPos()) < 450 then
            return true
        end
    end

end
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnThink_AIEnabled()

    if IsValid(self.TurretProp) then
        if self.VJ_IsBeingControlled then
            if self.VJ_TheController:KeyDown(IN_WALK) then
                self:DeployTurret()
            end
        else
            if IsValid(self:GetEnemy()) && self:CanDeployTurret() && !self:IsNearDropshipDropPoint() then
                self:DeployTurret()
            end
        end
    end

end
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnPriorToKilled(dmginfo, hitgroup)

    if IsValid(self.TurretProp) && GetConVar("vj_zippycombines_soldier_showturret"):GetInt() > 0 then
        self:CreateGibEntity("obj_vj_gib",self.TurretProp:GetModel(),{BloodType = "", CollideSound = {"SolidMetal.ImpactSoft"}})
    end

    if IsValid(self.ClaimedCoverPoint) then
        self.ClaimedCoverPoint.Occupied = false
        self.ClaimedCoverPoint = nil
        self.InCover = true
        self.CoverEnt:CheckCoverPointStatus()
        self.CoverEnt = nil
    end

end
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function ENT:SetUpGibesOnDeath(dmginfo,hitgroup)
    if self.HasGibDeathParticles == true then -- Taken from black mesa SNPCs I think Xdddddd
        local bloodeffect = EffectData()
        bloodeffect:SetOrigin(self:GetPos() + self:OBBCenter())
        bloodeffect:SetColor(VJ_Color2Byte(Color(130,19,10)))
        bloodeffect:SetScale(120)
        util.Effect("VJ_Blood1",bloodeffect)
    end

    self:CreateGibEntity("obj_vj_gib","models/gibs/humans/eye_gib.mdl",{Pos = self:LocalToWorld(Vector(0,0,55)),Ang = self:GetAngles() + Angle(0,-90,0),Vel = self:GetRight() * math.Rand(50,50) + self:GetForward() * math.Rand(-200,200)})
    if self:GetModel() != "models/combine_super_soldier.mdl" && self:GetModel() != "models/vj_fassassin_z.mdl" then
        self:CreateGibEntity("obj_vj_gib","models/gibs/humans/eye_gib.mdl",{Pos = self:LocalToWorld(Vector(0,0,55)),Ang = self:GetAngles() + Angle(0,-90,0),Vel = self:GetRight() * math.Rand(50,50) + self:GetForward() * math.Rand(-200,200)})
    end

    self:CreateGibEntity("obj_vj_gib","models/gibs/humans/brain_gib.mdl",{Pos = self:LocalToWorld(Vector(0,0,60)),Ang = self:GetAngles() + Angle(0,-90,0)})
    self:CreateGibEntity("obj_vj_gib","models/gibs/humans/heart_gib.mdl",{Pos = self:LocalToWorld(Vector(0,0,40))})
    self:CreateGibEntity("obj_vj_gib","models/gibs/humans/lung_gib.mdl",{Pos = self:LocalToWorld(Vector(0,0,40))})
    self:CreateGibEntity("obj_vj_gib","models/gibs/humans/lung_gib.mdl",{Pos = self:LocalToWorld(Vector(0,0,40))})
    self:CreateGibEntity("obj_vj_gib","models/gibs/humans/liver_gib.mdl",{Pos = self:LocalToWorld(Vector(0,0,35))})
    self:CreateGibEntity("obj_vj_gib","UseHuman_Small",{Pos = self:LocalToWorld(Vector(0,0,30))})
    self:CreateGibEntity("obj_vj_gib","UseHuman_Small",{Pos = self:LocalToWorld(Vector(0,0,30))})
    self:CreateGibEntity("obj_vj_gib","UseHuman_Small",{Pos = self:LocalToWorld(Vector(0,0,30))})
    self:CreateGibEntity("obj_vj_gib","UseHuman_Big",{Pos = self:LocalToWorld(Vector(0,0,35))})
    self:CreateGibEntity("obj_vj_gib","UseHuman_Big",{Pos = self:LocalToWorld(Vector(0,0,35))})
    self:CreateGibEntity("obj_vj_gib","UseHuman_Big",{Pos = self:LocalToWorld(Vector(0,0,35))})
    self:CreateGibEntity("obj_vj_gib","UseHuman_Big",{Pos = self:LocalToWorld(Vector(0,0,40))})
    self:CreateGibEntity("obj_vj_gib","UseHuman_Big",{Pos = self:LocalToWorld(Vector(0,0,40))})
    self:CreateGibEntity("obj_vj_gib","UseHuman_Big",{Pos = self:LocalToWorld(Vector(0,0,40))})
    self:CreateGibEntity("obj_vj_gib","UseHuman_Big",{Pos = self:LocalToWorld(Vector(0,0,35))})
    self:CreateGibEntity("obj_vj_gib","UseHuman_Big",{Pos = self:LocalToWorld(Vector(0,0,30))})
    self:CreateGibEntity("obj_vj_gib","UseHuman_Big",{Pos = self:LocalToWorld(Vector(0,0,30))})
    self:CreateGibEntity("obj_vj_gib","UseHuman_Big",{Pos = self:LocalToWorld(Vector(0,0,30))})
    return true
end
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------