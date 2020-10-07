#!/bin/bash

firewall-cmd --remove-port=7777/tcp --permanent
firewall-cmd --reload