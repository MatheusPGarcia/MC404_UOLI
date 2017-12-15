/*
 *	Lógica de Controle - LoCo - ronda.c
 *
 *	Criado por Matheus Pompeo Garcia - 156743
 *
 *   MC404 - Segundo semestre de 2017
*/

#include "api_robot2.h"

#define LEFT 1
#define RIGHT 0
#define FULL_SPEED 60
#define NO_SPEED 0
#define MIN_DISTANCE 30
#define MAX_DISTANCE 35


void goAhead();
void keepWalking();
void turnRight();
void keepTurningRight();
void keepThatWallOnYourLeft();


void main() {

	goAhead();
	keepWalking();

	while(1);
}

void goAhead() {
	
	motor_cfg_t mLeft, mRight; 

	mLeft.id = LEFT;
	mLeft.speed = FULL_SPEED; // Declare left motor with FULL_SPEED

	mRight.id = RIGHT;
	mRight.speed = FULL_SPEED; // Declare right motor with FULL_SPEED

	set_motors_speed(&mLeft, &mRight); // Make the call to set the motors
}

void keepWalking() {

	unsigned char sensor3;

	sensor3 = 3;

	// UOLI will keep walking foward until he finds an wall in front of him, than he will start turning right according to the callbacks
	register_proximity_callback(sensor3, MIN_DISTANCE, &turnRight);
}

void turnRight() {

	motor_cfg_t mRight;

	mRight.id = RIGHT;
	mRight.speed = NO_SPEED; // Declare right motor with NO_SPEED

	set_motor_speed(&mRight); // Make the call to set the motor

	keepTurningRight();
}

void keepTurningRight() {

	unsigned int time, distances[3], *pointDistances, vSensor0, vSensor1;

	unsigned char sensor0, sensor1;

	sensor0 = 0; //	Set the sensors that will be read
	sensor1 = 1;

	pointDistances = distances;

	read_sonars(sensor0, sensor1, pointDistances); // Take the distances read from the sonars

	vSensor0 = distances[0]; // Put the distance in variables with respective name
	vSensor1 = distances[1];

	// If the distance of the sensor0 is bigger than the distance in sensor1, than it will keepTurningRight
	if ((vSensor0 > vSensor1) && (vSensor0 > MAX_DISTANCE)) {
	
		get_time(&time); // Get the actual system time

		time = time + 20; // Increment the time in 20

		add_alarm(&keepTurningRight, time); //Set an alarm to call the same function 200 system times after
	}
	// In the casa sensor0 isn't bigger than sensor 1, thw program will call an function to keep following the wall and set callbacks in the case an wall appears in front of uoli
	else {
		goAhead();
		keepThatWallOnYourLeft();
	}
}

void keepThatWallOnYourLeft() {

	unsigned int time, distances[3], *pointDistances, vSensor0, vSensor14, vSensor15;
	
	unsigned char sensor0, sensor14, sensor15;

	sensor0 = 0;
	sensor14 = 14;
	sensor15 = 15;

	pointDistances = distances;
	
	read_sonars(sensor14, sensor15, pointDistances);

	vSensor0 = read_sonar(sensor0);
	vSensor14 = distances[0];
	vSensor15 = distances[1];

	if (vSensor0 > MAX_DISTANCE) {
		turnRight();
	}
	else if (vSensor14 > vSensor15) {

		get_time(&time);

		time = time + 200;

		add_alarm(&keepThatWallOnYourLeft, time);
	}
	else {
		turnRight();
	}
}
