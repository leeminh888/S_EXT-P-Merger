#!/bin/bash

# Merge S-P by YukoSky @ Treble-Experience
# License: GPL3

echo "#############################"
echo "#                           #"
echo "# S_EXT-P Merger by YukoSky #"
echo "#                           #"
echo "#############################"
echo ""

### Initial vars
LOCALDIR=`cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd`
FE="$LOCALDIR/tools/firmware_extractor"

## Mount Point vars for system_new
SYSTEM_NEW="$LOCALDIR/system_new"
SYSTEM_NEW_IMAGE="$LOCALDIR/system_new.img"

## Mount Point vars for system
SYSTEM="$LOCALDIR/system"
SYSTEM_IMAGE="$LOCALDIR/system.img"

## Mount Point vars for product
PRODUCT="$LOCALDIR/product"
PRODUCT_IMAGE="$LOCALDIR/product.img"

## Mount Point vars for opproduct
OPPRODUCT="$LOCALDIR/opproduct"
OPPRODUCT_IMAGE="$LOCALDIR/opproduct.img"

## Mount Point vars for system_ext
SYSTEM_EXT="$LOCALDIR/system_ext"
SYSTEM_EXT_IMAGE="$LOCALDIR/system_ext.img"

usage() {
    echo "Usage: $0 <Path to firmware>"
    echo -e "\tPath to firmware: the zip!"
}

if [ ! -f "$FE/extractor.sh" ]; then
   echo "-> Firmware Extractor isn't cloned or don't exists! Exit 1."
   exit 1
else
   if [ "$1" == "" ]; then
      echo "-> Enter all needed parameters."
      usage
      exit 1
   fi
   echo "-> Starting the process..."
   cd $FE; chmod +x -R *
   bash $FE/extractor.sh "$1" "$LOCALDIR"
fi

# system_new.img
echo "-> Check mount/etc for system_new.img"
if [ -f "$SYSTEM_NEW_IMAGE" ]; then
   # Check for AB/Aonly in system_new
   if [ -d "$SYSTEM_NEW" ]; then
      if [ -d "$SYSTEM_NEW/dev/" ]; then
         echo " - SAR Mount detected in system_new, force umount!"
         sudo "$SYSTEM_NEW/"
      else
         if [ -d "$SYSTEM_NEW/etc/" ]; then
            echo " - Aonly Mount detected in system_new, force umount!"
            sudo "$SYSTEM_NEW/"
         fi
      fi
   fi
   echo " - Delete: system_new and mount point"
   sudo rm -rf $SYSTEM_NEW_IMAGE $SYSTEM_NEW/
   sudo dd if=/dev/zero of=$SYSTEM_NEW_IMAGE bs=4k count=2048576 > /dev/null 2>&1
   sudo tune2fs -c0 -i0 $SYSTEM_NEW_IMAGE > /dev/null 2>&1
   sudo mkfs.ext4 $SYSTEM_NEW_IMAGE > /dev/null 2>&1
   if [ ! -f "$SYSTEM_NEW_IMAGE" ]; then
      echo " - system_new don't exists, exit 1."
      exit 1
   fi
else
   echo " - system_new.img don't exists, create one..."
    sudo rm -rf $SYSTEM_NEW_IMAGE $SYSTEM_NEW/
   sudo dd if=/dev/zero of=$SYSTEM_NEW_IMAGE bs=4k count=2048576 > /dev/null 2>&1
   sudo tune2fs -c0 -i0 $SYSTEM_NEW_IMAGE > /dev/null 2>&1
   sudo mkfs.ext4 $SYSTEM_NEW_IMAGE > /dev/null 2>&1
   if [ ! -f "$SYSTEM_NEW_IMAGE" ]; then
      echo " - system_new don't exists, exit 1."
      exit 1
   fi
   echo " - Done: system_new"
fi

# system.img
echo "-> Check mount/etc for system.img"
if [ -f "$SYSTEM_IMAGE" ]; then
   # Check for AB/Aonly in system
   if [ -d "$SYSTEM" ]; then
      if [ -d "$SYSTEM/dev/" ]; then
         echo " - SAR Mount detected in system, force umount!"
         sudo umount "$SYSTEM/"
      else
         if [ -d "$SYSTEM/etc/" ]; then
            echo " - Aonly Mount detected in system, force umount!"
            sudo umount "$SYSTEM/"
         fi
      fi
   fi
   echo " - Done: system"
else
   echo " - system don't exists, exit 1."
   exit 1
fi

# product.img
echo "-> Check mount/etc for product.img"
if [ -f "$PRODUCT_IMAGE" ]; then
   # Check if product is mounted
   if [ -d "$PRODUCT" ]; then
      if [ -d "$PRODUCT/etc/" ]; then
         echo " - Mount detected in product, force umount!"
         sudo umount "$PRODUCT/"
      fi
   fi
   echo " - Done: product"
else
   echo " - product don't exists, exit 1."
   exit 1
fi

# opproduct.img
echo "-> Check mount/etc for opproduct.img"
if [ -f "$OPPRODUCT_IMAGE" ]; then
   echo " - opproduct detected!"
   # Check if product is mounted
   if [ -d "$OPPRODUCT" ]; then
      if [ -d "$OPPRODUCT/etc/" ]; then
         echo " - Mount detected in opproduct, force umount!"
         sudo umount "$OPPRODUCT/"
      fi
   fi
   echo " - Done: opproduct"
else
   echo " - opproduct don't exists, be careful!"
fi

# product.img
echo "-> Check mount/etc for system_ext.img"
if [ -f "$SYSTEM_EXT_IMAGE" ]; then
   # Check if product is mounted
   if [ -d "$SYSTEM_EXT" ]; then
      if [ -d "$SYSTEM_EXT/etc/" ]; then
         echo " - Mount detected in system_ext, force umount!"
         sudo umount "$SYSTEM_EXT/"
      fi
   fi
   echo " - Done: system_ext"
