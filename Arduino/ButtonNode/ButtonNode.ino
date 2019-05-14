#include <EtherCard.h>

// ****************************************
// ****************************************
//        Network Configuration
// ****************************************
// ****************************************

static byte mymac[] = { 0x1A,0x2B,0x3C,0x4D,0x5E,0x6F };
static byte myip[] = { 192,168,1,2 };

static byte srip[] = { 192,168,1,125 };  // destination IP
static byte gwip[] = { 192,168,1,1 };
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

int clockEnablePin  = 3;  // Connects to Clock Enable pin the 165
int dataPin         = 6;  // Connects to the Q7 pin the 165
int clockPin        = 7;  // Connects to the Clock pin the 165

BYTES_VAL_T pinValues;
BYTES_VAL_T oldPinValues;


void setup () {
  Serial.begin(9600);

  initNetworking();
  initShiftRegisters();
}

void initNetworking()
{
  if (ether.begin(sizeof Ethernet::buffer, mymac, SS) == 0){
    Serial.println( "Failed to access Ethernet controller");
  }


  if (!ether.dhcpSetup()){
    Serial.println("DHCP failed. Setting static ip.");
    ether.staticSetup(myip, gwip, dns);
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
}

//char textToSend[] = "01010101010101010101010101010101010101";
char textToSend[39];

void loop () {
  
  // Read the state of all zones.
  pinValues = read_shift_regs();

  // If there was a chage in state, display which ones changed.
  if(pinValues != oldPinValues)
  {
      String pinValsStr = create_pin_values_string();
      
      Serial.print("Pin value change detected: ");
      Serial.println(pinValsStr);

      pinValsStr.toCharArray(textToSend, 39);
      ether.sendUdp(textToSend, sizeof(textToSend), srcPort, srip, dstPort );
      
      oldPinValues = pinValues;
  }
  
  delay(POLL_DELAY_MSEC);
}

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
 * serial data from the shift register chips and representing
 * the state of those pins in an unsigned integer (or long).
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
    for(int i = 0; i < DATA_WIDTH; i++)
    {
        bitVal = digitalRead(dataPin);

        // Set the corresponding bit in bytesVal.
        bytesVal |= (bitVal << ((DATA_WIDTH-1) - i));

        // Pulse the Clock (rising edge shifts the next bit).
        digitalWrite(clockPin, HIGH);
        delayMicroseconds(PULSE_WIDTH_USEC);
        digitalWrite(clockPin, LOW);
    }

    return(bytesVal);
}

String create_pin_values_string()
{
    String temp = "";

    for(int i = 0; i < DATA_WIDTH; i++)
    {
        if((pinValues >> i) & 1){
          temp += "1";
        }
        else {
          temp += "0";
        }
    }
    return temp;
}
 
void display_pin_values()
{
    Serial.print("Pin States:\r\n");

    for(int i = 0; i < DATA_WIDTH; i++)
    {
        Serial.print("  Pin-");
        Serial.print(i);
        Serial.print(": ");

        if((pinValues >> i) & 1)
            Serial.print("HIGH");
        else
            Serial.print("LOW");

        Serial.print("\r\n");
    }

    Serial.print("\r\n");
}
//END SHIFTY STUFF
