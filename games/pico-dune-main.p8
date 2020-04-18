pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
-- undune ii
-- by paul nicholas
-- (with support from my patrons)

-- =======================================
-- main cart (title menu, level select)
-- =======================================

--game_cart = "pico-dune.p8"
game_cart = "pico-dune_fmt.p8"

-- music
-- 00 = title
-- 06 = intro/advisor/level lose?
-- 10 = level win

-- constants
faction_cols = {
 { 12, 1}, -- Atreides
 { 11, 3}, -- Ordos
 { 8,  2}, -- Harkonnen
 { 14, 2}, -- Emperor?
}

-- cart modes
title_mode=1
levelselect_mode=2
levelend_mode=3

-- mission data (harkonnen)
mission_data={
-- # |	Credits |	Target Cred |	Enemy |	AI Level
 { 1,	999,	 1000,	nil, nil },	-- No enemy, just reach 1000 credits
 { 2,	1200,	2700,	1,   1 },	  -- 2700 credits of spice, OR eliminate Atreides presence
 { 3,	1500,	0,    2,   2	}, -- Eliminate enemy
 { 4,	1500,	0,    2,   3	}, -- Eliminate enemy
 { 5,	1500,	0,    1,   4 }, --	Eliminate enemy
 { 6,	1700,	0,    2,   5 }, --	Eliminate enemy
 { 7,	2000,	0,    1,   6 }, --	Eliminate enemy
 { 8,	2000,	0,    2,   7 }, --	(Should be 1 or 2)
 { 9,	2500,	0,    4,   8 }, --	Eliminate enemy
}

-- vars
mode = title_mode


-- title vars

-- level-end vars
endstate = 0


function _init()
 cartdata("pn_undune2")

 load_data()
end

function _draw()
 cls()
 print("-main cart-")

 if mode == title_mode then
  print("\n(title screen)")
  print("\n< press ❎ to start game >")
 
 elseif mode == levelselect_mode then
  print("\n(level select screen)")
  print("\n< press ❎ to choose level >")
 
 elseif mode == levelend_mode then
  print("\n(level end screen)")

  print("\nscore:"..p_score)
  print("time:"..p_time) -- TODO:Round to nearest minute
  print("rank:"..p_rank)
  
  print("\nspice harvested by")
  print(" > you:"..p_harvested)
  print(" > enemy:"..ai_harvested)
  
  print("\nunits destroyed by")
  print(" > you:"..p_units)
  print(" > enemy:"..ai_units)
  
  print("\nbuildings destroyed by")
  print(" > you:"..p_buildings)
  print(" > enemy:"..ai_buildings)

  print("\n< press ❎ to continue >")
 
 end 

end

function _update60()

 
 if mode == title_mode then
  -- switch to level select
  if btnp(5) then
   mode = levelselect_mode
   -- play "intro/select" music
   music(6)
  end 
 
 elseif mode == levelselect_mode then
  -- load and initialise game cart
  if btnp(5) then
   
   --load_level(p_level)
   load_level(2)

  end

 elseif mode == levelend_mode then
  -- switch to level select
  if btnp(5) then
   p_level += 1
   --printh("p_level = "..p_level)
   dset(0, p_level)
   dset(14, 0) -- clear endstate
   mode = levelselect_mode
   -- play "intro/select" music
   music(6)
  end

  
 end
 

 


end

function load_data()
 -- load saved data to determine current "state"

 p_level = max(1, dget(0))
 printh("p_level: = "..tostr(p_level))

 endstate = dget(14)  -- (0=none, 1=credit target, 2=enemy defeated, 3=player lost)
 printh("endstate = "..tostr(endstate))
 if endstate>0 then
  mode = levelend_mode
  -- get level end data
  p_score = dget(4)
  p_rank = calc_rank()
  p_time = flr(dget(13)) -- playing time 
  p_harvested = dget(10) -- spice harvested by player
  p_units = dget(11) -- units destroyed by player
  p_buildings = dget(12) -- buildings destroyed by player
  ai_harvested = dget(24) -- harvested by ai
  ai_units = dget(25) -- units destroyed by ai
  ai_buildings = dget(26) -- buildings destroyed by ai   
  if endstate < 3 then 
   -- play "win" music
   music(10)
  else
   -- play "lose" music
   music(6)
  end
 else
  -- play "title" music
  music(0)
 end

end

function calc_rank()
 return "sand warrior"
end

