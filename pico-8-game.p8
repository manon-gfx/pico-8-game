pico-8 cartridge // http://www.pico-8.com
version 41
__lua__
--main
function _init()
 print("♥")
 -- init debug print
 prints={}

 roomtrans=""
 roomtranst=t()

 objs={}
 for i=0,#rooms do
  objs[i]={}
 end

 add(objs[0], --key
  {t="key0",x=8,y=16,sp=2,
   bb={x=0,y=3,w=8,h=3},sparks=true})
 add(objs[0], --lock
  {t="lock0",x=116,y=44,sp=3,
   bb={x=0,y=3,w=8,h=3}})
 add(objs[1],
  {t="acorn",x=64,y=64-16,sp=1,
   bb={x=0,y=0,w=8,h=8},sparks=true})

 inventory={}
 particles={}

 frog={
  x=8, --x position
  y=44, --y position
  r=0,
  sp=16, --sprite index
  bb={x=1,y=3,w=6,h=5},
  dx=0, --x speed
  dy=0, --y speed
  left=false, --facing left
  down=false, --facing down
 }

 -- create wasx variables
 wasbuttons()
end

function _update()
 if roomtrans == "" then
  froggo_movement()
  detect_roomtrans()
 else
  update_roomtrans()
 end

 -- froggo object collision
 a=trans_aabb(frog.bb,frog.x,frog.y)
 for o in all(objs[frog.r]) do
  b=trans_aabb(o.bb,o.x,o.y)
  if aabb_overlap(a,b) then
   event_frog_col_object(frog, o)
  end
 end

 -- update particles
 i=1
 while i<=#particles do
  p=particles[i]
  p.vx+=p.ax
  p.vy+=p.ay
  p.x+=p.vx
  p.y+=p.vy

  sbb={x=0,y=0,w=128,h=96}
  if type(p.sp)=="number" then
   bb={x=p.x,y=p.y,w=8,h=8}
  else
   bb={x=p.x,y=p.y,w=p.sp.w,h=p.sp.h}
  end

  if aabb_overlap(bb, sbb) then
   i+=1
  else
   deli(particles, i)
  end
 end

 -- clean up objects marked for
 -- deletion
 local olist=objs[frog.r]
 for i=#olist,1,-1 do
  local o=olist[i]
  if(o.delete) deli(olist,i)
 end
end

function draw_obj(o)
 if o.tcol!=nil then
  palt(15,false)
  palt(o.tcol,true)
 end

 -- draw item sprite
 spr(o.sp, o.x, o.y)

 if o.tcol!=nil then
  palt(15,true)
  palt(o.tcol,false)
 end

  -- draw sprakle effect
 if o.sparks then
  magic=flr(t()*8)%6
  if(o.sparki==nil)magic=0
  if magic==0 then
   if not o.sparki then
    o.sparkx=o.x+rnd(8)
    o.sparky=o.y+rnd(8)
    o.sparki=true
   end
   pset(o.sparkx,o.sparky,7)
  elseif magic==1 then
   circ(o.sparkx, o.sparky, 1, 6)
   o.sparki=false
  elseif magic==2 then
   local sx=o.sparkx
   local sy=o.sparky
   pset(sx-2, sy, 5)
   pset(sx+2, sy, 5)
   pset(sx, sy-2, 5)
   pset(sx, sy+2, 5)
   o.sparki=false
  end
 end
end

function draw_room_map(r)
 local rx=(r%8)*16
 local ry=(r\8)*12
 map(rx,ry, 0,0, 16,12)

 -- corner rounding
 round_wall_corners(r)
end
function draw_room_obj(r)

 -- draw objects in room
 foreach(objs[r], draw_obj)

 -- draw froggo
 draw_froggo()

 -- render particles
 for p in all(particles) do
  if p.r==r then
   if type(p.sp)=="number" then
    spr(p.sp,p.x,p.y)
   else
    sp=p.sp
    sspr(sp.x,sp.y,sp.w,sp.h,p.x,p.y)
   end
  end
 end
end

