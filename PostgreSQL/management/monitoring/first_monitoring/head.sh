#!/bin/sh

########## DEFINE FUNCTION ##########
COMMON_PRINT_TITLE() {                # COMMON PRINT TITLE
  echo "--------------------"
  echo "- $$1 -"
  echo "--------------------"
}
PRINT_DATABASE_FILE_SYSTEM_INFO() {}  # just linux commands
PRINT_TEMP_INFO() {}                  # psql query 1
PRINT_EVERY_SESSION_INFO() {}         # psql query 2
PRINT_ACTIVE_SESSION_INFO() {}        # psql query 3
########## /DEFINE FUNCTION ##########

########## CALL FUNCTION ##########
PRINT_DATABASE_FILE_SYSTEM_INFO
PRINT_TEMP_INFO
PRINT_EVERY_SESSION_INFO
PRINT_ACTIVE_SESSION_INFO
########## /CALL FUNCTION ##########