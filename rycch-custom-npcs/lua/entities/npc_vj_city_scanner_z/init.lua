AddCSLuaFile("shared.lua")
include("shared.lua")
/*--------------------------------------------------
	*** Copyright (c) 2012-2021 by DrVrej, All rights reserved. ***
	No parts of this code or any of its contents may be reproduced, copied, modified or adapted,
	without the prior written consent of the author, unless otherwise indicated for stand-alone materials.
--------------------------------------------------*/
ENT.Model = {"models/combine_scanner.mdl"}
ENT.StartHealth = 40
ENT.TurningSpeed = 10
ENT.VJ_NPC_Class = {"CLASS_COMBINE"}
ENT.IdleAlwaysWander = true
ENT.SightAngle = 100

ENT.CallForHelpDistance = 10000
ENT.InvestigateSoundDistance = 18

ENT.PoseParameterLooking_Names = {pitch = {"flex_vert"}, yaw = {"flex_horz"}, roll = {""}}

ENT.HasItemDropsOnDeath = true
ENT.ItemDropsOnDeathChance = 2
ENT.ItemDropsOnDeath_EntityList = {
"item_battery",
}

ENT.HasMeleeAttack = false

ENT.Aerial_FlyingSpeed_Calm = 120
ENT.Aerial_FlyingSpeed_Alerted = 120
ENT.MovementType = VJ_MOVETYPE_AERIAL
ENT.AA_ConstantlyMove = true
--ENT.AA_MinWanderDist = 500
ENT.AA_MinWanderDist = 50
ENT.AA_GroundLimit = 60

ENT.ConstantlyFaceEnemy = true
ENT.ConstantlyFaceEnemyDistance = 10000

ENT.NoChaseAfterCertainRange = true
ENT.NoChaseAfterCertainRange_FarDistance = 300
ENT.NoChaseAfterCertainRange_CloseDistance = 0

ENT.HasGibOnDeathSounds = false

ENT.SoundTbl_Alert = {"NPC_CScanner.Alert"}
ENT.SoundTbl_Investigate = {"NPC_CScanner.Alert"}
ENT.SoundTbl_CombatIdle = {"NPC_CScanner.Idle"}
ENT.SoundTbl_Breath = {"NPC_CScanner.FlyLoop"}
ENT.SoundTbl_Pain = {"NPC_CScanner.Pain"}
ENT.SoundTbl_Death = {"NPC_CScanner.Die"}

ENT.DeathSoundLevel = 130
ENT.BreathSoundLevel = 75

ENT.FlashDistance = 10000
ENT.RedLightDist = ENT.NoChaseAfterCertainRange_FarDistance*1.25
ENT.NextRandomFlash = 20

ENT.CrashChance = 2

ENT.VJC_Data = {
	CameraMode = 1, -- Sets the default camera mode | 1 = Third Person, 2 = First Person
	ThirdP_Offset = Vector(0, 0, 0), -- The offset for the controller when the camera is in third person
	FirstP_Bone = "Scanner.Neck", -- If left empty, the base will attempt to calculate a position for first person
	FirstP_Offset = Vector(15, 0, 0), -- The offset for the controller when the camera is in first person
	FirstP_ShrinkBone = true, -- Should the bone shrink? Useful if the bone is obscuring the player's view
	FirstP_CameraBoneAng = 0, -- Should the camera's angle be affected by the bone's angle? | 0 = No, 1 = Pitch, 2 = Yaw, 3 = Roll
	FirstP_CameraBoneAng_Offset = 0, -- How much should the camera's angle be rotated by? | Useful for weird bone angles
}

function ENT:Controller_IntMsg(ply, controlEnt)

	ply:ChatPrint("NOTE: Controlling is not really supported for this SNPC!!")

end

function ENT:CustomOnInitialize()

	--self:SetBloodColor(BLOOD_COLOR_MECH)
	self:SetCollisionBounds(Vector(10, 10, 10), Vector(-10, -10, -10))

	local spawnheight = 50
	timer.Simple(0, function() if !self.IsThrownScanner then self:SetPos(self:GetPos()+Vector(0,0,spawnheight)) end end)

