/* ButtonNode.ino
   Author: Paul Sites (paul.sites@cerner.com)

   This ButtonNode is part of the LiteBrite project, created for DevCon 2019. The LiteBrite, slotted to have 24 rows,
   will have an arduino per row. Each arduino is responsible for monitoring button input from 38 buttons and passing
   the data on to the main controller over UDP.

   The IP of each Arduino should represent the row that they are positioned on the LiteBrite, starting from the top at 1.
   The MAC address should be unique for each Arduino.
   The destination IP can either be a specific device IP, or a broadcast (255.255.255.255).
*/

#define ROW_NUMBER   1
//The ROW_NUMBER will automatically configure the correct IP and unique MAC address.

#include <EEPROM.h>
#include <BitBool.h>

// ****************************************
// ****************************************
//        Network Configuration
// ****************************************
// ****************************************
#include <EtherCard.h>

static byte mymac[] = { 0x1A, 0x2B, 0x3C, 0x4D, 0x5E, ROW_NUMBER };
static byte myip[] = { 192, 168, 1, ROW_NUMBER };

//static byte srip[] = { 192, 168, 1, 100 }; // destination IP
static byte srip[] = { 255, 255, 255, 255 }; // destination IP
static byte gwip[] = { 192, 168, 1, 100 };
static byte dns[]  = { 192, 168, 1, 100 };
static byte mask[] = { 255, 255, 255, 0 }; //REQUIRED. Otherwise the DST MAC won't be specified.

const int dstPort PROGMEM = 6000;
const int srcPort PROGMEM = 6000;

const bool useDHCP PROGMEM = false;

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

#define NUM_ACTIVE_INPUTS 38

// Width of pulse to trigger the shift register to read and latch.
#define PULSE_WIDTH_USEC   5

//Optional delay between shift register reads.
#define POLL_DELAY_MSEC   10      //TODO 5/29 increased from 1ms. Going to see if that helps the double hit.
#define BYTES_VAL_T unsigned long


int configPin        = 9;  // Connects to the Clock pin the 1

int ploadPin        = 8;  // Connects to Parallel load pin the 165
int clockEnablePin  = 3;  // Connects to Clock Enable pin the 165
int dataPin         = 6;  // Connects to the Q7 pin the 165
int clockPin        = 7;  // Connects to the Clock pin the 165

BYTES_VAL_T tempPinValues;
BYTES_VAL_T deltaPinValues;
BYTES_VAL_T oldDeltaPinValues;
BYTES_VAL_T pinValues;
BYTES_VAL_T oldPinValues;

BitBool<DATA_WIDTH> tempPinValuesB;
BitBool<DATA_WIDTH> deltaPinValuesB;
BitBool<DATA_WIDTH> oldDeltaPinValuesB;
BitBool<DATA_WIDTH> pinValuesB;
BitBool<DATA_WIDTH> oldPinValuesB;


boolean isTraining = true;
int activeMappingIndex = 0;
byte buttonMapping[DATA_WIDTH];
String calibrationString = "00000000000000000000000000000000000000";//String(DATA_WIDTH, '0');





BitBool<DATA_WIDTH> pXOR(BitBool<DATA_WIDTH> x, BitBool<DATA_WIDTH> y)
{
  BitBool<DATA_WIDTH> result;
  for (int i = 0; i < DATA_WIDTH; i++)
  {
    if ( x[i] ^ y[i] ) {
      result[i] = true;
    } else {
      result[i] = false;
    }
  }
  return result;
}

BitBool<DATA_WIDTH> pAND(BitBool<DATA_WIDTH> x, BitBool<DATA_WIDTH> y)
{
  BitBool<DATA_WIDTH> result;
  for (int i = 0; i < DATA_WIDTH; i++)
  {
    if ( x[i] & y[i] ) {
      result[i] = true;
    } else {
      result[i] = false;
    }
  }
  return result;
}

