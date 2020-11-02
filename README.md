## Requirements
- protobuf
- LZMA
- 7z
- lz4
### Linux
```
apt install unace unrar zip unzip p7zip-full p7zip-rar sharutils rar uudeview mpack arj cabextract rename
apt install liblzma-dev python-pip brotli lz4
pip install backports.lzma protobuf pycrypto
```
### Mac
```
brew install protobuf liblzma-dev brotli lz4
pip install backports.lzma protobuf pycrypto
```
Also install [mono](https://www.mono-project.com/docs/getting-started/install/mac/)  

### Windows
Install cygwin, and select

```Latest python and pip packages, arj, brotli, cabextract, dos2unix, lz4, p7zip, renameutils, sharutils, unace, unzip and zip```

If you get syntax errors run dos2unix on extractor.sh

## How to use
### Download
```
git clone --recurse-submodules https://github.com/Treble-Experience/S_EXT-P-Merger.git
```

### Extract images from firmware URL
Example: Extracting images from LineageOS 18.0 zip:
```
cd S_EXT-P-Merger
wget https://android.googleapis.com/packages/ota-api/vsmart_jacaranda_jacarandaopen/12198da2140b32aa979058845de3c41f4be9e730.zip -o vos.zip
./merger.sh vos.zip
```
output will be on "S_EXT-P-Merger/system_new.img.zip"