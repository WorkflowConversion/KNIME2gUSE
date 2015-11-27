/**
 * Copyright (c) 2012, Luis de la Garza.
 *
 * This file is part of testFragment.
 * 
 * GenericKnimeNodes is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */
package com.workflowconversion.knime2guse.ui.wizard;

import java.io.File;
import java.util.Collection;

import org.apache.commons.lang.Validate;
import org.eclipse.ui.internal.dialogs.ExportWizard;
import org.knime.core.node.NodeLogger;
import org.knime.workbench.core.util.ImageRepository;
import org.knime.workbench.core.util.ImageRepository.SharedImages;
import org.knime.workbench.editor2.WorkflowEditor;

import com.workflowconversion.knime2guse.export.InternalModelConverter;
import com.workflowconversion.knime2guse.export.KnimeWorkflowExporter;
import com.workflowconversion.knime2guse.export.handler.NodeContainerConverter;
import com.workflowconversion.knime2guse.model.Workflow;

/**
 * 
 * 
 * @author Luis de la Garza
 */
// Eclipse discourages to use ExportWizard because of its dependencies.
// Since this fragment/plug-in is to be used in KNIME, there is no danger
// that the required dependency won't be included
@SuppressWarnings("restriction")
public class WorkflowExportWizard extends ExportWizard {

	protected static final NodeLogger LOGGER = NodeLogger.getLogger(WorkflowExportWizard.class);

	final WorkflowEditor workflowEditor;
	final Collection<KnimeWorkflowExporter> exporters;
	final Collection<NodeContainerConverter> nodeConverters;
	// pages
	final WorkflowExportPage workflowExportPage;

	/**
	 * Constructor.
	 */
	public WorkflowExportWizard(final WorkflowEditor workflowEditor, final Collection<KnimeWorkflowExporter> exporters,
			final Collection<NodeContainerConverter> nodeConverters) {
		Validate.notNull(workflowEditor, "workflowEditor is required and cannot be null");
		Validate.notEmpty(exporters, "exporter is required and cannot be null or empty");
		workflowExportPage = new WorkflowExportPage(exporters);

		setWindowTitle("Export a Workflow to other platforms");
		setDefaultPageImageDescriptor(ImageRepository.getImageDescriptor(SharedImages.ExportBig));
		setNeedsProgressMonitor(true);

		this.workflowEditor = workflowEditor;
		this.exporters = exporters;
		this.nodeConverters = nodeConverters;
	}

	/*
	 * (non-Javadoc)
	 * 
	 * @see org.eclipse.ui.internal.dialogs.ExportWizard#addPages()
	 */
	@Override
	public void addPages() {
		super.addPage(workflowExportPage);
	}

	/*
	 * (non-Javadoc)
	 * 
	 * @see org.eclipse.ui.internal.dialogs.ExportWizard#performFinish()
	 */
	@Override
	public boolean performFinish() {
		// check if we can finish in the first place
		if (!canFinish()) {
			return false;
		}

		// Obtain currently active workflow editor
		final InternalModelConverter converter = new InternalModelConverter(workflowEditor, nodeConverters);
		try {
			final Workflow workflow = converter.convert();
			// perform the export
			final KnimeWorkflowExporter exporter = workflowExportPage.getSelectedExporter();
			final String exportMode = workflowExportPage.getExportMode();
			if (exportMode != null) {
				exporter.setExportMode(exportMode);
			}
			if (LOGGER.isInfoEnabled()) {
				LOGGER.info("Exporting using " + exporter + ", mode=" + exportMode + ", file=" + workflowExportPage.getDestinationFile());
			}
			exporter.export(workflow, new File(workflowExportPage.getDestinationFile()));
			return true;
		} catch (final Exception e) {
			LOGGER.error("Could not export workflow", e);
			e.printStackTrace();
			return false;
		}
	}

}