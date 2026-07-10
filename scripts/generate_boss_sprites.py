from PIL import Image
import os

OUTPUT_DIR = r"""c:\Users\justf\OneDrive\바탕 화면\코딩\0.soul-dungeon\assets\pixel_art\bosses"""

def px(img, x, y, color):
    if 0 <= x < 32 and 0 <= y < 32:
        img.putpixel((x, y), color)

def fill_rect(img, x1, y1, x2, y2, color):
    for yy in range(y1, y2 + 1):
        for xx in range(x1, x2 + 1):
            px(img, xx, yy, color)

def gen_sewer_croc():
    img = Image.new("RGBA", (32, 32), (0,0,0,0))
    dk_green=(30,80,20,255); green=(50,130,40,255); lt_green=(80,160,60,255)
    belly=(120,140,80,255); eye_y=(220,200,40,255); eye_p=(20,10,5,255)
    teeth=(220,220,200,255); mouth=(100,30,30,255); water=(40,70,90,180)
    for sx in [13,15,17]: px(img,sx,3,dk_green)
    for sx in [14,16]: px(img,sx,2,dk_green)
    fill_rect(img,17,4,24,5,dk_green); fill_rect(img,18,4,23,4,green)
    fill_rect(img,12,6,24,8,green); fill_rect(img,13,6,23,7,lt_green)
    px(img,14,5,eye_y); px(img,15,5,eye_p); px(img,19,5,eye_y); px(img,20,5,eye_p)
    fill_rect(img,13,4,16,4,dk_green); fill_rect(img,18,4,21,4,dk_green)
    fill_rect(img,14,9,25,10,mouth)
    for tx in range(15,25,2): px(img,tx,9,teeth)
    for tx in range(16,25,2): px(img,tx,11,teeth)
    fill_rect(img,14,11,24,12,green); fill_rect(img,16,11,23,11,dk_green)
    fill_rect(img,11,12,19,20,green); fill_rect(img,12,13,18,19,lt_green)
    fill_rect(img,13,14,17,19,belly)
    for sy in range(13,20,2): px(img,11,sy,dk_green); px(img,19,sy,dk_green)
    fill_rect(img,8,13,10,17,green); fill_rect(img,7,17,9,18,green)
    for x in [7,8,9]: px(img,x,19,dk_green)
    fill_rect(img,20,13,22,17,green); fill_rect(img,21,17,23,18,green)
    for x in [21,22,23]: px(img,x,19,dk_green)
    fill_rect(img,11,21,14,25,green); fill_rect(img,16,21,19,25,green)
    fill_rect(img,10,26,14,27,dk_green); fill_rect(img,16,26,20,27,dk_green)
    for x in [10,12,17,19]: px(img,x,28,dk_green)
    fill_rect(img,7,19,10,20,green); fill_rect(img,5,20,8,21,green)
    fill_rect(img,4,21,6,22,dk_green); fill_rect(img,3,22,5,23,dk_green)
    px(img,3,24,dk_green); px(img,4,24,dk_green)
    for wx in range(6,26):
        if wx%3!=0: px(img,wx,29,water)
        if wx%4==0: px(img,wx,28,water)
    return img

