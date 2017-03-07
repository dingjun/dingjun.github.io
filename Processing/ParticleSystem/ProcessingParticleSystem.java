import processing.core.*; 
import processing.xml.*; 

import java.applet.*; 
import java.awt.Dimension; 
import java.awt.Frame; 
import java.awt.event.MouseEvent; 
import java.awt.event.KeyEvent; 
import java.awt.event.FocusEvent; 
import java.awt.Image; 
import java.io.*; 
import java.net.*; 
import java.text.*; 
import java.util.*; 
import java.util.zip.*; 
import java.util.regex.*; 

public class ProcessingParticleSystem extends PApplet {

// ProcessingParticleSystem.pde
// Ting-Chun Sun <dingjun@cs.nctu.edu.tw>
// Updated: 2011/04/13

// scene files
String fileFountain = "Scene/fountain.txt";
String fileWaterfall = "Scene/waterfall.txt";

// global flags
boolean flagWind = true;
int flagScene = 1;

// object lists
ArrayList particleSystem = new ArrayList();
ArrayList forceField = new ArrayList();
ArrayList collisionPlane = new ArrayList();

public void LoadScene( String fileName )
{
  String lines[] = loadStrings( fileName );
  
  for( int i=0; i<lines.length; i++ )
  {
    String s[] = splitTokens( lines[i] );
    switch( PApplet.parseInt( s[0] ) )
    {
      case 1:  // particle system
        int pType = PApplet.parseInt( s[1] );
        PVector pPosition = new PVector( PApplet.parseFloat( s[2] ), PApplet.parseFloat( s[3] ), PApplet.parseFloat( s[4] ) );
        PVector pVelocity = new PVector( PApplet.parseFloat( s[5] ), PApplet.parseFloat( s[6] ), PApplet.parseFloat( s[7] ) );
        int pCount = PApplet.parseInt( s[8] );
        int pMinLifespan = PApplet.parseInt( s[9] );
        int pMaxLifespan = PApplet.parseInt( s[10] );
        int pMinColour = color( PApplet.parseFloat( s[11] ), PApplet.parseFloat( s[12] ), PApplet.parseFloat( s[13] ) );
        int pMaxColour = color( PApplet.parseFloat( s[14] ), PApplet.parseFloat( s[15] ), PApplet.parseFloat( s[16] ) );
        float pMinSize = PApplet.parseFloat( s[17] ) ;
        float pMaxSize = PApplet.parseFloat( s[18] ) ;
        particleSystem.add( new ParticleSystem( pType, pPosition, pVelocity, pCount,
          pMinLifespan, pMaxLifespan, pMinColour, pMaxColour, pMinSize, pMaxSize ) );
        break;
        
      case 2:  // force field
        int fType = PApplet.parseInt( s[1] );
        float fMagnitude = PApplet.parseFloat( s[2] );
        switch( fType )
        {
          case 1:  // gravity
            PVector fgDirection = new PVector( PApplet.parseFloat( s[3] ), PApplet.parseFloat( s[4] ), PApplet.parseFloat( s[5] ) );
            forceField.add( new ForceField( fType, fMagnitude, fgDirection ) );
            break;
          case 2:  // wind
            PVector fwDirection = new PVector( PApplet.parseFloat( s[3] ), PApplet.parseFloat( s[4] ), PApplet.parseFloat( s[5] ) );
            float fwRandomness = PApplet.parseFloat( s[6] );
            forceField.add( new ForceField( fType, fMagnitude, fwDirection, fwRandomness ) );
            break;
        }
        break;
        
      case 3:  // collision plane
        int cType = PApplet.parseInt ( s[1] );
        float cA = PApplet.parseFloat( s[2] );
        float cB = PApplet.parseFloat( s[3] );
        float cC = PApplet.parseFloat( s[4] );
        float cD = PApplet.parseFloat( s[5] );
        collisionPlane.add( new CollisionPlane( cType, cA, cB, cC, cD ) );
        break;
    }
  }
}

public void ClearScene()
{
  while( particleSystem.size() > 0 )
    particleSystem.remove( 0 );
  
  while( forceField.size() > 0 )
    forceField.remove( 0 );
  
  while( collisionPlane.size() > 0 )
    collisionPlane.remove( 0 );
}

public void mousePressed()
{
  
}

public void keyPressed()
{
  switch( key )
  {
    case 'w':  // wind switch
      flagWind = !flagWind;
      break;
      
    case '1':  // fountain scene
      if( flagScene != 1 )
      {
        flagScene = 1;
        ClearScene();
        LoadScene( fileFountain );
      }
      break;
      
    case '2':  // waterfall scene
      if( flagScene != 2 )
      {
        flagScene = 2;
        ClearScene();
        LoadScene( fileWaterfall );
      }
      break;
  }
}

public void draw()
{
  background( 0 );
  
  // plane
  noStroke();
  for( int i=0; i<collisionPlane.size(); i++ )
  {
    CollisionPlane cp = (CollisionPlane) collisionPlane.get(i);
    cp.Render();
  }

  // particle system
  for( int i=0; i<particleSystem.size(); i++ )
  {
    ParticleSystem ps = (ParticleSystem) particleSystem.get(i);
    ps.Update();
    ps.Render();
  }
}

public void setup()
{
  size( 640, 480, P3D );
  smooth();
  
  strokeCap( ROUND );
  //frameRate( 20 );
  
  LoadScene( fileFountain );
}

// CollisionPlane.pde
// Ting-Chun Sun <dingjun@cs.nctu.edu.tw>
// Updated: 2011/04/13

class CollisionPlane
{
  int type;  // 1:bounce, 2:stick, 3:die
  float a, b, c, d;
  int colour;
  
