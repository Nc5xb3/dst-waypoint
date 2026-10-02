local function fn()
	local inst = CreateEntity()

	inst:AddTag("FX")
	inst:AddTag("NOCLICK")

	inst.persists = false

	inst.entity:AddTransform()
	inst.entity:AddMiniMapEntity()

	inst.Transform:SetScale(1,1,1)

	if not TheFrontEnd.NMapIconTemplateManager then
		local Compatibility = require "util/compatibility"
		inst.MiniMapEntity:SetIcon("flagmini.tex")
		if Compatibility:IsDST() then
	        inst.MiniMapEntity:SetPriority(1)
	        inst.MiniMapEntity:SetDrawOverFogOfWar(true)
		end
	end

	return inst
end

return Prefab("common/flagplacer", fn)