def gen_rat_monarch():
    img = Image.new("RGBA", (32,32), (0,0,0,0))
    brown=(120,80,40,255); dk_b=(80,50,25,255); lt_b=(160,120,70,255)
    fur=(140,130,120,255); pink=(200,140,140,255); eye_r=(200,40,40,255)
    gold=(220,190,50,255); dk_g=(180,150,30,255); gem=(180,30,30,255)
    cape=(140,20,30,255); cape_dk=(100,15,20,255); teeth=(230,220,200,255)
    fill_rect(img,11,4,20,5,gold)
    for cx in [11,13,15,17,19]: px(img,cx,3,gold); px(img,cx,2,dk_g)
    px(img,15,4,gem); px(img,16,4,gem)
    fill_rect(img,8,2,10,5,brown); px(img,9,3,pink); px(img,9,4,pink)
    fill_rect(img,21,2,23,5,brown); px(img,22,3,pink); px(img,22,4,pink)
    fill_rect(img,10,5,21,10,brown); fill_rect(img,11,6,20,9,fur)
    px(img,12,7,eye_r); px(img,13,7,eye_r); px(img,18,7,eye_r); px(img,19,7,eye_r)
    fill_rect(img,14,8,17,9,lt_b); px(img,15,8,pink); px(img,16,8,pink)
    px(img,10,8,dk_b); px(img,9,7,dk_b); px(img,9,9,dk_b)
    px(img,21,8,dk_b); px(img,22,7,dk_b); px(img,22,9,dk_b)
    px(img,15,10,teeth); px(img,16,10,teeth)
    fill_rect(img,9,11,22,20,brown); fill_rect(img,10,12,21,19,fur)
    fill_rect(img,12,14,19,18,lt_b)
    fill_rect(img,7,11,9,22,cape); fill_rect(img,22,11,24,22,cape)
    fill_rect(img,7,11,7,22,cape_dk); fill_rect(img,24,11,24,22,cape_dk)
    for cx in range(7,25):
        if cx%2==0: px(img,cx,23,cape)
    fill_rect(img,7,13,9,17,brown); fill_rect(img,22,13,24,17,brown)
    fill_rect(img,24,8,25,17,dk_g); fill_rect(img,23,7,26,8,gold)
    px(img,24,6,gem); px(img,25,6,gem)
    fill_rect(img,11,21,14,25,brown); fill_rect(img,17,21,20,25,brown)
    fill_rect(img,10,26,15,27,dk_b); fill_rect(img,16,26,21,27,dk_b)
    for x in [10,13,17,20]: px(img,x,28,dk_b)
    fill_rect(img,13,22,14,23,pink); fill_rect(img,12,24,13,25,pink)
    px(img,11,26,pink); px(img,10,27,pink)
    return img

def gen_warden_chief():
    img = Image.new("RGBA", (32,32), (0,0,0,0))
    a_dk=(40,40,50,255); a=(70,70,85,255); a_lt=(100,100,115,255)
    eye=(200,160,40,255); ch=(150,150,140,255); key=(200,180,60,255)
    belt=(100,60,30,255); boot=(50,35,20,255); cape=(30,25,40,255)
    blood=(120,20,20,255)
    fill_rect(img,15,1,16,2,a_dk); px(img,15,0,a)
    fill_rect(img,12,2,19,3,a_dk); fill_rect(img,11,3,20,8,a)
    fill_rect(img,12,4,19,7,a_lt); fill_rect(img,13,6,18,6,a_dk)
    px(img,14,6,eye); px(img,17,6,eye)
    fill_rect(img,7,9,11,12,a); fill_rect(img,8,10,10,11,a_lt)
    fill_rect(img,20,9,24,12,a); fill_rect(img,21,10,23,11,a_lt)
    px(img,7,8,a_dk); px(img,24,8,a_dk)
    fill_rect(img,11,9,20,18,a); fill_rect(img,12,10,19,17,a_lt)
    fill_rect(img,14,11,17,14,a)
    px(img,15,12,a_dk); px(img,16,12,a_dk); px(img,15,13,a_dk); px(img,16,13,a_dk)
    fill_rect(img,11,18,20,19,belt)
    px(img,12,20,key); px(img,12,21,key); px(img,13,21,key)
    px(img,19,20,key); px(img,19,21,key); px(img,20,21,key); px(img,14,20,ch)
    fill_rect(img,9,10,10,22,cape); fill_rect(img,21,10,22,22,cape)
    fill_rect(img,8,13,10,19,a); fill_rect(img,21,13,23,19,a)
    fill_rect(img,7,19,10,21,a_dk); fill_rect(img,21,19,24,21,a_dk)
    fill_rect(img,24,10,25,21,ch); fill_rect(img,23,7,26,10,a_dk)
    fill_rect(img,24,6,25,7,a)
    px(img,23,6,a_dk); px(img,26,6,a_dk); px(img,23,10,a_dk); px(img,26,10,a_dk)
    for p in [(6,20),(5,19),(4,18),(3,17),(4,16),(5,15)]: px(img,p[0],p[1],ch)
    fill_rect(img,12,20,15,25,a); fill_rect(img,16,20,19,25,a)
    fill_rect(img,11,26,15,28,boot); fill_rect(img,16,26,20,28,boot)
    px(img,11,27,a_dk); px(img,20,27,a_dk)
    px(img,13,17,blood); px(img,18,15,blood); px(img,8,20,blood)
    return img

