# LGTV

## Installation
cd /root
git clone git@github.com:muichunlim/LGTV.git

## crontab
bash 
```
0 0 1 * * /root/LGTV/reset_devmode.sh >> /root/reset_devmode.log 2>&1
```