  CollisionPlane( int _type, float _a, float _b, float _c, float _d )
  {
    type = _type;
    a = _a;
    b = _b;
    c = _c;
    d = _d;
    colour = color( random( 50, 150 ) );
  }
  
  public void Render()
  {
    fill( colour );
    
    beginShape();
      if( b != 0 )
      {
        vertex( 0, (-d-c*320)/b, 320 );
        vertex( 640, (-d-a*640-c*320)/b, 320 );
        vertex( 640, (-d-a*640+c*320)/b, -320 );
        vertex( 0, (-d+c*320)/b, -320 );
      }
      else if( a != 0 )
      {
        vertex( (-d-c*240)/a, 0, 240 );
        vertex( (-d-b*480-c*240)/a, 480, 240 );
        vertex( (-d-b*480+c*240)/a, 480, -240 );
        vertex( (-d+c*240)/a, 0, -240 );
      }
      else
      {
        vertex( 0, 0, -d/c );
        vertex( 640, 0, (-d-a*640)/c );
        vertex( 640, 480, (-d-a*640-b*480)/c );
        vertex( 0, 480, (-d-b*480)/c );
      }
    endShape( CLOSE );
  }
}

// Force.pde
// Ting-Chun Sun <dingjun@cs.nctu.edu.tw>
// Updated: 2011/04/13

class ForceField
{
  int type;  // 1:gravity, 2:wind
  float magnitude;
  PVector direction;
  float randomness;
  PVector currentDirection;
  
  ForceField( int _type, float _magnitude, PVector _direction )  // gravity
  {
    type = _type;
    magnitude = _magnitude;
    direction = _direction.get();
  }
  
  ForceField( int _type, float _magnitude, PVector _direction, float _randomness )  // wind
  {
    type = _type;
    magnitude = _magnitude;
    direction = _direction.get();
    randomness = _randomness;
  }
}

// Particle.pde
// Ting-Chun Sun <dingjun@cs.nctu.edu.tw>
// Updated: 2011/04/13

class Particle
{
  int type;  // 1:water
  PVector position;
  PVector velocity;
  PVector acceleration;
  int age;
  int lifespan;
  int colour;
  int opacity;  // @TODO
  float size;
  PVector orientation;  // @TODO
  ArrayList side;
  
