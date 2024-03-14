---@diagnostic disable

MyAddOnScrollingClipBoardBoxMixin = CreateFromMixins(CallbackRegistryMixin)
MyAddOnScrollingClipBoardBoxMixin:GenerateCallbackEvents(
	{
		"OnTabPressed",
		"OnTextChanged",
		"OnCursorChanged",
		"OnFocusGained",
		"OnFocusLost",
		"OnEnterPressed",
	}
)

function MyAddOnScrollingClipBoardBoxMixin:OnLoad()
	CallbackRegistryMixin.OnLoad(self)

	assert(self.fontName)

	local scrollBox = self:GetScrollBox()
	scrollBox:SetAlignmentOverlapIgnored(true)

	local clipBoard = self:GetClipBoard()


	clipBoard.fontName = self.fontName
	clipBoard.defaultFontName = self.defaultFontName
	clipBoard:SetFontObject(self.fontName)

	local fontHeight = clipBoard:GetFontHeight()
	local bottomPadding = fontHeight * .5
	local view = CreateScrollBoxLinearView(0, bottomPadding, 0, 0, 0)
	view:SetPanExtent(fontHeight)
	scrollBox:Init(view)

	clipBoard:RegisterCallback("OnTabPressed", self.OnEditBoxTabPressed, self)
	clipBoard:RegisterCallback("OnTextChanged", self.OnEditBoxTextChanged, self)
	clipBoard:RegisterCallback("OnEnterPressed", self.OnEditBoxEnterPressed, self)
	clipBoard:RegisterCallback("OnCursorChanged", self.OnEditBoxCursorChanged, self)
	clipBoard:RegisterCallback("OnEditFocusGained", self.OnEditBoxFocusGained, self)
	clipBoard:RegisterCallback("OnEditFocusLost", self.OnEditBoxFocusLost, self)
	clipBoard:RegisterCallback("OnMouseUp", self.OnEditBoxMouseUp, self)
end

function MyAddOnScrollingClipBoardBoxMixin:SetInterpolateScroll(canInterpolateScroll)
	local scrollBox = self:GetScrollBox()
	scrollBox:SetInterpolateScroll(canInterpolateScroll)
end

function MyAddOnScrollingClipBoardBoxMixin:OnMouseDown()
	local clipBoard = self:GetClipBoard()
	clipBoard:SetFocus()
end

function MyAddOnScrollingClipBoardBoxMixin:OnEditBoxMouseUp()
	local allowCursorClipping = false
	self:ScrollCursorIntoView(allowCursorClipping)
end

function MyAddOnScrollingClipBoardBoxMixin:GetScrollBox()
	return self.ScrollBox
end

function MyAddOnScrollingClipBoardBoxMixin:HasScrollableExtent()
	local scrollBox = self:GetScrollBox()
	return scrollBox:HasScrollableExtent()
end

function MyAddOnScrollingClipBoardBoxMixin:GetClipBoard()
	return self:GetScrollBox().ClipBoard
end

function MyAddOnScrollingClipBoardBoxMixin:SetFocus()
	self:GetClipBoard():SetFocus()
end

function MyAddOnScrollingClipBoardBoxMixin:SetFontObject(fontName)
	local clipBoard = self:GetClipBoard()
	clipBoard:SetFontObject(fontName)

	local scrollBox = self:GetScrollBox()
	local fontHeight = clipBoard:GetFontHeight()
	local padding = scrollBox:GetPadding()
	padding:SetBottom(fontHeight * .5)

	scrollBox:SetPanExtent(fontHeight)
	scrollBox:FullUpdate(ScrollBoxConstants.UpdateImmediately)
	scrollBox:ScrollToBegin(ScrollBoxConstants.NoScrollInterpolation)
end

function MyAddOnScrollingClipBoardBoxMixin:ClearText()
	self:SetText("")
end

function MyAddOnScrollingClipBoardBoxMixin:SetText(text)
	local clipBoard = self:GetClipBoard()
	clipBoard:SetClipBoardText(text)

	local scrollBox = self:GetScrollBox()
	scrollBox:FullUpdate(ScrollBoxConstants.UpdateImmediately)
	scrollBox:ScrollToBegin(ScrollBoxConstants.NoScrollInterpolation)