end

ENT.WheelPose = -180
ENT.alertamt = 0
ENT.straife_timer = CurTime()
ENT.straife_dir_side = -1
ENT.straife_dir_back = -1
function ENT:CustomOnThink_AIEnabled()

	if IsValid(self:GetEnemy()) && !self:Visible(self:GetEnemy()) && !self.VJ_IsBeingControlled then

		local moveSpeed = 2
		
		if self.MovementType == VJ_MOVETYPE_AERIAL then
			self.MovementType = VJ_MOVETYPE_STATIONARY
		end

		if self.straife_timer < CurTime() then
			self.straife_dir_side = math.random(-1, 1)
			self.straife_dir_back = math.random(-1, 0)
			self.straife_timer = CurTime() + 2
		end

		local tr = util.TraceLine({
		start = self:GetPos(),
		endpos = self:GetPos() + self:GetForward() * 70,
		filter = self:GetEnemy(),
		mask = MASK_NPCWORLDSTATIC,
		})
		if tr.HitWorld && !self.IsCrashing then
			self:SetVelocity((self:GetRight()*self.straife_dir_side + self:GetForward()*-1 )*moveSpeed)
		else 
			local velPos = (self:GetRight()*self.straife_dir_side )*moveSpeed
	
			self:SetVelocity( velPos )	
		end

		local tr = util.TraceLine({
		start = self:GetPos(),
		endpos = self:GetPos() + self:GetUp() * -50,
		filter = self:GetEnemy(),
		mask = MASK_NPCWORLDSTATIC,
		})
		if tr.HitWorld && !self.IsCrashing then
			self:SetVelocity((self:GetUp()*1 )*moveSpeed)
		end

	elseif self.MovementType == VJ_MOVETYPE_STATIONARY then

		self.MovementType = VJ_MOVETYPE_AERIAL

	end

	if IsValid(self:GetEnemy()) then

		local tr = util.TraceLine({
		start = self:GetEnemy():GetPos(),
		endpos = self:GetEnemy():GetPos() + Vector(0,0,10000),
		mask = MASK_NPCWORLDSTATIC,
		})
		local EnemyUpDist = math.abs(tr.HitPos.z - self:GetEnemy():GetPos().z)
		local ShootHeightRatio = math.Clamp(EnemyUpDist / 6000,0.01,0.33)

		local tr1 = util.TraceLine({
		start = self:GetPos(),
		endpos = ((self:GetPos() + self:GetEnemy():GetPos()) * 0.5) + Vector(0,0,10000),
		mask = MASK_NPCWORLDSTATIC,
		})
		local MortarUpDist1 = math.abs((tr1.HitPos.z - self:GetPos().z) * 0.75)
		local MinShootHeight = 70
		local Dist = self:GetEnemy():GetPos():Distance(self:GetPos())

		local enemypos2D = Vector( self:GetEnemy():GetPos().x , self:GetEnemy():GetPos().y , 0 )
		local selfpos2D = Vector( self:GetPos().x , self:GetPos().y , 0 )
		local Dist2D = enemypos2D:Distance(selfpos2D)

	end

	if IsValid(self:GetEnemy()) && self.alertamt < 1 then
		self.alertamt = math.Clamp(self.alertamt + 0.2, 0, 1)
	elseif !IsValid(self:GetEnemy()) && self.alertamt > 0 then
		self.alertamt = math.Clamp(self.alertamt - 0.2, 0, 1)
	end

	if self.WheelPose > 180 then
		self.WheelPose = -180
	else
		self.WheelPose = self.WheelPose+20
	end

	local tailcontrol = (1.5+math.sin(CurTime()*2.5))*10

	self:SetPoseParameter("alert_control", self.alertamt)
	self:SetPoseParameter("dynamo_wheel", self.WheelPose)
	self:SetPoseParameter("tail_control", tailcontrol)

	if self.IsCrashing then
		self:SetVelocity(self:GetForward() * 50)
	end

	local tr = util.TraceLine({
	start = self:GetPos(),
	endpos = self:GetPos() + self:GetUp() * 50,
	filter = self:GetEnemy(),
	mask = MASK_NPCWORLDSTATIC,
	})
	if tr.HitWorld && !self.IsCrashing then
		print("scanner moving up in world")
		self:SetVelocity((self:GetPos() - tr.HitPos) * (15 / self:GetPos():Distance(tr.HitPos)))
	end

	if IsValid(self:GetEnemy()) && self:GetPos():Distance(self:GetEnemy():GetPos()) < self.FlashDistance && self:Visible(self:GetEnemy()) then
		--self.CallForHelp = true
		if self.NextRandomFlash != 0 then
			self.NextRandomFlash = self.NextRandomFlash - 1
		end
		if self.NextRandomFlash == 0 then
			self:CustomOnCallForHelp()
		end
	else
		---self.CallForHelp = false
	end

	if (!self.SpotlightOn && !IsValid(self:GetEnemy())) or (!self.SpotlightOn && IsValid(self:GetEnemy()) && self:GetEnemy():GetPos():Distance(self:GetPos()) > self.RedLightDist) then
		if IsValid(self.AngryLight) then
			self.AngryLight:Remove()
		end
		self.SpotlightOn = true
		self:EmitSound( "HL2Player.FlashLightOn", 100, 100)
		self.Spotlight = ents.Create("point_spotlight")
		self.Spotlight:SetPos( self:GetAttachment(1).Pos )
		self.Spotlight:SetAngles( self:GetAngles() )
		self.Spotlight:SetKeyValue( "spawnflags", "1" + "2" )
		self.Spotlight:SetKeyValue( "spotlightlength", "100" )
		self.Spotlight:SetKeyValue( "spotlightwidth", "10" )
		self.Spotlight:SetColor(Color(150,150,150,255))
		self.Spotlight:SetParent(self)
		self.Spotlight:Spawn()
		self.Spotlight:Activate()
	end
	if self.SpotlightOn && IsValid(self:GetEnemy()) && self:GetEnemy():GetPos():Distance(self:GetPos()) < self.RedLightDist then
		self.AngryLight = ents.Create( "env_sprite" )
		self.AngryLight:SetKeyValue( "model","sprites/blueflare1.spr" )
		self.AngryLight:SetKeyValue( "rendercolor","255 50 0" )
		self.AngryLight:SetPos( self:GetPos() )
		self.AngryLight:SetMoveType( MOVETYPE_NONE )
		self.AngryLight:SetParent( self )
		self.AngryLight:Fire( "SetParentAttachment", "light" )
		self.AngryLight:SetKeyValue( "scale","0.4" )
		self.AngryLight:SetKeyValue( "rendermode","9" )
		self.AngryLight:Spawn()
		self:DeleteOnRemove(self.AngryLight)
		self.SpotlightOn = false
		self:EmitSound( "HL2Player.FlashLightOff", 100, 100)
		self.Spotlight:SetParent()
		self.Spotlight:Fire("lightoff")
		self.Spotlight:Fire("kill",self.Spotlight, 0.5)
	end

