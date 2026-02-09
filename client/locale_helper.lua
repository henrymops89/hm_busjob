-- Locale helper function - wrapper for Locale.Translate
-- Store reference to the Locale table before defining the function
local LocaleTable = Locale

function Locale(key, ...)
    return LocaleTable.Translate(key, ...)
end
