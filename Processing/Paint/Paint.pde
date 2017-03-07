int x0, y0, x1=-1, y1, xf=-1, yf, h=0, s=0, b=99, hf, sf, bf, tool_type=0;
boolean flag_cs=false, flag_aa=false, flag_pick=false, flag_rainbow=false, flag_help=false,
        flag_swap=false, flag_ps=false;

void setup()
{
  size(600, 600);  // 600x600 window
  colorMode(HSB, 359, 99, 99);
  background(0);  // black background
  noLoop();
}

void swap()  // swap two endpoints of the line
{
  int xt=x0, yt=y0;
  x0 = x1;
  y0 = y1;
  x1 = xt;
  y1 = yt;
  
  flag_swap = !flag_swap;
}

void setPixel(int x, int y, float f)  // draw a pixel with a specific color
{
  if(f == 1.0)
    stroke(h, s, b);
  else if(f > 0.0)
    stroke(lerpColor((pixels[y*800+x]), color(h, s, b), f));
  else
    return;

  point(x, y);
}

void newH()  // change hue
{
  if(flag_rainbow)
    h = ++h % 360;
}

void ALine()  // draw an aliasing line
{
  int dx=x1-x0, dy=y1-y0;
  float m;
  
  if(dx==0 || (m=float(dy)/dx)<-1.0)  // slope less than -1.0
  {
    int d=dy+2*dx;
    int delS=2*dx, delSE=2*(dy+dx);
    int x=x0, y=y0;
    setPixel(x, y, 1);
  
    while(y > y1)
    {
      if(d <= 0)
      {
        d+=delS; y--;
      }
      else
      {
        d+=delSE; x++; y--;
      }
      newH();
      setPixel(x, y, 1);
    }
  }
  
  else if(m < 0.0)  // slope less than 0.0
  {
    int d=2*dy+dx;
    int delE=2*dy, delSE=2*(dy+dx);
    int x=x0, y=y0;
    setPixel(x, y, 1);
  
    while(x < x1)
    {
      if(d >= 0)
      {
        d+=delE; x++;
      }
      else
      {
        d+=delSE; x++; y--;
      }
      newH();
      setPixel(x, y, 1);
    }
  }
  
  else if(m < 1.0)  // slope less than 1.0
  {
    int d=2*dy-dx;
    int delE=2*dy, delNE=2*(dy-dx);
    int x=x0, y=y0;
    setPixel(x, y, 1);
  
    while(x < x1)
    {
      if(d <= 0)
      {
        d+=delE; x++;
      }
      else
      {
        d+=delNE; x++; y++;
      }
      newH();
      setPixel(x, y, 1);
    }
  }
  
  else  // other slope
  {
    int d=dy-2*dx;
    int delN=-2*dx, delNE=2*(dy-dx);
    int x=x0, y=y0;
    setPixel(x, y, 1);
  
    while(y < y1)
    {
      if(d >= 0)
      {
        d+=delN; y++;
      }
      else
      {
        d+=delNE; x++; y++;
      }
      newH();
      setPixel(x, y, 1);
    }
  }
}

void AALine()  // draw an anti-aliasing line
{
  int dx=x1-x0;
  int dy=y1-y0;
  float m;

  if(dx==0 || (m=float(dy)/dx)<-1.0||m>=1.0)  // slope less than -1.0 or greater than or equal 1.0
  {
    if(y1 < y0)
      swap();
    
    m = float(dx) / dy;
    float x=x0; int y=y0;

    for(; y<=y1; y++)
    {
      int xi=floor(x); float f=x-xi;
      newH();
      setPixel(xi, y, 1-f);
      setPixel(xi+1, y, f);
      x += m;
    }
  }

  else  // other slope
  {
    int x=x0; float y=y0;

    for(; x<=x1; x++)
    {
      int yi=floor(y); float f=y-yi;
      newH();
      setPixel(x, yi, 1-f);
      setPixel(x, yi+1, f);
      y += m;
    }
  }
}

void Line()  // draw a line from left to right
{
  if(x1<x0 || x0==x1&&y1>y0)
    swap();
  
  if(!flag_aa || flag_ps)
    ALine();
  else
    AALine();
    
  if(flag_swap)
    swap();
}