def gen_ghost_convict():
    img = Image.new("RGBA", (32,32), (0,0,0,0))
    gb=(140,170,200,160); gl=(180,210,240,180); gd=(80,100,140,140)
    gc=(200,220,255,200); eg=(180,240,255,255); ep=(100,200,255,255)
    ch=(120,120,130,220); cl=(160,160,170,220); mv=(40,50,80,200)
    noose=(100,80,60,200); aura=(100,150,220,60); stripe=(60,70,100,150)
    for ax in range(8,24):
        for ay in [3,29]:
            if ax%2==0: px(img,ax,ay,aura)
    for ay in range(5,28):
        if ay%3==0: px(img,7,ay,aura); px(img,24,ay,aura)
    fill_rect(img,11,4,20,10,gb); fill_rect(img,12,5,19,9,gl)
    fill_rect(img,13,6,18,8,gc)
    fill_rect(img,12,6,14,8,mv); fill_rect(img,17,6,19,8,mv)
    px(img,13,7,eg); px(img,18,7,eg); px(img,13,6,ep); px(img,18,6,ep)
    fill_rect(img,14,9,17,11,mv); px(img,15,9,gd); px(img,16,9,gd)
    fill_rect(img,13,10,18,11,noose)
    px(img,15,3,noose); px(img,15,2,noose); px(img,16,1,noose)
    fill_rect(img,10,11,21,20,gb); fill_rect(img,11,12,20,19,gl)
    for sy in range(12,20,2): fill_rect(img,11,sy,20,sy,stripe)
    for cy in range(8,24,2):
        px(img,9,cy,ch); px(img,10,min(cy+1,31),cl)
        px(img,22,cy,ch); px(img,21,min(cy+1,31),cl)
    for cx in range(11,21):
        px(img,cx,14,ch if cx%2==0 else cl)
    fill_rect(img,7,15,9,16,ch); fill_rect(img,22,15,24,16,ch)
    fill_rect(img,8,12,10,18,gb); fill_rect(img,21,12,23,18,gb)
    fill_rect(img,6,18,9,20,gl); fill_rect(img,22,18,25,20,gl)
    fill_rect(img,11,20,20,22,gb)
    for wx in range(10,22):
        al=140-(abs(wx-15)*15)
        if al>0: px(img,wx,23,(140,170,200,al)); px(img,wx,24,(140,170,200,max(0,al-40)))
    for x,y,al in [(12,25,60),(15,26,50),(19,25,60),(11,26,40),(20,26,40)]:
        px(img,x,y,(140,170,200,al))
    px(img,8,21,ch); px(img,8,22,ch); px(img,8,23,cl)
    px(img,23,21,ch); px(img,23,22,ch); px(img,23,23,cl)
    return img

