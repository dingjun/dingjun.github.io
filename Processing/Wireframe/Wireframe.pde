Scene scen; String a_txt="venus&atenea.txt", b_txt="finding_venus.txt";
boolean flag_pp=true, flag_spin=false, flag_mc=false;
float spin=0.0, step=0.0;
int defo_type=1;

class Matrix
{
  float entry[][]=new float[4][4];

  Matrix()
  {
    int i, j;
    for(i=0; i<4; i++)
      for(j=0; j<4; j++)
        entry[i][j]=0.0;
  }
  Matrix(float e[][])
  {
    int i, j;
    for(i=0; i<4; i++)
      for(j=0; j<4; j++)
        entry[i][j]=e[i][j];
  }
  Matrix Multiply(Matrix m)
  {
    Matrix p=new Matrix();
    int i, j, k;

    for(i=0; i<4; i++)
      for(j=0; j<4; j++)
        for(k=0; k<4; k++)
          p.entry[i][j]+=entry[i][k]*m.entry[k][j];

    return p;
  }
}

class Vertex
{
  float posi[]=new float[4];
  float posiT[]=new float[4];
  float wc[]= new float[3];

  Vertex()
  {
    for(int i=0; i<4; i++)
      posi[i]=0.0;
  }
  Vertex(float p[])
  {
    for(int i=0; i<3; i++)
      posi[i]=p[i];
    posi[3]=1.0;
  }
  void Initiate()
  {
    for(int i=0; i<4; i++)
      posiT[i]=posi[i];
  }
  void Transform(Matrix xformMat)
  {
    float temp[]={0.0, 0.0, 0.0, 0.0};
    int i, j;

    for(i=0; i<4; i++)
      for(j=0; j<4; j++)
        temp[i]+=xformMat.entry[i][j]*posiT[j];
    for(i=0; i<4; i++)
      posiT[i]=temp[i];
  }
  void Spin()
  {
    if(flag_spin)
      spin+=0.00001;
      
    float f[][]={{cos(spin), 0.0, sin(spin), 0.0},
                 {0.0, 1.0, 0.0, 0.0},
                 {-sin(spin), 0.0, cos(spin), 0.0},
                 {0.0, 0.0, 0.0, 1.0}};
    float temp[]={0.0, 0.0, 0.0, 0.0};
    int i, j;

    for(i=0; i<4; i++)
      for(j=0; j<4; j++)
          temp[i]+=f[i][j]*posiT[j];
    for(i=0; i<4; i++)
      posiT[i]=temp[i];
  }
  void Shearing()
  {
    float f[][]={{1.0, 0.5, 0.0, 0.0},
                 {0.0, 1.0, 0.0, 0.0},
                 {0.0, 0.0, 1.0, 0.0},
                 {0.0, 0.0, 0.0, 1.0}};
    float temp[]={0.0, 0.0, 0.0, 0.0};
    int i, j;

    for(i=0; i<4; i++)
      for(j=0; j<4; j++)
          temp[i]+=f[i][j]*posiT[j];
    for(i=0; i<4; i++)
      posiT[i]=temp[i];
  }
  void Tapering()
  {
    float fx=(3.0-posiT[0])*(3.0-posiT[0])/9.0;
    float f[][]={{1.0, 0.0, 0.0, 0.0},
                 {0.0, fx, 0.0, 0.0},
                 {0.0, 0.0, 1.0, 0.0},
                 {0.0, 0.0, 0.0, 1.0}};
    float temp[]={0.0, 0.0, 0.0, 0.0};
    int i, j;

    for(i=0; i<4; i++)
      for(j=0; j<4; j++)
          temp[i]+=f[i][j]*posiT[j];
    for(i=0; i<4; i++)
      posiT[i]=temp[i];
  }
  void Twisting()
  {
    float fy=posiT[1]*2.0;
    float f[][]={{cos(fy), 0.0, sin(fy), 0.0},
                 {0.0, 1.0, 0.0, 0.0},
                 {-sin(fy), 0.0, cos(fy), 0.0},
                 {0.0, 0.0, 0.0, 1.0}};
    float temp[]={0.0, 0.0, 0.0, 0.0};
    int i, j;

    for(i=0; i<4; i++)
      for(j=0; j<4; j++)
          temp[i]+=f[i][j]*posiT[j];
    for(i=0; i<4; i++)
      posiT[i]=temp[i];
  }
  void WindowCoordinates()
  {
    for(int i=0; i<3; i++)
      posiT[i]=posiT[i]/posiT[3];
      
    wc[0]=(posiT[0]+1)*(width-1)/2+0;
    wc[1]=-(posiT[1]+1)*(height-1)/2+(height-1);
    wc[2]=posiT[2];
  }
}