void initMapping()
{
  for (int i = 0; i < DATA_WIDTH; i++)
  {
    buttonMapping[i] = i;
  }
}

void printButtonMapping()
{
  for (int i = 0; i < DATA_WIDTH; i++)
  {
    Serial.println("Input[" + String(i) + "] == button[" + buttonMapping[i] + "]");
  }
}

void startButtonTraining()
{

}

String generateCalibrationString(int index)
{
  String output = "";
  for (int i = 0; i < DATA_WIDTH; i++)
  {
    output += (i == index) ? "1" : "0";
  }
  //output += "c";
  return output;
}

void endButtonTraining()
{
  isTraining = false;
  Serial.println("Mapping complete.");
  printButtonMapping();
  //saveButtonMapping();
}

void readButtonMapping()
{
  Serial.println("Config: Reading mapping.");

  if ( EEPROM.read ( 0 ) != 0xff ) {
    for (int i = 0; i < DATA_WIDTH; ++i )
      buttonMapping [ i ] = EEPROM.read ( i );
  }
  Serial.println("Config: Read.");
}

void saveButtonMapping()
{
  Serial.println("Config: Saving mapping.");
  int eeAddress = 0;   //Location we want the data to be put.
  for ( int i = 0; i < DATA_WIDTH; ++i ) {
    EEPROM.write ( i, buttonMapping [ i ] );
  }
  Serial.println("Config: Saved.");
}

void setup () {
  Serial.begin(9600);

  Serial.println("ButtonNode: Starting...");

  initMapping();

  initNetworking();
  initShiftRegisters();


  initMapping();
  printButtonMapping();
  //saveButtonMapping();

  Serial.println("ButtonNode: Ready.");

}

void initNetworking()
{
  Serial.println("ButtonNode: Initializing Network.");
  if (ether.begin(sizeof Ethernet::buffer, mymac, SS) == 0) {
    Serial.println( "Failed to access Ethernet controller");
  }

  if (!useDHCP || !ether.dhcpSetup()) {
    if (useDHCP) {
      Serial.println("DHCP failed. Setting static ip.");
    }
    ether.staticSetup(myip, gwip, dns, mask);
  }

  char mac_cstr[17];
  ether.makeNetStr(mac_cstr, mymac, sizeof(mymac), ':', 16);
  Serial.println("\tMAC: " + String(mac_cstr));
  ether.printIp("\tIP:  ", ether.myip);
  ether.printIp("\tGW:  ", ether.gwip);
  ether.printIp("\tDNS: ", ether.dnsip);

  //if (!ether.dnsLookup(website))
  //  Serial.println("DNS failed");
  //ether.printIp("SRV: ", ether.hisip);
}

void initShiftRegisters()
{
  Serial.println("ButtonNode: Initializing Buttons.");
  // Initialize our digital pins
  pinMode(ploadPin, OUTPUT);
  pinMode(clockEnablePin, OUTPUT);
  pinMode(clockPin, OUTPUT);
  pinMode(dataPin, INPUT);

  pinMode(configPin, INPUT);
  digitalWrite(configPin, HIGH);

  digitalWrite(clockPin, LOW);
  digitalWrite(ploadPin, HIGH);

  // Read in the pin states at startup.
  read_shift_regs();
  //oldPinValues = pinValues;
  oldDeltaPinValuesB = deltaPinValuesB;
}

//char textToSend[] = "01010101010101010101010101010101010101";
char textToSend[DATA_WIDTH];

