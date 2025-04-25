# extended-calcview
 extended calcview waaaaaaaaaaaat

Don't you just hate the traditional calcview hook?.. no? Well I do.

This tool adds two new hooks: CalcViewEx and CalcViewModelViewEx. Both of them provide you with the ability to change given data by calling methods on an object, before CalcView and CalcViewModelView get called respectively.

As it stands, this will most likely break mods that rely on those hooks. Please report them to me, along with steps to reproduce the bug.
Here's a list of known baddies that I can't really fix properly:
- Actually none yet!

New classes / metatables:
```
- CVData - Data that gets passed to you in the CalcViewEx hooks
	- SetOrigin & GetOrigin
	- SetPlayer & GetPlayer
	- SetAngles & GetAngles
	- SetFOV & GetFOV
	- SetZNear & GetZNear
	- SetZFar & GetZFar
	- SetDrawViewer & GetDrawViewer
	- SetOverride & GetOverride - This means the execution will stop at the hook where it was set to true.

- VMData - Data that gets passed to you in the CalcViewModelViewEx hooks
	- SetWeapon & GetWeapon
	- SetViewmodel & GetViewmodel
	- SetOldPosition & GetOldPosition
	- SetOldAngles & GetOldAngles
	- SetPosition & GetPosition
	- SetAngles & GetAngles
	- SetOverride & GetOverride - This means the execution will stop at the hook where it was set to true.
```

New hooks:
```
- CalcViewEx(CVData data)
- CalcViewModelViewEx(VMData data)
```

Example:
```
hook.Add("CalcViewEx", "epic", function(data) 
	data:SetFOV(data:GetFOV() + 20)
end)

hook.Add("CalcViewModelViewEx", "epic", function(data) 
	data:SetAngles(Angle(90, 90, 90))
end)
```
