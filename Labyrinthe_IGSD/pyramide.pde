import java.util.ArrayList;
import java.util.Collections;

int iposX = 1;
int iposY = -13;
int iposZ = 1;

int posX = iposX;
int posY = iposY;
int posZ = iposZ;


int dirX = 0;
int dirY = 1;
int odirX = 0;
int odirY = 1;
int WALLD = 1;
int niveau = 0;
int CELL_SIZE = 2;
int SPACE_BETWEEN_LABYRINTHS = 50;


int anim = 0;
boolean animT=false;
boolean animR=false;

boolean inLab = true;

int LAB_SIZE = 21;
char labyrinthe [][];
char sides [][][];
char[][] laby1;
char[][] laby2;
PShape laby0;
PShape ceiling0;
PShape ceiling1;



PImage  texture0;
PImage  texture1;
PImage  texture2;
void setup() {
  pixelDensity(2);
  randomSeed(2);
  size(1000, 1000, P3D);
  genererlaby(0);

  texture1 = loadImage("stones.jpg");
  momie();
}

void draw() {  
  background(135,206,235);
  sphereDetail(6);
  if (anim>0) anim--;
  translate(0,0,-1.5*height/LAB_SIZE);
  sol(2000);

  soleil();
 if(estsursortie()==true && key == '1'){
    teleportToSecondLabyrinth();
  }  
 if(estsurporte()==true){
   labyrinthe[0][1]                   = ' ';
 }

  draw2();
  translate(-150,-150,-150);
  sol(200);
  drawMomie();
  //shape(momie,200,200);
  translate(60,0, 0);
  drawMomie();

}

void keyPressed() {

  if (key=='l') inLab = !inLab;
   if(key=='c') {
     posX=LAB_SIZE-1;
     posY=LAB_SIZE-2;
   }
  if (anim==0 && keyCode==38) {
    if (!(posX+dirX>=0 && posX+dirX<LAB_SIZE && posY+dirY>=0 && posY+dirY<LAB_SIZE) ||
      labyrinthe[posY+dirY][posX+dirX]!='#') {  // modif du if
      posX+=dirX;
      posY+=dirY;
      anim=20;
      animT = true;
      animR = false;
    }
  } // modif du if
  if (anim==0 && keyCode==40 && (posY-dirY <0 || posX-dirX<0 || labyrinthe[posY-dirY][posX-dirX]!='#')) {
    posX-=dirX;
    posY-=dirY;
  }
  if (anim==0 && keyCode==37) {
    odirX = dirX;
    odirY = dirY;
    anim = 20;
    int tmp = dirX;
    dirX=dirY;
    dirY=-tmp;
    animT = false;
    animR = true;
  }
  if (anim==0 && keyCode==39) {
    odirX = dirX;
    odirY = dirY;
    anim = 20;
    animT = false;
    animR = true;
    int tmp = dirX;
    dirX=-dirY;
    dirY=tmp;
  }
  estsursortie();
  test();
  montedeniveau();
}

boolean estsursortie(){
  return (posX==LAB_SIZE-1 && posY==LAB_SIZE-2);
}