void loop () {

  checkConfigButton();
  //REQUIRED. Handles low level network responses. Part of the MAC address fix.
  ether.packetLoop(ether.packetReceive());

  // Read the state of all zones.
  read_shift_regs();


  /*
     Since it is possible that multiple buttons in the same row could be pressed
     at the same time - more specifically, a new button could be pressed while another butting
     was already pressed - it is important to only send the change, delta, of the button states over
     the network.

     To do this we will only care when a button transistions from 0->1, ignoring when the button is released.

     We want to avoid:
     Frame 1: 00000000000000000000000000000000000001
     Frame 2: 00000000000000000000000000000000000101
     and instead send:
     Frame 1: 00000000000000000000000000000000000001
     Frame 2: 00000000000000000000000000000000000100
     In both scenarios, two buttons are pressed in Frame 2.

  */
  /*
     If I XOR previousVals and currentVals, then AND result and currentVals we will get ony the change to a pressed state.
     Threw a little demo sketch together to verify. https://code.sololearn.com/c40x3N2NWcIr/#py
  */

  //tempPinValuesB = pinValuesB ^ oldPinValuesB;  // XOR the old and new
  tempPinValuesB = pXOR(pinValuesB, oldPinValuesB);  // XOR the old and new

  //deltaPinValuesB = tempPinValuesB & pinValuesB;// AND the new and xor'd value to get only the changes to 1
  deltaPinValuesB = pAND(tempPinValuesB, pinValuesB);// AND the new and xor'd value to get only the changes to 1's.


  //tempPinValues = pinValues ^ oldPinValues;  // XOR the old and new
  //deltaPinValues = tempPinValues & pinValues;// AND the new and xor'd value to get only the changes to 1's.

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

  /*
    String pinValsStr = create_pin_values_string(pinValues);
    String deltaPinValsStr = create_pin_values_string(deltaPinValues);
    String oldDeltaPinValsStr = create_pin_values_string(oldDeltaPinValues);
    Serial.println("pins:      " + pinValsStr);
    Serial.println("delVal:    " + deltaPinValsStr);
    Serial.println("oldDelVal: " + oldDeltaPinValsStr);
  */
  boolean hasChanged = false;
  for (int i = 0; i < DATA_WIDTH; i++)
  {
    if ( deltaPinValuesB[i] != oldDeltaPinValuesB[i] ) {
      hasChanged = true;
      break;
    }
  }

  if (hasChanged)
  {
    //We only want to broadcast data out if we are on a rising edge of a change.
    //Make sure that we are sending a toggle.



    if (isTraining)
    {
      String deltaPinValsStr = create_pin_values_stringB(deltaPinValuesB);
      if (deltaPinValsStr.indexOf('1') >= 0) {
        Serial.println("SIGNIFICANT");

        train(deltaPinValsStr);
        /*
          buttonMapping[activeMappingIndex++] = deltaPinValsStr.indexOf('1');
          if (activeMappingIndex == DATA_WIDTH) {
          //Configuration complete.
          endButtonTraining();
          }
        */
      } else {
        Serial.println("INSIGNIFICANT");
      }

    } else {
      String deltaPinValsStr = create_pin_values_stringB_calib(deltaPinValuesB);
      if (deltaPinValsStr.indexOf('1') >= 0) {
        deltaPinValsStr.toCharArray(textToSend, DATA_WIDTH);
        ether.sendUdp(textToSend, sizeof(textToSend), srcPort, srip, dstPort );
      }
      else {
        Serial.println("INSIGNIFICANT");
      }
    }

    //Serial.println(" change detected.");

    oldPinValuesB = pinValuesB;
    oldDeltaPinValuesB = deltaPinValuesB;
  }

  hasChanged = false;
  for (int i = 0; i < DATA_WIDTH; i++)
  {
    if ( pinValuesB[i] != oldPinValuesB[i] ) {
      hasChanged = true;
      break;
    }
  }

  if (hasChanged)
  {
    oldPinValuesB = pinValuesB;
  }

  // If there was a chage in state, display which ones changed.

  //TODO REMOVE This is the old logic that broadcasts all state changes. Removal pending
  //testing of new methods.
  /*
    if (pinValues != oldPinValues)
    {
    String pinValsStr = create_pin_values_string(pinValues);

    Serial.print("Pin value change detected: ");
    Serial.println(pinValsStr);

    pinValsStr.toCharArray(textToSend, DATA_WIDTH);
    ether.sendUdp(textToSend, sizeof(textToSend), srcPort, srip, dstPort );

    oldPinValues = pinValues;
    }
  */
  /*
    //TODO DEBUG Helpful for checking that packets are making it to their destination.
    if (millis() > timer) {
      timer = millis() + 4000;

      Serial.print("Sending to server at: ");
      Serial.println(ipToString(srip));

     //static void sendUdp (char *data,uint8_t len,uint16_t sport, uint8_t *dip, uint16_t dport);
     ether.sendUdp(textToSend, sizeof(textToSend), srcPort, srip, dstPort );
    }
  */

  //if (isTraining && hasChanged && (millis() > timer) ) {
  /*
    if (isTraining && hasChanged) {
    //timer = millis() + 500;

    calibrationString = generateCalibrationString(activeMappingIndex);

    Serial.print("Sending calibration string: ");
    Serial.println(calibrationString);
    //Serial.println(ipToString(srip));

    char calibrationTextToSend[calibrationString.length() + 1];

    calibrationString.toCharArray(calibrationTextToSend, calibrationString.length());
    ether.sendUdp(calibrationTextToSend, sizeof(calibrationTextToSend), srcPort, srip, dstPort );
    }
  */
  delay(POLL_DELAY_MSEC);

}

