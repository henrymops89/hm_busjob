Locale = {}
Locale.Locales = {}
Locale.FallbackLocale = 'en'

function Locale.Load(locale)
    if Locale.Locales[locale] then
        return Locale.Locales[locale]
    end
    
    if Config.Debug then
        print(string.format('^3[Locale]^7 Locale ^3%s^7 not found, using fallback ^3%s^7', locale, Locale.FallbackLocale))
    end
    
    return Locale.Locales[Locale.FallbackLocale] or {}
end

function Locale.Translate(key, ...)
    local locale = Locale.Load(Config.Locale)
    local translation = locale[key]
    
    if not translation then
        if Config.Debug then
            print(string.format('^1[Locale]^7 Missing translation key: ^3%s^7', key))
        end
        return key
    end
    
    if ... then
        return string.format(translation, ...)
    end
    
    return translation
end

-- Shorthand function
function L(key, ...)
    return Locale.Translate(key, ...)
end
