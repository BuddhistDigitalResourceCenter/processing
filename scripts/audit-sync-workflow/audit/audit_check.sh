#!/bin/sh

dateTimeStamp=`date +'%Y%m%d_%H%M%S'`
auditLog="/Volumes/staging/audit-and-sync/audit//logs/audit_log_${dateTimeStamp}.txt"
auditWorks="../works"

cd $auditWorks


echo "" | tee -a $auditLog
echo "*****************************************************************" | tee -a $auditLog
echo "* #1 - ARCHIVE/IMAGES FILE COUNT MATCH" | tee -a $auditLog
echo "*****************************************************************" | tee -a $auditLog

auditCheck1Failed=false

for w in `ls -d W*`; do
  cd $w/images

  for d in `ls`; do
    cd $d

    if [ -d "../../archive/$d" ]; then
      archive_num=`ls ../../archive/$d/*.* | wc -l`
      images_num=`ls *.* | wc -l`

      if [ $archive_num -ne $images_num ]; then
        auditCheck1Failed=true

        echo "" | tee -a $auditLog
        echo "------ DISCREPANCY FOUND ------" | tee -a $auditLog
        echo "- $d" | tee -a $auditLog
        echo "- a: $archive_num" | tee -a $auditLog
        echo "- i: $images_num" | tee -a $auditLog
        echo "-------------------------------" | tee -a $auditLog
      fi
    else
      auditCheck1Failed=true

      echo "" | tee -a $auditLog
      echo "------ DISCREPANCY FOUND ------" | tee -a $auditLog
      echo "- Cannot perform comparison." | tee -a $auditLog
      echo "- The folder $w/archive/$d does not exist." | tee -a $auditLog
      echo "-------------------------------" | tee -a $auditLog
    fi

    cd ..
  done

  cd ../..
done

echo "" | tee -a $auditLog

if $auditCheck1Failed; then
  echo "=== AUDIT CHECK #1 STATUS -- FAILED ===" | tee -a $auditLog
else
  echo "=== AUDIT CHECK #1 STATUS -- PASSED ===" | tee -a $auditLog
fi

echo "" | tee -a $auditLog

echo "" | tee -a $auditLog
echo "*****************************************************************" | tee -a $auditLog
echo "* #2 - CHECK FILENAME CORRECTNESS" | tee -a $auditLog
echo "*****************************************************************" | tee -a $auditLog
echo "" | tee -a $auditLog

echo "" | tee -a $auditLog
echo "***Clearing temp files...***" | tee -a $auditLog
echo "" | tee -a $auditLog

sh ../scripts/delete_temp_files.sh

auditCheck2Failed=false

for w in `ls -d W*`; do
  cd $w

  if [ -d "images" ]; then
    cd images
    for i in `ls`; do
      cd $i
      imgGrp=`echo $i | cut -d'-' -f2`

      if [[ -n $(find . ! -name "$imgGrp*" -type f) ]]; then
        auditCheck2Failed=true

        echo ""
        echo "------ DISCREPANCY FOUND ------" | tee -a $auditLog
        echo "-" | tee -a $auditLog
        echo "- INCORRECT FILENAMES FOUND" | tee -a $auditLog
        echo "-" | tee -a $auditLog
        echo "- $w-$imgGrp:" | tee -a $auditLog

        for f in `find . ! -name "$imgGrp*" -type f`; do
          echo "- $f" | tee -a $auditLog
        done
        echo "-" | tee -a $auditLog
        echo "-------------------------------" | tee -a $auditLog

      fi

      cd ..
    done
    cd ..
  fi
  cd ..
done

echo "" | tee -a $auditLog

if $auditCheck2Failed; then
  echo "=== AUDIT CHECK #2 STATUS -- FAILED ===" | tee -a $auditLog
else
  echo "=== AUDIT CHECK #2 STATUS -- PASSED ===" | tee -a $auditLog
fi

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
echo "* #3 - CHECK FOR FILES > 400K in IMAGES FOLDER" | tee -a $auditLog
echo "*****************************************************************" | tee -a $auditLog
echo "" | tee -a $auditLog

auditCheck3Failed=false

for w in `ls -d W*`; do

  if [[ -n $(find $w/images -size +400k -type f) ]]; then
    auditCheck3Failed=true

    echo ""
    echo "------ DISCREPANCY FOUND ------" | tee -a $auditLog
    echo "-" | tee -a $auditLog
    echo "- IMAGES LARGER THAN 400KB FOUND" | tee -a $auditLog
    echo "- $w/images:" | tee -a $auditLog
    echo "-" | tee -a $auditLog
       
    for f in `find $w/images -size +400k -type f`; do
      echo "- $f" | tee -a $auditLog
    done

    echo "-" | tee -a $auditLog
    echo "-------------------------------" | tee -a $auditLog
  fi

done

if $auditCheck3Failed; then
  echo "" | tee -a $auditLog
  echo "TOTAL IMAGES > 400KB:" | tee -a $auditLog
  for w in `ls -d W*`; do find $w/images -size +400k; done | wc -l

  echo "" | tee -a $auditLog
  echo "=== AUDIT CHECK #3 STATUS -- FAILED ===" | tee -a $auditLog
  echo "" | tee -a $auditLog
else
  echo "=== AUDIT CHECK #3 STATUS -- PASSED ===" | tee -a $auditLog
  echo "" | tee -a $auditLog
fi
