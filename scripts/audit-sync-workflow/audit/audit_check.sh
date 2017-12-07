#!/bin/sh

dateTimeStamp=`date +'%Y%m%d_%H%M%S'`
auditLog="/Volumes/staging/audit/logs/audit_log_${dateTimeStamp}.txt"

echo "" | tee -a $auditLog
echo "*****************************************************************" | tee -a $auditLog
echo "* #1 - ARCHIVE/IMAGES FILE COUNT MATCH" | tee -a $auditLog
echo "*****************************************************************" | tee -a $auditLog

auditCheck1Failed=false

cd ../works

for w in `ls -d W*`; do
  cd $w/images

  for d in `ls`; do
    cd $d

    archive_num=`ls ../../archive/$d/*.* | wc -l`
    images_num=`ls *.* | wc -l`

    if [ $archive_num -ne $images_num ]; then
      auditCheck1Failed=true

      echo "-- DISCREPANCY FOUND --" | tee -a $auditLog
      echo "$d" | tee -a $auditLog
      echo "a: $archive_num" | tee -a $auditLog
      echo "i: $images_num" | tee -a $auditLog
    fi

    cd ..
  done

  cd ../..
done

echo "" | tee -a $auditLog

if $auditCheck1Failed; then
  echo "AUDIT CHECK #1 STATUS -- FAILED" | tee -a $auditLog
else
  echo "AUDIT CHECK #1 STATUS -- PASSED" | tee -a $auditLog
fi

echo "" | tee -a $auditLog

echo "" | tee -a $auditLog
echo "*****************************************************************" | tee -a $auditLog
echo "* #2 - CHECK FILENAME CORRECTNESS" | tee -a $auditLog
echo "*****************************************************************" | tee -a $auditLog
echo "" | tee -a $auditLog

auditCheck2Failed=false

for w in `ls -d W*`; do
  cd $w

  if [ -d "images" ]; then
    cd images
    for i in `ls`; do
      cd $i
      imgGrp=`echo $i | cut -d'-' -f2`
      echo "$w:" | tee -a $auditLog
      for f in `find . ! -name "$imgGrp*"`; do
        echo $f | tee -a $auditLog
      done
      cd ..
    done
    cd ..
  fi
  cd ..
done


#echo "" | tee -a $auditLog
#echo "*****************************************************************" | tee -a $auditLog
#echo "* #3 - CHECK FOR UNCOMPRESSED TIFS IN ARCHIVE FOLDER" | tee -a $auditLog
#echo "*****************************************************************" | tee -a $auditLog
#secho "" | tee -a $auditLog

#for w in `ls -d W*`; do
#    for f in `find $w -name "*.tif"`; do
#
#    if ! [[ $f =~ "0001.tif" ]]; then
#      if ! [[ $f =~ "0002.tif" ]]; then
#
#        file_type=`identify -quiet $f | cut -d" " -f2`
#
#        if [ "$file_type" = "TIFF" ]; then
#
#          compression_type=`identify -verbose -quiet $f | grep Compression | cut -d" " -f4`
#          if [ "$compression_type" = "None" ]; then
#            echo "***UNCOMPRESSED TIF FOUND: $f***"
#          fi
#        fi
#      fi 
#    fi
#
#    done
#done

echo "" | tee -a $auditLog
echo "*****************************************************************" | tee -a $auditLog
echo "* #4 - CHECK FOR FILES > 400K in IMAGES FOLDER" | tee -a $auditLog
echo "*****************************************************************" | tee -a $auditLog
echo "" | tee -a $auditLog

for w in `ls -d W*`; do
  find $w/images -size +400k | tee -a $auditLog
done