char[][] genererlaby(int niveau){
   LAB_SIZE = LAB_SIZE - niveau;
   
   texture0 = loadImage("stones.jpg");


  labyrinthe = new char[LAB_SIZE][LAB_SIZE];
  sides = new char[LAB_SIZE][LAB_SIZE][4];
  int todig = 0;
  for (int j=0; j<LAB_SIZE; j++) {
    for (int i=0; i<LAB_SIZE; i++) {
      sides[j][i][0] = 0;
      sides[j][i][1] = 0;
      sides[j][i][2] = 0;
      sides[j][i][3] = 0;
      if (j%2==1 && i%2==1) {
        labyrinthe[j][i] = '.';
        todig ++;
      } else
        labyrinthe[j][i] = '#';
    }
  }
  int gx = 1;
  int gy = 1;
  while (todig>0 ) {
    int oldgx = gx;
    int oldgy = gy;
    int alea = floor(random(0, 4)); // selon un tirage aleatoire
    if      (alea==0 && gx>1)          gx -= 2; // le fantome va a gauche
    else if (alea==1 && gy>1)          gy -= 2; // le fantome va en haut
    else if (alea==2 && gx<LAB_SIZE-2) gx += 2; // .. va a droite
    else if (alea==3 && gy<LAB_SIZE-2) gy += 2; // .. va en bas

    if (labyrinthe[gy][gx] == '.') {
      todig--;
      labyrinthe[gy][gx] = ' ';
      labyrinthe[(gy+oldgy)/2][(gx+oldgx)/2] = ' ';
    }
  }
 
  labyrinthe[0][1]                   = ' '; // entree
  labyrinthe[LAB_SIZE-2][LAB_SIZE-1] = ' '; // sortie

  for (int j=1; j<LAB_SIZE-1; j++) {
    for (int i=1; i<LAB_SIZE-1; i++) {
      if (labyrinthe[j][i]==' ') {
        if (labyrinthe[j-1][i]=='#' && labyrinthe[j+1][i]==' ' &&
          labyrinthe[j][i-1]=='#' && labyrinthe[j][i+1]=='#')
          sides[j-1][i][0] = 1;// c'est un bout de couloir vers le haut
        if (labyrinthe[j-1][i]==' ' && labyrinthe[j+1][i]=='#' &&
          labyrinthe[j][i-1]=='#' && labyrinthe[j][i+1]=='#')
          sides[j+1][i][3] = 1;// c'est un bout de couloir vers le bas
        if (labyrinthe[j-1][i]=='#' && labyrinthe[j+1][i]=='#' &&
          labyrinthe[j][i-1]==' ' && labyrinthe[j][i+1]=='#')
          sides[j][i+1][1] = 1;// c'est un bout de couloir vers la droite
        if (labyrinthe[j-1][i]=='#' && labyrinthe[j+1][i]=='#' &&
          labyrinthe[j][i-1]=='#' && labyrinthe[j][i+1]==' ')
          sides[j][i-1][2] = 1;// c'est un bout de couloir vers la gauche
      }
    }
  }
   


  //un affichage texte pour vous aider a visualiser le labyrinthe en 2D
  for (int j=0; j<LAB_SIZE; j++) {
    for (int i=0; i<LAB_SIZE; i++) {
      print(labyrinthe[j][i]);
    }
    println("");
  }
  float wallW = width/LAB_SIZE;
  float wallH = height/LAB_SIZE;

  ceiling0 = createShape();
  ceiling1 = createShape();
 
  ceiling1.beginShape(QUADS);
  ceiling0.beginShape(QUADS);
 
  laby0 = createShape();
  laby0.beginShape(QUADS);
  laby0.texture(texture0);
  //Pyramide = createShape();
  //Pyramide.beginShape(QUADS);
  //Pyramide.texture(texture1);
  laby0.noStroke();
  //laby0.stroke(255, 32);
  //laby0.strokeWeight(0.5);
 
  laby0.tint(255,255,0);
  for(int n = 0; n <= 10; n++){
  for (int j=0; j<LAB_SIZE-n*2; j++) {
    for (int i=0; i<LAB_SIZE-n*2; i++) {
      if (labyrinthe[j][i]=='#') {
       if(n>=1){
          labyrinthe[0][1]                   = '#';
       }
        laby0.fill(i*25, j*25, 255-i*10+j*10);
        if (j==0 || labyrinthe[j-1][i]==' ') {
          laby0.normal(0, -1, 0);
          for (int k=0; k<WALLD; k++)
            for (int l=-WALLD; l<WALLD; l++) {
              //float d1 = 15*(noise(0.3*(i*WALLD+(k+0)), 0.3*(j*WALLD), 0.3*(l+0))-0.5);
              //if (k==0)  d1=0;
              //if (l==-WALLD) d1=-2*abs(d1);
             
              if (j==0) laby0.tint(223,175,44);
              laby0.vertex(i*wallW-wallW/2+(k+0)*wallW/WALLD+n*50, j*wallH-wallH/2+n*50, (l+0)*50/WALLD +n*100, k/(float)WALLD*texture0.width, (0.5+l/2.0/WALLD)*texture0.height);
             
              //float d2 =15*(noise(0.3*(i*WALLD+(k+1)), 0.3*(j*WALLD), 0.3*(l+0))-0.5);
              //if (k+1==WALLD ) d2=0;
              //if (l==-WALLD) d2=-2*abs(d2);
              laby0.vertex(i*wallW-wallW/2+(k+1)*wallW/WALLD+n*50, j*wallH-wallH/2+n*50, (l+0)*50/WALLD +n*100, (k+1)/(float)WALLD*texture0.width, (0.5+l/2.0/WALLD)*texture0.height);
             
              //float d3 = 15*(noise(0.3*(i*WALLD+(k+1)), 0.3*(j*WALLD), 0.3*(l+1))-0.5);
              //if (k+1==WALLD ||l+1==WALLD) d3=0;
              laby0.vertex(i*wallW-wallW/2+(k+1)*wallW/WALLD+n*50, j*wallH-wallH/2+n*50, (l+1)*50/WALLD +n*100, (k+1)/(float)WALLD*texture0.width, (0.5+(l+1)/2.0/WALLD)*texture0.height);
             
              //float d4 = 15*(noise(0.3*(i*WALLD+(k+0)), 0.3*(j*WALLD), 0.3*(l+1))-0.5);
              //if (k==0 ||l+1==WALLD) d4=0;
              laby0.vertex(i*wallW-wallW/2+(k+0)*wallW/WALLD+n*50, j*wallH-wallH/2+n*50, (l+1)*50/WALLD +n*100, k/(float)WALLD*texture0.width, (0.5+(l+1)/2.0/WALLD)*texture0.height);
            }
            laby0.noTint();
        }

        if (j==LAB_SIZE-1 || labyrinthe[j+1][i]==' ') {
          laby0.normal(0, 1, 0);
          for (int k=0; k<WALLD; k++)
            for (int l=-WALLD; l<WALLD; l++) {
             
              if (j==LAB_SIZE-1) laby0.tint(223,175,44);
              laby0.vertex(i*wallW-wallW/2+(k+0)*wallW/WALLD+n*50, j*wallH+wallH/2+n*50, (l+1)*50/WALLD +n*100, (k+0)/(float)WALLD*texture0.width, (0.5+(l+1)/2.0/WALLD)*texture0.height);
              laby0.vertex(i*wallW-wallW/2+(k+1)*wallW/WALLD+n*50, j*wallH+wallH/2+n*50, (l+1)*50/WALLD +n*100, (k+1)/(float)WALLD*texture0.width, (0.5+(l+1)/2.0/WALLD)*texture0.height);
              laby0.vertex(i*wallW-wallW/2+(k+1)*wallW/WALLD+n*50, j*wallH+wallH/2+n*50, (l+0)*50/WALLD +n*100, (k+1)/(float)WALLD*texture0.width, (0.5+(l+0)/2.0/WALLD)*texture0.height);
              laby0.vertex(i*wallW-wallW/2+(k+0)*wallW/WALLD+n*50, j*wallH+wallH/2+n*50, (l+0)*50/WALLD +n*100, (k+0)/(float)WALLD*texture0.width, (0.5+(l+0)/2.0/WALLD)*texture0.height);
            }
            laby0.noTint();
        }

        if (i==0 || labyrinthe[j][i-1]==' ') {
          laby0.normal(-1, 1, 0);
          for (int k=0; k<WALLD; k++)
            for (int l=-WALLD; l<WALLD; l++) {
             
             if (i == 0) laby0.tint(223,175,44);
             
              laby0.vertex(i*wallW-wallW/2+n*50, j*wallH-wallH/2+(k+0)*wallW/WALLD+n*50, (l+1)*50/WALLD+n*100, (k+0)/(float)WALLD*texture0.width, (0.5+(l+1)/2.0/WALLD)*texture0.height);
              laby0.vertex(i*wallW-wallW/2+n*50, j*wallH-wallH/2+(k+1)*wallW/WALLD+n*50, (l+1)*50/WALLD+n*100, (k+1)/(float)WALLD*texture0.width, (0.5+(l+1)/2.0/WALLD)*texture0.height);
              laby0.vertex(i*wallW-wallW/2+n*50, j*wallH-wallH/2+(k+1)*wallW/WALLD+n*50, (l+0)*50/WALLD+n*100, (k+1)/(float)WALLD*texture0.width, (0.5+(l+0)/2.0/WALLD)*texture0.height);
              laby0.vertex(i*wallW-wallW/2+n*50, j*wallH-wallH/2+(k+0)*wallW/WALLD+n*50, (l+0)*50/WALLD+n*100, (k+0)/(float)WALLD*texture0.width, (0.5+(l+0)/2.0/WALLD)*texture0.height);
            }
            laby0.noTint();
        }

        if (i==LAB_SIZE-1 || labyrinthe[j][i+1]==' ') {
          laby0.normal(1, 0, 0);
          for (int k=0; k<WALLD; k++)
            for (int l=-WALLD; l<WALLD; l++) {
             
              if (i==LAB_SIZE-1) laby0.tint(223,175,44);
             
              laby0.vertex(i*wallW+wallW/2 +n*50, j*wallH-wallH/2+(k+0)*wallW/WALLD +n*50, (l+0)*50/WALLD+n*100, (k+0)/(float)WALLD*texture0.width, (0.5+(l+0)/2.0/WALLD)*texture0.height);
              laby0.vertex(i*wallW+wallW/2 +n*50, j*wallH-wallH/2+(k+1)*wallW/WALLD +n*50, (l+0)*50/WALLD+n*100, (k+1)/(float)WALLD*texture0.width, (0.5+(l+0)/2.0/WALLD)*texture0.height);
              laby0.vertex(i*wallW+wallW/2 +n*50, j*wallH-wallH/2+(k+1)*wallW/WALLD +n*50, (l+1)*50/WALLD+n*100, (k+1)/(float)WALLD*texture0.width, (0.5+(l+1)/2.0/WALLD)*texture0.height);
              laby0.vertex(i*wallW+wallW/2 +n*50, j*wallH-wallH/2+(k+0)*wallW/WALLD +n*50, (l+1)*50/WALLD+n*100, (k+0)/(float)WALLD*texture0.width, (0.5+(l+1)/2.0/WALLD)*texture0.height);
            }
            laby0.noTint();
        }
        ceiling1.fill(32, 255, 0);
        ceiling1.vertex(i*wallW-wallW/2+n*50, j*wallH-wallH/2+n*50, 50+n*100);
        ceiling1.vertex(i*wallW+wallW/2+n*50, j*wallH-wallH/2+n*50, 50+n*100);
        ceiling1.vertex(i*wallW+wallW/2+n*50, j*wallH+wallH/2+n*50, 50+n*100);
        ceiling1.vertex(i*wallW-wallW/2+n*50, j*wallH+wallH/2+n*50, 50+n*100);        
      } else {
        laby0.fill(192); // ground
        laby0.vertex(i*wallW-wallW/2, j*wallH-wallH/2, -50, 0, 0);
        laby0.vertex(i*wallW+wallW/2, j*wallH-wallH/2, -50, 0, 1);
        laby0.vertex(i*wallW+wallW/2, j*wallH+wallH/2, -50, 1, 1);
        laby0.vertex(i*wallW-wallW/2, j*wallH+wallH/2, -50, 1, 0);
       
        ceiling0.fill(32); // top of walls
        ceiling0.vertex(i*wallW-wallW/2+n*50, j*wallH-wallH/2+n*50, 50+n*100);
        ceiling0.vertex(i*wallW+wallW/2+n*50, j*wallH-wallH/2+n*50, 50+n*100);
        ceiling0.vertex(i*wallW+wallW/2+n*50, j*wallH+wallH/2+n*50, 50+n*100);
        ceiling0.vertex(i*wallW-wallW/2+n*50, j*wallH+wallH/2+n*50, 50+n*100);
      }
    }
  }

 
 
 
  }
  laby0.endShape();
  ceiling0.endShape();
  ceiling1.endShape();
 return labyrinthe;
}
 
 

 
void test(){
 
  println(posX,posY,niveau);
}
ArrayList<char[][]> labyrinthes = new ArrayList<char[][]>();

  void genererLabyrinthes() {
 
    labyrinthes.add(genererlaby(0));
   
    labyrinthes.add(genererlaby(6));
   
  }
  void drawLabyrinth(char[][] labyrinthe) {
  int offsetX = (LAB_SIZE * CELL_SIZE + SPACE_BETWEEN_LABYRINTHS);
 
  for (int j = 0; j < LAB_SIZE; j++) {
    for (int i = 0; i < LAB_SIZE; i++) {
      if (labyrinthe[j][i] == '#') {
        image(texture0, offsetX + i * CELL_SIZE, j * CELL_SIZE, CELL_SIZE, CELL_SIZE);
      }
    }
  }
}
int montedeniveau(){
  if (estsursortie()==true){
    niveau++;
  }
  return niveau;
}
void teleportToSecondLabyrinth() {
  // Mettre à jour la variable labyrinthe pour contenir le deuxième labyrinthe

  // Définir la position actuelle pour correspondre à celle du deuxième labyrinthe
  posX = iposX;
  posY = iposY;
  // Mettre à jour les variables de direction pour correspondre à la première cellule du labyrinthe
  dirX = 0;
  dirY = 1;
  // Mettre à jour les variables d'orientation de direction pour correspondre à la première cellule du labyrinthe
  odirX = 0;
  odirY = 1;
  // Mettre à jour la variable inLab pour indiquer que le joueur est dans le labyrinthe
  inLab = true;

}

