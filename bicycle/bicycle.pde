int pin1 = 7;
int en1 = 8;
int out1=5;
int out1_val=0;
int pin2 = 4;
int en2 = 2;
int out2=11;
int out2_val=0;

#define CLOSE_LIM  800
#define FAR_LIM    400

unsigned int delay1=10000, delay2=10000;

unsigned long duration1[3]={
  0,0,0}
, duration1_avg[]={
  0,0}
, duration2[3]={
  0,0,0}
, duration2_avg[]={
  0,0}
, out1_tmr=0, out2_tmr=0;
unsigned long currentTime=0, ledTime1=0, ledTime2=0;

void ledCheck(){
  if(out1_tmr > currentTime){
    //LEDs should be on, what's the fadeout status?
    if(currentTime - ledTime1 > (delay1>>9)){
      if(out1_val <= (delay1>>9)){
        out1_val=0;
      }
      else{
        out1_val=out1_val-(delay1>>9);
      } 

      ledTime1 = currentTime;
    }
  }
  else
    out1_val=0;  

  if(out2_tmr > currentTime){
    //LEDs should be on, what's the fadeout status?
    if(currentTime - ledTime2 > (delay2>>9)){
      if(out2_val <= (delay2>>9)){
        out2_val=0;
      }
      else{
        out2_val=out2_val-(delay2>>9);
      }
      ledTime2 = currentTime;
    }
  }
  else
    out2_val=0;


  analogWrite(out2, out2_val);
  analogWrite(out1, out1_val);

  Serial.print(out1_val); 
  Serial.print(",");
  Serial.println(out2_val);
}

void setup()
{
  pinMode(pin1, INPUT);
  pinMode(pin2, INPUT);
  pinMode(en1, OUTPUT);
  pinMode(en2, OUTPUT);
  Serial.begin(9600);
  currentTime = millis();
  out1_tmr=currentTime+(unsigned long)delay1;
  out1_val=255;
  analogWrite(out1,out1_val);  
  out2_tmr=currentTime+(unsigned long)delay2;
  out2_val=255;
  ledTime1=currentTime;
  ledTime2=currentTime;
  analogWrite(out2,out2_val);
  while(out1_val > 0 && out2_val > 0){
    currentTime=millis();
    ledCheck();
  }
  Serial.println("Done with init");
}

void loop(){
  currentTime=millis();
  ledCheck();

  for(char i=0; i<3; i++){
    digitalWrite(en2, LOW);
    digitalWrite(en1, HIGH);    //Start Ranging 1
    delay(10);
    duration1[i] = pulseIn(pin1, HIGH);
    duration1_avg[0]=(duration1[0]+duration1[1]+duration1[2])/3;
    if (duration1_avg[0] <= (duration1_avg[1] - CLOSE_LIM)){    //something got closer turn on the LEDs
      if(duration1_avg[1] - duration1_avg[0] > 5000){
        out1_val=255;
      }
      else{
       out1_val=255/(duration1_avg[1] - duration1_avg[0]>>9);
      }
      delay1=(duration1_avg[1]-duration1_avg[0])*10;
      out1_tmr=currentTime+(unsigned long)delay1;                            
      duration1_avg[1]=duration1_avg[0];
    }
    else if (duration1_avg[0] > (duration1_avg[1]+FAR_LIM)){  //moving further away
      delay1=delay1-100;
      duration1_avg[1]=duration1_avg[0];
    }

    digitalWrite(en1, LOW);    //Start Ranging 2
    digitalWrite(en2, HIGH);
    delay(10);
    duration2[i] = pulseIn(pin2, HIGH);
    duration2_avg[0]=(duration2[0]+duration2[1]+duration2[2])/3;
    if(duration2_avg[0] <= (duration2_avg[1] - CLOSE_LIM)){        //if the something is within 3 feet full bright 
      if(duration2_avg[1] - duration2_avg[0] > 5000){
        out2_val=255;
      }
      else{
       out2_val=255/(duration2_avg[1] - duration2_avg[0]>>9);
      }
      delay2=(duration2_avg[1]-duration2_avg[0])*10;
      out2_tmr=currentTime+(unsigned long)delay2;                            
      duration2_avg[1]=duration2_avg[0];
    }
    else if(duration2_avg[0] > (duration2_avg[1]+FAR_LIM)){  //moving further away
      delay2=delay2-100;
      duration2_avg[1]=duration2_avg[0];
    }
  }

}