class Polygon
{
  int num; 
  Vertex vert[];

  Polygon(int n, Vertex v[])
  {
    num=n; 
    vert=v;
  }
}

class Mesh
{
  String name; 
  int num; 
  Polygon poly[];

  Mesh(String s, int n, Polygon p[])
  {
    name=s; 
    num=n; 
    poly=p;
  }
}

class Object
{
  float r, g, b, radx, rady, radz;
  Matrix rx, ry, rz, s, t;
  Mesh mesh;

  Object(float f[], Mesh m)
  {
    r=f[0]; 
    g=f[1]; 
    b=f[2]; 
    radx=f[3]; 
    rady=f[4]; 
    radz=f[5];
    float frx[][]={{1.0, 0.0, 0.0, 0.0},
                   {0.0, cos(f[3]), -sin(f[3]), 0.0},
                   {0.0, sin(f[3]), cos(f[3]), 0.0},
                   {0.0, 0.0, 0.0, 1.0}},
          fry[][]={{cos(f[4]), 0.0, sin(f[4]), 0.0},
                   {0.0, 1.0, 0.0, 0.0},
                   {-sin(f[4]), 0.0, cos(f[4]), 0.0},
                   {0.0, 0.0, 0.0, 1.0}},
          frz[][]={{cos(f[5]), -sin(f[5]), 0.0, 0.0},
                   {sin(f[5]), cos(f[5]), 0.0, 0.0},
                   {0.0, 0.0, 1.0, 0.0},
                   {0.0, 0.0, 0.0, 1.0}},
           fs[][]={{f[6], 0.0, 0.0, 0.0},
                   {0.0, f[7], 0.0, 0.0},
                   {0.0, 0.0, f[8], 0.0},
                   {0.0, 0.0, 0.0, 1.0}},
           ft[][]={{1.0, 0.0, 0.0, f[9]},
                   {0.0, 1.0, 0.0, f[10]},
                   {0.0, 0.0, 1.0, f[11]},
                   {0.0, 0.0, 0.0, 1.0}};
                   
    rx=new Matrix(frx); ry=new Matrix(fry); rz=new Matrix(frz); s=new Matrix(fs); t=new Matrix(ft); mesh=m;
  }
}

class Scene
{
  int xres, yres;
  float px, py, pz, ux, uy, uz, vx, vy, vz, nx, ny, nz, near, far, top, bottom, left, right;
  Matrix cam, ndc, ndcO;
  ArrayList obje=new ArrayList();

