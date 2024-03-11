---@diagnostic disable

local function inject(tbl, method, func)
  local oldMethod = tbl[method]
  tbl[method] = function(self, ...)
    func(self, oldMethod, ...)
  end
end

MyAddOnClipBoardMixin = CreateFromMixins(CallbackRegistryMixin)

MyAddOnClipBoardMixin:GenerateCallbackEvents{
  "OnMouseDown",
  "OnMouseUp",
  "OnTabPressed",
  "OnTextChanged",
  "OnCursorChanged",
  "OnEscapePressed",
  "OnEditFocusGained",
  "OnEditFocusLost",
  "OnClipBoardChanged",
  "OnClipBoardCopied"
}

function MyAddOnClipBoardMixin:OnLoad_Intrinsic()
  CallbackRegistryMixin.OnLoad(self)
  inject(self, "SetMultiLine", MyAddOnClipBoardMixin.PreSetMultiline)
  inject(self, "SetFont", MyAddOnClipBoardMixin.OnSetFont)
  inject(self, "SetSpacing", MyAddOnClipBoardMixin.OnSetSpacing)
  inject(self, "SetFontObject", MyAddOnClipBoardMixin.OnSetFontObject)
  self:UpdateTextInsets()
end

function MyAddOnClipBoardMixin:UpdateTextInsets()
  if self:IsMultiLine() then
    local height, spacing = self:GetFontHeight(), self:GetSpacing()
    local overscan = height + spacing
    self:SetTextInsets(0, 0, -overscan, -overscan)
  else
    self:SetTextInsets(0, 0, 0, 0)
  end
end

function MyAddOnClipBoardMixin:OnSetMultiline(callback, multiLine)
  callback(self, multiLine)
  self:UpdateTextInsets()
end

function MyAddOnClipBoardMixin:OnSetFontObject(callback, ...)
  callback(self, ...)
  self:UpdateTextInsets()
end

function MyAddOnClipBoardMixin:OnSetFont(callback, ...)
  callback(self, ...)
  self:UpdateTextInsets()
end

function MyAddOnClipBoardMixin:OnSetSpacing(callback, ...)
  callback(self, ...)
  self:UpdateTextInsets()
end

function MyAddOnClipBoardMixin:OnMouseDown_Intrinsic()
	self:SetFocus();
	self:TriggerEvent("OnMouseDown", self);
end

function MyAddOnClipBoardMixin:OnMouseUp_Intrinsic()
	self:TriggerEvent("OnMouseUp", self);
end

function MyAddOnClipBoardMixin:OnTabPressed_Intrinsic()
	self:TriggerEvent("OnTabPressed", self);
end

function MyAddOnClipBoardMixin:OnEditFocusGained_Intrinsic()
  self:HighlightClipBoardText()
  self:TriggerEvent("OnEditFocusGained", self);
end

function MyAddOnClipBoardMixin:OnEditFocusLost_Intrinsic()
	self:ClearHighlightText();

	self:TriggerEvent("OnEditFocusLost", self);
end

function MyAddOnClipBoardMixin:OnCursorChanged_Intrinsic(x, y, width, height, context)
  if self:IsMultiLine() then
    local cursor = self:GetCursorPosition()
    if cursor == 0 then
      self:SetCursorPosition(1)
    elseif cursor == #self:GetText() then
      self:SetCursorPosition(cursor - 1)
    end
  end
  self:HighlightClipBoardText()
  -- we shouldn't change the cursorOffset & height, even if we bumped the cursor
  -- because those are used in ScrollingClipBoardMixin:ScrollCursorIntoView,
  -- which might scroll to the wrong point and put the cursor in the overscan if we 'fixed' this
	self.cursorOffset = y
	self.cursorHeight = height
  self:TriggerEvent("OnCursorChanged", self, x, y, width, height, context)
end

function MyAddOnClipBoardMixin:OnEscapePressed_Intrinsic()
	self:ClearFocus();

	self:TriggerEvent("OnEscapePressed", self);
end

function MyAddOnClipBoardMixin:OnArrowPressed_Intrinsic(key)
  -- singleline editboxes don't clear Highlight on up/down, so long as history is always clear,
  -- but they do clear it on left/right if the cursor is at the respective bookend
  if self:IsMultiLine() then return end
  self:HighlightClipBoardText()
end

function MyAddOnClipBoardMixin:OnTextChanged_Intrinsic()
  if not self:TextIsClipBoardText() then
    self:SetText(self.clipBoardText)
    if not self:IsMultiLine() then
      self:ClearHistory()
    else
      self:SetCursorPosition(1)
    end
    self:HighlightClipBoardText()
  end
end

function MyAddOnClipBoardMixin:OnKeyDown(key)
  if key == "c" and IsControlKeyDown() then
    self:TriggerEvent("OnClipBoardCopied", self)
  end
end

function MyAddOnClipBoardMixin:HighlightClipBoardText()
  if not self:IsMultiLine() then
    self:HighlightText()
  else
    self:HighlightText(1, #self.clipBoardText - 1)
  end
end

function MyAddOnClipBoardMixin:TextIsClipBoardText()
  if not self:IsMultiLine() then
    return self:GetText() == self.clipBoardText
  else
    return self:GetText() == ("\n%s\n"):format(self.clipBoardText)
  end
end

function MyAddOnClipBoardMixin:SetClipBoardText(text)
  assert(type(text) == "string", "text must be a string")
  local changed = self.clipBoardText ~= text
  if #text > 0 then
    self:Enable()
    self.clipBoardText = text
  else
    self.clipBoardText = ""
    self:Disable()
  end
  self:SetText((self:IsMultiLine() and #text > 0) and ("\n%s\n"):format(text) or text)
  self:ClearHistory()
  if self:IsMultiLine() then
    self:SetCursorPosition(1)
  end
  if changed then
    self:TriggerEvent("OnClipBoardChanged", self)
  end
end

function MyAddOnClipBoardMixin:GetCursorOffset()
	return self.cursorOffset or 0;
end

function MyAddOnClipBoardMixin:GetCursorHeight()
	return self.cursorHeight or 0;
end

function MyAddOnClipBoardMixin:GetFontHeight()
	return select(2, self:GetFont());
end

function MyAddOnClipBoardMixin:GetClipBoardText()
	return self.clipBoardText
end