void Reset()  // reset
{
  x1 = xf = -1;
}

void floodFill(int x, int y, color c)  // fill color
{ 
  if(pixels[y*800+x]!=c)
    return;

  setPixel(x, y, 1);
  loadPixels();
  floodFill(x-1, y, c);
  floodFill(x+1, y, c);
  floodFill(x, y-1, c);
  floodFill(x, y+1, c);
}

void ColorSelectorOn()  // turn on color selector
{
  flag_cs = true;
  cursor(CROSS);
  loadPixels();
  
  hf=h; sf=s; bf=b;
  ColorSelectorPanel(0, 0);
}

void ColorSelectorPanel(int x, int y)  // draw color selector panel
{
  background(330);
  int ht=h, st=s, bt=b, i, j;
  
  // hue bar
  s=99; b=99;
  for(h=0; h<360; h++)
    for(i=600; i<640; i++)
      setPixel(i, 579-h, 1);
  if(x>=600&&x<640&&y>=220&&y<580)
    ht=579-y;
  for(b=0, i=600; i<640; i++)  // black line
    setPixel(i, 579-ht, 1);
  h=ht;
  
  // saturation&brightness square
  for(; b<100; b++)
    for(j=599; j>595; j--)
      for(s=0; s<100; s++)
        for(i=160; i<164; i++)
          setPixel(s*4+i, j-b*4, 1);
  if(x>160&&x<560&&y>=200&&y<600)
  {
    st=(x-160)/4; bt=(599-y)/4;
  }
  if(bt>=50)  // black
    b=0;
  else  // white
    s=0;
  for(j=0; j<6; j++)  // 5x5 square
    for(i=0; i<6; i++)
      if(i*j%5==0)  // noFill();
        setPixel(159+st*4+i, 600-bt*4-j, 1);
  s=st; b=bt;
}

void ColorSelectorOff(boolean flag)  // turn off color selector
{
  if(!flag)
  {
    h=hf; s=sf; b=bf;
  }
    
  updatePixels();
  cursor(ARROW);
  flag_cs = false;
}

void Encircle()  // draw a line between the first and last points of the current poly-line
{
  x0 = xf;
  y0 = yf;
  
  Line();
  Reset();
}

void Invert()  // invert every pixel's color on canvas
{
  loadPixels();
  for(int i=0; i<640000; i++)
    pixels[i]=~pixels[i]|0xFF000000;
  updatePixels();
}

void New()  // new canvas
{
  background(0);
  Reset();
}

void Open()  // open Sun_HW1.png
{
  PImage i;
  
  if((i=loadImage("Sun_HW1.png")) != null)
  {
    image(i, 0, 0);
    Reset();
  }
  else
  {
    // load null
  }
}

void HelpOn()  // turn on help
{
  flag_help = true;
  cursor(HAND);
  loadPixels();
  background(100);
  
  text("[space]: Color Selector", 100, 30);
  text("[a]: Anti-aliasing", 100, 60);
  
  text("[l]: Poly-line", 100, 90);
    text("[r]: Reset", 130, 120);
    text("[c]: Encircle", 130, 150);
  text("[p]: Pencil", 100, 180);
  text("[b]: Airbrush", 100, 210);
  text("[k]: Pick Color", 100, 240);

  text("[1]: Pen Size (1px)", 100, 270);
  text("[2]: Pen Size (3px)", 100, 300);
  text("[3]: Pen Size (5px)", 100, 330);
  text("[4]: Pen Size (7px)", 100, 360);
  text("[9]: Pen Type (project)", 100, 390);
  text("[0]: Pen Type (round)", 100, 420);

  text("[w]: Rainbow", 100, 450);
  text("[i]: Invert", 100, 480);
  
  text("[h]: Help", 100, 630);
  text("[n]: New", 100, 510);
  text("[s]: Save", 100, 540);
  text("[o]: Open", 100, 570);
  text("[q]: Quit", 100, 600);
  
  text("***Click to Countinue***", 100, 700);
}

void HelpOff(int x, int y)  // turn off help
{
  updatePixels();   
  cursor(ARROW);
  flag_help = false;
}

