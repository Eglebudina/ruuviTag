# ruuviTag
raspberry pi and RuuviTag project

– updated 22–12–2021

RuuviTags are not set up with internet connectivity, therefore using Raspberry Pi is a perfect gateway. Raspberry Pi 3 has inbuilt BLE and WiFi and enough of processing power.

Our Raspberry Pi image has these components:

Rasbian as the base OS
WiFi hotspot to allow nearby devices to connect to it.
RuuviCollector to collect data
InfluxDB as a database
Grafana to provide a dashboard to InfluxDB
Raspberry Pi collecting and displaying data.
Raspberry Pi collecting and displaying data.

Once you log in, update the Pi by running sudo apt-get update and sudo apt-get upgrade.

Configuring the Raspberry Pi as a WiFi hotspot provides wireless connection to the Raspberry Pi without need to set up Ethernet connection. Configure your raspberry pi WiFi connection by running sudo raspi-config.

////////////////////////////////
InfluxDB
////////////////////////////////
Set up InfluxDB database, which is good for time series data and storing RuuviTag data. Influx data provides .deb builds for armhf. 

1. Run this command to install (source here https://portal.influxdata.com/downloads/):
wget https://dl.influxdata.com/influxdb/releases/influxdb-1.8.10_linux_armhf.tar.gz
tar xvfz influxdb-1.8.10_linux_armhf.tar.gz

2. Next, add the InfluxDB key. Adding the key will allow the package manager on Raspbian to search the repository and verify the packages its installing. Run the following command: curl https://repos.influxdata.com/influxdb.key | gpg --dearmor | sudo tee /usr/share/keyrings/influxdb-archive-keyring.gpg >/dev/null

3. We need to add InfluxDB repository to the sources list, run this command:
echo "deb [signed-by=/usr/share/keyrings/influxdb-archive-keyring.gpg] https://repos.influxdata.com/debian $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/influxdb.list
sudo apt-get update

4. Next, install InfluxDB to our Raspberry Pi, all we need to do is run the command below:
sudo apt install influxdb

5. With InfluxDB installed to Raspberry Pi, start it by making use of the systemctl service manager to enable our InfluxDB service file.
Run the following two commands to enable InfluxDB to start at boot on your Raspberry Pi:
sudo systemctl unmask influxdb
sudo systemctl enable influxdb

6. Start up the InfluxDB server: 
sudo systemctl start influxdb

7. Launch up Influx’s command-line tool by running the command below:
influx

9.  Create a database for ruuvi measurements with command: CREATE DATABASE ruuvi.

////////////////////////////////////////
Grafana
////////////////////////////////////////
Grafana is used to create dashboard and run some simple analytics on data. Download latest grafana binaries for Raspberry Pi from Grafana official distribution. Raspberry Pi 3, 3B+ and 4 use ARMv7.

Enable grafana with

sudo /bin/systemctl daemon-reload
sudo /bin/systemctl enable grafana-server
sudo /bin/systemctl start grafana-server
sudo /bin/systemctl status grafana-server
If everything has been properly set up, we can now browse over to raspberrypi.local:3000 and see web-ui of grafana. Default user and password is admin/admin. We change the password to ruuviberry on change password prompt.

Grafana login
Grafana login
Setup the connection to InfluxDB with “set up datasource” option. Settings:

Name: Ruuvi
Type: InfluxDB 
URL: http://localhost:8086
Access: proxy
Auth: blank
Database: ruuvi
Success image
Save and test, you should see a success image

/////////////////////////////////////////////////
RuuviCollector
/////////////////////////////////////////////////
RuuviCollector is a Java program which listens to HCIDump and parses RuuviTag data. It also provides some analytics, such as dew point based on humidity and temperature. Follow the instructions on github repository to install the RuuviCollector. Ruuvitag-sensor python library has some additional instructions on setting up the permissions of Bluetooth adapter of Raspberry Pi.
https://github.com/Scrin/RuuviCollector.git
https://github.com/ttu/ruuvitag-sensor.git

In my case, these commands are required to download dependencies and setup permissions:

sudo apt install openjdk-11-jdk
sudo apt install bluez bluez-hcidump
sudo setcap 'cap_net_raw,cap_net_admin+eip' `which hcitool`
sudo setcap 'cap_net_raw,cap_net_admin+eip' `which hcidump`
You can test the RuuviCollector by running
java -jar ruuvi-collector-0.2.jar. 

//////////////////////////////////////////////
Template for dashboard
/////////////////////////////////////////////
Browse back to raspberrypi.local:3000, create your first dashboard and add a panel. 
Add the template in the repo grafanaTemplate.json for displaying the dashboard in raspberrypi.local:3000.