  Particle( int _type, PVector _position, PVector _velocity, int _lifespan, int _colour, float _size )
  {
    type = _type;
    position = _position.get();
    velocity = _velocity.get();
    acceleration = new PVector( 0.0f, 0.0f, 0.0f );
    age = 0; 
    lifespan = _lifespan;
    colour = _colour;
    size = _size;
    
    side = new ArrayList();
    for( int i=0; i<collisionPlane.size(); i++ )
    {
      CollisionPlane cp = (CollisionPlane) collisionPlane.get(i);
      float value = cp.a*position.x + cp.b*position.y + cp.c*position.z + cp.d;
      
      if( value > 0 )
        side.add( 1 );
      else if( value < 0 )
        side.add( -1 );
      else
        side.add( 0 );  // @TODO
    }
  }
  
  public boolean Update()
  {
    if( lifespan==0 || age++<lifespan )
    {
      acceleration.set( 0.0f, 0.0f, 0.0f );
      
      // force field
      for( int i=0; i<forceField.size(); i++ )
      {
        ForceField ff = (ForceField) forceField.get(i);
        switch( ff.type )
        {
          case 1:  // gravity
            acceleration.add( PVector.mult( ff.currentDirection, ff.magnitude ) );
            break;
            
          case 2:  // wind
            if( flagWind )
              acceleration.add( PVector.mult( ff.currentDirection, ff.magnitude ) );
            break;
        }
      }
      
      velocity.add( acceleration );
      position.add( random( velocity.x-2.0f, velocity.x+2.0f ),
        random( velocity.y-2.0f, velocity.y+2.0f ), random( velocity.z-2.0f, velocity.z+2.0f ) );
      
      // collision plane
      for( int i=0; i<collisionPlane.size(); i++ )
      {
        CollisionPlane cp = (CollisionPlane) collisionPlane.get(i);
        
        float value = cp.a*position.x + cp.b*position.y + cp.c*position.z + cp.d;
        if( value>0 && (Integer) side.get(i)<0 )
        {
          switch( cp.type )
          {
            case 1:  // bounce
            case 2:  // stick
              PVector n = new PVector( -cp.a, -cp.b, -cp.c );
              value /= n.mag();
              n.normalize();
              if( cp.type == 1 )  // bounce
              {
                velocity.add( PVector.mult( n, -2*velocity.dot( n ) ) );
                velocity.mult( 0.3f );
                position.add( PVector.mult( n, 2*value ) );
                colorMode( HSB, 360, 100, 100 );
                  colour = color( hue( colour ), saturation( colour )-random( 100 ), brightness( colour ) );
                colorMode( RGB, 255, 255, 255 );
              }
              else  // stick
              {
                velocity.set( 0.0f, 0.0f, 0.0f );
                position.add( PVector.mult( n, value ) );
                colorMode( HSB, 360, 100, 100 );
                  colour = color( hue( colour ), saturation( colour )-random( 5 ), brightness( colour ) );
                colorMode( RGB, 255, 255, 255 );
              }
              size = size + random( 1.0f );
              break;
            case 3:  // die
              return false;
          }
        }
        else if( value<0 && (Integer) side.get(i)>0 )
        {
          switch( cp.type )
          {
            case 1:  // bounce
            case 2:  // stick
              PVector n = new PVector( cp.a, cp.b, cp.c );
              value /= n.mag();
              n.normalize();
              if( cp.type == 1 )  // bounce
              {
                velocity.add( PVector.mult( n, -2*velocity.dot( n ) ) );
                velocity.mult( 0.3f );
                position.add( PVector.mult( n, 2*value ) );
                colorMode( HSB, 360, 100, 100 );
                  colour = color( hue( colour ), saturation( colour )-random( 100 ), brightness( colour ) );
                colorMode( RGB, 255, 255, 255 );
              }
              else  // stick
              {
                velocity.set( 0.0f, 0.0f, 0.0f );
                position.add( PVector.mult( n, value ) );
                colorMode( HSB, 360, 100, 100 );
                  colour = color( hue( colour ), saturation( colour )-random( 5 ), brightness( colour ) );
                colorMode( RGB, 255, 255, 255 );
              }
              size = size + random( 1.0f );
              break;
            case 3:  // die
              return false;
          }
        }
        else  // no collision
        {
          switch( type )
          {
            case 1:  // water
              colorMode( HSB, 360, 100, 100 );
                if( saturation( colour ) < 80 )
                  colour = color( hue( colour ), saturation( colour )+1.0f, brightness( colour )+1.0f );
              colorMode( RGB, 255, 255, 255 );
              if( size >= 1.2f )
                size = size - 0.2f ;
              else
                size = 1.0f;
              break;
          }
        }
      }
      
      return true;
    }
    
    else
      return false;
  }
  
