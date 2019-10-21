#!/bin/sh
cron start && tail -f /var/log/cron.log