end

function ENT:CustomOnAlert(ent)

	self.TurningUseAllAxis = true

end

function ENT:CustomOnResetEnemy()

	self.TurningUseAllAxis = false

end

function ENT:CustomOnCallForHelp(ally)

	self.NextRandomFlash = math.random(1, 25)--50

	if !self.IsDoingFlash then
		self.IsDoingFlash = true
		local expLight = ents.Create("light_dynamic")
		expLight:SetKeyValue("brightness", "5")
		expLight:SetKeyValue("distance", "300")
		expLight:Fire("Color", "255 255 255")
		expLight:SetPos(self:GetPos())
		expLight:Spawn()
		expLight:Activate()
		expLight:Fire("TurnOn", "", 0)
		timer.Simple(0.2,function() if IsValid(expLight) then expLight:Remove() end end)
		self:DeleteOnRemove(expLight)

		self.Flash1 = ents.Create( "env_sprite" )
		self.Flash1:SetKeyValue( "model","sprites/blueflare1.spr" )
		self.Flash1:SetKeyValue( "rendercolor","125 125 125" )
		self.Flash1:SetPos( self:GetPos() )
		self.Flash1:SetMoveType( MOVETYPE_NONE )
		self.Flash1:SetParent( self )
		self.Flash1:Fire( "SetParentAttachment", "light" )
		self.Flash1:SetKeyValue( "scale","5" )
		self.Flash1:SetKeyValue( "rendermode","9" )
		self.Flash1:Spawn()
		self.Flash2 = ents.Create( "env_sprite" )
		self.Flash2:SetKeyValue( "model","sprites/blueflare1.spr" )
		self.Flash2:SetKeyValue( "rendercolor","255 255 255" )
		self.Flash2:SetPos( self:GetPos() )
		self.Flash2:SetMoveType( MOVETYPE_NONE )
		self.Flash2:SetParent( self )
		self.Flash2:Fire( "SetParentAttachment", "light" )
		self.Flash2:SetKeyValue( "scale","2.5" )
		self.Flash2:SetKeyValue( "rendermode","9" )
		self.Flash2:Spawn()
		timer.Simple(0.1,function() if IsValid(self) then self.Flash1:Remove() end end)
		timer.Simple(0.1,function() if IsValid(self) then self.Flash2:Remove() end end)
		timer.Simple(1,function() if IsValid(self) then self.IsDoingFlash = false end end)

		self.NoChaseAfterCertainRange_FarDistance = math.random(50, 450)

		--self:EmitSound( "NPC_CScanner.TakePhoto", 100, 100)
		timer.Create("scanner_shoot", 0.1, math.random(1, 5), function() 
			local shoot_angle = self:GetAimVector() --Vector(0.09,0.09,0.09)

			local shot = ents.Create( "obj_vj_smart_bullet" )
			local shoot_pos   = self:GetPos() + self:GetRight() + self:GetUp()*-10 + self:GetForward()*-8 + shoot_angle * -20
			if ( IsValid( shot ) ) then
				shot:SetPos( shoot_pos )
				shot:SetAngles( shoot_angle:Angle() )
				shot:SetOwner( self )
				shot.MyEnemy = self:GetEnemy()
				shot:Spawn()
			end

		end)

	end