def gen_crystal_golem():
    img = Image.new("RGBA", (32,32), (0,0,0,0))
    rock=(80,80,90,255); rdk=(50,50,60,255); rlt=(110,110,120,255)
    cc=(80,220,240,255); clt=(160,240,255,255); cdk=(40,140,180,255)
    cg=(120,255,255,200); eg=(100,255,255,255); core=(200,255,255,230)
    crack=(60,200,220,200)
    for x,y,c in [(10,3,cc),(11,4,clt),(10,4,cc),(9,2,cdk),(10,2,cc),
                   (21,3,cc),(20,4,clt),(21,4,cc),(22,2,cdk),(21,2,cc),
                   (15,3,clt),(16,3,clt),(15,2,cc),(16,2,cc),(15,1,cdk)]:
        px(img,x,y,c)
    fill_rect(img,11,5,20,10,rock); fill_rect(img,12,6,19,9,rlt)
    fill_rect(img,13,7,14,8,eg); fill_rect(img,17,7,18,8,eg)
    for mx in range(13,19): px(img,mx,9 if mx%2==0 else 10,crack)
    fill_rect(img,8,10,23,22,rock); fill_rect(img,9,11,22,21,rlt)
    fill_rect(img,10,12,21,20,rock)
    fill_rect(img,14,13,17,16,cc); fill_rect(img,15,14,16,15,core)
    px(img,13,14,cg); px(img,18,14,cg); px(img,15,12,cg); px(img,16,17,cg)
    for x,y in [(11,14),(12,15),(11,16),(20,13),(21,14),(20,15)]: px(img,x,y,crack)
    fill_rect(img,4,11,8,14,rock); fill_rect(img,3,14,7,18,rlt)
    fill_rect(img,2,18,6,21,rock)
    px(img,5,12,cc); px(img,4,11,clt); px(img,3,16,cc)
    fill_rect(img,23,11,27,14,rock); fill_rect(img,24,14,28,18,rlt)
    fill_rect(img,25,18,29,21,rock)
    px(img,26,12,cc); px(img,27,11,clt); px(img,28,16,cc)
    fill_rect(img,1,21,6,23,rdk); fill_rect(img,25,21,30,23,rdk)
    fill_rect(img,9,22,14,27,rock); fill_rect(img,17,22,22,27,rock)
    fill_rect(img,8,28,15,29,rdk); fill_rect(img,16,28,23,29,rdk)
    px(img,7,9,cc); px(img,6,8,clt); px(img,24,9,cc); px(img,25,8,clt)
    px(img,6,30,cdk); px(img,25,30,cdk)
    return img

def gen_mana_overload():
    img = Image.new("RGBA", (32,32), (0,0,0,0))
    p=(140,50,200,255); dp=(80,20,130,255); m=(200,50,180,255)
    lp=(180,120,240,255); ec=(255,200,255,255); em=(220,140,255,230)
    eo=(180,80,255,160); sp=(255,255,200,255); ew=(255,220,255,255)
    vd=(30,10,50,255); u=(255,100,200,200)
    for ax,ay in [(15,1),(10,2),(21,2),(8,5),(23,5),(6,10),(25,10),
                  (5,16),(26,16),(7,22),(24,22),(10,27),(21,27),(15,30)]:
        px(img,ax,ay,eo)
    fill_rect(img,12,3,19,8,p); fill_rect(img,13,4,18,7,lp)
    fill_rect(img,14,5,17,6,em)
    px(img,13,5,ew); px(img,14,5,sp); px(img,17,5,ew); px(img,18,5,sp)
    fill_rect(img,14,7,17,8,vd); px(img,15,7,m); px(img,16,7,m)
    px(img,11,2,m); px(img,10,1,u); px(img,20,2,m); px(img,21,1,u)
    px(img,15,2,sp); px(img,16,2,sp)
    fill_rect(img,10,9,21,19,p); fill_rect(img,11,10,20,18,dp)
    fill_rect(img,13,12,18,16,em); fill_rect(img,14,13,17,15,ec)
    px(img,15,14,sp); px(img,16,14,sp)
    for x,y in [(15,11),(16,10),(15,17),(16,18),(12,14),(11,13),(19,14),(20,13)]:
        px(img,x,y,u)
    fill_rect(img,7,10,10,13,p); fill_rect(img,5,13,8,16,lp)
    fill_rect(img,3,16,6,18,m)
    px(img,2,17,sp); px(img,1,16,sp); px(img,2,19,u); px(img,4,19,sp)
    fill_rect(img,21,10,24,13,p); fill_rect(img,23,13,26,16,lp)
    fill_rect(img,25,16,28,18,m)
    px(img,29,17,sp); px(img,30,16,sp); px(img,29,19,u); px(img,27,19,sp)
    fill_rect(img,11,19,15,23,p); fill_rect(img,16,19,20,23,p)
    for lx in range(10,22):
        al=200-abs(lx-15)*20
        if al>0: px(img,lx,24,(140,50,200,al)); px(img,lx,25,(140,50,200,max(0,al-50)))
    for dx in [11,14,17,20]:
        px(img,dx,26,(180,80,255,80)); px(img,dx,27,(180,80,255,40))
    for x,y in [(8,3),(23,4),(5,8),(26,7),(3,14),(28,13),(4,21),(27,20),(9,26),(22,25)]:
        px(img,x,y,sp)
    return img