function _draw()
 cls()

 palt(0,false)
 palt(15,true)

 if roomtrans!="" then
  local c0x=0
  local c0y=0
  local c1x=0
  local c1y=0

  local f=(t()-roomtranst)/0.75
  local nr
  if roomtrans=="n" then
   nr=rooms[frog.r].n
   c0y=f*96
   c1y=f*96-96
  elseif roomtrans=="e" then
   nr=rooms[frog.r].e
   c0x=f*128
   c1x=f*128-128
  elseif roomtrans=="s" then
   f=1-f
   nr=rooms[frog.r].s
   c1y=f*96
   c0y=f*96-96
  else
   assert(roomtrans=="w")
   f=1-f
   nr=rooms[frog.r].w
   c1x=f*128
   c0x=f*128-128
  end

  camera(c0x,c0y)
  draw_room_map(frog.r)
  camera(c1x,c1y)
  draw_room_map(nr)

  camera(c0x,c0y)
  draw_room_obj(frog.r)
  camera(c1x,c1y)
  draw_room_obj(nr)

  camera()
 else
  draw_room_map(frog.r)
  draw_room_obj(frog.r)
 end

 draw_ui()

 -- update wasx variables
 wasbuttons()

 -- debugging prints
 if #prints>0 then
  camera(0,0)
  print("",0,0,7)
  foreach(prints, print)
 end
 prints={}
end

-->8
--player logic
vel=1.5

function froggo_movement()
 local dx=0
 local dy=0

 l=tonum(btn(⬅️))
 r=tonum(btn(➡️))
 u=tonum(btn(⬆️))
 d=tonum(btn(⬇️))

 if l+r+u+d==1 then
  if l!=0 then
   dx-=vel
   frog.left=true
   frog.down=false
  elseif r!=0 then
   dx+=vel
   frog.left=false
   frog.down=false
  elseif u!=0 then
   dy-=vel
   frog.down=false
  elseif d!=0 then
   dy+=vel
   frog.down=true
  end
 end

 local dx,dy=froggo_collision(dx,dy)

 frog.dx=dx
 frog.dy=dy

 frog.x+=dx
 frog.y+=dy
end

function froggo_collision(dx,dy)
 bb=trans_aabb(frog.bb,frog.x,frog.y)
 -- bounds l,r,t,b --
 bl=bb.x
 br=bb.x+bb.w-1
 bt=bb.y
 bb=bb.y+bb.h-1

 -- check collision --
 col=false
 if dx<0 then
  spr_t=mget2((bl+dx)\8,bt\8)
  spr_b=mget2((bl+dx)\8,bb\8)
  col=fget(spr_t,0) or fget(spr_b,0)
 elseif dx>0 then
  spr_t=mget2((br+dx)\8,bt\8)
  spr_b=mget2((br+dx)\8,bb\8)
  col=fget(spr_t,0) or fget(spr_b,0)
 end
 if dy<0 then
  spr_l=mget2(bl\8,(bt+dy)\8)
  spr_r=mget2(br\8,(bt+dy)\8)
  col=fget(spr_l,0) or fget(spr_r,0)
 elseif dy>0 then
  spr_l=mget2(bl\8,(bb+dy)\8)
  spr_r=mget2(br\8,(bb+dy)\8)
  col=fget(spr_l,0) or fget(spr_r,0)
 end

 -- resolve collision --
 if col then
  if dx<0 then
   dx=(bl\8)*8-bl
  elseif dx>0 then
   dx=((br+7)\8)*8-br-1
  end
  if dy<0 then
   dy=(bt\8)*8-bt
  elseif dy>0 then
   dy=((bb+7)\8)*8-bb-1
  end
 end

 return dx, dy
end