end

function ENT:Crash()

	local targetpos = self:GetPos() + self:GetForward() * 100 - Vector(0,0,100)
	if IsValid(self:GetEnemy()) then
		targetpos = self:GetEnemy():GetPos()
	end

	local crashdir = targetpos - self:GetPos()

	local CrashingScannerProp = ents.Create("base_gmodentity")
	CrashingScannerProp:SetModel(self:GetModel())
	CrashingScannerProp:SetPos(self:GetPos())
	CrashingScannerProp:SetAngles(crashdir:Angle())
	CrashingScannerProp:Spawn()
	CrashingScannerProp:SetMoveType(MOVETYPE_FLY)
	CrashingScannerProp:SetSolid(SOLID_VPHYSICS)
	CrashingScannerProp.VJ_NPC_Class = self.VJ_NPC_Class

	CrashingScannerProp.Explode = function()
		util.VJ_SphereDamage(Entity(0),Entity(0),CrashingScannerProp:GetPos(),300,30,DMG_BLAST,true,true,false,false)
		ParticleEffect("grenade_explosion_01", CrashingScannerProp:GetPos(), Angle(0,0,0), nil)
		ParticleEffect("Explosion_2_Chunks", CrashingScannerProp:GetPos(), Angle(0,0,0), nil)
		local effectdata = EffectData()
		effectdata:SetOrigin(CrashingScannerProp:GetPos())
		util.Effect( "Explosion", effectdata )
		CrashingScannerProp:EmitSound( "Explo.ww2bomb", 130, 100)
		CrashingScannerProp:Remove()
	end

	CrashingScannerProp.Think = function()
		CrashingScannerProp:SetVelocity(crashdir:GetNormalized() * 15)
		CrashingScannerProp:SetAngles(CrashingScannerProp:GetAngles() + Angle(0,0,3))
		CrashingScannerProp:NextThink(CurTime())
		local tr = util.TraceLine({
			start = CrashingScannerProp:GetPos(),
			endpos = CrashingScannerProp:GetPos() + crashdir:GetNormalized() * 3000,
			filter = self
		})

		sound.EmitHint(SOUND_DANGER, tr.HitPos, 300, 0.5)
		return true
	end

	CrashingScannerProp.StartTouch = function()
		CrashingScannerProp:Explode()
	end

	timer.Simple(2, function() if IsValid(CrashingScannerProp) then CrashingScannerProp:Explode() end end)