def gen_arch_demon():
    img = Image.new("RGBA", (32,32), (0,0,0,0))
    r=(180,30,30,255); dr=(120,15,15,255); lr=(220,60,50,255)
    skin=(200,80,60,255); horn=(60,40,30,255); hl=(90,60,40,255)
    ef=(255,200,40,255); ec=(255,100,20,255); fire=(255,160,40,200)
    fd=(200,80,20,200); wd=(50,10,10,255); w=(80,20,20,255)
    wm=(100,30,25,200); teeth=(240,230,200,255); bk=(20,10,10,255)
    gold=(200,170,50,255)
    for x,y,c in [(9,0,horn),(10,1,horn),(10,2,hl),(11,3,hl),(11,4,horn),
                   (22,0,horn),(21,1,horn),(21,2,hl),(20,3,hl),(20,4,horn)]:
        px(img,x,y,c)
    fill_rect(img,12,4,19,9,r); fill_rect(img,13,5,18,8,dr)
    fill_rect(img,12,5,19,5,dr)
    fill_rect(img,13,6,14,7,ef); px(img,13,6,ec)
    fill_rect(img,17,6,18,7,ef); px(img,18,6,ec)
    fill_rect(img,14,8,17,9,bk)
    px(img,14,8,teeth); px(img,17,8,teeth); px(img,15,9,teeth); px(img,16,9,teeth)
    fill_rect(img,10,10,21,20,dr); fill_rect(img,11,11,20,19,r)
    fill_rect(img,12,12,19,18,skin)
    fill_rect(img,13,12,15,14,lr); fill_rect(img,16,12,18,14,lr)
    for ay in range(15,19,2): px(img,15,ay,dr); px(img,16,ay,dr)
    fill_rect(img,11,19,20,20,gold); px(img,15,20,ef); px(img,16,20,ef)
    fill_rect(img,2,6,10,8,wd); fill_rect(img,1,8,9,12,w)
    fill_rect(img,2,12,8,16,wm)
    for x in [3,5,7]: px(img,x,7,w)
    for wy in range(8,16):
        px(img,2,wy,wd)
        if wy<14: px(img,5,wy,wd)
    fill_rect(img,21,6,29,8,wd); fill_rect(img,22,8,30,12,w)
    fill_rect(img,23,12,29,16,wm)
    for x in [24,26,28]: px(img,x,7,w)
    for wy in range(8,16):
        px(img,29,wy,wd)
        if wy<14: px(img,26,wy,wd)
    fill_rect(img,7,11,10,17,dr); fill_rect(img,8,12,9,16,r)
    fill_rect(img,21,11,24,17,dr); fill_rect(img,22,12,23,16,r)
    px(img,6,17,bk); px(img,7,18,bk); px(img,8,18,dr)
    px(img,24,17,bk); px(img,25,18,bk); px(img,23,18,dr)
    fill_rect(img,25,12,26,18,horn)
    for x,y,c in [(25,11,fire),(26,11,fire),(25,10,fd),(26,10,fd),(27,10,fire),(25,9,fire)]:
        px(img,x,y,c)
    fill_rect(img,11,21,14,26,dr); fill_rect(img,17,21,20,26,dr)
    fill_rect(img,10,27,14,28,bk); fill_rect(img,17,27,21,28,bk)
    for x,y,c in [(14,22,dr),(13,23,dr),(12,24,r),(11,25,r),(10,26,dr),(9,26,fire),(9,27,fd)]:
        px(img,x,y,c)
    for fx in range(9,23):
        if fx%2==0: px(img,fx,29,fd)
        if fx%3==0: px(img,fx,28,fire)
    return img

