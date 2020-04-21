#!/usr/bin/fish

if test (cat /etc/hostname) = "work"
   set -x OSE_USER jmars23
   set -x GIT_AUTHOR_NAME 'Joshua Marsh'
   set -x GIT_AUTHOR_EMAIL 'josh.marsh@optum.com'
   set -x GIT_COMMITTER_NAME 'Joshua Marsh'
   set -x GIT_COMMITTER_EMAIL 'josh.marsh@optum.com'
end
