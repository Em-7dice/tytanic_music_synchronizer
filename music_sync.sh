#!/bin/bash

#
# Tytanic Music Syncronizer
#
#	syncs target .flac library to target .mp3 library
#
# To use: Run with 2 arguments:
#	-the path to a music library containing .flac files
#	-the path to a folder where you want a copy of the library, but with .mp3 files instead.
#
# The .flac files can be within subfolders, and it will recreate the folder structure in
# the target directory.
#
# Dependancies
#	ffmpeg. That's it really.
#

echo "Syncing Music..."

IFS=$'\n'

#	get either a list of directories or files recursively within a given directory.
#	get_list [target_dir] [file_ext]
#	if given only the target dir, it will search for directories.
get_list(){
	cd $1

	if [ -n "$2" ]; then			# if 2nd argument exists,
		list=$(find . -type f)		# find files, search for extension, and...
		list=$(echo "$list" | grep $2 | sed '/m3u/d')	# remove m3u playlists
	else
		list=$(find . -type d)		# otherwise, just list the directories
	fi

#		build the output as one multiline string
	output=''
	for address in $(echo "$list")
	do
		name=$(echo "$address" | cut -c 2-) # this cuts off the "." at the start
		output+=".${name%.*}"			# we put it back here, otherwise the "%.*"
		output+=$'\n'					# will remove all the chars in dir names
	done
	echo "$output"
}


#	List what files and directories we need for the sync
#	we hard-coded ffmpeg not to overwrite files, so checking if a file/dir
#		exists isn't necessary. Maybe for the rust port :P
input_files=$(get_list $1 flac)
#output_files=$(get_list $2 mp3)

input_dirs=$(get_list $1)
#output_dirs=$(get_list $2)

#	Creating the folder structure in the target directory
echo "Creating Directories"
for dir in $input_dirs
do
	echo "Creating $2$dir"
	mkdir -p "$2$dir"
done

#	Converting the files! ffmpeg is set to only output for errors, and not to overwrite any files.
echo "Converting/Transferring Files"
for file in $input_files
do
	echo "Converting $1$file.flac to $2$file.mp3"
	ffmpeg -hide_banner -loglevel error -n -i "$1$file.flac" "$2$file.mp3"
done

echo "Finished Syncing!"
exit 0