def gen_corrupt_high_priest():
    img = Image.new("RGBA", (32,32), (0,0,0,0))
    rdk=(40,15,60,255); ro=(70,25,100,255)
    skin=(170,160,140,255); sdk=(130,120,100,255)
    ev=(180,40,220,255); eg=(220,100,255,200)
    sw=(80,60,40,255); sg=(200,50,255,255); sgl=(160,80,220,150)
    gold=(200,180,60,255); da=(60,20,80,100); sym=(180,30,200,255)
    teeth=(200,200,180,255); hi=(20,5,30,255); cv=(100,30,120,200)
    for x,y in [(8,2),(23,3),(5,8),(26,9),(3,15),(28,14),(5,22),(26,21),(8,28),(23,27)]:
        px(img,x,y,da)
    fill_rect(img,10,2,21,4,rdk); fill_rect(img,9,4,22,9,ro)
    fill_rect(img,11,5,20,8,hi)
    fill_rect(img,12,5,19,9,sdk); fill_rect(img,13,6,18,8,skin)
    px(img,13,6,ev); px(img,14,6,eg); px(img,17,6,ev); px(img,18,6,eg)
    px(img,12,7,cv); px(img,19,7,cv); px(img,14,8,cv); px(img,17,8,cv)
    fill_rect(img,14,8,17,8,hi); px(img,14,8,teeth); px(img,17,8,teeth)
    fill_rect(img,9,9,22,26,ro); fill_rect(img,10,10,21,25,rdk)
    fill_rect(img,13,10,18,25,ro)
    for x,y in [(15,12),(16,12),(15,13),(16,13),(14,13),(17,13),(15,14),(16,14),(15,15),(16,15)]:
        px(img,x,y,sym)
    for gy in range(10,26): px(img,13,gy,gold); px(img,18,gy,gold)
    fill_rect(img,9,9,22,9,gold)
    fill_rect(img,7,9,10,12,ro); fill_rect(img,21,9,24,12,ro)
    px(img,7,9,gold); px(img,8,9,gold); px(img,23,9,gold); px(img,24,9,gold)
    fill_rect(img,6,12,9,18,rdk); fill_rect(img,22,12,25,18,rdk)
    fill_rect(img,5,18,8,19,sdk); fill_rect(img,23,18,26,19,sdk)
    px(img,6,18,cv); px(img,24,18,cv)
    fill_rect(img,4,4,5,20,sw)
    fill_rect(img,3,2,6,4,gold); fill_rect(img,4,2,5,3,sg)
    px(img,4,1,sgl); px(img,5,1,sgl); px(img,3,3,sgl); px(img,6,3,sgl)
    fill_rect(img,24,16,27,20,rdk); fill_rect(img,25,17,26,19,sym)
    px(img,25,18,ev)
    fill_rect(img,8,26,23,27,ro)
    for rx in range(8,24):
        if rx%2==0: px(img,rx,28,rdk)
        if rx%3==0: px(img,rx,29,rdk)
    px(img,10,29,da); px(img,15,30,da); px(img,21,29,da)
    return img

