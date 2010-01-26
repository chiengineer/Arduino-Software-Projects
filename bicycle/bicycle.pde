int pin1 = 7;
int en1 = 8;
int out1=5;
int out1_val=0;
int pin2 = 4;
int en2 = 2;
int out2=11;
int out2_val=0;
unsigned char i=0;

#define DEBUG
//#define DEBUG_EXT

#define FILTER_SAMPLES 13
#define CLOSE_LIM  300
#define FAR_LIM    150
#define PULSE_LIM  130000
#define WARNING_LIM 16
#define DISTANCE_LIM 10000
#define STUTTER_LIM  1000

unsigned int delay1=3000, delay2=3000, top, bottom;
unsigned long duration1[FILTER_SAMPLES], duration1_raw, duration1_Smooth, duration2[FILTER_SAMPLES], duration2_raw, duration2_Smooth;
unsigned long duration1_avg[2]={
  0,0}
, duration2_avg[2]={
  0,0};
unsigned long out1_tmr=0, out2_tmr=0;
unsigned long currentTime=0, ledTime1=0, ledTime2=0;

void ledCheck(){
  if((duration1_avg[1] < DISTANCE_LIM) && (out1_val <= WARNING_LIM) && (ledTime1 < currentTime)){
    out1_val= WARNING_LIM;
  }
  else if(out1_tmr > currentTime){
    //LEDs should be on, what's the fadeout status?
    if(currentTime - ledTime1 > (delay1>>9)){
      if(out1_val <= (delay1>>9)){              //is the current value less than the delay divided by 255?
        if(duration1_avg[1] < DISTANCE_LIM)
          out1_val=WARNING_LIM;
        else if(out1_val > 0)
          out1_val-=5;
        else
          out1_val=0;
      }
      else{
        out1_val=abs(out1_val-(delay1>>9));    //subtract the difference
        if((out1_val < WARNING_LIM) && (duration1_avg[1] < DISTANCE_LIM)){
          out1_val = WARNING_LIM; 
        }
      } 

      ledTime1 = currentTime;
    }
  }
  else if(out1_val > 1){
    out1_val-=5;
  }
  else    //something crazy happended just turn off
  out1_val=0;  

  if((duration2_avg[1] < DISTANCE_LIM) && (out2_val <= WARNING_LIM) && (ledTime2 < currentTime)){
    out2_val= WARNING_LIM;
  }
  else if(out2_tmr > currentTime){
    //LEDs should be on, what's the fadeout status?
    if(currentTime - ledTime2 > (delay2>>9)){
      if(out2_val <= (delay2>>9)){              //is the current value less than the delay divided by 255?
        if(duration2_avg[1] < DISTANCE_LIM)
          out2_val=WARNING_LIM;
        else if(out2_val > 0)
          out2_val-=5;
        else
          out2_val=0;
      }
      else{
        out2_val=abs(out2_val-(delay2>>9));    //subtract the difference
        if((out2_val < WARNING_LIM) && (duration2_avg[1] < DISTANCE_LIM)){
          out2_val = WARNING_LIM; 
        }
      } 

      ledTime2 = currentTime;
    }
  }  
  else if(out2_val > 1){
    out2_val-=5;
  }
  else    //something crazy happended just turn off
  out2_val=0;  

  out2_val=abs(out2_val);
  out1_val=abs(out1_val);

  analogWrite(out2, out2_val);
  analogWrite(out1, out1_val);
#ifdef DEBUG
  Serial.print(out1_val); 
  Serial.print(",");
  Serial.println(out2_val);
#endif
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
  duration1_avg[1]=30000;
  duration2_avg[1]=30000;
  analogWrite(out2,out2_val);
  while(out1_val > 0 && out2_val > 0){
    currentTime=millis();
    ledCheck();
  }
  bottom = max(((FILTER_SAMPLES * 15)  / 100), 1); 
  top = min((((FILTER_SAMPLES * 85) / 100) + 1  ), (FILTER_SAMPLES - 1));   // the + 1 is to make up for asymmetry caused by integer rounding
  Serial.println("Done with init");
  duration1_avg[1]=0;
  duration2_avg[1]=0;
}

