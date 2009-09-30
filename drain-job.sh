#!/bin/bash
# drain-job.sh job_dir xfer_job_dir thumper
#
# run draintasker processes on a crawl job in single mode.
# the idea here is to keep a crawl draining while not spending
# too much time on any one process. if there is a  backlog of
# prerequisites, then each task can be run in a separate 
# process in non-single mode to catch up.
#
#  pack-warcs.sh
#  make-manifests.sh
#  launch-transfers.sh
#  verify-transfers.sh
#  delete-warcs.sh
#
# siznax 2009

usage="$0 job_dir xfer_job_dir thumper"

if [ -n "$3" ]
then

  job_dir=$1
  xfer_job_dir=$2
  thumper=$3

  echo $0 `date`

  if [ -e $job_dir ] 
  then

    # check for xfer_job_dir
    if [ ! -e $xfer_job_dir ]
    then 
      echo "ERROR: xfer_job_dir not found: $xfer_job_dir" 
    fi

    # pack a single series
    ./pack-warcs.sh $job_dir $xfer_job_dir 10 1 single
    if [ $? != 0 ]
    then
      echo "ERROR packing warcs: $?"
      exit 1
    fi

    # make a single manifest
    ./make-manifests.sh $xfer_job_dir single
    if [ $? != 0 ]
    then
      echo "ERROR making manifests: $?"
      exit 1
    fi

    # launch a single task
    ./launch-transfers.sh $xfer_job_dir $thumper 1 single
    if [ $? != 0 ]
    then
      echo "ERROR launching transfers: $?"
      exit 1
    fi

    # verify a single transfer (BY SIZE - see verify-transfers.sh)
    ./verify-transfers.sh $xfer_job_dir size single
    if [ $? != 0 ]
    then
      echo "ERROR verifying transfers: $?"
      exit 1
    fi

    # delete verified warcs
    ./delete-verified-warcs.sh $xfer_job_dir 1
    if [ $? != 0 ]
    then
      echo "ERROR deleting warcs: $?"
      exit 1
    fi

  else
    echo "ERROR: job_dir not found: $job_dir"
    exit 1
  fi
else
  echo $usage
  exit 1
fi
echo $0 "Done." `date`
