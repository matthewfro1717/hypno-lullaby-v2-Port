-- Original script by: Cyn (https://twitter.com/cyn__8)
-- Slightly edited by Axor and Laztrix (https://twitter.com/Axor_A)  (https://twitter.com/non_Laztrix)
--Y pos yo lo adapte para V2 en vez de V1 (Nickobelit)

--[[ setting stuffs ]]

local sprite_dir = "UI/base/Unown_Alphabet"

local stunBF = true
local isTyping = false
local bg_color = "ff0000"
local bg_alpha = 0.5

local letter_y = 200
local letter_padding = 50
local screen_padding = 50

local input_color = "000000"
local input_y = 575
local input_height = 8

local countdown_size = 32

local texts = {
	"ABANDONED",
	"AGONY",
	"BOO!",
	"CAN YOU SEE?",
	"CELEBI DIED",
	"DONT BELONG",
	"DYING",
	"FERALIGATR",
	"GET OUT",
	"GOLD",
	"GOODBYE",
	"GRAVEYARD",
	"GRUESOME",
	"HE DIED",
	"HELP",
	"HOPELESS",
	"IM DEAD",
	"I SEE YOU",
	"IT FAILED",
	"LEAVE HURRY",
	"NIGHTMARE",
	"NOT WANTED",
	"NOT WELCOME",
	"PERISH SONG",
	"RELIVE",
	"RUN",
	"SILVER",
	"TIRESOME",
	"USELESS",
	"UNOWN",
	"WHERE?",
	"XXXXX",
}

local rare_chance = 50
local rare_texts = {
	"NICE COCK",
	"SUS AF",
	"BOOB LOL",
	"LMAO GOTTEM",
	"RATIO",
	"HIPPOPOTAMUS",
	"POGGERS!",
	"BUSSY",
	"ASS LMAO",
	"RUN STREAMER",
}

local super_rare_chance = 1000
local super_rare_texts = {
	"WANNA WORK ON MY FNF MOD?",
	"IM IN A FUCKING WHEEL CHAIR",
	"HI SHUBS",
	"GET CANCELLED",
	"SASTER",
	"BFEZZ",
	"XENDRACK",
	"NICKOBELIT",
	"PEREZ",
	"PHYSIK"
}

local hell_mode_texts = {
	"SKILL ISSUE",
	"WELCOME TO HELL",
	"WORK THAT PENDULUM",
	"HES BRI ISH GET HIM",
	"MAYBE TRY PUSSY MODE",
	"KEK",
	-- "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
}

--[[ code stuffs ]]

local selected_text = nil
local current_character = 1
local countdown_end = nil

function onCreate()
	precacheImage(sprite_dir)
	alreadyHasNR = getPropertyFromClass("ClientPrefs", "noReset")
	if difficulty == 3 then -- custom charts go after number 2 (hard)
		for _,v in ipairs(hell_mode_texts) do
			table.insert(texts, v)
		end
	end
end

local function remove_stuffs()
	isTyping = false
	removeLuaSprite("unown_bg", false)
	removeLuaText("unown_countdown", false)
	
	for i = 1, #selected_text do
		local character = selected_text:sub(i, i)
		if character ~= " " then
			removeLuaSprite("unown_letter" .. i, false)
			removeLuaSprite("unown_input" .. i, false)
		end
	end
	
	countdown_end = nil
	selected_text = nil
end

function onEvent(name, value_1, value_2)
	if name == "Unown" then
		isTyping = true
		if selected_text then
			remove_stuffs()
		end
		setPropertyFromClass("ClientPrefs", "noReset", true)
		local bg_sprite = "unown_bg"
		makeLuaSprite(bg_sprite, "", 0, 0)
		makeGraphic(bg_sprite, 1280, 720, bg_color)
		addLuaSprite(bg_sprite, true)
		setProperty(bg_sprite .. ".alpha", bg_alpha)
		setObjectCamera(bg_sprite, "other")
		
		-- idk how to get the difficulty name for the hell mode texts so nothing here
		-- ^^^^^^^
		-- there's still nothing here but i added it for you i guess - Axor
		
		if value_2 == "" then
			if 1 == getRandomInt(1, rare_chance) then
				if 1 == getRandomInt(1, super_rare_chance / rare_chance) then
					selected_text = super_rare_texts[getRandomInt(1, #super_rare_texts)]
				else
					selected_text = rare_texts[getRandomInt(1, #rare_texts)]
				end
			else
				selected_text = texts[getRandomInt(1, #texts)]
			end
		else
			selected_text = value_2:upper()
		end
		
		current_character = 1
		
		local letter_width = 0
		local letter_placement = -letter_padding
		
		for i = 1, #selected_text do
			letter_placement = letter_placement + letter_width + letter_padding
			
			local character = selected_text:sub(i, i)
			if character == " " then
				letter_width = letter_padding * 2
			else
				local letter_sprite = "unown_letter" .. i
				makeAnimatedLuaSprite(letter_sprite, sprite_dir, letter_placement, letter_y)
				addAnimationByPrefix(letter_sprite, character, character, 24, true)
				objectPlayAnimation(letter_sprite, character, true)
				addLuaSprite(letter_sprite, true)
				setProperty(letter_sprite .. ".y", letter_y - (getProperty(letter_sprite .. ".frameHeight") / 2))
				setObjectCamera(letter_sprite, "other")
				
				letter_width = getProperty(letter_sprite .. ".frameWidth")
			end
		end
		
		letter_placement = letter_placement + letter_width
		
		local scale = 1
		local threshold = 1280 - (screen_padding * 2)
		if letter_placement > threshold then
			repeat
				scale = scale - 0.05
				if scale > 0 then
					letter_width = 0
					letter_placement = -(letter_padding * scale)
					
					for i = 1, #selected_text do
						letter_placement = letter_placement + letter_width + (letter_padding * scale)
						
						if selected_text:sub(i, i) == " " then
							letter_width = (letter_padding * 2) * scale
						else
							local letter_sprite = "unown_letter" .. i
							
							scaleObject(letter_sprite, scale, scale)
							setProperty(letter_sprite .. ".x", letter_placement)
							
							letter_width = getProperty(letter_sprite .. ".frameWidth") * scale
						end
					end
					
					letter_placement = letter_placement + letter_width
				else
					break
				end
			until letter_placement < threshold
		end
		
		for i = 1, #selected_text do
			local character = selected_text:sub(i, i)
			if character ~= " " then
				local letter_sprite = "unown_letter" .. i
				setProperty(letter_sprite .. ".x", getProperty(letter_sprite .. ".x") + ((1280 - letter_placement) / 2))
				
				local input_sprite = "unown_input" .. i
				makeLuaSprite(input_sprite, "", getProperty(letter_sprite .. ".x"), input_y)
				makeGraphic(input_sprite, getProperty(letter_sprite .. ".frameWidth") * scale, input_height, input_color)
				addLuaSprite(input_sprite, true)
				setObjectCamera(input_sprite, "other")
			end
		end
		
		local song_pos = getPropertyFromClass("Conductor", "songPosition")
		countdown_end = value_1 + 1
		makeLuaText("unown_countdown", countdown_end, countdown_size*1.5, 640, 420)
		setTextFont("unown_countdown", "metro.otf")
		setTextSize("unown_countdown", countdown_size)
		setTextBorder("unown_countdown", -0, 'FFFFFF')
		addLuaText("unown_countdown")
		setObjectCamera("unown_countdown", "other")
		if stunBF then
			runTimer('stunDelay', 1)
		end
	end
end
function onBeatHit()
	countdown_end = countdown_end - 1
	
	if curBeat > 415 then
		texts = {
			"FORGOTTEN",
			"TOMBSTONE",
			"TYPHLOSION",
			"MELANCHOLY",
			"FERALIGATR",
			"FRUSTRATION",
			"HIPPOPOTAMUS",
			"CYNDAQUIL",
			"DECAPITATION",
			"POSSESSION",
			"MONOTONY",
			"EERIE NOISE",
			"NOTHINGNESS"
		}
		rare_texts = {
			"NOT YOUR FATE",
			"THE END OF ALL THINGS",
			"DEATH TO GLORY",
			"LOST MEMORIES",
			"ASPHYXIATION"
		}
	end
end

function onUpdate()
if isTyping then
	if selected_text then
		local song_pos = getPropertyFromClass("Conductor", "songPosition")
		if countdown_end > -1 then
			setTextString("unown_countdown", countdown_end)
			screenCenter("unown_countdown", "x")
			
			if getPropertyFromClass("flixel.FlxG", "keys.justPressed." .. selected_text:sub(current_character, current_character)) and difficultyName == 'Hard' or keyJustPressed('down') and difficultyName == 'Pussy' then --Esto es por la votación de YouTube
				setProperty("unown_input" .. current_character .. ".alpha", 0)
				current_character = current_character + 1
			end
			
			if current_character > #selected_text then
				playSound('CORRECT')
				setProperty('boyfriend.stunned', false)
				remove_stuffs()
				cancelTimer('stunDelay')
				if alreadyHasNR == false then
					runTimer('complete', 0.1)
				end
			end
		else
			remove_stuffs()
			local heaith = getProperty('health')
			setProperty('health', 0)
		end
	end
end
end

function onTimerCompleted(tag)
	if tag == 'stunDelay' then
		setProperty('boyfriend.stunned', true)
	elseif tag == 'complete' then
		setPropertyFromClass("ClientPrefs", "noReset", false)
	end
end

function onGameOver()
	remove_stuffs()
	setProperty('health', heaith)
	return Function_Continue;
end