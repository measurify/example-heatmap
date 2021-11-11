// Library used to connect to the WiFi
#include <WiFi.h>
// Library used to send requests to Measurify
#include <HTTPClient.h>
// Library used to get GSP data from the device
#include <TinyGPS++.h>
// Library used to handle json objects
#include <ArduinoJson.h>

const char* wifi_ssid = "Oneplus 8T";
const char* wifi_password = "123456789abc";

const char* measurify_username = "heatmap-user-username";
const char* measurify_password = "heatmap-user-password";
const char* measurify_tenant = "measurify-heatmap";
char* measurify_token = "";

HTTPClient http;
TinyGPSPlus gps;
StaticJsonDocument<1024> doc;

struct gpssample
{
  double lat;
  double lng;
  double alt;
};

int cacheMaxIndex = 100000 / sizeof(gpssample);
gpssample* cache = new gpssample[cacheMaxIndex+1];
int cacheNextIndex = 0;

void setup()
{
  // Initialize Serial for log info
  Serial.begin(115200);

  // Initialize Serial1 for GPS data comunication
  Serial1.begin(9600, SERIAL_8N1, 34, 12);
}

void loop() 
{
  // Waits for some time before retrieving new GPS data
  delay(5000);
  
  // Checks if the device is connected to the WiFi and
  // tries to connect it otherwise.
  checkAndConnectToWiFi(wifi_ssid, wifi_password);

  // Updated the GPS data so that are available for retrival
  // in the next steps. Goes to next iteration if this fails.
  if(!updateGPSData())
    return;

  // Gets the current GPS samples.
  gpssample sampl = getCurrentGPSSample();

  // If manages to send current sample, tries to send all cached samples.
  // Otherwise caches current sample.
  if(sendSample(sampl))
    sendCachedSamples();
  else
    cacheSample(sampl);
}

static void checkAndConnectToWiFi(const char* ssid, const char* password) 
{
  if(WiFi.status() == WL_CONNECTED)
    return; 
  
  Serial.println("Trying to connect to WiFi...");
  
  WiFi.begin(ssid, password);
  delay(2000);

  if(WiFi.status() == WL_CONNECTED)
    Serial.println(String("Connected to WiFi with IP: ") + String(WiFi.localIP()));
  else
    Serial.println("Failed to connect to WiFi... retring later");
}

static bool requestToken()
{
  // Makes a get request with the specified body and some headers
  http.begin("https://students.atmosphere.tools/v1/login");
  http.addHeader("Content-Type", "application/json");
  http.addHeader("Connection", "keep-alive");
  int code = http.POST(
    String("{\"username\":\"") + measurify_username + 
    String("\",\"password\":\"") + measurify_password + 
    String("\",\"tenant\":\"") + measurify_tenant + String("\"}")
    );
  String json = http.getString();
  http.end();

  if(code != 200)
  {
    Serial.println("Could not connect to Measurify!");
    return false;
  }

  DeserializationError error = deserializeJson(doc, json);
  if (deserializeJson(doc, json)) 
  {
    Serial.print("Measurify's response json deserialization failed: ");
    Serial.println(error.f_str());
    return false;
  }

  measurify_token = const_cast<char*>(doc["token"].as<char*>());
  Serial.println("Correctly got token from Measurify.");
  return true;
}

// Function that retrieves GPS info.
// It takes 1 millis to retrieve the data if nothing goes wrong.
// The function tries to retrieve the data for 50 millis.
static boolean updateGPSData()
{
  unsigned long start = millis();
  do
  {
    while(Serial1.available()) 
    {
      gps.encode(Serial1.read());
      if(gps.location.isUpdated())
      {
        Serial.println("Correctly retrieved GPS data.");
        return true;
      }
    }
  }while(millis() - start < 100);

  Serial.println("Failed to retrieve GPS data!");
  return false;
}

static gpssample getCurrentGPSSample()
{
  return (gpssample) {
    gps.location.lat(), 
    gps.location.lng(), 
    gps.altitude.meters()
  };
}

static void cacheSample(gpssample sampl)
{
  if(cacheNextIndex > cacheMaxIndex)
  {
    Serial.println("Cache reached limit, discarding sample.");
    return;
  }

  cache[cacheNextIndex] = sampl;
  ++cacheNextIndex;
  Serial.println("A sample has been cached.");
}

static void sendCachedSamples()
{
  // Check if there are available samples
  if(cacheNextIndex == 0)
    return;

  Serial.print("Sending ");
  Serial.print(cacheNextIndex);
  Serial.println(" cached samples...");

  do
  {
    if(sendSample(cache[cacheNextIndex-1]))
      --cacheNextIndex;
    else
      break;
  }while(cacheNextIndex > 0);

  if(cacheNextIndex == 0)
    Serial.println("...sent all cached samples.");
  else
  {
    Serial.print("...could not send all samples, ");
    Serial.print(cacheNextIndex);
    Serial.println(" remaining!");
  }
}

static bool sendSample(gpssample sampl)
{ 
  String body =
  String("{ \"thing\":\"user A\",")+
  String("\"feature\":\"location\",")+
  String("\"device\":\"heatmap-monitor\",")+
  String("\"location\":{\"type\": \"Point\", \"coordinates\": [")+
    String(sampl.lat, 6)+String(",")+
    String(sampl.lng, 6)+String("]},")+
  String("\"samples\":[{\"values\": ")+sampl.alt+String("}] }");
  
  http.begin("https://students.atmosphere.tools/v1/measurements");

  http.addHeader("Content-Type", "application/json");
  http.addHeader("Content-Length", String(body.length()));
  http.addHeader("Host", "students.atmosphere.tools");
  http.addHeader("Connection", "keep-alive");
  http.addHeader("Authorization", measurify_token);
  int code = http.POST(body);

  http.end();

  if(code == 401)
  {
    Serial.println("Token expired, requesting new token...");
    requestToken();
    return false;
  }
  
  if(code != 200)
  {
    Serial.print("Sample not posted correctly on Measurify! Code: ");
    Serial.println(code);
    return false;
  }

  Serial.println("Sample posted correctly on Measurify.");
  return true;
}
