float corpsR = 100; 
float teteR = 70;
float brasR = 50;
PShape momie;
PShape oeil;

PShape momie() {
  momie = createShape(GROUP);
  
  PShape torse = createShape();
  torse.beginShape(QUAD_STRIP);
  torse.noStroke();
  for (int z=1; z<=64; z++){
    for (int i=0; i<32; i++){
      float deg =  i*PI/16; // determine l'angle des points qui composent le quad_STRIP
      float z1 = (z-1)+i/32.; 
      z1 += 3*noise(z1);
      float z2 = (z+1)+i/32.; 
      z2 += 3*noise(z2);
      torse.emissive( 20 + noise(deg,z1)*50 , 20 + 50*noise(deg,z1), 0);

      float rx = 2 + corpsR/10*sin(z*PI/64) + corpsR/30*noise(deg, z1);
      float ry = 1+ corpsR/10*sin(z*PI/64)+ corpsR/30*noise(deg, z1);
      torse.vertex(rx*cos(deg), ry*sin(deg), z1 );
      torse.vertex(rx*cos(deg), ry*sin(deg), z2 );
      torse.fill(0,75*noise(z1,z2),0);
    }
  }
  torse.endShape();
  
  momie.addChild(torse);
  momie.addChild(fullTete());
  
  PShape bras1 = createShape();
  bras1.beginShape(QUAD_STRIP);
  PShape bras2 = createShape();
  bras2.beginShape(QUAD_STRIP);
  bras1.noStroke();
  bras2.noStroke();
  for (int z=0; z<30; z++)
    for (int i=0; i<32; i++){
      float deg = i* PI/16;
      float z1 = (z-1)+i/32.0-5; 
      z1 += 3*noise(z1/1.0)-5;
      float z2 = (z+1)+i/32.0-5; 
      z2 += 3*noise(z2/1.0)-5;
      bras1.emissive( 20 + noise(deg,z1)*50 , 20 + 50*noise(deg,z1), 0);
      bras2.emissive( 20 + noise(deg,z1)*50 , 20 + 50*noise(deg,z1), 0);
      float rx = brasR/15+ 2*noise(z1, deg);
      float ry = brasR/15+ 2*noise(z1, deg); 
      bras1.fill(0,75*noise(z1,z2),0);
      bras2.fill(0,75*noise(z1,z2),0);
      bras1.vertex(rx*cos(deg), ry*sin(deg), z1);
      bras1.vertex(rx*cos(deg), ry*sin(deg), z2);
      bras2.vertex(-rx*cos(deg), ry*sin(deg), z1);
      bras2.vertex(-rx*cos(deg), ry*sin(deg), z2);      
    }
    
  bras1.endShape();
  bras2.endShape();
  PShape main2 = loadShape("hand1.obj");
  PShape main1 = loadShape("hand2.obj");
  bras1.translate(10, -50, 10);
  
  main1.rotateZ(PI/2);
  main1.rotateY(PI/2);
  main1.translate(25, -13, 47);
  main1.rotateZ(PI/2);
  
  main2.rotateX(PI/2);
  main2.rotateZ(PI);
  main2.translate(-13, 25, 47);
  
  bras1.rotateX(-PI/2);
  bras2.translate(-10, -50, 10);
  bras2.rotateX(-PI/2);
  momie.addChild(bras1);
  momie.addChild(bras2); 

  momie.addChild(main1);
  momie.addChild(main2);
  
  PShape oeilG = oeil();
  oeilG.translate(4,7,75);
  momie.addChild(oeilG);
  
  PShape oeilD = oeil();
  oeilD.translate(-4,7,75);
  momie.addChild(oeilD);
  
  return momie;
}
  
PShape oeil() {
  PShape oeil = createShape(GROUP);
  oeil.beginShape();
  
  //sphère blanche pour le blanc de l'oeil
  PShape blanc = createShape(SPHERE, 1.5);
  blanc.setStroke(false);
  blanc.fill(255);
  blanc.endShape();
  oeil.addChild(blanc);
 
  //sphère noire pour la iris
  PShape iris = createShape(SPHERE, 0.5);
  iris.setStroke(false);
  iris.setFill(color(0));
  iris.translate(0, 1.5, 0);
  oeil.addChild(iris);
  blanc.endShape();
  iris.endShape();
  
  return oeil;
}


PShape demiTete(){
  PShape demiTete = createShape();
  demiTete.beginShape(QUAD_STRIP);
  demiTete.noStroke();
  for (int z=64; z<=84; z++){
    for(int i=0; i<32; i++){
      float deg = i*PI/12;
      float z1 = 64 +0.40*(z-64)-3; 
      z1 += 3*noise(z1);
      float z2 = 64 + 0.40*(z-64)+3; 
      z2 += 3*noise(z2);
      demiTete.emissive( 40 + noise(deg,z1)*50 , 40 + 50*noise(deg,z1), 0);
      //TETE.normal(cos(deg), sin(deg), 0);
      float rx = 3 + teteR/12*sin(2*(z-64)/32.0);
      float ry = 3 + teteR/12*sin(2*(z-64)/32.0);
      
      demiTete.vertex(rx*cos(deg), ry*sin(deg), z1);
      demiTete.vertex(rx*cos(deg), ry*sin(deg), z2);
      demiTete.fill(0,75*noise(z1,z2),0);
    }
  }
  demiTete.endShape();
  return demiTete;
}

PShape fullTete(){
  PShape fullTete = createShape(GROUP);
  fullTete.beginShape();
  PShape t1 = createShape();
  t1 = demiTete();
  
  PShape t2 = createShape();
  t2 = demiTete();
  t2.translate(0, 0,-150);
  t2.rotateX(PI);
  
  fullTete.addChild(t1);
  t1.endShape();
  t2.endShape();
  fullTete.addChild(t2);

  return fullTete;
}


  

void drawMomie() {
  //background(200);
  pushMatrix();
  translate(-300+width/2, 100, 350);
  rotateX(-PI/2);
  
  shape(momie(),0,0);
  popMatrix();
}
