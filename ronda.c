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
#define DISTANCE 50
#define SENSOR 3

unsigned int nextAlarmTime;
int timesTheRondaWasMade;
int unity = 4000;
int adicao = 0;


void stop();
void goAhead();
void setAlarm();
void setProximity();
void itsTimeToTurnRightForAlarm();
void itsTimeToTurnRightForProximity();
void iWillGoForAlarm();
void iWillGoForProximity();
void resetRonda();


void main () {

	resetRonda();

	setAlarm();
	// setProximity();

	goAhead();

	while (1);
}

void goAhead() {

	motor_cfg_t mLeft, mRight; 

	mLeft.id = LEFT;
	mLeft.speed = FULL_SPEED; // Declare left motor with FULL_SPEED

	mRight.id = RIGHT;
	mRight.speed = FULL_SPEED; // Declare right motor with FULL_SPEED

	set_motors_speed(&mLeft, &mRight); // Make the call to set the motors
}

void setAlarm() {

	get_time(&nextAlarmTime);
	nextAlarmTime = nextAlarmTime + unity + adicao;

	add_alarm(&itsTimeToTurnRightForAlarm, nextAlarmTime);
}

void setProximity() {

	register_proximity_callback(3, 50, &itsTimeToTurnRightForProximity);
}

void itsTimeToTurnRightForAlarm() {

	motor_cfg_t mRight;

	mRight.id = RIGHT;
	mRight.speed = NO_SPEED; // Declare right motor with NO_SPEED

	set_motor_speed(&mRight); // Make the call to set the motor

	get_time(&nextAlarmTime);
	nextAlarmTime = nextAlarmTime + 650;

	add_alarm(&iWillGoForAlarm, nextAlarmTime); //!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! SWEET JESUS !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
}

void itsTimeToTurnRightForProximity() {

	motor_cfg_t mRight;

	mRight.id = RIGHT;
	mRight.speed = NO_SPEED; // Declare right motor with NO_SPEED

	set_motor_speed(&mRight); // Make the call to set the motor

	get_time(&nextAlarmTime);
	nextAlarmTime = nextAlarmTime + 650;

	add_alarm(&iWillGoForProximity, nextAlarmTime); //!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! SWEET JESUS !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
}

void iWillGoForAlarm() {

	timesTheRondaWasMade++;
	adicao = adicao + 1000;

	if (timesTheRondaWasMade == 50) {
		resetRonda();
	}

	goAhead();
	setAlarm();
}

void iWillGoForProximity() {

	goAhead();
	setProximity();
}

void resetRonda() {
	
	timesTheRondaWasMade = 0;
	nextAlarmTime = 0;
	adicao = 0;
}