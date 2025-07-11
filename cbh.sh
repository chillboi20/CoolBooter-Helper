#!/bin/bash

tmp=$(sed '1,11d; 13,14d' /System/Library/CoreServices/SystemVersion.plist)
sysver=$(echo "$tmp" | tr -d '</string> ')
start=1

readvalues () {
bsize=4096
hfextra=12800
extra=52428800
#echo $bsize

tmp1=$(echo -e "i\n1"  | gptfdisk /dev/rdisk0s1 2> /dev/null)
id1=$(echo $tmp1 | cut -d ' ' -f 43)
echo "$id1"

tmp2=$(echo -e "i\n2" | gptfdisk /dev/rdisk0s1 2> /dev/null)
id2=$(echo $tmp2 | cut -d ' ' -f 43)
echo "$id2"

tmp3=$(echo -e "i\n3"  | gptfdisk /dev/rdisk0s1 2> /dev/null)
id3=$(echo $tmp3 | cut -d ' ' -f 42,43 | tr -d 'GUID: First')
echo "$id3"

tmp4=$(echo -e "i\n4" | gptfdisk /dev/rdisk0s1 2> /dev/null)
id4=$(echo $tmp4 | cut -d ' ' -f 43)
echo "$id4"

mount_hfs /dev/disk0s1s2 /mnt
tused2=$(df -B1 /dev/disk0s1s2 | cut -d ' ' -f 3)
umount /mnt
#echo $tused2
used2=$(($tused2 / $bsize + $hfextra))
#echo $used2

mount_hfs /dev/disk0s1s1 /mnt
tused1=$(df -B1 /dev/disk0s1s1 | cut -d ' ' -f 3)
umount /mnt
#echo $tused1
used1=$(($tused1 / $bsize + $hfextra + 12800))
#echo $used1

tsize3=$(echo -e "i\n3" | gptfdisk /dev/rdisk0s1 2> /dev/null)
size3=$(echo $tsize3 | cut -d ' ' -f 57,58 | tr -d 'size: sectors')

tsize1=$(echo -e "i\n1" | gptfdisk /dev/rdisk0s1 2> /dev/null)
size1=$(echo $tsize1 | cut -d ' ' -f 58  )

tsize2=$(echo -e "i\n2" | gptfdisk /dev/rdisk0s1 2> /dev/null)
size2=$(echo $tsize2 | cut -d ' ' -f 58)

tsize4=$(echo -e "i\n4" | gptfdisk /dev/rdisk0s1 2> /dev/null)
size4=$(echo $tsize4 | cut -d ' ' -f 58)

#echo "$size1" > /ogsize.txt

totalsize=$(($size2 + $size4))
hftotalsize=$(($bsize * ($size2 + $size4)))
}

softpart () {
    echo -e "\np\ni\n2\ni\n3\ni\n4\nd\n2\nd\n3\nd\n4\nn\n2\n\n$(($used2 + $size1))\n\nn\n3\n\n$(($used2 + $size1 + $size3))\n\nn\n4\n\n\n\nc\n2\nData\nc\n3\nApple iBoot Update partition\nx\na\n2\n48\n49\n\nc\n2\n$id2\nc\n3\n$id3\nc\n4\n$id4\nm\np\ni\n2\ni\n3\ni\n4\nw\ny" | gptfdisk /dev/rdisk0s1
}
hardpart () {
echo -e "\np\ni\n1\ni\n2\ni\n3\ni\n4\nd\n1\nd\n2\nd\n3\nd\n4\nn\n1\n\n$used1\n\nn\n2\n\n$(($used2 + $used1))\n\nn\n3\n\n$(($used2 + $used1 + $size3))\n\nn\n4\n\n\n\nc\n1\nSystem\nc\n2\nData\nc\n3\nApple iBoot Update partition\nx\na\n2\n48\n49\n\nc\n1\n$id1\nc\n2\n$id2\nc\n3\n$id3\nc\n4\n$id4\nm\np\ni\n1\ni\n2\ni\n3\ni\n4\nw\ny" | gptfdisk /dev/rdisk0s1
}
syncparts () {
tsize4=$(echo -e "i\n4" | gptfdisk /dev/rdisk0s1 2> /dev/null)
size4=$(echo $tsize4 | cut -d ' ' -f 58)
newsize4=$(($size4 * $bsize))
tsize2=$(echo -e "i\n2" | gptfdisk /dev/rdisk0s1 2> /dev/null)
size2=$(echo $tsize2 | cut -d ' ' -f 58)
newsize2=$(($size2 * $bsize))
tsize1=$(echo -e "i\n1" | gptfdisk /dev/rdisk0s1 2> /dev/null)
size1=$(echo $tsize1 | cut -d ' ' -f 58)
newsize1=$(($size1 * $bsize))
}

