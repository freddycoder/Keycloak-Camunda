#!/bin/bash
set -e
CMD="/camunda/internal/run.sh"
exec ${CMD} start $ADDITIONAL_CMD_LINE_ARGS