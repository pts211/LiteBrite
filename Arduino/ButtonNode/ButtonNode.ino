#include <EtherCard.h>

// ****************************************
// ****************************************
//        Network Configuration
// ****************************************
// ****************************************

static byte mymac[] = { 0x1A, 0x2B, 0x3C, 0x4D, 0x5E, 0x6F };
static byte myip[] = { 192, 168, 1, 2 };

static byte srip[] = { 192, 168, 1, 125 }; // destination IP
static byte gwip[] = { 192, 168, 1, 1 };
//static byte dns[]  = { 192,168,1,1 };

const int dstPort PROGMEM = 6000;
const int srcPort PROGMEM = 6000;

byte Ethernet::buffer[700];
static uint32_t timer;

// ****************************************
// ****************************************
//        Shift Register Configuration
// ****************************************
// ****************************************

// How many shift register chips are daisy-chained.
#define NUMBER_OF_SHIFT_CHIPS   5

//Width of data (how many ext lines).
#define DATA_WIDTH   NUMBER_OF_SHIFT_CHIPS * 8

// Width of pulse to trigger the shift register to read and latch.
#define PULSE_WIDTH_USEC   5

//Optional delay between shift register reads.
#define POLL_DELAY_MSEC   1
#define BYTES_VAL_T unsigned long

int ploadPin        = 8;  // Connects to Parallel load pin the 165
int clockEnablePin  = 3;  // Connects to Clock Enable pin the 165
int dataPin         = 6;  // Connects to the Q7 pin the 165
int clockPin        = 7;  // Connects to the Clock pin the 165

BYTES_VAL_T tempPinValues;
BYTES_VAL_T deltaPinValues;
BYTES_VAL_T oldDeltaPinValues;
BYTES_VAL_T pinValues;
BYTES_VAL_T oldPinValues;

void setup () {
  Serial.begin(9600);

  initNetworking();
  initShiftRegisters();
}

void initNetworking()
{
  if (ether.begin(sizeof Ethernet::buffer, mymac, SS) == 0) {
    Serial.println( "Failed to access Ethernet controller");
  }


  if (!ether.dhcpSetup()) {
    Serial.println("DHCP failed. Setting static ip.");
    ether.staticSetup(myip, gwip);
  }

  ether.printIp("IP:  ", ether.myip);
  ether.printIp("GW:  ", ether.gwip);
  //ether.printIp("DNS: ", ether.dnsip);

  //if (!ether.dnsLookup(website))
  //  Serial.println("DNS failed");
  //ether.printIp("SRV: ", ether.hisip);
}

void initShiftRegisters()
{
  // Initialize our digital pins
  pinMode(ploadPin, OUTPUT);
  pinMode(clockEnablePin, OUTPUT);
  pinMode(clockPin, OUTPUT);
  pinMode(dataPin, INPUT);

  digitalWrite(clockPin, LOW);
  digitalWrite(ploadPin, HIGH);

  // Read in the pin states at startup.
  pinValues = read_shift_regs();
  oldPinValues = pinValues;
  oldDeltaPinValues = deltaPinValues;
}

//char textToSend[] = "01010101010101010101010101010101010101";
char textToSend[DATA_WIDTH];