  Scene(int n[], float f[])
  {
    xres=n[0]; yres=n[1]; px=f[0]; py=f[1]; pz=f[2]; ux=f[3]; uy=f[4]; uz=f[5]; vx=f[6]; vy=f[7]; vz=f[8]; 
    nx=f[9]; ny=f[10]; nz=f[11]; near=f[12]; far=f[13]; top=f[14]; bottom=f[15]; left=f[16]; right=f[17];

    float dp[]={0.0, 0.0, 0.0};
    int i, j;
    for(i=0; i<3; i++)
      dp[0]-=f[i]*f[i+3];
    for(i=0; i<3; i++)
      dp[1]-=f[i]*f[i+6];
    for(i=0; i<3; i++)
      dp[2]-=f[i]*f[i+9];
    float fcam[][]={{f[3], f[4], f[5], dp[0]},
                    {f[6], f[7], f[8], dp[1]},
                    {f[9], f[10], f[11], dp[2]},
                    {0.0, 0.0, 0.0, 1.0}},
          fndc[][]={{2.0*near/(right-left), 0.0, (right+left)/(right-left), 0.0},
                    {0.0, 2.0*near/(top-bottom), (top+bottom)/(top-bottom), 0.0},
                    {0.0, 0.0, -(far+near)/(far-near), -2.0*(far*near)/(far-near)},
                    {0.0, 0.0, -1.0, 0.0}},
         fndcO[][]={{2.0/(right-left), 0.0, 0.0, -(right+left)/(right-left)},
                    {0.0, 2.0/(top-bottom), 0.0, -(top+bottom)/(top-bottom)},
                    {0.0, 0.0, -2.0/(far-near), -(far+near)/(far-near)},
                    {0.0, 0.0, 0.0, 1.0}};
    cam=new Matrix(fcam);  ndc=new Matrix(fndc);  ndcO=new Matrix(fndcO);
  }
  void AddObject(Object o)
  {
    obje.add(o);
  }
  void MoveCamera(float x, float y, float z)
  {
    float xz=sqrt(nx*nx+nz*nz);
    step+=0.2;
    if(x==0)
    {px+=(z*nx/xz); pz+=(z*nz/xz);}
    else
    {px+=(x*ux/xz); pz+=(x*uz/xz);}
    cam.entry[0][3]=-(px*ux+(py+sin(step))*uy+pz*uz);
    cam.entry[1][3]=-(px*vx+(py+sin(step))*vy+pz*vz);
    cam.entry[2][3]=-(px*nx+(py+sin(step))*ny+pz*nz);
  }
  void RotateCameraX(float h)
  {
    float f[][]={{cos(h)*ux+sin(h)*uz, uy, cos(h)*uz-sin(h)*ux, 0.0},
                 {cos(h)*vx+sin(h)*vz, vy, cos(h)*vz-sin(h)*vx, 0.0},
                 {cos(h)*nx+sin(h)*nz, ny, cos(h)*nz-sin(h)*nx, 0.0},
                 {0.0, 0.0, 0.0, 1.0}},
    ux=f[0][0]; uz=f[0][2]; vx=f[1][0]; vz=f[1][2]; nx=f[2][0]; nz=f[2][2];
    f[0][3]=-(px*ux+(py+sin(step))*uy+pz*uz);
    f[1][3]=-(px*vx+(py+sin(step))*vy+pz*vz);
    f[2][3]=-(px*nx+(py+sin(step))*ny+pz*nz);
    cam=new Matrix(f);
  }
}

Mesh LoadMesh(String sff)
{
  String lines[]=loadStrings(sff), s[];
  int line_num=0, poly_num=int(splitTokens(lines[line_num++])[0]), vert_num, i, j, k;
  Polygon poly[]=new Polygon[poly_num]; 
  Vertex vert[];  
  float pos[]=new float[3];

  for(i=0; i<poly_num; i++)  // polygon
  {
    vert_num=int(splitTokens(lines[line_num++])[0]);
    vert=new Vertex[vert_num];

    for(j=0; j<vert_num; j++)  // vertex
    {
      for(s=splitTokens(lines[line_num++]), k=0; k<s.length; k++)
        pos[k]=float(s[k]);

      vert[j]=new Vertex(pos);
    }
    poly[i]=new Polygon(vert_num, vert);
  }

  return new Mesh(sff, poly_num, poly);
}

Scene LoadScene(String txt)
{
  String lines[]=loadStrings(txt), s[];
  int n[]=new int[2], i, j;
  float fs[]=new float[18], fo[]=new float[12];
  Object obje;

  for(s=splitTokens(lines[0]), i=0; i<s.length; i++)  // line0
    n[i]=int(s[i]);
  for(s=splitTokens(lines[1]), i=0; i<s.length; i++)  // line1
    fs[i]=float(s[i]);
  for(s=splitTokens(lines[2]), i=0; i<s.length; i++)  // line2
    fs[i+12]=float(s[i]);
  Scene scen=new Scene(n, fs);

  for(j=3; j<lines.length; j++)  // object
  {
    for(s=splitTokens(lines[j]), i=0; i<s.length-1; i++)
      fo[i]=float(s[i]);
    scen.AddObject(new Object(fo, LoadMesh(s[i])));
  }

  return scen;
}