while [ "$start" == 1 ]; do
        mount_hfs /dev/disk0s1s3 /mnt 2> /dev/null
        clear
        echo "CoolBooter Helper 1.0b1"
        echo "This is a beta release, so there might be bugs!"
        echo "NOTE: CoolBooter is incompatible with powdersn0w devices"
        if test -f "/mnt/applelogo"; then
            cbinstalled=1
            tmp2=$(sed '1,11d; 13,14d' /mnt/System/Library/CoreServices/SystemVersion.plist)
            cbver=$(echo "$tmp2" | tr -d '</string>')
            umount /dev/disk0s1s3
            echo "Currently on host OS"
            echo "CoolBooter partition found!"
            echo "System version: $sysver"
            echo "Paritioned version: $cbver"
            printf "Select option\n#1: Boot CoolBooter\n#2: Uninstall CoolBooter\n#3: Resize Partitions\n#4: Reboot\n#5: Exit\n"
        elif test -f "/applelogo"; then
            cbinstalled=2
            mount_hfs /dev/disk0s1s1 /mnt 2> /dev/null
            tmp2=$(sed '1,11d; 13,14d' /mnt/System/Library/CoreServices/SystemVersion.plist)
            cbver=$(echo "$tmp2" | tr -d '</string>')
            umount /dev/disk0s1s1
            echo "Currently on Coolbooter OS"
            echo "System version: $cbver"
            echo "Partitioned version: $sysver"
            printf "Select option\n#1: Resize partitions\n#2: Reboot\n#3: Exit\n"
        else
            cbinstalled=0
            echo "Currently on host OS"
            echo "CoolBooter partition not found!"
            printf "Select option\n#1: Install CoolBooter\n#2: Reboot\n#3: Exit\n"
        fi
    read select
    if [ "$cbinstalled" == 0 ]; then
        if [ "$select" == 1 ]; then
            select=0
            echo "Enter version (ex: 6.1.3)"
            read version
            echo "Enter Storage in GB (ex: 8)"
            read storage
            echo "Make sure to sure to set Auto-lock to \"Never\" in Settings > General > Auto-lock before continuing! (press Enter to continue)"
            read
            coolbootercli "$version" --datasize "$storage"GB --use-dpw
        elif [ "$select" == 2 ]; then
            reboot
        elif [ "$select" == 3 ]; then
            start=0
        fi
    fi
    if [ "$cbinstalled" == 1 ]; then
        while [ "$select" == 2 ]; do
            echo "Are you sure you want to uninstall the partition? All data will be lost! (y/n)"
            read select2
            if [ "$select2" == "n" ]; then
                select=0
            elif [ "$select2" == "y" ]; then
                coolbootercli -u
                select=0
            fi
        done
    fi
    if [ "$cbinstalled" == 1 ]; then
        while [ "$select" == 3 ]; do