else
   echo " - system_ext don't exists, be careful!"
fi

echo "-> Starting process!"
echo " - Mount system"
if [ ! -d "$SYSTEM/" ]; then
   mkdir $SYSTEM
fi
sudo mount -o ro $SYSTEM_IMAGE $SYSTEM/

echo " - Mount system_new"
if [ ! -d "$SYSTEM_NEW/" ]; then
   mkdir $SYSTEM_NEW
fi
sudo mount -o loop $SYSTEM_NEW_IMAGE $SYSTEM_NEW/

echo " - Mount product"
if [ ! -d "$PRODUCT/" ]; then
   mkdir $PRODUCT
fi
sudo mount -o ro $PRODUCT_IMAGE $PRODUCT/

if [ -f "$OPPRODUCT_IMAGE" ]; then
   echo " - Mount product"
   if [ ! -d "$OPPRODUCT/" ]; then
      mkdir $OPPRODUCT
   fi
   sudo mount -o ro $OPPRODUCT_IMAGE $OPPRODUCT/
fi

if [ -f "$SYSTEM_EXT_IMAGE" ]; then
   echo " - Mount system_ext"
   if [ ! -d "$SYSTEM_EXT/" ]; then
      mkdir $SYSTEM_EXT
   fi
sudo mount -o ro $SYSTEM_EXT_IMAGE $SYSTEM_EXT/
fi

echo "-> Copy system files to system_new"
cp -v -r -p $SYSTEM/* $SYSTEM_NEW/ > /dev/null 2>&1 && sync
echo " - Umount system"
umount $SYSTEM/

echo "-> Copy product files to system_new"
if [ -d "$SYSTEM_NEW/dev/" ]; then
   echo " - Using SAR method"
   cd $LOCALDIR/system_new/
   rm -rf product; cd system; rm -rf product
   mkdir -p product/
   cp -v -r -p $PRODUCT/* product/ > /dev/null 2>&1
   cd ../
   echo " - Fix symlink in product"
   ln -s /system/product/ product
   sync
   echo " - Fixed"
else
   if [ ! -f "$SYSTEM_NEW/build.prop" ]; then
      echo " - Are you sure this is a Android image?"
      exit 1
   fi
   cd $SYSTEM_NEW
   rm -rf product
   mkdir product && cd ../
   cp -v -r -p $PRODUCT/* $SYSTEM_NEW/product/ > /dev/null 2>&1 && sync
   cd $LOCALDIR
fi
cd $LOCALDIR

echo " - Umount product"
sudo umount $PRODUCT/

if [ -f "$OPPRODUCT_IMAGE" ]; then
echo "-> Copy opproduct files to system_new"
   if [ -d "$SYSTEM_NEW/dev/" ]; then
      echo " - Using SAR method"
      cd $LOCALDIR/system_new/
      rm -rf oneplus; cd system; rm -rf oneplus
      mkdir -p oneplus/
      cp -v -r -p $OPPRODUCT/* oneplus/ > /dev/null 2>&1
      cd ../
      echo " - Fix symlink in opproduct"
      ln -s /system/oneplus/ oneplus
      sync
      echo " - Fixed"
else
   if [ ! -f "$SYSTEM_NEW/build.prop" ]; then
      echo " - Are you sure this is a Android image?"
      exit 1
   fi
   cd $SYSTEM_NEW
   rm -rf oneplus
   mkdir oneplus && cd ../
   cp -v -r -p $OPPRODUCT/* $SYSTEM_NEW/oneplus/ > /dev/null 2>&1 && sync
   cd $LOCALDIR
   fi
fi
cd $LOCALDIR

if [ -f "$OPPRODUCT_IMAGE" ]; then
   echo " - Umount opproduct"
   sudo umount $OPPRODUCT/
fi

if [ -f "$SYSTEM_EXT_IMAGE" ]; then
echo "-> Copy system_ext files to system_new"
   if [ -d "$SYSTEM_NEW/dev/" ]; then
      echo " - Using SAR method"
      cd $LOCALDIR/system_new/
      rm -rf system_ext; cd system; rm -rf system_ext
      mkdir -p system_ext/
      cp -v -r -p $SYSTEM_EXT/* system_ext/ > /dev/null 2>&1
      cd ../
      echo " - Fix symlink in system_ext"
      ln -s /system/system_ext/ system_ext
      sync
      echo " - Fixed"
else
   if [ ! -f "$SYSTEM_NEW/build.prop" ]; then
      echo " - Are you sure this is a Android image?"
      exit 1
   fi
   cd $SYSTEM_NEW
   rm -rf system_ext
   mkdir system_ext && cd ../
   cp -v -r -p $SYSTEM_EXT/* $SYSTEM_NEW/system_ext/ > /dev/null 2>&1 && sync
   cd $LOCALDIR
   fi
fi
cd $LOCALDIR

if [ -f "$SYSTEM_EXT_IMAGE" ]; then
   echo " - Umount system_ext"
   sudo umount $SYSTEM_EXT/
fi

echo " - Umount system_new"
sudo umount $SYSTEM_NEW/

echo "-> Remove tmp folders and files"
sudo rm -rf $SYSTEM $SYSTEM_NEW $PRODUCT $SYSTEM_IMAGE $PRODUCT_IMAGE $SYSTEM_EXT $SYSTEM_EXT_IMAGE $OPPRODUCT $OPPRODUCT_IMAGE

echo " - Zip system_new.img"
zip system.img.zip system_new.img

sudo rm -rf *.img

echo "-> Done, just run with !jurl2gsi/url2GSI.sh."