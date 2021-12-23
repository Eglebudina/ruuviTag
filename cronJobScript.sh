#!/bin/bash
java -jar ~/RuuviCollector/target/ruuvi-collector-0.2.jar

# Cron job running every 2h (as java application for ruvvitags stops after 1h 55m)
# To create a cron job run crontab -e and update the file to the below command:
# 0 */2 * * * bash /home/pi/ruuviTag/cronJobScript.sh