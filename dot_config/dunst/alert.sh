#!/bin/sh

URGENCY=$5

if [ "$URGENCY" == "LOW" ]; then
    exit 0  # Do nothing and exit for the 'massage-kg' rule
fi


if [ "$DND" == "1" ]; then
    exit 0  # Do nothing and exit for the 'massage-kg' rule
fi


paplay ~/.config/dunst/sound.wav