void dessinlaby(){
 
  float wallW = width/LAB_SIZE;
  float wallH = height/LAB_SIZE;

  perspective();
  camera(width/2.0, height/2.0, (height/2.0) / tan(PI*30.0 / 180.0), width/2.0, height/2.0, 0, 0, 1, 0);
  noLights();
  stroke(0);
  for (int j=0; j<LAB_SIZE; j++) {
    for (int i=0; i<LAB_SIZE; i++) {
      if (labyrinthe[j][i]=='#') {
        fill(i*25, j*25, 255-i*10+j*10);
        pushMatrix();
        translate(50+i*wallW/8, 50+j*wallH/8, 50);
        box(wallW/10, wallH/10, 5);
        popMatrix();
      }
    }
  }
  pushMatrix();
  fill(0, 255, 0);
  noStroke();
  translate(50+posX*wallW/8, 50+posY*wallH/8, 50);
  sphere(3);
  popMatrix();

  stroke(0);
  if (inLab) {
    perspective(2*PI/3, float(width)/float(height), 1, 10000);
    if (animT){
      camera((posX-dirX*anim/20.0)*wallW,      (posY-dirY*anim/20.0)*wallH,      -15+2*sin(anim*PI/5.0),
             (posX-dirX*anim/20.0+dirX)*wallW, (posY-dirY*anim/20.0+dirY)*wallH, -15+4*sin(anim*PI/5.0), 0, 0, -1);
             /*camera((posX-dirX*anim/20.0)*wallW, (posY-dirY*anim/20.0)*wallH, -15+6*sin(anim*PI/20.0), (posX+dirX-dirX*anim/20.0)*wallW, (posY+dirY-dirY*anim/20.0)*wallH, -15+10*sin(anim*PI/20.0), 0, 0, -1);*/
           }
    else if (animR)
      camera(posX*wallW, posY*wallH, -15,
            (posX+(odirX*anim+dirX*(20-anim))/20.0)*wallW, (posY+(odirY*anim+dirY*(20-anim))/20.0)*wallH, -15-5*sin(anim*PI/20.0), 0, 0, -1);
    else {
      camera(posX*wallW, posY*wallH, -15,
             (posX+dirX)*wallW, (posY+dirY)*wallH, -15, 0, 0, -1);
    }
   

    if (posX>=0 && posX<LAB_SIZE && posY>=0 && posY+dirY<LAB_SIZE)
      lightFalloff(0.0, 0.01, 0.0001);
    pointLight(255, 255, 255, posX*wallW, posY*wallH, 15);
  } else{
    lightFalloff(0.0, 0.05, 0.0001);
    ambientLight(255, 255, 255);
    pointLight(255, 255, 255,posX*wallW, posY*wallH, 15);
  }

  noStroke();
  for (int j=0; j<LAB_SIZE; j++) {
    for (int i=0; i<LAB_SIZE; i++) {
      pushMatrix();
      translate(i*wallW, j*wallH, 0);
      if (labyrinthe[j][i]=='#') {
        beginShape(QUADS);
        if (sides[j][i][3]==1) {
          pushMatrix();
          translate(0, -wallH/2, 40);
          if (i==posX || j==posY) {
            fill(i*25, j*25, 255-i*10+j*10);
            sphere(5);              
            spotLight(i*25, j*25, 255-i*10+j*10, 0, -15, 15, 0, 0, -1, PI/4, 1);
          } else {
            fill(128);
            sphere(15);
          }
          popMatrix();
        }

        if (sides[j][i][0]==1) {
          pushMatrix();
          translate(0, wallH/2, 40);
          if (i==posX || j==posY) {
            fill(i*25, j*25, 255-i*10+j*10);
            sphere(5);              
            spotLight(i*25, j*25, 255-i*10+j*10, 0, -15, 15, 0, 0, -1, PI/4, 1);
          } else {
            fill(128);
            sphere(15);
          }
          popMatrix();
        }
         
         if (sides[j][i][1]==1) {
          pushMatrix();
          translate(-wallW/2, 0, 40);
          if (i==posX || j==posY) {
            fill(i*25, j*25, 255-i*10+j*10);
            sphere(5);              
            spotLight(i*25, j*25, 255-i*10+j*10, 0, -15, 15, 0, 0, -1, PI/4, 1);
          } else {
            fill(128);
            sphere(15);
          }
          popMatrix();
        }
         
        if (sides[j][i][2]==1) {
          pushMatrix();
          translate(0, wallH/2, 40);
          if (i==posX || j==posY) {
            fill(i*25, j*25, 255-i*10+j*10);
            sphere(5);              
            spotLight(i*25, j*25, 255-i*10+j*10, 0, -15, 15, 0, 0, -1, PI/4, 1);
          } else {
            fill(128);
            sphere(15);
          }
          popMatrix();
        }
      }
      popMatrix();
    }
  }
 
  shape(laby0, 0, 0);
  if (inLab)
    shape(ceiling0, 0, 0);
  else
    shape(ceiling1, 0, 0);
}
boolean estsurporte(){
  return (posX==1 && posY==-1);
}

