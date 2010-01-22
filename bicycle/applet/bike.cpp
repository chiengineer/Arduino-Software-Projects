//if the current average is +200 outside of the current set value bump up brightness and reset fade out time
/*

enum side{
	left,
	right,
	none
};

enum {
	avg = 3
};

enum{
	current,
	previous
};

unsigned long Time[2];
int sensor_dwell, led_dwell[2];

int left_pin=4, left_en=2;
unsigned long sensor_left[4]=0, sensor_left_avg=0;

int right_pin=7, right_en=8;
unsigned long sensor_right[4]=0, sensor_right_avg=0;	

}

setup(){
	pinMode(left_pin, INPUT);
	pinMode(left_en, OUTPUT);
	pinMode(right_pin, INPUT);
	pinMode(right_en, OUTPUT);
	digitalWrite(left_en, LOW);		//start with both sensors off
	digitalWrite(right_en, LOW);
	for(char i=0; i<3; i++){
 		sensor_left[i]=0;
 		sensor_right[i]=0; 
	}
	Serial.begin(9600);
}

void loop(){
	Time[current] = millis();
	//check for rollover
	
	//System State - read left sensor

	//System State - Read right sensor
	if(sensorToRead == right && sensor_dwell <= Time[current]){
		digitalWrite(right_en, HIGH);
		delay(1);	//wait one millisecond to start pinging
		sensor_left[i] = pulseIn(pin1, HIGH);
		
		sensorToRead = left;
		sensor_dwell = millis()+10;
	}
	
	//System State - Set Left LED
	
	//System State - Set Right LED
	
}
*/