void mousePressed()
{
  if(!flag_pick&&!flag_cs&&!flag_help && mouseButton==LEFT)
  {
    switch(tool_type)
    {
      case 0:  // poly-line
        loadPixels();
        x0 = x1;
        y0 = y1;
        x1 = mouseX;
        y1 = mouseY;
      
        if(x0 < 0)  // first point
          setPixel(x1, y1, 1);
        else  // other points
          Line();  
      break;
      
      case 1:  // pencil
        setPixel(mouseX, mouseY, 1);
      break;
      
      case 2:  // airbrush
        loadPixels();
        floodFill(mouseX, mouseY, pixels[mouseY*800+mouseX]);
      break;
    }
  }
  
  redraw();
}

void mouseDragged()
{
  if(!flag_pick&&!flag_cs&&!flag_help && mouseButton==LEFT)
  {
    switch(tool_type)
    {
      case 0:  // simulate poly-line
        updatePixels();
        x1 = mouseX;
        y1 = mouseY;
    
        if(x0 < 0)  // first point
          setPixel(x1, y1, 1);
        else  // other points
          Line();
      break;
      
      case 1:  // draw by pencil
        x0 = pmouseX;
        y0 = pmouseY;
        x1 = mouseX;
        y1 = mouseY;
        Line();
      break;
    }
  }
  
  redraw();
}

void mouseReleased()
{
  if(!flag_pick&&!flag_cs&&!flag_help && mouseButton==LEFT)
  {
    switch(tool_type)
    {
      case 0:  // draw poly-line
        updatePixels();
        x1 = mouseX;
        y1 = mouseY;
        
        if(x0 < 0)  // first point
        {
          xf = x1;
          yf = y1;
          setPixel(x1, y1, 1);
        }
        else  // other points
          Line();
      break;
    }
  }

  else if(flag_pick)  // pick color
  {
    color c=get(mouseX, mouseY);
    h=round(hue(c)); s=round(saturation(c)); b=round(brightness(c));
    cursor(ARROW);
    flag_pick = false;
  }
  else if(flag_cs)  // select color
    ColorSelectorPanel(mouseX, mouseY);
  else if(flag_help)  // turn off help
    HelpOff(mouseX, mouseY);

  redraw();
}

void keyPressed()
{
  if(!flag_cs && !flag_help)  // in canvas
  {
    switch(tool_type)
    {
      case 0:  // poly-line
        switch(key)
        {
          case 'r': Reset(); break;  // reset
          case 'c': Encircle(); break;  // encircle
        }
      break;
    }
    
    switch(key)
    {
      case ' ': strokeWeight(1); flag_ps=false; ColorSelectorOn(); break;  // color selector
      case 'a': flag_aa=!flag_aa; break;  // anti-aliasing
      
      case 'l': Reset(); tool_type=0; break;  // poly-line
      case 'p': Reset(); tool_type=1; break;  // pencil
      case 'b': Reset(); tool_type=2; break;  // airbrush
      case 'k': flag_pick=!flag_pick; cursor(HAND); break;  // pick color
      
      case '1': strokeWeight(1); flag_ps=false; break;  // pencil size--1px
      case '2': strokeWeight(3); flag_ps=true; break;  // pencil size--3px
      case '3': strokeWeight(5); flag_ps=true; break;  // pencil size--5px
      case '4': strokeWeight(7); flag_ps=true; break;  // pencil size--7px
      case '9': strokeCap(PROJECT); break;  // pencil type--project
      case '0': strokeCap(ROUND); break;  // pencil type--round
      
      case 'w': flag_rainbow=!flag_rainbow; s=99; break;  // rainbow
      case 'i': Invert(); break;  // invert
      
      case 'h': HelpOn(); break;  // help
      case 'n': New(); break;  // new
      case 's': save("Sun_HW1.png"); break;  // save
      case 'o': Open(); break;  // open
    }
  }
    
  else if(flag_cs)  // in color selector
    switch(key)
    {
      case ' ': ColorSelectorOff(true); break;  // ok
      case DELETE: ColorSelectorOff(false); break;  // cancel
    }
    
  switch(key)  // everywhere
  {
    case 'q': exit();  // quit
  }
  
  redraw();
}

void draw()
{
  
}
