#!/bin/bash

echo "Hammering syslog until it dies..."

for i in {1..1000000}
do
	echo "Attempt $i"
	logger "Attempt $i"
done