end

function MyAddOnScrollingClipBoardBoxMixin:GetClipBoardText()
	local clipBoard = self:GetClipBoard()
	return clipBoard:GetInputText()
end

function MyAddOnScrollingClipBoardBoxMixin:GetFontHeight()
	local clipBoard = self:GetClipBoard()
	return clipBoard:GetFontHeight()
end

function MyAddOnScrollingClipBoardBoxMixin:ClearFocus()
	local clipBoard = self:GetClipBoard()
	clipBoard:ClearFocus()
end

function MyAddOnScrollingClipBoardBoxMixin:SetEnabled(enabled)
	local clipBoard = self:GetClipBoard()
	clipBoard:SetEnabled(enabled)
end

function MyAddOnScrollingClipBoardBoxMixin:OnEditBoxTabPressed(clipBoard)
	self:TriggerEvent("OnTabPressed", clipBoard)
end

function MyAddOnScrollingClipBoardBoxMixin:OnEditBoxTextChanged(clipBoard, userChanged)
	local scrollBox = self:GetScrollBox()
	scrollBox:FullUpdate(ScrollBoxConstants.UpdateImmediately)

	self:TriggerEvent("OnTextChanged", clipBoard, userChanged)
end

function MyAddOnScrollingClipBoardBoxMixin:OnEditBoxEnterPressed(clipBoard)
	self:TriggerEvent("OnEnterPressed", clipBoard)
end

function MyAddOnScrollingClipBoardBoxMixin:OnEditBoxCursorChanged(clipBoard, x, y, width, height, context)
	local scrollBox = self:GetScrollBox()
	scrollBox:FullUpdate(ScrollBoxConstants.UpdateImmediately)

	local allowCursorClipping = context ~= Enum.InputContext.Keyboard
	self:ScrollCursorIntoView(allowCursorClipping)

	self:TriggerEvent("OnCursorChanged", clipBoard, x, y, width, height)
end

function MyAddOnScrollingClipBoardBoxMixin:OnEditBoxFocusGained(clipBoard)
	self:TriggerEvent("OnFocusGained", clipBoard)
end

function MyAddOnScrollingClipBoardBoxMixin:OnEditBoxFocusLost(clipBoard)
	self:TriggerEvent("OnFocusLost", clipBoard)
end

function MyAddOnScrollingClipBoardBoxMixin:ScrollCursorIntoView(allowCursorClipping)
	local clipBoard = self:GetClipBoard()
	local cursorOffset = -clipBoard:GetCursorOffset()
	local cursorHeight = clipBoard:GetCursorHeight()

	local scrollBox = self:GetScrollBox()
	local editBoxExtent = scrollBox:GetFrameExtent(clipBoard)
	if editBoxExtent <= 0 then
		return
	end

	local scrollOffset = Round(scrollBox:GetDerivedScrollOffset())
	if cursorOffset < scrollOffset then
		local visibleExtent = scrollBox:GetVisibleExtent()
		local deltaExtent = editBoxExtent - visibleExtent
		if deltaExtent > 0 then
			local percentage = cursorOffset / deltaExtent
			scrollBox:ScrollToFrame(clipBoard, percentage)
		end
	else
		local visibleExtent = scrollBox:GetVisibleExtent()
		local offset = allowCursorClipping and cursorOffset or (cursorOffset + cursorHeight)
		if offset >= (scrollOffset + visibleExtent) then
			local deltaExtent = editBoxExtent - visibleExtent
			if deltaExtent > 0 then
				local descenderPadding = math.floor(cursorHeight * .3)
				local cursorDeltaExtent = offset - visibleExtent
				if cursorDeltaExtent + descenderPadding > deltaExtent then
					scrollBox:ScrollToEnd()
				else
					local percentage = (cursorDeltaExtent + descenderPadding) / deltaExtent
					scrollBox:ScrollToFrame(clipBoard, percentage)
				end
			end
		end
	end
end
