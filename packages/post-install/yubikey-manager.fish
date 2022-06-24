#!/usr/bin/fish

add_service pcscd
gpg --recv 0x81252059f305fc3ef91812c8f8adb576bb5af985 # Get our key