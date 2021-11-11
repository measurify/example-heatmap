# DESIGN AND IMPLEMENTATION OF AN EMBEDDED SYSTEM FOR THE DEVELOPMENT OF HEATMAPS
The aim of this thesis is to design and implement an embedded system in order to detect and store information on the cloud about the location of the user carrying the device and, later, to use such geolocation data to obtain a heatmap of the displacements, that is, a graphical representation of the data in which the individual values ​​are represented by colors.
Specifically, a T-Beam ESP32 card equipped with integrated GPS and Wi-Fi modules is used. The data collected by this device is stored on the cloud through the features provided by the Measurify API.
At this point, the samples can be viewed through a mobile device application created using the Flutter framework. Before that, you need to authenticate to Measurify so that it is actually possible to communicate with the cloud and take the stored samples. The application includes several screens with which it is possible to perform multiple actions, including selecting the date that will be used to filter the samples, view the heatmap of the movements and analyze some statistics, obtained through local computation, on the geolocation data.

## Quick start

To setup the embedded system, the following steps need to be followed:
1. Install Arduino IDE.
2. Inside the IDE settings, in:
	"File --> Settings --> Additional Boards Manager URLs"
   Specify the following libraries to make the IDE work with ESP32 boards:
	https://dl.espressif.com/dl/package_esp32_index.json
3. Install the following libraries:
	- WiFi
	- HTTPClient
	- TinyGPS++
	- ArduinoJson
4. Now the sketch is ready to be compiled and executed by the board.

To setup the mobile device, the following steps need to be followed:
1. Install AndroidStudio IDE.
2. Install the Flutter plugin.
3. Create an empty Flutter project.
4. Inside the "lib" folder place the code in the repository.
5. Replace the pubspect.yaml file.
6. Replace the AndroidManifest.xml file inside "android/app/scr/main".
7. Now the client application is ready to be debugged on a device.