def gen_void_sovereign():
    img = Image.new("RGBA", (32,32), (0,0,0,0))
    vb=(10,5,20,255); vd=(25,10,45,255); vp=(60,20,90,255)
    ve=(90,40,130,255); co=(120,80,200,200)
    swh=(220,220,255,255); sb=(150,180,255,255)
    ev=(180,0,255,255); ei=(255,100,255,255)
    cvoid=(80,0,120,255); cg=(200,0,255,255)
    re=(100,50,160,255); npk=(200,60,150,150); nbl=(60,80,200,150)
    for x,y in [(3,1),(28,2),(1,8),(30,7),(2,15),(29,14),(4,23),(27,22),(1,28),(30,27)]:
        px(img,x,y,swh)
    for x,y in [(5,4),(26,5),(3,12),(28,11),(6,20),(25,19)]:
        px(img,x,y,npk); px(img,x+1,y,nbl)
    fill_rect(img,11,1,20,2,cvoid)
    for cx in [11,13,15,17,19]: px(img,cx,0,cvoid)
    px(img,15,0,cg); px(img,11,1,cg); px(img,20,1,cg)
    fill_rect(img,11,3,20,9,vb); fill_rect(img,12,4,19,8,vd)
    px(img,13,5,ev); px(img,14,5,ei); px(img,17,5,ev); px(img,18,5,ei)
    px(img,15,4,ei); px(img,16,4,ei); px(img,14,7,ev); px(img,17,7,ev)
    fill_rect(img,8,9,23,26,vb); fill_rect(img,9,10,22,25,vd)
    fill_rect(img,10,11,21,24,vp)
    for x,y in [(12,13),(15,11),(19,14),(13,17),(17,16),(11,20),(20,19),(14,22),(18,21)]:
        px(img,x,y,sb)
    for x,y in [(14,12),(18,13),(12,16),(16,18),(20,22)]:
        px(img,x,y,swh)
    fill_rect(img,13,14,15,15,npk); fill_rect(img,16,18,18,19,nbl)
    for ry in range(10,26): px(img,8,ry,re); px(img,23,ry,re)
    fill_rect(img,8,9,23,9,re)
    fill_rect(img,4,11,8,14,vd); fill_rect(img,2,14,6,17,vp)
    px(img,1,17,ve); px(img,2,18,co); px(img,3,18,ve); px(img,1,16,co); px(img,0,15,ve)
    fill_rect(img,23,11,27,14,vd); fill_rect(img,25,14,29,17,vp)
    px(img,30,17,ve); px(img,29,18,co); px(img,28,18,ve); px(img,30,16,co); px(img,31,15,ve)
    fill_rect(img,26,12,28,14,vb); px(img,27,13,ei); px(img,26,12,co); px(img,28,14,co)
    fill_rect(img,7,26,24,27,vd)
    for rx in range(7,25):
        al=200-abs(rx-15)*12
        if al>0: px(img,rx,28,(25,10,45,al)); px(img,rx,29,(25,10,45,max(0,al-60)))
    for tx,ty in [(9,29),(12,30),(15,31),(19,30),(22,29)]:
        px(img,tx,ty,(60,20,90,100))
    px(img,6,6,co); px(img,25,5,co); px(img,4,18,swh); px(img,27,20,swh)
    return img