function event_frog_col_object(
 frog,
 obj)
 if obj.t=="key0" then
  sfx(0)
  obj.delete=true
  add(inventory, {t=obj.t,sp=obj.sp})
 elseif obj.t=="lock0" then
  keyi=find_in_inv("key0")
  if keyi!=nil then
   sfx(0)
   deli(inventory,keyi)
   -- the boy's soul
   mset(15,5,62)
   mset(15,6,61)

   obj.delete=true

   -- spawn particles
   add(particles,{
    x=obj.x,
    y=obj.y,
    r=frog.r,
    vx=-1.2,
    vy=-4,
    ax=0,
    ay=0.5,
    sp={x=32,y=0,w=8,h=4}
   })
   add(particles,{
    x=obj.x,
    y=obj.y+4,
    r=frog.r,
    vx=-1,
    vy=-3,
    ax=0,
    ay=0.5,
    sp={x=32,y=4,w=8,h=4}
   })
  end
 elseif obj.t=="acorn" then
  sfx(0)
  obj.delete=true
  add(inventory, {t=obj.t,sp=obj.sp})
 end
end

function draw_froggo()
 ptile=mget2((frog.x+4)\8,(frog.y+4)\8)
 pspr=frog.sp;
 pspr+=flr(t()*4)%2

 if frog.dx==0 then
  jump=false
 elseif (btn(⬅️) or btn(➡️))
  and jump==false then
  jump=true
  tjump=flr(t()*frog.dx*4)
 end

 sprlist={16,18,19,20}
 if jump then
  dtjump=flr(t()*frog.dx*4)-tjump
  pspr=sprlist[dtjump%4+1]
 end

 // froggo outline
 if fget(ptile,1) then
  for i=3,11,4 do pal(i,0) end
  spr(pspr,frog.x-1,frog.y,1,1,frog.left)
  spr(pspr,frog.x+1,frog.y,1,1,frog.left)
  spr(pspr,frog.x,frog.y-1,1,1,frog.left)
  spr(pspr,frog.x,frog.y+1,1,1,frog.left)

  pal()
  palt(0,false)
  palt(15,true)
 end

 spr(pspr,frog.x,frog.y,1,1,frog.left)
end

