require "rails_helper"

describe DataExportTaskJob do
  let(:task) { create(:task, job_class: DataExportTaskJob) }
  let(:data_export) { create(:data_export) }

  context "has errors on some loans" do
    it "should fail and have relevant activity message" do
      allow(::DataExportService).to receive(:run).and_raise DataExportError
      expect { DataExportTaskJob.perform_now(task_id: task.id, data_export_id: data_export.id) }.to raise_error DataExportError
      expect(task.reload.status).to eq :failed
      expect(task.reload.activity_message_value).to eq "finished_with_custom_error_data"
    end
  end

  context "no errors" do
    it "should succeed and have appropriate activity message" do
      allow(::DataExportService).to receive(:run).and_return(0)
      DataExportTaskJob.perform_now(task_id: task.id, data_export_id: data_export.id)
      expect(task.reload.status).to eq :succeeded
      expect(task.reload.activity_message_value).to eq "completed"
    end
  end
end
