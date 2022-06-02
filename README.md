# Debian Offline Autoinstall Generator

### Features
* Add preseed file.
* Add custom files to home.
* Add extra packages.

### Requirements
Tested on a host running Debian 11.3.0.
- Utilities required:
    - ```xorriso```
    - ```sed```
    - ```rsync```
    - ```apt-move```

### Example
```
[2022-06-02 11:54:13] 👶 Starting up...
[2022-06-02 11:54:13] 📁 Created temporary working directory /tmp/tmp.9SQadMcp9E
[2022-06-02 11:54:13] 🔎 Checking for required utilities...
[2022-06-02 11:54:13] 🔧 Extracting ISO image...
[2022-06-02 11:54:14] 👍 Extracted to /tmp/tmp.9SQadMcp9E
[2022-06-02 11:54:14] 🧩 Adding custom file...
[2022-06-02 11:54:14] 👍 Added custom file...
[2022-06-02 11:54:14] 🧩 Merging extra package files into package pool...
[2022-06-02 11:54:15] 👍 Merged extra package files into package pool.
[2022-06-02 11:54:15] 🧩 Updating Packages and Release files...
[2022-06-02 11:54:17] 👍 Updated Packages and Release files.
[2022-06-02 11:54:17] 🧩 Adding preseed file...
[2022-06-02 11:54:20] 👍 Added preseed file.
[2022-06-02 11:54:20] 👷 Updating md5sum with hashes of modified files...
[2022-06-02 11:54:21] 👍 Updated hashes.
[2022-06-02 11:54:21] 📦 Repackaging extracted files into an ISO image...
[2022-06-02 11:54:24] 👍 Repackaged into ./iso_destination/debian-11.3.0-amd64-offline-preseeded.iso
[2022-06-02 11:54:24] ✅ Completed.
[2022-06-02 11:54:24] 🚽 Deleted temporary working directory /tmp/tmp.9SQadMcp9E
```
### Thanks
Some script snippets are from [this](https://github.com/covertsh/ubuntu-autoinstall-generator).

### License
MIT license.