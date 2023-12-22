#!/bin/sh

########## DEFINE FUNCTION ##########
COMMON_PRINT_TITLE() {                # COMMON PRINT TITLE
  echo "--------------------"
  echo "- $1 -"
  echo "--------------------"
}
PRINT_DATABASE_FILE_SYSTEM_INFO() {
  COMMON_PRINT_TITLE "PRINT_DATABASE_FILE_SYSTEM_INFO"
  printf "Mount   Total Used  Avail Use "
  echo "  "
  df -h | grep /data | awk '{print $6, '\t', '\t', '\t', '\t', $2, '\t', $3, '\t', '\t', $4, '\t', $5}'
  df -h | grep /archive | awk '{print $6, '\t', $2, '\t', '\t', $3, '\t', $4, '\t', '\t', $5}'
  df -h | grep /pg_xlog | awk '{print $6, '\t', $2, '\t', '\t', $3, '\t', $4, '\t', '\t', $5}'
}
PRINT_TEMP_INFO() {
  COMMON_PRINT_TITLE "PRINT_TEMP_INFO"
  echo "PRINT_TEMP_INFO"
}
PRINT_EVERY_SESSION_INFO() {
  COMMON_PRINT_TITLE "PRINT_EVERY_SESSION_INFO"
  echo "PRINT_EVERY_SESSION_INFO"
}
PRINT_ACTIVE_SESSION_INFO() {
  COMMON_PRINT_TITLE "PRINT_ACTIVE_SESSION_INFO"
  echo "PRINT_ACTIVE_SESSION_INFO"
}
########## /DEFINE FUNCTION ##########

########## CALL FUNCTION ##########
PRINT_DATABASE_FILE_SYSTEM_INFO
PRINT_TEMP_INFO
PRINT_EVERY_SESSION_INFO
PRINT_ACTIVE_SESSION_INFO
########## /CALL FUNCTION ##########