#!/bin/sh
for dir in `find ../RHO_ERP_WEB/ -type d -name "app"`
do
  for file in `find $dir -name "*.js"`
  do
  echo "Compressing $file …"
  java -jar yuicompressor-2.4.8.jar --type js -o $file $file
  done
done

for dir in `find ../RHO_ERP_WEB/ -type d -name "cmn_scrpts"`
do
  for file in `find $dir -name "*_scripts.js"`
  do
  echo "Compressing $file …"
  java -jar yuicompressor-2.4.8.jar --type js -o $file $file
  done

  for file in `find $dir -maxdepth 1 -name "*.css"`
  do
  echo "Compressing $file …"
  java -jar yuicompressor-2.4.8.jar --type css -o $file $file
  done
done

for dir in `find ../RHO_ERP_WEB/ -type d -name "js_self"`
do
  for file in `find $dir -name "*.js"`
  do
  echo "Compressing $file …"
  java -jar yuicompressor-2.4.8.jar --type js -o $file $file
  done

  for file in `find $dir -maxdepth 1 -name "*.css"`
  do
  echo "Compressing $file …"
  java -jar yuicompressor-2.4.8.jar --type css -o $file $file
  done
done

for file in `find ../../db -name "superAdminConfigFile.rhocnfg"`
do
echo "Updating jsCssFileVrsn to $(date +%Y%m%d)_$(date +%H%M%S) in $file …"
sed -i -E "s/,\"jsCssFileVrsn\":\"[^\"]*\",/,\"jsCssFileVrsn\":\"$(date +%Y%m%d)_$(date +%H%M%S)\",/1" $file
#sed -i -E "s/,\"jsCssFileVrsn\":\"[^\"]*\",/,\"jsCssFileVrsn\":\"$(date +%Y%m%d)_$(date +%H%M%S)\",/g" $file
done