function load_level(num)
 printh("in load_level("..num..")...")

 local mdata = mission_data[num]

 -- set player to harkonnen
 p_fact = 3
 dset(0, num)
 dset(1, p_fact3) -- p_faction
 dset(2, faction_cols[p_fact][1]) -- p_col1
 dset(3, faction_cols[p_fact][2]) -- p_col2

 dset(6, mdata[2]) -- starting credits
 dset(7, mdata[3]) -- target credits
 dset(10, 0) -- harvested
 dset(11, 0) -- units destroyed
 dset(12, 0) -- buildings destroyed
 dset(13, 0) -- playing time

 ai_fact = mdata[4]
 dset(20, ai_fact) -- ai_faction
 dset(21, ai_fact and faction_cols[ai_fact][1] or nil) -- ai_col1
 dset(22, ai_fact and faction_cols[ai_fact][2] or nil) -- ai_col2
 
 dset(23, mdata[5]) -- ai level
 dset(24, 0) -- ai harvested
 dset(25, 0) -- ai units destroyed
 dset(26, 0) -- ai buildings destroyed


 -- set ai to atreides
 -- ai_fact = 1
 -- dset(20, ai_fact) -- ai_faction
 -- dset(21, faction_cols[ai_fact][1]) -- ai_col1
 -- dset(22, faction_cols[ai_fact][2]) -- ai_col2
 
 -- dset(23, 5) -- ai level
 -- dset(24, 0) -- ai harvested
 -- dset(25, 0) -- ai units destroyed
 -- dset(26, 0) -- ai buildings destroyed
 

 -- load level map data
 local mapfile = "pico-dune-map"..num..".p8"
 printh("loading data from: "..mapfile)
 reload(0x4300, 0x2000, 0x1000, mapfile)  -- read map data to user mem
 cstore(0x2000, 0x4300, 0x1000, game_cart)    -- write user mem to game map data

 load(game_cart)
end

__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__label__
00006660666066606600000006606660666066600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00006660606006006060000060006060606006000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
66606060666006006060000060006660660006006660000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00006060606006006060000060006060606006000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00006060606066606060000006606060606006000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
06006660666066606000666000000660066066606660666066000600000000000000000000000000000000000000000000000000000000000000000000000000
60000600060006006000600000006000600060606000600060600060000000000000000000000000000000000000000000000000000000000000000000000000
60000600060006006000660000006660600066006600660060600060000000000000000000000000000000000000000000000000000000000000000000000000
60000600060006006000600000000060600060606000600060600060000000000000000000000000000000000000000000000000000000000000000000000000
06000600666006006660666000006600066060606660666060600600000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00600000666066606660066006600000066666000000666006600000066066606660666066600000066066606660666000006000000000000000000000000000
06000000606060606000600060000000660606600000060060600000600006006060606006000000600060606660600000000600000000000000000000000000
60000000666066006600666066600000666066600000060060600000666006006660660006000000600066606060660000000060000000000000000000000000
06000000600060606000006000600000660606600000060060600000006006006060606006000000606060606060600000000600000000000000000000000000
00600000600060606660660066000000066666000000060066000000660006006060606006000000666060606060666000006000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000

