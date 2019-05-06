#include <EtherCard.h>

static byte mymac[] = { 0x1A,0x2B,0x3C,0x4D,0x5E,0x6F };
byte Ethernet::buffer[700];
static uint32_t timer;

static byte myip[] = { 192,168,1,2 };
static byte gwip[] = { 192,168,1,100 };
static byte srip[] = { 192,168,1,100 };

// destination IP
//static uint8_t serverIP[] = {10, 10, 2, 24};
static uint8_t serverIP[] = { 192,168,1,100 };

const int dstPort PROGMEM = 5400;
const int srcPort PROGMEM = 5400;

void setup () {
  Serial.begin(9600);

  // Change 'SS' to your Slave Select pin, if you arn't using the default pin
  if (ether.begin(sizeof Ethernet::buffer, mymac, SS) == 0)
    Serial.println( "Failed to access Ethernet controller");

  ether.staticSetup(myip, gwip);
  
  ether.printIp("IP:  ", ether.myip);
  ether.printIp("GW:  ", ether.gwip);
  ether.printIp("DNS: ", ether.dnsip);

  //if (!ether.dnsLookup(website))
  //  Serial.println("DNS failed");

  //ether.printIp("SRV: ", ether.hisip);
}

char textToSend[] = "01010101010101010101010101010101010101";

void loop () {
  if (millis() > timer) {
      timer = millis() + 2000;

      Serial.println("Sending to server at: " + ipToString(serverIP));

     //static void sendUdp (char *data,uint8_t len,uint16_t sport, uint8_t *dip, uint16_t dport);
     ether.sendUdp(textToSend, sizeof(textToSend), srcPort, srip, dstPort );
  }
}

String ipToString(byte ip[4])
{
  return String(ip[0]) + "." + String(ip[1]) + "." + String(ip[2]) + "." + String(ip[3]);
}
