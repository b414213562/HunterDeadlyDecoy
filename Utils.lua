
-- This label is for stripping markup, do not touch!
getRawText = Turbine.UI.Label();
getRawText:SetMarkupEnabled(true);

function GetRawText(textWithMarkup)
    getRawText:SetText(textWithMarkup);
    return getRawText:GetText();
end

-- End stripping markup

-- Basic debug function to look at a table:
function dump(o)
   if type(o) == 'table' then
      local s = '{ '
      for k,v in pairs(o) do
         if type(k) ~= 'number' then k = '"'..k..'"' end
         s = s .. '['..k..'] = ' .. dump(v) .. ','
      end
      return s .. '} '
   else
      return tostring(o)
   end
end
