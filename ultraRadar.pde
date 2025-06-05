import processing.serial.*;
import java.io.PrintWriter; // Import for file writing

Serial myPort;

String data = "";
String distanceStr = "";

int iDistance;
float pixsDistance;

int angle = 15;
int angleStep = 1;
int[] distances = new int[181]; // stores distances for 0° to 180°

PrintWriter output; // CSV writer

void setup() {
  size(1200, 700);
  myPort = new Serial(this, "COM4", 9600);
  myPort.bufferUntil('.');
  smooth();
  
  // Open CSV file for writing (will overwrite each run)
  output = createWriter("radar_data.csv");
  // Write CSV header
  output.println("timestamp,angle,distance_cm");
}

void draw() {
  background(0);
  drawRadar();
  drawSweepLine();
  drawDetectedObjects();
  drawText();

  // sweep angle
  angle += angleStep;
  if (angle >= 165 || angle <= 15) {
    angleStep *= -1;
  }
}

void serialEvent(Serial myPort) {
  data = myPort.readStringUntil('.');
  if (data != null) {
    data = trim(data);
    int commaIndex = data.indexOf(',');
    if (commaIndex > 0) {
      distanceStr = data.substring(commaIndex + 1);
      iDistance = int(distanceStr);
      distances[angle] = iDistance;
      
      // Get current timestamp (in milliseconds since program start)
      String timestamp = str(millis());
      // Write data to CSV: timestamp, angle, distance
      output.println(timestamp + "," + angle + "," + iDistance);
      output.flush(); // Ensure data is written immediately
    }
  }
}

void drawRadar() {
  pushMatrix();
  translate(width / 2, height - height * 0.074);
  stroke(98, 245, 31);
  noFill();
  strokeWeight(2);

  // arcs
  for (int r = 1; r <= 4; r++) {
    arc(0, 0, r * 150, r * 150, PI, TWO_PI);
  }

  // angle lines
  for (int a = 15; a <= 165; a += 15) {
    float x = 300 * cos(radians(a));
    float y = -300 * sin(radians(a));
    line(0, 0, x, y);
  }

  popMatrix();
}

void drawSweepLine() {
  pushMatrix();
  translate(width / 2, height - height * 0.074);
  stroke(30, 250, 60);
  strokeWeight(2);
  float x = 300 * cos(radians(angle));
  float y = -300 * sin(radians(angle));
  line(0, 0, x, y);
  popMatrix();
}

void drawDetectedObjects() {
  pushMatrix();
  translate(width / 2, height - height * 0.074);
  stroke(255, 10, 10);
  strokeWeight(8);

  for (int a = 15; a <= 165; a++) {
    int d = distances[a];
    if (d > 0 && d < 40) {
      float r = d * 6; // scale distance to pixels
      float x = r * cos(radians(a));
      float y = -r * sin(radians(a));
      point(x, y);
    }
  }

  popMatrix();
}

void drawText() {
  fill(98, 245, 31);
  textSize(16);
  text("Angle: " + angle + "°", 50, 50);
  text("Distance: " + iDistance + " cm", 50, 70);
  if (iDistance > 40) {
    text("Object: Out of Range", 50, 90);
  } else {
    text("Object: In Range", 50, 90);
  }
}

// Ensure the CSV file is closed properly when the sketch is stopped
void exit() {
  output.flush();
  output.close();
  super.exit();
}
