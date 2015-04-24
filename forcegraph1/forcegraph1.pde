import java.util.Map;
import java.util.Iterator;

int [][] graph;
HashMap<Integer, PVector> posDict;
int i=0;
boolean animate = false;
float stop_threshold = 0.005;
boolean belowStopThreshold = false;

void setup(){
  
 size(640, 360);
 background(255);
 frameRate(400);
 stroke(0); 
 noLoop();
 int listEdges [][] = {{0,1},{0,2},{1,2},{2,3},{3,4},{3,5},{2,5},{2,6},{6,7},{7,8},{5,7}};
 //graph = getHardCodedGraph(9,listEdges);
 //graph = getCloud(10);
 graph = getPolygon(21); // polygons of size > 22 are not reaching equilibrium for some reason????
 posDict = randomPositions(graph.length);
}

boolean doSegIntersect(PVector uA, PVector uB, PVector vA, PVector vB){
  // credit http://processingjs.org/learning/custom/intersect/

  float x1, y1, x2, y2, x3, y3, x4, y4; 
  x1 = uA.x;
  y1 = uA.y; 
  x2 = uB.x; 
  y2 = uB.y; 
  x3 = vA.x;
  y3 = vA.y; 
  x4 = vB.x; 
  y4 = vB.y;
  
  float a1, a2, b1, b2, c1, c2;
  float r1, r2 , r3, r4;
  float denom, offset, num;

  // Compute a1, b1, c1, where line joining points 1 and 2
  // is "a1 x + b1 y + c1 = 0".
  a1 = y2 - y1;
  b1 = x1 - x2;
  c1 = (x2 * y1) - (x1 * y2);

  // Compute r3 and r4.
  r3 = ((a1 * x3) + (b1 * y3) + c1);
  r4 = ((a1 * x4) + (b1 * y4) + c1);

  // Check signs of r3 and r4. If both point 3 and point 4 lie on
  // same side of line 1, the line segments do not intersect.
  if ((r3 != 0) && (r4 != 0) && same_sign(r3, r4)){
    return false;
  }

  // Compute a2, b2, c2
  a2 = y4 - y3;
  b2 = x3 - x4;
  c2 = (x4 * y3) - (x3 * y4);

  // Compute r1 and r2
  r1 = (a2 * x1) + (b2 * y1) + c2;
  r2 = (a2 * x2) + (b2 * y2) + c2;

  // Check signs of r1 and r2. If both point 1 and point 2 lie
  // on same side of second line segment, the line segments do
  // not intersect.
  if ((r1 != 0) && (r2 != 0) && (same_sign(r1, r2))){
    return false;
  }
  
  return true;

}

boolean same_sign(float a, float b){
  return (( a * b) >= 0);
}


int calculateNumCrossings(){
  
  int total = 0;
  
  ArrayList<ArrayList<PVector>> segments = new ArrayList<ArrayList<PVector>>();
  
  for (int i=0; i<graph.length; i++){
    for (int j=i; j<graph[i].length; j++){
      // starting at j=i since we only need to check the upper-triangular matrix
      if (graph[i][j] == 1) { // if there is an edge between i and j
        PVector vA = posDict.get(i);
        PVector vB = posDict.get(j);
        
        // check to see if it intersects with any of the previous segments
        for (ArrayList<PVector> line2 : segments) {
          if (doSegIntersect(line2.get(0), line2.get(1), vA, vB)){
            total += 1;
          }
        }
        
        // add it to the list to be checked against future segments
        ArrayList<PVector> line = new ArrayList<PVector>();
        line.add(vA);
        line.add(vB);
        
        segments.add(line);
      }
    }
  }
  
  return total;
  
}


void draw(){
 background(255); 
 int n= graph.length;
   print("\n\n ITERATION "+i+"\n\n");
   i++;
   HashMap<Integer, PVector> dispF = calculateDisp(posDict, graph);
   // will also set the variable belowStopThreshold to true if all the displacements are less
   // than the constant stop_threshold
   
   drawGraph(posDict,graph);
   print("\n crossings: "+calculateNumCrossings());

   if (belowStopThreshold){
     noLoop();
     print("\n crossings: "+calculateNumCrossings());
   } else {
     posDict = updatePos(posDict, dispF, n);
   }
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
  
  belowStopThreshold = true;
  
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
    print("\n"+cur.mag());
    
    if (cur.mag() > stop_threshold){
      belowStopThreshold = false;
    }
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
  // we're not using this
  
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
    for (int j=i; j<graph[i].length; j++){
      // starting at j=i since we only need to draw the upper triangular matrix
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
