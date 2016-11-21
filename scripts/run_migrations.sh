#!/bin/bash

GUESTS=( test-0 test-1 test-2 test-3 )

function log() {
    date=`date +"%d-%m-%Y %T"`
    echo "*** $date | $1"
}

function id() {
    ID=`nova show $1 | grep "| id" | awk '{print $4}'`
    echo $ID
}

i=0
while true; do
    i=$((i+1))

    log "Guests migration loop: $i"

    for GUEST in "${GUESTS[@]}"; do
        ID=$(id $GUEST)
        log "Migrating $GUEST"
        nova migrate $ID
        if [ $? -ne 0 ]; then
            log "Migration failed, exit"
            exit
        fi
    done

    for GUEST in "${GUESTS[@]}"; do
        ID=$(id $GUEST)
        while true; do
            sleep 1
            STATUS=`nova show $ID | grep "| status" | awk '{print $4}'`
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

        log "Confirm migration $GUEST"
        nova resize-confirm $ID
        if [ $? -ne 0 ]; then
            log "Confirm resize failed, exit"
            exit
        fi

        while true; do
            sleep 1
            STATUS=`nova show $ID | grep "| status" | awk '{print $4}'`
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
done