void loop () {
  // Read the state of all zones.
  pinValues = read_shift_regs();


  /*  
   * Since it is possible that multiple buttons in the same row could be pressed
   * at the same time - more specifically, a new button could be pressed while another butting
   * was already pressed - it is important to only send the change, delta, of the button states over
   * the network. 
   * 
   * To do this we will only care when a button transistions from 0->1, ignoring when the button is released.
   * 
   * We want to avoid:
   * Frame 1: 00000000000000000000000000000000000001
   * Frame 2: 00000000000000000000000000000000000101
   * and instead send:
   * Frame 1: 00000000000000000000000000000000000001
   * Frame 2: 00000000000000000000000000000000000100
   * In both scenarios, two buttons are pressed in Frame 2.
   * 
   */
  /*
   * If I XOR previousVals and currentVals, then AND result and currentVals we will get ony the change to a pressed state.
   * Threw a little demo sketch together to verify. https://code.sololearn.com/c40x3N2NWcIr/#py
   */
  tempPinValues = pinValues ^ oldPinValues;  // XOR the old and new
  deltaPinValues = tempPinValues & pinValues;// AND the new and xor'd value to get only the changes to 1's.

  /*
  // TODO REMOVE This should be UNNEEDED thanks to bitwise operators. Keeping around just in case I need a backup.
  long currentBitVal;
  long previousBitVal;
  for (int i = 0; i < DATA_WIDTH; i++)
  {
    currentBitVal = (pinValues >> i);
    previousBitVal = (oldPinValues >> i);

    if(currentBitVal == previousBitVal){
      deltaPinValues |= (0 << ((DATA_WIDTH - 1) - i));
    }
    else if( (currentBitVal != previousBitVal) && currentBitVal){
      deltaPinValues |= (1 << ((DATA_WIDTH - 1) - i));
    }
  }
  */

  if(deltaPinValues != oldDeltaPinValues)
  {
    String pinValsStr = create_pin_values_string(pinValues);
    String deltaPinValsStr = create_pin_values_string(deltaPinValues);

    Serial.print("Pin value change detected: \r\n pinVal: ");
    Serial.println(pinValsStr);
    Serial.print("delVal: ");
    Serial.println(deltaPinValsStr);

    //We only want to broadcast data out if we are on a rising edge of a change.
    //Make sure that we are sending a toggle.
    if(deltaPinValsStr.indexOf('1') >= 0){
      deltaPinValsStr.toCharArray(textToSend, DATA_WIDTH);
      ether.sendUdp(textToSend, sizeof(textToSend), srcPort, srip, dstPort );  
    }
    
    oldPinValues = pinValues;
    oldDeltaPinValues = deltaPinValues;
  }



  // If there was a chage in state, display which ones changed.
  /*
  //TODO REMOVE This is the old logic that broadcasts all state changes. Removal pending
  //testing of new methods.
  if (pinValues != oldPinValues)
  {
    String pinValsStr = create_pin_values_string();

    Serial.print("Pin value change detected: ");
    Serial.println(pinValsStr);

    pinValsStr.toCharArray(textToSend, DATA_WIDTH);
    ether.sendUdp(textToSend, sizeof(textToSend), srcPort, srip, dstPort );

    oldPinValues = pinValues;
  }
  */

  delay(POLL_DELAY_MSEC);
}

// ****************************************
// ****************************************
//        Networking Methods
// ****************************************
// ****************************************

String ipToString(byte ip[4])
{
  return String(ip[0]) + "." + String(ip[1]) + "." + String(ip[2]) + "." + String(ip[3]);
}

// ****************************************
// ****************************************
//        Shift Register Methods
// ****************************************
// ****************************************

/* This function is essentially a "shift-in" routine reading the
   serial data from the shift register chips and representing
   the state of those pins in an unsigned integer (or long).
*/
BYTES_VAL_T read_shift_regs()
{
  long bitVal;
  BYTES_VAL_T bytesVal = 0;

  // Trigger a parallel Load to latch the state of the data lines,
  digitalWrite(clockEnablePin, HIGH);
  digitalWrite(ploadPin, LOW);
  delayMicroseconds(PULSE_WIDTH_USEC);
  digitalWrite(ploadPin, HIGH);
  digitalWrite(clockEnablePin, LOW);

  // Loop to read each bit value from the serial out line of the SN74HC165N.
  for (int i = 0; i < DATA_WIDTH; i++)
  {
    bitVal = digitalRead(dataPin);

    // Set the corresponding bit in bytesVal.
    bytesVal |= (bitVal << ((DATA_WIDTH - 1) - i));

    // Pulse the Clock (rising edge shifts the next bit).
    digitalWrite(clockPin, HIGH);
    delayMicroseconds(PULSE_WIDTH_USEC);
    digitalWrite(clockPin, LOW);
  }

  return (bytesVal);
}

String tempStr = "";

String create_pin_values_string(BYTES_VAL_T values)
{
  tempStr = "";
  for (int i = 0; i < DATA_WIDTH; i++)
  {
    //Test simplifying.
    tempStr += (values >> i);
    /*
      if((pinValues >> i) & 1){
        temp += "1";
      }
      else {
        temp += "0";
      }
    */
  }
  return tempStr;
}

/*
String create_pin_values_string()
{
  tempStr = "";
  for (int i = 0; i < DATA_WIDTH; i++)
  {
    //Test simplifying.
    tempStr += (pinValues >> i);
    
     // if((pinValues >> i) & 1){
     //   temp += "1";
     // }
     // else {
     //   temp += "0";
     // }
    
  }
  return tempStr;
}
*/

void display_pin_values()
{
  Serial.print("Pin States:\r\n");

  for (int i = 0; i < DATA_WIDTH; i++)
  {
    Serial.print("  Pin-");
    Serial.print(i);
    Serial.print(": ");

    if ((pinValues >> i) & 1)
      Serial.print("HIGH");
    else
      Serial.print("LOW");

    Serial.print("\r\n");
  }

  Serial.print("\r\n");
}
//END SHIFTY STUFF
