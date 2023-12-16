AddCSLuaFile( "shared.lua" )
include('shared.lua')
/*-----------------------------------------------
	This SNPC is made by DrVrej
-----------------------------------------------*/
ENT.Model = "models/assault_synth.mdl" -- Leave empty if using more than one model
ENT.StartHealth =  170
ENT.HullType = HULL_WIDE_SHORT
ENT.VJ_NPC_Class = {"CLASS_COMBINE"}
ENT.BloodColor = "White"
ENT.BloodDecalRate = 0 -- The more the number is the more chance is has to spawn | 1000 is a good number for yellow blood, for red blood 500 is good | Make the number smaller if you are using big decal like Antlion Splat, Which 5 or 10 is a really good number for this stuff
ENT.NextAnyAttackTime_Melee = 0.2 -- How much time until it can use a attack again? | Counted in SecondsENT.MeleeAttackDamage = 15
ENT.TimeUntilMeleeAttackDamage = 0.7 -- This counted in seconds | This calculates the time until it hits something
ENT.HasExtraMeleeAttackSounds = true
ENT.MeleeAttackDamage = 15
ENT.MeleeAttackDistance = 30 -- How close does it have to be until it attacks?
ENT.HasRangeAttack = true -- Should the SNPC have a range attack?
ENT.RangeAttackEntityToSpawn = "obj_vj_chopper_missile_z"--"obj_as_projectile" -- The entity that is spawned when range attacking
ENT.AnimTbl_RangeAttack = {ACT_RANGE_ATTACK1} -- Range Attack Animations
ENT.RangeDistance = 3000 -- This is how far away it can shoot
ENT.RangeToMeleeDistance = 250 -- How close does it have to be until it uses melee?
ENT.TimeUntilRangeAttackProjectileRelease = 0.6 -- How much time until the projectile code is ran?
ENT.NextRangeAttackTime = 2.5 -- How much time until it can use a range attack?
ENT.NextAnyAttackTime_Range = 0.2 -- How much time until it can use a attack again? | Counted in Seconds
ENT.FootStepTimeRun = 0.2 -- Next foot step sound when it is running
ENT.FootStepTimeWalk = 0.5 -- Next foot step sound when it is walking
ENT.FootStepPitch1 = 150
ENT.FootStepPitch2 = 180
ENT.RangeUpPos = 37 -- Spawning Position for range attack | + = up, - = down
ENT.DisableFootStepSoundTimer = true -- If set to true, it will disable the time system for the footstep sound code, allowing you to use other ways like model events
	-- Sounds --
-- Reminder: If you leave a sound blank, the game will still try to play!
ENT.SoundTbl_FootStep = {""}
ENT.SoundTbl_Idle = {}
ENT.SoundTbl_RangeAttack = {"weapons/ioncannon/ioncannon_1.wav", "weapons/ioncannon/ioncannon_2.wav", "weapons/ioncannon/ioncannon_3.wav"}
ENT.SoundTbl_MeleeAttackMiss = {"npc/zombie/claw_miss1.wav","npc/zombie/claw_miss2.wav"}
ENT.SoundTbl_Death = {}
ENT.SoundTbl_Impact = {"physics/flesh/flesh_strider_impact_bullet1.wav", "physics/flesh/flesh_strider_impact_bullet2.wav", "physics/flesh/flesh_strider_impact_bullet3.wav"}

ENT.RangeAttackSoundLevel = 100
ENT.RangeAttackPitch1 = 150
ENT.RangeAttackPitch2 = 150

ENT.MeleeAttackMissSoundPitch1 = 220
ENT.MeleeAttackMissSoundPitch2 = 240
ENT.ExtraMeleeSoundPitch1 = 120
ENT.ExtraMeleeSoundPitch2 = 140

ENT.ImpactSoundPitch1 = 150
ENT.ImpactSoundPitch2 = 170

function ENT:CustomOnInitialize()
	self:SetModelScale( self:GetModelScale() * 0.75, 0 )
end