end

function ENT:SetUpGibesOnDeath(dmginfo, hitgroup)

	if math.random(1, self.CrashChance) == 1 then
		self:Crash()
	else
		self:CreateGibEntity("obj_vj_gib","models/gibs/scanner_gib01.mdl",{BloodType = "",Pos = self:LocalToWorld(Vector(0,0,0)), CollideSound = {"SolidMetal.ImpactSoft"}})
		self:CreateGibEntity("obj_vj_gib","models/gibs/scanner_gib02.mdl",{BloodType = "",Pos = self:LocalToWorld(Vector(0,0,0)), CollideSound = {"SolidMetal.ImpactSoft"}})
		self:CreateGibEntity("obj_vj_gib","models/gibs/scanner_gib04.mdl",{BloodType = "",Pos = self:LocalToWorld(Vector(0,0,0)), CollideSound = {"SolidMetal.ImpactSoft"}})
		self:CreateGibEntity("obj_vj_gib","models/gibs/scanner_gib05.mdl",{BloodType = "",Pos = self:LocalToWorld(Vector(0,0,0)), CollideSound = {"SolidMetal.ImpactSoft"}})
	end

	return true

end

function ENT:CustomOnPriorToKilled(dmginfo, hitgroup)

	local effectdata = EffectData()
	effectdata:SetOrigin(self:GetPos())
	util.Effect( "Explosion", effectdata )

end

function ENT:CustomOnTakeDamage_BeforeDamage(dmginfo, hitgroup)

	if dmginfo:IsBulletDamage() then
		dmginfo:SetDamage(dmginfo:GetDamage() * 0.5)

        if math.random(1, 3) == 1 then
			self:EmitSound("weapons/fx/rics/ric1.wav", 82, math.random(85, 115))
			
			local spark = ents.Create("env_spark")
			spark:SetPos(dmginfo:GetDamagePosition())
			spark:Spawn()
			spark:Fire("StartSpark", "", 0)
			spark:Fire("StopSpark", "", 0.001)
			self:DeleteOnRemove(spark)
		end
	end

end

function ENT:CustomOnDeath_AfterCorpseSpawned(dmginfo, hitgroup, corpseEnt)

	ParticleEffectAttach("electrical_arc_01_system", PATTACH_ABSORIGIN_FOLLOW, corpseEnt, 0)
	local Spark = ents.Create("env_spark")
	Spark:SetKeyValue("MaxDelay","1")
	Spark:SetKeyValue("Magnitude","2")
	Spark:SetKeyValue("Spark Trail Length","2")
	Spark:SetAngles(corpseEnt:GetAngles())
	Spark:SetParent(corpseEnt)
	Spark:SetPos(corpseEnt:GetPos())
	Spark:Spawn()
	Spark:Activate()
	Spark:Fire("StartSpark", "", 0)
	Spark:Fire("StopSpark", "", 4)
	corpseEnt:DeleteOnRemove(Spark)

	if math.random(1, self.CrashChance) == 1 then -- Crash

		self:Crash()

		corpseEnt:Remove()
	end

end

function ENT:CustomOnRemove()

	if IsValid (self.Spotlight) then
		self.Spotlight:SetParent()
		self.Spotlight:Fire("lightoff")
		self.Spotlight:Fire("kill",self.Spotlight, 0.5)
	end

end

