#include <Servo.h>
 
// --- Pinnen ---
const int trig1     = 7;
const int echo1     = 6;
const int trig2     = 5;
const int echo2     = 4;
const int servoPin1 = 9;
const int servoPin2 = 8;
 
// --- Afstand & smoothing ---
const long minDist = 5;    // cm
const long maxDist = 150;  // cm
const int  N       = 10;   // aantal samples voor smoothing
int buf1[N], buf2[N];
int idx1 = 0, idx2 = 0;
 
// --- Servo-hoeklimieten ---
const int leftMinAngle  = 0;   // noord
const int leftMaxAngle  = 180;  // links-beneden
const int rightMinAngle = 0;    // rechts-beneden
const int rightMaxAngle = 180;   // noord
 
Servo servo1, servo2;
 
void setup() {
  Serial.begin(9600);
  servo1.attach(servoPin1);
  servo2.attach(servoPin2);
  pinMode(trig1, OUTPUT); pinMode(echo1, INPUT);
  pinMode(trig2, OUTPUT); pinMode(echo2, INPUT);

  // startbuffers vullen met de noord-hoeken
  for (int i = 0; i < N; i++) {
    buf1[i] = leftMinAngle;
    buf2[i] = rightMaxAngle;
  }
  // servostartposities
  servo1.write(leftMinAngle);
  servo2.write(rightMaxAngle);
}

long meetAfstand(int trigPin, int echoPin) {
  digitalWrite(trigPin, LOW);  delayMicroseconds(2);
  digitalWrite(trigPin, HIGH); delayMicroseconds(10);
  digitalWrite(trigPin, LOW);
  long duur = pulseIn(echoPin, HIGH, 38000);
  if (duur == 0) return maxDist;
  return constrain(duur * 0.0343 / 2, minDist, maxDist);
}

int averageBuffer(int buf[], int size) {
  long sum = 0;
  for (int i = 0; i < size; i++) sum += buf[i];
  return sum / size;
}

void loop() {
  long d1 = meetAfstand(trig1, echo1);
  delay(50);  // vermijd cross-talk
  long d2 = meetAfstand(trig2, echo2);

  Serial.print("L: "); Serial.print(d1);
  Serial.print(" cm\tR: "); Serial.print(d2);
  Serial.println(" cm");

  int a1 = map(d1, minDist, maxDist, leftMaxAngle, leftMinAngle);
  int a2 = map(d2, minDist, maxDist, rightMaxAngle, rightMinAngle);

  buf1[idx1++] = a1; if (idx1 >= N) idx1 = 0;
  buf2[idx2++] = a2; if (idx2 >= N) idx2 = 0;

  int avg1 = averageBuffer(buf1, N);
  int avg2 = averageBuffer(buf2, N);

  servo1.write(avg1);
  servo2.write(avg2);

  delay(50);
}
