#include "WProgram.h"
void setup();
void loop();
int pin1 = 7;
int en1 = 8;
int out1=5;
int out1_val=0;
int pin2 = 4;
int en2 = 2;
int out2=11;
int out2_val=0;

#define SENSE_DELTA 

unsigned long duration1[3], duration1_avg=0, duration2[3], duration2_avg=0, delta1=0, delta2=0;

void setup()
{
  pinMode(pin1, INPUT);
  pinMode(pin2, INPUT);
  pinMode(en1, OUTPUT);
  pinMode(en2, OUTPUT);
  for(char i=0; i<3; i++){
   duration1[i]=0;
   duration2[i]=0; 
  }
  Serial.begin(9600);
}

void loop()
{
  for(char i=0; i<3; i++){
  out1_val=0;
  digitalWrite(en2, LOW);
  digitalWrite(en1, HIGH);    //Start Ranging 1
  delay(10);
  duration1[i] = pulseIn(pin1, HIGH);
  duration1_avg=(duration1[0]+duration1[1]+duration1[2])/3;
  if(duration1_avg <= 5292)        //if the something is within 3 feet full bright 
    out1_val=255;
  else if(duration1_avg > 17640)   //if something is more than 10 feet turn off
    out1_val=0;
  else{    //range left 26180 with 147 us per step
    out1_val=-duration1_avg*0.02 + 353;
  }
  analogWrite(out1,out1_val);

  digitalWrite(en1, LOW);    //Start Ranging 2
  digitalWrite(en2, HIGH);
  delay(10);
  duration2[i] = pulseIn(pin2, HIGH);
  duration2_avg=(duration2[0]+duration2[1]+duration2[2])/3;
  delay(10);
  if(duration2_avg <= 5292)        //if the something is within 3 feet full bright 
    out2_val=255;
  else if(duration2_avg > 17640)   //if something is more than 10 feet turn off
    out2_val=0;
  else{    //range left 26180 with 147 us per step
    out2_val=-duration2_avg*0.02 + 353;
  }
  analogWrite(out2,out2_val);
  
  Serial.print(duration1_avg,DEC);
  Serial.print(",");
  Serial.println(duration2_avg,DEC);
  }
}


int main(void)
{
	init();

	setup();
    
	for (;;)
		loop();
        
	return 0;
}