def gen_dimension_collapser():
    import random; random.seed(42)
    img = Image.new("RGBA", (32,32), (0,0,0,0))
    gr=(255,30,60,255); gg=(30,255,80,255); gbl=(40,80,255,255)
    gc=(0,255,255,255); gm=(255,0,200,255); gy=(255,255,0,255)
    vb=(5,0,10,255); grey=(140,140,150,255)
    dg=(60,60,70,255); d1=(200,100,255,200); d2=(100,200,255,200)
    st=(180,180,180,150); wh=(255,255,255,255)
    gcolors=[gr,gg,gbl]
    for sy in [2,7,14,21,28]:
        for sx in range(0,32,3):
            c=gcolors[sx%3]; px(img,sx,sy,(c[0],c[1],c[2],60))
    fill_rect(img,12,3,19,8,dg); fill_rect(img,13,4,18,7,grey)
    fill_rect(img,14,2,21,7,(dg[0],dg[1],dg[2],100))
    px(img,14,5,wh); px(img,15,5,gr); px(img,17,5,gc); px(img,18,5,wh)
    px(img,16,4,gm); px(img,19,4,gg)
    fill_rect(img,14,7,17,8,vb); px(img,15,7,gr); px(img,16,7,gbl)
    px(img,11,3,gr); px(img,20,4,gc); px(img,10,5,gg); px(img,21,3,gm)
    fill_rect(img,10,9,21,20,dg); fill_rect(img,11,10,20,19,grey)
    for cy in range(9,21):
        off=(cy*3)%5-2; cx=15+off
        px(img,cx,cy,vb); px(img,cx-1,cy,gr); px(img,cx+1,cy,gc)
    fill_rect(img,11,11,13,13,gbl); fill_rect(img,18,14,20,16,gr)
    fill_rect(img,13,17,15,18,gg); fill_rect(img,16,10,18,12,gm)
    fill_rect(img,6,10,10,14,grey); fill_rect(img,4,14,8,17,dg)
    px(img,5,11,gy); px(img,7,13,gc); px(img,3,15,gr)
    px(img,7,12,(0,0,0,0)); px(img,9,11,(0,0,0,0))
    fill_rect(img,21,10,25,14,grey); fill_rect(img,23,14,27,17,dg)
    fill_rect(img,22,11,24,13,(grey[0],grey[1],grey[2],150))
    px(img,26,15,gm); px(img,24,12,gg); px(img,22,16,gbl)
    px(img,23,12,(0,0,0,0)); px(img,25,14,(0,0,0,0))
    fill_rect(img,2,17,5,19,d1); px(img,1,18,gm)
    fill_rect(img,26,17,29,19,d2); px(img,30,18,gc)
    fill_rect(img,11,20,14,25,dg); fill_rect(img,17,20,20,25,dg)
    fill_rect(img,12,21,13,23,gbl); fill_rect(img,18,22,19,24,gr)
    fill_rect(img,10,26,15,27,grey); fill_rect(img,16,26,21,27,grey)
    for fx,fy,fc in [(9,28,gr),(12,28,gg),(14,29,gbl),(17,28,gm),(20,29,gc),(22,28,gy)]:
        px(img,fx,fy,fc)
    frags=[(3,3,gr),(28,4,gbl),(1,12,gg),(30,11,gy),(2,20,gc),(29,22,gm),
           (5,27,gr),(26,28,gbl),(7,6,gm),(24,7,gg)]
    for fx,fy,fc in frags:
        px(img,fx,fy,fc); px(img,fx+1,fy,(fc[0],fc[1],fc[2],150))
        px(img,fx,fy+1,(fc[0],fc[1],fc[2],100))
    for _ in range(20):
        sx=random.randint(0,31); sy=random.randint(0,31)
        if img.getpixel((sx,sy))[3]==0: px(img,sx,sy,st)
    for ry in range(5,25):
        rl=8-abs(ry-15)//3; rr=23+abs(ry-15)//3
        if 0<=rl<32 and img.getpixel((rl,ry))[3]==0: px(img,rl,ry,(5,0,10,80))
        if 0<=rr<32 and img.getpixel((rr,ry))[3]==0: px(img,rr,ry,(5,0,10,80))
    return img


if __name__ == "__main__":
    os.makedirs(OUTPUT_DIR, exist_ok=True)
    bosses = [
        ("sewer_croc.png", gen_sewer_croc, "Floor 1 - Sewer Croc"),
        ("rat_monarch.png", gen_rat_monarch, "Floor 1 - Rat Monarch"),
        ("warden_chief.png", gen_warden_chief, "Floor 2 - Warden Chief"),
        ("ghost_convict.png", gen_ghost_convict, "Floor 2 - Ghost Convict"),
        ("crystal_golem.png", gen_crystal_golem, "Floor 3 - Crystal Golem"),
        ("mana_overload.png", gen_mana_overload, "Floor 3 - Mana Overload"),
        ("arch_demon.png", gen_arch_demon, "Floor 4 - Arch Demon"),
        ("corrupt_high_priest.png", gen_corrupt_high_priest, "Floor 4 - Corrupt High Priest"),
        ("void_sovereign.png", gen_void_sovereign, "Floor 5 - Void Sovereign"),
        ("dimension_collapser.png", gen_dimension_collapser, "Floor 5 - Dimension Collapser"),
    ]
    for fn, gen, desc in bosses:
        fp = os.path.join(OUTPUT_DIR, fn)
        img = gen()
        img.save(fp)
        print(f"  [OK] {fn:30s} - {desc}")
    print("")
    print(f"All {len(bosses)} boss sprites generated in: {OUTPUT_DIR}")