function ENT:AA_IdleWander(playAnim, moveType, extraOptions)
	print("running custom wander")
	moveType = moveType or "Calm" -- "Calm" | "Alert"
	local moveSpeed = (moveType == "Calm" and self.Aerial_FlyingSpeed_Calm) or self.Aerial_FlyingSpeed_Alerted
	local moveDown = false -- Used by aquatic NPCs only, forces them to move down
	
	local debug = self.VJ_DEBUG
	extraOptions = extraOptions or {}
	
	-- Movement Calculations
	local myPos = self:GetPos()
	local myMaxs = self:OBBMaxs():Length()
	local minDist = math.random(self.AA_MinWanderDist, self.AA_MinWanderDist + 150)
	local tr_endpos = myPos + self:GetForward()*((myMaxs + minDist)) + self:GetRight()*((myMaxs + minDist)) + self:GetUp()*((myMaxs - minDist))
	if moveDown == true then
		tr_endpos = myPos + self:GetUp()*((myMaxs + math.random(100, 150))*-1)
	end
	local tr = util.TraceLine({start = myPos, endpos = tr_endpos, filter = self})
	local finalPos = tr.HitPos
	//PrintTable(tr)
	-- If we aren't being forced to move down, then make sure we limit how close we get to the ground!
	if extraOptions.IgnoreGround != true && !moveDown && self.MovementType == VJ_MOVETYPE_AERIAL then
		local tr_check = util.TraceLine({start = finalPos, endpos = finalPos + Vector(0, 0, -(self.AA_GroundLimit/6)), filter = self})
		--if debug == true then
		--	print("checking...")
		--	VJ_CreateTestObject(finalPos, self:GetAngles(), Color(255,255,255), 5)
		--	VJ_CreateTestObject(tr_check.HitPos, self:GetAngles(), Color(255,0,255), 5)
		--end
		-- If it hit the world, then we are too close to the ground, replace "tr" with a new position!
		if tr_check.HitWorld == true then
			print("hit ground")
			--if debug == true then print("Ground Hit!", tr_check.HitPos:Distance(finalPos)) end
			tr_endpos.z = myPos.z + self.AA_GroundLimit
			tr = util.TraceLine({start = myPos, endpos = tr_endpos, filter = self})
			finalPos = tr.HitPos
		end
	end
	
	--if debug == true then
	--	VJ_CreateTestObject(finalPos, self:GetAngles(), Color(0,255,255), 5)
	--	util.ParticleTracerEx("Weapon_Combine_Ion_Cannon_Beam", tr.StartPos, finalPos, false, self:EntIndex(), 0)
	--	ParticleEffect("vj_impact1_centaurspit", finalPos, defAng, self)
	--end
	
	self.AA_CurrentMoveMaxSpeed = moveSpeed
	if self.AA_MoveAccelerate > 0 then moveSpeed = Lerp(FrameTime()*2, self:GetVelocity():Length(), moveSpeed) end
	
	-- Set the velocity
	local velPos = (finalPos - myPos):GetNormal()*moveSpeed
	local velTime = finalPos:Distance(myPos) / velPos:Length()
	local velTimeCur = CurTime() + velTime
	if velTimeCur == velTimeCur then -- Check for NaN
		self.AA_CurrentMoveTime = velTimeCur
		//self.NextIdleTime = velTimeCur
	end
	if extraOptions.FaceDest != false then
		self:FaceCertainPosition(finalPos, velTime)
		//self.AA_CurrentTurnAng = self:GetFaceAngle((finalPos - tr.StartPos):Angle())
		//self:SetLocalAngularVelocity(self:GetFaceAngle((finalPos-tr.StartPos):Angle()))
	end
	self.AA_CurrentMoveType = 1
	self.AA_CurrentMovePos = finalPos
	self.AA_CurrentMovePosDir = finalPos - myPos
	self.AA_CurrentMoveDist = -1
	self:SetLocalVelocity(velPos)
	
	-- Animations
	if playAnim != false then
		self.CurrentAnim_AAMovement = self.CurrentAnim_AAMovement
		self.AA_CurrentMoveAnimationType = moveType
	else
		self.CurrentAnim_AAMovement = false
	end
end
/*--------------------------------------------------
	*** Copyright (c) 2012-2021 by DrVrej, All rights reserved. ***
	No parts of this code or any of its contents may be reproduced, copied, modified or adapted,
	without the prior written consent of the author, unless otherwise indicated for stand-alone materials.
--------------------------------------------------*/