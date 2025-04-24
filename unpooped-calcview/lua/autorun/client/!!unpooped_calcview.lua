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

local function CalcViewOverride( Player, Origin, Angles, FOV, ZNear, ZFar, ... )
	local Vehicle = Player:GetVehicle( )

	local View = {
		["origin"] = Origin,
		["angles"] = Angles,
		["fov"] = FOV,
		["znear"] = ZNear,
		["zfar"] = ZFar,
		["drawviewer"] = false
	}

	if ( IsValid( Vehicle ) ) then
		return hook.Run( "CalcVehicleView", Vehicle, Player, View ) 
	end

	local Weapon = Player:GetActiveWeapon( )

	if ( IsValid( Weapon ) ) then
		local Function = Weapon.CalcView
		if ( Function ) then
			local WeaponOrigin, WeaponAngles, WeaponFOV = Function( Weapon, Player, Vector( View.origin ), Angle( View.angles ), View.fov )

			View.origin = WeaponOrigin or View.origin
			View.angles = WeaponAngles or View.angles
			View.fov = WeaponFOV or View.fov
		end
	end

	local Data = CVData( )

	Data:SetPlayer( Player )
	Data:SetOrigin( View.origin )
	Data:SetAngles( View.angles )
	Data:SetFOV( View.fov )
	Data:SetZNear( View.znear )
	Data:SetZFar( View.zfar )
	Data:SetDrawViewer( View.drawviewer )
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

	View.origin = Data:GetOrigin( )
	View.angles = Data:GetAngles( )
	View.fov = Data:GetFOV( )
	View.znear = Data:GetZNear( )
	View.zfar = Data:GetZFar( )
	View.drawviewer = Data:GetDrawViewer( )

	local Hooks = hook.GetTable( )[ "CalcView" ]

	if ( Hooks ) then
		for Name, Function in pairs( Hooks ) do
			local HookView = Function( Player, View.origin, View.angles, View.fov, View.znear, View.zfar, ... )

			if HookView then
				return HookView
			end
		end
	end

	// player_manager.RunClass( Player, "CalcView", View, ... )

	if ( drive.CalcView( Player, View ) ) then
		return View 
	end

	return View
end

local function CalcViewModelViewOverride( Weapon, Viewmodel, OldPosition, OldAngles, Position, Angles )
	//local ReturnPosition = Vector( OldPosition )
	//local ReturnAngles = Angle( OldAngles )

	if ( IsValid( Weapon ) ) then
		local Function = Weapon.CalcViewModelView
		if ( Function ) then
			local FuncPosition, FuncAngles = Function( Weapon, Viewmodel, OldPosition, OldAngles, Position, Angles )
			if ( FuncPosition and FuncAngles ) then
				Position = FuncPosition
				Angles = FuncAngles
			end
		end

		local Function2 = Weapon.GetViewModelPosition
		if ( Function2 ) then
			local FuncPosition, FuncAngles = Function2( Weapon, Position, Angles )
			if ( FuncPosition and FuncAngles ) then
				Position = FuncPosition
				Angles = FuncAngles
			end
		end
	end

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

	Position = Data:GetPosition( )
	Angles = Data:GetAngles( )

	local Hooks = hook.GetTable( )[ "CalcViewModelView" ]

	if ( Hooks ) then
		for Name, Function in pairs( Hooks ) do
			local HookPosition, HookAngles = Function( Weapon, Viewmodel, OldPosition, OldAngles, Position, Angles )

			if ( HookPosition && HookAngles ) then
				return HookPosition, HookAngles
			end
		end
	end

	return Position, Angles
end

local HookCallOriginal = hook.Call
hook.Call = function( name, gm, ... )
	if name == "CalcView" then
		local a, b, c, d, e, f = CalcViewOverride( ... )
		return a, b, c, d, e, f
	end
	
	if name == "CalcViewModelView" then
		local a, b, c, d, e, f = CalcViewModelViewOverride( ... )
		return a, b, c, d, e, f
	end

	return HookCallOriginal( name, gm, ... )
end