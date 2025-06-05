const int trigPin = 6;
const int echoPin = 7;

long duration;
int distance;

void setup() {
pinMode(trigPin, OUTPUT);
pinMode(echoPin, INPUT);
Serial.begin(9600);
}

void loop() {
distance = calculateDistance();

// Always send 90° as the angle
Serial.print("90,");
Serial.print(distance);
Serial.print(".");

delay(100); // adjust for smoother data flow
}

int calculateDistance() {
digitalWrite(trigPin, LOW);
delayMicroseconds(2);
digitalWrite(trigPin, HIGH);
delayMicroseconds(10);
digitalWrite(trigPin, LOW);

duration = pulseIn(echoPin, HIGH);
distance = duration * 0.034 / 2;
return distance;
}