void draw2(){
   float wallW = width/LAB_SIZE;
  float wallH = height/LAB_SIZE;

  perspective();
  camera(width/2.0, height/2.0, (height/2.0) / tan(PI*30.0 / 180.0), width/2.0, height/2.0, 0, 0, 1, 0);
  noLights();
  stroke(0);
  for (int j=0; j<LAB_SIZE; j++) {
    for (int i=0; i<LAB_SIZE; i++) {
      if (labyrinthe[j][i]=='#') {
        fill(i*25, j*25, 255-i*10+j*10);
        pushMatrix();
        translate(50+i*wallW/8, 50+j*wallH/8, 50);
        box(wallW/10, wallH/10, 5);
        popMatrix();
      }
    }
  }
  pushMatrix();
  fill(0, 255, 0);
  noStroke();
  translate(50+posX*wallW/8, 50+posY*wallH/8, 50);
  sphere(3);
  popMatrix();

  stroke(0);
  if (inLab) {
    perspective(2*PI/3, float(width)/float(height), 1, 10000);
    if (animT){
      camera((posX-dirX*anim/20.0)*wallW,      (posY-dirY*anim/20.0)*wallH,      -15+2*sin(anim*PI/5.0),
             (posX-dirX*anim/20.0+dirX)*wallW, (posY-dirY*anim/20.0+dirY)*wallH, -15+4*sin(anim*PI/5.0), 0, 0, -1);
             /*camera((posX-dirX*anim/20.0)*wallW, (posY-dirY*anim/20.0)*wallH, -15+6*sin(anim*PI/20.0), (posX+dirX-dirX*anim/20.0)*wallW, (posY+dirY-dirY*anim/20.0)*wallH, -15+10*sin(anim*PI/20.0), 0, 0, -1);*/
           }
    else if (animR)
      camera(posX*wallW, posY*wallH, -15,
            (posX+(odirX*anim+dirX*(20-anim))/20.0)*wallW, (posY+(odirY*anim+dirY*(20-anim))/20.0)*wallH, -15-5*sin(anim*PI/20.0), 0, 0, -1);
    else {
      camera(posX*wallW, posY*wallH, -15,
             (posX+dirX)*wallW, (posY+dirY)*wallH, -15, 0, 0, -1);
    }
   

    if (posX>=0 && posX<LAB_SIZE && posY>=0 && posY+dirY<LAB_SIZE)
      lightFalloff(0.0, 0.01, 0.0001);
    pointLight(255, 255, 255, posX*wallW, posY*wallH, 15);
  } else{
    lightFalloff(0.0, 0.05, 0.0001);
    ambientLight(255, 255, 255);
    pointLight(255, 255, 255,posX*wallW, posY*wallH, 15);
  }

  noStroke();
  for (int j=0; j<LAB_SIZE; j++) {
    for (int i=0; i<LAB_SIZE; i++) {
      pushMatrix();
      translate(i*wallW, j*wallH, 0);
      if (labyrinthe[j][i]=='#') {
        beginShape(QUADS);
        if (sides[j][i][3]==1) {
          pushMatrix();
          translate(0, -wallH/2, 40);
          if (i==posX || j==posY) {
            fill(i*25, j*25, 255-i*10+j*10);
            sphere(5);              
            spotLight(i*25, j*25, 255-i*10+j*10, 0, -15, 15, 0, 0, -1, PI/4, 1);
          } else {
            fill(128);
            sphere(15);
          }
          popMatrix();
        }

        if (sides[j][i][0]==1) {
          pushMatrix();
          translate(0, wallH/2, 40);
          if (i==posX || j==posY) {
            fill(i*25, j*25, 255-i*10+j*10);
            sphere(5);              
            spotLight(i*25, j*25, 255-i*10+j*10, 0, -15, 15, 0, 0, -1, PI/4, 1);
          } else {
            fill(128);
            sphere(15);
          }
          popMatrix();
        }
         
         if (sides[j][i][1]==1) {
          pushMatrix();
          translate(-wallW/2, 0, 40);
          if (i==posX || j==posY) {
            fill(i*25, j*25, 255-i*10+j*10);
            sphere(5);              
            spotLight(i*25, j*25, 255-i*10+j*10, 0, -15, 15, 0, 0, -1, PI/4, 1);
          } else {
            fill(128);
            sphere(15);
          }
          popMatrix();
        }
         
        if (sides[j][i][2]==1) {
          pushMatrix();
          translate(0, wallH/2, 40);
          if (i==posX || j==posY) {
            fill(i*25, j*25, 255-i*10+j*10);
            sphere(5);              
            spotLight(i*25, j*25, 255-i*10+j*10, 0, -15, 15, 0, 0, -1, PI/4, 1);
          } else {
            fill(128);
            sphere(15);
          }
          popMatrix();
        }
      }
      popMatrix();
    }
  }
 
  shape(laby0, 0, 0);
  if (inLab)
    shape(ceiling0, 0, 0);
  else
    shape(ceiling1, 0, 0);
}


