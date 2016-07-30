local whitelist = {
    -- buffs/debuffs blizzard possibly dont find worthy
    -- not all buffs tested, better to be safe than sorry
    
    -- ROG
    --- buffs
    [2983] = true, -- sprint
    [35729] = true, -- clos
    [32645] = true, -- env
    [13750] = true, -- ar
    [13877] = true, -- bf
    [5277] = true, -- evasion
    [199754] = true, -- riposte
    [199603] = true, -- rtb - jolly roger
    [193358] = true, -- rtb - grand melee
    [193357] = true, -- rtb - shark infested waters
    [193359] = true, -- rtb - true bearing
    [199600] = true, -- rtb - buried treasure
    [193356] = true, -- rtb - broadsides
    [121471] = true, -- shadow blades
    [185313] = true, -- shadow dance
    [36554] = true, -- shadow step
    [212283] = true, -- symbols of death
    [193539] = true, -- alacrity
    [193640] = true, -- elaborate planning
    [206237] = true, -- enveloping shadows
    [51690] = true, -- killing spree
    [5171] = true, -- slice and dice
    [185311] = true, -- crimson vial
    [1966] = true, -- feint
    
    --- debuffs
    [200802] = true, -- ago poison
    [196937] = true, -- ghostly strike
    [16511] = true, -- hemo
    [137619] = true, -- marked for death
    [199743] = true, -- parley
    [192759] = true, -- kingsbane
    [2094] = true, -- blind
    [199740] = true, -- bribe
    
    
}

local blacklist = {
    [193316] = true, -- rtb - why the fuck are they showing this?_?
}

local function UpdateBuffs(self, unit, filter)
    self.unit = unit
    self.filter = filter
    self:UpdateAnchor()
    
    for i = 1, BUFF_MAX_DISPLAY do
        if (filter == "NONE" and self.buffList[i]) then
            self.buffList[i]:Hide()
            return
        end
        
        local name, rank, texture, count, debuffType, duration, expirationTime, caster, _, nameplateShowPersonal, spellId, _, _, _, nameplateShowAll = UnitAura(unit, i, filter)
        
        if((self:ShouldShowBuff(name, caster, nameplateShowPersonal, nameplateShowAll, duration) or whitelist[spellId]) and not blacklist[spellId]) then
            if (not self.buffList[i]) then
                self.buffList[i] = CreateFrame("Frame", self:GetParent():GetName() .. "Buff" .. i, self, "NameplateBuffButtonTemplate")
            end
            
            local buff = self.buffList[i]
            buff:SetID(i)
            buff.name = name
            buff.layoutIndex = i
            buff.Icon:SetTexture(texture)
            
            if(count > 1) then
                buff.CountFrame.Count:SetText(count)
                buff.CountFrame.Count:Show()
            else
                buff.CountFrame.Count:Hide()
            end
            
            if (buff.Cooldown.TimerTicker and not buff.Cooldown.TimerTicker._cancelled) then
			buff.Cooldown.TimerTicker:Cancel()
		end
		
		CooldownFrame_Set (buff.Cooldown, expirationTime - duration, duration, duration > 0, true)
            
            buff:Show()
        else
            if(self.buffList[i]) then
                self.buffList[i]:Hide()
            end
        end
    end
    self:Layout()
end

hooksecurefunc(NameplateBuffContainerMixin, 'UpdateBuffs', UpdateBuffs)