void train(String deltaPinValsStr)
{
  buttonMapping[activeMappingIndex] = deltaPinValsStr.indexOf('1');
  
  if (activeMappingIndex >= NUM_ACTIVE_INPUTS - 1) {
  
    //Configuration complete.
    endButtonTraining();
  }
  calibrationString = generateCalibrationString(activeMappingIndex);

  Serial.print("Sending calibration string: ");
  Serial.println(calibrationString);
  //Serial.println(ipToString(srip));

  char calibrationTextToSend[calibrationString.length() + 1];

  calibrationString.toCharArray(calibrationTextToSend, calibrationString.length());
  ether.sendUdp(calibrationTextToSend, sizeof(calibrationTextToSend), srcPort, srip, dstPort );
  
  activeMappingIndex++;
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
    pinValuesB[i] = digitalRead(dataPin);

    /* Pulse the Clock (rising edge shifts the next bit).
    */
    digitalWrite(clockPin, HIGH);
    delayMicroseconds(PULSE_WIDTH_USEC);
    digitalWrite(clockPin, LOW);
  }
}

String tempStr = "";
String create_pin_values_string(BYTES_VAL_T values)
{
  tempStr = "";
  for (int i = 0; i < DATA_WIDTH; i++)
  {
    //Test simplifying.
    tempStr += ((values >> i) & 1) ? "1" : "0";
  }
  return tempStr;
}

String create_pin_values_stringB(BitBool<DATA_WIDTH> values)
{
  tempStr = "";
  for (int i = 0; i < DATA_WIDTH; i++)
  {
    //Test simplifying.
    tempStr += values[i] ? "1" : "0";
  }
  return tempStr;
}

String create_pin_values_stringB_calib(BitBool<DATA_WIDTH> values)
{
  tempStr = "";
  for (int i = 0; i < DATA_WIDTH; i++)
  {
    //Test simplifying.
    tempStr += values[ buttonMapping[i] ] ? "1" : "0";
  }
  return tempStr;
}

void display_pin_values()
{
  Serial.print("Pin States:\r\n");

  for (int i = 0; i < DATA_WIDTH; i++)
  {
    Serial.print("  Pin-");
    Serial.print(i);
    Serial.print(": ");

    if (pinValuesB[i])
      Serial.print("HIGH");
    else
      Serial.print("LOW");

    Serial.print("\r\n");
  }

  Serial.print("\r\n");
}
//END SHIFTY STUFF
