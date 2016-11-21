#!/bin/bash

NAME=test
ID=`nova show test | grep "| id" | awk '{print $4}'`

function log() {
    date=`date +"%d-%m-%Y %T"`
    echo "*** $date | $1"
}

i=0
while true; do
    i=$((i+1))
    log "Guest migration: $i"
    sleep 1

    nova migrate $ID
    if [ $? -ne 0 ]; then
        log "Migration failed, exit"
        exit
    fi
    sleep 1

    while true; do
        sleep 2
        STATUS=`nova show test | grep "| status" | awk '{print $4}'`
        case "$STATUS" in
            VERIFY_RESIZE)
                break
                ;;
            ERROR)
                log "Instance in error, exit"
                exit
                ;;
            *)
                ;;
        esac
    done

    nova resize-confirm $ID
    if [ $? -ne 0 ]; then
        log "Confirm resize failed, exit"
        exit
    fi
    sleep 1

    while true; do
        sleep 2
        STATUS=`nova show test | grep "| status" | awk '{print $4}'`
        case "$STATUS" in
            ACTIVE)
                break
                ;;
            ERROR)
                log "Instance in error, exit"
                exit
                ;;
            *)
                ;;
        esac
    done
done