__sfx__
010200030016500065007650c1000c000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010200020c4100c210000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010200030021500415003250c00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000010c15000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010100140c3100c3200c1700c1700c1600c1600c1500c0500c0400c0300c0300c0300c7300c7300c7300c7300c7200c7200c7100c3150c1000c1000c1000c1000c1000c1000c1000c1000c1000c1000c1000c100
010300183c6353c6050000000000356153f6050500005000356153f6050500005000356153f6050500005000356153f6050500005000356153f6053f6053f6053c6053c6053c6053c6053c6053c6053c6053c605
01ff02041823418221182311822118200182001820018200182001820118201182011820118201182011820118201182011820118201182011820118201182011820118201182011820118201182011820118201
011406073c5303c5213c5113c5113c5113c5103c51000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500
010a00001881018810188101881018821188201882018820188311883018830188301884118840188401884018851188501885018850188501885018850188501885018850188501885018850188501885018850
010a00000000000000000000000000000000000000000000009140091000910009100092100920009200092000931009300093000930009410094000940009400094000940009400094000940009400094000940
0150000018f2018f111bf201bf111af201af111af101af101af101af101af101af101af101af101af101af151b7201b7111b7111b715197201971119710197151886018851188411883118821188111681112811
0150000030f2430f1133f2433f110cb700cb510cb310cb1100b7000b6100b5100b4100b3100b2100b1100b150ff300ff2113f3013f2114f3014f2114f1114f1014f1500914009250093400945009340092500914
01500000188501884118831188411885118841188311884118a2418a3118a4118a3118a4118a3118a4118a3118a4018a3118a2118a3118a2118a3118a2118a1118a4016a4114a3112a3110a210ea210ca110aa11
01500000009400094000940009400092000920009110091518834188211881118821188111882118810188101f7301f7211f7111f7152073020721207112071500b7000b6100b5100b4100b3100b2100b1100b15
0115000003b5003b5003b5003b5003b5003b5003b5003b5003b4103b4003b4003b3103b3003b3003b2103b2006b5006b5006b5006b5006b5006b5006b5006b5006b4106b4006b4006b3106b3006b3006b2106b20
0115000022b3022b3022b2122b2022b2022b2022b2022b2022b2022b2022b1122b1022b1022b1022b1022b1521b3021b3021b3021b3021b3021b2121b2021b2021b2021b2021b1121b1021b1021b1021b1021b10
0115000022f2022f2022f2022f2022f2022f2022f2022f2022f1022f1022f1022f1022f1022f1122f1022f1521f2021f2021f2021f2021f2021f2021f2021f2021f1021f1021f1021f1021f1021f1121f1021f15
0115000024115231151f1151e1152111522115261152711523115211151d1151c11520115211152511526115201151f1151b1151a1151e1152111525115261151e1151d11519115171151e1151f1152311524115
0115000005b5005b5005b4105b4005b3105b3005b2105b1008b5008b5008b4108b4008b3108b3008b2108b1009b5009b5009b5009b4109b4009b4009b3109b3009b3009b2109b2009b2009b1109b1009b1009b10
01160000177371a727177171a717177171a717177171a717177171a717177171a717177171a715177001a700187371c727187171c717187171c717187171c717187171c717187171c717187171c715187001c700
0115000026b3026b3026b2126b2026b2026b2026b2026b2026b2026b2026b1126b1026b1026b1026b1026b1528b3028b3028b3028b3028b3028b2128b2028b2028b2028b2028b1128b1028b1028b1028b1028b15
0015000026f2026f2026f2026f2026f1126f1026f1026f1026f1026f1026f1026f1026f1026f1126f1026f1528f3028f3028f3028f3028f3028f3028f3028f3028f2028f2028f2028f2028f2028f1128f1028f15
012800000bb600bb510bb410bb310eb600eb510eb410eb3108b6008b5108b4108b3108b2108b1108b1108b100db600db510db410db3110b6010b5110b4110b310ab600ab510ab410ab310ab210ab110ab110ab10
012800000ef400ef110df400bf4006f4006f3106f2106f1108f4008f4008f3108f3008f2108f2008f1108f1510f4010f110ff400df4008f4008f3108f2108f110af400af400af310af300af210af200af110af15
012800001e7201e7121e7121e7151a7221a7121a7121a7151b7301b7211b7221b7111b7121b7121b7121b715207202071220712207151c7221c7121c7121c7151d7301d7301d7211d7221d7221d7111d7121d715
0128000006f3006f3006f2106f1502f3002f3002f2102f1503f3003f3003f2103f152cf202cf112cf112cf1008f3008f3008f2108f1504f3004f3004f2104f1505f2005f2005f2105f152ef202ef112ef102ef11
0128000003b6003b5103b4103b3103b2103b1103b1103b1503b6003b5103b4103b3103b2103b1503b6003b5502b6002b5102b4102b3102b2102b1102b1102b1002b1002b1002b1002b1002b1002b1002b1002b10
012800002eb042eb003ab143ab1239b1239b1135b1235b1235b1035b1036b1236b122fb122fb122eb122eb122db122db122db122db102db102db102db102db102db102db152db002db002db002db002db002db00
012800002e5202e5112e5102e5102e5102e5102e5102e5151e5201e5111e5101e5101e5101e5101e5101e51526520265112651026510265102651026510265102651026510265152650526500265002650026505
012800002ef202ef202ef202ef202ef202ef212ef112ef151ef201ef201ef201ef201ef201ef211ef111ef1526f2026f2026f2026f2026f1126f1026f1026f1026f151a8141a8211a8311a8411a8311a8211a811
0150000019a5019a5019a5019a5019a5019a5019a5019a5019a5019a5019a5019a5019a5019a5019a5019a5019a5019a5019a5019a5019a5019a5019a5019a5019a5019a5019a5019a5019a5019a5019a5019a50
015000201ce541ce411ce311ce211ce111ce111ce151ce051be541be411be311be211be111be111be151be051ce541ce411ce311ce211ce111ce1523e5423e4124e5024e4124e3124e2124e1124e1124e1524e05
015000001c9501c9411c9311c9211c9121c9121c9121c91501b7001b6101b5101b4101b3101b2101b1101b1501b7001b5101b5501b7501b7001b6101b5101b1101b7001b5101b5501b7501b7001b6101b5101b11
0150000004520045110451104511045120451204515045050f5200f5110f5100f5151352013511135101351510520105111051010515145201451114510145100f5200f5110f5100f51513520135111351013515
015000000d9140d9210d9310d9410d9510d9410d9310d9351b9501b9411b9311b9211f9501f9411f9311f9211c9501c9411c9311c921209502094120931209211b9501b9411b9311b9211f9501f9411f9311f921
015000000eb400eb310eb210eb2509b4009b450eb400eb450db400db310db3501b6501b6001b5101b4101b450eb400eb310eb210eb2509b4009b450eb400eb450db400db310db3501b6501b6001b5101b4101b45
0150000015c1015c1015c1015c1015c1015c1015c1015c1014c1014c1014c1014c1014c1014c1014c1014c2115c2015c2017c2017c2018c2018c201dc201dc1120c1020c1020c1020c1020c1020c1020c1020c10
0150000011c2011c2011c2011c2011c2011c2011c2011c2010c2010c2010c2010c2010c2010c2010c2010c2011c2011c1114c1014c1015c1015c101ac101ac101cc101cc101cc101cc101cc101cc101cc101cc10
015000000050000500005000050000500005000050000500085500854108521085250d5500d5410d5210d5250050000500005000050000500005000050000500085500854108521085250d5500d5410d5210d525
015000000eb400eb310eb3509b650eb500eb310eb110eb1510b4010b3110b3504b6504b5004b4104b2104b250eb400eb310eb3509b650eb500eb310eb110eb1510b4010b3110b3504b6504b5004b4104b2104b20
0150000009014090100901209012090120901209012090150b016170160b0120b0120b0120b0120b0120b01509017150170901209012090120901209012090150b016170160b0120b0120b0120b0120b0120b010
015000001d9401d9311d9211d9111d9101d9101d9101d9111f9301f9301f9301f9301f9211f9111f9151f9051d9301d9301d9301d9301d9301d9211d9111d9111354013531135111351012540125311251112510
015000001d5301d5211d5111d5111d5111d5151d5001d5051f5401f5311f5111f515235402353123511235151d5401d5311d5211d5111d5111d5151d5001d5051fe541fe411fe311fe211ee501ee411ee311ee21
0150000001b5001b4101b3101b2101b1101b1001b1001b1501b7001b6101b5101b4101b3101b2101b1101b1501b7001b5101b5501b7501b7001b6101b5101b1101b7001b5101b5501b7501b7001b6101b5101b11
010c00001705000000000000000017050000000000000000170500000000000000001705000000000000000017050000000000000000170500000000000000001705000000000000000017050000000000000000
0118000018d3018d3018d3518d3018d3018d3518d3018d3018d3518d3519d3019d3518d3018d3519d301ad3018d3018d3018d3518d3018d3018d3518d3018d3018d3518d3519d3019d3518d3018d3519d301ad30
010c00200bb750bb650bb550bb450bb350bb250bb750bb650bb550bb450bb350bb250bb750bb650bb550bb450bb350bb250bb750bb650bb550bb450bb350bb250cb750cb550cb750cb6509b7509b5509b7509b65
0118000039a4631a3639a2736a1739a1239a1239a1239a1239a1239a1239a1239a1239a4631a3639a1736a173da4639a363da2736a173da123da123da123da123da123da123da123da123da4638a363da2738a17
011800001e4201e4101e4111e2101e2101e2101e4101e4121e4121b2121b4121b2121f4201f4111f2121f2121e4201e4111e4101e2101e2101e2101e4101e4121e4121b2121b4121b2121f4201f4111f2121f212
011800002322023211232112341023411234102341023411232122321223212232122322023211232122321223220232112321023410234102341023412234122321223212232122321223220234112321223212
010c002006b7506b5506b3506b3506b3506b3506b7506b5506b3506b3506b3506b3512b7506b5506b4506b3506b3506b2506b7506b5506b3506b3506b3506b2506b7506b5506b7506b6512b7506b5506b3506b35
010c00201214512135121251201512015120151214512135121251201512015120151214512135120251201512115121151214512135121251201512015120151314513135130251301515145151351502515015
__music__
01 08094a4b
00 0c0d0a0b
00 0e0f1011
00 12141315
00 16171819
02 1a1b1c1d
01 2021221f
00 23242526
00 2728292a
02 2b21221f
01 2e30312d
02 322f332d

