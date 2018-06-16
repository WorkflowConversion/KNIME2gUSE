#!/usr/bin/env bash
# THIS FILE WAS AUTOMATICALLY GENERATED BY THE KNIME2GUSE KNIME EXTENSION

# contains names of input ports that take filelists
INPUT_PORTS_WITH_FILELIST="@@INPUT_PORTS_WITH_FILELIST@@"
# contains names of output ports that generate filelists
OUTPUT_PORTS_WITH_FILELIST="@@OUTPUT_PORTS_WITH_FILELIST@@"
EXECUTABLE="@@EXECUTABLE@@"

for input_port in ${INPUT_PORTS_WITH_FILELIST}; do
	echo "expanding ${input_port}"
	echo tar xfz ${input_port}
done

# execute the tool
echo "Executing: ${EXECUTABLE} $@"
${EXECUTABLE} $@

# compress the multi-file outputs and make sure to name the archive using port name and .tar.gz as extension
# see: com.workflowconversion.knime2grid.export.workflow.ConverterUtils.generateFileNameForExport(String, String, int) and
#      com.workflowconversion.knime2grid.export.workflow.impl.guse.GuseKnimeWorkflowExporter.fixPortName(Port)
for output_port in ${OUTPUT_PORTS_WITH_FILELIST}; do
	echo "compressing ${output_port}"
	# tools have been configured to output files using the following pattern:
	# 0_[port_name].[ext], 1_[port_name].[ext], ... , n_[port_name].[ext]
	echo tar cfz ${output_port}.tar.gz *_${output_port}
done