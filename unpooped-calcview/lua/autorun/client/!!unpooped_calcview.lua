print("[unpoopedcalcview] loaded")

UNPOOPED_CALCVIEW = true

local _CVData = { }

_CVData.__index = _CVData
AccessorFunc( _CVData, "Origin", "Origin", FORCE_VECTOR )
AccessorFunc( _CVData, "Player", "Player" )
AccessorFunc( _CVData, "Angles", "Angles", FORCE_ANGLE )
AccessorFunc( _CVData, "FOV", "FOV", FORCE_NUMBER )
AccessorFunc( _CVData, "ZNear", "ZNear", FORCE_NUMBER )
AccessorFunc( _CVData, "ZFar", "ZFar", FORCE_NUMBER )
AccessorFunc( _CVData, "DrawViewer", "DrawViewer", FORCE_BOOL )
AccessorFunc( _CVData, "Override", "Override", FORCE_BOOL )

RegisterMetaTable( "CVData", _CVData )

function CVData( )
	return setmetatable( { }, _CVData )
end

local _VMData = { }

_VMData.__index = _VMData
AccessorFunc( _VMData, "Weapon", "Weapon" )
AccessorFunc( _VMData, "Viewmodel", "Viewmodel" )
AccessorFunc( _VMData, "OldPosition", "OldPosition", FORCE_VECTOR )
AccessorFunc( _VMData, "OldAngles", "OldAngles", FORCE_ANGLE )
AccessorFunc( _VMData, "Position", "Position", FORCE_VECTOR )
AccessorFunc( _VMData, "Angles", "Angles", FORCE_ANGLE )
AccessorFunc( _VMData, "Override", "Override", FORCE_BOOL )

RegisterMetaTable( "VMData", _VMData )

function VMData( )
	return setmetatable( { }, _VMData )
end

local function RunCalcViewEx( Player, Origin, Angles, FOV, ZNear, ZFar )
	local Data = CVData( )

	Data:SetPlayer( Player )
	Data:SetOrigin( Origin )
	Data:SetAngles( Angles )
	Data:SetFOV( FOV )
	Data:SetZNear( ZNear )
	Data:SetZFar( ZFar )
	Data:SetDrawViewer( false )
	Data:SetOverride( false )

	local ExHooks = hook.GetTable( )[ "CalcViewEx" ]

	if ( ExHooks ) then
		for Name, Function in pairs( ExHooks ) do
			Function( Data )
			if Data:GetOverride( ) then
				break
			end
		end
	end

	return Data:GetPlayer( ), Data:GetOrigin( ), Data:GetAngles( ), Data:GetFOV( ), Data:GetZNear( ), Data:GetZFar( ), Data:GetDrawViewer( )
end

local function RunCalcViewModelViewEx( Weapon, Viewmodel, OldPosition, OldAngles, Position, Angles )
	local Data = VMData( )

	Data:SetWeapon( Weapon )
	Data:SetViewmodel( Viewmodel )
	Data:SetOldPosition( OldPosition )
	Data:SetOldAngles( OldAngles )
	Data:SetPosition( Position )
	Data:SetAngles( Angles )

	local ExHooks = hook.GetTable( )[ "CalcViewModelViewEx" ]

	if ( ExHooks ) then
		for Name, Function in pairs( ExHooks ) do
			Function( Data )
			if ( Data:GetOverride( ) ) then
				break
			end
		end
	end

	return Data:GetWeapon( ), Data:GetViewmodel( ), Data:GetOldPosition( ), Data:GetOldAngles( ), Data:GetPosition( ), Data:GetAngles( )
end

local CalcViewExCalled = false
local CalcViewModelViewExCalled = false

local HookCallOriginal = hook.Call
hook.Call = function( Name, Gamemode, ... )
	if Name == "CalcView" then
		if CalcViewExCalled then
			return HookCallOriginal( Name, Gamemode, ... )
		end

		CalcViewExCalled = true
		local Player, Origin, Angles, FOV, ZNear, ZFar, DrawViewer = RunCalcViewEx( ... )
		local Result = HookCallOriginal( Name, Gamemode, Player, Origin, Angles, FOV, ZNear, ZFar )
		CalcViewExCalled = false

		if DrawViewer then
			Result["drawviewer"] = true
		end

		return Result
	end

	if Name == "CalcViewModelView" then
		if CalcViewModelViewExCalled then
			return HookCallOriginal( Name, Gamemode, ... )
		end

		CalcViewModelViewExCalled = true
		local Weapon, Viewmodel, OldPosition, OldAngles, Position, Angles = RunCalcViewModelViewEx( ... )
		local out, out2 = HookCallOriginal( Name, Gamemode, Weapon, Viewmodel, OldPosition, OldAngles, Position, Angles )
		CalcViewModelViewExCalled = false

		return out, out2
	end

	return HookCallOriginal( Name, Gamemode, ... )
end

hook.Add( "Initialize", "jeff_the_killer_came_to_me_in_my_sleep_and_said_skibidi_dop_dop_yes_yes", function( )
	timer.Simple( 1, function( )
		if !VManip then return end

		local Function = hook.GetTable( )[ "CalcView" ][ "VManip_Cam" ]
		if ( isfunction( Function ) ) then
			hook.Remove( "CalcView", "VManip_Cam" )

			hook.Add( "CalcViewEx", "VManip_Cam", function( Data ) 
			    if ( !VManip:IsActive( ) || !VManip.Attachment ) then 
			    	return 
			    end

			    if ( ( Data:GetPlayer( ):GetViewEntity( ) != Data:GetPlayer( ) ) || Data:GetPlayer( ):ShouldDrawLocalPlayer( ) ) then 
			    	return 
			    end

			    local Ang = VManip.Attachment.Ang - VManip.Cam_Ang

			    Ang.x = Ang.x * VManip.Cam_AngInt[ 1 ]
			    Ang.y = Ang.y * VManip.Cam_AngInt[ 2 ]
			    Ang.z = Ang.z * VManip.Cam_AngInt[ 3 ]

			    Data:GetAngles( ):Add( Ang )
			end )
		end
	end )
end )