-->8
--user interface
function draw_ui()
 -- black background --
 rectfill(0, 96, 127, 127, 0)
 -- gray border --
 rect(0, 96, 127, 127, 6)

 print("♥♥♥", 4, 100, 8)

 -- item box --
 print("items", 105, 100, 7)
 rect(103, 98, 125, 125, 6)
 -- current time --
 local x={[0]=105,116}
 local y={[0]=106,116}

 palt(0,false)palt(15,true)
 for i=1,min(#inventory,4) do
  spr(inventory[i].sp, x[(i-1)%2], y[(i-1)\2])
 end
 palt()
end
-->8
--helpers

-- mget with room correction
function mget2(x,y)
 if x<0 or x>=16 or y<0 or y>=12 then
  return 0
 else
  x+=(frog.r%8)*16
  y+=(frog.r\8)*12
  return mget(x,y)
 end
end

-- update previous button state
function wasbuttons()
 wasl=btn(⬅️)
 wasr=btn(➡️)
 wasu=btn(⬆️)
 wasd=btn(⬇️)
 wasx=btn(❎)
 waso=btn(🅾️)
end

-- test overlap between bounding
-- boxes
function aabb_overlap(b0, b1)
 if b0.x<b1.x+b1.w and
    b0.x+b0.w>b1.x and
    b0.y<b1.y+b1.h and
    b0.y+b0.h>b1.y then
  return true
 else
  return false
 end
end
-- translate aabb
function trans_aabb(b, x, y)
  return{
   x=b.x+x,
   y=b.y+y,
   w=b.w,
   h=b.h
  }
end

-- inventory lookup
function find_in_inv(tag)
 for i=1,#inventory do
  if inventory[i].t==tag then
   return i
  end
 end
 -- return nil
end


-->8
--room layout

function init_r2()
 prints[1]="hello!"
end

-- after init_rx functions!
rooms={
 [0]={e=1,w=2}, // entry
 [1]={w=0}, // first room castle
 [2]={w=2,e=0,init=init_r2}, // repeating garden
}

function detect_roomtrans()
 local nr=nil
 local room=rooms[frog.r]
 if frog.x+frog.bb.x<0 then
  if room.w==nil then
   frog.x=-frog.bb.x
  else
   roomtrans="w"
   roomtranst=t()
   nr=rooms[frog.r].w
  end
  frog.dx=0
 elseif frog.x+frog.bb.x+frog.bb.w>128 then
  if room.e==nil then
   frog.x=128-frog.bb.x-frog.bb.w
  else
   roomtrans="e"
   roomtranst=t()
   nr=rooms[frog.r].e
  end
  frog.dx=0
 elseif frog.y+frog.bb.y<0 then
  if room.n==nil then
   frog.y=-frog.bb.y
  else
   roomtrans="n"
   roomtranst=t()
   nr=rooms[frog.r].n
  end
  frog.dy=0
 elseif frog.y+frog.bb.y+frog.bb.h>96 then
  if room.s==nil then
   frog.y=96-frog.bb.y-frog.bb.h
  else
   roomtrans="s"
   roomtranst=t()
   nr=rooms[frog.r].s
  end
  frog.dy=0
 end

 if nr!=nil then
  if(rooms[nr].init) rooms[nr].init()
 end
end

function update_roomtrans()
 local done=t()>=0.75+roomtranst
 if done then
  local room=rooms[frog.r]

  if roomtrans=="n" then
   frog.r=room.n
   frog.y=96-frog.bb.y-frog.bb.h
  elseif roomtrans=="e" then
   frog.r=room.e
   frog.x=-frog.bb.x
  elseif roomtrans=="s" then
   frog.r=room.s
   frog.y=-frog.bb.y
  else
   assert(roomtrans=="w")
   frog.r=room.w
   frog.x=128-frog.bb.x-frog.bb.w
  end

  roomtrans="" // finish transition
 end
end

function round_wall_corners(r)
 for dx=0,15 do
  for dy=0,15 do
   local sp=mget2(dx,dy)
   if sp==27 or sp==31 then
    local lsp=mget2(dx-1,dy)
    local rsp=mget2(dx+1,dy)
    local tsp=mget2(dx,dy-1)
    local bsp=mget2(dx,dy+1)

    -- wall corners
    if sp==31 then
     if lsp==11 then
      if tsp==11 then
       sspr(96,8,4,4,8*dx,8*dy)
      end
      if bsp==11 then
       sspr(96,12,4,4,8*dx,8*dy+4)
      end
     end
     if rsp==11 then
      if tsp==11 then
       sspr(100,8,4,4,8*dx+4,8*dy)
      end
      if bsp==11 then
       sspr(100,12,4,4,8*dx+4,8*dy+4)
      end
     end
    end

    -- carpet franjes
    if sp==27 then
     if lsp!=27 then
      sspr(80,8,4,8,8*dx,8*dy)
     end
     if rsp!=27 then
      sspr(84,8,4,8,8*dx+4,8*dy)
     end
     if tsp!=27 then
      sspr(80,0,8,4,8*dx,8*dy)
     end
     if bsp!=27 then
      sspr(80,4,8,4,8*dx,8*dy+4)
     end
    end
   end
  end
 end
end
__gfx__
00000000fff44fffffffffffffffffffff666fff0000000033333333ffffffff00000000000000009a9a9a9adddddddd33333333333333335444444433333333
0000000044444444ffffffffff666ffff6fff6ff0000000033bbb33bffffffff0000000000000000a9fffff9dddddddd3333333333bb3b334445444433b3333b
0070070044444444fffffffff6fff6fff6fff6ff000000003bbbbbb3ff44444f00000000000000009fffffffdddddddd3333333333bbbbb3444445543b3333b3
0007700049999994aaaffffff6fff6fff6fff6ff00000000bbb8bbbbf44000440000000000000000ffffffffdddddddd333333333bbb8bbb4544445433333333
00077000f999999fafaaaaaa555a555f555a555f00000000b8bbbb8b444044440000000000000000ffffffffdddddddd333333333bbbbb8b444454443333b33b
00700700f999999faaaffafa55a0a55f55a0a55f00ddd000bbbbbbbb444004440000000000000000afffffffdddddddd3333bb333bb8bbbb44544444333b3333
00000000f999999fffffffff55a0a55f55a0a55f0d5ddd00bbbbb8bbf440444400000000000000009afffffadddddddd33bbbbb333bbbbb3445444543b3333b3
00000000ff9999ffffffffff555a555f555a555ffdddddffb8b8bbbbff4000ff0000000000000000a9a9a9a9dddddddd3333333333333333444444443b333333
ffffffffffffffffffffff77ffffff77fffff77f000000003bbbbbb3ff4444ff00000000000000009affff9a88828888dffffffd660000000000006666566666
fffffffffffff77ffff77370fff77370ff77370f0000000043bbb8bbf444444f0000000000000000affffff988888888ffffffff604444444444440666566666
fffff77fff77370fff370333ff370333f370333f00000000343443b3f400044f00000000000000009ffffffa88822888ffffffff044444444444444055555555
ff77370ff370333fff3333bbff3333bbf3333bbf06600000334443334404444f0000000000000000affffff988882888ffffffff044444444444444066666656
f370333ff3333bbfff33bbbbff33bbbbf33bbbbf966006663334433b440044ff00000000000000009ffffffa88228888ffffffff044444a44a44444066666656
f3333bbff33bbbbfff33ff33333ff333f3fff3ff0d6666d033344333f40444ff0000000000000000affffff988888888ffffffff044444444444444066666656
f33bbbbff3fff3fff3fff3ff33fff33fff3fff3f00dddd003b3443b3f40004ff00000000000000009affff9a88888888ffffffff044444444444444055555555
f33ff33ff33ff33ff33ff33fffffffffff33ff33000900003b444433f4444fff0000000000000000a9aff9a988888288dffffffd044444444444444066566666
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000444444400000006600000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000444a44404444440600000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000444444404444444000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000444444404444444000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000444444404444444000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000444444404444444000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000044444406444a444000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000664444444000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000006600000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004444440600000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000444444060000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000660000000000000000
__gff__
0000000000000300000000000201000200000000000003000000000000010101000000000000000000000000000101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0f0f0f0f0f0f0f0f0f0f0f0f0f0f0d1f1f1f1f1f1f1f1f1f1f1f1f1f1f1f1f1f0f0f0f0f0f060f060f0f0f0f0f060f0f0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0f0f0d0d0f0f0d0d0f0f0d0d0f0f0d1f1f0b0b0b0b0b0b1f0b0b0b0b0b0b0b1f0f0d0d0f061606160f0d0d0f0616060f0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0f0f0d0d0f0f0d0d0f0f0d0d0f0f0d1f1f0b0b0b0b0b0b1f0b0b0b0b0b0b0b1f0f0d0d0f160f160f0f0d0d0f160f160f0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0f0f0f0f0f0f0f0f0f0f0f0f0f0f0d1f1f0b0b0b0b0b0b1f1f1f1f1f1f1f1f1f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0d0d0d0d0d0d0d0d0d0d0d0d0c0d0d1f1f0b0b0b0b0b0b0b0b0b0b0b0b0b0b1f0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e2e3e1b1b1b1b1b1b1b1b0b0b0b0b0b0b1f0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e2d3d1b1b1b1b1b1b1b1b0b0b0b0b0b0b1f0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d1f1f0b0b0b1f0b0b0b0b0b0b0b0b0b0b1f0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0f0f0f0f0f0f0f0f0f0f0f0f0f0f0d1f1f0b0b1f1f0b0b0b0b0b0b0b0b0b0b1f0f060f060f0f0f0f0f060f060f0f0f0f0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0f0f0d0d0f0f0d0d0f0f0d0d0f0f0d1f1f0b0b1f0b1f0b0b0b0b0b0b0b0b0b1f0f1606160f0d0d0f061606160f0d0d0f0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0f0f0d0d0f0f0d0d0f0f0d0d0f0f0d1f1f0b0b1f0b1f0b0b0b0b0b0b1f0b0b1f0f0f160f0f0d0d0f160f160f0f0d0d0f0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0f0f0f0f0f0f0f0f0f0f0f0f0f0f0d1f1f1f1f1f1f1f1f1f1f1f1f1f1f1f1f1f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
000100000000010050110501305015050150501605016050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000001500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