function ENT:CustomOnAcceptInput(key,activator,caller,data)
	if key == "event_emit Foot" then
		self:FootStepSoundCode()
		VJ_EmitSound(self,"npc/antlion/foot"..math.random(1,4)..".wav",60,170)
	end
end

function ENT:CustomOnDeath_AfterCorpseSpawned(dmginfo, hitgroup, corpseEnt) 
	--print("i got called")
	--corpseEnt:SetModelScale(corpseEnt:GetModelScale()*.25, 0)
    --timer.Simple(0.5, function() print("i got called 2") corpseEnt:SetModelScale(corpseEnt:GetModelScale()*.25, 0)  end)

	for i = 0, corpseEnt:GetBoneCount() - 1 do
		local name = corpseEnt:GetBoneName(i)
		local scale = -0.4

		if name ~= "__INVALIDBONE__" then
			if name == "ValveBiped.Bip01_Head1" then
				corpseEnt:ManipulateBoneScale(i, Vector(1.1+scale,1.1+scale,1.1+scale))
			else
				corpseEnt:ManipulateBoneScale(i, Vector(1.1+scale,1.1+scale,1.1+scale))
			end
		end
	end		
end

function ENT:CreateDeathCorpse(dmginfo, hitgroup)
	-- In case it was not set
		-- NOTE: dmginfo at this point can be incorrect/corrupted, but its better than leaving the self.SavedDmgInfo empty!
	if !self.SavedDmgInfo then
		self.SavedDmgInfo = {
			dmginfo = dmginfo, -- The actual CTakeDamageInfo object | WARNING: Can be corrupted after a tick, recommended not to use this!
			attacker = dmginfo:GetAttacker(),
			inflictor = dmginfo:GetInflictor(),
			amount = dmginfo:GetDamage(),
			pos = dmginfo:GetDamagePosition(),
			type = dmginfo:GetDamageType(),
			force = dmginfo:GetDamageForce(),
			ammoType = dmginfo:GetAmmoType(),
			hitgroup = hitgroup,
		}
	end
	
	self:CustomOnDeath_BeforeCorpseSpawned(dmginfo, hitgroup)
	if self.HasDeathRagdoll == true then
		local corpseMdl = self:GetModel()
		local corpseMdlCustom = VJ_PICK(self.DeathCorpseModel)
		if corpseMdlCustom != false then corpseMdl = corpseMdlCustom end
		local corpseType = "prop_physics"
		if self.DeathCorpseEntityClass == "UseDefaultBehavior" then
			if util.IsValidRagdoll(corpseMdl) == true then
				corpseType = "prop_ragdoll"
			elseif util.IsValidProp(corpseMdl) == false or util.IsValidModel(corpseMdl) == false then
				return false
			end
		else
			corpseType = self.DeathCorpseEntityClass
		end
		//if self.VJCorpseDeleted == true then
		self.Corpse = ents.Create(corpseType) //end
		self.Corpse:SetModel(corpseMdl)
		self.Corpse:SetPos(self:GetPos())
		self.Corpse:SetAngles(self:GetAngles())
		self.Corpse:Spawn()
		self.Corpse:Activate()
		self.Corpse:SetColor(self:GetColor())
		self.Corpse:SetMaterial(self:GetMaterial())
		if corpseMdlCustom == false && self.DeathCorpseSubMaterials != nil then -- Take care of sub materials
			for _, x in ipairs(self.DeathCorpseSubMaterials) do
				if self:GetSubMaterial(x) != "" then
					self.Corpse:SetSubMaterial(x, self:GetSubMaterial(x))
				end
			end
			 -- This causes lag, not a very good way to do it.
			/*for x = 0, #self:GetMaterials() do
				if self:GetSubMaterial(x) != "" then
					self.Corpse:SetSubMaterial(x, self:GetSubMaterial(x))
				end
			end*/
		end
		//self.Corpse:SetName("self.Corpse" .. self:EntIndex())
		//self.Corpse:SetModelScale(self:GetModelScale()*.75)
		self.Corpse.FadeCorpseType = (self.Corpse:GetClass() == "prop_ragdoll" and "FadeAndRemove") or "kill"
		self.Corpse.IsVJBaseCorpse = true
		self.Corpse.DamageInfo = dmginfo
		self.Corpse.ExtraCorpsesToRemove = self.ExtraCorpsesToRemove_Transition
		self.Corpse.BloodData = {Color = self.BloodColor, Particle = self.CustomBlood_Particle, Decal = self.CustomBlood_Decal}

		if self.Bleeds == true && self.HasBloodPool == true && GetConVar("vj_npc_nobloodpool"):GetInt() == 0 then
			self:SpawnBloodPool(dmginfo, hitgroup)
		end
		
		-- Collision --
		self.Corpse:SetCollisionGroup(self.DeathCorpseCollisionType)
		if GetConVar("ai_serverragdolls"):GetInt() == 1 then
			undo.ReplaceEntity(self, self.Corpse)
		else -- Keep corpses is not enabled...
			VJ_AddCorpse(self.Corpse)
			//hook.Call("VJ_CreateSNPCCorpse", nil, self.Corpse, self)
			if GetConVar("vj_npc_undocorpse"):GetInt() == 1 then undo.ReplaceEntity(self, self.Corpse) end -- Undoable
		end
		cleanup.ReplaceEntity(self, self.Corpse) -- Delete on cleanup
		
		-- Miscellaneous --
		self.Corpse:SetSkin((self.DeathCorpseSkin == -1 and self:GetSkin()) or self.DeathCorpseSkin)
		
		if self.DeathCorpseSetBodyGroup == true then -- Yete asega true-e, ooremen gerna bodygroup tenel
			for i = 0,18 do -- 18 = Bodygroup limit
				self.Corpse:SetBodygroup(i,self:GetBodygroup(i))
			end
			if self.DeathCorpseBodyGroup.a != -1 then -- Yete asiga nevaz meg chene, user-in teradz tevere kordzadze
				self.Corpse:SetBodygroup(self.DeathCorpseBodyGroup.a, self.DeathCorpseBodyGroup.b)
			end
		end
		
		if self:IsOnFire() then -- If was on fire then...
			self.Corpse:Ignite(math.Rand(8, 10), 0)
			self.Corpse:SetColor(colorGrey)
			//self.Corpse:SetMaterial("models/props_foliage/tree_deciduous_01a_trunk")
		end
		//gamemode.Call("CreateEntityRagdoll",self,self.Corpse)
		
		-- Dissolve --
		if (bit.band(self.SavedDmgInfo.type, DMG_DISSOLVE) != 0) or (IsValid(self.SavedDmgInfo.inflictor) && self.SavedDmgInfo.inflictor:GetClass() == "prop_combine_ball") then
			self.Corpse:SetName("vj_dissolve_corpse")
			local dissolver = ents.Create("env_entity_dissolver")
			dissolver:SetPos(self.Corpse:GetPos())
			dissolver:Spawn()
			dissolver:Activate()
			//dissolver:SetKeyValue("target","vj_dissolve_corpse")
			dissolver:SetKeyValue("magnitude",100)
			dissolver:SetKeyValue("dissolvetype",0)
			dissolver:Fire("Dissolve","vj_dissolve_corpse")
			if IsValid(self.TheDroppedWeapon) then
				self.TheDroppedWeapon:SetName("vj_dissolve_weapon")
				dissolver:Fire("Dissolve","vj_dissolve_weapon")
			end
			dissolver:Fire("Kill", "", 0.1)
			//dissolver:Remove()
		end
		
		-- Bone and Angle --
		-- If it's a bullet, it will use localized velocity on each bone depending on how far away the bone is from the dmg position
		local useLocalVel = (bit.band(self.SavedDmgInfo.type, DMG_BULLET) != 0 and self.SavedDmgInfo.pos != defPos) or false
		local dmgForce = (self.SavedDmgInfo.force / 40) + self:GetMoveVelocity() + self:GetVelocity()
		if self.DeathAnimationCodeRan then
			useLocalVel = false
			dmgForce = self:GetMoveVelocity() == defPos and self:GetGroundSpeedVelocity() or self:GetMoveVelocity()
		end
		local totalSurface = 0
		local physCount = self.Corpse:GetPhysicsObjectCount()
		for boneLimit = 0, physCount - 1 do -- 128 = Bone Limit
			local childphys = self.Corpse:GetPhysicsObjectNum(boneLimit)
			if IsValid(childphys) then
				totalSurface = totalSurface + childphys:GetSurfaceArea()
				local childphys_bonepos, childphys_boneang = self:GetBonePosition(self.Corpse:TranslatePhysBoneToBone(boneLimit))
				if (childphys_bonepos) then
					//if math.Round(math.abs(childphys_boneang.r)) != 90 then -- Fixes ragdolls rotating, no longer needed!    --->    sv_pvsskipanimation 0
						if self.DeathCorpseSetBoneAngles == true then childphys:SetAngles(childphys_boneang) end
						childphys:SetPos(childphys_bonepos)
					//end
					if self.Corpse:GetName() == "vj_dissolve_corpse" then
						childphys:EnableGravity(false)
						childphys:SetVelocity(self:GetForward()*-150 + self:GetRight()*math.Rand(100,-100) + self:GetUp()*50)
					else
						if self.DeathCorpseApplyForce == true /*&& self.DeathAnimationCodeRan == false*/ then
							childphys:SetVelocity(dmgForce / math.max(1, (useLocalVel and childphys_bonepos:Distance(self.SavedDmgInfo.pos)/12) or 1))
						end
					end
				elseif physCount == 1 then -- If it's only 1, then it's likely a regular physics model with no bones
					if self.Corpse:GetName() == "vj_dissolve_corpse" then
						childphys:EnableGravity(false)
						childphys:SetVelocity(self:GetForward()*-150 + self:GetRight()*math.Rand(100,-100) + self:GetUp()*50)
					else
						if self.DeathCorpseApplyForce == true /*&& self.DeathAnimationCodeRan == false*/ then
							childphys:SetVelocity(dmgForce / math.max(1, (useLocalVel and self.Corpse:GetPos():Distance(self.SavedDmgInfo.pos)/12) or 1))
						end
					end
				end
			end
		end
		
		if self.Corpse:Health() <= 0 then
			local hpCalc = totalSurface / 60 // self.Corpse:OBBMaxs():Distance(self.Corpse:OBBMins())
			self.Corpse:SetMaxHealth(hpCalc)
			self.Corpse:SetHealth(hpCalc)
		end
		VJ_AddStinkyEnt(self.Corpse, true)
		
		if self.DeathCorpseFade == true then self.Corpse:Fire(self.Corpse.FadeCorpseType,"",self.DeathCorpseFadeTime) end
		if GetConVar("vj_npc_corpsefade"):GetInt() == 1 then self.Corpse:Fire(self.Corpse.FadeCorpseType,"",GetConVar("vj_npc_corpsefadetime"):GetInt()) end
		self:CustomOnDeath_AfterCorpseSpawned(dmginfo, hitgroup, self.Corpse)
		self.Corpse:CallOnRemove("vj_"..self.Corpse:EntIndex(),function(ent,exttbl)
			for _,v in ipairs(exttbl) do
				if IsValid(v) then
					if v:GetClass() == "prop_ragdoll" then v:Fire("FadeAndRemove","",0) else v:Fire("kill","",0) end
				end
			end
		end,self.Corpse.ExtraCorpsesToRemove)
		hook.Call("CreateEntityRagdoll", nil, self, self.Corpse)
		return self.Corpse
	else
		for _,v in ipairs(self.ExtraCorpsesToRemove_Transition) do
			if v.IsVJBase_Gib == true && v.RemoveOnCorpseDelete == true then
				v:Remove()
			end
		end
	end
end