  public void Render()
  {
    stroke( colour );
    strokeWeight( size );
    point( position.x, position.y, position.z );
  }
}

// ParticleSystem.pde
// Ting-Chun Sun <dingjun@cs.nctu.edu.tw>
// Updated: 2011/04/13

class ParticleSystem
{
  int type;  // 1:water
  PVector position;
  PVector velocity;
  int count;
  int minLifespan, maxLifespan;  // @TODO: min&max
  int minColour, maxColour;  // @TODO: min&max
  float minSize, maxSize;  // @TODO: min&max
  ArrayList particle;

  ParticleSystem( int _type, PVector _position, PVector _velocity, int _count,
    int _minLifespan, int _maxLifespan, int _minColour, int _maxColour, float _minSize, float _maxSize )
  {
    type = _type;
    position = _position.get();
    velocity = _velocity.get();
    count = _count;
    minLifespan = _minLifespan;
    maxLifespan = _maxLifespan;
    minColour = _minColour;
    maxColour = _maxColour;
    minSize = _minSize;
    maxSize = _maxSize;
    particle = new ArrayList();
  }

  public void Update()
  {
    // current force
    for( int i=0; i<forceField.size(); i++ )
    {
      ForceField ff = (ForceField) forceField.get(i);
      switch( ff.type )
      {
        case 1:  // gravity
          ff.currentDirection = ff.direction.get();
          break;
          
        case 2:  // wind
          PVector randomDirection = new PVector( random( -ff.randomness, ff.randomness ),
            random( -ff.randomness, ff.randomness ), random( -ff.randomness, ff.randomness ) );
          ff.currentDirection = PVector.add( ff.direction, randomDirection );
          break;
      }
    }
    
    // current particle
    for( int i=0; i<particle.size(); i++ )
    {
      Particle p = (Particle) particle.get(i);
      if( !p.Update() )
        particle.remove(i);
    }

    // new particle
    PVector p = new PVector( random( position.x-2.0f, position.x+2.0f ),
      random( position.y-2.0f, position.z+2.0f ), random( position.z-2.0f, position.z+2.0f ) );
    for( int i=0; i<count; i++ )
    {
      int lifespan = (int) random( minLifespan, maxLifespan );
      int colour = color( random( red( minColour ), red( maxColour ) ),
        random( green( minColour ), green( maxColour ) ), random( blue( minColour ), blue( maxColour ) ) );
      float size = random( minSize, maxSize );
      particle.add( new Particle( type, p, velocity, lifespan, colour, size ) );
    }
  }

  public void Render()
  {
    for( int i=0; i<particle.size(); i++ )
    {
      Particle p = (Particle) particle.get(i);
      p.Render();
    }
  }
}

  static public void main(String args[]) {
    PApplet.main(new String[] { "--bgcolor=#F0F0F0", "ProcessingParticleSystem" });
  }
}
