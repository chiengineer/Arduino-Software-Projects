//#include <TimerOne.h>

//#define DEG_45  0.785398163 
//#define DEG_60  1.047197551
#define DEG_30  0.523598776
#define DEG_120 2.094395102

#define X_ZERO_POINT 477
#define Y_ZERO_POINT 374
#define Z_ZERO_POINT 477
#define CUTOFF     9

#define GYRO_X_ZERO_POINT 534
#define GYRO_Y_ZERO_POINT 466

#define TRUE  1
#define FALSE 0

#define ALL 0x00
#define NODE1  0x01  //60
#define NODE2  0x02  //90
#define NODE3  0x04  //120
#define NODE4  0x08  //240
#define NODE5  0x10  //270
#define NODE6  0x20  //300

#define SLICE1  0x03
#define SLICE2  0X06
#define SLICE3  0x0C
#define SLICE4  0x18
#define SLICE5  0x30
#define SLICE6  0x21

#define ACTIVE 0
#define MAGNITUDE 1
#define NODE_COUNT 6

char VersionDate[] = "3.7.2009";
char VersionNumber[] =  "0.7";

int x_accel_pin = 2;
int y_accel_pin = 1;
int z_accel_pin = 0;

int gyro1 = 4;
int gyro2 = 7;

int x_accel = 0;
int y_accel = 0;
int z_accel = 0;

int x_accelCurrent = 0;
int y_accelCurrent = 0;
int z_accelCurrent = 0;

int vectorMagnitude = 0;
int convertedMagnitude = 0;
int maxmag = 0;
int previousMagnitude = 0;
unsigned long time;

//int nodes[]={ 3, 5, 6, 9, 10, 11 };
int nodes[]={ 11,3,5,6,10,9};
int value=0, val_max=0, abs_value=0;
int gyro_X=0, gyro_Y=0;
unsigned int abs_X=0,abs_Y=0;
int PWMMask[6][2];


void setup() {
  Serial.begin(57600);
  //Timer1.initialize(100);
  for(int i=0; i< NODE_COUNT; i++)
    pinMode(nodes[i], OUTPUT);
  time = millis();  
  Serial.println("==== Balance Shirt ====");
  Serial.print("Date: ");Serial.println(VersionDate);
  Serial.print("Version: ");Serial.println(VersionNumber);
  initializationPluse();
}

void loop() {
  gyro_X = GYRO_X_ZERO_POINT - analogRead(gyro1);
  gyro_Y = GYRO_Y_ZERO_POINT - analogRead(gyro2);
  abs_X = abs(gyro_X);
  abs_Y = abs(gyro_Y);
  Serial.print(gyro_X);Serial.print(" , ");Serial.println(gyro_Y);
//  gyro_X=0;
//  gyro_Y=0;
//  Serial.println(value);
//  value = gyro_X;
//  abs_value = abs_X;

  if(abs_X > CUTOFF || abs_Y > CUTOFF)
  {
  if(abs_X >  CUTOFF){    
    if(gyro_X > 0)  //to the right
    {
      clearPWM(1);
      analogWrite(nodes[3],(7*gyro_X+330)/10);
    }
    else          //to the left
    {
      clearPWM(1);
      analogWrite(nodes[0],(7*gyro_X+330)/10);

    }
    if(abs_X < 50)
      delay(10);
  }
  if(abs_Y >  CUTOFF){

    
    if(gyro_Y > 0)  //to the front
    {
      clearPWM(2);
      analogWrite(nodes[1],(7*gyro_Y+330)/20);
      analogWrite(nodes[2],(7*gyro_Y+330)/20);
    }
    else          //to the back
    {
      clearPWM(2);
      analogWrite(nodes[4],(7*gyro_Y+330)/20);
      analogWrite(nodes[5],(7*gyro_Y+330)/20);
    }
    if(abs_Y < 50)
      delay(10);
  }
  }
  else
    clearPWM(0);
  
    
  /*
  getAccel();
  x_accelCurrent = x_accelCurrent + x_accel;
  y_accelCurrent = y_accelCurrent + y_accel;
  z_accelCurrent = z_accelCurrent + z_accel;
//  vectorMagnitude= (int)sqrt(x_accelCurrent*x_accelCurrent+y_accelCurrent*y_accelCurrent);
    vectorMagnitude= (int)sqrt(x_accel*x_accel+y_accel*y_accel);
//  Serial.print("Magnitude: ");
//  Serial.println(vectorMagnitude);
  if(vectorMagnitude > maxmag){
   maxmag = vectorMagnitude;
  }
  if((time+1000) <= millis()){
     //ScrollingDisplay();
     time = millis();
  }
  if(vectorMagnitude > CUTOFF){
     convertedMagnitude = (int)(2.654*(float)vectorMagnitude + 17);
     //Serial.print(convertedMagnitude);Serial.print("\t");Serial.print(x_accel);Serial.print("\t");Serial.print(y_accel);Serial.print("\t");Serial.println(z_accel);
     ProcessMagnitude(convertedMagnitude, x_accel, y_accel);
  }
  else
    clearPWM();
  Serial.print(x_accel);Serial.print("\t");Serial.print(y_accel);Serial.print("\t");Serial.println(z_accel);
 */
}

