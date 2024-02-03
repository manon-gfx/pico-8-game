pico-8 cartridge // http://www.pico-8.com
version 41
__lua__
--main
function _init()
 print("♥")

 items={} -- list of items on screen

 -- spawn key
 add(items, {
  t="key0",
  x=8,
  y=16,
  r=0,
  sp=2,
  bb={x=0,y=3,w=8,h=3},
  sparks=true,
  delete=false,
 })

 -- spawn lock
 add(items, {
  t="lock0",
  x=116,
  y=44,
  r=0,
  sp=3,
  bb={x=0,y=3,w=8,h=3},
  tcol=4,
  delete=false,
 })

 inventory={}
 particles={}

 frog={
  w=8, --width
  h=8, --height
  bb={x=1,y=3,w=6,h=5},
  x=8, --x position
  y=44, --y position
  r=0,
  sp=16, --sprite index
  dx=0, --x speed
  dy=0, --y speed
  left=false, --facing left
  down=false, --facing down
 }

 -- create wasx variables
 wasbuttons()

 -- init debug print
 prints={}
end

function _update()
 froggo_movement()

 room=rooms[frog.r]

 init_func=room.init
 if init_func!=nil then
  if last_init!=init_func then
   init_func()
   last_init=init_func
  end
 end

 if frog.x+frog.bb.x<0 then
  if room.w==nil then
   frog.x=-frog.bb.x
   frog.dx=0
  else
   sfx(0)
  end
 elseif frog.x+frog.bb.x+frog.bb.w>=128 then
  if room.e==nil then
   frog.x=128-frog.bb.x-frog.bb.w
   frog.dx=0
  else
   sfx(0)
  end
 elseif frog.y+frog.bb.y<0 then
  if room.n==nil then
   frog.y=-frog.bb.y
   frog.dy=0
  else
   sfx(0)
  end
 elseif frog.y+frog.bb.y+frog.bb.h>=96 then
  if room.s==nil then
   frog.y=96-frog.bb.y-frog.bb.h
   frog.dy=0
  else
   sfx(0)
  end
 end

 -- froggo item collision
 a=trans_aabb(frog.bb,frog.x,frog.y)
 for i in all(items) do
  b=trans_aabb(i.bb,i.x,i.y)
  if frog.r==i.r and aabb_overlap(a,b) then
   event_frog_col_item(frog, i)
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

 -- clean up items marked for
 -- deletion
 i=1
 while i<=#items do
  it=items[i]
  if it.delete then
   deli(items,i)
  else
   i+=1
  end
 end
end

function draw_item(i)
 if(i.r!=frog.r) return

 if i.tcol!=nil then
  palt(0,false)
  palt(i.tcol,true)
 end
 -- draw item sprite
 spr(i.sp, i.x, i.y)
 if i.tcol!=nil then
  palt(0,true)
  palt(i.tcol,false)
 end

  -- draw sprakle effect
 if i.sparks then
  magic=flr(t()*8)%6
  if magic==0 then
   if not i.sparki then
    i.sparkx=i.x+rnd(8)
    i.sparky=i.y+rnd(8)
    i.sparki=true
   end
   sx=i.sparkx
   sy=i.sparky
   circ(sx, sy, 0, 7)
  elseif magic==1 then
   sx=i.sparkx
   sy=i.sparky
   circ(sx, sy, 1, 6)
   i.sparki=false
  elseif magic==2 then
   sx=i.sparkx
   sy=i.sparky
   pset(sx-2, sy, 5)
   pset(sx+2, sy, 5)
   pset(sx, sy-2, 5)
   pset(sx, sy+2, 5)
   i.sparki=false
  end
 end
end

function _draw()
 cls()

 rx=(frog.r%8)*16
 ry=(frog.r\8)*12
 map(rx,ry, 0,0, 16,12)

 -- draw items
 foreach(items, draw_item)

 -- draw froggo
 palt(0,false)
 palt(4,true)
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
  palt(4,true)
 end

 spr(pspr,frog.x,frog.y,1,1,frog.left)

 palt()

 -- render particles
 for i=1,#particles do
  p=particles[i]
  if type(p.sp)=="number" then
   spr(p.sp,p.x,p.y)
  else
   sp=p.sp
   sspr(sp.x,sp.y,sp.w,sp.h,p.x,p.y)
  end
 end

 draw_ui()

 -- update wasx variables
 wasbuttons()

 -- debugging prints
 if #prints>0 then
  camera(0,0)
  print("",0,0,7)
  for p in all(prints) do
   print(p)
  end
 end
 prints={}
end

-->8
--player logic
vel=1.5

function froggo_movement()
 dx=0
 dy=0

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

 dx,dy=froggo_collision(dx,dy)

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

