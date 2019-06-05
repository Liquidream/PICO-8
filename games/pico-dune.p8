pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
-- pico-dune
-- by paul nicholas
-- (with support from my patrons)

-- global flags
debug_mode=true
debug_collision=false

-- fields
camx,camy=0,0
cursx,cursy=0,0
keyx,keyy=0,0
selected_obj=nil
credits=2335
col1=8 -- faction cols
col2=2
_t=0

--cor=nil
count=0
units={}
object_tiles={}
buildings={}
ui_controls={}

_g={}
_g.factory_click=function(self)
  menu_pos=1
  --printh("todo: load construction yard menu...")
  selected_subobj=self.parent.build_objs[1]
  -- create buttons
  m_button(6,89,"⬆️",function(self)   
   --sel_build_item_idx-=1
   sel_build_item_idx=mid(1,sel_build_item_idx-1,#selected_obj.build_objs)
   selected_subobj = selected_obj.build_objs[sel_build_item_idx]
   if (sel_build_item_idx<menu_pos) menu_pos-=1
   --menu_pos=max(menu_pos-1,1)
  end, 10)
  m_button(17,89,"⬇️",function(self)
   sel_build_item_idx=mid(1,sel_build_item_idx+1,#selected_obj.build_objs)
   selected_subobj = selected_obj.build_objs[sel_build_item_idx]
   if (sel_build_item_idx>menu_pos+2) menu_pos=min(menu_pos+1,#show_menu.parent.build_objs-2)
   --menu_pos=min(menu_pos+1,#show_menu.parent.build_objs-2)
  end, 10)
  m_button(32,88,"build",function(self)
   --printh(">>> build clicked!")
   show_menu=nil
   selected_obj.build_obj=last_selected_subobj
   last_selected_subobj:func_onclick()
  end)
  m_button(96,88,"close",function(self)
   --printh(">>> close clicked!")
   show_menu=nil
  end)
  -- show build menu
  show_menu=self
end
-- _g.draw_slab=function(self)
--   for xx=0,self.spr_w-1 do
--    for yy=0,self.spr_h-1 do
--     spr(19, self.x+(xx*8), self.y+(yy*8))
--    end
--   end
-- end
_g.init_windtrap=function(self)
  self.col_cycle = {
    {14,12},
    {14,12},
    {14,12},
    {14,12},
    {14,13},
    {14,1},
    {14,1},
    {14,1},
    {14,1},
    {14,13},
  }
  self.col_cycle_pos=1
end



-- object data
obj_data=[[id|name|obj_spr|ico_spr|map_spr|type|w|h|trans_col|parent_id|req_id|req_level|req_faction|cost|power|arms|hitpoint|speed|range|norotate|altframe|framecount|description|func_init|func_draw|func_update|func_onclick
]]..
-- buildings
[[1|cONSTRUCTION yARD|64|128||2|2|2|nil|nil|nil|1||100|nil||400||||||aLL STRUCTURES ARE BUILT BY THE CONSTRUCTION YARD.||||factory_click
2|wINDTRAP|66|130||2|2|2|nil|1|1|1||300|100||200|||||10|tHE WINDTRAP SUPPLIES POWER TO YOUR BASE. wITHOUT POWER YOUR STRUCTURES WILL DECAY.|init_windtrap|||
3|sMALL cONCRETE sLAB|19|160||2|1|1|nil|1|1|1||5|nil||0||||||uSE CONCRETE TO MAKE A STURDY FOUNDATION FOR YOUR STRUCTURES.||||
4|lARGE cONCRETE sLAB|19|162||2|2|2|nil|1|1|4||20|nil||0||||||uSE CONCRETE TO MAKE A STURDY FOUNDATION FOR YOUR STRUCTURES.||||
5|dEFENSIVE wALL|79|164||2|1|1|nil|1|7|4||50|nil||50||||||tHE wALL IS USED FOR PASSIVE DEFENSE.||||
6|sPICE rEFINERY|68|132||2|3|2|nil|1|2|1||400|30||450||||||tHE rEFINERY CONVERTS SPICE INTO CREDITS.||||
7|rADAR oUTPOST|73|136||2|2|2|nil|1|2|2||400|30||500||||||tHE oUTPOST PROVIDES RADAR AND AIDS CONTROL OF DISTANT VEHICLES.||||
8|sPICE sTORAGE sILO|71|134||2|2|2|nil|1|6|2||150|5||150||||||tHE sPICE SILO IS USED TO STORE REFINED SPICE.||||
9|bARRACKS|75|||2|2|2|nil|1|7|2||300|10||300||||||tHE bARRACKS IS USED TO TRAIN YOUR lIGHT INFANTRY.||||factory_click
10|wor tROOPER fACILITY|77|138||2|2|2|nil|1|7|2||400|10||400||||||wor IS USED TO TRAIN YOUR hEAVY INFANTRY.||||factory_click
11|lIGHT vEHICLE fACTORY|96|||2|2|2|nil|1|6|2||400|20||350||||||tHE lIGHT fACTORY PRODUCES LIGHT ATTACK VEHICLES.||||factory_click
12|hEAVY vEHICLE fACTORY|98|||2|3|2|nil|1|6|3||600|20||200||||||tHE hEAVY fACTORY PRODUCES HEAVY ATTACK VEHICLES.||||factory_click
13|hI-tECH fACTORY|101|||2|3|2|nil|1|7+12|5||500|35||400||||||tHE hI-tECH fACTORY PRODUCES FLYING VEHICLES.||||factory_click
14|cANNON tURRET|60|||2|1|1|nil|1|7|5||125|10||200||||||tHE cANNON tURRET IS USED FOR SHORT RANGE ACTIVE DEFENSE.||||
15|rOCKET tURRET|61|||2|1|1|nil|1|7|6||250|20||200||||||tHE rOCKET/cANNON TURRET IS USED FOR BOTH SHORT AND MEDIUM RANGE ACTIVE DEFENSE.||||
16|rEPAIR fACILITY||||2|3|2|nil|1|7+12|5||700|20||200||||||tHE rEPAIR fACILITY IS USED TO REPAIR YOUR VEHICLES.||||
17|sTARPORT||||2|3|3|nil|1|6|6||500|50||500||||||tHE sTARPORT IS USED TO ORDER AND RECEIVED SHIPMENTS FROM c.h.o.a.m.||||factory_click
18|hOUSE OF ix||||2|2|2|nil|1|7+12|5||500|40||400||||||tHE ix rESEARCH fACILITY ADVANCES YOUR hOUSE'S TECHNOLOGY.||||
19|pALACE||||2|3|3|nil|1|17|8||999|80||1000||||||tHIS IS YOUR pALACE.||||factory_click
]]..
-- units
[[20|lIGHT iNFANTRY (X3)|62|||1|1|1|11|9|9|2|AO|60||4|50|0.05|2|1|63|10|iNFANTRY ARE LIGHTLY ARMOURED FOOTSOLDIERS, WITH LIMITED FIRING RANGE AND SPEED.||||
21|hEAVY tROOPERS (X3)|62|194||1|1|1|11|10|9|3|HO|100||8|110|0.1|3|1|63|10|tROOPERS ARE HEAVILY ARMOURED FOOTSOLDIERS, WITH IMPROVED FIRING RANGE AND SPEED.|||
22|tRIKE||||1|1|1|11|11+17||2||150||8|100|0.6|3||||tHE tRIKE IS A LIGHTLY-ARMOURED, 3-WHEELED VEHICLE, WITH LIMITED FIRING RANGE, BUT RAPID SPEED.||||
23|qUAD||||1|1|1|11|11+17||3||200||10|130|0.5|3||||tHE qUAD IS A LIGHTLY-ARMOURED, 4-WHEELED VEHICLE. sLOWER THAN THE tRIKE, BUT STRONGER ARMOUR AND FIREPOWER.||||
24|cOMBAT tANK|51|196||1|1|1|11|12+17|7|4||300||38|200|0.25|4||||tHE cOMBAT tANK IS A MEDIUM ARMOURED TANK, FIRES HIGH-EXPLOSIVE ROUNDS.||||
25|sIEGE tANK|50|198||1|1|1|11|12+17|7|6||600||45|300|0.2|5||||tHE mISSILE tANK IS A MEDIUM ARMOURED TANK, WHICH FIRES MISSILES. lONG-RANGE, BUT INACCURATE.||||
26|rOCKET lAUNCHER|53|202||1|1|1|11|12+17|7|5||450||112|100|0.3|9||||tHE sIEGE tANK IS A HEAVY ARMOURED TANK, WHICH HAS DUAL CANNONS, BUT IS SLOW.||||
27|hARVESTER|49|192||1|1|1|11|12+17||2||300||0|150|0.3|nil||||tHE hARVESTER SEPARATES SPICE FROM THE SAND & RETURNS RAW SPICE TO THE rEFINERY FOR PROCESSING.||||
28|cARRYALL||||1|1|1|11|13|13|5||800||0|100|2|nil||||tHE cARRYALL IS A LIGHTLY ARMOURED AIRCRAFT WITH NO WEAPONS. mAINLY USED TO LIFT+TRANSPORT hARVESTERS.||||
29|oRNITHOPTER||||1|1|1|11|13+17|13|7|AO|600||75|5|1.5|5||||tHE oRNITHOPTER IS A LIGHTLY ARMOURED AIRCRAFT THAT FIRES ROCKETS. hIGHLY MANOUVERABLE + FASTED AIRCRAFT ON dUNE.||||
30|mcv (mOBILE CONSTRUCTION VEHICLE)||||1|2|1|11|12+17|7|4||900||0|150|0|nil||||tHE mcv SCOUT VEHICLE IS USED TO FIND AND DEPLOY NEW BASE LOCATIONS.||||
31|sONIC tANK||||1|1|1|11|12|7|7|A|600||90|110|0.3|8||||dEVELOPED BY THE aTREIDES, THIS ENHANCED TANK FIRES POWERFUL BLAST WAVES OF SONIC ENERGY.||||
32|fREMEN (X3)||||1|1|1|11|19||8|A|0||8|220|0.1|3||||tHE fREMEN ARE NATIVE TO dUNE. eLITE FIGHTERS, IN ALLIANCE WITH THE aTREIDES.||||
33|dEVASTATOR|52|200||1|1|1|11|12|13|8|H|800||60|400|0.1|7||||tHE dEVESTATOR IS A hARKENNEN-DEVELOPED NUCKEAR-POWERED TANK, WHICH FIRES DUAL PLASMA CHARGES. mOST POWERFUL TANK ON dUNE, BUT POTENTIALLY UNSTABLE IN COMBAT.||||
34|dEATH hAND||||1|1|1|11|19||8|H|0||150|70|2.5|nil||||tHE dEATH hAND IS A SPECIAL hARKONNEN pALACE WEAPON. aN INACCURATE, BUT VERY DESTRUCTIVE BALLISTIC MISSILE.||||
35|rAIDER||||1|1|1|11|11||2|O|150||8|80|0.75|3||||tHE oRDOS rAIDER IS SIMILAR TO THE STANDARD tRIKE, BUT WITH LESS ARMOUR IN FAVOUR OF SPEED.||||
36|dEVIATOR||||1|1|1|11|12|13|7|O|750||0|120|0.3|7||||tHE oRDOS dEVIATOR IS A STANDARD mISSILE tANK, WHICH FIRES UNIQUE NERVE GAS MISSILES THAT MAY TEMPORARILY CHANGE ENEMY LOYALTY.||||
37|sABOTEUR||||1|1|1|11|19||8|O|0||150|40|0.4|2||||tHE sABOTEUR IS A SPECIAL MILITARY UNIT, TRAINED AT AN oRDOS pALACE. cAN DESTRY ALMOST ANY STRUCTURE OR VEHICLE.||||
]]..
-- other
[[38|sARDAUKAR||||1|1|1|11|nil|nil|4||0||5|110|0.1|1||||tHE sARDULAR ARE THE eMPEROR'S ELITE TROOPS. WITH SUPERIOR FIREPOWER AND ARMOUR.||||
39|sANDWORM||||1|1|1|11|nil|nil|3||0||300|1000|0.35|0||||tHE sAND wORMS ARE INDIGEONOUS TO dUNE. aTTRACTED BY VIBRATIONS, ALMOST IMPOSSIBLE TO DESTROY, WILL CONSUME ANYTHING THAT MOVES.||||]]
















--[[
  ## messages ##
There isn't enough open concrete to place this structure. You may proceed, but without enough concrete the building will need repairs.

You have successfully completed your mission.

]]

--p8 functions
--------------------------------

function _init()
 printh("-- init -------------") 
 -- enable mouse
 poke(0x5f2d, 1)

 cartdata("pn_picodune") 

 explode_data()

 -- starting mode 
 -- (1=normal, 2=build menu, 3=???)
 curr_mode = 1

 -- init the game/title
 level_init()
 ticks=0

 -- create cursor ui "object" (for collisions)
 cursor = {
  x=0,
  y=0,
  w=8,
  h=8,
  spr=0,
  get_hitbox=function(self)
   return {
    x=self.x+(not ui_collision_mode and camx or 0)+2,
    y=self.y+(not ui_collision_mode and camy or 0)+1,
    w=1,
    h=1
   }
  end,
  draw=function(self)   
   spr((selected_obj and (selected_obj.type==1)) and 1 or self.obj_spr, 
    self.x, self.y, self.w/8, self.h/8)
  end
 }

 discover_objs()

 camx=15

 music(9)
end

-- analyse current map & spawn objs  
function discover_objs()
  -- make 2 passes
  -- (first find the player start pos/const yard)
  -- (second finds everything else)
  for i=1,2 do
   for my=0,31 do
     for mx=0,127 do
       local objref=nil
       local spr_val=mget(mx,my)
       local flags=fget(spr_val)
       local owner=0 -- default to auto-owner
       
       -- handle player start pos (const yard) as a special case
       if i==1 and spr_val==1 then
        -- found player start
        owner=1
        objref=obj_data[1]
       else
        -- find object for id
        for o in all(obj_data) do       
         if (o.obj_spr!=nil and o.obj_spr==spr_val) objref=o break       
        end
       end
       
       if objref!=nil then
         m_map_obj_tree(objref, mx*8,my*8, owner)

         if objref.type==2 then
           mset(mx,my,20)        
         elseif objref.type==1 then
           mset(mx,my,17)
         end
       end
     end
   end
 end
end

function m_map_obj_tree(objref, x,y, owner)
  local newobj=m_obj_from_ref(objref, x,y, objref.type, nil, _g[objref.func_init], _g[objref.func_draw], _g[objref.func_update], nil)
  -- set type==3 (icon!)
  newobj.ico_obj=m_obj_from_ref(objref, 109,0, 3, newobj, nil, nil, _g[objref.func_onclick])
  newobj.life=100 -- unless built without concrete
  
  -- factory?
  newobj.build_objs={}
  -- go through all ref's and see if any valid for this building
  for o in all(obj_data) do
    --printh("o.parent="..(o.parent_id!=nil and o.parent_id or "nil"))
    if (o.parent_id!=nil and o.parent_id==newobj.id) then
    --printh("found child: "..o.name)
    -- set type==4 (build icon!)
    local build_obj = m_obj_from_ref(o, 109,0, 4, newobj, nil, nil, function(self)
      -- build icon clicked
      printh("build item clicked...")
      printh("name=.."..self.name)
      if show_menu then
        -- select building
        selected_obj=self
      else
        --auto build
        self.build_step=5/self.cost
        self.cor=cocreate(function(self)        
          -- build object
          self.buildstep=0
          self.spent=0
          while self.spent<self.cost do
            self.buildstep+=1
            if (self.buildstep>3)self.buildstep=0 credits-=1 sfx(63) self.spent+=1
            self.life=(self.spent/self.cost)*100
            yield()
          end
          -- ready to place!
          sfx(56)
        end)
      end
    end)

    -- player-controlled or ai?
    finish this!!!!! #######
    newobj.ai=(owner!=1 or 
    
    add(newobj.build_objs,build_obj)
    newobj.build_obj=newobj.build_objs[1]
    end
  end
  
  --printh("objref.type=="..objref.type)
  -- building props?        
  if objref.type==2 then
    add(buildings,newobj)
  end
  -- unit props
  if objref.type==1 then
    if (newobj.norotate!=1) newobj.r=flr(rnd(8))*.125
    add(units,newobj)
  end
  reveal_fow(newobj)
end

function m_obj_from_ref(ref_obj, x,y, in_type, parent, func_init, func_draw, func_onclick)
 local _w=(ref_obj.w or 1)*8 -- pixel dimensions
 local _h=(ref_obj.h or 1)*8 --
 local obj={
  ref=ref_obj,
  x=x,
  y=y,
  z=1, -- defaults
  type=in_type, -- 1=unit, 2=structure, 3=obj_status_icon, 4=build_icon, 9=worm
  parent=parent,
  func_onclick=func_onclick,
  w=_w,
  h=_h,
  orig_spr=ref_obj.obj_spr,
  spr_w=ref_obj.w or 1, -- defaults
  spr_h=ref_obj.h or 1, --
  life=0,
  frame=0,
  get_hitbox=function(self)
    return {
     x=self.x,
     y=self.y,
     w=(self.type>2 and 16 or self.w)-1,
     h=(self.type>2 and 16 or self.h)-1
    }
   end,
   draw=func_draw or function(self)--, x,y) 
     pal()
     palt(0,false)
     if (self.trans_col) palt(self.trans_col,true)
     -- colour anim?
     if self.col_cycle then
       pal(self.col_cycle[self.col_cycle_pos][1],
           self.col_cycle[self.col_cycle_pos][2])
     end
     -- rotating obj?
     if self.r then
      rspr(self.obj_spr%16*8,flr(self.obj_spr/16)*8, self.x, self.y+1, .25-self.r, 1, self.trans_col, 5)
      rspr(self.obj_spr%16*8,flr(self.obj_spr/16)*8, self.x, self.y, .25-self.r, 1, self.trans_col)      
     -- norm sprite
     else      
       -- icon mode?
       if self.type>2 then
         rectfill(self.x-1,self.y-1,self.x+16,self.y+19,0)
         -- draw health/progress
         local this=self.type==4 and self or self.parent
         local col = this.build_step and 12 or (this.life<33 and 8 or this.life<66 and 10 or 11)
         if (this.life>0) rectfill(self.x,self.y+17,self.x+(15*this.life/100),self.y+18,col)
       end
       -- non-rotational sprite
       if self.type>2 then 
        spr(self.ico_spr, self.x, self.y, 2, 2)
       else
        spr(self.obj_spr, self.x, self.y, self.w/8, self.h/8)
       end
     end
 
     if (debug_collision) draw_hitbox(self)
   end,
   update=function(self)
     -- default functionality?    
     if self.framecount!=nil then
      self.frame+=1
      if (self.frame > self.framecount) then
       self.frame=0
       -- alternate moving frame?
       if self.altframe 
        and self.state==2 then
         self.obj_spr=self.orig_spr+(self.altframe-self.obj_spr)
       end
 
       if self.col_cycle then
         self.col_cycle_pos+=1
         if (self.col_cycle_pos>#self.col_cycle) self.col_cycle_pos=1
       end
      end
     end
   end,
   setpos=function(self,x,y)
    self.x=x
    self.y=y
   end
  }
 --end

 -- copy ref properties to object (where empty!)
 for k,v in pairs(ref_obj) do
  if obj[k]==nil and v!="" then
   --printh(">>>>> copying: "..k.." = "..tostr(v).." (type:"..type(v)..")")
   obj[k] = v
  --else
   --printh(">>>>>>>> SKIPPING - already has value")
  end
 end

 -- finally, init obj
 if (func_init) func_init(obj)

 return obj
end


function reveal_fow(object)  
 local size = object.type==2 and 3 or 2
 -- clear group of tiles
 for xx=-size,size do
  for yy=-size,size do
    -- clear tile
    local posx=flr(object.x/8)+xx
    local posy=flr(object.y/8)+yy    
    fow[posx][posy]=16 
    test_tile(posx,posy)
    -- update neighborhood
    for dy=-1,1 do
        for dx=-1,1 do
          test_tile(posx+dx,posy+dy)
        end
    end
  end
 end
end


function _update60()  --game_update

 update_level()
 
 -- update positions of pathfinding "blocker" objects
 if (t()%1==0) update_obj_tiles()
 _t+=1
end


function _draw()
 -- draw the map, objects - everything except ui
 draw_level()
 -- draw score, mouse, etc.
 draw_ui()
  
  --printh("cpu: "..flr(stat(1)*100).."% mem: "..(flr(stat(0)/2048*100)).."% fps: "..stat(7))--,2,109,8,0)
  if (debug_mode) printo("cpu: "..flr(stat(1)*100).."%\nmem: "..(flr(stat(0)/2048*100)).."%\nfps: "..stat(7),2,109,8,0)

 -- print(a[1][2],20,20,7)
end


-- init related
--------------------------------
function level_init()
 -- todo: parse map data into objects

 -- init fog of war?
 fow={}
 for i=-2,66 do
  fow[i]={}
  for l=-2,66 do
   fow[i][l]=0
  end
 end

end

-- fog of war
function draw_fow()
 local mapx=flr(camx/8)
 local mapy=flr(camy/8)
 for xx=mapx-1,mapx+16 do
  for yy=mapy-1,mapy+16 do
    if fow[xx][yy]!=0 and fow[xx][yy]!=16 then

     palt(11,true)

     spr(fow[xx][yy]+31,xx*8,yy*8)


    elseif fow[xx][yy]<16 then
     rectfill(xx*8, yy*8, xx*8+7, yy*8+7, 0)
    end
  end
 end
end



-- https://www.lexaloffle.com/bbs/?tid=30902
function test_tile(x,y) 
 
 -- bail (outside testtile bounds)
 if (x<0 or x>#fow or y<0 or y>#fow) return
	
  -- figure out bitmask
  local mask = 0

	if fow[x][y]!=0 then
  
    -- north has tile?
		if (fow[x][y-1]>0) mask+=1
	
    -- east has tile?
		if (fow[x-1][y]>0) mask+=2
	
    -- south has tile?
		if (fow[x+1][y]>0) mask+=4
	
    -- west has tile?
		if (fow[x][y+1]>0) mask+=8
		
    fow[x][y]=1 + mask
	end

end

-- update related
--------------------------------

function update_obj_tiles() 
 object_tiles={}
 -- (The pico-8 map is a 128x32 (or 128x64 using shared space))
 for _,unit in pairs(units) do  
  object_tiles[flr(unit.x/8)..","..flr(unit.y/8)]=1
 end
end

function update_level()
 
  
  -- mouse control
  mouse_x = stat(32)
  mouse_y = stat(33)
  mouse_btn = stat(34)
  left_button_clicked = (mouse_btn>0 and last_mouse_btn != mouse_btn) or btnp(4)
  
  --printh(tostr(left_button_clicked))

  -- keyboard input
  for k=0,1 do
   if(btn(k))keyx+=k*2-1
   if(btn(k+2))keyy+=k*2-1
  end

 -- update cursor pos
 cursx = mid(0,mouse_x+keyx,127) -- mouse xpos
 cursy = mid(0,mouse_y+keyy,127) -- mouse ypos
  
 cursor.x = cursx
 cursor.y = cursy

 --
 -- game mode
 --
 if not show_menu then 
  -- auto-scroll (pan) map
  if (cursx<4) camx-=2
  if (cursx>123) camx+=2
  if (cursy<4) camy-=2
  if (cursy>123) camy+=2

  -- lock cam to map
  camx=mid(camx,384)  --896
  camy=mid(camy,384)  --128
 end

 update_coroutines()

 collisions()

 ticks+=1
 last_mouse_btn = mouse_btn
 last_selected_obj = selected_obj
 last_selected_subobj = selected_subobj
end

function move_unit_pos(unit,x,y)
  unit.path="init"
  -- mouse  
    
  -- check target valid
  if fget(mget(x,y), 0) 
   or object_tiles[x..","..y] then
   -- abort as target invalid
   printh("aborting pathfinding - invalid target")
   return
  end


  --printh("goal="..goal.x..","..goal.y)

  -- create co-routine to find path (over number of cycles)  
  unit.tx = x
  unit.ty = y
  -- 0=idle, 1=pathfinding, 2=moving, 3=attacking, 4=guarding?
  unit.prev_state = unit.state
  unit.state = 1
  unit.cor = cocreate(findpath_cor)
end

function update_coroutines()
 -- update all unit coroutines 
 -- (pathfinding, moving, attacking, etc.)
 for _,unit in pairs(units) do 
  update_cor(unit)
 end
 -- update all building coroutines
 -- (building, repairing, etc.)
 for _,building in pairs(buildings) do 
  update_cor(building)
  update_cor(building.build_obj)
 end
end

function update_cor(obj)
 if obj then
  if obj.cor and costatus(obj.cor) != 'dead' then
    assert(coresume(obj.cor, obj))
  else
    obj.cor = nil
  end
 end
end

-- draw related
--------------------------------
function draw_level()
 -- draw the map, objects - everything except ui
	cls"15"
 --draw_sand?()
 
 camera(camx,camy)
 
 palt()
 --p1:draw()
 pal()

 -- temp fudge
 palt(0,false) 
 palt(11,true)
 
 map(0,0, 0,0, 64,32)
 map(64,0, 0,256, 64,32)

 -- debug pathfinding
 --if (debug_mode) draw_pathfinding()

 if path != nil and path != "init" then
  spr(144, path[1].x*8, path[1].y*8)
 end

 -- buildings
 for _,building in pairs(buildings) do 
  building:update()
  building:draw()
  -- draw selected reticule
  if (building == selected_obj) then 
   rect(selected_obj.x, selected_obj.y, 
        selected_obj.x+selected_obj.w-1, selected_obj.y+selected_obj.h-1, 
        7)
  end
 end
 
 -- draw units
 palt(11,true)
 for _,unit in pairs(units) do
  unit:update()
  unit:draw()
  -- draw selected reticule
  if (unit == selected_obj) then   
   palt(11,true)
   spr(16, selected_obj.x, selected_obj.y)
  end
 end

-- draw fog-of-war
draw_fow()
end



function draw_ui()
 -- ui (score, mouse, etc.)
 camera(0,0)
 pal()
 -- selected objects?
 palt(0,false) 
 
 -- object menu icon/buttons?
 if selected_obj and selected_obj.ico_obj then
  selected_obj.ico_obj:setpos(109,20)
  selected_obj.ico_obj:draw()--109,20)  
  if selected_obj.build_obj then
    selected_obj.build_obj:setpos(109,44) 
    selected_obj.build_obj:draw()--109,44)  
   end
 end
 
--  if selected_obj and selected_obj==2 then
--   selected_obj:draw(109,20,true)  
--  end
 
 -- radar 
--  rectfill(94, 94, 125, 125, 0)
--  rect(94, 94, 125, 125, 5)

 -- score
 printo("00"..flr(credits), 103,2, 7)
 
 -- placement?
 if selected_obj 
  and selected_obj.build_obj 
  and selected_obj.build_obj.life>=100 then
  -- draw placement
  -- (todo: improve this code!)
  local xpos=flr((cursor.x+camx)/8)*8-camx
  local ypos=flr((cursor.y+camy)/8)*8-camy

  fillp("0b1110110110110111.1")
  rectfill(xpos, ypos,
           xpos+selected_obj.build_obj.w, ypos+selected_obj.build_obj.h, 11)
  fillp()
 end

 if show_menu then
  -- test
  draw_dialog(121,73,col2,col1)

  -- build menu?
  if selected_obj.build_objs then
    rectfill(6,30,27,97,0)
    for i=1,#selected_obj.build_objs do
     local curr_item=selected_obj.build_objs[i]
     if i>=menu_pos and i<=menu_pos+2 then
      curr_item:setpos(9,32+((i-menu_pos)*19))
      curr_item:draw()
     else
      -- hide!
      curr_item:setpos(-16,16)
     end
     -- draw selected reticule
     if (selected_subobj == curr_item) then 
      sel_build_item_idx=i
      rect(curr_item.x-2, curr_item.y-2, 
          curr_item.x+17, curr_item.y+17, 
          7)

      print(selected_subobj.name,30,31,7)
      print("cOST:"..selected_subobj.cost,85,38,9)
      yoff=0
      local desc_lines=create_text_lines(selected_subobj.description, 23)
      for l in all(desc_lines) do
       print(l,30,44+yoff,6)
       yoff+=6
      end

     end
    end
  end

  -- ui elements (buttons)?
  for _,controls in pairs(ui_controls) do 
    --controls:update()
    controls:draw()
  end
 end

 -- cursor
 palt(11,true)
 cursor:draw()
end

function draw_dialog(w,h,bgcol,bordercol)
 fillp(0xA5A5.8)
 rectfill(0,0,127,127,0)
 fillp()

 rectfill(64-w/2, 64-h/2, 64+w/2, 64+h/2, bgcol)
 rect(64-w/2+1, 64-h/2+1, 64+w/2-1, 64+h/2-1, bordercol) 
end

function m_button(x,y,text,func_onclick,_w)
local obj={
  x=x,
  y=y,
  w=_w or #text*4+2,
  h=8,
  text=text,
  get_hitbox=function(self)
    return {
     x=self.x,
     y=self.y,
     w=self.w,
     h=self.h
    }
   end,
  draw=function(self)
    if(#text>1)rectfill(self.x,self.y,self.x+self.w,self.y+self.h, 7)
    if(#text>1)rectfill(self.x+1,self.y+1,self.x+self.w-1,self.y+self.h-1, self.hover and 12 or 6)
    print(self.text,self.x+2,self.y+2,(#text>1) and 0 or (self.hover and 12 or 7))

    if (debug_collision) draw_hitbox(self)
  end,
  func_onclick = func_onclick
 }
 add(ui_controls,obj)
end

-- auto-break message into lines
function create_text_lines(msg, max_line_length) --, comma_is_newline)
	--  > ";" new line, shown immediately
	local lines={}
	local currline=""
	local curword=""
	local curchar=""
	
	local upt=function(max_length)
		if #curword + #currline > max_length then
			add(lines,currline)
			currline=""
		end
		currline=currline..curword
		curword=""
	end

	for i = 1, #msg do
		curchar=sub(msg,i,i)
		curword=curword..curchar
		
		if curchar == " "
		 or #curword > max_line_length-1 then
			upt(max_line_length)
		
		elseif #curword>max_line_length-1 then
			curword=curword.."-"
			upt(max_line_length)

		elseif curchar == ";" then 
			-- line break
			currline=currline..sub(curword,1,#curword-1)
			curword=""
			upt(0)
		end
	end

	upt(max_line_length)
	if currline!="" then
		add(lines,currline)
	end

	return lines
end

-- function draw_pathfinding()
--  -- debug pathfinding 
--  if path != nil and path != "init" then
--   draw_path(path, 1, 1)
--   draw_path(path, 0, 12)
--  end
-- end

-- function draw_path(path, dy, clr)
--  local p = path[1]
--  for i = 2, #path do
--   local n = path[i]
--    line(p.x * 8 + 4 + dy - camx, p.y * 8 + 4 + dy - camy, n.x * 8 + 4 + dy - camx, n.y * 8 + 4 + dy - camy, clr)
--   p = n
--  end
-- end


-- game flow / collisions
--------------------------------



-- check all collisions
function collisions()
 
 clickedsomething=false

 -- check cursor/ui collisions
 if not show_menu then  
  -- unit collisions
  foreach(units, check_hover_select)
  -- building collisions 
  foreach(buildings, check_hover_select)
 end
 -- selected obj ui collision
 if selected_obj then
   ui_collision_mode=true
   if (selected_obj.ico_obj and not show_menu) check_hover_select(selected_obj.ico_obj)
   foreach(selected_obj.build_objs, check_hover_select)
   foreach(ui_controls, check_hover_select)
   --if (selected_obj.build_obj) check_hover_select(selected_obj.build_obj)
   ui_collision_mode=false
 end
 

 -- clicked something?
 if left_button_clicked then
  if clickedsomething then
   --show_menu=nil
    -- object "button"?
    if (not show_menu and selected_obj.func_onclick and selected_obj.parent!=nil) selected_obj:func_onclick() selected_obj=last_selected_obj
    if (show_menu and selected_subobj.text and selected_subobj.func_onclick) selected_subobj:func_onclick() --selected_subobj=last_selected_subobj
  
    -- clicked unit (first time?)
    if (selected_obj.type==1) sfx(62)
  -- deselect?
  else 
    -- do we have a unit selected?
    if selected_obj and selected_obj.type==1 then
      move_unit_pos(selected_obj, flr((camx+cursx)/8), flr((camy+cursy)/8))
    end
    
    -- placement? (temp code!)
    if selected_obj 
     and selected_obj.build_obj 
     and selected_obj.build_obj.life>=100 then
      -- place object
      local xpos=flr((cursor.x+camx)/8)
      local ypos=flr((cursor.y+camy)/8)
      -- slabs?
      if (selected_obj.build_obj.id==3 or selected_obj.build_obj.id==4) then
       for xx=0,selected_obj.build_obj.spr_w-1 do
        for yy=0,selected_obj.build_obj.spr_h-1 do
          mset(xpos+xx, ypos+yy, 19)
        end
       end
      else
       -- normal obj placement
       local objref = selected_obj.build_obj.ref
       m_map_obj_tree(objref,xpos*8,ypos*8)
      end
      -- reset build
      selected_obj.build_obj.life=0
      sfx(61)
    end

    if (not show_menu) selected_obj=nil
    --show_menu=nil
  end 
 end

end

function check_hover_select(obj)
  obj.hover = collide(cursor, obj)
  if left_button_clicked and obj.hover then
   if show_menu then
    selected_subobj = obj
    printh("selected_subobj selected!")
   else
    -- avoid certain objects from selection
    --if (obj.parent==nil and obj.id==3 or obj.id==4) return
    selected_obj = obj
   end
   clickedsomething=true
  end
end

function collide_event(o1, o2)
 
 -- player collisions
 -- if o1.type==type_player then
  
 --  -- player touching laser?
 --  if (o2.type==type_laser 
 --   or (o2.type==type_pressure_pad and p1.grounded))
 --   and not o2.triggered 
 --   and not o2.done then
 --   -- trigger alarm
 --   sfx(63,2) --alarm
 --   o2.triggered=true
 --   o2.alarm_cooldown=100
 --   -- noise
 --   sound_monitor:add_noise(40)

 --  -- player on stairs?
 --  elseif o2.type==type_stairs then
 --   o1.close_object=o2
  
 --  -- player in front of present drop?
 --  elseif o2.type==type_present_drop 
 --   and not o2.done then
 --   o1.close_object=o2

 --  end

 -- -- ball collisions
 -- elseif o1.type==type_ball then
 --  if o2.type==type_dog then
 --   --ball collided with dog
 --   o2.done=true
 --   o2.state=4
 --   -- kill ball
 --   del(curr_level.objects,o1)
 --   del(curr_level.balls,o1)
 --  end
 
 -- --snow spray collisions
 -- elseif o1.type==type_snowspray then
 --  if o2.type==type_camera
 --   and p1.flipx==(o2.spr==49) then
 --   o2.done=true
 --  end

 -- --snow globe collisions
 -- elseif o1.type==type_snowglobe then
 --  if o2.type==type_laser 
 --   and (o2.spr==23 or o2.spr==26)
 --   and not o2.done then
 --   o2:deactivate()
 --   sfx(55,3)
 --  end

 -- end

end



-- object shared methods
--------------------------------
function _set_anim(self,anim)
 if(anim==self.curanim)return--early out.
 local a=self.anims[anim]
 self.animtick=a.ticks--ticks count down.
 self.curanim=anim
 self.curframe=1
end

function _update_anim(self)
--anim tick
 self.animtick-=1
 if self.animtick<=0 then
  self.curframe+=1
  local a=self.anims[self.curanim]
  self.animtick=a.ticks--reset timer
  if self.curframe>#a.frames then
   self.curframe=1--loop
  end
  -- store the spr frame
  self.obj_spr=a.frames[self.curframe]
  
 end
end

--other helper functions
--------------------------------

--print string with outline.
function printo(str,startx,
 starty,col,
 col_bg)
 for xx = -1, 1 do
 for yy = -1, 1 do
 print(str, startx+xx, starty+yy, col_bg)
 end
 end
 print(str,startx,starty,col)
end

function collide(o1, o2)
 local hb1=o1:get_hitbox()
 local hb2=o2:get_hitbox()
 
 if hb1.x < hb2.x + hb2.w and
  hb1.x + hb1.w > hb2.x and
  hb1.y < hb2.y + hb2.h and
  hb1.y + hb1.h >hb2.y 
 then
  return true
  --collide_event(o1, o2)
 else
  return false
 end
end

function draw_hitbox(obj)
 --reset_draw_pal()
 local hb=obj:get_hitbox()
 rect(hb.x,hb.y,hb.x+hb.w,hb.y+hb.h,obj.hover and 11 or 8)
 --rect(hb.x,hb.y,hb.x+hb.w,hb.y+hb.h,selected_obj==obj and 7 or obj.hover and 11 or 8)
 --set_goggle_pal()
end

function alternate()
 return flr(t())%2==0
end


-- explode object data
function explode_data()
 str_arrays=split(obj_data,"|","\n")
 ---------------------------------
 -- printh("------------------")
 -- printh("test 1:"..#str_arrays)
 -- printh("test 4:"..str_arrays[1][1])
 -- printh("test 5:"..str_arrays[2][1])
 -- printh("test 5.1:"..str_arrays[2][11])
 -- --test 6
 -- --_g[a[2][11]]()
 -- --test 7
 -- new_obj={
 --   name="test obj",
 --   draw=_g[str_arrays[3][20]]
 -- }
 -- new_obj:draw()
 ---------------------------------

 new_data={}
 -- loop all objects
 for i=2,#str_arrays-1 do
  new_obj={}
  -- loop all properties
  for j=1,#str_arrays[i] do
   local val=str_arrays[i][j]
   -- convert all but the text columns to numbers
   if (j!=2 and j<23) val=tonum(val)
   new_obj[str_arrays[1][j]]=val
  end
  --printh(">>>>"..str_arrays[i][1])
  new_data[tonum(str_arrays[i][1])]=new_obj
 end
 -- replace with exploded data
 obj_data=new_data
 -- test new structure!
 printh("test 8:"..obj_data[2].name)
 printh("test 98:"..obj_data[2].id)
 printh("test 98b:"..obj_data[2].func_init)
end


-- split string
-- https://www.lexaloffle.com/bbs/?tid=32520
 function split(str,d,dd)
 local a={}
 local c=0
 local s=''
 local tk=''
 
 if dd~=nil then str=split(str,dd) end
 while #str>0 do
  if type(str)=='table' then
   s=str[1]
   add(a,split(s,d))
   del(str,s)
  else
   s=sub(str,1,1)
   str=sub(str,2)
   if s==d then 
    add(a,tk)
    tk=''
   else
    tk=tk..s
   end
  end
 end
 add(a,tk)
 return a
 end

-- rotate sprite
-- by freds72
-- https://www.lexaloffle.com/bbs/?pid=52525#p52541
local rspr_clear_col=0

function rspr(sx,sy,x,y,a,w,trans,single_col)
	local ca,sa=cos(a),sin(a)
	local srcx,srcy,addr,pixel_pair
	local ddx0,ddy0=ca,sa
	local mask=shl(0xfff8,(w-1))
	w*=4
	ca*=w-0.5
	sa*=w-0.5
	local dx0,dy0=sa-ca+w,-ca-sa+w
	w=2*w-1
	for ix=0,w do
		srcx,srcy=dx0,dy0
		for iy=0,w do
			if band(bor(srcx,srcy),mask)==0 then
				local c=sget(sx+srcx,sy+srcy)
				if (c!=trans) pset(x+ix,y+iy, single_col or c)
			--else
				--pset(x+ix,y+iy,rspr_clear_col)
			end
			srcx-=ddy0
			srcy+=ddx0
		end
		dx0+=ddx0
		dy0+=ddy0
	end
end

-- fixed sqrt to avoid overflow
-- https://www.lexaloffle.com/bbs/?tid=29528
function dist(x1,y1,x2,y2)
 return abs(sqrt(((x1-x2)/1000)^2+((y1-y2)/1000)^2)*1000)
end


--
-- pathfinding-related
--

-- func for co-routine call
function findpath_cor(unit)
 -- start = {
 --  x = unit.x/8, 
 --  y = unit.y/8
 -- }
 unit.path = find_path(
                   { x = flr(unit.x/8), y = flr(unit.y/8) },
                   { x = unit.tx, y = unit.ty},
                   manhattan_distance,
                   flag_cost,
                   map_neighbors,
                   function (node) return shl(node.y, 8) + node.x end,
                   nil)  
 
 -- todo: check path valid???

 -- now auto-move to path 
 -- 0=idle, 1=pathfinding, 2=moving, 3=attacking, 4=guarding?
 unit.prev_state = unit.state
 unit.state = 2
 unit.cor = cocreate(movepath_cor)
end
 
function movepath_cor(unit)
 --printh("-------------")

 unit.state=2 --moving

 -- loop all path nodes...
 for i=#unit.path-1,1,-1 do
  local node=unit.path[i]

  if not unit.norotate then
    -- rotate to angle
    local dx=unit.x-(node.x*8)
    local dy=unit.y-(node.y*8)
    local a=atan2(dx,dy)
    --printh("  >> target angle="..a)
    while (unit.r != a) do
      turntowardtarget(unit, a)
    end
  end
  
  -- move to new position
  local scaled_speed = unit.speed or .5
  local distance = sqrt((node.x*8 - unit.x) ^ 2 + (node.y*8 - unit.y) ^ 2)
  local step_x = scaled_speed * (node.x*8 - unit.x) / distance
  local step_y = scaled_speed * (node.y*8 - unit.y) / distance 
  for i = 0, distance/scaled_speed-1 do
   unit.x+=step_x
   unit.y+=step_y
   yield()
  end
  unit.x,unit.y = node.x*8, node.y*8

  -- reveal fog?
  reveal_fow(unit)-- .x,unit.y)
 end

 -- arrived?
 unit.state=1 --idle

 -- todo: set map/path data that tile is now occupied
end


-- rotate to next path node
-- function rotatetoangle_cor()
--  -- get next node pos
--  local node=path[i]
--  turntowardtarget(unit, targetangle)
--  --cor = cocreate(movepath_cor)
-- end

pi = 3.14159
turnspeed = .5 * (pi/180)


function turntowardtarget(unit, targetangle)
   diff = targetangle-unit.r
  --  printh("unit.r="..unit.r)
  --  printh("targetangle="..targetangle)
  --  printh("diff="..diff)
  --  printh("turnspeed="..turnspeed)
  --  printh("-")
   
   -- never turn more than 180
   if diff > 0.5 then
    --printh("big angle 1")
    diff -= 1
   elseif diff < -0.5 then
    --printh("big angle 2")
    diff += 1
   end

   -- fake delay
   -- for sleep=1,20 do
   --  yield()
   -- end

   if diff > turnspeed then
    unit.r += turnspeed
   elseif diff < -turnspeed then
    unit.r -= turnspeed
   else
    -- we're already very close
    unit.r = targetangle
   end

   -- make sure that our rotation value always stays within a "one-cycle" range
   if (unit.r > pi) unit.r-=2*pi
   if (unit.r < -pi) unit.r+=2*pi
   
   -- fake delay
   --for sleep=1,20 do
    yield()
   --end
end





-- makes the cost of entering a
-- node 4 if flag 1 is set on
-- that map square and zero
-- otherwise
-- unless the new node is a 
-- diagonal, in which case
-- make it cost a bit more
function flag_cost(from, node, graph)
 -- get the standard cost of the tile (grass vs. mud/water)
 local base_cost = fget(mget(node.x, node.y), 1) and 4 or 1
 -- make diagonals cost a little more than normal tiles
 -- (this helps negate "wiggling" in close quarters)
 if (from.x != node.x and from.y != node.y) return base_cost+1
 return base_cost
end


-- returns any neighbor map
-- position at which flag zero
-- is unset
function map_neighbors(node, graph)
 local neighbors = {}
 for xx = -1, 1 do
  for yy = -1, 1 do
   if (xx!=0 or yy!=0) maybe_add(node.x+xx, node.y+yy, neighbors)
  end
 end return neighbors
end

-- maybe adds the node to neighbors table
-- (if flag zero is unset at this position)
function maybe_add(nx, ny, ntable)
 --printh("testing:"..nx..","..ny)
 if (
  not fget(mget(nx,ny), 0) 
  and object_tiles[nx..","..ny]==nil
 )

  -- todo:: parse entire map into chunks of higher-level connected regions
  --        - each chunk represents 16x16 tiles
  --        - just need to check that there is a connection
  --        - then use a* on the higher level to traverse longer than 1-screen
  --        - use normal/detailed a* when traversing within each chunk 
  --          (series of paths, joining a complete journey)

  -- (tried capping max path, still uses a lot of cpu)
  -- and nx>start.x-8 and nx<start.x+8
  -- and ny>start.y-8 and ny<start.y+8

  then 
   add(ntable, {x=nx, y=ny}) 
 end
 --printh("test passed.")
end

-- estimates the cost from a to
-- b by assuming that the graph
-- is a regular grid and all
-- steps cost 1.
function manhattan_distance(a, b)
 return abs(a.x - b.x) + abs(a.y - b.y)
end


-- pathfinder
-- by @casualeffects

-- i minimized the number of
-- tokens as far as possible
-- without hurting readability
-- or performance. you can save
-- another four tokens and a
-- lot of characters by
-- minifying if you don't care
-- about reading the code.

-- returns the shortest path, in
-- reverse order, or nil if the
-- goal is unreachable.
--
-- from the graphics codex
-- http://graphicscodex.com
function find_path
 (start,
  goal,
  estimate,
  edge_cost,
  neighbors, 
  node_to_id, 
  graph)
  
  -- the final step in the
  -- current shortest path
  local shortest, 
  -- maps each node to the step
  -- on the best known path to
  -- that node
  best_table = {
   last = start,
   cost_from_start = 0,
   cost_to_goal = estimate(start, goal, graph)
  }, {}
 
  best_table[node_to_id(start, graph)] = shortest
 
  -- array of frontier paths each
  -- represented by their last
  -- step, used as a priority
  -- queue. elements past
  -- frontier_len are ignored
  local frontier, frontier_len, goal_id, max_number = {shortest}, 1, node_to_id(goal, graph), 32767.99
 
  -- while there are frontier paths
  while frontier_len > 0 do
 
   -- find and extract the shortest path
   local cost, index_of_min = max_number
   for i = 1, frontier_len do
    local temp = frontier[i].cost_from_start + frontier[i].cost_to_goal
    if (temp <= cost) index_of_min,cost = i,temp
   end
  
   -- efficiently remove the path 
   -- with min_index from the
   -- frontier path set
   shortest = frontier[index_of_min]
   frontier[index_of_min], shortest.dead = frontier[frontier_len], true
   frontier_len -= 1
 
   -- last node on the currently
   -- shortest path
   local p = shortest.last
   
   if node_to_id(p, graph) == goal_id then
    -- we're done.  generate the
    -- path to the goal by
    -- retracing steps. reuse
    -- 'p' as the path
    p = {goal}
 
    while shortest.prev do
     shortest = best_table[node_to_id(shortest.prev, graph)]
     add(p, shortest.last)
    end
 
    -- we've found the shortest path
    return p
   end -- if
 
   -- consider each neighbor n of
   -- p which is still in the
   -- frontier queue
   for n in all(neighbors(p, graph)) do
    -- find the current-best
    -- known way to n (or
    -- create it, if there isn't
    -- one)
    local id = node_to_id(n, graph)
    local old_best, new_cost_from_start =
     best_table[id],
     shortest.cost_from_start + edge_cost(p, n, graph)
    
    if not old_best then
     -- create an expensive
     -- dummy path step whose
     -- cost_from_start will
     -- immediately be
     -- overwritten
     old_best = {
      last = n,
      cost_from_start = max_number,
      cost_to_goal = estimate(n, goal, graph)
     }
 
     -- insert into queue
     frontier_len += 1
     frontier[frontier_len], best_table[id] = old_best, old_best
    end -- if old_best was nil
 
    -- have we discovered a new
    -- best way to n?
    if not old_best.dead and old_best.cost_from_start > new_cost_from_start then
     -- update the step at this
     -- node
     old_best.cost_from_start, old_best.prev = new_cost_from_start, p
    end -- if
   end -- for each neighbor
   
   count+=1
   if count>10 then
    count=1
    yield()
   end
   --count%=100
   --yield()

  end -- while frontier not empty
 
  -- unreachable, so implicitly
  -- return nil
 end
 








__gfx__
bbbbbbbbbbb1bbbbf5d555d555d555d55d555d5fffffffff1d515555ffffffff99f99999ffffffffffffffff9f99f9f9ff9f9999ffffffffffffffffffffffff
bb11bbbbbb171bbb1555515d15555155d51555515dfffd5f5155d55dffff9fff9f9999f9fff9fffffffffffff99f99f999f99899ffffffffffffffffffffffff
bb171bbbb1bbb1bb5d55d5515d55d555155d55d5d5155551555d5155ffff999999ff99999999ffffffffffff9f99f99f9f9989f9ffffffffffffffffffffffff
bb1771bb17b1b71b55515d5555515d5d55d51555155d55d5d5555d55fff99f9f99999f99f9f99ffff9ffff9f999f999999f88899ffffffffffffffffffffffff
bb17771bb1bbb1bbd55d5555d55555555555d55d55d5155555d155d5fffff9f9fff999999f9fffffff99f999f9ffff9f99998f99ffffffffffffffffffffffff
bb177771bb171bbb55d551d555d515555d155d555555d55d15555555ffff999999999f999999ffff999f99f9fffffffffff89999ffffffffffffffffffffffff
bb17711bbbb1bbbb1555555515555515555555515d155d55f51ffd5ffff99f9f99fff9f9f9f99fff9f99f99fffffffff99999f99ffffffffffffffffffffffff
bbb11bbbbbbbbbbbf55d5515555d55555155d55f55555551ffffffffffff99f9ff9f99999f99fffff99f99f9ffffffff99fff9f9ffffffffffffffffffffffff
b7bbbb7bffffffffffffffffddddddddddddddddffffffffffffffff55d555d555d555d555d555d555dd444444444444444444d555dd444444444444444444d5
77bbbb77fffffffffff77fffd5555555d5555555f888888ff6ffffff155551551555515515555155155d44444444444444444455155044444444444444444055
bbbbbbbbffffffffff79ff7fd5555555d5015515f8a8888fffffff6f5d55d55555dddd555d55d5555dd4444444444444444444455d5104444444444444444155
bbbbbbbbfffffffff79f779fd5555555d5105555f888888fffffffff555155dddd4444ddddd15d5d55d44444444444444444444d555114444444444444440d5d
bbbbbbbbfffffffffff799ffd5555555d5555111f888888fffffffffd555dd444444444444445555d5d444444444444444444445d55510044444444444401555
bbbbbbbbffffffffff799fffd5555555d1555101f888888ffff6ffff55d5d444444444444444455555d44444444444444444444555d515100044444000015555
77bbbb77ffffffffff79ffffd5555555d5555111f888888fffffffff155d44444444444444444415155d44444444444444444415155555151100000111155515
b7bbbb7bfffffffff7ffffffd5555555d5515555ffffffffffffffff555d44444444444444444455555d44444444444444444455555d555555111115555d5555
000000000bbbbbb000000000bbbbb1b1000000001b1bbbbb00000000bbbbbbbb0000000001bbbb1010000000bbbbbbb0000000010bbbbbbb00000000ffffffff
001bb1000bbbbbb0bbb1b000bbb1bb000000bbbb00bb1bbb1b1b1b1bbbbbbbbb000000000bbbbbb0b0000000bbbbb1000000000b00bbbbbbb000000bffffffff
01bbbb100bbbbbb0bbbb1b00bb1b0000000b1bbb0001b1bbbbbbbbbbbbbbbbbb00b0b00001bbbb101b000000bbbb1b00000000b1001bbbbbb1b1b1bbffffffff
0bbbbbb00b1b1b10bbb1b000b1b0000000b1bbbb00000b1bbbbbbbbbbbbbbbbb0b1b1b000bbbbbb0bb000000bbbbb100000001bb00b1bbbbbb1b1bbbffffffff
0bbbbbb000b1b1b0bbbb1b00bb000000000b1bbb000001bbbbbbbbbbbbb1b1bb01b1b1b001bbbb10b1b00000bbbb1b0000000b1b001bbbbbbbbbbbbbffffffff
01bbbb10000b0b00bbb1b0001b00000000b1bbbb000000b1bbbbbbbbbb1b1b1b0bbbbbb00bbbbbb0bb1b0000bbbbb1000001b1bb00b1bbbbbbbbbbbbffffffff
001bb10000000000bbbb0000b0000000000b1bbb0000000b1b1b1b1bb000000b0bbbbbb001bbbb10bbb1bb00bbbbbb0000bb1bbb001bbbbbbbbbbbbbffffffff
0000000000000000bbb0bbbb10000000000000000000000100000000000000000bbbbbb00bbbbbb0bbbbb1b1bbbbbbb01b1bbbbb0bbbbbbbbbbbbbbbffffffff
ffffffffbb2222bbb08dd80bbbbbbbbbb28882bbbbbbbbbbffffffffffffffffffffffffffffffffffffffff50bbb05bbbb76bbbbbb76bbbb6bbb6bbb6bbb6bb
ffffffffb088880bb2d77d2bb68d86bb0888880bb68886bbbfffffffffffffffffffffffffffffffffffffff6888886bbbb76bbbbbb76bbbb8bbb8bbb8bbb8bb
ffffffffb088880bb867768bb7d7d7bb0828280bb8ddd8bbbfffffffffffffffffffffffffffffffffffffff68d8d86bbbbddbbbb7b55b7bb2bbb2bbb2bbb2bb
ffffffffb288882bb867768bb7d6d7bb2868682bb86868bbbfffffffffffffffffffffffffffffffffffffff6868686bbbd66dbbb651156bb0bbb0bb0b0b0b0b
ffffffffb288882bb2d66d2bb78687bb2262622bb87878bbbfffffffffffffffffffffffffffffffffffffff6878786bbbd66dbbbdd66ddbbbb6bbbbbbb6bbbb
ffffffffb028820bb286682bb78087bb2c0c0c2bb80808bbbfffffffffffffffffffffffffffffffffffffff6808086bbbbddbbbb1b11b1bbbb8bbbbbbb8bbbb
ffffffffb0d22d0bb026620bb62226bb0088800bb62226bbbfffffffffffffffffffffffffffffffffffffff7888887bbbbbbbbbbbbbbbbbbbb2bbbbbbb2bbbb
ffffffffbb2882bbbbb00bbbbbbbbbbbbbbbbbbbbbbbbbbbffffffffffffffffffffffffffffffffffffffff50bbb05bbbbbbbbbbbbbbbbbbbb0bbbbbb0b0bbb
d66dddddddd6fffdddd776ddddddddddddddddddddd666ddddddddddddd6666dddddddddddddddddddddddddddddddddddddddddd19999999999999977777777
76665555551ffff1d576de65d5577655d5555555d5766665d5555555d566777655555555d555555555555555d766777755555555d49495594999924976666665
76665805555f4441d76deee5d576de65d5556555d5766665d5888885d767666d65555555d554777777777455d7ddfff755555555d19425599922999976666665
177d22055d5ffff1d66d11e5d76deee5d5576655d5677725d5555555d767666d65555555d544ff7fff7ff445d7777f7765555777d495f5f4f412141976666665
d1d55505555f1011d66d01e5d66d11e5d55d7d55d566dd25d5522255d766ddd665555555d504777778617405d4447ff7265557f6d19565656599995976666665
6555550515df1001d66d0e55d66d01e5d55ddd55d566dd25d5555555d676666625555555d544ff7ff6d1f445d4047777655777fdd49995555594495976666665
d6d6d55555551005d56dd555d66d0e55d555d555d556dd55d5552555d667ddd225666655d504777771177405d44444442657ffffd19495805594495976666665
d6d6d555d55d5555d5555555d56dd555d5555555d5555555d5522255d66d11d226680765d544ff7fff7ff445d55544445557ff7fd49992205594495955555555
dddddddd55d555d5ddddd776ddddddddddd666ddddddddddddddddddd56d11d2762206d6d504777777777405d76677775557ff7fd195594095999959dddddddd
d555555515555155d55576de65555555d5766665d5555555d5522255d55d11d5767606d6d544ff7fff7ff445d7ddfff755577777d495594495977779d5ddddd5
d555555a5d55d555d5576deee5558055d5766665d5556555d5552555d5555555766d0d66d542222222222245d7777f77655444449999529925777777d55ddd55
d5aaa99a55515d5dd5566d11e5522055d5677725d5576655d5555555d555555567666662d528028020200225d4447ff7265804809429444444776666d555d555
d5aaa55ad5555555d5566d01e5555055d566dd25d55d7d55d5522255d5555555667dd722d522022022200225d4047777652202209999242424766666d5551555
d5a1199a55d51555d5566d0ed5555055d566dd25d55ddd55d5555555d555555566d11d22d551011011111115d444444426550550944242424296666dd5511155
d544445a15555515d5556dd5d5555555d556dd55d555d555d5888885d555555556d11d25d555011011111155d555444455550550944242424294ddd2d5111115
d5151515555d5555d5555555d5555555d5555555d5555555d5555555d555555555d11d55d555511111111555d555222255555555d555555555594425d1111111
dddd666666ddddddddd7778666666dddddddddddddddddddddddd666666666660000000000000000000000000000000000000000000000000000000000000000
d566ddddd61111106667d22ddddd657667555555d557755555555ddddd4ddddd0000000000000000000000000000000000000000000000000000000000000000
d5dddd000066dd666dd7dd0dd6666dddddd56765d566969666655ddddd4ddd5d0000000000000000000000000000000000000000000000000000000000000000
d5dd0000001111dd6dd7660dd6dd611111ddddd5d5ddadadddd55ddd5ddd5ddd0000000000000000000000000000000000000000000000000000000000000000
d50000000066dd106dd11666666d7055011111157777a7a711555ddddd55d5dd0000000000000000000000000000000000000000000000000000000000000000
d5555555551111106d76611111177050554214257d9d9d971155544d5555dd440000000000000000000000000000000000000000000000000000000000000000
d551f6155566dd666d55d5dd66611005554254257da76767115767dddd5d5ddd0000000000000000000000000000000000000000000000000000000000000000
d550f605551111dd6ddd6ddd711110255542542575776d675576667d5ddddd5d0000000000000000000000000000000000000000000000000000000000000000
d555f655551d6d106d777777711110455542542575777777766767667d4d5ddd0000000000000000000000000000000000000000000000000000000000000000
d5516615551d6d106d7011111ddd6445555555557d780777767767767d4ddddd0000000000000000000000000000000000000000000000000000000000000000
d5505505551d6d106770d1d11ddd7055555555557d220dddd666d66d755555550000000000000000000000000000000000000000000000000000000000000000
d5555555551d6d10ddd0d1d116777055555555557ddd0d777d66d6dd765555550000000000000000000000000000000000000000000000000000000000000000
d55555555510d010ddd0d1dd111115dddddd5555777757707dddddd77d6755550000000000000000000000000000000000000000000000000000000000000000
d555550f050aaa000001d1111111105555555555ddddddd07777777776d755550000000000000000000000000000000000000000000000000000000000000000
d55f0f555555555500111ddd111115dddddd5555d111d1d5ddddddddd77755550000000000000000000000000000000000000000000000000000000000000000
d555555555555555011111111111105555555555d5555555d1d1d1d1dddd55550000000000000000000000000000000000000000000000000000000000000000
ccccccccccccc0cccccccccccccccccccccccccccccccccc9ff99f999f999999ccccccccccccccccccccccccccccccccffffffffffffffffeeeeeeeeeeeeeeee
ccccccccccccc0ccccccccccccccccccc71dcccc1c0c1cc79999999999996666cccccccc7cccccccccccccccccccccccffffffffffffffffeeeeeeeeeeeeeeee
cccccccccccccdccccccc677ddcccccc5666ccccc101c7d7ff99f99ff96666ddccccccc7dc0cccccdddcccccccccccccffffffffffffffffeeeeeeeeeeeeeeee
ccccccccccccccdccccc67111dcccccc11116666dc0157d799999999dd766666cccc7ccc50ccccccdddddddccccccc66ffffffffffffffffeeeeeeeeeeeeeeee
9accc5acccccc55cccc6660dd1dccccc6d1d111166665757777666dd55777777ccc7d1cc5ccccc7cddddddddddcc6666ffffffffffffffffeeeeeeeeeeeeeeee
575c544aaaccccccccd6650001dccc7776d76d1c1111111066dd666155766dddcc6666666dddc7dcddd7dddddddd6666ffffffffffffffffeeeeeeeeeeeeeeee
5d75144444aaaccc9dddd055d1d996666d1dd11cc56505556666661155766dddff61616160d0cc5cdd75ddf2dddddd66ffffffffffffffffeeeeeeeeeeeeeeee
9511199994444ccc95ddd000011d5ddd6d1d6d1ccd7d0d6ddddd22115d766dddf666ddd66d55dc5fddd1df442df4ddddffffffffffffffffeeeeeeeeeeeeeeee
9001199999991515675dd055501d5ddd6d1d6d1ddd7d0d7ddddd2661dd766dddf666ddd66d55dffffd42d9442d94d76dffffffffffffffffeeeeeeeeeeeeeeee
50d019999999151501755000001d55556d1d4d9949945499dddd2261d5566ddd777777777776666d9944444444444994ffffffffffffffffeeeeeeeeeeeeeeee
501015aaaaaaa44450155ddddddd66996d19999999666666dddd2261ddd55d6d777777766667777d49442424242449d4ffffffffffffffffeeeeeeeeeeeeeeee
4500545aa744444566666666666666669999999966776767dddd22655dddd565ffff7776666666dd4944242424244994ffffffffffffffffeeeeeeeeeeeeeeee
544454444444544466666666555555554999996777777776dddd2265555ddd654999466555555dddff22222222222255ffffffffffffffffeeeeeeeeeeeeeeee
4554444544544454555555559999f99999446776677676985555555555777777994999966ddddd945555555555999955ffffffffffffffffeeeeeeeeeeeeeeee
54445544554545449f9999f9999999f99977777777679887555555557666666694494494994499495559999955559999ffffffffffffffffeeeeeeeeeeeeeeee
455454554555544599fffffff9f99999477777667798897755555576666dddd644444444444444449999999999955559ffffffffffffffffeeeeeeeeeeeeeeee
ffffffffffffffffffffffffffffffffccccccccccccccccffffffffffffffffeeeeeeeeeeeeeeeeffffffffffffffffeeeeeeeeeeeeeeeeffffffffffffffff
ffffffffffffffffffffffffffffffffcccccccccccccc77ffffffffffffffffeeeeeeeeeeeeeeeeffffffffffffffffeeeeeeeeeeeeeeeeffffffffffffffff
ffffffffffffffffffffffffffffffffccccccccccc77766ffffffffffffffffeeeeeeeeeeeeeeeeffffffffffffffffeeeeeeeeeeeeeeeeffffffffffffffff
ffffffffffffffffffffffffffffffffcccccc7777766666ffffffffffffffffeeeeeeeeeeeeeeeeffffffffffffffffeeeeeeeeeeeeeeeeffffffffffffffff
ff77777777ffffffff77757777ffffffccc7776666766666ffffffffffffffffeeeeeeeeeeeeeeeeffffffffffffffffeeeeeeeeeeeeeeeeffffffffffffffff
ff766666666fffffff766657666fffff7776666666766666ffffffffffffffffeeeeeeeeeeeeeeeeffffffffffffffffeeeeeeeeeeeeeeeeffffffffffffffff
ff7666666666ffffff5555565555ffff6676666666766666ffffffffffffffffeeeeeeeeeeeeeeeeffffffffffffffffeeeeeeeeeeeeeeeeffffffffffffffff
f766666666666ffff777777577777fff6676666666766666ffffffffffffffffeeeeeeeeeeeeeeeeffffffffffffffffeeeeeeeeeeeeeeeeffffffffffffffff
f7666666666666fff7666665766666ff6676666666766666ffffffffffffffffeeeeeeeeeeeeeeeeffffffffffffffffeeeeeeeeeeeeeeeeffffffffffffffff
f76666666666666ff76666665766666f6676666666766666ffffffffffffffffeeeeeeeeeeeeeeeeffffffffffffffffeeeeeeeeeeeeeeeeffffffffffffffff
f55555555555555ff55555555555555f6676666666766666ffffffffffffffffeeeeeeeeeeeeeeeeffffffffffffffffeeeeeeeeeeeeeeeeffffffffffffffff
ffffffffffffffffffffffffffffffffdd76666666766666ffffffffffffffffeeeeeeeeeeeeeeeeffffffffffffffffeeeeeeeeeeeeeeeeffffffffffffffff
fffffffffffffffffffffffffffffffffffdddd666766666ffffffffffffffffeeeeeeeeeeeeeeeeffffffffffffffffeeeeeeeeeeeeeeeeffffffffffffffff
fffffffffffffffffffffffffffffffffffffffddd766666ffffffffffffffffeeeeeeeeeeeeeeeeffffffffffffffffeeeeeeeeeeeeeeeeffffffffffffffff
fffffffffffffffffffffffffffffffffffffffffffddd66ffffffffffffffffeeeeeeeeeeeeeeeeffffffffffffffffeeeeeeeeeeeeeeeeffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffddffffffffffffffffeeeeeeeeeeeeeeeeffffffffffffffffeeeeeeeeeeeeeeeeffffffffffffffff
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccffffffffffffffffeeeeeeeeeeeeeeee
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccffffffffffffffffeeeeeeeeeeeeeeee
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc7cccccccffffffffffffffffeeeeeeeeeeeeeeee
ccccccccccccccccccccccf7ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccffc7ccccccffffffffffffffffeeeeeeeeeeeeeeee
cccc7755555555ccccccc5f01cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccfff54cccccccffffffffffffffffeeeeeeeeeeeeeeee
ccc7675dd55dd5cccccc055ffccccccccccccc4ff75550cccccccccc7776660ccccc2888887660cccc4ff54cccccccccffffffffffffffffeeeeeeeeeeeeeeee
cc7666755566555ccccc0f7557ccccccccccc4ffff7fccccccccc4ffff75550cccc288888887ccccccc54cccccff5cccffffffffffffffffeeeeeeeeeeeeeeee
cd66d6755666655ccccc0f7fff7ccccccc54454444444f7ccc45444444444ccccc5225222222287ccc45555cc4ffffccffffffffffffffffeeeeeeeeeeeeeeee
c5dd66655555555ccccc0ff000550cccc555fffffffff55cc54fffffffffff5cc55588888888855cc54fffffffffff5cffffffffffffffffeeeeeeeeeeeeeeee
916666d001110009cccc00df00cccccc9506000000000659950400000000045995060000000006599504000000000459ffffffffffffffffeeeeeeeeeeeeeeee
f90500000444000999999900ff9999999955555555555599995555555555559999555555555555999955555555555599ffffffffffffffffeeeeeeeeeeeeeeee
999999999999999f44999df9dff9f999f99999999999999f9999999999999999f99999999999999f9999999999999999ffffffffffffffffeeeeeeeeeeeeeeee
9f9ff9999f9999994444df449df999f9999999f999999999f99f99f99999f99f999999f999999999f99f99f99999f99fffffffffffffffffeeeeeeeeeeeeeeee
99999999999999f999945559455599999ff9999999fff999999999999ff999999ff9999999fff999999999999ff99999ffffffffffffffffeeeeeeeeeeeeeeee
99999999ffff9999fff999999999999999999999999999ff999fff9999999f9999999999999999ff999fff9999999f99ffffffffffffffffeeeeeeeeeeeeeeee
9fffff99999999ff9999999f99999ff999fffff9999f99999f9999999999999999fffff9999f99999f99999999999999ffffffffffffffffeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeffffffffffffffffeeeeeeeeeeeeeeeeffffffffffffffffeeeeeeeeeeeeeeeeffffffffffffffffeeeeeeeeeeeeeeeeffffffffffffffff
eeeeeeeeeeeeeeeeffffffffffffffffeeeeeeeeeeeeeeeeffffffffffffffffeeeeeeeeeeeeeeeeffffffffffffffffeeeeeeeeeeeeeeeeffffffffffffffff
eeeeeeeeeeeeeeeeffffffffffffffffeeeeeeeeeeeeeeeeffffffffffffffffeeeeeeeeeeeeeeeeffffffffffffffffeeeeeeeeeeeeeeeeffffffffffffffff
eeeeeeeeeeeeeeeeffffffffffffffffeeeeeeeeeeeeeeeeffffffffffffffffeeeeeeeeeeeeeeeeffffffffffffffffeeeeeeeeeeeeeeeeffffffffffffffff
eeeeeeeeeeeeeeeeffffffffffffffffeeeeeeeeeeeeeeeeffffffffffffffffeeeeeeeeeeeeeeeeffffffffffffffffeeeeeeeeeeeeeeeeffffffffffffffff
eeeeeeeeeeeeeeeeffffffffffffffffeeeeeeeeeeeeeeeeffffffffffffffffeeeeeeeeeeeeeeeeffffffffffffffffeeeeeeeeeeeeeeeeffffffffffffffff
eeeeeeeeeeeeeeeeffffffffffffffffeeeeeeeeeeeeeeeeffffffffffffffffeeeeeeeeeeeeeeeeffffffffffffffffeeeeeeeeeeeeeeeeffffffffffffffff
eeeeeeeeeeeeeeeeffffffffffffffffeeeeeeeeeeeeeeeeffffffffffffffffeeeeeeeeeeeeeeeeffffffffffffffffeeeeeeeeeeeeeeeeffffffffffffffff
eeeeeeeeeeeeeeeeffffffffffffffffeeeeeeeeeeeeeeeeffffffffffffffffeeeeeeeeeeeeeeeeffffffffffffffffeeeeeeeeeeeeeeeeffffffffffffffff
eeeeeeeeeeeeeeeeffffffffffffffffeeeeeeeeeeeeeeeeffffffffffffffffeeeeeeeeeeeeeeeeffffffffffffffffeeeeeeeeeeeeeeeeffffffffffffffff
eeeeeeeeeeeeeeeeffffffffffffffffeeeeeeeeeeeeeeeeffffffffffffffffeeeeeeeeeeeeeeeeffffffffffffffffeeeeeeeeeeeeeeeeffffffffffffffff
eeeeeeeeeeeeeeeeffffffffffffffffeeeeeeeeeeeeeeeeffffffffffffffffeeeeeeeeeeeeeeeeffffffffffffffffeeeeeeeeeeeeeeeeffffffffffffffff
eeeeeeeeeeeeeeeeffffffffffffffffeeeeeeeeeeeeeeeeffffffffffffffffeeeeeeeeeeeeeeeeffffffffffffffffeeeeeeeeeeeeeeeeffffffffffffffff
eeeeeeeeeeeeeeeeffffffffffffffffeeeeeeeeeeeeeeeeffffffffffffffffeeeeeeeeeeeeeeeeffffffffffffffffeeeeeeeeeeeeeeeeffffffffffffffff
eeeeeeeeeeeeeeeeffffffffffffffffeeeeeeeeeeeeeeeeffffffffffffffffeeeeeeeeeeeeeeeeffffffffffffffffeeeeeeeeeeeeeeeeffffffffffffffff
eeeeeeeeeeeeeeeeffffffffffffffffeeeeeeeeeeeeeeeeffffffffffffffffeeeeeeeeeeeeeeeeffffffffffffffffeeeeeeeeeeeeeeeeffffffffffffffff
__label__
99f99999ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
9f9999f9fff9ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
99ff99999999ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
99999f99f9f99fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
fff999999f9fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
99999f999999ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
99fff9f9f9f99fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ff9f99999f99ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
99f9999999f99999fffffffff5d555d5ffffffffffffffffffffffff5d555d5fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
9f9999f99f9999f9fff9ffff1555515dffffffffffffffffffffffffd5155551ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
99ff999999ff99999999ffff5d55d551ffffffffffffffffffffffff155d55d5ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
99999f9999999f99f9f99fff55515d55ffffffffffffffffffffffff55d51555ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
fff99999fff999999f9fffffd55d5555ffffffffffffffffffffffff5555d55dffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
99999f9999999f999999ffff55d551d5ffffffffffffffffffffffff5d155d55ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
99fff9f999fff9f9f9f99fff15555555ffffffffffffffffffffffff55555551f11fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ff9f9999ff9f99999f99fffff55d5515ffffffffffffffffffffffff5155d55ff171ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
99f9999999f99999ff9f9999fffffffffffffffffffffffffffffffffffffffff1771fffffffffffffffffffffffffffddd776ddddddddddffffffffffffffff
9f9999f99f9999f999f99899fffffffffffffffffff9fffffffffffffffffffff17771ffffffffffffffffffffffffffd576dc65d5577655ffffffffffffffff
99ff999999ff99999f9989f9ffffffffffffffff9999fffffffffffffffffffff177771fffffffffffffffffffffffffd76dccc5d576dc65ffffffffffffffff
99999f9999999f9999f88899f9ffff9ff9ffff9ff9f99ffffffffffffffffffff17711ffffffffffffffffffffffffffd66d11c5d76dccc5ffffffffffffffff
fff99999fff9999999998f99ff99f999ff99f9999f9fffffffffffffffffffffff11ffffffffffffffffffffffffffffd66d01c5d66d11c5ffffffffffffffff
99999f9999999f99fff89999999f99f9999f99f99999ffffffffffffffffffffffffffffffffffffffffffffffffffffd66d0c55d66d01c5ffffffffffffffff
99fff9f999fff9f999999f999f99f99f9f99f99ff9f99fffffffffffffffffffffffffffffffffffffffffffffffffffd56dd555d66d0c55ffffffffffffffff
ff9f9999ff9f999999fff9f9f99f99f9f99f99f99f99ffffffffffffffffffffffffffffffffffffffffffffffffffffd5555555d56dd555ffffffffffffffff
99f9999999f9999999f9999999f999999f99f9f9ffffffffffffffffff8dd8fffffffffff28882ffffffffffffffffffddddd776ddddddddffffffffffffffff
9f9999f99f9999f99f9999f99f9999f9f99f99f9fffffffffffffffff8d66d8fffffffff2828282fffffffffffffffffd55576dc65555555ffffffffffffffff
99ff999999ff999999ff999999ff99999f99f99ffffffffffffffffff8d66d8fffffffff2868682fffffffffffffffffd5576dccc5558055ffffffffffffffff
99999f9999999f9999999f9999999f99999f9999fffffffffffffffff8d66d8fffffffff2262622fffffffffffffffffd5566d11c5522055ffffffffffffffff
fff99999fff99999fff99999fff99999f9ffff9ffffffffffffffffff856658fffffffff2808082fffffffffffffffffd5566d01c5555055ffffffffffffffff
99999f9999999f9999999f9999999f99fffffffffffffffffffffffff886688fffffffff2888882fffffffffffffffffd5566d0cd5555055ffffffffffffffff
99fff9f999fff9f999fff9f999fff9f9fffffffffffffffffffffffff220022fffffffff00fff00fffffffffffffffffd5556dd5d5555555ffffffffffffffff
ff9f9999ff9f9999ff9f9999ff9f9999fffffffffffffffffffffffff00ff00fffffffffffffffffffffffffffffffffd5555555d5555555ffffffffffffffff
99f999999f99f9f99f99f9f9ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff5d555d5f5d555d5fffffffffffffffffffffffff
9f9999f9f99f99f9f99f99f9fffffffffff77fffffffffffffffffffffffffffffffffffffffffffffffffffd5155551d5155551ffffffffffffffffffffffff
99ff99999f99f99f9f99f99fffffffffff79ff7fffffffffffffffffffffffffffffffffffffffffffffffff155d55d5155d55d5ffffffffffffffffffffffff
99999f99999f9999999f9999fffffffff79f779fffffffffffffffffffffffffffffffffffffffffffffffff55d5155555d51555ffffffffffffffffffffffff
fff99999f9ffff9ff9ffff9ffffffffffff799ffffffffffffffffffffffffffffffffffffffffffffffffff5555d55d5555d55dffffffffffffffffffffffff
99999f99ffffffffffffffffffffffffff799fffffffffffffffffffffffffffffffffffffffffffffffffff5d155d555d155d55ffffffffffffffffffffffff
99fff9f9ffffffffffffffffffffffffff79ffffffffffffffffffffffffffffffffffffffffffffffffffff5555555155555551ffffffffffffffffffffffff
ff9f9999fffffffffffffffffffffffff7ffffffffffffffffffffffffffffffffffffffffffffffffffffff5155d55f5155d55fffffffffffffffffffffffff
fffffffffffffffffffffffffffffffffffffffffffffffffffffffff5666666ffffffffddddddddddd666ddddddddddffffffffffffffffffffffffffffffff
fffffffffffffffffffffffffff77ffffff77ffffffffffffffffffff0288dd2ffffffffd5555555d5766665d5555555ffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffff79ff7fff79ff7fffffffffffffffffff28d66dffffffffd5556555d5766665d5888885ffffffffffffffffffffffffffffffff
fffffffffffffffffffffffff79f779ff79f779ffffffffffffffffff066666dffffffffd5576655d5677725d5555555ffffffffffffffffffffffffffffffff
fffffffffffffffffffffffffff799fffff799ffffffffffffffffffff28d66dffffffffd55d7d55d566dd25d5522255ffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffff799fffff799ffffffffffffffffffff0288dd2ffffffffd55ddd55d566dd25d5555555ffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffff79ffffff79fffffffffffffffffffff5666666ffffffffd555d555d556dd55d5552555ffffffffffffffffffffffffffffffff
fffffffffffffffffffffffff7fffffff7ffffffffffffffffffffffffffffffffffffffd5555555d5555555d5522255ffffffffffffffffffffffffffffffff
fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff5d555d5ddd666ddddddddddddddddddfffffffffff22fffffffffffffffffff
fffffffffff77ffffff77ffffff77ffffff77fffffffffffffffffffffffffff1555515dd5766665d5555555d5522255ffffffffff2882ffffffffffffffffff
ffffffffff79ff7fff79ff7fff79ff7fff79ff7fffffffffffffffffffffffff5d55d551d5766665d5556555d5552555fffffffff522225fffffffffffffffff
fffffffff79f779ff79f779ff79f779ff79f779fffffffffffffffffffffffff55515d55d5677725d5576655d5555555fffffffff028820fffffffffffffffff
fffffffffff799fffff799fffff799fffff799ffffffffffffffffffffffffffd55d5555d566dd25d55d7d55d5522255ffffffffff2882ffffffffffffffffff
ffffffffff799fffff799fffff799fffff799fffffffffffffffffffffffffff55d551d5d566dd25d55ddd55d5555555fffffffff522225fffffffffffffffff
ffffffffff79ffffff79ffffff79ffffff79ffffffffffffffffffffffffffff15555555d556dd55d555d555d5888885fffffffff002200fffffffffffffffff
fffffffff7fffffff7fffffff7fffffff7fffffffffffffffffffffffffffffff55d5515d5555555d5555555d5555555ffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffddddddddd66dddddddd6fffdffffffffffffffffffffffffffffffff
fffffffffff77ffffff77ffffff77ffffff77fffffffffffffffffffffffffffffffffffd555555576665555551ffff1ffffffffffffffffffffffffffffffff
ffffffffff79ff7fff79ff7fff79ff7fff79ff7fffffffffffffffffffffffffffffffffd555555576665805555f4441ffffffffffffffffffffffffffffffff
fffffffff79f779ff79f779ff79f779ff79f779fffffffffffffffffffffffffffffffffd5555555177d22055d5ffff1ffffffffffffffffffffffffffffffff
fffffffffff799fffff799fffff799fffff799ffffffffffffffffffffffffffffffffffd5555555d1d55505555f1011ffffffffffffffffffffffffffffffff
ffffffffff799fffff799fffff799fffff799fffffffffffffffffffffffffffffffffffd55555556555550515df1001ffffffffffffffffffffffffffffffff
ffffffffff79ffffff79ffffff79ffffff79ffffffffffffffffffffffffffffffffffffd5555555d6d6d55555551005ffffffffffffffffffffffffffffffff
fffffffff7fffffff7fffffff7fffffff7ffffffffffffffffffffffffffffffffffffffd5555555d6d6d555d55d5555ffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffdddddddd55d555d5ffffffffffffffffffffffffffffffff
fffffffffff77ffffff77ffffff77ffffff77fffffffffffffffffffffffffffffffffffffffffffd555555515555155ffffffffffffffffffffffffffffffff
ffffffffff79ff7fff79ff7fff79ff7fff79ff7fffffffffffffffffffffffffffffffffffffffffd555555a5d55d555ffffffffffffffffffffffffffffffff
fffffffff79f779ff79f779ff79f779ff79f779fffffffffffffffffffffffffffffffffffffffffd5aaa99a55515d5dffffffffffffffffffffffffffffffff
fffffffffff799fffff799fffff799fffff799ffffffffffffffffffffffffffffffffffffffffffd5aaa55ad5555555ffffffffffffffffffffffffffffffff
ffffffffff799fffff799fffff799fffff799fffffffffffffffffffffffffffffffffffffffffffd5a1199a55d51555ffffffffffffffffffffffffffffffff
ffffffffff79ffffff79ffffff79ffffff79ffffffffffffffffffffffffffffffffffffffffffffd544445a15555515ffffffffffffffffffffffffffffffff
fffffffff7fffffff7fffffff7fffffff7ffffffffffffffffffffffffffffffffffffffffffffffd5151515555d5555ffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffddddddddddddddddffffffffffffffffffffffff
fffffffffff77ffffff77ffffffffffffff77fffffffffffffffffffffffffffffffffffffffffffffffffffd5555555d55555555dfffd5f5dfffd5fffffffff
ffffffffff79ff7fff79ff7fffffffffff79ff7fffffffffffffffffffffffffffffffffffffffffffffffffd5555555d5555555d5155551d5155551ffffffff
fffffffff79f779ff79f779ffffffffff79f779fffffffffffffffffffffffffffffffffffffffffffffffffd5555555d5555555155d55d5155d55d5ffffffff
fffffffffff799fffff799fffffffffffff799ffffffffffffffffffffffffffffffffffffffffffffffffffd5555555d555555555d5155555d51555ffffffff
ffffffffff799fffff799fffffffffffff799fffffffffffffffffffffffffffffffffffffffffffffffffffd5555555d55555555555d55d5555d55dffffffff
ffffffffff79ffffff79ffffffffffffff79ffffffffffffffffffffffffffffffffffffffffffffffffffffd5555555d55555555d155d555d155d55ffffffff
fffffffff7fffffff7fffffffffffffff7ffffffffffffffffffffffffffffffffffffffffffffffffffffffd5555555d55555555555555155555551ffffffff
fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff5d555d51d515555ffffffff
fffffffffffffffffffffffffffffffffff77fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff1555515d5155d55dffffffff
ffffffffffffffffffffffffffffffffff79ff7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff5d55d551555d5155ffffffff
fffffffffffffffffffffffffffffffff79f779fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff55515d55d5555d55ffffffff
fffffffffffffffffffffffffffffffffff799ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffd55d555555d155d5ffffffff
ffffffffffffffffffffffffffffffffff799fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff55d551d515555555ffffffff
ffffffffffffffffffffffffffffffffff79ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff15555555f51ffd5fffffffff
fffffffffffffffffffffffffffffffff7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff55d5515ffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
fffffffffffffffffffffffffff77ffffff77fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffff79ff7fff79ff7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
fffffffffffffffffffffffff79f779ff79f779fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
fffffffffffffffffffffffffff799fffff799ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffff799fffff799fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffff79ffffff79ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
fffffffffffffffffffffffff7fffffff7ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff77ffffff77ffffff77fff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff79ff7fff79ff7fff79ff7f
fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff79f779ff79f779ff79f779f
ff000000000000fffffff0000000000000fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff799fffff799fffff799ff
f0088088808080000ffff0880088008080ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff799fffff799fffff799fff
f0800080808080080ffff0080008000080ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff79ffffff79ffffff79ffff
f080f088808080000fffff080f08000800fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff7fffffff7fffffff7ffffff
f0800080008080080ffff0080008008000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
f0088080f00880000ff770888088808080f77ffffff77ffffffffffffffffffffffffffffffffffffffffffffff77ffffff77ffffff77ffffff77ffffff77fff
f0000000000000ffff79f000000000000079ff7fff79ff7fffffffffffffffffffffffffffffffffffffffffff79ff7fff79ff7fff79ff7fff79ff7fff79ff7f
f088808880888000079f70888080809ff79f779ff79f779ffffffffffffffffffffffffffffffffffffffffff79f779ff79f779ff79f779ff79f779ff79f779f
f0888080008880080ff79000800080fffff799fffff799fffffffffffffffffffffffffffffffffffffffffffff799fffff799fffff799fffff799fffff799ff
f0808088008080000f799088800800ffff799fffff799fffffffffffffffffffffffffffffffffffffffffffff799fffff799fffff799fffff799fffff799fff
f0808080008080080f79f080008000ffff79ffffff79ffffffffffffffffffffffffffffffffffffffffffffff79ffffff79ffffff79ffffff79ffffff79ffff
f08080888080800007fff088808080fff7fffffff7fffffffffffffffffffffffffffffffffffffffffffffff7fffffff7fffffff7fffffff7fffffff7ffffff
f0000000000000fffffff000000000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
f0888088800880000ff77080f08880fffff77ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff77ffffff77fff
f0800080808000080f79f0800080807fff79ff7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff79ff7fff79ff7f
f088008880888000079f70888080809ff79f779ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff79f779ff79f779f
f0800080000080080ff79080808080fffff799fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff799fffff799ff
f080f080f08800000f799088808880ffff799fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff799fffff799fff
f000f000f0000fffff79f000000000ffff79ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff79ffffff79ffff
fffffffff7fffffff7fffffff7fffffff7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff7fffffff7ffffff

__gff__
0000020202020400000000000000000000000200010000010101010101010101010101010000000000000101010000000001010101010000000000010000000001010101010102010101010101010100010101010101020101010101010101000101010102000000000000000000000001010101020000000000000000000000
0000000000000000000001010000000000000000000000000000010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000015151500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000151515
0000000000000000000000000000000000000000000000000000000000000000000000000000000000121200000000121200000000000000000000000000000015000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000015
1212000000000000001616161600003300000000000007080900000000000000000000000000000000001212121212120000000000000000000003030300000015000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000015
12121200000000161616163e0000000000000000000708080809000000000000000000000000000000000000000012000000000000000000000303030303030000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1212121212120000161616004214000000000007080808080809000000000000000000000000000000000000000000000000030303030303030303030303030000000012121212000000000000000000120012000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1212121200000032160000001414000000000708080808080b00000000000000000000000000000000000000000000000000000003000000000303030303030000001212121212121200000000000000121212000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
121212160000000000000002040000070a0a0c080808080b0000000000120000000000000000030303030303030303030000000000000000000003030303030000121212121212000000000000001212121212000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000120000000000441414000000000b08080808080b000000121212000000000000000003030303171819030303030303000000000000000003030303030012120000000000000000000000121212121200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00121212000016350014141400310000000205050000000000001200000000000000000000030303171b1b1b190303030303000000000000000000030303030012000000000000000000000000121212120000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1212121212000016000640140000000005031719050000000012120000000000000000000003031a1b1b1e1e1e1e03030303030000000000000000000303030000000000000000000012120000121212120000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1212121212001600000014140000000003171b1c030000000012000000000000000000000303031d1b1f0303030303030303030300000003030303030303000000000000000000000012121212121212000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00121200120016160002031313050500031d1b1f03000000000000000000000000000000030303031a030303030303030300000000000000030303030303030000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000001200001600060600000206000603030303000000000000000000001200000003030303031d1f0303030000000000000000000000000000000003030000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000001212000000000000000000000000060606060000000000000000000012000000030303030303030303030300000000000012000000000000000000030000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000341616000000000000000000000000000000000000121212000003030303030303030303030303000000120012121212121200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000016000012121200000000000000001200001212120000000003030303030303030303030303030000120000000000000000000000000000000000000000000000000000000000000000000000000000121212121212120000000000000000000000000000000000000000000000000000000000000000
0000121212120000000000001212121212120000000000001212121200000000000003030000000000000000000303030000001200120000000000000000000000000000000000000000000000000000000000000000000012121212121212120000000000000000000000000000000000000000000000000000000000000000
0012121212000016000000000000121212121212000000000000000000000000000003000000000000000000000003030300000000120000000000000000000000000000000000000000000000000000000000000000001212121212121212120000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000002050400000000000000000000000012000000000000000012121212121200000000030300000000001212000000000000000000000000000000000000000000000000000000000000001212121200121212000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000205050503030400000000000000000000000012121212000000000000001212121212120000000000000600000012121203000000060000000000000000000000000000000000000000001212121212120000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000217181819030303000000000000000000000000000012120000000000000000121212120000000000000000000000000003000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000005031d1b1b1b181819040000000000000000000000000000120000000000000000000000120000000000000000000000000003000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000020303031d1b1b1b1b1c030400000000000000000000000012000000000000000000000000000000000000000003000000000303000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000060303031a1b1b1f030606060000000000000000121212000000000000000000000000000000000000000003030303030300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000002031d1b1f03060000000606000000000012120000000000000000000006060606060600000000000000030303000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000060603030303000000000000060000000012000000030000000000000000000000000606000600060000000003030303000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000606000000000000060000000000000000030000000000000000000000000000000000000000030300000003000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000060000000000000000000000000000000000000000000000000000000000030303030300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000600000000000000000000000000000000000000000000000000000000030603030600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1500000000000000000000000000000000000000000000000006060600000000000000000000000000000000000000000000000000000000000000000000001500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1515150000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000015151500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
010c0004246152461524615246250c000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010200020c4100c210000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01030010184300c1700c1400c1150c3300c1700c1400c1150c3300c1700c1400c1150c3300c1700c1400c1150c1050c1050c1050c1050c1050c1050c1050c1050010500105001050010500105001050010500105
011000010015000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01030018184300c1700c1400c1150c3200c1400c1300c1250c3100c1100c1100c115184300c1700c1400c1150c3300c1400c1300c1250c3100c1100c1100c1150010500105001050010500105001050010500105
010800103061530600306153c605306153c605306150c0003c6103c615306153c605306153c605306150c0003c6050c6003c6050c6003c6050c6000c6000c6000c6000c6000c6000c6003c6050c6003c6050c000
010800203c615306003c6053c6053c6153c6053c6150c0003c6153c6053c605306003c615306003c6053c6053c6150c6003c6150c6003c6150c6000c6000c6000c6000c6000c6000c6003c6150c6003c6150c000
011406073c5303c5213c5113c5113c5113c5103c51000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500
0120000011b5011b5011b5011b4111b4011b4011b3111b3011b3011b2111b2011b2011b1111b1011b1011b1511b5011b5011b5011b4111b4011b4011b3111b3011b3011b2111b2011b2011b1111b1011b1011b15
012000000595005950059500594105940059400593105930059300592105920059200591105910059100591505950059500595005941059400594005931059300593005921059200592005911059100591005915
0120000011f3011f3011f2111f2011f1111f1011f1011f1013f3013f3013f2113f2013f1113f1013f1013f1014f3014f3014f2114f2014f1114f1014f1014f1013f3013f3013f2113f2013f1113f1013f1013f10
0120002018e2518e2518e2518e2518e2518e2518e2518e2518e2518e2518e2518e2518e2518e2518e2518e2518e2518e2518e2518e2518e2518e2518e2518e2518e2518e2518e2518e2518e2518e2518e2518e25
012000001d315243152931535315110052431529315353151d315243152731533315110052431527315333151d315243152c3153831511005243152c315383151d315243152b3153731511005243152b31537315
0120000014b5014b5014b5014b4114b4014b4014b3114b3014b3014b2114b2014b2014b1114b1014b1014b1514b5014b5014b5014b4114b4014b4014b3114b3014b3014b2114b2014b2014b1114b1014b1014b15
0120000020315273152c3153831514005273152c3153831520315273152a3153631514005273152a3153631520315273152f3153b31514005273152f3153b31520315273152e3153a31514005273152e3153a315
0120000014f3014f3014f2114f2014f1114f1014f1014f1016f3016f3016f2116f2016f1116f1016f1016f1017f3017f3017f2117f2017f1117f1017f1017f1016f3016f3016f2116f2016f1116f1016f1016f10
011000200c0430c04305155051550515511975051551197506155061550615511975031550315503155039750c0430c0430515505155051551810005155119750d1550d1550d155199750c1550c1550c15518100
011000001211112112121121211212112121121111112112121121211412115121141211511114121151211412115119751197511975119751193511975249001997519975199752490018975189751897518945
011000000655206552065520655206542065420654206542065320653206532065320652206522065220652206512065120651206512065120651206512065120651206512065150650206502065020650206502
0110000830d1530d1530d1530d1530d1030d1530d1530d1511d0518d0511d0518d0511d0518d0511d0518d0511d0518d0511d0518d0511d0518d0511d0518d0511d0518d0511d0518d0511d0518d0511d0518d05
011000001e4021e4020c4250c4250c4250c4250c425114050d4250d4250d425114050f4250f4250f425034051140511975114251142511425114251142511975124251242512425129750f4250f4250f4250f975
011000001e4021e4020c4250c4250c4250c4250c425114050d4250d4250d425114050f4250f4250f4250340511405119751142511425114251142511425119751442514425144251497513425134251342513975
0110000019b5019b4119b3119b2119b1019b1019b1019b1019b1019b1019b1019b1018b5018b1116b5016b1113b5013b5013b4113b4013b3113b3013b2113b2013b1013b1013b1013b1013b1013b1013b1013b10
0110000019f4019f3119f2119f1119f1119f1019f1019f1016f4016f2116f1116f1019f4019f2119f1119f101af401af211af111af111af111af101af101af1014f4014f2114f1114f1013f4013f2113f1113f10
011000002074220732207222071220712207122071220712207122071220712207121d7421d7321d7221d7121f7421f7321f7221f7121f7121f7121f7121f7121f7121f7121f7121f7121f7121f7121f7121f715
011000001100531d1530d1531d1530d1530d1530d1530d1530d10246051100518005110051800511005180051100531d1530d1531d1530d1530d1530d1530d1530d1024605110051800511005180051100518005
0110000011f4011f2111f1111f1012111121121211212112121121211211111121121211212114121151211412975119751297512975129750597505975181000d9750d9750d9750d9450c9750c9750c9750c945
011000001f7021f7021f7021f70506552065520655206552065420654206542065420653206532065320653206522065220652206522065120651206512065120651206512065120651206512065120651506502
0110000011f0011f0111f0118e0512121121221211112112121121211211111121121211212114121151211412915119141291512914129151800005955181000d9550d9550d955181000c9550c9550c95518000
011000001f7021f7021f7021f70506552065520655206552065420654206542065420653206532065320653206522065220652206522065120651206512065120651206512065120651206512065120651506502
011000200c0430c04308155081550815514975081551497509155091550915514975061550615506155069750c0430c04308155081550815514975081551b100101551015510155109750f1550f1550f1551b100
011000000c0430c04305155051550515511975051551197506155061550615511975031550315503155039750c0430c0430515505155051551810005155181000d1550d1550d155181000c1550c1550c15518100
0118002009a5009a5009a3009a3009c5009c5009c5009a5009a5009a3009a3009c5009c5009c5009c5009c5009c5009a5009a5009a3009a3009c5009c5009c5009c5009c5009c5009c5007a5007a5007a3007a30
0118000015b4015b1515b4015b1515b4015b151821615b4015b1515b4015b1515b4015b151821615b4015b102721615b4015b1515b4015b1515b4015b151821615b4015b1515b4015b1513b4013b1513b4013b15
011800203082531810308253181030825308103082031815308103182530810318253181030810318253181030810318253081031825308103182531810318103082531810308253181030825318203082031820
011800001c7041c7051170518700187041c705182161c7001870011705187001c700187001c216187001c7001b216187001b700187001c7001870021700182161c7041c705057050c70013210132101321213212
011800002db20155152db20155152db2015515182162db20155152db20155152db2015515182162db20155151b2162db20155152db20155152db2015515182162db2015515155142db202bb202bb122bb122bb15
0118000018a3018a3018a3018a3018c3018c301c72617a3017a3017a3017a3017c3017c301872617c3018c301c72618a3018a3018a3018a3018c3018c301c72717c3017c3018c3018c301aa301aa301aa301aa30
011800000cf500cf500cf500cf410cf310cf220cf120bf500bf500bf500bf410bf310bf210bf110bf110bf120bf1209f5009f5009f5009f4109f3109f2209f1205f5005f5005f5005f4105f3105f2105f1205f12
001400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010400000647307b710a6730cb711093313631159331ab510145302b510565307b310b9330e6211092315b410044300b410064302b4106923096210b92310b210041300b110061300b110191304611069130bb11
01020000104230db53306532db532b953276532495323b53206531f4531c9531b6531895316b531564313b4312943104430f9430db330b63309b3308923066230492303b230162300b2300933002150094300615
00040000049132ff13069132cf13039132af23049230592327f230693326f330493325f430694325f430494328f430794329f430a94326f530595324f530795329f2321f432cf632ff7330610306103061030615
010400002b72418765187641876518764187551875418755187541874518744187451873418735187341872518724187251870418705187041870518704187051870418705187041870518704187051870418705
010800002e1402e1222e115181002e1402e1203314033120331103311233115181001810018100181001810000100001000010000100001000010000100001000010000100001000010000100001000010000100
010200002cd732cd732cd732cd732cd632cd632cd632cd632bd132bd532ad532ad1329d5329d4328d4327d4326d132594324d432293320d331e9031cd331a93319d0317d231592313d131191300d0300d0300d03
000200000fd130452011d33107301ad43157501fd531b76326d601d76332d70157732ed600b7632ad600975323d50057431cd400673316d200a72310d10027130ad15007030dd0009d0006d0003d0001d0001d00
0101000030e71189753fe000000000000000000d97118e75000000000000000000003097118e7500e0018e0116e0100e0113e0111e0100e010de010ce0100e0109e0107e0100e0105e0104e0100e0101e0100e01
0102000033b6131863006102f86316b61006101eb531c851006101885116b430061013b4311841006100d8410cb430061009b3307831006100582104b230061001b1100811006140061507b0007b0006b0105b01
010100003063030620306303c6203c6303c6100060000600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600
0101000030f650000031f4531f0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__music__
00 21232262
01 20242223
00 20252223
00 20252223
00 20262223
02 21262223
00 21232263
00 21226263
00 08092262
01 08090a0b
00 080c0a0b
00 080c0a0b
00 0d0e0f0b
00 0d0e0f0b
00 10111213
00 10111213
00 10141213
00 10151213
00 16171819
00 101a1b13
00 101c1b13
00 100c0a13
00 1e0f0e13
00 16171819
00 1f0c0a13
00 16171819
02 08090a0b

