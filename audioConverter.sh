#!/bin/bash


# Converts the audio files from the SmartHUB into wav files so they can be played back

SAMPLERATE=16000
ENCODING="signed"
BITRATE=16
CHANNELS=1

echo "Files to be converted..."
ls *.pcm

cp GSMLineIn.pcm GSMLineIn.raw
cp GSMLineOut.pcm GSMLineOut.raw
cp GSMMICIn.pcm GSMMICIn.raw
cp GSMSpeakerOut.pcm GSMSpeakerOut.raw

SOXCOMMAND="sox -r $SAMPLERATE -e $ENCODING -b $BITRATE -c $CHANNELS "

$SOXCOMMAND GSMLineIn.raw GSMLineIn.wav
$SOXCOMMAND GSMLineOut.raw GSMLineOut.wav
$SOXCOMMAND GSMMICIn.raw GSMMICIn.wav
$SOXCOMMAND GSMSpeakerOut.raw GSMSpeakerOut.wav