function event_frog_col_item(
 frog,
 item)
 if item.t=="key0" then
  sfx(0)
  item.delete=true
  add(inventory, {t=item.t,sp=item.sp})
 elseif item.t=="lock0" then
  keyi=find_in_inv("key0")
  if keyi!=nil then
   sfx(0)
   deli(inventory,keyi)
   -- the boy's soul
   mset(15,5,62)
   mset(15,6,61)

   item.delete=true

   -- spawn particles
   add(particles,{
    x=item.x,
    y=item.y,
    vx=-1.2,
    vy=-4,
    ax=0,
    ay=0.5,
    sp={x=32,y=0,w=8,h=4}
   })
   add(particles,{
    x=item.x,
    y=item.y+4,
    vx=-1,
    vy=-3,
    ax=0,
    ay=0.5,
    sp={x=32,y=4,w=8,h=4}
   })
  end
 end
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
 x={[0]=105,116}
 y={[0]=106,116}
 for i=1,min(#inventory,4) do
  spr(2, x[(i-1)\2], y[(i-1)\2])
 end
end
-->8
--helpers

-- mget with room correction
function mget2(x,y)
 x+=(frog.r%8)*16
 y+=(frog.r\8)*12
 return mget(x,y)
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
 [0]={e=1}, // entry
 [1]={w=0}, // first room castle
 [2]={w=2,e=0,init=init_r2}, // repeating garden
}

__gfx__
0000000000000000000000004444444400666000000000000000000000000000000000000000000000000000dddddddd33333333333333335444444433333333
000000000000000000000000446664440600060000000000000bb00000000000000000000000000000000000dddddddd3333333333bb3b334445444433b3333b
0070070000000000000000004644464406000600000000000bbbbbb000000000000000000000000000000000dddddddd3333333333bbbbb3444445543b3333b3
0007700000000000aaa00000464446440600060000000000bbb8bbbb00000000000000000000000000000000dddddddd333333333bbb8bbb4544445433333333
0007700000000000a0aaaaaa555a5554555a555000000000b8bbbb8b00000000000000000000000000000000dddddddd333333333bbbbb8b444454443333b33b
0070070000000000aaa00a0a55a0a55455a0a55000ddd000bbbbbbbb00000000000000000000000000000000dddddddd3333bb333bb8bbbb44544444333b3333
00000000000000000000000055a0a55455a0a5500d5ddd00bbbbb8bb00000000000000000000000000000000dddddddd33bbbbb333bbbbb3445444543b3333b3
000000000000000000000000555a5554555a5550fdddddffb8b8bbbb00000000000000000000000000000000dddddddd3333333333333333444444443b333333
4444444444444444444444774444447744444774000000000bbbbbb0000000000000000000000000000000008882888800000000660000000000006666566666
44444444444447744447737044477370447737040000000040bbb8b0000000000000000000000000000000008888888800000000604444444444440666566666
44444774447737044437033344370333437033340000000004044000000000000000000000000000000000008882288800000000044444444444444055555555
4477370443703334443333bb443333bb43333bb40660000000444000000000000000000000000000000000008888288800000000044444444444444066666656
4370333443333bb44433bbbb4433bbbb433bbbb49660066600044000000000000000000000000000000000008822888800000000044444a44a44444066666656
43333bb4433bbbb44433443333344333434443440d6666d000044000000000000000000000000000000000008888888800000000044444444444444066666656
433bbbb44344434443444344334443344434443400dddd0000044000000000000000000000000000000000008888888800000000044444444444444055555555
43344334433443344334433444444444443344330009000000444400000000000000000000000000000000008888828800000000044444444444444066566666
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
0000000000000000000000000201000200000000000000000000000000010101000000000000000000000000000101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0f0f0f0f0f0f0f0f0f0f0f0f0f0f0d1f1f1f1f1f1f1f1f1f1f1f1f1f1f1f1f1f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0f0f0d0d0f0f0d0d0f0f0d0d0f0f0d1f1f0b0b0b0b0b0b1f0b0b0b0b0b0b0b1f0f0d0d0f0f0d0d0f0f0d0d0f0f0d0d0f0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0f0f0d0d0f0f0d0d0f0f0d0d0f0f0d1f1f0b0b0b0b0b0b1f0b0b0b0b0b0b0b1f0f0d0d0f0f0d0d0f0f0d0d0f0f0d0d0f0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0f0f0f0f0f0f0f0f0f0f0f0f0f0f0d1f1f0b0b0b0b0b0b1f1f1f1f1f1f1f1f1f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0d0d0d0d0d0d0d0d0d0d0d0d0c0d0d1f1f0b0b0b0b0b0b0b0b0b0b0b0b0b0b1f0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e2e3e1b1b1b1b1b1b1b1b0b0b0b0b0b0b1f0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e2d3d1b1b1b1b1b1b1b1b0b0b0b0b0b0b1f0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d1f1f0b0b0b1f0b0b0b0b0b0b0b0b0b0b1f0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0f0f0f0f0f0f0f0f0f0f0f0f0f0f0d1f1f0b0b1f1f0b0b0b0b0b0b0b0b0b0b1f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0f0f0d0d0f0f0d0d0f0f0d0d0f0f0d1f1f0b0b1f0b1f0b0b0b0b0b0b0b0b0b1f0f0d0d0f0f0d0d0f0f0d0d0f0f0d0d0f0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0f0f0d0d0f0f0d0d0f0f0d0d0f0f0d1f1f0b0b1f0b1f0b0b0b0b0b0b1f0b0b1f0f0d0d0f0f0d0d0f0f0d0d0f0f0d0d0f0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0f0f0f0f0f0f0f0f0f0f0f0f0f0f0d1f1f1f1f1f1f1f1f1f1f1f1f1f1f1f1f1f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
000100000000010050110501305015050150501605016050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000001500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
