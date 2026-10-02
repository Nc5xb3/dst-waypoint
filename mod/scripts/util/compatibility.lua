-- Adding support for compatibility between DS and DST
local Compatibility = Class(function(self)
	self.DST = TheSim:GetGameID() == "DST"
end)

function Compatibility:IsDST()
	return self.DST
end
function Compatibility:ThePlayer()
	if self.DST then
		return ThePlayer
	end
	return GetPlayer()
end
function Compatibility:TheWorld()
	if self.DST then
		return TheWorld
	end
	return GetWorld()
end

function Compatibility:NewFont()
	if self.DST then
		return NEWFONT
	end
	return TALKINGFONT
end

function Compatibility:Button()
	if self.DST then
		return require "widgets/button"
	end
	return require "widgets/dstbutton"
end
function Compatibility:Image()
	if self.DST then
		return require "widgets/image"
	end
	return require "widgets/dstimage"
end
function Compatibility:ImageButton()
	if self.DST then
		return require "widgets/imagebutton"
	end
	return require "widgets/dstimagebutton"
end
function Compatibility:Text()
	if self.DST then
		return require "widgets/text"
	end
	return require "widgets/dsttext"
end
function Compatibility:TextButton()
	if self.DST then
		return require "widgets/textbutton"
	end
	return require "widgets/dsttextbutton"
end
function Compatibility:TextEdit()
	if self.DST then
		return require "widgets/textedit"
	end
	return require "widgets/dsttextedit"
end

return Compatibility()