void loop(){
  currentTime=millis();
  ledCheck();

  i = (i+1) % FILTER_SAMPLES;
  digitalWrite(en2, LOW);
  digitalWrite(en1, HIGH);    //Start Ranging 1
  delay(70);
  duration1_raw = pulseIn(pin1, HIGH, PULSE_LIM);
  if(duration1_raw > PULSE_LIM)
    duration1_raw = PULSE_LIM;
  duration1_avg[0] = digitalSmooth(duration1_raw, duration1);

  if(abs(duration1_avg[1] - duration1_avg[0]) > STUTTER_LIM){
    if(duration1_avg[0] > duration1_avg[1]){  //we got further away
      delay1 = delay1-100;
    }
    else{          //we got closer
      if(duration1_avg[0] > DISTANCE_LIM){
        out1_val=out1_val+100;  
      }
      else{
        out1_val=255; 
      }
    }
    duration1_avg[1] = duration1_avg[0];
  }
  else{
    if(duration1_avg[0] > duration1_avg[1])
    {
      delay1-=50;
      duration1_avg[1] +=100;
    }
    else
    {
      delay1+=50;
      duration1_avg[1] -=100;
    } 
  }
  //else do nothing because it's just a jitter

  /********* OTHER SIDE **************/

  digitalWrite(en1, LOW);    //Start Ranging 2
  digitalWrite(en2, HIGH);
  delay(70);
  duration2_raw = pulseIn(pin2, HIGH, PULSE_LIM);
  if(duration2_raw > PULSE_LIM)
    duration2_raw = PULSE_LIM;
  duration2_avg[0]=digitalSmooth(duration2_raw, duration2);

  if(abs(duration2_avg[1] - duration2_avg[0]) > STUTTER_LIM){
    if(duration2_avg[0] > duration2_avg[1]){  //we got further away
      delay2 = delay2-100;
    }
    else{          //we got closer
      if(duration2_avg[0] > DISTANCE_LIM){
        out2_val=out2_val+100;  
      }
      else{
        out2_val=255; 
      }
    }
    duration2_avg[1] = duration2_avg[0];
  }
  else{
    if(duration2_avg[0] > duration2_avg[1])
    {
      delay2-=50;
      duration2_avg[1] += 100;

    }
    else
    {
      delay2+=50;
      duration2_avg[1] -= 100;
    } 
  }
#ifdef DEBUG
  Serial.print(duration1_avg[1], DEC);
  Serial.print(","); 
  Serial.println(duration2_avg[1], DEC);
#endif
}

unsigned long digitalSmooth(unsigned long rawIn, unsigned long *sensSmoothArray){     // "int *sensSmoothArray" passes an array to the function - the asterisk indicates the array name is a pointer
  unsigned long j, k, temp;
  unsigned long total;
  static int i;
  // static int raw[FILTER_SAMPLES];
  static int sorted[FILTER_SAMPLES];
  boolean done;

  i = (i + 1) % FILTER_SAMPLES;    // increment counter and roll over if necc. -  % (modulo operator) rolls over variable
  sensSmoothArray[i] = rawIn;                 // input new data into the oldest slot

  for (j=0; j<FILTER_SAMPLES; j++){     // transfer data array into anther array for sorting and averaging
    sorted[j] = sensSmoothArray[j];
  }

  done = 0;                // flag to know when we're done sorting              
  while(done != 1){        // simple swap sort, sorts numbers from lowest to highest
    done = 1;
    for (j = 0; j < (FILTER_SAMPLES - 1); j++){
      if (sorted[j] > sorted[j + 1]){     // numbers are out of order - swap
        temp = sorted[j + 1];
        sorted [j+1] =  sorted[j] ;
        sorted [j] = temp;
        done = 0;
      }
    }
  }


#ifdef DEBUG_EXT
  Serial.print("raw = ");
  for (j = 0; j < (FILTER_SAMPLES); j++){    // print the array to debug
    Serial.print(sorted[j]); 
    Serial.print("   "); 
  }
  Serial.println();
#endif
  // throw out top and bottom 15% of samples - limit to throw out at least one from top and bottom

  k = 0;
  total = 0;
  for ( j = bottom; j< top; j++){
    total += sorted[j];  // total remaining indices
    k++; 
#ifdef DEBUG_EXT
    Serial.print(sorted[j]); 
    Serial.print("   "); 
#endif
  }
#ifdef DEBUG_EXT
  Serial.println();
  Serial.print("average = ");
  Serial.println(total/k);
#endif
  return total / k;    // divide by number of samples
}





















