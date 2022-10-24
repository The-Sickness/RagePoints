RagePoints_UpdateRate = 0.2;
RagePoints_Elapsed = 0;
RagePoints_LastPower = -1;
RagePoints_LastCombo = -1;

function RagePoints_EvtHandler(self, event, ...)
	local unit;

	if event == "UNIT_MAXPOWER" or event == "UNIT_DISPLAYPOWER" then
		unit = ...;
	end

	if unit == "player" or event == "PLAYER_ENTERING_WORLD" then
		-- Mana (current/max)
		if UnitPowerType("player") == SPELL_POWER_MANA then
			RagePoints_Rage:SetText(UnitPowerMax("player") .." / ".. UnitPowerMax("player"));

		-- Energy (energy/combo)
		elseif UnitPowerType("player") == SPELL_POWER_ENERGY then
			RagePoints_Rage:SetText(UnitPowerMax("player") .." / ".. MAX_COMBO_POINTS);

		-- Rage/Focus (number)
		else
			RagePoints_Rage:SetText(UnitPowerMax("player") .. "");
		end





		RagePoints_LastPower = -1;
		RagePoints_LastCombo = -1;
		RagePoints_Update();
	end
end

function RagePoints_OnUpdate(elapsed)
	RagePoints_Elapsed = RagePoints_Elapsed + elapsed;

	if (RagePoints_Elapsed > RagePoints_UpdateRate) then
		RagePoints_Update();
		RagePoints_Elapsed = 0;
	end
end

function RagePoints_Update()
	if (UnitPower("player") ~= RagePoints_LastPower 
		or GetComboPoints("player", "target") ~= RagePoints_LastCombo)
	then
		RagePoints_LastPower = UnitPower("player");
		RagePoints_LastCombo = GetComboPoints("player", "target");

		-- Mana (number / manaMax)
		if UnitPowerType("player") == SPELL_POWER_MANA then
			RagePoints_Rage:SetText(UnitPower("player") .." / ".. UnitPowerMax("player"));

		-- Energy (energy / combo)
		elseif UnitPowerType("player") == SPELL_POWER_ENERGY then
			RagePoints_Rage:SetText(UnitPower("player") .." / ".. GetComboPoints("player", "target"));

		-- Rage/Focus (number)
		else
			RagePoints_Rage:SetText(UnitPower("player"));
		end

		local r, g, b = RagePoints_SetManaColor();

		RagePoints_Rage:SetTextColor(r, g, b);
	end
end

function RagePoints_SetManaColor()
	local mana = UnitPower("player") / UnitPowerMax("player");
	local r = 0;
	local g = 0;
	local b = 0;

	-- white
	if (mana >= 1) then
		r = 1;
		g = 1;
		b = 1;

    -- blue (for mana) or..
    elseif (mana >= 0.8 and UnitPowerType("player") == SPELL_POWER_MANA) then
		b = 1;

    -- .. red
    elseif (mana >= 0.8 and UnitPowerType("player") ~= SPELL_POWER_MANA) then
		r = 1; 

	-- green
	elseif (mana >= 0.6) then
		g = 1;

	-- red for low mana
	elseif (mana < 0.2 and UnitPowerType("player") == SPELL_POWER_MANA) then
		r = 1;

	-- dirty yellow
	elseif (mana > 0) then
		r = 0.75;
		g = 0.75;

	-- gray
	else
		r = 0.5;
		g = 0.5;
		b = 0.5;
	end

	return r, g, b;
end
