import java.util.Map;
import java.util.Iterator;

int [][] graph;
HashMap<Integer, PVector> posDict;
int i=0;
boolean animate = false;

void setup(){
  
 size(640, 360);
 background(255);
 frameRate(200);
 stroke(0); 
 noLoop();
 int listEdges [][] = {{0,1},{0,2},{1,2},{2,3},{3,4},{3,5},{2,5},{2,6},{6,7},{7,8},{5,7}};
 graph = getHardCodedGraph(9,listEdges);
 //graph = getCloud(10);
// graph = getPolygon(5);
 posDict = randomPositions(graph.length);
}


void draw(){
 background(255); 
 int n= graph.length;
   print("\n\n ITERATION "+i+"\n\n");
   i++;
   HashMap<Integer, PVector> dispF = calculateDisp(posDict, graph);
   drawGraph(posDict,graph);
   posDict = updatePos(posDict, dispF, n);
}

PVector clipVectorToScreen(PVector cur){
    if (cur.y < 0){  cur.y = 0; }
    if (cur.x < 0){   cur.x = 0; }
    if (cur.y > height) {   cur.y = height; }
    if (cur.x > width) {  cur.x = width; }
    return cur;
}

HashMap<Integer,PVector> updatePos(HashMap<Integer, PVector> posDict, HashMap<Integer, PVector> dispF, int n){
  float delta= 0.1;
  for (int i=0; i<n; i++){
    PVector cur= posDict.get(i);
    PVector disp= dispF.get(i);
    disp.mult(delta);
    cur.add(disp);
    
    // clip to screen
    cur = clipVectorToScreen(cur);
    
    posDict.put(i,cur);
  }
  
  return posDict;
  
}

HashMap<Integer, PVector> calculateDisp(HashMap<Integer, PVector> posDict, int[][] graph){
  
  HashMap<Integer, PVector> dispF= new HashMap<Integer, PVector>();
  for(int i=0; i<graph.length; i++){
    PVector cur= new PVector();
    for(int j= 0; j<graph.length; j++){
      if (i==j){
        continue;
      }
      if(graph[i][j]==0){
        cur.add(repF(posDict.get(i),posDict.get(j)));
      } else {
        cur.add(sprF(posDict.get(i),posDict.get(j)));
      }
    }
    dispF.put(i, cur);
  }
  
//  print("\nDISP-F\n");
//  for (int i=0;i<graph.length;i++){
//
//            PVector pos = dispF.get(i);
//            System.out.println(i + ": " + pos.x + "," + pos.y);  
//} 
  
  return dispF;
}

PVector repF(PVector u, PVector v){
  int c = 10000;
  PVector utoV = PVector.sub(u,v); // this is working, but shouldn't it be sub(v,u)?
  float mag_sq = utoV.magSq();
  if (mag_sq == 0){
    throw new IllegalArgumentException("u and v are equal");
  }
  utoV.normalize();
  utoV.mult(c/mag_sq);
  
  
  return utoV;
}

PVector repFquick(PVector u, PVector v){
  int l=20;
  PVector utoV = PVector.sub(v,u);
  float mag = utoV.mag();
  if (mag == 0){
    print("u and v: "+u+","+v);
    throw new IllegalArgumentException("u and v are equal");
  }
  print("\nmag: "+mag);
  utoV.mult(l*l/mag);
  print("\nresult: "+utoV);
  return utoV;
  
}

PVector sprF(PVector u, PVector v){
 int c= 50;
 int l= 50;

 PVector utoV = PVector.sub(v,u);

 float mag= c*log(utoV.mag()/l);
 
 utoV.normalize();

 utoV.mult(mag);
 return utoV;
 
} 

void drawGraph(HashMap<Integer, PVector> posDict, int [] [] graph){
  strokeWeight(10);

  for (int i=0;i<graph.length;i++){
    strokeWeight(10);
    point(posDict.get(i).x,posDict.get(i).y); // draw point for every vertex
    
    strokeWeight(1);
    for (int j=0; j<graph[i].length; j++){
      if (graph[i][j] != graph[j][i]){
        throw new IllegalArgumentException("Invalid adjacency matrix: need graph(i,j)=graph(j,i)");
      }
      
      if (graph[i][j] == 1){
        line(posDict.get(i).x, posDict.get(i).y, posDict.get(j).x, posDict.get(j).y);
        // draw line for every edge
      }  
    }
  }

}

HashMap<Integer,PVector> randomPositions(int n){
  
  HashMap<Integer, PVector> posDict = new HashMap<Integer,PVector>();
  for (int i=0; i<n; i++){
    
    float x = random(width);
    float y = random(height);
    posDict.put(i, new PVector(x,y));
  }
  
  return posDict;
}

int[][] getCloud(int n){
  int [] [] adjMat= new int[n][n];
  for (int i=0;i<n;i++){
    for (int j=0; j<n; j++){
      adjMat[i][j] = 0;
    }
  }
  return adjMat;
}

int[][] getPolygon(int n){
  int [] [] adjMat= new int[n][n];
  
  for (int i=0;i<n;i++){
    for (int j=0; j<n; j++){
      adjMat[i][j] = 1;
    }
  }
  
  return adjMat;
  
}

int[][] getHardCodedGraph(int n, int[][] listEdges){
  int [] [] adjMat= new int[n][n];
  
  for (int i=0; i<listEdges.length; i++){
    int vi = listEdges[i][0];
    int vj = listEdges[i][1];
    adjMat[vi][vj] = 1;
    adjMat[vj][vi] = 1;
  }
  
  return adjMat;
}


void keyPressed() {
  if (key == ENTER) {
    redraw();
  }
}

void mousePressed() {
  animate = !animate;
  if (animate){
    loop();
  } else {
    noLoop();
  }
}
