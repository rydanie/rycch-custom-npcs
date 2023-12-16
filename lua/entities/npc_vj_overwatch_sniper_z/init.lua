AddCSLuaFile("shared.lua")
include("shared.lua")

ENT.Model = {"models/DPFilms/Metropolice/female_police.mdl"}
ENT.StartHealth = 80

ENT.HasWeaponBackAway = false -- Should the SNPC back away if the enemy is close?
ENT.WeaponBackAway_Distance = 250 -- When the enemy is this close, the SNPC will back away | 0 = Never back away
ENT.MoveRandomlyWhenShooting = false -- Should it move randomly when shooting?
--ENT.CanCrouchOnWeaponAttackChance = 1 -- How much chance of crouching? | 1 = Crouch every time
ENT.CanCrouchOnWeaponAttack = false -- Can it crouch while shooting?
ENT.AnimTbl_WeaponAttackCrouch = {ACT_RUN_CROUCH_AIM} -- Animation played when the SNPC does weapon attack while crouching | For VJ Weapons
ENT.AnimTbl_WeaponAim = {ACT_RUN_CROUCH_AIM}
ENT.HasShootWhileMoving = false
--ENT.AnimTbl_WeaponAttackFiringGesture = {ACT_RUN_CROUCH_AIM} -- Firing Gesture animations used when the SNPC is firing the weapon
ENT.AnimTbl_TakingCover = {ACT_COVER_LOW_RPG} -- The animation it plays when hiding in a covered position
ENT.AnimTbl_MoveToCover = {ACT_RUN_CROUCH_RIFLE} -- The animation it plays when moving to a covered position
ENT.AnimTbl_Walk = {ACT_RUN_CROUCH_RIFLE} -- Set the walking animations | Put multiple to let the base pick a random animation when it moves
ENT.AnimTbl_Run = {ACT_RUN_CROUCH_RIFLE} -- Set the running animations | Put multiple to let the base pick a random animation when it moves

ENT.HasMeleeAttack = false -- Should the SNPC have a melee attack?
ENT.MeleeAttackDamage = 10
ENT.MeleeAttackDamageType = DMG_CLUB -- Type of Damage
ENT.HasMeleeAttackKnockBack = true -- Should knockback be applied on melee hit? | Use self:MeleeAttackKnockbackVelocity() to edit the velocity
	-- ====== Animation Variables ====== --
ENT.AnimTbl_MeleeAttack = {ACT_MELEE_ATTACK_SWING} -- Melee Attack Animations
ENT.MeleeAttackAnimationDelay = 0 -- It will wait certain amount of time before playing the animation
ENT.MeleeAttackAnimationFaceEnemy = true -- Should it face the enemy while playing the melee attack animation?
ENT.MeleeAttackAnimationDecreaseLengthAmount = 0 -- This will decrease the time until starts chasing again. Use it to fix animation pauses until it chases the enemy.
ENT.MeleeAttackAnimationAllowOtherTasks = false -- If set to true, the animation will not stop other tasks from playing, such as chasing | Useful for gesture attacks!

ENT.HasGrenadeAttack = false -- Should the NPC have a grenade attack?
ENT.GrenadeAttackEntity = "npc_drop_flash" -- Entities that it can spawn when throwing a grenade | If set as a table, it picks a random entity | VJ: "obj_vj_grenade" | HL2: "npc_grenade_frag"
ENT.GrenadeAttackModel = nil -- Overrides the model of the grenade | Can be nil, string, and table | Does NOT apply to picked up grenades and forced grenade attacks with custom entity
ENT.GrenadeAttackAttachment = "anim_attachment_LH" -- The attachment that the grenade will be set to | -1 = Skip to use "self.GrenadeAttackBone" instead
ENT.GrenadeAttackBone = "ValveBiped.Bip01_L_Finger1" -- The bone that the grenade will be set to | -1 = Skip to use fail safe instead
	-- ====== Animation Variables ====== --
ENT.AnimTbl_GrenadeAttack = {"grenThrow"} -- Grenade Attack Animations
ENT.GrenadeAttackAnimationDelay = 0 -- It will wait certain amount of time before playing the animation
ENT.GrenadeAttackAnimationFaceEnemy = true -- Should it face the enemy while playing the grenade attack animation?
	-- ====== Distance & Chance Variables ====== --
ENT.ThrowGrenadeChance = 4 -- Chance that it will throw the grenade | Set to 1 to throw all the time
ENT.GrenadeAttackThrowDistance = 1 -- How far it can throw grenades
ENT.GrenadeAttackThrowDistanceClose = 1 -- How close until it stops throwing grenades
	-- ====== Timer Variables ====== --
	-- Set this to false to make the attack event-based:
ENT.TimeUntilGrenadeIsReleased = 0.72 -- Time until the grenade is released

-- ====== Constantly Face Enemy Variables ====== --
ENT.ConstantlyFaceEnemy = false -- Should it face the enemy constantly?
ENT.ConstantlyFaceEnemy_IfVisible = false -- Should it only face the enemy if it's visible?
ENT.ConstantlyFaceEnemy_IfAttacking = true -- Should it face the enemy when attacking?
ENT.ConstantlyFaceEnemy_Postures = "Standing" -- "Both" = Moving or standing | "Moving" = Only when moving | "Standing" = Only when standing
ENT.ConstantlyFaceEnemyDistance = 2500 -- How close does it have to be until it starts to face the enemy?
    -- ====== Combat Face Enemy Variables ====== --
    -- Mostly used by base tasks
ENT.CombatFaceEnemy = false -- If enemy exists and is visible