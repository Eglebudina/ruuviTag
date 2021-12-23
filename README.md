# ruuviTag
Raspberry pi and RuuviTag project. Some knowledge in Linux and Java is necessary for fully understanding how to use this application.

– updated 22–12–2021

RuuviTags are not set up with internet connectivity, therefore using Raspberry Pi is a perfect gateway. Raspberry Pi 3 has inbuilt BLE and WiFi and enough of processing power.

Once you log in, update the Pi by running sudo apt-get update and sudo apt-get upgrade and sudo apt-geet upgrade. 

Configuring the Raspberry Pi as a WiFi hotspot provides wireless connection to the Raspberry Pi without need to set up Ethernet connection. Configure your raspberry pi WiFi connection by running sudo raspi-config.
You will also need some java and mvn packages installed in your Raspberry pi. Here is a good link to follow for installing mvn https://xianic.net/2015/02/21/installing-maven-on-the-raspberry-pi/

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

1. sudo /bin/systemctl daemon-reload
2. sudo /bin/systemctl enable grafana-server
3. sudo /bin/systemctl start grafana-server
4. sudo /bin/systemctl status grafana-server

If everything has been properly set up, we can now browse over to raspberrypi.local:3000 and see web-ui of grafana. Default user and password is admin/admin. (I have changed password for my own use)

Grafana login
Setup the connection to InfluxDB with “set up datasource” option. Settings:

1. Name: Ruuvi
2. Type: InfluxDB 
3. URL: http://localhost:8086
4. Access: proxy
5. Auth: blank
6. Database: ruuvi
7. 
/////////////////////////////////////////////////
RuuviCollector
/////////////////////////////////////////////////
RuuviCollector is a Java program which listens to HCIDump and parses RuuviTag data. It also provides some analytics, such as dew point based on humidity and temperature. Follow the instructions on github repository to install the RuuviCollector. Ruuvitag-sensor python library has some additional instructions on setting up the permissions of Bluetooth adapter of Raspberry Pi.
https://github.com/Scrin/RuuviCollector.git
https://github.com/ttu/ruuvitag-sensor.git

In my case, these commands are required to download dependencies and setup permissions:

1. sudo apt install openjdk-11-jdk
2. udo apt install bluez bluez-hcidump
3. sudo setcap 'cap_net_raw,cap_net_admin+eip' `which hcitool`
4. sudo setcap 'cap_net_raw,cap_net_admin+eip' `which hcidump`
5. You may need to troubleshoot if there are more dependencies missing, but if everything is set up correctly go to RuuviCollector java program and change parameter position (in RuuviCollector/targets) to suit ruuvi tag mac addresses. In my case, I've uploaded the changes in this repo: ruuvi-collector.properties and ruuvi-names.properties
6. Execute by running: mvn clean package
7. Test the RuuviCollector by running: java -jar ruuvi-collector-0.2.jar 

//////////////////////////////////////////////
Template for dashboard
/////////////////////////////////////////////
Browse back to raspberrypi.local:3000, create your first dashboard and add a panel. 
Add the template in the repo grafanaTemplate.json for displaying the dashboard in raspberrypi.local:3000.

//////////////////////////////////////////////
Cronjob to run java application
/////////////////////////////////////////////
I've created a simple script so application can run continuously every 2hours as a cron job. See repo cronJobScript.sh
