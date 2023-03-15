--[[
* Hello Dear Dev, if you read this you just downloaded my addon.
* I must warn you, I am not the best coder, I tried to optimize it as I could. But it isn't perfect.
* if you are wondering why I use "? * ! +" in front of my commentary it is just the better commentary extention for VS Code
? if you have any problems with my addon you can contact me on steam or my github : "https://github.com/avivi55"
! It uses Fortification Props Model Pack "https://steamcommunity.com/sharedfiles/filedetails/?id=422672588"
]]

AddCSLuaFile( 'cl_init.lua' )
AddCSLuaFile( 'shared.lua' )

include( 'shared.lua' )

--+ Initial health amount
ENT.DefaultHealth = 1000

function ENT:Initialize()

	--+ prepare a table of those who will take damage
	self.Delays = {}

	--+ https://wiki.facepunch.com/gmod/ENTITY:StartTouch
	self:SetTrigger( true )

	--+ Health setup
	self:SetMaxHealth( self.DefaultHealth )
	self:SetHealth( self.DefaultHealth )

	--+ setting physics parameters
	self:SetModel( 'models/barbed_prop/lapland02_128.mdl' )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )

	--+ creating a physical object
	self:PhysicsInit( SOLID_VPHYSICS )

	--+ "unfreezing" the object
	self:PhysWake()

end

--* if you want to constrain a job to be able to use this functionality.
/*function ENT:Use( activator, caller )
	local job_command = caller:getJobTable().command
	if( job_command == ???)then --* ONLY IN DARK RP
		self:SetCreator( caller ) --+ allows any player who wants to move it to do it.
	end
end*/

ENT.DamageScale = {

	--+ melee damage, 200%
	[ DMG_GENERIC ] = 2,
	[ DMG_CLUB ] = 2,

	--+ bullets, 50%
	[ DMG_BULLET ] = 0.5,

	--+ fire damage, 80%
	[ DMG_BURN ] = 0.8,

	--+ explosions, 100%
	[ DMG_BLAST ] = 1,

	--+ vehicles, kills immediately
	[ DMG_VEHICLE ] = function( self, dmg )
		dmg:SetDamage( self:Health() )
	end

}

--+ lua damage, like ENT:TakeDamage, I'm not sure it's worth considering...
-- ENT.DamageScale[ DMG_DIRECT ] = ENT.DamageScale[ DMG_VEHICLE ]

function ENT:OnTakeDamage( dmg )
	--+ damage scaling
	for damageType, value in pairs( self.DamageScale ) do
		if ( bit.band( dmg:GetDamageType(), damageType ) == damageType ) then
			if isnumber( value ) then
				dmg:ScaleDamage( value )
			elseif isfunction( value ) then
				value( self, dmg )
			end
		end
	end

	--+ applying damage
	local health = math.floor( self:Health() - dmg:GetDamage() )
	if ( health <= 0 ) then
		self:Remove()
		return
	end

	self:SetHealth( health )
end

function ENT:StartTouch( ent )
	if ent:IsVehicle() then
		local phys = ent:GetPhysicsObject()
		if not IsValid( phys ) then return end
		self:TakeDamage( ( phys:GetVelocity():Length() / 200 ) * self:Health(), ent, ent )
		return
	end

	--+ dealing damage to a player
	if ( ent:IsPlayer() and ent:Alive() ) or ent:IsNPC() then
		if ( ( self.Delays[ ent:EntIndex() ] or 0 ) > CurTime() ) then return end
		self.Delays[ ent:EntIndex() ] = CurTime() + 0.5

		local dmg = DamageInfo()

		dmg:SetDamage( math.random( 5, 10 ) )
		dmg:SetDamageType( DMG_SLASH )
		dmg:SetInflictor( self )
		dmg:SetAttacker( ent )

		ent:TakeDamageInfo( dmg )

		sound.Play( 'physics/metal/metal_chainlink_impact_hard' .. math.random( 1, 3 ) .. '.wav', ent:GetPos(), 75, math.random( 90, 120 ) )
	end
end

function ENT:OnRemove()
	self:EmitSound( 'physics/wood/wood_box_break' .. math.random( 1, 2 ) .. '.wav' ) --+ wood break sound, on barbed wire removal
end