void sol(int a){
rotateX(PI/2);
fill(237, 216, 123);
beginShape();
noStroke();
pushMatrix();
vertex(-a,0,-a);
vertex(-a,0,a);
vertex(a,0,a);
vertex(a,0,-a);
endShape();
popMatrix();
}


void soleil() {
  float centerX = width/2;
  float centerY = height - 50;
  float radius = min(width, height)/8 - 20;

  // Draw sun rays
  pushMatrix();
  translate(centerX, centerY);
  strokeWeight(2);
  stroke(255, 242, 0);
  for (int i = 0; i < 360; i += 30) {
    float angleRadians = radians(i);
    float x1 = cos(angleRadians) * radius * 1.1;
    float y1 = sin(angleRadians) * radius * 1.1;
    float x2 = cos(angleRadians) * radius * 1.4;
    float y2 = sin(angleRadians) * radius * 1.4;
    line(x1, y1, x2, y2);
    
    // Draw small yellow circles at the end of each ray
    fill(255, 242, 0);
    noStroke();
    float x3 = cos(angleRadians) * radius * 1.45;
    float y3 = sin(angleRadians) * radius * 1.45;
    ellipse(x2, y2, radius/6, radius/6);
    ellipse(x3, y3, radius/6, radius/6);
  }
  popMatrix();

  // Draw sun
  pushMatrix();
  translate(centerX, centerY);
  noStroke();
  fill(255, 242, 0);
  ellipse(0, 0, radius*2, radius*2);
  popMatrix();
}
void drawCompass() {
  // Calculer la position de la boussole en bas à droite de l'écran

  // Calculer l'angle de la flèche de la boussole en fonction de la direction du joueur
  float angle = atan2(dirY, dirX);

  // Sauvegarder l'état actuel du dessin et des transformations
  pushStyle();
  pushMatrix();
  
  // Positionner la boussole en bas à droite de l'écran
  translate(130, 200);

  // Dessiner le cercle de la boussole
  stroke(0);
  fill(255);
  ellipse(0, 0, 20 * 2, 20 * 2);

  // Appliquer la rotation à la flèche de la boussole
  rotate(angle + HALF_PI); // Ajouter HALF_PI pour aligner la flèche avec la direction

  // Dessiner la flèche de la boussole
  stroke(255, 0, 0);
  line(0, 0, 0, -20);

  // Restaurer l'état du dessin et des transformations
  popMatrix();
  popStyle();
}
