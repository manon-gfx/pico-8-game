pico-8 cartridge // http://www.pico-8.com
version 41
__lua__
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

function _init()
 print("♥")

 items={} -- list of items on screen

 -- spawn key
 add(items, {
  t="key",
  x=8,
  y=16,
  sp=2,
  bb={x=0,y=3,w=8,h=3},
 })

 inventory={}

 frog={
  w=8, --width
  h=8, --height
  bb={x=1,y=1,w=6,h=7},
  x=8, --x position
  y=44, --y position
  sp=16, --sprite index
 }
end

function _update()
 froggo_movement()

 a=trans_aabb(frog.bb,frog.x,frog.y)
 for i=1,#items do
  it=items[i]
  b=trans_aabb(it.bb,it.x,it.y)
  if aabb_overlap(a,b) then
   -- collision!
  end
 end
end

function draw_item(i)
  -- draw item sprite
  spr(i.sp, i.x, i.y)

  -- draw sprakle effect
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
   i.sparki=false
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

function _draw()
 cls()
 map()

 -- draw items
 foreach(items, draw_item)

 -- draw froggo
 palt(0,false)
 palt(4,true)
 ptile=mget((frog.x+4)\8,(frog.y+4)\8)
 pspr=frog.sp;
 pspr+=flr(t()*4)%2

 if fget(ptile,1) then
  pspr+=16
 end
 spr(pspr,frog.x,frog.y)
 palt(0,true)
 palt(4,false)

 draw_ui()
end

-->8
vel=1

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
  elseif r!=0 then
   dx+=vel
  elseif u!=0 then
   dy-=vel
  elseif d!=0 then
   dy+=vel
  end
 end

 dx,dy=froggo_collision(dx,dy)

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
  spr_t=mget((bl+dx)\8,bt\8)
  spr_b=mget((bl+dx)\8,bb\8)
  col=fget(spr_t,0) or fget(spr_b,0)
 elseif dx>0 then
  spr_t=mget((br+dx)\8,bt\8)
  spr_b=mget((br+dx)\8,bb\8)
  col=fget(spr_t,0) or fget(spr_b,0)
 end
 if dy<0 then
  spr_l=mget(bl\8,(bt+dy)\8)
  spr_r=mget(br\8,(bt+dy)\8)
  col=fget(spr_l,0) or fget(spr_r,0)
 elseif dy>0 then
  spr_l=mget(bl\8,(bb+dy)\8)
  spr_r=mget(br\8,(bb+dy)\8)
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
-->8
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
 spr(2, 105, 106) -- slot 0
 spr(2, 116, 106) -- slot 1
 spr(2, 105, 116) -- slot 2
 spr(2, 116, 116) -- slot 3
end
__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000033333333333333335444444433333333
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003333333333bb3b334445444433b3333b
0070070000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003333333333bbbbb3444445543b3333b3
0007700000000000aaa00000000000000000000000000000000000000000000000000000000000000000000000000000333333333bbb8bbb4544445433333333
0007700000000000a0aaaaaa000000000000000000000000000000000000000000000000000000000000000000000000333333333bbbbb8b444454443333b33b
0070070000000000aaa00a0a0000000000000000000000000000000000000000000000000000000000000000000000003333bb333bb8bbbb44544444333b3333
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000033bbbbb333bbbbb3445444543b3333b3
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003333333333333333444444443b333333
44444444444444440000000000000000000000000000000000000000000000000000000000000000000000000000000000000000660000000000006666566666
44444774444444440000000000000000000000000000000000000000000000000000000000000000000000000000000000000000604444444444440666566666
44773704444447740000000000000000000000000000000000000000000000000000000000000000000000000000000000000000044444444444444055555555
43703334447737040000000000000000000000000000000000000000000000000000000000000000000000000000000000000000044444444444444066666656
43333bb4437033340000000000000000000000000000000000000000000000000000000000000000000000000000000000000000044444a44a44444066666656
433bbbb443333bb40000000000000000000000000000000000000000000000000000000000000000000000000000000000000000044444444444444066666656
43444344433bbbb40000000000000000000000000000000000000000000000000000000000000000000000000000000000000000044444444444444055555555
43344334433443340000000000000000000000000000000000000000000000000000000000000000000000000000000000000000044444444444444066566666
44444004444444440000000000000000000000000000000000000000000000000000000000000000000000000000000000000000044444400000006600000000
44000770444440040000000000000000000000000000000000000000000000000000000000000000000000000000000000000000044a44400444440600000000
40773700440007700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000044444400444444000000000
03703330407737000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000044444400444444000000000
03333bb0037033300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000044444400444444000000000
033bbbb003333bb00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000044444400444444000000000
03000304033bbbb0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004444406044a444000000000
03300330033003300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000660444444000000000
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
00000000000000000000000000000000000000000000000000000000000000000000000000000000eeeeeeee0000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000eeeeeeee0000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000eeeeeeee0000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000eeeeeeee0000000000000000000000000000000000000000
__gff__
0000000000000000000000000201000200000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0f0f0f0f0f0f0f0f0f0f0f0f0f0f0d1f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0f0f0d0d0f0f0d0d0f0f0d0d0f0f0d1f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0f0f0d0d0f0f0d0d0f0f0d0d0f0f0d1f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0f0f0f0f0f0f0f0f0f0f0f0f0f0f0d1f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0d0d0d0d0d0d0d0d0d0d0d0d0c0d0d1f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e2e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e2d00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d1f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0f0f0f0f0f0f0f0f0f0f0f0f0f0f0d1f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0f0f0d0d0f0f0d0d0f0f0d0d0f0f0d1f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0f0f0d0d0f0f0d0d0f0f0d0d0f0f0d1f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0f0f0f0f0f0f0f0f0f0f0f0f0f0f0d1f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
