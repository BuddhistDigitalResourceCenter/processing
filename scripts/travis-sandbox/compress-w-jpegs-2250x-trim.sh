#!/bin/sh

srcDir=$1
workDirs=($@)

fullPixelWidth=225000
reducedWidth=225000

if [ -d $srcDir ]; then
  pushd $srcDir > /dev/null
else
  echo "ERROR: $srcDir is not a valid path"
  exit 1
fi

if [ ${#workDirs[@]} -lt 2 ]; then
  echo "ERROR: No directories to work on"
  exit 1
else 
  workDirs=("${workDirs[@]:1:${#workDirs[@]}-1}")
fi

for d in "${workDirs[@]}"; do
#  if [[ -n $(find $d -name "*.jpg" -size +300k) ]]; then
    echo "Compressing images in $d"
    mkdir -p $d/converted
    for f in `find $d -name "*.jpg"`; do
      imgWidth=`identify -format "%w" $f`
      resizeRatio=$(bc <<< "($fullPixelWidth/$imgWidth)")

      if [ $resizeRatio -lt 100 ]; then
        mogrify -fuzz 30% -trim -resize 2250x -quality 65 -path $d/converted $f
      fi
    done
#  else
#    echo "Skipping images in $d.  Images already compressed."
#  fi
done

popd > /dev/null  