void initializationPluse(void){
  analogWrite(nodes[0],255);
  delay(300);
  analogWrite(nodes[0],0);
  delay(200);  
  analogWrite(nodes[3],255);
  delay(300);
  analogWrite(nodes[3],0);
  delay(200);
  analogWrite(nodes[1],255);
  delay(300);
  analogWrite(nodes[1],0);
  delay(200);
  analogWrite(nodes[4],255);
  delay(300);
  analogWrite(nodes[4],0);
  delay(200);
  analogWrite(nodes[2],255);
  delay(300);
  analogWrite(nodes[2],0);
  delay(200);
  analogWrite(nodes[5],255);
  delay(300);
  analogWrite(nodes[5],0);
}

void clearPWM(unsigned char mask){
  switch(mask){
    default:
    case 0:
      for(int i=0; i<6; i++){
        analogWrite(nodes[i],0);
      } 
     break;
     case 1: //sides only
       analogWrite(nodes[0],0);
       analogWrite(nodes[3],0);
     break;
     case 2: //front and back only
       analogWrite(nodes[1],0);
       analogWrite(nodes[2],0);
       analogWrite(nodes[4],0);
       analogWrite(nodes[5],0);
     break;
  }
}

void ScrollingDisplay(void){
  Serial.print("mMag: ");Serial.print(maxmag);Serial.print("\t");
  maxmag=0; 
  //Serial.print("( ");Serial.print(x_accelCurrent);Serial.print(" , ");Serial.print(y_accelCurrent);Serial.print(" )");Serial.print("\t");
  for(unsigned char i=0; i<NODE_COUNT; i++){
     Serial.print(PWMMask[i][ACTIVE]); 
  }Serial.print("\t");
  Serial.println();
}
/*
void clearPWM(void){
	for(unsigned char i=0; i<NODE_COUNT; i++){
			PWMMask[i][ACTIVE]=FALSE;
			PWMMask[i][MAGNITUDE]=0;
	}
}
*/
void printDouble( double val, unsigned int precision){
// prints val with number of decimal places determine by precision
// NOTE: precision is 1 followed by the number of zeros for the desired number of decimial places
// example: printDouble( 3.1415, 100); // prints 3.14 (two decimal places)

    Serial.print (int(val));  //prints the int part
    Serial.print("."); // print the decimal point
    unsigned int frac;
    if(val >= 0)
	frac = (val - int(val)) * precision;
    else
	 frac = (int(val)- val ) * precision;
    int frac1 = frac;
    while( frac1 /= 10 )
	  precision /= 10;
    precision /= 10;
    while(  precision /= 10)
	  Serial.print("0");

    Serial.println(frac,DEC) ;
}

void setPWM(unsigned char mask, int x, int y, int magnitude,float ratio){
unsigned char comp=0x01, count =0;
double theta = 0.0;
double theta_ = 0.0;
//Serial.print("Mask: ");
//Serial.println(mask+256, BIN);
int mag_a=0, mag_b=0,temp=0;
  for(unsigned char i=0; i< NODE_COUNT; i++){
    if(mask & comp){
      PWMMask[i][ACTIVE]=TRUE;
      count++;
    }
    else
      PWMMask[i][ACTIVE]=FALSE;
    comp=comp<<1;
  }
  switch (count){
    default:
    case 0:    //count out of bounds clear PWMs
      for(unsigned char i=0; i<NODE_COUNT; i++){
         PWMMask[i][MAGNITUDE]=0; 
         PWMMask[i][ACTIVE]=FALSE;        
      }
      Serial.println("mags cleared");
      break;
    case 1:    //on a node
        for(unsigned char i=0; i<NODE_COUNT; i++){
            if(PWMMask[i][ACTIVE])
              PWMMask[i][MAGNITUDE]=magnitude;
            else
              PWMMask[i][MAGNITUDE]=0;
        }
      break;
    case 2:    //in a slice
	theta = atan(y/x);
        //printDouble(theta,1000);
        if(ratio > -1.7 && ratio < 1.7){  //120 degree range
          theta_ = fmod((double)theta,DEG_120);
	  mag_a = (int)(magnitude*(theta_/DEG_120));
	  mag_b = 255-mag_a;
        }
        else{  //30 degree range
	  theta_ = fmod((double)theta,DEG_30);
	  mag_a = (int)(magnitude*(theta_/DEG_30*100));
	  mag_b = 255-mag_a;
        }
        //Serial.println(mag_a);
        //Serial.println(mag_b);
	if(mag_a < mag_b){
		temp=mag_b;
		mag_b=mag_a;
		mag_a=temp;
	}
      switch(mask){
		default:break;
		case SLICE1:
		PWMMask[NODE1][MAGNITUDE]=mag_a;
		PWMMask[NODE2][MAGNITUDE]=mag_b;
		break;
		case SLICE2:
		PWMMask[NODE2][MAGNITUDE]=mag_a;
		PWMMask[NODE3][MAGNITUDE]=mag_b;
		break;
		case SLICE3:
		PWMMask[NODE3][MAGNITUDE]=mag_a;
		PWMMask[NODE4][MAGNITUDE]=mag_b;
		break;
		case SLICE4:
		PWMMask[NODE4][MAGNITUDE]=mag_a;
		PWMMask[NODE5][MAGNITUDE]=mag_b;
		break;
		case SLICE5:
		PWMMask[NODE5][MAGNITUDE]=mag_a;
		PWMMask[NODE6][MAGNITUDE]=mag_b;
		break;
		case SLICE6:
		PWMMask[NODE6][MAGNITUDE]=mag_a;
		PWMMask[NODE1][MAGNITUDE]=mag_b;
		break;
      }
      break;
  }
  processPWM();
  return;
}