#clear
            printf "Use this feature at your own risk! Please back up anything important before using this, as I (chillboi20) am not responsible for any data loss.\nTested devices: iPhone 5, iPad Mini 1st gen\nUntested devices: iPhone 4S, iPad 2, iPad 3rd gen, iPad 4th gen, iPod Touch 5th gen, iPhone 5C\nUnsupported devices: iPhone 3GS, iPhone 4, iPod Touch 3rd gen, iPod Touch 4th gen, iPad 1st gen\n"
            printf "#1: Resize CoolBooter Partition to maximum\n#2: Resize Coolbooter partition to custom amount\n#3: Debug scan\n#4: Exit\n"
            read select2 
            if [ "$select2" == "1" ]; then
                readvalues
                softpart
                syncparts
                echo $newsize2
                hfs_resize /private/var $newsize2
                mount_hfs /dev/disk0s1s4 /mnt
                hfs_resize /mnt $newsize4
                umount /mnt
                reboot
            elif [ "$select2" == "unfinished wip" ]; then
                readvalues
                hardpart
                syncparts
                hfs_resize / $newsize1
                echo $newsize2
                hfs_resize /private/var $newsize2
                mount_hfs /dev/disk0s1s4 /mnt
                hfs_resize /mnt $newsize4
                umount /mnt
                reboot
            elif [ "$select2" == "2" ]; then
                readvalues
                echo "Enter the desired amount in MB (ex: 8192 for 8GB)"
                read input
                hfused2=$(($input * 1024 * 1024))
                used2=$(($totalsize - $hfused2 / $bsize + $hfextra))
                softpart
                syncparts
                mount_hfs /dev/disk0s1s4 /mnt
                hfs_resize /mnt $newsize4
                umount /mnt
                echo $newsize2
                hfs_resize /private/var $newsize2
                reboot
            elif [ "$select2" == "4" ]; then
                select=0
            elif [ "$select2" == "3" ]; then
                readvalues
            fi
        done
    fi
    if [ "$cbinstalled" == 1 ]; then
        if [ "$select" == 1 ]; then
            echo "Contrary to what it will say, you do NOT have to lock your device. (press Enter to continue)"
            read
            coolbootercli -b
        elif [ "$select" == 5 ]; then
            start=0
        elif [ "$select" == 4 ]; then
            reboot
        fi
    fi
    if [ "$cbinstalled" == 2 ]; then
        if [ "$select" == 3 ] ; then
            start=0
        elif [ "$select" == 2 ]; then
            reboot
        fi
    fi
    if [ "$cbinstalled" == 2 ]; then
        while [ "$select" == 1 ]; do
#clear
            printf "Use this feature at your own risk! Please back up anything important before using this, as I (chillboi20) am not responsible for any data loss.\nTested devices: iPhone 5, iPad Mini 1st gen\nUntested devices: iPhone 4S, iPad 2, iPad 3rd gen, iPad 4th gen, iPod Touch 5th gen, iPhone 5C\nUnsupported devices: iPhone 3GS, iPhone 4, iPod Touch 3rd gen, iPod Touch 4th gen, iPad 1st gen\n"
            printf "#1: Resize CoolBooter partition to maximum\n#2: Resize Coolbooter partition to custom amount\n#3: Debug scan\n#4: Exit\n"
            read select2 
            if [ "$select2" == "1" ]; then
                readvalues
                mount_hfs /dev/disk0s1s2 /mnt
                hfs_resize /mnt $(($tused2 + $extra))
                echo "this is $(($tused2 + 10485760))"
                umount /mnt
                softpart
                syncparts
                echo $newsize4
                hfs_resize /private/var $newsize4
                reboot
            elif [ "$select2" == "unfinished wip" ]; then
                readvalues
                hardpart
                syncparts
                echo $newsize2
                hfs_resize /private/var $newsize2
                mount_hfs /dev/disk0s1s2 /mnt
                hfs_resize /mnt $newsize2
                umount /mnt
                mount_hfs /dev/disk0s1s1 /mnt
                hfs_resize /mnt $newsize1
                umount /mnt
                reboot
            elif [ "$select2" == "2" ]; then
                readvalues
                echo "Enter the desired amount in MB (ex: 8192 for 8GB)"
                read input
                hfused2=$(($input * 1024 * 1024))
                used2=$(($totalsize - $hfused2 / $bsize + $hfextra))
                softpart
                syncparts
                mount_hfs /dev/disk0s1s2 /mnt
                hfs_resize /mnt $newsize2
                umount /mnt
                echo $newsize4
                hfs_resize /private/var $newsize4
                reboot
            elif [ "$select2" == "4" ]; then
                select=0
            elif [ "$select2" == "3" ]; then
                readvalues
            fi
        done
    fi
done
