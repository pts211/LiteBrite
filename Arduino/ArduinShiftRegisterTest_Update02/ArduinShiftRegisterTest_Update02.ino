/*
   SN74HC165N_shift_reg

   Program to shift in the bit values from a SN74HC165N 8-bit
   parallel-in/serial-out shift register.

   This sketch demonstrates reading in 16 digital states from a
   pair of daisy-chained SN74HC165N shift registers while using
   only 4 digital pins on the Arduino.

   You can daisy-chain these chips by connecting the serial-out
   (Q7 pin) on one shift register to the serial-in (Ds pin) of
   the other.

   Of course you can daisy chain as many as you like while still
   using only 4 Arduino pins (though you would have to process
   them 4 at a time into separate unsigned long variables).

*/

/* How many shift register chips are daisy-chained.
*/
#define NUMBER_OF_SHIFT_CHIPS   5

/* Width of data (how many ext lines).
*/
#define DATA_WIDTH   NUMBER_OF_SHIFT_CHIPS * 8

#define ARR_SIZE 2


/* Width of pulse to trigger the shift register to read and latch.
*/
#define PULSE_WIDTH_USEC   5

/* Optional delay between shift register reads.
*/
#define POLL_DELAY_MSEC   1

/* You will need to change the "int" to "long" If the
   NUMBER_OF_SHIFT_CHIPS is higher than 2.
*/
#define BYTES_VAL_T unsigned long

int ploadPin        = 8;  // Connects to Parallel load pin the 165
int clockEnablePin  = 3;  // Connects to Clock Enable pin the 165
int dataPin         = 6; // Connects to the Q7 pin the 165
int clockPin        = 7; // Connects to the Clock pin the 165

BYTES_VAL_T pinValues;
BYTES_VAL_T oldPinValues;

//const int ARR_SIZE = 2;

unsigned long pinValuesArr[ARR_SIZE];
unsigned long oldPinValuesArr[ARR_SIZE];

/* This function is essentially a "shift-in" routine reading the
   serial Data from the shift register chips and representing
   the state of those pins in an unsigned integer (or long).
*/
void read_shift_regs()
{
  long bitVal;
  BYTES_VAL_T bytesVal = 0;

  /* Trigger a parallel Load to latch the state of the data lines,
  */
  digitalWrite(clockEnablePin, HIGH);
  digitalWrite(ploadPin, LOW);
  delayMicroseconds(PULSE_WIDTH_USEC);
  digitalWrite(ploadPin, HIGH);
  digitalWrite(clockEnablePin, LOW);

  /* Loop to read each bit value from the serial out line
     of the SN74HC165N.
  */
  int arrayIndex = -1;
  unsigned long current;
  for (int i = 0; i < DATA_WIDTH; i++)
  {
    if ( (i % 32) == 0 ) {
      arrayIndex++;
      current = pinValuesArr[arrayIndex];
    }

    bitVal = digitalRead(dataPin);

    /* Set the corresponding bit in bytesVal.
    */
    if ( (i % 32) == 0 ) {
      arrayIndex++;
    }

    Serial.print("Index[" + String(i) + "]: ");
    Serial.println(bitVal);

    current |= (bitVal << ((DATA_WIDTH - 1) - i));


    pinValuesArr[arrayIndex] = current;
    /* Pulse the Clock (rising edge shifts the next bit).
    */
    digitalWrite(clockPin, HIGH);
    delayMicroseconds(PULSE_WIDTH_USEC);
    digitalWrite(clockPin, LOW);
  }
}

/* Dump the list of zones along with their current status.
*/
void display_pin_values()
{
  Serial.print("Pin States:\r\n");

  int arrayIndex = -1;
  unsigned long current;
  for (int i = 0; i < DATA_WIDTH; i++)
  {
    if ( (i % 32) == 0 ) {
      arrayIndex++;
      current = pinValuesArr[arrayIndex];
    }


    Serial.print("  Pin-");
    Serial.print(i);
    Serial.print(": ");

    if ((current >> i) & 1) {
      Serial.print("HIGH");
    } else {
      Serial.print("LOW");
    }

    Serial.print("\r\n");
  }
  Serial.print("\r\n");
}

void setup()
{
  Serial.begin(9600);
  
  Serial.println("Hello world");
  Serial.print("ARR_SIZE: ");
  Serial.println(ARR_SIZE);

  /* Initialize our digital pins...
  */
  pinMode(ploadPin, OUTPUT);
  pinMode(clockEnablePin, OUTPUT);
  pinMode(clockPin, OUTPUT);
  pinMode(dataPin, INPUT);

  digitalWrite(clockPin, LOW);
  digitalWrite(ploadPin, HIGH);

  /* Read in and display the pin states at startup.
  */
  read_shift_regs();
  display_pin_values();
  //oldPinValues = pinValues;
}

void loop()
{
  /* Read the state of all zones.
  */
  //read_shift_regs();

  /* If there was a chage in state, display which ones changed.
  */

  boolean hasChanged = false;
  for (int i = 0; i < ARR_SIZE; i++)
  {
    if (pinValuesArr[i] != oldPinValuesArr[i])
    {
      hasChanged = true;
    }
  }

  if (hasChanged)
  {
    Serial.print("*Pin value change detected*\r\n");
    display_pin_values();
    //oldPinValues = pinValues;
    for (int i = 0; i < ARR_SIZE; i++)
    {
      oldPinValuesArr[i] = pinValuesArr[i];
    }
  }

  delay(POLL_DELAY_MSEC);
}

void printBinary(byte inByte)
{
  for (int b = 7; b >= 0; b--)
  {
    Serial.print(bitRead(inByte, b));
  }
}
