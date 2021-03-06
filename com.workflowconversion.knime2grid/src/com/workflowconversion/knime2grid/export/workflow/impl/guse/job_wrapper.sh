#!/usr/bin/env bash
# THIS FILE WAS AUTOMATICALLY GENERATED BY THE KNIME2Grid KNIME EXTENSION

# contains names of input ports that take filelists, separated by whitespace
INPUT_PORTS_WITH_FILELIST="@@INPUT_PORTS_WITH_FILELIST@@"

# we cannot assume that the contents of the archive contain the input files named exactly as expected
# this section relates input port names to a (base) filename to use to change the names of the extracted files, e.g.,
#   KNIME2GRID_VAR_N="bar"
# signifies that the the contents of the N-th input will be extracted and renamed to 0_bar, 1_bar, ...
##### start filename translation variables 
@@INPUT_FILENAME_TRANSLATION@@
##### end

# contains names of output ports that generate filelists, separated by whitespace
OUTPUT_PORTS_WITH_FILELIST="@@OUTPUT_PORTS_WITH_FILELIST@@"
EXECUTABLE="@@EXECUTABLE@@"
COMMAND_LINE_PARAMETERS="@@COMMAND_LINE_PARAMETERS@@"

# KNIME 3.6 seems to have a race condition, sometimes KNIME reports that the node "Table Reader" is not available, but it is...
# This is probably not best practice, not regular practice, hell, this should not be practice, but basically what we do here
# is to wait for ALL outputs...
# Major Hackett made me do it, I am sorry. The chain of command is sacred.
MAJOR_HACKETT="@@MAJOR_HACKETT@@"
# Hackett out!

ARCHIVE_INDEX=0
if [ -n "$INPUT_PORTS_WITH_FILELIST" ]; then
	for input_port in ${INPUT_PORTS_WITH_FILELIST}; do
		echo "expanding ${input_port}"
		# extract files individually and rename them
		FILE_INDEX=0
		BASENAME_VARIABLE_NAME="KNIME2GRID_VAR_${FILE_INDEX}"
		for input_file in `tar tfz ${input_port}`; do
			# use basename and index to rename the file as its written to stdout
			tar xOfz ${input_port} ${input_file} > ${FILE_INDEX}_${!BASENAME_VARIABLE_NAME}
			FILE_INDEX=$(expr ${FILE_INDEX} + 1)
		done
		ARCHIVE_INDEX=$(expr ${ARCHIVE_INDEX} + 1)
	done
fi

# execute the tool using Major Hackett's approach
N_ATTEMPTS=1
HACKETT_OUT=""
while [  -z "${HACKETT_OUT}"  ]; do
	echo "Executing(${N_ATTEMPTS}): ${EXECUTABLE} ${COMMAND_LINE_PARAMETERS}"
	N_ATTEMPTS=$(expr ${N_ATTEMPTS} + 1)
	${EXECUTABLE} ${COMMAND_LINE_PARAMETERS}
	HACKETT_OUT="yes"
	for hackettinno in ${MAJOR_HACKETT}; do
		if [ ! -s ${hackettinno} ]; then
			# expected output not found or size zero
			HACKETT_OUT=""
			sleep 2
			break;
		fi
	done
done


# compress the multi-file outputs
if [ -n "$OUTPUT_PORTS_WITH_FILELIST" ]; then
	for output_port in ${OUTPUT_PORTS_WITH_FILELIST}; do
		echo "compressing outputs for ${output_port}"
		# the name of the port would be similar to foo.tar.gz, so we need to strip the .tar.gz (7 chars long) off the name
		# tools have been configured to output files using the following pattern:
		# 0_[foo].[bar], 1_[foo].[bar], ... 
		tar cfz ${output_port} *_${output_port:0:(-7)}
	done
fi