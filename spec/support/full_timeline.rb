shared_context "full timeline" do
  # Creates a timeline that sorts as follows:
  #
  # root
  #   g1
  #     g1_s1      (2017-01-01, 5 days)
  #   g2
  #   g2_g1
  #     g2_g1_s1   (2017-01-01, 5 days)
  #   g2_g2
  #     g2_g2_s1   (2017-01-10, 5 days)
  #   g3
  #     g3_s1      (2017-01-01, 10 days)
  #     g3_s2      (2017-02-01, 2 days)
  #     g3_s3      (2017-02-01, 5 days)
  #     g3_s4      (no date, no days)
  #   s1           (2017-02-28, 30 days)
  #   g4
  #     g4_s1      (2017-03-01, 0 days)
  #   g5
  #     g5_s1      (no date, 3 days)
  #   g6
  #     s2         (no date, 0 days)
  #
  # But creates in a jumbled order so that we know sort works properly.

  let(:project) { create(:loan) }
  let!(:root) { create(:root_project_group, project: project) }
    let!(:g3) { create_group(root) }
      let!(:g3_s3) { create_step(g3, "2017-02-01", 5) }
      let!(:g3_s2) { create_step(g3, "2017-02-01", 2) }
      let!(:g3_s4) { create_step(g3, nil, nil) }
      let!(:g3_s1) { create_step(g3, "2017-01-01", 10) }
    let!(:g1) { create_group(root) }
      let!(:g1_s1) { create_step(g1, "2017-01-01", 5) }
    let!(:g5) { create_group(root) }
      let!(:g5_s1) { create_step(g5, nil, 3) }
    let!(:g6) { create_group(root) }
    let!(:g4) { create_group(root) }
      let!(:g4_s1) { create_step(g4, "2017-03-01", 0) }
    let!(:g2) { create_group(root) }
      let!(:g2_g2) { create_group(g2) }
        let!(:g2_g2_s1) { create_step(g2_g2, "2017-01-10", 5) }
      let!(:g2_g1) { create_group(g2) }
        let!(:g2_g1_s1) { create_step(g2_g1, "2017-01-01", 5) }
    let!(:s2) { create_step(root, nil, 0) }
    let!(:s1) { create_step(root, "2017-02-28", 30) }

  def create_group(parent)
    create(:project_group, project: parent.project, parent: parent).tap do |group|
      parent.children << group
    end
  end

  def create_step(parent, scheduled_start_date, scheduled_duration_days)
    create(:project_step,
      project: parent.project,
      parent: parent,
      scheduled_start_date: scheduled_start_date,
      scheduled_duration_days: scheduled_duration_days
    ).tap do |step|
      parent.children << step
    end
  end
end
