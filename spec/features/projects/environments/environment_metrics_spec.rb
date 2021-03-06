require 'spec_helper'

feature 'Environment > Metrics', :feature do
  include PrometheusHelpers

  given(:user) { create(:user) }
  given(:project) { create(:prometheus_project) }
  given(:pipeline) { create(:ci_pipeline, project: project) }
  given(:build) { create(:ci_build, pipeline: pipeline) }
  given(:environment) { create(:environment, project: project) }
  given(:current_time) { Time.now.utc }

  background do
    project.add_developer(user)
    create(:deployment, environment: environment, deployable: build)
    stub_all_prometheus_requests(environment.slug)

    gitlab_sign_in(user)
    visit_environment(environment)
  end

  around do |example|
    Timecop.freeze(current_time) { example.run }
  end

  context 'with deployments and related deployable present' do
    scenario 'shows metrics' do
      click_link('See metrics')

      expect(page).to have_css('svg.prometheus-graph')
    end
  end

  def visit_environment(environment)
    visit namespace_project_environment_path(environment.project.namespace,
                                             environment.project,
                                             environment)
  end
end