void WireframeRendering()
{
  Object o; 
  Matrix mo, mw;
  int i, j, k;
  float zbuffer[][]=new float[scen.yres][scen.xres];

  for(i=0; i<scen.obje.size(); i++)  // for each mesh in the scene
  {
    o=(Object)scen.obje.get(i);
    stroke(o.r, o.g, o.b);

    mo=o.s.Multiply(o.rz.Multiply(o.ry.Multiply(o.rx)));
    if(flag_pp)
      mw=scen.ndc.Multiply(scen.cam.Multiply(o.t));
    else
      mw=scen.ndcO.Multiply(scen.cam.Multiply(o.t));

    for(j=0; j<o.mesh.poly.length; j++)  // for each polygon in the mesh
    {
      for(k=0; k<o.mesh.poly[j].vert.length; k++)  // for each edge (pair of vertices) of the polygon
      {
        // transforming pairs of vertices
        o.mesh.poly[j].vert[k].Initiate();
        o.mesh.poly[j].vert[k].Transform(mo);
        switch(defo_type)
        {
          case 2: o.mesh.poly[j].vert[k].Shearing(); break;
          case 3: o.mesh.poly[j].vert[k].Tapering(); break;
          case 4: o.mesh.poly[j].vert[k].Twisting(); break;
        }
        o.mesh.poly[j].vert[k].Spin();
        o.mesh.poly[j].vert[k].Transform(mw);
        
        o.mesh.poly[j].vert[k].WindowCoordinates();
        
        // draw a digital line
        if(k>0)
          if(o.mesh.poly[j].vert[k].wc[2]>=-1.0&&o.mesh.poly[j].vert[k].wc[2]<=1.0
            && o.mesh.poly[j].vert[k-1].wc[2]>=-1.0&&o.mesh.poly[j].vert[k-1].wc[2]<=1.0)
            line(o.mesh.poly[j].vert[k].wc[0], o.mesh.poly[j].vert[k].wc[1], o.mesh.poly[j].vert[k-1].wc[0], o.mesh.poly[j].vert[k-1].wc[1]);
      }
      if(o.mesh.poly[j].vert[k-1].wc[2]>=-1.0&&o.mesh.poly[j].vert[k-1].wc[2]<=1.0
        && o.mesh.poly[j].vert[0].wc[2]>=-1.0&&o.mesh.poly[j].vert[0].wc[2]<=1.0)
        line(o.mesh.poly[j].vert[k-1].wc[0], o.mesh.poly[j].vert[k-1].wc[1], o.mesh.poly[j].vert[0].wc[0], o.mesh.poly[j].vert[0].wc[1]);
    }
  }
}

void setup()
{
  scen=LoadScene(a_txt);
  size(scen.xres, scen.yres);
}

void keyPressed()
{
   switch(key)
   {
     case 'e': if(!flag_mc)
               {scen=LoadScene(b_txt); flag_mc=true;
               flag_pp=true; flag_spin=false; spin=0.0; defo_type=1;}
               else
               {scen=LoadScene(a_txt); flag_mc=false; step=0.0;}
               break;
     
     case 'p': if(!flag_mc) flag_pp=!flag_pp; break;  // change projection
     case 'o': if(!flag_mc) flag_spin=!flag_spin; break;  // spin objects
     case '1': if(!flag_mc) defo_type=1; break;  // no deformation
     case '2': if(!flag_mc) defo_type=2; break;  // shearing
     case '3': if(!flag_mc) defo_type=3; break;  // tapering
     case '4': if(!flag_mc) defo_type=4; break;  // twisting
     
     case 'a': if(flag_mc) scen.MoveCamera(-1.0, 0.0, 0.0); break;
     case 'd': if(flag_mc) scen.MoveCamera(1.0, 0.0, 0.0); break;
     case 's': if(flag_mc) scen.MoveCamera(0.0, 0.0, 1.0); break;
     case 'w': if(flag_mc) scen.MoveCamera(0.0, 0.0, -1.0); break;

     case 'q': exit();  // quit
   }
}

void draw()
{
  if(flag_mc)
      scen.RotateCameraX((mouseX-pmouseX)*-0.004);
  background(0);
  WireframeRendering();
}

