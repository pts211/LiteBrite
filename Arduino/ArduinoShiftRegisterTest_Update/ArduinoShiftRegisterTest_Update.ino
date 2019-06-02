/*
   SN74HC165N_shift_reg

   Program to shift in the bit values from a SN74HC165N 8-bit
   parallel-in/serial-out shift register.
*/

#include <BitBool.h>

/* How many shift register chips are daisy-chained.
*/
#define NUMBER_OF_SHIFT_CHIPS   5

/* Width of data (how many ext lines).
*/
#define DATA_WIDTH   NUMBER_OF_SHIFT_CHIPS * 8

/* Width of pulse to trigger the shift register to read and latch.
*/
#define PULSE_WIDTH_USEC   5

/* Optional delay between shift register reads.
*/
#define POLL_DELAY_MSEC   1


int ploadPin        = 8;  // Connects to Parallel load pin the 165
int clockEnablePin  = 3;  // Connects to Clock Enable pin the 165
int dataPin         = 6; // Connects to the Q7 pin the 165
int clockPin        = 7; // Connects to the Clock pin the 165

BitBool<DATA_WIDTH> bits;
BitBool<DATA_WIDTH> oldBits;

/* This function is essentially a "shift-in" routine reading the
   serial Data from the shift register chips and representing
   the state of those pins in an unsigned integer (or long).
*/
void read_shift_regs()
{
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
  for (int i = 0; i < DATA_WIDTH; i++)
  {
    /* Set the corresponding bit in bytesVal.
    */
    bits[i] = digitalRead(dataPin);

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

  for (int i = 0; i < DATA_WIDTH; i++)
  {
    Serial.print("  Pin-");
    Serial.print(i);
    Serial.print(": ");

    if (bits[i])
      Serial.print("HIGH");
    else
      Serial.print("LOW");

    Serial.print("\r\n");
  }

  Serial.print("\r\n");
}

void setup()
{
  Serial.begin(250000);

  /* Initialize our digital pins...
  */
  pinMode(ploadPin, OUTPUT);
  pinMode(clockEnablePin, OUTPUT);
  pinMode(clockPin, OUTPUT);
  pinMode(dataPin, INPUT);

  digitalWrite(clockPin, LOW);
  digitalWrite(ploadPin, HIGH);


  read_shift_regs();
  display_pin_values();
  oldBits = bits;
}

boolean hasChanged = false;
void loop()
{
  /* Read the state of all zones.
  */
  read_shift_regs();


  for (int i = 0; i < DATA_WIDTH; i++)
  {
    if ( bits[i] != oldBits[i] ) {
      hasChanged = true;
      break;
    }
  }

  if (hasChanged)
  {
    Serial.print("*Pin value change detected*\r\n");
    display_pin_values();
    oldBits = bits;
    hasChanged = false;
  }

  delay(POLL_DELAY_MSEC);
}

BitBool<DATA_WIDTH> notxor(BitBool<DATA_WIDTH> x1, BitBool<DATA_WIDTH> x2)
{


}