void processPWM(void){
  unsigned char i=0;
  //PWMMask is in percentages
/*  for(i=0;i<NODE_COUNT;i++){
     if(PWMMask[i][ACTIVE])
       analogWrite(nodes[i],PWMMask[i][MAGNITUDE]);
     else
       analogWrite(nodes[i],0);
  }
*/
return;
}

void ProcessMagnitude(int magnitude, int x, int y)
{
  float ratio = 0.0;
  //special cases where results fall on the lines
  clearPWM(0);  //clear all pwm values
  if(x==0 && y!=0){
      if(y>0)
        setPWM(NODE2,x,y,magnitude,ratio);  //at 90 degrees
      else //y<0
        setPWM(NODE5,x,y,magnitude,ratio);  //at 270 degrees
    return;  //done return
  }
  else if(x==0 && y==0){
        //everything is at zero
        return;
  }
  else if(x!=0 && y!=0){
    ratio = (int)(y/x);
    /***** START On Node values *****/
    if(ratio >= 1.7 && ratio <= 1.75){  //60 or 240 degrees
         if(x > 0 && y > 0)  //60 degrees
            setPWM(NODE1,x,y,magnitude,ratio);
         else  //240 degrees
            setPWM(NODE4,x,y,magnitude,ratio);
    }
    else if(ratio <= -1.7 && ratio >= -1.75){  //120 or 300 degrees
         if(x < 0 && y > 0)  //120 degrees
            setPWM(NODE3,x,y,magnitude,ratio);
         else  //300 degrees
            setPWM(NODE6,x,y,magnitude,ratio);
    }    
    /***** END on node values *****/
    /***** START in Slice values *****/
    else if(ratio > 1.75){  //between 60 and 90 or 240 and 270
      if(x>0 && y>0)  //between 60 and 90
        setPWM(SLICE1,x,y,magnitude,ratio);
      else //between 240 and 270
        setPWM(SLICE4,x,y,magnitude,ratio);
    }
    else if(ratio < -1.75){  //between 90 and 120 or 270 and 300
      if(x < 0)  //between 90 and 120
        setPWM(SLICE2,x,y,magnitude,ratio);
      else       //between 270 and 300
        setPWM(SLICE5,x,y,magnitude,ratio);
    }  
    else if(ratio > -1.7 || ratio < 1.7){ //between 120 and 240 or between 300 and 60
      if(x < 0)  //between 120 and 240
        setPWM(SLICE3,x,y,magnitude,ratio);
      if(x > 0)  //between 300 and 60
        setPWM(SLICE6,x,y,magnitude,ratio);
    }
    /***** END in Slice values *****/
    return;
  }
    return;
}

void getAccel(){
  x_accel = translateAccelData(analogRead(x_accel_pin),1);
//  Serial.print("x accel ");
//  Serial.print(analogRead(x_accel_pin)); Serial.print(",");
//  Serial.println(x_accel);
  y_accel = translateAccelData(analogRead(y_accel_pin),2);
//  Serial.print("y accel ");
//  Serial.print(analogRead(y_accel_pin));Serial.print(",");
//  Serial.println(y_accel);
  z_accel = translateAccelData(analogRead(z_accel),3);
}

int translateAccelData(int value,unsigned char axis){
    switch(axis){
    case 1:return(value-X_ZERO_POINT);
    case 2:return(value-Y_ZERO_POINT);
    case 3:return(value-Z_ZERO_POINT);
    }
}
